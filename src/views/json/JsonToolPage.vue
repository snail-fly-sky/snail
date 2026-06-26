<template>
  <main class="tool-page">
    <header class="tool-header">
      <button class="ghost-action" type="button" @click="goHome">
        <ArrowLeft :size="18" />
        首页
      </button>
      <div>
        <p class="eyebrow">JSON Tool</p>
        <h1>JSON 处理</h1>
      </div>
    </header>

    <section class="tool-grid json-tool-grid">
      <div class="tool-panel">
        <div class="tool-panel-head">
          <h2>输入</h2>
        </div>
        <el-input
          v-model="jsonInput"
          class="tool-textarea"
          type="textarea"
          :rows="18"
          resize="none"
          placeholder="粘贴 JSON 内容"
        />
      </div>

      <div class="tool-panel">
        <div class="tool-panel-head">
          <h2>输出</h2>
          <div class="tool-actions">
            <el-button plain @click="loadSample">示例</el-button>
            <el-button plain @click="clearJson">清空</el-button>
            <el-button type="primary" plain @click="beautifyJson">
              <Braces :size="18" />
              美化
            </el-button>
            <el-button plain @click="minifyJson">压缩</el-button>
            <el-button plain @click="copyOutput">复制</el-button>
          </div>
        </div>
        <el-input
          v-model="jsonOutput"
          class="tool-textarea"
          type="textarea"
          :rows="18"
          resize="none"
          placeholder="处理结果会显示在这里"
        />
      </div>
    </section>

    <el-alert
      v-if="jsonError.length > 0"
      class="tool-alert"
      :title="jsonError"
      type="error"
      show-icon
      :closable="false"
    />
  </main>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { ArrowLeft, Braces } from 'lucide-vue-next'

const router = useRouter()
const sampleJson = `{
  "name": "snail",
  "tools": ["resume", "json", "time"],
  "enabled": true
}`
const jsonInput = ref(sampleJson)
const jsonOutput = ref('')
const jsonError = ref('')

function transformJson(space) {
  jsonError.value = ''
  try {
    const parsed = JSON.parse(jsonInput.value)
    jsonOutput.value = JSON.stringify(parsed, null, space)
  } catch (error) {
    jsonError.value = error.message
  }
}

function formatJson() {
  transformJson(2)
}

function beautifyJson() {
  formatJson()
}

function minifyJson() {
  transformJson(0)
}

async function copyOutput() {
  await navigator.clipboard.writeText(jsonOutput.value)
  ElMessage.success('已复制结果')
}

function loadSample() {
  jsonInput.value = sampleJson
  jsonOutput.value = ''
  jsonError.value = ''
}

function clearJson() {
  jsonInput.value = ''
  jsonOutput.value = ''
  jsonError.value = ''
}

function goHome() {
  router.push('/')
}
</script>
