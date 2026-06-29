<template>
  <main class="tool-page">
    <header class="tool-header">
      <button class="ghost-action" type="button" @click="goHome">
        <ArrowLeft :size="18" />
        首页
      </button>
      <div>
        <p class="eyebrow">Time Tool</p>
        <h1>时间转换</h1>
      </div>
      <el-button type="primary" @click="syncNow">
        <RefreshCcw :size="18" />
        当前时间
      </el-button>
    </header>

    <section class="tool-grid time-tool-grid">
      <div class="tool-panel">
        <div class="tool-panel-head">
          <h2>时间戳转时间</h2>
        </div>
        <label>
          时间戳
          <el-input v-model="timestampInput" placeholder="例如：1719360000" />
        </label>
        <label>
          单位
          <el-radio-group v-model="timestampUnit">
            <el-radio-button label="seconds">秒</el-radio-button>
            <el-radio-button label="milliseconds">毫秒</el-radio-button>
          </el-radio-group>
        </label>
        <el-button type="primary" @click="convertTimestamp">转换</el-button>
        <div class="tool-result-group">
          <div class="tool-result">
            <span>本地时间</span>
            <strong>{{ convertedDate }}</strong>
          </div>
          <div class="tool-result">
            <span>UTC 时间</span>
            <strong>{{ convertedUtcDate }}</strong>
          </div>
        </div>
      </div>

      <div class="tool-panel">
        <div class="tool-panel-head">
          <h2>时间转时间戳</h2>
        </div>
        <label>
          本地时间
          <el-date-picker
            v-model="dateInput"
            type="datetime"
            format="YYYY-MM-DD HH:mm:ss"
            value-format="YYYY-MM-DD HH:mm:ss"
            placeholder="选择日期时间"
            :clearable="false"
          />
        </label>
        <el-button type="primary" @click="convertDate">生成时间戳</el-button>
        <div class="tool-result-group">
          <div class="tool-result">
            <span>秒级</span>
            <strong>{{ secondsResult }}</strong>
          </div>
          <div class="tool-result">
            <span>毫秒级</span>
            <strong>{{ millisecondsResult }}</strong>
          </div>
        </div>
      </div>

      <div class="tool-panel">
        <div class="tool-panel-head">
          <h2>时间差计算</h2>
        </div>
        <label>
          起止时间
          <el-date-picker
            v-model="differenceRange"
            type="datetimerange"
            format="YYYY-MM-DD HH:mm:ss"
            value-format="YYYY-MM-DD HH:mm:ss"
            range-separator="至"
            start-placeholder="开始时间"
            end-placeholder="结束时间"
            :clearable="false"
          />
        </label>
        <el-button type="primary" @click="calculateDifference">计算差值</el-button>
        <div class="tool-result">
          <span>差值</span>
          <strong>{{ differenceResult }}</strong>
        </div>
        <div class="time-metric-grid">
          <div v-for="item in differenceTotals" :key="item.label" class="time-metric">
            <span>{{ item.label }}</span>
            <strong>{{ item.value }}</strong>
          </div>
        </div>
      </div>

      <div class="tool-panel">
        <div class="tool-panel-head">
          <h2>时间加减</h2>
        </div>
        <label>
          基准时间
          <el-date-picker
            v-model="calculateBaseDate"
            type="datetime"
            format="YYYY-MM-DD HH:mm:ss"
            value-format="YYYY-MM-DD HH:mm:ss"
            placeholder="选择基准时间"
            :clearable="false"
          />
        </label>
        <div class="time-form-row">
          <label>
            数值
            <el-input-number v-model="calculateAmount" :min="0" :precision="0" controls-position="right" />
          </label>
          <label>
            单位
            <el-select v-model="calculateUnit">
              <el-option
                v-for="item in calculateUnits"
                :key="item.value"
                :label="item.label"
                :value="item.value"
              />
            </el-select>
          </label>
        </div>
        <label>
          方向
          <el-radio-group v-model="calculateDirection">
            <el-radio-button label="add">增加</el-radio-button>
            <el-radio-button label="subtract">减少</el-radio-button>
          </el-radio-group>
        </label>
        <el-button type="primary" @click="calculateDateOffset">生成结果</el-button>
        <div class="tool-result-group">
          <div class="tool-result">
            <span>目标时间</span>
            <strong>{{ calculatedDate }}</strong>
          </div>
          <div class="tool-result">
            <span>毫秒时间戳</span>
            <strong>{{ calculatedTimestamp }}</strong>
          </div>
        </div>
      </div>

      <div class="tool-panel">
        <div class="tool-panel-head">
          <h2>相对时间</h2>
        </div>
        <label>
          目标时间
          <el-date-picker
            v-model="relativeDate"
            type="datetime"
            format="YYYY-MM-DD HH:mm:ss"
            value-format="YYYY-MM-DD HH:mm:ss"
            placeholder="选择目标时间"
            :clearable="false"
          />
        </label>
        <el-button type="primary" @click="calculateRelativeTime">计算相对时间</el-button>
        <div class="tool-result">
          <span>相对当前</span>
          <strong>{{ relativeResult }}</strong>
        </div>
      </div>

      <div class="tool-panel">
        <div class="tool-panel-head">
          <h2>快捷范围</h2>
        </div>
        <label>
          范围
          <el-radio-group v-model="rangePreset" class="time-range-options" @change="generateRange">
            <el-radio-button
              v-for="item in rangePresets"
              :key="item.value"
              :label="item.value"
            >
              {{ item.label }}
            </el-radio-button>
          </el-radio-group>
        </label>
        <el-button type="primary" @click="generateRange">生成范围</el-button>
        <div class="tool-result-group">
          <div class="tool-result">
            <span>开始时间</span>
            <strong>{{ rangeStart }}</strong>
          </div>
          <div class="tool-result">
            <span>结束时间</span>
            <strong>{{ rangeEnd }}</strong>
          </div>
        </div>
      </div>

      <div class="tool-panel">
        <div class="tool-panel-head">
          <h2>状态判断</h2>
        </div>
        <label>
          业务周期
          <el-date-picker
            v-model="statusRange"
            type="datetimerange"
            format="YYYY-MM-DD HH:mm:ss"
            value-format="YYYY-MM-DD HH:mm:ss"
            range-separator="至"
            start-placeholder="开始时间"
            end-placeholder="结束时间"
            :clearable="false"
          />
        </label>
        <el-button type="primary" @click="judgeTimeStatus">判断状态</el-button>
        <div class="tool-result-group">
          <div class="tool-result">
            <span>状态</span>
            <strong>{{ statusResult }}</strong>
          </div>
          <div class="tool-result">
            <span>说明</span>
            <strong>{{ statusDetail }}</strong>
          </div>
        </div>
      </div>
    </section>

    <el-alert
      v-if="timeError.length > 0"
      class="tool-alert"
      :title="timeError"
      type="error"
      show-icon
      :closable="false"
    />
  </main>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { ArrowLeft, RefreshCcw } from 'lucide-vue-next'

