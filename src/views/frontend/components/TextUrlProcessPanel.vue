<template>
          <div class="frontend-tool-grid">
            <section class="frontend-tool-card">
              <div class="tool-panel-head">
                <h2>URL 参数解析</h2>
                <div class="tool-actions">
                  <el-button plain @click="parseUrlParams">解析</el-button>
                  <el-button plain @click="buildUrlFromParams">拼接</el-button>
                </div>
              </div>
              <el-input v-model="urlInput" placeholder="https://example.com?a=1&b=2" />
              <div class="frontend-param-list">
                <div v-for="item in urlParams" :key="item.id" class="frontend-param-row">
                  <el-input v-model="item.key" placeholder="key" />
                  <el-input v-model="item.value" placeholder="value" />
                </div>
              </div>
              <el-input v-model="urlOutput" type="textarea" :rows="3" resize="none" placeholder="拼接结果" />
            </section>

            <section class="frontend-tool-card">
              <div class="tool-panel-head">
                <h2>URL 编码 / 解码</h2>
                <div class="tool-actions">
                  <el-button plain @click="encodeUrlText">编码</el-button>
                  <el-button plain @click="decodeUrlText">解码</el-button>
                </div>
              </div>
              <el-input v-model="urlCodecInput" type="textarea" :rows="5" resize="none" placeholder="输入 URL 或参数文本" />
              <el-input v-model="urlCodecOutput" type="textarea" :rows="5" resize="none" placeholder="处理结果" />
            </section>

            <section class="frontend-tool-card">
              <div class="tool-panel-head">
                <h2>HTML 实体转义</h2>
                <div class="tool-actions">
                  <el-button plain @click="encodeHtmlEntities">转义</el-button>
                  <el-button plain @click="decodeHtmlEntities">反转义</el-button>
                </div>
              </div>
              <el-input v-model="htmlEntityInput" type="textarea" :rows="5" resize="none" placeholder="<div>hello</div>" />
              <el-input v-model="htmlEntityOutput" type="textarea" :rows="5" resize="none" placeholder="处理结果" />
            </section>

            <section class="frontend-tool-card">
              <div class="tool-panel-head">
                <h2>文本批处理</h2>
                <div class="tool-actions">
                  <el-button plain @click="removeEmptyLines">去空行</el-button>
                  <el-button plain @click="uniqueLines">去重复</el-button>
                  <el-button plain @click="sortLines">排序</el-button>
                </div>
              </div>
              <el-input v-model="batchTextInput" type="textarea" :rows="7" resize="none" placeholder="每行一条文本" />
              <div class="tool-actions">
                <el-button plain @click="trimLines">清理首尾空格</el-button>
                <el-button plain @click="upperCaseText">大写</el-button>
                <el-button plain @click="lowerCaseText">小写</el-button>
              </div>
              <el-input v-model="batchTextOutput" type="textarea" :rows="7" resize="none" placeholder="处理结果" />
            </section>

            <section class="frontend-tool-card frontend-tool-card-wide">
              <div class="tool-panel-head">
                <h2>文本差异对比</h2>
                <el-button plain @click="compareText">对比</el-button>
              </div>
              <div class="frontend-preview-grid">
                <el-input v-model="diffLeft" type="textarea" :rows="8" resize="none" placeholder="原文本" />
                <el-input v-model="diffRight" type="textarea" :rows="8" resize="none" placeholder="新文本" />
              </div>
              <div class="frontend-diff-list">
                <div v-for="item in diffRows" :key="item.id" :class="['frontend-diff-row', item.type]">
                  <span>{{ item.label }}</span>
                  <code>{{ item.text }}</code>
                </div>
              </div>
            </section>

            <section class="frontend-tool-card">
              <div class="tool-panel-head">
                <h2>正则匹配测试</h2>
                <div class="tool-actions">
                  <el-button plain @click="runRegex">匹配</el-button>
                  <el-button plain @click="replaceRegex">替换</el-button>
                </div>
              </div>
              <el-input v-model="regexPattern" placeholder="正则表达式，不需要 / /" />
              <div class="frontend-control-grid compact">
                <label>
                  flags
                  <el-input v-model="regexFlags" placeholder="gi" />
                </label>
                <label>
                  替换为
                  <el-input v-model="regexReplacement" placeholder="$1" />
                </label>
              </div>
              <el-input v-model="regexText" type="textarea" :rows="6" resize="none" placeholder="待匹配文本" />
              <pre class="frontend-code">{{ regexOutput }}</pre>
            </section>

            <section class="frontend-tool-card">
              <div class="tool-panel-head">
                <h2>浏览器 UA 解析</h2>
                <el-button plain @click="parseUserAgent">解析</el-button>
              </div>
              <el-input v-model="userAgentInput" type="textarea" :rows="5" resize="none" placeholder="粘贴 User-Agent" />
              <div class="frontend-kv-list">
                <span>浏览器</span><strong>{{ userAgentInfo.browser }}</strong>
                <span>系统</span><strong>{{ userAgentInfo.os }}</strong>
                <span>设备</span><strong>{{ userAgentInfo.device }}</strong>
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

function getActiveCopyText() {
  return batchTextOutput.value
}

defineExpose({
  getActiveCopyText
})
</script>
