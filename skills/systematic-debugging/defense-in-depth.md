# 纵深防御验证（Defense-in-Depth Validation）

## 概述

当你修复一个由无效数据导致的 bug 时，只在一处加校验似乎就够了。但这一处检查可能被不同的代码路径、重构或 mock 绕过。

**核心原则：** 在数据流经的每一层（EVERY layer）都做校验，让这个 bug 在结构上不可能发生。

## 为什么需要多层

单层校验：“我们修复了这个 bug”
多层防御：“我们让这个 bug 不可能发生”

不同的层捕获不同的情况：
- 入口校验捕获大多数 bug
- 业务逻辑捕获边界情况
- 环境防护阻止特定上下文中的危险操作
- 调试日志在其他层失效时提供帮助

## 四个层级

### 第 1 层：入口点校验
**目的：** 在 API 边界拒绝明显无效的输入

```typescript
function createProject(name: string, workingDirectory: string) {
  if (!workingDirectory || workingDirectory.trim() === '') {
    throw new Error('workingDirectory cannot be empty');
  }
  if (!existsSync(workingDirectory)) {
    throw new Error(`workingDirectory does not exist: ${workingDirectory}`);
  }
  if (!statSync(workingDirectory).isDirectory()) {
    throw new Error(`workingDirectory is not a directory: ${workingDirectory}`);
  }
  // ... 继续执行
}
```

### 第 2 层：业务逻辑校验
**目的：** 确保数据对当前操作而言是合理的

```typescript
function initializeWorkspace(projectDir: string, sessionId: string) {
  if (!projectDir) {
    throw new Error('projectDir required for workspace initialization');
  }
  // ... 继续执行
}
```

### 第 3 层：环境防护
**目的：** 阻止特定上下文中的危险操作

```typescript
async function gitInit(directory: string) {
  // 在测试中，拒绝在临时目录之外执行 git init
  if (process.env.NODE_ENV === 'test') {
    const normalized = normalize(resolve(directory));
    const tmpDir = normalize(resolve(tmpdir()));

    if (!normalized.startsWith(tmpDir)) {
      throw new Error(
        `Refusing git init outside temp dir during tests: ${directory}`
      );
    }
  }
  // ... 继续执行
}
```

### 第 4 层：调试插桩
**目的：** 捕获上下文，供事后取证

```typescript
async function gitInit(directory: string) {
  const stack = new Error().stack;
  logger.debug('About to git init', {
    directory,
    cwd: process.cwd(),
    stack,
  });
  // ... 继续执行
}
```

## 应用该模式

当你发现一个 bug 时：

1. **追踪数据流** - 错误的值从哪里产生？在哪里被使用？
2. **梳理所有检查点** - 列出数据流经的每一个点
3. **在每一层都加校验** - 入口、业务、环境、调试
4. **测试每一层** - 尝试绕过第 1 层，验证第 2 层能捕获它

## 来自会话的示例

Bug：空的 `projectDir` 导致在源码目录中执行了 `git init`

**数据流：**
1. 测试准备 → 空字符串
2. `Project.create(name, '')`
3. `WorkspaceManager.createWorkspace('')`
4. `git init` 在 `process.cwd()` 中运行

**新增的四层：**
- 第 1 层：`Project.create()` 校验非空/存在/可写
- 第 2 层：`WorkspaceManager` 校验 projectDir 非空
- 第 3 层：`WorktreeManager` 在测试中拒绝在 tmpdir 之外执行 git init
- 第 4 层：在 git init 之前记录堆栈跟踪日志

**结果：** 全部 1847 个测试通过，bug 已不可能复现

## 关键洞见

四层都是必要的。测试过程中，每一层都捕获了其他层漏掉的 bug：
- 不同的代码路径绕过了入口校验
- mock 绕过了业务逻辑检查
- 不同平台上的边界情况需要环境防护
- 调试日志识别出了结构性的误用

**不要只在一处校验就停下。** 在每一层都加检查。
