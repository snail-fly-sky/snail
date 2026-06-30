<template>
  <div class="frontend-text-workbench">
    <section class="frontend-tool-card frontend-text-card frontend-text-span-12 frontend-text-url-card">
      <div class="tool-panel-head">
        <h2>URL 参数解析</h2>
        <div class="tool-actions frontend-panel-head-actions">
          <el-button type="primary" @click="parseUrlParams">解析</el-button>
          <el-button plain @click="buildUrlFromParams">拼接</el-button>
          <el-button plain @click="copyText(urlOutput)">复制结果</el-button>
        </div>
      </div>
      <div class="frontend-text-url-layout">
        <div class="frontend-text-control-panel">
          <label class="frontend-text-field">
            <span>待解析 URL</span>
            <el-input v-model="urlInput" placeholder="https://example.com?a=1&b=2" />
          </label>
          <div class="frontend-text-param-table">
            <div class="frontend-text-table-head">
              <span>Key</span>
              <span>Value</span>
            </div>
            <div class="frontend-param-list">
              <div v-for="item in urlParams" :key="item.id" class="frontend-param-row">
                <el-input v-model="item.key" placeholder="key" />
                <el-input v-model="item.value" placeholder="value" />
              </div>
            </div>
          </div>
        </div>
        <div class="frontend-text-result-panel">
          <div class="frontend-text-panel-head">
            <span>拼接结果</span>
            <strong>{{ urlParams.length }} params</strong>
          </div>
          <pre v-if="urlOutput.length > 0" class="frontend-text-code">{{ urlOutput }}</pre>
          <el-empty
            v-else
            class="frontend-empty-state"
            description="未生成结果"
            :image-size="48"
          />
          <div class="frontend-text-meta-grid">
            <span>基础地址</span><strong>{{ urlBase }}</strong>
            <span>Hash</span><strong>{{ urlHash }}</strong>
          </div>
        </div>
      </div>
    </section>

    <section class="frontend-tool-card frontend-text-card frontend-text-span-6">
      <div class="tool-panel-head">
        <h2>URL 编码 / 解码</h2>
        <div class="tool-actions frontend-panel-head-actions">
          <el-button type="primary" plain @click="encodeUrlText">编码</el-button>
          <el-button plain @click="decodeUrlText">解码</el-button>
          <el-button plain @click="copyText(urlCodecOutput)">复制</el-button>
        </div>
      </div>
      <div class="frontend-text-io-grid">
        <label class="frontend-text-editor-panel">
          <span>输入</span>
          <el-input
            v-model="urlCodecInput"
            type="textarea"
            :rows="5"
            resize="none"
            placeholder="输入 URL 或参数文本"
          />
        </label>
        <label class="frontend-text-editor-panel is-result">
          <span>结果</span>
          <el-input
            v-model="urlCodecOutput"
            type="textarea"
            :rows="5"
            resize="none"
            placeholder="处理结果"
          />
        </label>
      </div>
    </section>

    <section class="frontend-tool-card frontend-text-card frontend-text-span-6">
      <div class="tool-panel-head">
        <h2>HTML 实体转义</h2>
        <div class="tool-actions frontend-panel-head-actions">
          <el-button type="primary" plain @click="encodeHtmlEntities">转义</el-button>
          <el-button plain @click="decodeHtmlEntities">反转义</el-button>
          <el-button plain @click="copyText(htmlEntityOutput)">复制</el-button>
        </div>
      </div>
      <div class="frontend-text-io-grid">
        <label class="frontend-text-editor-panel">
          <span>输入</span>
          <el-input
            v-model="htmlEntityInput"
            type="textarea"
            :rows="5"
            resize="none"
            placeholder="<div>hello</div>"
          />
        </label>
        <label class="frontend-text-editor-panel is-result">
          <span>结果</span>
          <el-input
            v-model="htmlEntityOutput"
            type="textarea"
            :rows="5"
            resize="none"
            placeholder="处理结果"
          />
        </label>
      </div>
    </section>

    <section class="frontend-tool-card frontend-text-card frontend-text-span-8">
      <div class="tool-panel-head">
        <h2>文本批处理</h2>
        <div class="tool-actions frontend-panel-head-actions">
          <el-button type="primary" plain @click="removeEmptyLines">去空行</el-button>
          <el-button plain @click="uniqueLines">去重复</el-button>
          <el-button plain @click="sortLines">排序</el-button>
          <el-button plain @click="trimLines">清理空格</el-button>
          <el-button plain @click="upperCaseText">大写</el-button>
          <el-button plain @click="lowerCaseText">小写</el-button>
          <el-button plain @click="copyText(batchTextOutput)">复制</el-button>
        </div>
      </div>
      <div class="frontend-text-io-grid">
        <label class="frontend-text-editor-panel">
          <span>输入</span>
          <el-input
            v-model="batchTextInput"
            type="textarea"
            :rows="6"
            resize="none"
            placeholder="每行一条文本"
          />
        </label>
        <label class="frontend-text-editor-panel is-result">
          <span>结果</span>
          <el-input
            v-model="batchTextOutput"
            type="textarea"
            :rows="6"
            resize="none"
            placeholder="处理结果"
          />
        </label>
      </div>
    </section>

    <section class="frontend-tool-card frontend-text-card frontend-text-span-4">
      <div class="tool-panel-head">
        <h2>浏览器 UA 解析</h2>
        <div class="tool-actions frontend-panel-head-actions">
          <el-button plain @click="parseUserAgent">解析</el-button>
        </div>
      </div>
      <div class="frontend-text-ua-layout">
        <label class="frontend-text-editor-panel">
          <span>User-Agent</span>
          <el-input
            v-model="userAgentInput"
            type="textarea"
            :rows="5"
            resize="none"
            placeholder="粘贴 User-Agent"
          />
        </label>
        <div class="frontend-kv-list frontend-text-kv-list">
          <span>浏览器</span><strong>{{ userAgentInfo.browser }}</strong>
          <span>系统</span><strong>{{ userAgentInfo.os }}</strong>
          <span>设备</span><strong>{{ userAgentInfo.device }}</strong>
        </div>
      </div>
    </section>

    <section class="frontend-tool-card frontend-text-card frontend-text-span-6">
      <div class="tool-panel-head">
        <h2>文本差异对比</h2>
        <div class="tool-actions frontend-panel-head-actions">
          <el-button type="primary" plain @click="compareText">对比</el-button>
        </div>
      </div>
      <div class="frontend-text-io-grid">
        <label class="frontend-text-editor-panel">
          <span>原文本</span>
          <el-input v-model="diffLeft" type="textarea" :rows="5" resize="none" placeholder="原文本" />
        </label>
        <label class="frontend-text-editor-panel is-result">
          <span>新文本</span>
          <el-input v-model="diffRight" type="textarea" :rows="5" resize="none" placeholder="新文本" />
        </label>
      </div>
      <div class="frontend-diff-list frontend-text-diff-list">
        <div v-for="item in diffRows" :key="item.id" :class="['frontend-diff-row', item.type]">
          <span>{{ item.label }}</span>
          <code>{{ item.text }}</code>
        </div>
      </div>
    </section>

    <section class="frontend-tool-card frontend-text-card frontend-text-span-6">
      <div class="tool-panel-head">
        <h2>正则匹配测试</h2>
        <div class="tool-actions frontend-panel-head-actions">
          <el-button type="primary" plain @click="runRegex">匹配</el-button>
          <el-button plain @click="replaceRegex">替换</el-button>
          <el-button plain @click="copyText(regexOutput)">复制</el-button>
        </div>
      </div>
      <div class="frontend-text-regex-layout">
        <div class="frontend-text-control-panel">
          <label class="frontend-text-field">
            <span>正则表达式</span>
            <el-input v-model="regexPattern" placeholder="正则表达式，不需要 / /" />
          </label>
          <div class="frontend-control-grid compact">
            <label class="frontend-text-field">
              <span>flags</span>
              <el-input v-model="regexFlags" placeholder="gi" />
            </label>
            <label class="frontend-text-field">
              <span>替换为</span>
              <el-input v-model="regexReplacement" placeholder="$1" />
            </label>
          </div>
          <label class="frontend-text-editor-panel">
            <span>待匹配文本</span>
            <el-input v-model="regexText" type="textarea" :rows="5" resize="none" placeholder="待匹配文本" />
          </label>
        </div>
        <div class="frontend-text-result-panel">
          <div class="frontend-text-panel-head">
            <span>处理结果</span>
          </div>
          <pre v-if="regexOutput.length > 0" class="frontend-text-code">{{ regexOutput }}</pre>
          <el-empty
            v-else
            class="frontend-empty-state"
            description="未生成结果"
            :image-size="48"
          />
        </div>
      </div>
    </section>

  </div>
