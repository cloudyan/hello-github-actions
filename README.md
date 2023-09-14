# CI/CD

使用 github actions 做 CI/CD 案例实践

## 基本概念

前面了解了 CI, CD, 构建容器以及部署容器，接下来我们做个案例实践

单独构建一套完整流程比较复杂，市面上常见的 CI/CD 系统有很多

- Jenkins
- Drone CI
- Travis CI
- CircleCI
- Github Actions
- Gitlab Runners
- ...

每一家 CI/CD 产品，都有各自的配置方式，但总体上用法差不多。

我们先了解下 CI/CD 基本术语

- `runner`: 用来执行 CI/CD 的构建服务器
- `workflow/pipeline`（工作流程）: 持续集成一次运行的过程，就是一个 workflow。
- `job`（任务）: 一个 workflow 由一个或多个 jobs 构成，含义是一次持续集成的运行，可以完成多个任务。
- `step`（步骤）: 每个 job 由多个 step 构成，一步步完成。
- `action`（动作）: 每个 step 可以依次执行一个或多个命令（action）。

### 示例

```yml
name: hello-github-actions

on: [push]

jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: 18
          cache: 'pnpm'
      - run: pnpm install --frozen-lockfile
      - run: pnpm build
```

## github actions 实战

使用 github actions 自定义实现 CI/CD 工作流，实现目标如下

场景诉求：对一个前端服务，实现以下功能流程

1. 持续集成 CI
   1. push 提交代码自动构建
   2. 支持代码检查 lint
   3. 支持自动测试 test
   4. 支持预览链接
2. 持续部署 CD
   1. 提交 PR 自动检查
   2. 完成 PR 自动部署服务

### 初始化项目

```bash
npm create vite@latest
```

### github actions

参见文档：https://docs.github.com/zh/actions/learn-github-actions/understanding-github-actions
