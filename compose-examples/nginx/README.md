# 网关服务

## 服务链路

```bash
user -> nginx (/api) -> nestjs
user -> nginx (/) -> vue(dist)
```

## 设计方案

### 1. 服务架构

- 前端服务：Vue 静态资源部署在 Nginx
- 后端服务：NestJS API 服务
- 网关层：Nginx 作为统一入口
- 数据库：MongoDB@4.4
- 缓存服务：Redis

### 数据持久化

- docker-apps
  - frontend-dist
  - backend-dist
  - mongo-data
  - redis-data
  - nginx-certs 对应 nginx/certs
  - nginx-conf 对应 nginx/nginx.conf
  - certbot-webroot
- docker-backups

## 拆分

将所有服务放在一个 docker-compose 文件中确实可以方便管理和部署，但随着系统复杂度的增加，这种方式可能会导致一些问题，比如服务之间的耦合度过高、资源分配不合理、维护成本增加等。为了增强系统的稳定性、可维护性和可扩展性，可以考虑以下优化设计方案：

### 分层架构设计

将系统按照功能模块划分为不同的层级，例如：

- 前端服务：如 nginx 和 certbot。
- 后端服务：如 api（Node.js 应用）。
- 数据库服务：如 mongo 和 redis。
- 辅助服务：如 mongo-backup。

虽然服务被拆分到不同的 docker-compose 文件中，但可以通过 Docker 网络将它们连接起来。

```bash
docker network create frontend-network
docker network create backend-network
```

### 2. 路由规则

- `/api/*`: 转发到 NestJS 后端服务（端口 3000）
- `/*`: 指向前端构建产物目录（端口 80）

### 3. 性能优化

- 启用 GZIP 压缩
- 配置静态资源缓存策略
- 开启 HTTP2 支持
- 配置 keepalive 连接

### 4. 安全措施

- 配置安全相关的 HTTP 头
- 限制上传文件大小
- 关闭服务器版本显示

### 5. 高可用配置

- 自动选择工作进程数
- 配置连接超时时间
- 错误页面处理
