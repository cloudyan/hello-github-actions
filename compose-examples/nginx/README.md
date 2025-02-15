# 网关服务

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
- 数据服务层：MongoDB 数据库和 Redis 缓存服务，包含自动备份功能

### 2. 数据持久化

- docker-apps
  - frontend-dist：前端构建产物
  - backend-dist：后端构建产物
  - mongo-data：MongoDB 数据存储
  - mongo-backup：MongoDB 数据备份
  - redis-data：Redis 数据存储
  - nginx-certs：SSL 证书（对应 nginx/certs）
  - nginx-conf：Nginx 配置（对应 nginx/nginx.conf）
  - certbot-webroot：SSL 证书自动续期
- docker-backups
  - mongo-backup：MongoDB 数据备份

### 3. 服务拆分

为了增强系统的稳定性、可维护性和可扩展性，采用分层架构设计，每层服务使用独立的 docker-compose 文件管理：

- docker-compose.gateway.yml：网关层服务（Nginx + Certbot）
  - 提供统一的访问入口
  - 管理 SSL 证书的自动续期
  - 处理请求路由和负载均衡

- docker-compose.frontend.yml：前端服务层（Vue）
  - 部署静态资源
  - 通过 frontend-network 与网关层通信

- docker-compose.backend.yml：后端服务层（NestJS）
  - 提供 API 服务
  - 通过 backend-network 与网关层和数据层通信

- docker-compose.database.yml：数据服务层（MongoDB + Redis）
  - 提供数据存储和缓存服务
  - 通过 database-network 与后端服务层通信
  - 包含数据备份服务

服务间通过 Docker 网络实现通信：

```bash
# 创建网络
docker network create frontend-network  # 前端与网关层通信
docker network create backend-network   # 后端与网关层通信
docker network create database-network  # 后端与数据层通信
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
