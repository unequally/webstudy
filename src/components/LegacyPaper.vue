<script setup>
import { nextTick, onBeforeUnmount, ref, watch } from 'vue'

const props = defineProps({
  src: { type: String, required: true },
  title: { type: String, required: true },
})

const emit = defineEmits(['loaded', 'error'])
const host = ref(null)
const status = ref('loading')
const errorMessage = ref('')
let requestId = 0
let injectedStyles = []
let injectedScripts = []
const legacyGlobals = ['toggleSidebar', 'toggleSearch', 'toggleLang', 'toggleTheme', 'doSearch', 'exportMarkdown', 'openFigureModal', 'closeFigureModal']

function resolveUrl(value, sourceUrl) {
  if (!value || value.startsWith('#') || value.startsWith('/') || value.startsWith('//') || value.startsWith('data:') || value.startsWith('http:') || value.startsWith('https:') || value.startsWith('mailto:') || value.startsWith('javascript:')) return value
  return new URL(value, new URL(sourceUrl, window.location.origin)).pathname + new URL(value, new URL(sourceUrl, window.location.origin)).search
}

function clearInjectedContent() {
  injectedStyles.forEach((style) => style.remove())
  injectedScripts.forEach((script) => script.remove())
  injectedStyles = []
  injectedScripts = []
  if (host.value) host.value.innerHTML = ''
}

function rewriteRelativeAssets(root, sourceUrl) {
  root.querySelectorAll('[src], [href]').forEach((element) => {
    const attribute = element.hasAttribute('src') ? 'src' : 'href'
    const value = element.getAttribute(attribute)
    if (attribute === 'href' && value?.startsWith('#')) return
    element.setAttribute(attribute, resolveUrl(value, sourceUrl))
  })
}

async function loadPaper() {
  const currentRequest = ++requestId
  status.value = 'loading'
  errorMessage.value = ''
  clearInjectedContent()

  try {
    const response = await fetch(props.src)
    if (!response.ok) throw new Error(`HTTP ${response.status}`)
    const html = await response.text()
    if (currentRequest !== requestId) return

    const documentFragment = new DOMParser().parseFromString(html, 'text/html')
    const styles = Array.from(documentFragment.head.querySelectorAll('style'))
    styles.forEach((sourceStyle) => {
      const style = document.createElement('style')
      style.dataset.paperStyle = props.title
      style.textContent = sourceStyle.textContent
      document.head.appendChild(style)
      injectedStyles.push(style)
    })

    const scripts = Array.from(documentFragment.querySelectorAll('script'))
    scripts.forEach((script) => script.remove())
    rewriteRelativeAssets(documentFragment.body, props.src)
    host.value.innerHTML = documentFragment.body.innerHTML
    host.value.dataset.paperFramework = 'shared'
    host.value.dataset.paperSlug = props.title.toLowerCase()
    const legacyTopbar = host.value.querySelector('.topbar')
    if (legacyTopbar) {
      const homeLink = document.createElement('a')
      homeLink.className = 'legacy-home-link'
      homeLink.href = '/'
      homeLink.textContent = '← 首页'
      homeLink.setAttribute('aria-label', '返回首页')
      legacyTopbar.prepend(homeLink)
    }
    await nextTick()

    // Each legacy document declares common top-level names such as `init` and
    // `D`. Keep them in a private closure so route changes cannot redeclare them.
    window.__legacyPaperInit = undefined
    legacyGlobals.forEach((name) => { delete window[name] })
    for (const sourceScript of scripts) {
      const script = document.createElement('script')
      if (sourceScript.src) script.src = resolveUrl(sourceScript.getAttribute('src'), props.src)
      else {
        const exports = legacyGlobals
          .map((name) => `if (typeof ${name} === 'function') window.${name} = ${name};`)
          .join('\n')
        script.textContent = `(function () {\n${sourceScript.textContent}\nwindow.__legacyPaperInit = typeof init === 'function' ? init : null;\n${exports}\n})();`
      }
      script.async = false
      script.dataset.paperScript = props.title
      document.body.appendChild(script)
      injectedScripts.push(script)
    }

    // DyRAMO and PMMG register an init function for DOMContentLoaded. The Vue
    // host is already mounted, so run only the current paper's initializer.
    if (typeof window.__legacyPaperInit === 'function') window.__legacyPaperInit()

    status.value = 'ready'
    emit('loaded')
  } catch (error) {
    if (currentRequest !== requestId) return
    status.value = 'error'
    errorMessage.value = error instanceof Error ? error.message : String(error)
    emit('error', error)
  }
}

function retry() {
  loadPaper()
}

watch(() => props.src, loadPaper, { immediate: true })
onBeforeUnmount(() => {
  requestId += 1
  clearInjectedContent()
})
</script>

<template>
  <div v-if="status === 'loading'" class="paper-loading" role="status">正在加载 {{ title }}…</div>
  <div v-else-if="status === 'error'" class="paper-error" role="alert">
    <h1>{{ title }} 加载失败</h1>
    <p>{{ errorMessage }}</p>
    <button type="button" @click="retry">重新加载</button>
  </div>
  <div v-show="status === 'ready'" ref="host" class="legacy-paper-host" :aria-label="title" />
</template>