const minuteMilliseconds = 60 * 1000
const hourMilliseconds = 60 * minuteMilliseconds
const dayMilliseconds = 24 * hourMilliseconds
const calculateUnits = [
  { label: '分钟', value: 'minutes' },
  { label: '小时', value: 'hours' },
  { label: '天', value: 'days' },
  { label: '月', value: 'months' },
  { label: '年', value: 'years' }
]
const rangePresets = [
  { label: '今日', value: 'today' },
  { label: '本周', value: 'week' },
  { label: '本月', value: 'month' },
  { label: '今年', value: 'year' },
  { label: '近 7 天', value: 'last7' },
  { label: '近 30 天', value: 'last30' }
]
const router = useRouter()
const timestampInput = ref(String(Math.floor(Date.now() / 1000)))
const timestampUnit = ref('seconds')
const convertedDate = ref('')
const convertedUtcDate = ref('')
const dateInput = ref('')
const secondsResult = ref('')
const millisecondsResult = ref('')
const differenceRange = ref([])
const differenceResult = ref('')
const differenceTotals = ref([])
const calculateBaseDate = ref('')
const calculateAmount = ref(1)
const calculateUnit = ref('days')
const calculateDirection = ref('add')
const calculatedDate = ref('')
const calculatedTimestamp = ref('')
const relativeDate = ref('')
const relativeResult = ref('')
const rangePreset = ref('today')
const rangeStart = ref('')
const rangeEnd = ref('')
const statusRange = ref([])
const statusResult = ref('')
const statusDetail = ref('')
const timeError = ref('')

function padDatePart(value) {
  return String(value).padStart(2, '0')
}

