const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');

const app = express();

// 服务静态文件
app.use(express.static('public'));

const logProxyRequest = (proxyReq, req, res) => {
  console.log(`Proxying: ${req.method} ${req.url} -> ${proxyReq.path}`);
};

const handleProxyError = (err, req, res) => {
  console.error('Proxy error:', err);
  res.writeHead(500, {
    'Content-Type': 'text/plain',
  });
  res.end('Proxy error: ' + err.message);
};

// taroweb 项目代理
app.use('/api', createProxyMiddleware({
  target: 'http://127.0.0.1:4010',
  changeOrigin: true,
  ws: true,
  pathRewrite: {'^/api' : '/api'},
  onProxyReq: logProxyRequest,
  onError: handleProxyError,
}));

// 主项目代理(小贷项目)
app.use('/', createProxyMiddleware({
  target: 'http://127.0.0.1:3000',
  changeOrigin: true,
  ws: true, // 支持 websocket
  onProxyReq: logProxyRequest,
  onError: handleProxyError,
}));


app.listen(8080, () => {
  console.log('Proxy server running on http://localhost:8080');
});
