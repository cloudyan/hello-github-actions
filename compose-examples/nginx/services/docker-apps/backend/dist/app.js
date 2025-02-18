const express = require('express')
const multer = require('multer')

const app = express()
const port = 8001

// 添加 CORS 中间件，允许所有域名跨域访问
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*')
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept')
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
  // 处理 OPTIONS 预检请求
  if (req.method === 'OPTIONS') {
    return res.sendStatus(200)
  }
  next()
})

// 添加请求体解析中间件
app.use(express.json({ limit: '1mb' }))
app.use(express.urlencoded({ extended: true, limit: '1mb' }))

// 添加请求体解析错误处理
app.use((err, req, res, next) => {
  if (err instanceof SyntaxError && err.status === 400 && 'body' in err) {
    return res.status(400).json(createResponse({
      data: null,
      code: 400,
      message: '无效的请求数据格式'
    }))
  }
  next()
})

// 添加 multipart/form-data 解析中间件
const upload = multer({ limits: { fileSize: 1 * 1024 * 1024 } }) // 限制文件大小为10MB

// 统一的响应格式
const createResponse = ({
  data = null,
  code = 0,
  message = 'success'
}) => ({
  data,
  code,
  message,
  timestamp: Date.now()
})

app.get('/api/hello', (req, res) => {
  res.json(createResponse({ data: {greeting: 'Hello World!'} }))
})

app.post('/api/echo', (req, res) => {
  try {
    const requestData = req.body
    console.log(requestData);
    res.json(createResponse({
      data: requestData
    }))
  } catch (err) {
    res.status(400).json(createResponse({
        data: null,
        code: 400,
        message: err.message || '请求处理失败'
      }
    ))
  }
})

// 服务器部署验证
app.get('/health', function (req, res) {
  return res.status(200).send('OK');
});

// 错误处理中间件
app.use((err, req, res, next) => {
  console.error('Error:', err)
  res.status(500).json(createResponse({
      data: null,
      code: 500,
      message: '服务器内部错误'
    }
  ))
})

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})
