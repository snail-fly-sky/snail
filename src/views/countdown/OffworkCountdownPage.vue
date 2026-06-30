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

    <section class="offwork-hero" :style="{ '--progress': `${progressPercent}%` }">
      <div class="offwork-board">
        <div class="offwork-board-head">
          <span class="offwork-status-pill">{{ statusLabel }}</span>
          <small>{{ weekdayText }}</small>
        </div>

        <div class="offwork-flip-clock" aria-label="下班倒计时">
          <template v-for="(part, index) in mechanicalCountdownParts" :key="part.label">
            <span class="offwork-flip-unit">
              <span class="offwork-flip-leaf" :class="{ 'is-flipping': part.isFlipping }" :key="part.flipKey">
                <span class="offwork-flip-static offwork-flip-static-top">
                  <span>{{ part.value }}</span>
                </span>
                <span class="offwork-flip-static offwork-flip-static-bottom">
                  <span>{{ part.value }}</span>
                </span>
                <span class="offwork-flip-panel offwork-flip-panel-top">
                  <span>{{ part.previousValue }}</span>
                </span>
                <span class="offwork-flip-panel offwork-flip-panel-bottom">
                  <span>{{ part.value }}</span>
                </span>
              </span>
              <small>{{ part.label }}</small>
            </span>
            <em v-if="index < mechanicalCountdownParts.length - 1">:</em>
          </template>
        </div>

        <div class="offwork-board-foot">
          <span>{{ targetText }}</span>
          <strong>{{ nowText }}</strong>
        </div>
      </div>

      <div class="offwork-dispatch">
        <div class="offwork-dispatch-top">
          <el-tag class="offwork-tag" effect="plain" type="info">现在 {{ nowText }}</el-tag>
          <span class="offwork-progress-number">{{ progressPercent }}%</span>
        </div>
        <h2>{{ headline }}</h2>
        <p>{{ subline }}</p>

        <div class="offwork-route">
          <div class="offwork-route-line">
            <span></span>
          </div>
          <div class="offwork-route-stops">
            <span>
              <small>开工</small>
              <strong>{{ workStartTime }}</strong>
            </span>
            <span class="active">
              <small>现在</small>
              <strong>{{ nowText }}</strong>
            </span>
            <span>
              <small>下班</small>
              <strong>{{ offworkTime }}</strong>
            </span>
          </div>
        </div>

        <div class="offwork-metrics">
          <span>
            <small>当前时间</small>
            <strong>{{ nowText }}</strong>
          </span>
          <span>
            <small>剩余时间</small>
            <strong>{{ countdownText }}</strong>
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
const previousCountdownValues = ref(['00', '00', '00'])
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

previousCountdownValues.value = countdownText.value.split(':')

const countdownParts = computed(() => {
  const parts = countdownText.value.split(':')
  return [
    { label: '时', value: parts[0] },
    { label: '分', value: parts[1] },
    { label: '秒', value: parts[2] },
  ]
})