</template>

<script setup>
import { ref } from 'vue'
import { ElMessage } from 'element-plus'

const urlInput = ref('https://example.com/search?keyword=snail&page=1')
const urlParams = ref([])
const urlBase = ref('https://example.com/search')
const urlHash = ref('')
const urlOutput = ref('')
const urlCodecInput = ref('https://example.com/?q=前端工具')
const urlCodecOutput = ref('')
const htmlEntityInput = ref('<button class="primary">保存</button>')
const htmlEntityOutput = ref('')
const batchTextInput = ref('apple\n\nbanana\napple\n  orange  ')
const batchTextOutput = ref('')
const diffLeft = ref('首页\nJSON 工具\n二维码')
const diffRight = ref('首页\nJSON 工具\n图片处理')
const diffRows = ref([])
const regexPattern = ref('\\btool\\b')
const regexFlags = ref('gi')
const regexReplacement = ref('utility')
const regexText = ref('tool, frontend tool, toolbar')
const regexOutput = ref('')
const userAgentInput = ref(navigator.userAgent)
const userAgentInfo = ref({
  browser: '',
  os: '',
  device: ''
})


function parseUrlParams() {
  try {
    const url = new URL(urlInput.value, window.location.origin)
    urlBase.value = `${url.origin}${url.pathname}`
    urlHash.value = url.hash
    urlParams.value = Array.from(url.searchParams.entries()).map((item, index) => {
      return {
        id: index,
        key: item[0],
        value: item[1]
      }
    })
    urlOutput.value = url.href
  } catch (error) {
    ElMessage.error(error.message)
  }
}

