// 切换到admin数据库
db = db.getSiblingDB('admin');

// 创建root用户(已通过环境变量创建，这里可以省略)
// db.createUser({
//   user: 'admin',
//   pwd: 'admin123',
//   roles: [ { role: "root", db: "admin" } ]
// });

// 在 MongoDB 容器首次启动时自动执行的脚本
// 获取环境变量中的数据库名称，如果未设置则使用默认值'mydb'
const dbName = process.env.MONGO_INITDB_DATABASE || 'mydb';
console.log('创建数据库: ', dbName);

// 切换到业务数据库
db = db.getSiblingDB(dbName);

// 创建具体业务数据库的用户
db.createUser({
  user: 'xiaohan',
  pwd: 'xiaohan123',
  roles: [
    { role: 'readWrite', db: dbName },
    { role: 'dbAdmin', db: dbName }
  ]
});

// 可以在这里添加一些初始化数据
// db.collections.insertMany([...])
