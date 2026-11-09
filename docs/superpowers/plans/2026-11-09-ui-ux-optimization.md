# Research Workspace UI/UX Optimization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 将现有 Vue 研究工作台优化为层级清楚、可长期使用、移动端友好且具备真实天气与可互动桌宠的统一界面。

**Architecture:** 保留 Vue 3 + Vue Router + Vite 和现有数据模型，在 `App.vue` 统一壳层，在页面组件中保留现有内容并加强信息层级；天气请求在首页内用 AbortController 管理生命周期，桌宠用 CSS 状态帧和可访问按钮实现，不增加大型依赖或后端。

**Tech Stack:** Vue 3 script setup, Vue Router, CSS variables, Open-Meteo REST API, Browser Geolocation API。

## Global Constraints

- 不修改 `public/legacy-papers` 的论文内容。
- 不破坏现有路由和现有数据内容。
- 不新增大型 UI 框架或 API key。
- 所有请求、定时器和事件监听必须在组件卸载时清理。
- 支持 `prefers-reduced-motion`，页面不能产生整体横向滚动。

### Task 1: Shared shell and design tokens

**Files:** `src/App.vue`, `src/styles.css`

- [ ] 移除干扰阅读的漂浮装饰，统一品牌、副标题、活动导航、focus-visible 和简洁 footer。
- [ ] 整理 CSS 变量、页面宽度、间距、圆角、边框、阴影、状态色，并补齐移动导航滚动和断点。
- [ ] 保留桌面顶部导航与手机横向导航，但禁止页面整体横向滚动。

### Task 2: Home workspace and utilities

**Files:** `src/views/HomeView.vue`, `src/styles.css`

- [ ] 保持研究内容在生活模块之前，增加明确的最近工作、项目状态、论文入口和今日提示层级。
- [ ] 将天气请求改成可取消、可刷新、定位后反向地理编码、IP fallback、30 分钟刷新，并展示来源与错误状态。
- [ ] 将桌宠由 emoji 替换为固定尺寸 CSS sprite-like 状态帧，支持 idle/blink/happy/play、暂停和 reduced motion。

### Task 3: Archive and progress scanning

**Files:** `src/views/PapersIndexView.vue`, `src/views/DailyWorkView.vue`, `src/views/ProjectProgressView.vue`, `src/styles.css`

- [ ] 给论文档案增加关键词搜索、状态筛选、无结果状态和明确打开按钮。
- [ ] 统一每日工作与项目进展的可展开时间线、状态标签、长文本换行和移动端单列布局。
- [ ] 让项目页明确显示已完成、当前推进、HOLD 和下一步。

### Task 4: Verification

**Files:** none

- [ ] 执行 `npm.cmd run build`。
- [ ] 启动 `npm.cmd run dev -- --host 127.0.0.1 --port 8000` 并检查核心路由响应。
- [ ] 检查无构建错误、路由可加载、天气失败不影响页面、移动布局不横向溢出。