function buildUrlFromParams() {
  const params = new URLSearchParams()
  urlParams.value.forEach((item) => {
    if (item.key.length > 0) {
      params.append(item.key, item.value)
    }
  })

  const query = params.toString()
  if (query.length > 0) {
    urlOutput.value = `${urlBase.value}?${query}${urlHash.value}`
  } else {
    urlOutput.value = `${urlBase.value}${urlHash.value}`
  }
}

function encodeUrlText() {
  urlCodecOutput.value = encodeURIComponent(urlCodecInput.value)
}

function decodeUrlText() {
  try {
    urlCodecOutput.value = decodeURIComponent(urlCodecInput.value)
  } catch (error) {
    ElMessage.error(error.message)
  }
}

function encodeHtmlEntities() {
  htmlEntityOutput.value = htmlEntityInput.value
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;')
}

function decodeHtmlEntities() {
  const textarea = document.createElement('textarea')
  textarea.innerHTML = htmlEntityInput.value
  htmlEntityOutput.value = textarea.value
}

function trimLines() {
  batchTextOutput.value = batchTextInput.value.split('\n').map((line) => line.trim()).join('\n')
}

function removeEmptyLines() {
  batchTextOutput.value = batchTextInput.value.split('\n').filter((line) => line.trim().length > 0).join('\n')
}

