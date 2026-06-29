<template>
          <div class="frontend-tool-grid">
            <section class="frontend-tool-card">
              <div class="tool-panel-head">
                <h2>JSON 路径提取</h2>
                <el-button plain @click="extractJsonPaths">提取</el-button>
              </div>
              <el-input v-model="jsonPathInput" type="textarea" :rows="9" resize="none" placeholder="粘贴 JSON" />
              <div class="frontend-path-list">
                <button
                  v-for="item in jsonPaths"
                  :key="item"
                  type="button"
                  @click="copyText(item)"
                >
                  {{ item }}
                </button>
              </div>
            </section>

            <section class="frontend-tool-card">
              <div class="tool-panel-head">
                <h2>CSV / JSON 互转</h2>
                <div class="tool-actions">
                  <el-button plain @click="csvToJson">CSV 转 JSON</el-button>
                  <el-button plain @click="jsonToCsv">JSON 转 CSV</el-button>
                </div>
              </div>
              <el-input v-model="csvJsonInput" type="textarea" :rows="8" resize="none" placeholder="CSV 或 JSON 数组" />
              <el-input v-model="csvJsonOutput" type="textarea" :rows="8" resize="none" placeholder="转换结果" />
            </section>

            <section class="frontend-tool-card">
              <div class="tool-panel-head">
                <h2>Mock 数据生成</h2>
                <div class="tool-actions">
                  <el-button plain @click="generateMockData">生成</el-button>
                  <el-button plain @click="copyText(mockOutput)">复制</el-button>
                </div>
              </div>
              <div class="frontend-control-grid compact">
                <label>
                  数量（条）
                  <el-input-number v-model="mockCount" :min="1" :max="200" controls-position="right" />
                </label>
                <label>
                  场景
                  <el-select v-model="mockScene">
                    <el-option label="用户列表" value="users" />
                    <el-option label="订单列表" value="orders" />
                    <el-option label="文章列表" value="articles" />
                  </el-select>
                </label>
              </div>
              <el-input v-model="mockOutput" type="textarea" :rows="12" resize="none" placeholder="生成结果" />
            </section>

            <section class="frontend-tool-card frontend-tool-card-wide">
              <div class="tool-panel-head">
                <h2>Markdown 预览</h2>
                <el-button plain @click="copyText(markdownHtml)">复制 HTML</el-button>
              </div>
              <div class="frontend-preview-grid">
                <el-input v-model="markdownInput" type="textarea" :rows="14" resize="none" placeholder="# 标题" />
                <article class="frontend-markdown-preview" v-html="markdownHtml"></article>
              </div>
            </section>
          </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import { ElMessage } from 'element-plus'

const jsonPathInput = ref('{"user":{"name":"snail","tags":["vue","tools"]}}')
const jsonPaths = ref([])
const csvJsonInput = ref('name,type\nsnail,tool\nvue,framework')
const csvJsonOutput = ref('')
const mockCount = ref(10)
const mockScene = ref('users')
const mockOutput = ref('')
const markdownInput = ref('# 前端工具\n\n- 图片处理\n- 文本处理\n\n**复制结果** 后即可使用。')

const markdownHtml = computed(() => {
  return renderMarkdown(markdownInput.value)
})

function extractJsonPaths() {
  try {
    const data = JSON.parse(jsonPathInput.value)
    const paths = []
    walkJsonPaths(data, '', paths)
    jsonPaths.value = paths
  } catch (error) {
    ElMessage.error(error.message)
  }
}

function walkJsonPaths(value, path, paths) {
  if (Array.isArray(value)) {
    value.forEach((item, index) => {
      const nextPath = `${path}[${index}]`
      paths.push(nextPath)
      walkJsonPaths(item, nextPath, paths)
    })
    return
  }

  if (value !== null && typeof value === 'object') {
    Object.keys(value).forEach((key) => {
      const nextPath = path.length > 0 ? `${path}.${key}` : key
      paths.push(nextPath)
      walkJsonPaths(value[key], nextPath, paths)
    })
  }
}

function csvToJson() {
  try {
    const rows = parseCsv(csvJsonInput.value)
    const headers = rows[0]
    const data = rows.slice(1).map((row) => {
      const item = {}
      headers.forEach((header, index) => {
        item[header] = row[index]
      })
      return item
    })
    csvJsonOutput.value = JSON.stringify(data, null, 2)
  } catch (error) {
    ElMessage.error(error.message)
  }
}

function jsonToCsv() {
  try {
    const data = JSON.parse(csvJsonInput.value)
    const headers = Object.keys(data[0])
    const rows = data.map((item) => headers.map((header) => csvCell(item[header])).join(','))
    csvJsonOutput.value = [headers.join(','), ...rows].join('\n')
  } catch (error) {
    ElMessage.error(error.message)
  }
}

