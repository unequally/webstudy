<script setup>
import { RouterLink, RouterView, useRoute } from 'vue-router'

const navItems = [
  { to: '/', label: '工作台' },
  { to: '/daily-work', label: '每日工作' },
  { to: '/papers', label: '已读论文' },
  { to: '/project-progress', label: '项目进展' },
]

const route = useRoute()

function isNavActive(path) {
  return route.path === path || (path === '/papers' && route.path.startsWith('/papers/'))
}
</script>

<template>
  <div class="app-shell">
    <header class="site-header">
      <RouterLink class="site-brand" to="/">
        <span class="brand-mark" aria-hidden="true">PR</span>
        <span>
          <strong>Research Desk</strong>
          <small>论文、实验与每日记录</small>
        </span>
      </RouterLink>

      <nav class="site-nav" aria-label="工作台导航">
        <RouterLink v-for="item in navItems" :key="item.to" :to="item.to" :class="{ 'is-active': isNavActive(item.to) }">
          {{ item.label }}
        </RouterLink>
      </nav>
    </header>

    <main class="site-main">
      <RouterView />
    </main>

    <footer class="site-footer">
      <span>Research Desk · Vue 3 + Vite</span>
      <span>个人研究记录工作台</span>
    </footer>
  </div>
</template>
