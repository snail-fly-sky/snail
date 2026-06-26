<template>
  <main class="tool-page offwork-page">
    <header class="tool-header offwork-header">
      <button class="ghost-action" type="button" @click="goHome">
        <ArrowLeft :size="18" />
        首页
      </button>
      <div>
        <p class="eyebrow">Offwork Countdown</p>
        <h1>下班倒计时</h1>
      </div>
      <el-button type="primary" @click="resetTime">
        <RotateCcw :size="18" />
        恢复默认
      </el-button>
    </header>

    <section class="offwork-hero">
      <div class="offwork-orbit" :style="{ '--progress': `${progressPercent}%` }">
        <div class="offwork-orbit-core">
          <span>{{ statusLabel }}</span>
          <strong>{{ countdownText }}</strong>
          <small>{{ targetText }}</small>
        </div>
      </div>

      <div class="offwork-copy">
        <el-tag class="offwork-tag" effect="plain" type="info">{{ weekdayText }}</el-tag>
        <h2>{{ headline }}</h2>
        <p>{{ subline }}</p>
        <div class="offwork-metrics">
          <span>
            <small>当前时间</small>
            <strong>{{ nowText }}</strong>
          </span>
          <span>
            <small>今日进度</small>
            <strong>{{ progressPercent }}%</strong>
          </span>
          <span>
            <small>目标时间</small>
            <strong>{{ offworkTime }}</strong>
          </span>
        </div>
      </div>
    </section>

    <section class="offwork-grid">
      <div class="tool-panel offwork-panel">
        <div class="tool-panel-head">
          <h2>时间设置</h2>
          <Briefcase :size="20" />
        </div>
        <div class="offwork-settings">
          <label>
            <span>上班时间</span>
            <el-time-picker
              v-model="workStartTime"
              class="offwork-time-picker"
              format="HH:mm"
              value-format="HH:mm"
              :clearable="false"
              :editable="false"
              placeholder="选择上班时间"
            />
          </label>
          <label>
            <span>下班时间</span>
            <el-time-picker
              v-model="offworkTime"
              class="offwork-time-picker"
              format="HH:mm"
              value-format="HH:mm"
              :clearable="false"
              :editable="false"
              placeholder="选择下班时间"
            />
          </label>
        </div>
        <div class="tool-actions offwork-presets">
          <el-button class="offwork-preset-button" :class="{ active: offworkTime === '17:30' }" plain @click="setPreset('17:30')">17:30</el-button>
          <el-button class="offwork-preset-button" :class="{ active: offworkTime === '18:00' }" plain @click="setPreset('18:00')">18:00</el-button>
          <el-button class="offwork-preset-button" :class="{ active: offworkTime === '18:30' }" plain @click="setPreset('18:30')">18:30</el-button>
          <el-button class="offwork-preset-button" :class="{ active: offworkTime === '19:00' }" plain @click="setPreset('19:00')">19:00</el-button>
        </div>
      </div>

      <div class="tool-panel offwork-panel">
        <div class="tool-panel-head">
          <h2>今日节奏</h2>
          <Clock3 :size="20" />
        </div>
        <div class="offwork-timeline">
          <div>
            <span>开工</span>
            <strong>{{ workStartTime }}</strong>
          </div>
          <div>
            <span>现在</span>
            <strong>{{ nowText }}</strong>
          </div>
          <div>
            <span>下班</span>
            <strong>{{ offworkTime }}</strong>
          </div>
        </div>
        <div class="offwork-bar">
          <span :style="{ width: `${progressPercent}%` }"></span>
        </div>
      </div>

      <div class="tool-panel offwork-panel offwork-note-panel">
        <div class="tool-panel-head">
          <h2>状态</h2>
          <Sparkles :size="20" />
        </div>
        <strong>{{ moodTitle }}</strong>
        <p>{{ moodText }}</p>
      </div>
    </section>
  </main>
</template>

