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
        <div class="tool-result">
          <span>本地时间</span>
          <strong>{{ convertedDate }}</strong>
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

const router = useRouter()
const timestampInput = ref(String(Math.floor(Date.now() / 1000)))
const timestampUnit = ref('seconds')
const convertedDate = ref('')
const dateInput = ref('')
const secondsResult = ref('')
const millisecondsResult = ref('')
const timeError = ref('')

function formatDate(date) {
  return date.toLocaleString('zh-CN', { hour12: false })
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
  convertedDate.value = formatDate(date)
}

function convertDate() {
  timeError.value = ''
  const date = new Date(dateInput.value)
  const milliseconds = date.getTime()
  if (Number.isNaN(milliseconds)) {
    timeError.value = '请选择有效的本地时间。'
    return
  }

  secondsResult.value = String(Math.floor(milliseconds / 1000))
  millisecondsResult.value = String(milliseconds)
}

function syncNow() {
  const now = new Date()
  const milliseconds = now.getTime()
  timestampInput.value = String(Math.floor(milliseconds / 1000))
  timestampUnit.value = 'seconds'
  convertedDate.value = formatDate(now)
  dateInput.value = now.toLocaleString('sv-SE')
  secondsResult.value = String(Math.floor(milliseconds / 1000))
  millisecondsResult.value = String(milliseconds)
  timeError.value = ''
}

function goHome() {
  router.push('/')
}

syncNow()
</script>
