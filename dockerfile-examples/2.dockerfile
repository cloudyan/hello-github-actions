# FROM node:latest
FROM node:18-alpine

WORKDIR /app

COPY package.json pnpm-lock.yaml .

RUN npm config set registry https://registry.npmmirror.com/

RUN npm i -g pnpm serve
RUN pnpm install

COPY . .

RUN npm run build

EXPOSE 5173

CMD ["serve", "dist", "-l", "5173"]
# CMD ["npm", "run", "dev"]
# CMD ["sleep", "10m"]

# docker build -f dockerfile-examples/2.dockerfile -t hello:2 .
# docker run -d --name hello-2 -p 5173:5173 hello:2