function uniqueLines() {
  const seen = new Set()
  const lines = []
  batchTextInput.value.split('\n').forEach((line) => {
    if (!seen.has(line)) {
      seen.add(line)
      lines.push(line)
    }
  })
  batchTextOutput.value = lines.join('\n')
}

function sortLines() {
  batchTextOutput.value = batchTextInput.value.split('\n').sort((left, right) => left.localeCompare(right)).join('\n')
}

function upperCaseText() {
  batchTextOutput.value = batchTextInput.value.toUpperCase()
}

function lowerCaseText() {
  batchTextOutput.value = batchTextInput.value.toLowerCase()
}

function compareText() {
  const leftLines = diffLeft.value.split('\n')
  const rightLines = diffRight.value.split('\n')
  const maxLength = Math.max(leftLines.length, rightLines.length)
  const rows = []

  for (let index = 0; index < maxLength; index += 1) {
    const left = leftLines[index]
    const right = rightLines[index]

    if (left === right) {
      rows.push({
        id: `same-${index}`,
        type: 'same',
        label: '=',
        text: left
      })
    } else {
      if (left !== undefined) {
        rows.push({
          id: `remove-${index}`,
          type: 'remove',
          label: '-',
          text: left
        })
      }

      if (right !== undefined) {
        rows.push({
          id: `add-${index}`,
          type: 'add',
          label: '+',
          text: right
        })
      }
    }
  }

  diffRows.value = rows
}

function runRegex() {
  try {
    const flags = regexFlags.value.includes('g') ? regexFlags.value : `${regexFlags.value}g`
    const regex = new RegExp(regexPattern.value, flags)
    const matches = []
    let match = regex.exec(regexText.value)

    while (match) {
      matches.push({
        index: match.index,
        value: match[0],
        groups: match.slice(1)
      })
      match = regex.exec(regexText.value)
    }

    regexOutput.value = JSON.stringify(matches, null, 2)
  } catch (error) {
    ElMessage.error(error.message)
  }
}

function replaceRegex() {
  try {
    const regex = new RegExp(regexPattern.value, regexFlags.value)
    regexOutput.value = regexText.value.replace(regex, regexReplacement.value)
  } catch (error) {
    ElMessage.error(error.message)
  }
}

function parseUserAgent() {
  userAgentInfo.value = {
    browser: parseBrowser(userAgentInput.value),
    os: parseOperatingSystem(userAgentInput.value),
    device: parseDevice(userAgentInput.value)
  }
}

function parseBrowser(value) {
  if (value.includes('Edg/')) {
    return browserVersion(value, /Edg\/([\d.]+)/, 'Edge')
  }

  if (value.includes('Chrome/')) {
    return browserVersion(value, /Chrome\/([\d.]+)/, 'Chrome')
  }

  if (value.includes('Firefox/')) {
    return browserVersion(value, /Firefox\/([\d.]+)/, 'Firefox')
  }

  if (value.includes('Safari/') && value.includes('Version/')) {
    return browserVersion(value, /Version\/([\d.]+)/, 'Safari')
  }

  return '未知浏览器'
}

function browserVersion(value, pattern, name) {
  const match = value.match(pattern)
  if (match) {
    return `${name} ${match[1]}`
  }

  return name
}

function parseOperatingSystem(value) {
  if (value.includes('Windows NT 10.0')) {
    return 'Windows 10 / 11'
  }

  if (value.includes('Mac OS X')) {
    return 'macOS'
  }

  if (value.includes('Android')) {
    return 'Android'
  }

  if (value.includes('iPhone') || value.includes('iPad')) {
    return 'iOS / iPadOS'
  }

  if (value.includes('Linux')) {
    return 'Linux'
  }

  return '未知系统'
}

