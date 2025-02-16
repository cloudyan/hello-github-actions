// 切换到admin数据库
db = db.getSiblingDB('admin');

// 创建root用户(已通过环境变量创建，这里可以省略)
// db.createUser({
//   user: 'admin',
//   pwd: 'admin123',
//   roles: [ { role: "root", db: "admin" } ]
// });

// 切换到业务数据库
db = db.getSiblingDB('blog');

// 创建具体业务数据库的用户
db.createUser({
  user: 'blog_admin',
  pwd: 'blog_admin123',
  roles: [
    { role: 'readWrite', db: 'blog' },
    { role: 'dbAdmin', db: 'blog' }
  ]
});

// 可以在这里添加一些初始化数据
// db.collections.insertMany([...])
