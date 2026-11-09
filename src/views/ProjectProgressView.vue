<script setup>
import { projectProgress, workHistory } from '../data/dashboardData'

const projectHistory = workHistory
  .filter((item) => item.area !== '网站工作台')
  .sort((a, b) => b.date.localeCompare(a.date))
</script>

<template>
  <section class="workspace-page">
    <div class="page-heading">
      <div>
        <p class="section-kicker">PROJECT CONTROL</p>
        <h1>项目进展</h1>
        <p>来自 AI-agent-drug-design 项目的 Codex 工作记录快照。</p>
      </div>
      <a class="source-link" :href="`codex://threads/${projectProgress.source.threadId}`">打开来源聊天</a>
    </div>

    <section class="progress-summary">
      <p>{{ projectProgress.summary }}</p>
      <div class="source-meta">
        <span>来源：{{ projectProgress.source.title }}</span>
        <span>记录日期：{{ projectProgress.source.updated }}</span>
        <span>项目目录：{{ projectProgress.source.path }}</span>
      </div>
    </section>

    <div class="progress-grid">
      <section class="progress-panel">
        <div class="panel-heading"><span>01</span><h2>已经完成</h2></div>
        <ul><li v-for="item in projectProgress.completed" :key="item">{{ item }}</li></ul>
      </section>
      <section class="progress-panel">
        <div class="panel-heading"><span>02</span><h2>当前推进</h2></div>
        <div class="progress-items">
          <div v-for="item in projectProgress.current" :key="item.label" class="progress-item">
            <div><strong>{{ item.label }}</strong><span>{{ item.value }}</span></div>
            <b>{{ item.status }}</b>
          </div>
        </div>
      </section>
    </div>

    <section class="guardrail-panel">
      <div class="panel-heading"><span>03</span><h2>当前门禁</h2></div>
      <ul><li v-for="item in projectProgress.guardrails" :key="item">{{ item }}</li></ul>
    </section>

    <section class="plan-section">
      <div class="section-heading"><span>ROADMAP</span><h2>AI-agent-drug-design-main-next 总体计划</h2></div>
      <p class="history-intro">按研究问题、工程实现、证据门禁和发布交付拆分阶段；每个阶段都明确已完成内容和下一步，方便判断项目是否真正闭环。</p>
      <div class="plan-list">
        <details v-for="phase in projectProgress.plan" :key="phase.id" class="plan-item" :open="phase.status.includes('进行中') || phase.status === 'HOLD'">
          <summary>
            <span class="plan-id">{{ phase.id }}</span>
            <span class="plan-name">{{ phase.name }}</span>
            <b :class="{ 'plan-hold': phase.status === 'HOLD', 'plan-active': phase.status.includes('进行中') }">{{ phase.status }}</b>
          </summary>
          <p class="plan-detail">{{ phase.detail }}</p>
          <div class="plan-columns">
            <div><strong>已完成</strong><ul><li v-for="item in phase.done" :key="item">{{ item }}</li></ul></div>
            <div><strong>未完成 / 下一步</strong><ul><li v-for="item in phase.pending" :key="item">{{ item }}</li></ul></div>
          </div>
        </details>
      </div>
    </section>

    <section class="project-timeline">
      <div class="section-heading"><span>PROJECT LOG</span><h2>项目逐日进展</h2></div>
      <p class="history-intro">这条时间线来自项目工作日志文件和对应的 Codex 工作记录，按日期保留了阶段变化和当天的结论。</p>
      <div class="history-timeline">
        <details v-for="day in projectHistory" :key="day.date + day.title" class="history-day record-details">
          <summary class="history-summary-row">
            <div class="history-date"><strong>{{ day.date }}</strong><span>{{ day.area }}</span></div>
            <div class="history-body">
              <div class="history-title"><h3>{{ day.title }}</h3><b>{{ day.state }}</b></div>
              <p class="history-summary"><strong>当天总结：</strong>{{ day.summary }}</p>
            </div>
          </summary>
          <div class="history-expanded">
            <p><strong>做了什么：</strong>{{ day.work }}</p>
            <p><strong>得到什么：</strong>{{ day.output }}</p>
            <p class="history-summary"><strong>这一天的意义：</strong>{{ day.summary }}</p>
          </div>
        </details>
      </div>
    </section>
  </section>
</template>
