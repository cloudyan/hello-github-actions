# FROM node:latest
FROM node:20-alpine

WORKDIR /app

COPY package.json pnpm-lock.yaml .

RUN npm config set registry https://registry.npmmirror.com/

RUN npm i -g pnpm serve
RUN pnpm install

COPY . .

# RUN npm run build

EXPOSE 5173

CMD ["serve", "dist", "-l", "5173"]
ENTRYPOINT ["npm", "run", "dev"]
CMD ["npm", "run", "dev"]
CMD ["sleep", "5s"]
ENTRYPOINT ["sleep", "10s"]
ENTRYPOINT ["sleep"]
CMD ["20s"]

# docker build -f dockerfile-examples/4.dockerfile -t hello:4 .
# docker run -d --name hello-4 -p 5175:5173 hello:4 npm run dev -- --host 0.0.0.0
# docker run -d --name hello-4 -p 5175:5173 --entrypoint npm hello:4 run dev -- --host 0.0.0.0
# docker run -d --name hello-4 -p 5175:5173 --entrypoint sleep hello:4 30s
