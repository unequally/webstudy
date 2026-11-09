import { createRouter, createWebHistory } from 'vue-router'
import HomeView from './views/HomeView.vue'
import PaperView from './views/PaperView.vue'
import DailyWorkView from './views/DailyWorkView.vue'
import PapersIndexView from './views/PapersIndexView.vue'
import ProjectProgressView from './views/ProjectProgressView.vue'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: '/', name: 'home', component: HomeView },
    { path: '/daily-work', name: 'daily-work', component: DailyWorkView },
    { path: '/papers', name: 'papers', component: PapersIndexView },
    { path: '/project-progress', name: 'project-progress', component: ProjectProgressView },
    { path: '/papers/:slug', name: 'paper', component: PaperView, props: true },
    { path: '/:pathMatch(.*)*', redirect: '/' },
  ],
  scrollBehavior() {
    return { top: 0 }
  },
})

export default router
