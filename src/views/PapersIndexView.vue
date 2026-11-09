<script setup>
import { computed, ref } from 'vue'
import { RouterLink } from 'vue-router'
import { papers } from '../data/dashboardData'

const query = ref('')
const statusFilter = ref('全部状态')
const filteredPapers = computed(() => papers.filter((paper) => {
  const haystack = `${paper.name} ${paper.title} ${paper.description}`.toLowerCase()
  return haystack.includes(query.value.trim().toLowerCase()) && (statusFilter.value === '全部状态' || paper.status === statusFilter.value)
}))
</script>

<template>
  <section class="workspace-page">
    <div class="page-heading">
      <div>
        <p class="section-kicker">READING ARCHIVE</p>
        <h1>已读论文</h1>
        <p>当前已整理成可搜索、可复用精读页面的论文。</p>
      </div>
      <span class="heading-count">{{ papers.length }} 篇</span>
    </div>

    <div class="archive-controls" role="search">
      <label class="search-field"><span aria-hidden="true">⌕</span><input v-model="query" type="search" placeholder="搜索论文名称、主题或关键词" aria-label="搜索论文" /></label>
      <label class="filter-field"><span>阅读状态</span><select v-model="statusFilter" aria-label="按阅读状态筛选"><option>全部状态</option><option v-for="status in [...new Set(papers.map((paper) => paper.status))]" :key="status">{{ status }}</option></select></label>
    </div>

    <div v-if="filteredPapers.length" class="archive-list">
      <RouterLink v-for="paper in filteredPapers" :key="paper.slug" class="archive-row" :class="`accent-${paper.accent}`" :to="`/papers/${paper.slug}`">
        <span class="archive-number">{{ paper.number }}</span>
        <span class="archive-copy">
          <strong>{{ paper.name }}</strong>
          <span>{{ paper.title }}</span>
          <small>{{ paper.description }}</small>
        </span>
        <span class="archive-status"><b>{{ paper.status }}</b><span>打开精读 →</span></span>
      </RouterLink>
    </div>
    <div v-else class="empty-state"><strong>没有找到匹配论文</strong><p>换一个关键词，或把阅读状态切换为全部状态。</p></div>
  </section>
</template>