function formatDate(date) {
  const year = date.getFullYear()
  const month = padDatePart(date.getMonth() + 1)
  const day = padDatePart(date.getDate())
  const hours = padDatePart(date.getHours())
  const minutes = padDatePart(date.getMinutes())
  const seconds = padDatePart(date.getSeconds())
  return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`
}

function formatUtcDate(date) {
  return date.toISOString().replace('T', ' ').replace(/\.\d{3}Z$/, ' UTC')
}

function parseLocalDate(value) {
  const [dateText, timeText] = value.split(' ')
  const [year, month, day] = dateText.split('-').map(Number)
  const [hour, minute, second] = timeText.split(':').map(Number)
  return new Date(year, month - 1, day, hour, minute, second)
}

function formatNumber(value) {
  return Number(value.toFixed(2)).toLocaleString('zh-CN')
}

function formatDuration(milliseconds) {
  const absoluteMilliseconds = Math.abs(milliseconds)
  let remainingMilliseconds = absoluteMilliseconds
  const days = Math.floor(remainingMilliseconds / dayMilliseconds)
  remainingMilliseconds -= days * dayMilliseconds
  const hours = Math.floor(remainingMilliseconds / hourMilliseconds)
  remainingMilliseconds -= hours * hourMilliseconds
  const minutes = Math.floor(remainingMilliseconds / minuteMilliseconds)
  remainingMilliseconds -= minutes * minuteMilliseconds
  const seconds = Math.floor(remainingMilliseconds / 1000)
  const parts = []

  if (days > 0) {
    parts.push(`${days} 天`)
  }

  if (hours > 0) {
    parts.push(`${hours} 小时`)
  }

  if (minutes > 0) {
    parts.push(`${minutes} 分钟`)
  }

  if (seconds > 0) {
    parts.push(`${seconds} 秒`)
  }

  if (parts.length === 0) {
    return '0 秒'
  }

  return parts.join(' ')
}

function formatRelativeDuration(milliseconds) {
  const absoluteMilliseconds = Math.abs(milliseconds)

  if (absoluteMilliseconds < minuteMilliseconds) {
    return `${Math.floor(absoluteMilliseconds / 1000)} 秒`
  }

  if (absoluteMilliseconds < hourMilliseconds) {
    return `${Math.floor(absoluteMilliseconds / minuteMilliseconds)} 分钟`
  }

  if (absoluteMilliseconds < dayMilliseconds) {
    return `${Math.floor(absoluteMilliseconds / hourMilliseconds)} 小时`
  }

  return `${Math.floor(absoluteMilliseconds / dayMilliseconds)} 天`
}

function getTimestampMultiplier() {
  if (timestampUnit.value === 'seconds') {
    return 1000
  }
  return 1
}

function convertTimestamp() {
  timeError.value = ''
  const timestamp = Number(timestampInput.value)
  if (Number.isNaN(timestamp)) {
    timeError.value = '请输入有效的数字时间戳。'
    return
  }

  const date = new Date(timestamp * getTimestampMultiplier())
  if (Number.isNaN(date.getTime())) {
    timeError.value = '时间戳超出有效日期范围。'
    return
  }

  convertedDate.value = formatDate(date)
  convertedUtcDate.value = formatUtcDate(date)
}

function convertDate() {
  timeError.value = ''
  if (dateInput.value.length === 0) {
    timeError.value = '请选择有效的本地时间。'
    return
  }

  const date = parseLocalDate(dateInput.value)
  const milliseconds = date.getTime()
  if (Number.isNaN(milliseconds)) {
    timeError.value = '请选择有效的本地时间。'
    return
  }

  secondsResult.value = String(Math.floor(milliseconds / 1000))
  millisecondsResult.value = String(milliseconds)
}

function setDifferenceTotals(milliseconds) {
  const absoluteMilliseconds = Math.abs(milliseconds)
  differenceTotals.value = [
    { label: '总天数', value: formatNumber(absoluteMilliseconds / dayMilliseconds) },
    { label: '总小时', value: formatNumber(absoluteMilliseconds / hourMilliseconds) },
    { label: '总分钟', value: formatNumber(absoluteMilliseconds / minuteMilliseconds) }
  ]
}

function calculateDifference() {
  timeError.value = ''
  if (differenceRange.value.length !== 2) {
    timeError.value = '请选择需要计算的起止时间。'
    return
  }

  const startDate = parseLocalDate(differenceRange.value[0])
  const endDate = parseLocalDate(differenceRange.value[1])
  const startMilliseconds = startDate.getTime()
  const endMilliseconds = endDate.getTime()
  if (Number.isNaN(startMilliseconds) || Number.isNaN(endMilliseconds)) {
    timeError.value = '请选择有效的起止时间。'
    return
  }

  const differenceMilliseconds = endMilliseconds - startMilliseconds
  let resultPrefix = '相差 '
  if (differenceMilliseconds < 0) {
    resultPrefix = '结束早于开始，相差 '
  }

  differenceResult.value = `${resultPrefix}${formatDuration(differenceMilliseconds)}`
  setDifferenceTotals(differenceMilliseconds)
}

function getOffsetDate(date, amount) {
  const result = new Date(date.getTime())
  let signedAmount = amount
  if (calculateDirection.value === 'subtract') {
    signedAmount = -amount
  }

  if (calculateUnit.value === 'minutes') {
    result.setMinutes(result.getMinutes() + signedAmount)
  } else if (calculateUnit.value === 'hours') {
    result.setHours(result.getHours() + signedAmount)
  } else if (calculateUnit.value === 'days') {
    result.setDate(result.getDate() + signedAmount)
  } else if (calculateUnit.value === 'months') {
    result.setMonth(result.getMonth() + signedAmount)
  } else if (calculateUnit.value === 'years') {
    result.setFullYear(result.getFullYear() + signedAmount)
  }

  return result
}

function calculateDateOffset() {
  timeError.value = ''
  if (calculateBaseDate.value.length === 0) {
    timeError.value = '请选择需要加减的基准时间。'
    return
  }

  const amount = Number(calculateAmount.value)
  if (!Number.isFinite(amount)) {
    timeError.value = '请输入有效的加减数值。'
    return
  }

  const baseDate = parseLocalDate(calculateBaseDate.value)
  const baseMilliseconds = baseDate.getTime()
  if (Number.isNaN(baseMilliseconds)) {
    timeError.value = '请选择有效的基准时间。'
    return
  }

  const resultDate = getOffsetDate(baseDate, amount)
  const resultMilliseconds = resultDate.getTime()
  calculatedDate.value = formatDate(resultDate)
  calculatedTimestamp.value = String(resultMilliseconds)
}

function calculateRelativeTime() {
  timeError.value = ''
  if (relativeDate.value.length === 0) {
    timeError.value = '请选择需要计算的目标时间。'
    return
  }

  const targetDate = parseLocalDate(relativeDate.value)
  const targetMilliseconds = targetDate.getTime()
  if (Number.isNaN(targetMilliseconds)) {
    timeError.value = '请选择有效的目标时间。'
    return
  }

  const differenceMilliseconds = targetMilliseconds - Date.now()
  if (Math.abs(differenceMilliseconds) < 30 * 1000) {
    relativeResult.value = '刚刚'
    return
  }

  let suffix = '前'
  if (differenceMilliseconds > 0) {
    suffix = '后'
  }
  relativeResult.value = `${formatRelativeDuration(differenceMilliseconds)}${suffix}`
}

function getStartOfDay(date) {
  const result = new Date(date.getTime())
  result.setHours(0, 0, 0, 0)
  return result
}

function getEndOfDay(date) {
  const result = new Date(date.getTime())
  result.setHours(23, 59, 59, 999)
  return result
}

function getStartOfWeek(date) {
  const result = getStartOfDay(date)
  const weekday = result.getDay()
  let offset = weekday - 1
  if (weekday === 0) {
    offset = 6
  }
  result.setDate(result.getDate() - offset)
  return result
}

function generateRange() {
  timeError.value = ''
  const now = new Date()
  let startDate = getStartOfDay(now)
  let endDate = getEndOfDay(now)

  if (rangePreset.value === 'week') {
    startDate = getStartOfWeek(now)
    endDate = new Date(startDate.getTime())
    endDate.setDate(endDate.getDate() + 6)
    endDate = getEndOfDay(endDate)
  } else if (rangePreset.value === 'month') {
    startDate = new Date(now.getFullYear(), now.getMonth(), 1, 0, 0, 0)
    endDate = new Date(now.getFullYear(), now.getMonth() + 1, 0, 23, 59, 59)
  } else if (rangePreset.value === 'year') {
    startDate = new Date(now.getFullYear(), 0, 1, 0, 0, 0)
    endDate = new Date(now.getFullYear(), 11, 31, 23, 59, 59)
  } else if (rangePreset.value === 'last7') {
    startDate.setDate(startDate.getDate() - 6)
  } else if (rangePreset.value === 'last30') {
    startDate.setDate(startDate.getDate() - 29)
  }

  rangeStart.value = formatDate(startDate)
  rangeEnd.value = formatDate(endDate)
}

function judgeTimeStatus() {
  timeError.value = ''
  if (statusRange.value.length !== 2) {
    timeError.value = '请选择需要判断的业务周期。'
    return
  }

  const startDate = parseLocalDate(statusRange.value[0])
  const endDate = parseLocalDate(statusRange.value[1])
  const startMilliseconds = startDate.getTime()
  const endMilliseconds = endDate.getTime()
  if (Number.isNaN(startMilliseconds) || Number.isNaN(endMilliseconds)) {
    timeError.value = '请选择有效的业务周期。'
    return
  }

  if (startMilliseconds > endMilliseconds) {
    timeError.value = '开始时间不能晚于结束时间。'
    return
  }

  const nowMilliseconds = Date.now()
  if (nowMilliseconds < startMilliseconds) {
    statusResult.value = '未开始'
    statusDetail.value = `还有 ${formatDuration(startMilliseconds - nowMilliseconds)} 开始`
    return
  }

  if (nowMilliseconds > endMilliseconds) {
    statusResult.value = '已结束'
    statusDetail.value = `已结束 ${formatDuration(nowMilliseconds - endMilliseconds)}`
    return
  }

  statusResult.value = '进行中'
  statusDetail.value = `剩余 ${formatDuration(endMilliseconds - nowMilliseconds)}`
}

function syncNow() {
  const now = new Date()
  const milliseconds = now.getTime()
  const later = new Date(milliseconds)
  later.setHours(later.getHours() + 2)
  const yesterday = new Date(milliseconds)
  yesterday.setDate(yesterday.getDate() - 1)
  timestampInput.value = String(Math.floor(milliseconds / 1000))
  timestampUnit.value = 'seconds'
  convertedDate.value = formatDate(now)
  convertedUtcDate.value = formatUtcDate(now)
  dateInput.value = formatDate(now)
  secondsResult.value = String(Math.floor(milliseconds / 1000))
  millisecondsResult.value = String(milliseconds)
  differenceRange.value = [formatDate(now), formatDate(later)]
  calculateBaseDate.value = formatDate(now)
  relativeDate.value = formatDate(yesterday)
  statusRange.value = [formatDate(now), formatDate(later)]
  calculateDifference()
  calculateDateOffset()
  calculateRelativeTime()
  generateRange()
  judgeTimeStatus()
  timeError.value = ''
}

function goHome() {
  router.push('/')
}

syncNow()
</script>

<style scoped>
.time-tool-grid {
  grid-template-columns: repeat(3, minmax(0, 1fr));
}

.time-form-row {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 12px;
}

.time-metric-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 10px;
}

.time-metric {
  display: grid;
  gap: 4px;
  min-height: 70px;
  padding: 12px;
  border: 1px solid rgba(21, 25, 31, 0.1);
  border-radius: 8px;
  background: rgba(255, 255, 255, 0.72);
}

.time-metric span {
  color: var(--muted);
  font-size: 12px;
  font-weight: 900;
}

.time-metric strong {
  color: var(--ink);
  font-size: 18px;
  line-height: 1.2;
  font-weight: 950;
  word-break: break-word;
}

.time-tool-grid :deep(.el-date-editor),
.time-tool-grid :deep(.el-input-number),
.time-tool-grid :deep(.el-select) {
  width: 100%;
}

.time-tool-grid :deep(.el-radio-group) {
  align-items: stretch;
}

.time-range-options {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.time-range-options :deep(.el-radio-button__inner) {
  border-left: 1px solid var(--el-border-color);
  border-radius: 6px;
}

@media (max-width: 1380px) {
  .time-tool-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}

@media (max-width: 760px) {
  .time-tool-grid,
  .time-form-row,
  .time-metric-grid {
    grid-template-columns: 1fr;
  }
}
</style>
