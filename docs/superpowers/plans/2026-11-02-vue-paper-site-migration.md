# Vue Paper Site Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 将现有三个独立 HTML 论文页面迁移到 Vue 3 + Vite 单页应用，提供首页、路由、统一导航和可复用论文容器，同时保留现有论文内容与图片资源。

**Architecture:** 使用 Vite 作为构建工具，Vue Router 管理 `/`, `/papers/dyramo`, `/papers/pharmagent`, `/papers/pmmg` 路由。旧页面移动到 `public/papers` 作为内容源，由 `LegacyPaper` Vue 组件加载、提取样式与正文并在路由切换时清理，确保已有交互和 MathJax 内容继续工作；Vue 应用负责站点级导航、首页和页面状态。

**Tech Stack:** Vue 3, Vite, Vue Router 4, 原生 JavaScript, 现有 HTML/CSS/PNG 资源。

## Global Constraints

- 保留现有三个论文页面的正文、图片和交互表现。
- 使用 Vue 3 + Vite，不引入 React。
- 开发服务器使用 `npm run dev`，生产构建使用 `npm run build`。
- 不在仓库中提交 `node_modules` 或构建产物。

---

### Task 1: Scaffold Vue project

**Files:**
- Create: `package.json`
- Create: `index.html`
- Create: `vite.config.js`
- Create: `src/main.js`
- Create: `src/router.js`
- Create: `src/App.vue`
- Create: `src/styles.css`

**Interfaces:**
- `src/router.js` exports a Vue Router instance with the four application routes.
- `src/App.vue` renders the global shell and `<RouterView />`.

- [ ] **Step 1: Add package metadata and Vite scripts**

Use `vue`, `vue-router`, `vite`, and `@vitejs/plugin-vue` with scripts `dev`, `build`, and `preview`.

- [ ] **Step 2: Add the Vue entry and router**

Mount `App.vue` from `src/main.js`; configure history routing and routes for the home page plus three paper pages.

- [ ] **Step 3: Add the global shell and styles**

Create a responsive navigation bar with links to each paper and a `<RouterView />` content region. Keep global styles scoped to the new shell.

- [ ] **Step 4: Run the production build**

Run `npm install` then `npm run build`; expected result is a generated `dist` directory with exit code 0.

### Task 2: Move legacy pages into public content

**Files:**
- Create: `public/papers/DyRAMO.html`
- Create: `public/papers/PharmAgent.html`
- Create: `public/papers/PMMG.html`
- Move or copy: `pmmg_assets/**` to `public/papers/pmmg_assets/**`
- Move or copy: `pharmagent_assets/**` to `public/papers/pharmagent_assets/**`

**Interfaces:**
- The URLs `/papers/DyRAMO.html`, `/papers/PharmAgent.html`, and `/papers/PMMG.html` remain fetchable by the Vue `LegacyPaper` component.
- Relative image URLs inside the moved documents continue to resolve under `/papers/`.

- [ ] **Step 1: Copy each legacy HTML document and its referenced image directories**

Keep the original root files untouched until the new app has passed visual and HTTP checks.

- [ ] **Step 2: Normalize document-relative asset paths**

Confirm image paths remain relative to each HTML file and external MathJax remains available from its CDN URL.

- [ ] **Step 3: Request each public document directly**

Use `Invoke-WebRequest` against the Vite server and expect HTTP 200 for all three HTML files and one representative PNG.

### Task 3: Build reusable legacy-paper route component

**Files:**
- Create: `src/components/LegacyPaper.vue`
- Create: `src/views/HomeView.vue`
- Create: `src/views/PaperView.vue`
- Modify: `src/router.js`

**Interfaces:**
- `LegacyPaper` accepts `src` and `title` props and emits `loaded` and `error`.
- `PaperView` accepts a route `slug`, maps it to a safe public HTML source, and renders `LegacyPaper`.

- [ ] **Step 1: Implement safe source mapping in `PaperView.vue`**

Map only `dyramo`, `pharmagent`, and `pmmg` to known public paths; do not interpolate arbitrary route input into a request.

- [ ] **Step 2: Implement `LegacyPaper.vue` loading and cleanup**

Fetch the selected HTML, parse it with `DOMParser`, inject its `<style>` blocks and body markup into a scoped host, execute inline/external scripts in order, and remove injected styles/scripts/listeners on unmount or source change.

- [ ] **Step 3: Add loading, error, and retry UI**

Show a stable loading state, a readable error state, and a retry button if the document cannot be fetched.

- [ ] **Step 4: Create a useful home route**

List all three papers with titles and direct router links, plus a short status note explaining that the site is now a Vue app.

### Task 4: Validate routing, assets, and build output

**Files:**
- Modify: `src/styles.css` only for fixes found during validation.

**Interfaces:**
- All four routes render without uncaught Vue errors.
- `npm run build` succeeds from a clean dependency install.

- [ ] **Step 1: Start the Vite development server**

Run `npm run dev -- --host 127.0.0.1`; record the actual local URL.

- [ ] **Step 2: Validate HTTP routes and assets**

Request `/`, each paper route, each public paper source, and representative PNG assets; expect HTTP 200.

- [ ] **Step 3: Validate production build and preview**

Run `npm run build`, then `npm run preview -- --host 127.0.0.1`; request the built root and paper routes.

- [ ] **Step 4: Report the migration and next deployment command**

Provide the local URL, explain that `dist/` is the deployable output for Alibaba Cloud OSS, and mention that the original HTML files remain available as source references until the migration is confirmed.