function parseDevice(value) {
  if (value.includes('Mobile')) {
    return '移动设备'
  }

  if (value.includes('Tablet') || value.includes('iPad')) {
    return '平板设备'
  }

  return '桌面设备'
}

parseUrlParams()
compareText()
runRegex()
parseUserAgent()

async function copyText(value) {
  if (value.length === 0) {
    ElMessage.warning('暂无可复制内容')
    return
  }

  await navigator.clipboard.writeText(value)
  ElMessage.success('已复制')
}

function getActiveCopyText() {
  return batchTextOutput.value
}

defineExpose({
  getActiveCopyText
})
</script>

<style scoped>
.frontend-text-workbench {
  display: grid;
  grid-template-columns: repeat(12, minmax(0, 1fr));
  gap: 12px;
  align-items: stretch;
}

.frontend-text-card {
  --text-panel-border: #d7dee8;
  --text-panel-soft: #f7f9fc;
  --text-panel-ink: #15191f;
  --text-panel-muted: #5f6d7e;
  align-content: stretch;
  gap: 12px;
  padding: 12px;
}

.frontend-text-span-12 {
  grid-column: span 12;
}

.frontend-text-span-8 {
  grid-column: span 8;
}

.frontend-text-span-6 {
  grid-column: span 6;
}

.frontend-text-span-4 {
  grid-column: span 4;
}

.frontend-text-card .tool-panel-head {
  min-height: 36px;
}

.frontend-text-card .tool-panel-head h2 {
  font-size: 20px;
  line-height: 1.2;
}

.frontend-text-card .tool-actions {
  gap: 8px;
}

.frontend-text-card .tool-actions .el-button {
  min-height: 34px;
  padding: 0 14px;
}

.frontend-text-url-layout,
.frontend-text-regex-layout {
  display: grid;
  grid-template-columns: minmax(300px, 0.36fr) minmax(0, 1fr);
  gap: 12px;
  min-width: 0;
  min-height: 0;
}

.frontend-text-regex-layout {
  grid-template-columns: minmax(260px, 0.48fr) minmax(0, 1fr);
}

.frontend-text-control-panel,
.frontend-text-result-panel,
.frontend-text-param-table,
.frontend-text-editor-panel {
  min-width: 0;
}

.frontend-text-control-panel {
  display: grid;
  gap: 10px;
  align-content: start;
}

.frontend-text-field,
.frontend-text-editor-panel {
  display: grid;
  gap: 7px;
  color: var(--text-panel-muted);
  font-size: 12px;
  font-weight: 950;
}

.frontend-text-field > span,
.frontend-text-editor-panel > span {
  min-height: 22px;
  display: inline-flex;
  align-items: center;
  width: fit-content;
  padding: 0 9px;
  border-radius: 999px;
  background: #15191f;
  color: #ffffff;
  font-size: 12px;
  font-weight: 950;
  line-height: 1;
  letter-spacing: 0;
}

.frontend-text-field > span {
  justify-self: start;
  align-self: start;
}

.frontend-text-editor-panel.is-result > span {
  background: #2557f6;
}

.frontend-text-param-table {
  display: grid;
  gap: 8px;
  padding: 10px;
  border: 1px solid var(--text-panel-border);
  border-radius: 8px;
  background: var(--text-panel-soft);
}

.frontend-text-table-head {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 8px;
  color: var(--text-panel-muted);
  font-size: 11px;
  font-weight: 950;
  line-height: 1;
  text-transform: uppercase;
}

.frontend-text-param-table .frontend-param-list {
  max-height: 122px;
  gap: 7px;
}

.frontend-text-param-table .frontend-param-row {
  gap: 7px;
}

.frontend-text-result-panel {
  display: grid;
  grid-template-rows: auto minmax(0, 1fr) auto;
  gap: 9px;
  padding: 10px;
  border: 1px solid rgba(37, 87, 246, 0.18);
  border-radius: 8px;
  background: #ffffff;
}

