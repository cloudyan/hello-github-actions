#!/bin/bash

# 设置错误处理
set -e
set -o pipefail

# 定义颜色输出
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m" # No Color

# 定义日志文件
LOG_FILE="deploy_$(date +%Y%m%d_%H%M%S).log"

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

# 清理函数
cleanup() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        log_error "脚本执行失败，退出码: $exit_code"
    fi
    exit $exit_code
}

# 设置清理钩子
trap cleanup EXIT

# 检查 Docker 是否运行
if ! docker info > /dev/null 2>&1; then
    log_error "Docker 未运行，请先启动 Docker"
    exit 1
fi

# 检查必要的命令
for cmd in docker docker-compose mongodump curl; do
    if ! command -v $cmd &> /dev/null; then
        log_error "命令 '$cmd' 未找到"
        exit 1
    fi
done

# 创建必要的目录
DOCKER_APPS_DIR="$HOME/docker-apps"
for dir in frontend-dist backend-dist mongo-data redis-data nginx/certs nginx/nginx.conf certbot-webroot mongo-backup; do
    if ! mkdir -p "$DOCKER_APPS_DIR/$dir"; then
        log_error "创建目录 '$DOCKER_APPS_DIR/$dir' 失败"
        exit 1
    fi
done

# 检查目录是否就绪
check_directories() {
    local dir=$1
    if [ ! -d "$dir" ] || [ -z "$(ls -A "$dir")" ]; then
        log_error "目录 '$dir' 不存在或为空"
        return 1
    fi
    return 0
}

# 健康检查函数
health_check() {
    local service=$1
    local port=$2
    local endpoint=${3:-"/health"}
    local max_retries=30
    local retry_interval=2
    local retries=0

    log_info "正在检查 $service 服务健康状态..."
    while [ $retries -lt $max_retries ]; do
        if curl -s "http://localhost:${port}${endpoint}" > /dev/null 2>&1; then
            log_info "$service 服务健康检查通过"
            return 0
        fi
        retries=$((retries + 1))
        log_warn "$service 服务健康检查重试 $retries/$max_retries"
        sleep $retry_interval
    done

    log_error "$service 服务健康检查失败"
    return 1
}

# 备份数据库
backup_database() {
    log_info "开始备份数据库..."
    BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
    BACKUP_DIR="$DOCKER_APPS_DIR/mongo-backup/$BACKUP_DATE"

    if ! docker-compose -f docker-compose.backend.yml exec -T mongo mongodump --out /backup/$BACKUP_DATE; then
        log_error "数据库备份失败"
        return 1
    fi

    log_info "数据库备份完成: $BACKUP_DATE"
    echo "$BACKUP_DATE" > "$DOCKER_APPS_DIR/mongo-backup/latest_backup"
    return 0
}

# 恢复数据库
restore_database() {
    local backup_date=$1
    log_info "开始恢复数据库到备份点: $backup_date"

    if ! docker-compose -f docker-compose.backend.yml exec -T mongo mongorestore --drop /backup/$backup_date; then
        log_error "数据库恢复失败"
        return 1
    fi

    log_info "数据库恢复完成"
    return 0
}

# 启动数据库服务
start_database_services() {
    log_info "开始启动数据库服务..."

    # 启动 MongoDB 和 Redis
    if ! docker-compose -f docker-compose.backend.yml up -d mongo redis; then
        log_error "数据库服务启动失败"
        return 1
    fi

    # 等待数据库服务就绪
    sleep 5

    log_info "数据库服务启动成功"
    return 0
}

# 更新后端服务
update_backend() {
    log_info "开始更新后端服务..."

    # 检查后端代码是否就绪
    if ! check_directories "$DOCKER_APPS_DIR/backend-dist"; then
        return 1
    fi

    # 备份当前版本
    if ! backup_database; then
        return 1
    fi

    # 记录当前运行的容器版本
    local current_containers=$(docker-compose -f docker-compose.backend.yml ps -q)

    # 确保数据库服务运行
    if ! start_database_services; then
        return 1
    fi

    # 停止后端服务
    docker-compose -f docker-compose.backend.yml stop api

    # 启动后端服务
    if ! docker-compose -f docker-compose.backend.yml up -d api; then
        log_error "后端服务启动失败"
        return 1
    fi

    # 健康检查
    if ! health_check "backend" 3000 "/health"; then
        log_error "后端服务健康检查失败，准备回滚"
        docker-compose -f docker-compose.backend.yml stop api
        docker-compose -f docker-compose.backend.yml up -d $current_containers
        restore_database "$(cat "$DOCKER_APPS_DIR/mongo-backup/latest_backup")"
        return 1
    fi

    log_info "后端服务更新成功"
    return 0
}

# 更新前端服务
update_frontend() {
    log_info "开始更新前端服务..."

    # 检查前端代码是否就绪
    if ! check_directories "$DOCKER_APPS_DIR/frontend-dist"; then
        return 1
    fi

    # 记录当前运行的容器版本
    local current_containers=$(docker-compose -f docker-compose.frontend.yml ps -q)

    # 停止前端服务
    docker-compose -f docker-compose.frontend.yml down

    # 启动前端服务
    if ! docker-compose -f docker-compose.frontend.yml up -d; then
        log_error "前端服务启动失败"
        return 1
    fi

    # 健康检查
    if ! health_check "frontend" 80 "/"; then
        log_error "前端服务健康检查失败，准备回滚"
        docker-compose -f docker-compose.frontend.yml down
        docker-compose -f docker-compose.frontend.yml up -d $current_containers
        return 1
    fi

    log_info "前端服务更新成功"
    return 0
}

# 主函数
main() {
    log_info "开始部署和升级流程..."

    # 启动数据库服务
    if ! start_database_services; then
        log_error "数据库服务启动失败，终止部署"
        exit 1
    fi

    # 备份数据库
    if ! backup_database; then
        log_error "数据库备份失败，终止部署"
        exit 1
    fi

    # 更新后端服务
    if ! update_backend; then
        log_error "后端服务更新失败"
        exit 1
    fi

    # 更新前端服务
    if ! update_frontend; then
        log_error "前端服务更新失败"
        exit 1
    fi

    log_info "部署和升级完成"
}

# 执行主函数
main
