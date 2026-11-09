<script setup>
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'
import { RouterLink } from 'vue-router'
import { papers, codexDailyHistory, projectProgress } from '../data/dashboardData'

const now = ref(new Date())
const weather = ref({ status: '正在获取天气', temperature: '--', humidity: '--', wind: '--', label: '定位中', source: '', icon: '☼', updated: '' })
const catMood = ref('安静地陪你工作')
const catEnergy = ref(72)
const catAffection = ref(46)
const catFrame = ref('idle')
const catPaused = ref(false)
const calendarCursor = ref(new Date(now.value.getFullYear(), now.value.getMonth(), 1))
let clockTimer
let weatherTimer
let weatherAbort
let catTimer
let catResetTimer

const dateText = computed(() => now.value.toLocaleDateString('zh-CN', { year: 'numeric', month: 'long', day: 'numeric', weekday: 'long' }))
const timeText = computed(() => now.value.toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' }))
const yearMonth = computed(() => calendarCursor.value.toLocaleDateString('zh-CN', { year: 'numeric', month: 'long' }))
const monthDays = computed(() => {
  const year = calendarCursor.value.getFullYear()
  const month = calendarCursor.value.getMonth()
  const firstDay = new Date(year, month, 1).getDay()
  const count = new Date(year, month + 1, 0).getDate()
  return Array.from({ length: firstDay + count }, (_, index) => index < firstDay ? null : index - firstDay + 1)
})
const todayKey = computed(() => formatKey(now.value))
const selectedMonthKey = computed(() => `${calendarCursor.value.getFullYear()}-${String(calendarCursor.value.getMonth() + 1).padStart(2, '0')}`)
const activityDays = computed(() => new Set(codexDailyHistory.map((item) => item.date)))
const fortune = computed(() => {
  const seed = Number(`${now.value.getFullYear()}${now.value.getMonth() + 1}${now.value.getDate()}`)
  const fortunes = [
    ['研究运', '先把一个关键证据闭环，今天适合收口而不是铺开新线。', '专注'],
    ['灵感运', '把刚出现的想法写成一个小实验，灵感会在动手后变清楚。', '记录'],
    ['协作运', '适合向 Codex 提出一个具体问题，越清楚的输入越容易得到好结果。', '提问'],
    ['整理运', '清理一处记录、文件或计划，明天会因此省下很多时间。', '归档'],
    ['突破运', '卡住的地方可以换一个角度，先做最小验证，不必一次解决全部。', '试验'],
  ]
  return fortunes[seed % fortunes.length]
})

function formatKey(date) {
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`
}

function shiftMonth(offset) { calendarCursor.value = new Date(calendarCursor.value.getFullYear(), calendarCursor.value.getMonth() + offset, 1) }
function resetMonth() { calendarCursor.value = new Date(now.value.getFullYear(), now.value.getMonth(), 1) }
function playWithCat(action) {
  if (action === 'pet') { catAffection.value = Math.min(100, catAffection.value + 8); catMood.value = '被摸摸了，继续陪你专注'; catFrame.value = 'happy' }
  else if (action === 'feed') { catEnergy.value = Math.min(100, catEnergy.value + 12); catMood.value = '吃饱了，精神满满'; catFrame.value = 'happy' }
  else { catEnergy.value = Math.max(0, catEnergy.value - 9); catAffection.value = Math.min(100, catAffection.value + 5); catMood.value = '玩得很开心，尾巴在摇'; catFrame.value = 'play' }
  window.clearTimeout(catResetTimer)
  catResetTimer = window.setTimeout(() => { if (catFrame.value !== 'idle') catFrame.value = 'idle' }, 1800)
}
function toggleCat() { catPaused.value = !catPaused.value; catMood.value = catPaused.value ? '先休息一下，随时可以继续陪你' : '重新开始陪你工作' }
function weatherLabel(code) {
  if (code === 0) return '晴朗'
  if ([1, 2, 3].includes(code)) return '多云'
  if ([45, 48].includes(code)) return '有雾'
  if ([51, 53, 55, 56, 57].includes(code)) return '小毛毛雨'
  if ([61, 63, 65, 66, 67, 80, 81, 82].includes(code)) return '有雨'
  if ([71, 73, 75, 77, 85, 86].includes(code)) return '有雪'
  return '天气变化中'
}
async function loadWeather() {
  weatherAbort?.abort()
  weatherAbort = new AbortController()
  const { signal } = weatherAbort
  let latitude = 39.9042; let longitude = 116.4074; let locationLabel = '北京（默认位置）'; let source = '默认位置'
  weather.value = { ...weather.value, status: '正在获取天气', label: '定位中', source: '', icon: '…' }
  try {
    if ('geolocation' in navigator) {
      const position = await new Promise((resolve, reject) => navigator.geolocation.getCurrentPosition(resolve, reject, { timeout: 4500, maximumAge: 1800000 }))
      latitude = position.coords.latitude; longitude = position.coords.longitude; source = 'GPS 定位'
      const place = await fetch(`https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=${latitude}&longitude=${longitude}&localityLanguage=zh`, { signal }).then((r) => r.ok ? r.json() : null)
      locationLabel = [place?.city || place?.locality, place?.principalSubdivision].filter(Boolean).slice(0, 2).join(' · ') || '当前位置'
    } else throw new Error('geolocation unavailable')
  } catch (error) {
    if (error?.name === 'AbortError') return
    try {
      const ip = await fetch('https://ipapi.co/json/', { signal }).then((r) => r.ok ? r.json() : null)
      if (ip?.latitude && ip?.longitude) { latitude = ip.latitude; longitude = ip.longitude; locationLabel = `${ip.city || '当前城市'}（按网络推断）`; source = 'IP 推断' }
    } catch (fallbackError) { if (fallbackError?.name === 'AbortError') return }
  }
  try {
    const response = await fetch(`https://api.open-meteo.com/v1/forecast?latitude=${latitude}&longitude=${longitude}&current=temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code&timezone=auto`, { signal })
    if (!response.ok) throw new Error('weather request failed')
    const data = await response.json()
    const code = data.current.weather_code
    weather.value = { status: weatherLabel(code), temperature: `${Math.round(data.current.temperature_2m)}°C`, humidity: `${data.current.relative_humidity_2m}%`, wind: `${Math.round(data.current.wind_speed_10m)} km/h`, label: locationLabel, source, icon: code === 0 ? '☀' : [1, 2, 3].includes(code) ? '☁' : [71, 73, 75, 77, 85, 86].includes(code) ? '❄' : '☂', updated: new Date().toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' }) }
  } catch (error) {
    if (error?.name === 'AbortError') return
    weather.value = { ...weather.value, status: '天气暂不可用', temperature: '--', humidity: '--', wind: '--', label: locationLabel, source: source || '请求失败', icon: '!', updated: '' }
  }
}
onMounted(() => {
  clockTimer = window.setInterval(() => { now.value = new Date() }, 1000)
  weatherTimer = window.setInterval(loadWeather, 30 * 60 * 1000)
  catTimer = window.setInterval(() => {
    if (!catPaused.value && catFrame.value === 'idle') {
      catFrame.value = 'blink'
      catResetTimer = window.setTimeout(() => { catFrame.value = 'idle' }, 700)
    }
  }, 8000)
  loadWeather()
})
onBeforeUnmount(() => { window.clearInterval(clockTimer); window.clearInterval(weatherTimer); window.clearInterval(catTimer); window.clearTimeout(catResetTimer); weatherAbort?.abort() })
</script>

<template>
  <section class="dashboard-page reference-home">
    <div class="reference-layout">
      <aside class="profile-column">
        <section class="profile-card">
          <div class="profile-avatar">PR</div>
          <h1>研究工作台</h1>
          <p>把论文、实验和每天的 Codex 工作，整理成一个可以慢慢长大的研究空间。</p>
          <div class="profile-links"><a href="https://github.com" target="_blank" rel="noreferrer" title="GitHub">GH</a><a href="mailto:research@example.com" title="联系">@</a><RouterLink to="/daily-work" title="每日工作">日</RouterLink><RouterLink to="/papers" title="论文">读</RouterLink></div>
          <div class="profile-stats"><span><b>{{ papers.length }}</b>论文</span><span><b>{{ projectProgress.plan.length }}</b>阶段</span><span><b>{{ codexDailyHistory.length }}</b>记录日</span></div>
        </section>
        <nav class="side-menu" aria-label="研究导航"><h2>导航</h2><RouterLink to="/daily-work"><span>▣</span>每日工作</RouterLink><RouterLink to="/papers"><span>▧</span>已读论文</RouterLink><RouterLink to="/project-progress"><span>⌁</span>项目进展</RouterLink><a href="#life-zone"><span>◌</span>今日生活</a></nav>
      </aside>

      <main class="research-feed">
        <div class="feed-heading"><div><span>RESEARCH JOURNAL</span><h2>最近正在发生的事</h2><p>把今天的研究线索、项目判断和阅读入口放在一起。</p></div><div class="feed-clock"><b>{{ timeText }}</b><small>{{ dateText }}</small></div></div>
        <RouterLink class="feed-card feature-feed" to="/daily-work"><div class="feed-card-copy"><span class="feed-tag">DAILY WORK · {{ codexDailyHistory[0].date }}</span><h3>{{ codexDailyHistory[0].title }}</h3><p>{{ codexDailyHistory[0].summary }}</p><div class="feed-meta">{{ codexDailyHistory[0].state }} <b>打开每日工作 →</b></div></div><div class="feed-art art-research"><span>Codex<br />research<br />notes</span><i>✦</i></div></RouterLink>
        <RouterLink class="feed-card" to="/project-progress"><div class="feed-art art-project"><span>RATM<br />v6 / v7</span><i>↗</i></div><div class="feed-card-copy"><span class="feed-tag">PROJECT CONTROL</span><h3>AI-agent-drug-design-main-next</h3><p>{{ projectProgress.summary }}</p><div class="feed-meta">{{ projectProgress.current[0].status }} <b>查看项目进展 →</b></div></div></RouterLink>
        <RouterLink class="feed-card" to="/papers"><div class="feed-card-copy"><span class="feed-tag">READING ARCHIVE · {{ papers.length }} PAPERS</span><h3>DyRAMO · PharmAgent · PMMG</h3><p>多目标分子设计、约束感知搜索和 Pareto 生成的论文精读档案。</p><div class="feed-meta">已读论文 <b>打开论文档案 →</b></div></div><div class="feed-art art-papers"><span>READ<br />THINK<br />MAKE</span><i>◎</i></div></RouterLink>
        <section class="feed-note"><span>今日研究提示</span><p>{{ fortune[1] }}</p><small>自动更新 · {{ dateText }}</small></section>
      </main>

      <aside class="utility-column" id="life-zone">
        <article class="utility-card music-card"><div class="utility-label">FOCUS MUSIC <span>· live</span></div><div class="music-disc">◒</div><h2>研究中的安静时刻</h2><p>让今天的注意力有一个柔软的背景。</p><div class="music-line"><span>00:00</span><i></i><span>∞</span></div><div class="music-controls"><button type="button" title="上一首">|‹</button><button type="button" title="播放">▶</button><button type="button" title="下一首">›|</button></div></article>
        <article class="utility-card weather-card"><div class="life-card-top"><span class="life-label">LIVE WEATHER</span><button class="icon-button" type="button" title="刷新天气" aria-label="刷新天气" @click="loadWeather">↻</button></div><div class="weather-main"><span class="weather-symbol" aria-hidden="true">{{ weather.icon }}</span><div><strong>{{ weather.temperature }}</strong><span>{{ weather.status }}</span></div></div><p class="weather-location">{{ weather.label }}</p><div class="weather-stats"><span>湿度 <b>{{ weather.humidity }}</b></span><span>风速 <b>{{ weather.wind }}</b></span></div><small class="weather-source">{{ weather.source }}<span v-if="weather.updated"> · {{ weather.updated }} 更新</span></small></article>
        <article class="utility-card calendar-card"><div class="life-card-top"><span class="life-label">CALENDAR</span><div class="calendar-actions"><button type="button" title="上个月" @click="shiftMonth(-1)">‹</button><button type="button" title="回到本月" @click="resetMonth">今天</button><button type="button" title="下个月" @click="shiftMonth(1)">›</button></div></div><div class="calendar-title"><h2>{{ yearMonth }}</h2><span>{{ activityDays.size }} 天有记录</span></div><div class="calendar-week"><span v-for="day in ['日', '一', '二', '三', '四', '五', '六']" :key="day">{{ day }}</span></div><div class="calendar-grid"><span v-for="(day, index) in monthDays" :key="`${selectedMonthKey}-${index}`" :class="{ muted: !day, today: day && formatKey(new Date(calendarCursor.getFullYear(), calendarCursor.getMonth(), day)) === todayKey, active: day && activityDays.has(formatKey(new Date(calendarCursor.getFullYear(), calendarCursor.getMonth(), day))) }">{{ day }}</span></div></article>
        <article class="utility-card cat-card"><div class="life-card-top"><span class="life-label">WORK BUDDY</span><button class="cat-status cat-toggle" type="button" @click="toggleCat">{{ catPaused ? '已暂停' : '在线陪伴' }}</button></div><div class="cat-stage" :class="{ paused: catPaused }"><div class="cat-shadow"></div><div class="cat-sprite" :class="`frame-${catFrame}`" role="img" aria-label="桌宠小墨"></div><div class="cat-sparkle" aria-hidden="true">✦</div></div><h2>小墨</h2><p aria-live="polite">{{ catMood }}</p><div class="cat-meters"><span>精力 <i><b :style="{ width: `${catEnergy}%` }"></b></i></span><span>亲密 <i><b :style="{ width: `${catAffection}%` }"></b></i></span></div><div class="cat-actions"><button type="button" @click="playWithCat('pet')">摸摸</button><button type="button" @click="playWithCat('feed')">喂食</button><button type="button" @click="playWithCat('play')">逗它玩</button></div></article>
      </aside>
    </div>
  </section>
</template>
