# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概览

这是一个基于 Hugo 静态站点生成器构建的个人博客/文档网站（logosblog.com），主要用于分享信息技术、心理学等领域的知识内容。

- **站点生成器**: Hugo 0.134+ (需要 extended 版本)
- **主题**: hugo-book (通过 git submodule 管理)
- **主要语言**: 简体中文
- **内容格式**: Markdown 文件，使用 YAML/TOML frontmatter

## 常用命令

### 本地开发
```bash
# 启动本地开发服务器（支持热重载）
hugo server --minify --theme hugo-book

# 或者使用草稿模式查看未发布内容
hugo server --buildDrafts --minify --theme hugo-book
```

本地服务器默认运行在 `http://localhost:1313`

### 构建生产版本
```bash
# 生成静态站点到 public/ 目录
hugo --minify
```

### 内容管理
```bash
# 创建新文章（会使用 archetypes/default.md 模板）
hugo new docs/信息技术/新文章名称.md

# 创建新章节
hugo new docs/新章节/_index.md
```

新创建的文件默认是草稿状态 (`draft = true`)，发布前需要改为 `draft = false` 或删除该字段。

### Git Submodule（主题管理）
```bash
# 首次克隆仓库后，初始化并更新主题
git submodule update --init --recursive

# 更新主题到最新版本
cd themes/hugo-book
git pull origin master
cd ../..
git add themes/hugo-book
git commit -m "更新 hugo-book 主题"
```

## 代码架构

### 目录结构

```
logosblog/
├── content/              # 内容目录（所有 Markdown 文章）
│   ├── _index.md         # 网站首页
│   ├── quotes.md         # 每日格言数据源（headless page）
│   └── docs/             # 文档分类目录
│       ├── 信息技术/      # 技术文章（Java、架构设计等）
│       ├── 心理学/        # 心理学文章（认知心理学、人际关系等）
│       └── 其他/          # 其他内容（工具、教程等）
│
├── layouts/              # 自定义模板（覆盖主题默认模板）
│   ├── partials/         # 局部模板片段
│   │   └── docs/
│   │       ├── html-head-favicon.html  # 多格式网站图标配置
│   │       └── html-head-title.html    # 动态页面标题生成
│   └── shortcodes/       # 自定义短代码
│       ├── daily-quote.html           # 随机每日格言
│       ├── latest-posts.html          # 最新单篇文章
│       ├── recent-posts.html          # 近期文章列表
│       ├── recommended-posts.html     # 推荐文章（featured）
│       └── tags-list.html             # 标签云
│
├── static/               # 静态资源（favicon、图片等）
├── themes/hugo-book/     # Hugo Book 主题（git submodule）
├── archetypes/           # 内容模板
│   └── default.md        # 默认文章模板（TOML frontmatter）
└── hugo.toml             # Hugo 主配置文件
```

### 内容组织架构

1. **层级结构**: 使用 `_index.md` 定义章节，支持无限层级嵌套
2. **导航排序**: 通过 frontmatter 中的 `weight` 字段控制排序（数字越小越靠前）
3. **章节折叠**: 使用 `bookCollapseSection: true` 实现可折叠侧边栏
4. **推荐内容**: 通过 `featured: true` 标记推荐文章
5. **标签系统**: 使用 `tags` 字段分类文章

### 自定义短代码系统

项目实现了 5 个自定义短代码，用于动态内容展示：

1. **`{{< daily-quote >}}`**
   - 功能：从 `content/quotes.md` 随机展示一条格言
   - 实现：使用 JavaScript 客户端随机选择，支持紫色主题样式
   - 位置：layouts/shortcodes/daily-quote.html:1-65

2. **`{{< latest-posts >}}`**
   - 功能：显示最新的一篇文章（非章节页）
   - 排序：按发布日期降序

3. **`{{< recent-posts limit=10 >}}`**
   - 功能：显示最近 N 篇文章列表
   - 参数：`limit` 指定显示数量

4. **`{{< recommended-posts >}}`**
   - 功能：显示所有标记为 `featured: true` 的文章
   - 用途：首页推荐内容展示

5. **`{{< tags-list >}}`**
   - 功能：展示所有文章标签及统计数量
   - 用途：标签云功能

### Hugo 配置要点

**hugo.toml 关键配置**:
```toml
baseURL = 'https://logosblog.com/'
languageCode = 'zh-cn'
title = '𝓛𝓸𝓰𝓸𝓼'
theme = 'hugo-book'
enableEmoji = true

[params]
  BookTheme = "light"        # 固定使用亮色主题
  BookToC = true             # 启用右侧目录

[markup.goldmark.renderer]
  unsafe = true              # 允许在 Markdown 中使用 HTML

[markup.highlight]
  style = "monokai"          # 代码高亮：Monokai 主题
  lineNos = true             # 显示代码行号
```

### Frontmatter 标准格式

```toml
+++
title = '文章标题'
date = '2025-01-15T10:00:00+08:00'
draft = false
weight = 10                    # 可选：控制排序
bookCollapseSection = true     # 可选：章节折叠
featured = true                # 可选：推荐文章标记
tags = ['Java', 'Spring', '微服务']  # 可选：标签
+++
```

## 开发注意事项

### 内容创建规范

1. **章节页面** (`_index.md`): 用于创建导航分类，必须包含 `bookCollapseSection` 等元数据
2. **普通页面** (`.md`): 具体文章内容，需要包含 title、date 等基本字段
3. **草稿状态**: 新建内容默认为 `draft = true`，发布前需改为 `false` 或删除该字段
4. **文件命名**: 支持中文文件名，Hugo 会自动生成友好的 URL

### 主题定制原则

- **不直接修改主题文件**: themes/hugo-book/ 是 git submodule，应通过 layouts/ 目录覆盖
- **Partial 覆盖**: layouts/partials/docs/ 中的文件优先级高于主题默认
- **短代码扩展**: 所有自定义短代码放在 layouts/shortcodes/
- **静态资源**: 直接放在 static/ 目录，Hugo 会自动处理

### 格言系统（quotes.md）

`content/quotes.md` 是一个特殊的 headless page，用于存储每日格言数据：

```yaml
---
headless: true
quotes:
  - "第一条格言内容"
  - "第二条格言内容"
  - "第三条格言内容"
---
```

- **不会生成独立页面**: `headless: true` 确保该页面不出现在导航中
- **数据源**: daily-quote shortcode 会读取 `quotes` 数组
- **随机展示**: 每次页面加载随机选择一条格言

### 构建输出说明

- **public/**: 生产环境静态文件输出目录（已在 .gitignore 中）
- **resources/**: Hugo 资源缓存目录（已在 .gitignore 中）
- **.hugo_build.lock**: Hugo 构建锁文件（已在 .gitignore 中）

这些目录无需提交到 Git 仓库。

## 分支管理

- **主分支**: `master` - 用于创建 Pull Request
- **开发分支**: `develop` - 当前工作分支

## 技术栈说明

- **Markdown 渲染器**: Goldmark（Hugo 默认）
- **代码高亮**: Chroma（内置）
- **搜索功能**: Flexsearch（主题集成，客户端 JavaScript 实现）
- **PWA 支持**: 已配置 manifest 和 service worker
- **图标格式**: 支持 favicon.ico、PNG、Apple Touch Icon、Android Chrome

## 主题文档

Hugo Book 主题的完整文档位于: `themes/hugo-book/README.md`

如需了解主题的高级功能（如 Mermaid 图表、数学公式、自定义菜单等），请参考主题文档。
