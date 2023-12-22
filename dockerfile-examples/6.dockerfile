FROM node:20-alpine

WORKDIR /app

# nodejs 运行环境，pnpm 管理依赖
COPY package.json pnpm-lock.yaml .

RUN npm config set registry https://registry.npmmirror.com/

RUN corepack enable
RUN pnpm install

COPY . .

# 构建
RUN pnpm run build


# 发布只需要构建产物及依赖即可
FROM node:20-alpine
COPY --from=builder app/dist app/dist

EXPOSE 3000