.frontend-text-panel-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
  min-width: 0;
}

.frontend-text-panel-head span,
.frontend-text-panel-head strong {
  color: var(--text-panel-muted);
  font-size: 12px;
  font-weight: 950;
  line-height: 1;
}

.frontend-text-panel-head strong {
  color: var(--blue);
  white-space: nowrap;
}

.frontend-text-code {
  width: 100%;
  min-width: 0;
  min-height: 0;
  max-height: 180px;
  margin: 0;
  padding: 12px;
  border: 0;
  border-radius: 8px;
  background: #11161d;
  color: #f5ffcf;
  font-family: "Cascadia Code", "Consolas", monospace;
  font-size: 12px;
  font-weight: 750;
  line-height: 1.55;
  overflow: auto;
  white-space: pre-wrap;
  word-break: break-word;
}

.frontend-text-meta-grid {
  display: grid;
  grid-template-columns: 68px minmax(0, 1fr);
  gap: 7px 10px;
  padding-top: 8px;
  border-top: 1px solid rgba(21, 25, 31, 0.08);
}

.frontend-text-meta-grid span,
.frontend-text-meta-grid strong {
  min-width: 0;
  color: var(--text-panel-muted);
  font-size: 12px;
  font-weight: 950;
  line-height: 1.35;
}

.frontend-text-meta-grid strong {
  color: var(--text-panel-ink);
  overflow-wrap: anywhere;
}

.frontend-text-io-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 10px;
  min-width: 0;
  min-height: 0;
}

.frontend-text-editor-panel {
  position: relative;
  display: block;
  min-height: 158px;
  padding: 40px 10px 10px;
  border: 1px solid var(--text-panel-border);
  border-radius: 8px;
  background: var(--text-panel-soft);
}

.frontend-text-span-8 .frontend-text-editor-panel {
  min-height: 214px;
}

.frontend-text-span-4 .frontend-text-editor-panel {
  min-height: 146px;
}

.frontend-text-editor-panel > span {
  position: absolute;
  top: 10px;
  left: 10px;
  z-index: 1;
}

.frontend-text-editor-panel.is-result {
  border-color: rgba(37, 87, 246, 0.22);
  background: #f8fbff;
}

.frontend-text-ua-layout {
  display: grid;
  grid-template-columns: minmax(0, 1fr);
  gap: 10px;
  min-width: 0;
}

.frontend-text-kv-list {
  align-content: start;
  gap: 8px 10px;
  border: 1px solid var(--text-panel-border);
  background: var(--text-panel-soft);
}

.frontend-text-diff-list {
  max-height: 154px;
  padding: 10px;
  border: 1px solid var(--text-panel-border);
  border-radius: 8px;
  background: var(--text-panel-soft);
}

.frontend-text-diff-list .frontend-diff-row {
  padding: 7px 8px;
  border: 1px solid rgba(21, 25, 31, 0.06);
}

.frontend-text-card :deep(.el-input__wrapper),
.frontend-text-card :deep(.el-textarea__inner) {
  box-shadow: 0 0 0 1px rgba(21, 25, 31, 0.12) inset;
}

.frontend-text-editor-panel :deep(.el-textarea) {
  display: block;
  height: 100%;
}

.frontend-text-card :deep(.el-textarea__inner) {
  height: 100%;
  min-height: 0 !important;
  font-family: "Cascadia Code", "Consolas", monospace;
  font-size: 13px;
  line-height: 1.5;
}

.frontend-text-card :deep(.el-textarea__inner:focus),
.frontend-text-card :deep(.el-input__wrapper.is-focus) {
  box-shadow: 0 0 0 1px rgba(37, 87, 246, 0.38) inset;
}

