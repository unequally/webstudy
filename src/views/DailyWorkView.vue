<script setup>
import { codexDailyHistory } from '../data/dashboardData'
</script>

<template>
  <section class="workspace-page">
    <div class="page-heading">
      <div>
        <p class="section-kicker">DAILY REVIEW</p>
        <h1>每日工作</h1>
        <p>按 Codex 聊天记录的最近更新日，归纳你每天让 Codex 做过的事情、产出和当天总结。</p>
      </div>
        <span class="heading-date">{{ codexDailyHistory[0].date }}</span>
    </div>

    <div class="daily-summary">
      <div><strong>{{ codexDailyHistory.length }}</strong><span>有记录的工作日</span></div>
      <div><strong>3</strong><span>当前高频方向</span></div>
      <div><strong>{{ codexDailyHistory[0].date }}</strong><span>最近记录</span></div>
      <div><strong>Codex</strong><span>记录来源</span></div>
    </div>

    <div class="codex-recent-grid">
      <details v-for="day in codexDailyHistory.slice(0, 3)" :key="day.date + day.title" class="work-stream record-details accent-blue" open>
        <summary><div class="stream-meta"><span>{{ day.date }} · {{ day.focus }}</span><b>{{ day.state }}</b></div><h2>{{ day.title }}</h2></summary>
        <p>{{ day.summary }}</p>
        <p><strong>当天做了什么：</strong>{{ day.work }}</p>
        <p><strong>产出：</strong>{{ day.output }}</p>
        <p><strong>相关聊天：</strong>{{ day.chats.join('；') }}</p>
      </details>
    </div>

    <aside class="analysis-note">
      <span class="note-label">工作分析</span>
      <p>这里记录的是 Codex 聊天本身：论文阅读、导师汇报、项目实验、网站工程和部署规划都会出现。项目进展页只回答“项目走到哪一步”，不再替代每日工作记录。</p>
    </aside>

    <section class="history-section">
      <div class="section-heading"><span>HISTORY</span><h2>之前每个有记录的工作日</h2></div>
      <p class="history-intro">以下按 Codex 聊天记录的最近更新日从新到旧排列。记录日来自聊天更新时间和可核对的聊天主题；没有聊天记录的日期不推断为“没有工作”。</p>
      <div class="history-timeline">
        <details v-for="day in codexDailyHistory" :key="day.date + day.title" class="history-day record-details">
          <summary class="history-summary-row">
            <div class="history-date"><strong>{{ day.date }}</strong><span>{{ day.focus }}</span></div>
            <div class="history-body">
              <div class="history-title"><h3>{{ day.title }}</h3><b>{{ day.state }}</b></div>
              <p class="history-summary"><strong>当天总结：</strong>{{ day.summary }}</p>
            </div>
          </summary>
          <div class="history-expanded">
            <p><strong>相关聊天：</strong>{{ day.chats.join('；') }}</p>
            <p><strong>当天做了什么：</strong>{{ day.work }}</p>
            <p><strong>产出：</strong>{{ day.output }}</p>
          </div>
        </details>
      </div>
    </section>
  </section>
</template>