const mechanicalCountdownParts = computed(() => {
  const previousValues = previousCountdownValues.value
  return countdownParts.value.map((part, index) => {
    const previousValue = previousValues[index]
    return {
      ...part,
      previousValue,
      isFlipping: previousValue !== part.value,
      flipKey: `${part.label}-${previousValue}-${part.value}`,
    }
  })
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

watch(countdownText, (value, oldValue) => {
  previousCountdownValues.value = oldValue.split(':')
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
.offwork-header {
  position: relative;
  z-index: 2;
}

.offwork-hero {
  position: relative;
  min-height: 520px;
  display: grid;
  grid-template-columns: minmax(360px, 0.95fr) minmax(0, 1.05fr);
  gap: 0;
  align-items: stretch;
  padding: 0;
  border: 1px solid rgba(21, 25, 31, 0.1);
  border-radius: 8px;
  background:
    linear-gradient(90deg, rgba(8, 13, 18, 0.98), rgba(17, 27, 39, 0.94) 52%, rgba(31, 42, 56, 0.9)),
    #111827;
  color: #ffffff;
  box-shadow: 0 24px 70px rgba(44, 55, 67, 0.18);
  overflow: hidden;
  isolation: isolate;
}

.offwork-hero::before {
  position: absolute;
  inset: 0;
  z-index: 0;
  background:
    repeating-linear-gradient(90deg, rgba(255, 255, 255, 0.045) 0 1px, transparent 1px 52px),
    repeating-linear-gradient(0deg, rgba(255, 255, 255, 0.035) 0 1px, transparent 1px 52px);
  content: "";
  pointer-events: none;
}

.offwork-hero::after {
  position: absolute;
  right: 18px;
  bottom: 10px;
  z-index: 0;
  color: rgba(255, 255, 255, 0.055);
  font-size: 118px;
  line-height: 1;
  font-weight: 950;
  content: "SHIFT";
  pointer-events: none;
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
  font-variant-numeric: tabular-nums;
}

:global(:root:not([data-theme="dark"]) .offwork-page .offwork-hero) {
  border-color: rgba(21, 25, 31, 0.08);
  background:
    linear-gradient(90deg, rgba(250, 253, 246, 0.98), rgba(237, 245, 255, 0.94)),
    linear-gradient(135deg, rgba(255, 255, 255, 0.98), rgba(238, 245, 255, 0.92)),
    #ffffff;
  color: #111827;
  box-shadow: 0 24px 70px rgba(44, 55, 67, 0.12);
}

:global(:root:not([data-theme="dark"]) .offwork-page .offwork-hero::before) {
  background:
    repeating-linear-gradient(90deg, rgba(21, 25, 31, 0.04) 0 1px, transparent 1px 52px),
    repeating-linear-gradient(0deg, rgba(21, 25, 31, 0.035) 0 1px, transparent 1px 52px);
}

:global(:root:not([data-theme="dark"]) .offwork-page .offwork-hero::after) {
  color: rgba(21, 25, 31, 0.06);
}

.offwork-page {
  background:
    linear-gradient(135deg, rgba(199, 239, 56, 0.14), transparent 30%),
    linear-gradient(225deg, rgba(255, 104, 79, 0.12), transparent 32%),
    linear-gradient(180deg, rgba(37, 87, 246, 0.08), transparent 52%);
}

.offwork-board {
  position: relative;
  z-index: 1;
  display: grid;
  grid-template-rows: auto minmax(180px, 1fr) auto;
  gap: 24px;
  min-width: 0;
  padding: 30px;
  border-right: 1px solid rgba(255, 255, 255, 0.12);
  background:
    linear-gradient(180deg, rgba(3, 8, 13, 0.86), rgba(15, 23, 42, 0.66)),
    repeating-linear-gradient(135deg, rgba(255, 255, 255, 0.05) 0 2px, transparent 2px 10px);
}

.offwork-board-head,
.offwork-board-foot,
.offwork-dispatch-top {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 14px;
  min-width: 0;
  flex-wrap: wrap;
}

.offwork-status-pill {
  min-height: 30px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 5px 12px;
  border: 1px solid rgba(255, 255, 255, 0.16);
  border-radius: 8px;
  background: rgba(199, 239, 56, 0.12);
  color: #dffb6a;
  font-size: 13px;
  font-weight: 950;
}

.offwork-board-head small {
  color: rgba(255, 255, 255, 0.68);
  font-size: 13px;
  font-weight: 950;
}

.offwork-flip-clock {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  width: 100%;
  font-variant-numeric: tabular-nums;
}

.offwork-flip-unit {
  flex: 1 1 0;
  min-width: 0;
  display: grid;
  gap: 12px;
  justify-items: center;
}

.offwork-flip-leaf {
  position: relative;
  width: 100%;
  min-height: 168px;
  overflow: hidden;
  perspective: 900px;
  transform-style: preserve-3d;
  padding: 18px 10px 14px;
  border: 1px solid rgba(255, 255, 255, 0.12);
  border-radius: 8px;
  background:
    linear-gradient(180deg, #121b29 0 49%, #05080d 49% 51%, #182434 51% 100%);
  box-shadow:
    inset 0 1px 0 rgba(255, 255, 255, 0.12),
    inset 0 -18px 30px rgba(0, 0, 0, 0.2),
    0 18px 38px rgba(0, 0, 0, 0.24);
}

.offwork-flip-leaf::before {
  position: absolute;
  right: 0;
  left: 0;
  top: 50%;
  z-index: 4;
  height: 2px;
  background:
    linear-gradient(90deg, transparent, rgba(0, 0, 0, 0.68) 18% 82%, transparent),
    rgba(255, 255, 255, 0.08);
  content: "";
  pointer-events: none;
}

.offwork-flip-leaf::after {
  position: absolute;
  top: calc(50% - 5px);
  right: 14px;
  left: 14px;
  z-index: 5;
  height: 10px;
  background:
    radial-gradient(circle at left center, rgba(199, 239, 56, 0.82) 0 4px, transparent 5px),
    radial-gradient(circle at right center, rgba(199, 239, 56, 0.82) 0 4px, transparent 5px);
  content: "";
  pointer-events: none;
}

.offwork-flip-static,
.offwork-flip-panel {
  position: absolute;
  right: 0;
  left: 0;
  height: 50%;
  overflow: hidden;
}

.offwork-flip-static {
  z-index: 1;
}

.offwork-flip-static-top,
.offwork-flip-panel-top {
  top: 0;
  border-bottom: 1px solid rgba(0, 0, 0, 0.58);
  background: linear-gradient(180deg, #152033, #101827);
}

.offwork-flip-static-bottom,
.offwork-flip-panel-bottom {
  bottom: 0;
  background: linear-gradient(180deg, #172235, #1c2b3f);
}

.offwork-flip-static span,
.offwork-flip-panel span {
  position: absolute;
  right: 0;
  left: 0;
  display: grid;
  place-items: center;
  height: 200%;
  color: #ffffff;
  font-family: "DIN Alternate", "Bahnschrift", "SFMono-Regular", Consolas, monospace;
  font-size: 72px;
  line-height: 0.9;
  font-weight: 950;
  text-shadow: 0 8px 18px rgba(0, 0, 0, 0.34);
}

.offwork-flip-static-top span,
.offwork-flip-panel-top span {
  top: 0;
}

.offwork-flip-static-bottom span,
.offwork-flip-panel-bottom span {
  bottom: 0;
}

.offwork-flip-panel {
  z-index: 3;
  opacity: 0;
  transform-style: preserve-3d;
  backface-visibility: hidden;
  pointer-events: none;
}

.offwork-flip-panel-top {
  transform-origin: center bottom;
}

.offwork-flip-panel-bottom {
  transform: rotateX(90deg);
  transform-origin: center top;
}

.offwork-flip-leaf.is-flipping .offwork-flip-panel {
  opacity: 1;
}

.offwork-flip-leaf.is-flipping .offwork-flip-panel-top {
  animation: offwork-flip-top 520ms cubic-bezier(0.34, 0.08, 0.22, 1) forwards;
}

.offwork-flip-leaf.is-flipping .offwork-flip-panel-bottom {
  animation: offwork-flip-bottom 520ms cubic-bezier(0.16, 0.78, 0.22, 1) forwards;
}

.offwork-flip-unit small {
  color: rgba(255, 255, 255, 0.62);
  font-size: 12px;
  font-weight: 950;
}

.offwork-flip-clock em {
  color: rgba(199, 239, 56, 0.78);
  font-size: 46px;
  line-height: 1;
  font-style: normal;
  font-weight: 950;
  transform: translateY(-10px);
}

@keyframes offwork-flip-top {
  0% {
    filter: brightness(1.16);
    transform: rotateX(0deg);
  }

  100% {
    filter: brightness(0.62);
    transform: rotateX(-92deg);
  }
}

@keyframes offwork-flip-bottom {
  0% {
    filter: brightness(0.72);
    transform: rotateX(92deg);
  }

  54% {
    filter: brightness(0.8);
    transform: rotateX(92deg);
  }

  100% {
    filter: brightness(1);
    transform: rotateX(0deg);
  }
}

.offwork-board-foot {
  padding-top: 18px;
  border-top: 1px solid rgba(255, 255, 255, 0.12);
}

.offwork-board-foot span,
.offwork-board-foot strong {
  font-weight: 950;
}

.offwork-board-foot span {
  color: rgba(255, 255, 255, 0.7);
  font-size: 13px;
  line-height: 1.45;
}

.offwork-board-foot strong {
  color: #ffffff;
  font-size: 18px;
  font-variant-numeric: tabular-nums;
}

.offwork-dispatch {
  position: relative;
  z-index: 1;
  display: grid;
  gap: 18px;
  align-content: center;
  min-width: 0;
  padding: 30px;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.08), transparent 58%);
}

.offwork-tag {
  justify-self: start;
}

.offwork-progress-number {
  color: var(--lime);
  font-family: "DIN Alternate", "Bahnschrift", "SFMono-Regular", Consolas, monospace;
  font-size: 44px;
  line-height: 1;
  font-weight: 950;
  font-variant-numeric: tabular-nums;
}

.offwork-dispatch h2 {
  max-width: 640px;
  margin: 0;
  color: #ffffff;
  font-size: 58px;
  line-height: 1.02;
  font-weight: 950;
}

.offwork-dispatch p {
  max-width: 560px;
  margin: 0;
  color: rgba(255, 255, 255, 0.76);
  font-size: 18px;
  line-height: 1.7;
}

.offwork-route {
  display: grid;
  gap: 12px;
  max-width: 680px;
  padding: 8px 0 4px;
}

.offwork-route-line {
  height: 12px;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.12);
  overflow: hidden;
}

.offwork-route-line span {
  display: block;
  width: var(--progress);
  height: 100%;
  border-radius: inherit;
  background: linear-gradient(90deg, var(--blue), var(--lime) 48%, var(--coral));
  transition: width 240ms ease;
}

.offwork-route-stops {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 10px;
}

.offwork-route-stops span {
  display: grid;
  gap: 6px;
  min-height: 72px;
  padding: 12px;
  border: 1px solid rgba(255, 255, 255, 0.13);
  border-radius: 8px;
  background: rgba(255, 255, 255, 0.08);
}

.offwork-route-stops span.active {
  border-color: rgba(199, 239, 56, 0.36);
  background: rgba(199, 239, 56, 0.12);
}

.offwork-route-stops small {
  color: rgba(255, 255, 255, 0.62);
  font-size: 12px;
  font-weight: 950;
}

.offwork-route-stops strong {
  color: #ffffff;
  font-size: 20px;
  font-weight: 950;
  font-variant-numeric: tabular-nums;
}

:global(:root:not([data-theme="dark"]) .offwork-page .offwork-board) {
  background:
    linear-gradient(180deg, rgba(11, 18, 28, 0.97), rgba(18, 29, 42, 0.94)),
    repeating-linear-gradient(135deg, rgba(255, 255, 255, 0.05) 0 2px, transparent 2px 10px);
}

:global(:root:not([data-theme="dark"]) .offwork-page .offwork-status-pill) {
  border-color: rgba(199, 239, 56, 0.34);
  background: rgba(199, 239, 56, 0.12);
  color: #dffb6a;
}

:global(:root:not([data-theme="dark"]) .offwork-page .offwork-board .offwork-flip-static span),
:global(:root:not([data-theme="dark"]) .offwork-page .offwork-board .offwork-flip-panel span),
:global(:root:not([data-theme="dark"]) .offwork-page .offwork-board .offwork-board-foot strong) {
  color: #ffffff;
}

:global(:root:not([data-theme="dark"]) .offwork-page .offwork-board .offwork-flip-unit > small),
:global(:root:not([data-theme="dark"]) .offwork-page .offwork-board .offwork-board-head small),
:global(:root:not([data-theme="dark"]) .offwork-page .offwork-board .offwork-board-foot span) {
  color: rgba(255, 255, 255, 0.68);
}

:global(:root:not([data-theme="dark"]) .offwork-page .offwork-board .offwork-flip-clock em) {
  color: rgba(199, 239, 56, 0.82);
}

:global(:root:not([data-theme="dark"]) .offwork-page .offwork-dispatch) {
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.72), rgba(255, 255, 255, 0.24));
}

:global(:root:not([data-theme="dark"]) .offwork-page .offwork-dispatch h2),
:global(:root:not([data-theme="dark"]) .offwork-page .offwork-route-stops strong),
:global(:root:not([data-theme="dark"]) .offwork-page .offwork-metrics strong) {
  color: #111827;
}

:global(:root:not([data-theme="dark"]) .offwork-page .offwork-dispatch p),
:global(:root:not([data-theme="dark"]) .offwork-page .offwork-route-stops small),
:global(:root:not([data-theme="dark"]) .offwork-page .offwork-metrics small) {
  color: #526071;
}

:global(:root:not([data-theme="dark"]) .offwork-page .offwork-route-line) {
  background: rgba(21, 25, 31, 0.08);
}

:global(:root:not([data-theme="dark"]) .offwork-page .offwork-route-stops span),
:global(:root:not([data-theme="dark"]) .offwork-page .offwork-metrics span) {
  border-color: rgba(21, 25, 31, 0.08);
  background: rgba(255, 255, 255, 0.78);
  box-shadow: 0 14px 34px rgba(44, 55, 67, 0.08);
}

:global(:root:not([data-theme="dark"]) .offwork-page .offwork-route-stops span.active) {
  border-color: rgba(37, 87, 246, 0.22);
  background: rgba(37, 87, 246, 0.08);
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

  .offwork-board {
    border-right: 0;
    border-bottom: 1px solid rgba(255, 255, 255, 0.12);
  }

  .offwork-dispatch h2 {
    font-size: 50px;
  }
}

@media (max-width: 760px) {
  .offwork-hero {
    min-height: auto;
    gap: 0;
    padding: 0;
  }

  .offwork-board,
  .offwork-dispatch {
    padding: 16px;
  }

  .offwork-dispatch {
    gap: 14px;
  }

  .offwork-dispatch h2 {
    font-size: 34px;
  }

  .offwork-dispatch p {
    font-size: 16px;
  }

  .offwork-flip-clock {
    gap: 4px;
  }

  .offwork-flip-leaf {
    min-height: 112px;
    padding: 12px 6px 10px;
  }

  .offwork-flip-static span,
  .offwork-flip-panel span {
    font-size: 40px;
  }

  .offwork-flip-clock em {
    font-size: 24px;
    transform: translateY(-6px);
  }

  .offwork-progress-number {
    font-size: 34px;
  }

  .offwork-route-stops {
    grid-template-columns: 1fr;
  }

  .offwork-board-foot {
    align-items: flex-start;
    flex-direction: column;
  }

  .offwork-metrics strong {
    font-size: 22px;
  }

  .offwork-metrics,
  .offwork-settings,
  .offwork-timeline {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 420px) {
  .offwork-flip-static span,
  .offwork-flip-panel span {
    font-size: 34px;
  }

  .offwork-status-pill,
  .offwork-board-foot span {
    font-size: 12px;
  }
}
</style>