:global(:root[data-theme="dark"]) .frontend-text-card {
  --text-panel-border: rgba(255, 255, 255, 0.12);
  --text-panel-soft: #0f1724;
  --text-panel-ink: #eef4ff;
  --text-panel-muted: #b7c3d7;
}

:global(:root[data-theme="dark"]) .frontend-text-param-table,
:global(:root[data-theme="dark"]) .frontend-text-editor-panel,
:global(:root[data-theme="dark"]) .frontend-text-kv-list,
:global(:root[data-theme="dark"]) .frontend-text-diff-list {
  border-color: var(--text-panel-border);
  background: var(--text-panel-soft);
}

:global(:root[data-theme="dark"]) .frontend-text-result-panel,
:global(:root[data-theme="dark"]) .frontend-text-editor-panel.is-result {
  border-color: rgba(116, 167, 255, 0.24);
  background: #111827;
}

:global(:root[data-theme="dark"]) .frontend-text-field > span,
:global(:root[data-theme="dark"]) .frontend-text-editor-panel > span {
  background: rgba(238, 244, 255, 0.92);
  color: #0f172a;
}

:global(:root[data-theme="dark"]) .frontend-text-editor-panel.is-result > span {
  background: #74a7ff;
  color: #07101f;
}

:global(:root[data-theme="dark"]) .frontend-text-card :deep(.el-input__wrapper),
:global(:root[data-theme="dark"]) .frontend-text-card :deep(.el-textarea__inner) {
  background: #0b1220;
  color: var(--text-panel-ink);
  box-shadow: 0 0 0 1px rgba(255, 255, 255, 0.16) inset;
}

:global(:root[data-theme="dark"]) .frontend-text-card :deep(.el-input__inner) {
  color: var(--text-panel-ink);
}

:global(:root[data-theme="dark"]) .frontend-text-card :deep(.el-input__inner::placeholder),
:global(:root[data-theme="dark"]) .frontend-text-card :deep(.el-textarea__inner::placeholder) {
  color: #718096;
}

:global(:root[data-theme="dark"]) .frontend-text-card :deep(.el-textarea__inner:focus),
:global(:root[data-theme="dark"]) .frontend-text-card :deep(.el-input__wrapper.is-focus) {
  box-shadow: 0 0 0 1px rgba(116, 167, 255, 0.46) inset;
}

:global(:root[data-theme="dark"]) .frontend-text-code {
  background: #07101f;
  color: #d7ff8a;
}

:global(:root[data-theme="dark"]) .frontend-text-meta-grid {
  border-top-color: rgba(255, 255, 255, 0.1);
}

:global(:root[data-theme="dark"]) .frontend-text-meta-grid strong,
:global(:root[data-theme="dark"]) .frontend-text-kv-list strong,
:global(:root[data-theme="dark"]) .frontend-text-diff-list .frontend-diff-row code {
  color: var(--text-panel-ink);
}

:global(:root[data-theme="dark"]) .frontend-text-diff-list .frontend-diff-row {
  border-color: rgba(255, 255, 255, 0.08);
}

:global(:root[data-theme="dark"] .frontend-tools-page .frontend-text-card) {
  --text-panel-border: rgba(148, 163, 184, 0.22);
  --text-panel-soft: #0b1220;
  --text-panel-ink: #eef4ff;
  --text-panel-muted: #a9b7cc;
  --el-fill-color-blank: #07101f;
  --el-input-bg-color: #07101f;
  --el-input-text-color: #eef4ff;
  --el-text-color-regular: #eef4ff;
  --el-text-color-placeholder: #718096;
}

:global(:root[data-theme="dark"] .frontend-tools-page .frontend-text-card .frontend-text-param-table),
:global(:root[data-theme="dark"] .frontend-tools-page .frontend-text-card .frontend-text-editor-panel),
:global(:root[data-theme="dark"] .frontend-tools-page .frontend-text-card .frontend-text-kv-list),
:global(:root[data-theme="dark"] .frontend-tools-page .frontend-text-card .frontend-text-diff-list) {
  border-color: var(--text-panel-border) !important;
  background: #0b1220 !important;
  color: var(--text-panel-muted) !important;
}

