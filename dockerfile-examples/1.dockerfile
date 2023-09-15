FROM nginx:alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY dist /usr/share/nginx/html

# docker build -f dockerfile-examples/1.dockerfile -t hello:1 .
# docker run -d --name hello-1 -p 8090:80 hello:1
