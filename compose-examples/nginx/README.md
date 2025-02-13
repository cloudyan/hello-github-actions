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