<script setup>
import { computed, onMounted, onUnmounted, ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import { ArrowLeft, Briefcase, Clock3, RotateCcw, Sparkles } from 'lucide-vue-next'

const router = useRouter()
const workStartStorageKey = 'snail-offwork-work-start-time'
const offworkStorageKey = 'snail-offwork-offwork-time'
const now = ref(new Date())
const workStartTime = ref('09:00')
const offworkTime = ref('18:00')
let timer = 0

const nowText = computed(() => {
  return formatTime(now.value)
})

const weekdayText = computed(() => {
  return new Intl.DateTimeFormat('zh-CN', { weekday: 'long' }).format(now.value)
})

const workStartDate = computed(() => {
  return timeToDate(workStartTime.value)
})

const offworkDate = computed(() => {
  return timeToDate(offworkTime.value)
})

const remainingMs = computed(() => {
  const value = offworkDate.value.getTime() - now.value.getTime()
  if (value > 0) {
    return value
  }

  return 0
})

const progressPercent = computed(() => {
  const total = offworkDate.value.getTime() - workStartDate.value.getTime()
  const elapsed = now.value.getTime() - workStartDate.value.getTime()

  if (total <= 0) {
    return 100
  }

  if (elapsed <= 0) {
    return 0
  }

  if (elapsed >= total) {
    return 100
  }

  return Math.round((elapsed / total) * 100)
})

const countdownText = computed(() => {
  if (remainingMs.value <= 0) {
    return '00:00:00'
  }

  const totalSeconds = Math.floor(remainingMs.value / 1000)
  const hours = Math.floor(totalSeconds / 3600)
  const minutes = Math.floor((totalSeconds % 3600) / 60)
  const seconds = totalSeconds % 60
  return `${padTime(hours)}:${padTime(minutes)}:${padTime(seconds)}`
})

const statusLabel = computed(() => {
  if (now.value < workStartDate.value) {
    return '还没开工'
  }

  if (remainingMs.value <= 0) {
    return '可以下班'
  }

  return '距离下班'
})

const targetText = computed(() => {
  if (remainingMs.value <= 0) {
    return '今天的任务栏可以清空了'
  }

  return `目标 ${offworkTime.value}`
})

const headline = computed(() => {
  if (now.value < workStartDate.value) {
    return '今天还没正式开始'
  }

  if (remainingMs.value <= 0) {
    return '下班时间到了'
  }

  if (progressPercent.value >= 80) {
    return '最后一段，稳住节奏'
  }

  if (progressPercent.value >= 50) {
    return '已经过半，进入收束'
  }

  return '今天还在推进中'
})

const subline = computed(() => {
  if (remainingMs.value <= 0) {
    return '收尾、保存、同步，剩下的交给明天。'
  }

  return `还有 ${countdownText.value}，当前进度 ${progressPercent.value}%。`
})

const moodTitle = computed(() => {
  if (remainingMs.value <= 0) {
    return '收工模式'
  }

  if (progressPercent.value >= 80) {
    return '低噪冲刺'
  }

  if (progressPercent.value >= 50) {
    return '整理优先'
  }

  return '专注推进'
})

const moodText = computed(() => {
  if (remainingMs.value <= 0) {
    return '现在适合检查未保存内容、同步文件和关闭临时页面。'
  }

  if (progressPercent.value >= 80) {
    return '减少新开任务，把已经开始的事情收干净。'
  }

  if (progressPercent.value >= 50) {
    return '适合整理结果、补记录、处理可完成的小项。'
  }

  return '先处理最重要的一件事，不要被零碎事情打散。'
})

function timeToDate(value) {
  const parts = value.split(':')
  const date = new Date(now.value)
  date.setHours(Number(parts[0]), Number(parts[1]), 0, 0)
  return date
}

function formatTime(value) {
  return `${padTime(value.getHours())}:${padTime(value.getMinutes())}:${padTime(value.getSeconds())}`
}

function padTime(value) {
  return String(value).padStart(2, '0')
}

function setPreset(value) {
  offworkTime.value = value
}

function resetTime() {
  workStartTime.value = '09:00'
  offworkTime.value = '18:00'
}

function goHome() {
  router.push('/')
}

function restoreStoredTime() {
  const storedWorkStartTime = localStorage.getItem(workStartStorageKey)
  const storedOffworkTime = localStorage.getItem(offworkStorageKey)

  if (storedWorkStartTime !== null) {
    workStartTime.value = storedWorkStartTime
  }

  if (storedOffworkTime !== null) {
    offworkTime.value = storedOffworkTime
  }
}

watch(workStartTime, (value) => {
  localStorage.setItem(workStartStorageKey, value)
})

watch(offworkTime, (value) => {
  localStorage.setItem(offworkStorageKey, value)
})

onMounted(() => {
  restoreStoredTime()

  timer = window.setInterval(() => {
    now.value = new Date()
  }, 1000)
})

onUnmounted(() => {
  window.clearInterval(timer)
})
</script>

<style scoped>
.offwork-page {
  background:
    radial-gradient(circle at 18% 12%, rgba(255, 104, 79, 0.18), transparent 28%),
    radial-gradient(circle at 88% 8%, rgba(37, 87, 246, 0.16), transparent 30%);
}

.offwork-header {
  position: relative;
  z-index: 2;
}

.offwork-hero {
  position: relative;
  min-height: 560px;
  display: grid;
  grid-template-columns: minmax(340px, 0.82fr) minmax(0, 1fr);
  gap: 22px;
  align-items: center;
  padding: 22px;
  border: 1px solid rgba(21, 25, 31, 0.1);
  border-radius: 8px;
  background:
    linear-gradient(135deg, rgba(21, 25, 31, 0.94), rgba(35, 48, 67, 0.9)),
    var(--ink);
  color: #ffffff;
  box-shadow: 0 24px 70px rgba(44, 55, 67, 0.18);
  overflow: hidden;
}

.offwork-hero::after {
  position: absolute;
  right: -42px;
  bottom: -42px;
  color: rgba(255, 255, 255, 0.06);
  font-size: 138px;
  font-weight: 950;
  content: "OFF";
}

.offwork-orbit {
  position: relative;
  z-index: 1;
  width: min(100%, 430px);
  aspect-ratio: 1;
  display: grid;
  place-items: center;
  border-radius: 50%;
  background:
    conic-gradient(var(--coral) 0 var(--progress), rgba(255, 255, 255, 0.12) var(--progress) 100%),
    rgba(255, 255, 255, 0.08);
  box-shadow: inset 0 0 0 1px rgba(255, 255, 255, 0.16), 0 28px 70px rgba(0, 0, 0, 0.2);
}

.offwork-orbit::before {
  position: absolute;
  inset: 18px;
  border-radius: 50%;
  background:
    linear-gradient(145deg, rgba(255, 255, 255, 0.18), rgba(37, 87, 246, 0.22)),
    #1d2838;
  content: "";
}

.offwork-orbit-core {
  position: relative;
  z-index: 1;
  display: grid;
  gap: 12px;
  place-items: center;
  text-align: center;
}

.offwork-orbit-core span,
.offwork-orbit-core small {
  color: rgba(255, 255, 255, 0.72);
  font-size: 13px;
  font-weight: 950;
}

.offwork-orbit-core strong {
  color: #ffffff;
  font-size: clamp(44px, 7vw, 78px);
  line-height: 1;
  font-weight: 950;
}

.offwork-copy {
  position: relative;
  z-index: 1;
  display: grid;
  gap: 18px;
}

.offwork-tag {
  justify-self: start;
}

.offwork-copy h2 {
  max-width: 640px;
  margin: 0;
  font-size: clamp(38px, 6vw, 72px);
  line-height: 1.02;
  font-weight: 950;
}

.offwork-copy p {
  max-width: 560px;
  margin: 0;
  color: rgba(255, 255, 255, 0.76);
  font-size: 18px;
  line-height: 1.7;
}

.offwork-metrics {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 10px;
  max-width: 680px;
}

.offwork-metrics span {
  display: grid;
  gap: 7px;
  min-height: 94px;
  padding: 14px;
  border: 1px solid rgba(255, 255, 255, 0.13);
  border-radius: 8px;
  background: rgba(255, 255, 255, 0.08);
}

.offwork-metrics small {
  color: rgba(255, 255, 255, 0.62);
  font-size: 12px;
  font-weight: 950;
}

.offwork-metrics strong {
  color: #ffffff;
  font-size: 24px;
  font-weight: 950;
}

.offwork-grid {
  display: grid;
  grid-template-columns: minmax(0, 0.9fr) minmax(0, 1.1fr) minmax(280px, 0.8fr);
  gap: 14px;
  margin-top: 18px;
}

.offwork-panel {
  align-content: start;
}

.offwork-panel .tool-panel-head svg {
  color: var(--blue);
}

.offwork-settings {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 10px;
}

.offwork-settings label {
  position: relative;
  display: grid;
  gap: 10px;
  padding: 12px;
  border: 1px solid rgba(21, 25, 31, 0.08);
  border-radius: 8px;
  background:
    linear-gradient(180deg, rgba(255, 255, 255, 0.96), rgba(248, 250, 252, 0.96)),
    #ffffff;
  color: #526071;
  font-size: 12px;
  font-weight: 950;
  box-shadow: 0 14px 34px rgba(44, 55, 67, 0.08);
}

.offwork-settings label::after {
  position: absolute;
  top: 18px;
  right: 14px;
  width: 7px;
  height: 7px;
  border-radius: 50%;
  background: var(--coral);
  content: "";
}

.offwork-settings label span {
  color: #526071;
  letter-spacing: 0;
}

.offwork-time-picker {
  width: 100%;
}

.offwork-time-picker :deep(.el-input__wrapper) {
  min-height: 48px;
  border: 1px solid rgba(21, 25, 31, 0.1);
  border-radius: 8px;
  background: #ffffff;
  box-shadow: none;
}

.offwork-time-picker :deep(.el-input__wrapper.is-focus) {
  border-color: rgba(37, 87, 246, 0.42);
  box-shadow: 0 0 0 4px rgba(37, 87, 246, 0.1);
}

.offwork-time-picker :deep(.el-input__inner) {
  color: var(--ink);
  font-size: 18px;
  font-weight: 900;
}

.offwork-time-picker :deep(.el-input__prefix) {
  color: var(--blue);
}

.offwork-presets {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 8px;
}

.offwork-presets .el-button + .el-button {
  margin-left: 0;
}

.offwork-preset-button {
  min-height: 40px;
  border-color: rgba(21, 25, 31, 0.1);
  border-radius: 8px;
  color: #526071;
  font-weight: 900;
}

.offwork-preset-button.active {
  border-color: var(--blue);
  background: rgba(37, 87, 246, 0.1);
  color: var(--blue);
}

.offwork-timeline {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 10px;
}

.offwork-timeline div {
  display: grid;
  gap: 6px;
  padding: 12px;
  border-radius: 8px;
  background: #ffffff;
}

.offwork-timeline span {
  color: var(--muted);
  font-size: 12px;
  font-weight: 950;
}

.offwork-timeline strong {
  color: var(--ink);
  font-size: 18px;
  font-weight: 950;
}

.offwork-bar {
  height: 14px;
  border-radius: 999px;
  background: rgba(21, 25, 31, 0.08);
  overflow: hidden;
}

.offwork-bar span {
  height: 100%;
  display: block;
  border-radius: inherit;
  background: linear-gradient(90deg, var(--blue), var(--coral));
  transition: width 240ms ease;
}

.offwork-note-panel strong {
  color: var(--ink);
  font-size: 28px;
  line-height: 1.1;
  font-weight: 950;
}

.offwork-note-panel p {
  margin: 0;
  color: #526071;
  line-height: 1.7;
}

@media (max-width: 1180px) {
  .offwork-hero,
  .offwork-grid {
    grid-template-columns: 1fr;
  }

  .offwork-orbit {
    justify-self: center;
  }
}

@media (max-width: 760px) {
  .offwork-hero {
    min-height: auto;
    padding: 16px;
  }

  .offwork-metrics,
  .offwork-settings,
  .offwork-timeline {
    grid-template-columns: 1fr;
  }
}
</style>
