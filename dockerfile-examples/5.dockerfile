# 多阶段构建
FROM node:18-alpine as builder

WORKDIR /app

# 单独分离 package.json，是为了安装依赖可最大限度利用缓存
# COPY package.json pnpm-lock.yaml /app/
COPY package.json pnpm-lock.yaml .

RUN npm config set registry https://registry.npmmirror.com/

RUN npm i -g pnpm serve
RUN pnpm install

COPY . .

RUN npm run build

# 选择更小体积的基础镜像
FROM nginx:alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder app/dist /usr/share/nginx/html

# EXPOSE 80

# docker build -f dockerfile-examples/5.dockerfile -t hello:5 .
# docker run -d --name hello-5 -p 8091:80 hello:5