function generateMockData() {
  const data = []
  for (let index = 0; index < mockCount.value; index += 1) {
    if (mockScene.value === 'users') {
      data.push(mockUser(index))
    }

    if (mockScene.value === 'orders') {
      data.push(mockOrder(index))
    }

    if (mockScene.value === 'articles') {
      data.push(mockArticle(index))
    }
  }
  mockOutput.value = JSON.stringify(data, null, 2)
}

function mockUser(index) {
  const names = ['林舟', '陈一诺', '周宁', '许然', '沈清', '顾南', '叶安', '赵川']
  const cities = ['上海', '杭州', '深圳', '成都', '南京', '广州', '北京', '苏州']
  return {
    id: index + 1,
    name: names[index % names.length],
    phone: `13${String(800000000 + index * 731).slice(0, 9)}`,
    email: `user${index + 1}@example.com`,
    city: cities[index % cities.length],
    status: index % 3 === 0 ? 'inactive' : 'active',
    createdAt: mockDate(index)
  }
}

function mockOrder(index) {
  const statuses = ['pending', 'paid', 'shipped', 'completed']
  return {
    id: `OD${String(index + 1).padStart(6, '0')}`,
    amount: Number((99 + index * 17.6).toFixed(2)),
    quantity: index % 5 + 1,
    status: statuses[index % statuses.length],
    buyer: `客户 ${index + 1}`,
    createdAt: mockDate(index)
  }
}

function mockArticle(index) {
  const categories = ['设计', '前端', '工具', '效率']
  return {
    id: index + 1,
    title: `示例文章 ${index + 1}`,
    category: categories[index % categories.length],
    author: `作者 ${index % 6 + 1}`,
    views: 120 + index * 37,
    published: index % 4 !== 0,
    createdAt: mockDate(index)
  }
}

function mockDate(index) {
  const date = new Date()
  date.setDate(date.getDate() - index)
  return date.toISOString().slice(0, 10)
}

function parseCsv(text) {
  const rows = []
  let row = []
  let cell = ''
  let quoted = false

  for (let index = 0; index < text.length; index += 1) {
    const char = text[index]
    const nextChar = text[index + 1]

    if (char === '"' && quoted && nextChar === '"') {
      cell += '"'
      index += 1
    } else if (char === '"') {
      quoted = !quoted
    } else if (char === ',' && !quoted) {
      row.push(cell)
      cell = ''
    } else if (char === '\n' && !quoted) {
      row.push(cell)
      rows.push(row)
      row = []
      cell = ''
    } else if (char !== '\r') {
      cell += char
    }
  }

  row.push(cell)
  rows.push(row)
  return rows
}

function csvCell(value) {
  const text = String(value)
  if (text.includes(',') || text.includes('"') || text.includes('\n')) {
    return `"${text.replace(/"/g, '""')}"`
  }

  return text
}

function renderMarkdown(text) {
  const lines = escapeHtml(text).split('\n')
  const html = []
  let listOpen = false

  lines.forEach((line) => {
    if (line.startsWith('- ')) {
      if (!listOpen) {
        html.push('<ul>')
        listOpen = true
      }
      html.push(`<li>${inlineMarkdown(line.slice(2))}</li>`)
      return
    }

    if (listOpen) {
      html.push('</ul>')
      listOpen = false
    }

    if (line.startsWith('### ')) {
      html.push(`<h3>${inlineMarkdown(line.slice(4))}</h3>`)
    } else if (line.startsWith('## ')) {
      html.push(`<h2>${inlineMarkdown(line.slice(3))}</h2>`)
    } else if (line.startsWith('# ')) {
      html.push(`<h1>${inlineMarkdown(line.slice(2))}</h1>`)
    } else if (line.length === 0) {
      html.push('<br>')
    } else {
      html.push(`<p>${inlineMarkdown(line)}</p>`)
    }
  })

  if (listOpen) {
    html.push('</ul>')
  }

  return html.join('')
}

function inlineMarkdown(text) {
  return text
    .replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')
    .replace(/`(.+?)`/g, '<code>$1</code>')
    .replace(/\[(.+?)\]\((.+?)\)/g, '<a href="$2" target="_blank" rel="noreferrer">$1</a>')
}

function escapeHtml(text) {
  return text
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;')
}

async function copyText(value) {
  if (value.length === 0) {
    ElMessage.warning('暂无可复制内容')
    return
  }

  await navigator.clipboard.writeText(value)
  ElMessage.success('已复制')
}

extractJsonPaths()
csvToJson()
generateMockData()

function getActiveCopyText() {
  return csvJsonOutput.value
}

defineExpose({
  getActiveCopyText
})
</script>
