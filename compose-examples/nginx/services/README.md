# 服务

```bash
ln -s /xxx/xx/docker-apps ~/docker-apps

# 在一个配置文件内维护，但可以单个服务来启动以及重启 相互独立，互不影响，分层架构，独立部署维护
docker compose -f ./docker-compose.yml -p local up -d
docker compose -f ./docker-compose.yml -p local up -d frontend backend minio gateway certbot mongo mongo-backup
docker compose -f ./docker-compose.backend.yml -p local restart backend
```

## 服务链路

```bash
user -> nginx (/api) -> nestjs
user -> nginx (/) -> vue(dist)
```

## 设计方案

### 1. 服务架构

系统采用分层架构设计，按功能模块拆分为以下几层：

- 网关层：Nginx 作为统一入口，配置 SSL 证书自动续期
- 前端服务层：Vue 静态资源部署
- 后端服务层：NestJS API 服务
- 数据服务层：
  - MongoDB 数据库：结构化数据存储
  - MinIO 对象存储：文件存储服务
- 辅助服务层：
  - 数据自动备份功能
  - SSL 证书自动续期

### 2. 数据持久化

持久化映射的数据目录结构：

- docker-apps
  - frontend
    - dist：前端构建产物
    - nginx.conf：前端服务 Nginx 配置
  - backend
    - dist：后端构建产物
  - mongodb
    - data：MongoDB 数据存储
    - config: MongoDB 配置
    - backups：MongoDB 数据备份
  - minio
    - data：对象存储数据
    - config：MinIO 配置
    - certs：MinIO SSL 证书
  - gateway
    - certs：SSL 证书
    - nginx.conf：Nginx 配置
  - certbot
    - certs：SSL 证书
    - wwwroot：SSL 证书存储目录
- docker-backups
  - mongo-backup：MongoDB 数据备份

### 3. 服务拆分

为了增强系统的稳定性、可维护性和可扩展性，采用分层架构设计，每层服务使用独立的 docker-compose 文件管理：

- docker-compose.gateway.yml：网关层服务（Nginx + Certbot）
  - 提供统一的访问入口
  - 管理 SSL 证书的自动续期
  - 处理请求路由和负载均衡
  - 对应 gateway/nginx.conf 配置文件

- docker-compose.frontend.yml：前端服务层（Vue）
  - 部署静态资源
  - 通过 frontend-network 与网关层通信
  - 对应 frontend/nginx.conf 配置文件

- docker-compose.backend.yml：后端服务层（NestJS）
  - 提供 API 服务
  - 通过 backend-network 与网关层和数据层通信

- docker-compose.database.yml：数据服务层
  - MongoDB：提供结构化数据存储服务
  - MongoDB 额外通过 database-network 与后端服务层通信

- docker-compose.minio.yml：对象存储服务层
  - MinIO：提供对象存储服务
  - MinIO 额外通过 storage-network 提供存储服务

- docker-compose.backup.yml：数据备份服务
  - 包含数据备份服务
  - 通过 database-network 与数据服务层通信
  - 备份文件存储到 docker-backups 中

- docker-compose.certbot.yml
  - 使用 Certbot 自动生成和管理 SSL 证书
  - 管理 SSL 证书的自动续期

服务间通过 Docker 网络实现通信：

```bash
# 创建网络
docker network create frontend-network  # 前端与网关层通信
docker network create backend-network   # 后端与网关层通信
docker network create database-network  # 后端与数据层通信
docker network create storage-network  # 后端与存储通信
```

### 4. 路由规则

- `/api/*`: 转发到 NestJS 后端服务（端口 3000）
- `/*`: 指向前端构建产物目录（端口 80）

### 5. 性能优化

- 启用 GZIP 压缩
- 配置静态资源缓存策略
- 开启 HTTP2 支持
- 配置 keepalive 连接

### 6. 安全措施

- 配置安全相关的 HTTP 头
- 限制上传文件大小
- 关闭服务器版本显示
- 数据自动备份策略
  - MongoDB 数据每 24 小时自动备份一次
  - 备份文件按时间戳存储

### 7. 高可用配置

- 自动选择工作进程数
- 配置连接超时时间
- 错误页面处理
- 服务健康检查
- 容器自动重启策略
