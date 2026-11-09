<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import LegacyPaper from '../components/LegacyPaper.vue'

const route = useRoute()

const props = defineProps({
  slug: { type: String, default: '' },
})

const paperSources = {
  dyramo: { title: 'DyRAMO', src: '/legacy-papers/DyRAMO.html' },
  pharmagent: { title: 'PharmAgent', src: '/legacy-papers/PharmAgent.html' },
  pmmg: { title: 'PMMG', src: '/legacy-papers/PMMG.html' },
  conformal: { title: 'Conformal Prediction', src: '/legacy-papers/ConformalPrediction.html' },
}

const paper = computed(() => {
  const slug = String(props.slug || route.params.slug || '').trim().toLowerCase()
  return paperSources[slug] || null
})
</script>

<template>
  <section v-if="paper" class="paper-view">
    <LegacyPaper :key="paper.src" :src="paper.src" :title="paper.title" />
  </section>
  <section v-else class="paper-error">
    <h1>找不到这篇论文</h1>
    <p>该路由没有对应的论文页面。</p>
  </section>
</template>