:global(:root[data-theme="dark"] .frontend-tools-page .frontend-text-card .frontend-text-result-panel),
:global(:root[data-theme="dark"] .frontend-tools-page .frontend-text-card .frontend-text-editor-panel.is-result) {
  border-color: rgba(116, 167, 255, 0.28) !important;
  background: #111827 !important;
}

:global(:root[data-theme="dark"] .frontend-tools-page .frontend-text-card .frontend-text-field > span),
:global(:root[data-theme="dark"] .frontend-tools-page .frontend-text-card .frontend-text-editor-panel > span) {
  border: 1px solid rgba(116, 167, 255, 0.34) !important;
  background: rgba(116, 167, 255, 0.16) !important;
  color: #dbeafe !important;
}

:global(:root[data-theme="dark"] .frontend-tools-page .frontend-text-card .frontend-text-editor-panel.is-result > span) {
  border-color: transparent !important;
  background: #74a7ff !important;
  color: #07101f !important;
}

:global(:root[data-theme="dark"] .frontend-tools-page .frontend-text-card .el-input__wrapper),
:global(:root[data-theme="dark"] .frontend-tools-page .frontend-text-card .el-textarea__inner) {
  border-color: rgba(148, 163, 184, 0.2) !important;
  background: #07101f !important;
  background-color: #07101f !important;
  color: var(--text-panel-ink) !important;
  box-shadow: 0 0 0 1px rgba(148, 163, 184, 0.2) inset !important;
}

:global(:root[data-theme="dark"] .frontend-tools-page .frontend-text-card .el-input__inner),
:global(:root[data-theme="dark"] .frontend-tools-page .frontend-text-card .el-textarea__inner) {
  color: var(--text-panel-ink) !important;
  caret-color: #74a7ff;
}

:global(:root[data-theme="dark"] .frontend-tools-page .frontend-text-card .el-input__inner::placeholder),
:global(:root[data-theme="dark"] .frontend-tools-page .frontend-text-card .el-textarea__inner::placeholder) {
  color: #718096 !important;
}

:global(:root[data-theme="dark"] .frontend-tools-page .frontend-text-card .el-input__wrapper:hover),
:global(:root[data-theme="dark"] .frontend-tools-page .frontend-text-card .el-input__wrapper.is-focus),
:global(:root[data-theme="dark"] .frontend-tools-page .frontend-text-card .el-textarea__inner:hover),
:global(:root[data-theme="dark"] .frontend-tools-page .frontend-text-card .el-textarea__inner:focus) {
  box-shadow: 0 0 0 1px rgba(116, 167, 255, 0.46) inset !important;
}

:global(:root[data-theme="dark"] .frontend-tools-page .frontend-text-card .frontend-diff-row) {
  background: #07101f !important;
}

:global(:root[data-theme="dark"] .frontend-tools-page .frontend-text-card .frontend-diff-row.add) {
  background: rgba(46, 125, 86, 0.18) !important;
}

:global(:root[data-theme="dark"] .frontend-tools-page .frontend-text-card .frontend-diff-row.remove) {
  background: rgba(255, 104, 79, 0.18) !important;
}

@media (max-width: 1180px) {
  .frontend-text-span-8,
  .frontend-text-span-6,
  .frontend-text-span-4 {
    grid-column: span 12;
  }
}

@media (max-width: 760px) {
  .frontend-text-workbench,
  .frontend-text-url-layout,
  .frontend-text-regex-layout,
  .frontend-text-io-grid {
    grid-template-columns: 1fr;
  }

  .frontend-text-card .tool-panel-head {
    align-items: stretch;
  }

  .frontend-text-card .tool-actions .el-button {
    flex: 1 1 auto;
  }
}
</style>
