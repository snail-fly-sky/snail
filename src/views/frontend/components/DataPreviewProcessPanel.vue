<template>
  <div class="frontend-data-workbench">
    <section class="frontend-tool-card frontend-data-card frontend-data-span-6">
      <div class="tool-panel-head">
        <h2>JSON 路径提取</h2>
        <div class="tool-actions frontend-panel-head-actions">
          <el-button type="primary" plain @click="extractJsonPaths">提取</el-button>
        </div>
      </div>
      <div class="frontend-data-split">
        <label class="frontend-data-editor-panel">
          <span>JSON</span>
          <el-input v-model="jsonPathInput" type="textarea" :rows="8" resize="none" placeholder="粘贴 JSON" />
        </label>
        <div class="frontend-data-result-panel">
          <div class="frontend-data-panel-head">
            <span>路径列表</span>
            <strong>{{ jsonPaths.length }} paths</strong>
          </div>
          <div class="frontend-path-list frontend-data-path-list">
            <button
              v-for="item in jsonPaths"
              :key="item"
              type="button"
              @click="copyText(item)"
            >
              {{ item }}
            </button>
          </div>
        </div>
      </div>
    </section>

    <section class="frontend-tool-card frontend-data-card frontend-data-span-6">
      <div class="tool-panel-head">
        <h2>CSV / JSON 互转</h2>
        <div class="tool-actions frontend-panel-head-actions">
          <el-button type="primary" plain @click="csvToJson">CSV 转 JSON</el-button>
          <el-button plain @click="jsonToCsv">JSON 转 CSV</el-button>
          <el-button plain @click="copyText(csvJsonOutput)">复制</el-button>
        </div>
      </div>
      <div class="frontend-data-io-grid">
        <label class="frontend-data-editor-panel">
          <span>输入</span>
          <el-input v-model="csvJsonInput" type="textarea" :rows="8" resize="none" placeholder="CSV 或 JSON 数组" />
        </label>
        <label class="frontend-data-editor-panel is-result">
          <span>结果</span>
          <el-input v-model="csvJsonOutput" type="textarea" :rows="8" resize="none" placeholder="转换结果" />
        </label>
      </div>
    </section>

    <section class="frontend-tool-card frontend-data-card frontend-data-span-5">
      <div class="tool-panel-head">
        <h2>Mock 数据生成</h2>
        <div class="tool-actions frontend-panel-head-actions">
          <el-button type="primary" plain @click="generateMockData">生成</el-button>
          <el-button plain @click="copyText(mockOutput)">复制</el-button>
        </div>
      </div>
      <div class="frontend-data-mock-layout">
        <div class="frontend-data-control-grid">
          <label class="frontend-data-field">
            <span>数量</span>
            <el-input-number v-model="mockCount" :min="1" :max="200" controls-position="right" />
          </label>
          <label class="frontend-data-field">
            <span>场景</span>
            <el-select v-model="mockScene" popper-class="frontend-data-select-popper">
              <el-option label="用户列表" value="users" />
              <el-option label="订单列表" value="orders" />
              <el-option label="文章列表" value="articles" />
            </el-select>
          </label>
        </div>
        <label class="frontend-data-editor-panel is-result">
          <span>生成结果</span>
          <el-input v-model="mockOutput" type="textarea" :rows="10" resize="none" placeholder="生成结果" />
        </label>
      </div>
    </section>

    <section class="frontend-tool-card frontend-data-card frontend-data-span-7">
      <div class="tool-panel-head">
        <h2>Markdown 预览</h2>
        <div class="tool-actions frontend-panel-head-actions">
          <el-button plain @click="copyText(markdownHtml)">复制 HTML</el-button>
        </div>
      </div>
      <div class="frontend-data-markdown-layout">
        <label class="frontend-data-editor-panel">
          <span>Markdown</span>
          <el-input v-model="markdownInput" type="textarea" :rows="12" resize="none" placeholder="# 标题" />
        </label>
        <article class="frontend-markdown-preview frontend-data-markdown-preview" v-html="markdownHtml"></article>
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

<style scoped>
.frontend-data-workbench {
  display: grid;
  grid-template-columns: repeat(12, minmax(0, 1fr));
  gap: 12px;
  align-items: stretch;
}

.frontend-data-card {
  --data-panel-border: #d7dee8;
  --data-panel-soft: #f7f9fc;
  --data-panel-ink: #15191f;
  --data-panel-muted: #5f6d7e;
  gap: 12px;
  padding: 12px;
  align-content: stretch;
}

.frontend-data-span-7 {
  grid-column: span 7;
}

.frontend-data-span-6 {
  grid-column: span 6;
}

.frontend-data-span-5 {
  grid-column: span 5;
}

.frontend-data-card .tool-panel-head {
  min-height: 36px;
}

.frontend-data-card .tool-panel-head h2 {
  font-size: 20px;
  line-height: 1.2;
}

.frontend-data-card .tool-actions {
  gap: 8px;
}

.frontend-data-card .tool-actions .el-button {
  min-height: 34px;
  padding: 0 14px;
}

.frontend-data-split,
.frontend-data-io-grid,
.frontend-data-markdown-layout {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 10px;
  min-width: 0;
  min-height: 0;
}

.frontend-data-split {
  grid-template-columns: minmax(0, 0.58fr) minmax(190px, 0.42fr);
}

.frontend-data-markdown-layout {
  grid-template-columns: minmax(0, 0.48fr) minmax(0, 0.52fr);
}

.frontend-data-mock-layout,
.frontend-data-control-grid {
  display: grid;
  gap: 10px;
  min-width: 0;
}

.frontend-data-control-grid {
  grid-template-columns: minmax(110px, 0.7fr) minmax(0, 1fr);
}

.frontend-data-editor-panel,
.frontend-data-result-panel,
.frontend-data-field {
  min-width: 0;
}

.frontend-data-card .frontend-data-editor-panel {
  position: relative;
  display: block;
  min-height: 238px;
  padding: 40px 10px 10px;
  border: 1px solid var(--data-panel-border);
  border-radius: 8px;
  background: var(--data-panel-soft);
}

.frontend-data-span-5 .frontend-data-editor-panel {
  min-height: 318px;
}

.frontend-data-markdown-layout .frontend-data-editor-panel,
.frontend-data-markdown-preview {
  min-height: 362px;
}

.frontend-data-editor-panel > span {
  position: absolute;
  top: 10px;
  left: 10px;
  z-index: 1;
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

.frontend-data-editor-panel.is-result {
  border-color: rgba(37, 87, 246, 0.22);
  background: #f8fbff;
}

.frontend-data-editor-panel.is-result > span {
  background: #2557f6;
}

.frontend-data-result-panel {
  display: grid;
  grid-template-rows: auto minmax(0, 1fr);
  gap: 9px;
  padding: 10px;
  border: 1px solid rgba(37, 87, 246, 0.18);
  border-radius: 8px;
  background: #ffffff;
}

.frontend-data-panel-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
  min-width: 0;
}

.frontend-data-panel-head span,
.frontend-data-panel-head strong {
  color: var(--data-panel-muted);
  font-size: 12px;
  font-weight: 950;
  line-height: 1;
}

.frontend-data-panel-head strong {
  color: var(--blue);
  white-space: nowrap;
}

.frontend-data-path-list {
  max-height: none;
  gap: 7px;
  overflow: auto;
}

.frontend-data-path-list button {
  border-color: rgba(37, 87, 246, 0.16);
  background: var(--data-panel-soft);
  color: var(--blue);
  font-family: "Cascadia Code", "Consolas", monospace;
  font-size: 12px;
  line-height: 1.35;
}

.frontend-data-path-list button:hover,
.frontend-data-path-list button:focus-visible {
  border-color: rgba(37, 87, 246, 0.34);
  background: rgba(37, 87, 246, 0.08);
  outline: none;
}

.frontend-data-card .frontend-data-field {
  display: grid;
  gap: 7px;
  color: var(--data-panel-muted);
  font-size: 12px;
  font-weight: 950;
}

.frontend-data-field > span {
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
}

.frontend-data-field :deep(.el-input-number),
.frontend-data-field :deep(.el-select) {
  width: 100%;
}

.frontend-data-markdown-preview {
  min-width: 0;
  overflow: auto;
  background: #ffffff;
}

.frontend-data-card :deep(.el-input__wrapper),
.frontend-data-card :deep(.el-textarea__inner) {
  box-shadow: 0 0 0 1px rgba(21, 25, 31, 0.12) inset;
}

.frontend-data-editor-panel :deep(.el-textarea) {
  display: block;
  height: 100%;
}

.frontend-data-card :deep(.el-textarea__inner) {
  height: 100%;
  min-height: 0 !important;
  font-family: "Cascadia Code", "Consolas", monospace;
  font-size: 13px;
  line-height: 1.5;
}

.frontend-data-card :deep(.el-textarea__inner:focus),
.frontend-data-card :deep(.el-input__wrapper.is-focus) {
  box-shadow: 0 0 0 1px rgba(37, 87, 246, 0.38) inset;
}

:global(:root[data-theme="dark"]) .frontend-data-card {
  --data-panel-border: rgba(255, 255, 255, 0.12);
  --data-panel-soft: #0f1724;
  --data-panel-ink: #eef4ff;
  --data-panel-muted: #b7c3d7;
}

:global(:root[data-theme="dark"]) .frontend-data-card .frontend-data-editor-panel,
:global(:root[data-theme="dark"]) .frontend-data-card .frontend-data-field {
  color: var(--data-panel-muted);
}

:global(:root[data-theme="dark"]) .frontend-data-card .frontend-data-editor-panel,
:global(:root[data-theme="dark"]) .frontend-data-result-panel {
  border-color: var(--data-panel-border);
  background: var(--data-panel-soft);
}

:global(:root[data-theme="dark"]) .frontend-data-result-panel,
:global(:root[data-theme="dark"]) .frontend-data-editor-panel.is-result,
:global(:root[data-theme="dark"]) .frontend-data-markdown-preview {
  border-color: rgba(116, 167, 255, 0.24);
  background: #111827;
}

:global(:root[data-theme="dark"]) .frontend-data-editor-panel > span,
:global(:root[data-theme="dark"]) .frontend-data-field > span {
  background: rgba(238, 244, 255, 0.92);
  color: #0f172a;
}

:global(:root[data-theme="dark"]) .frontend-data-editor-panel.is-result > span {
  background: #74a7ff;
  color: #07101f;
}

:global(:root[data-theme="dark"]) .frontend-data-path-list button {
  border-color: rgba(116, 167, 255, 0.22);
  background: #0b1220;
  color: #74a7ff;
}

:global(:root[data-theme="dark"]) .frontend-data-path-list button:hover,
:global(:root[data-theme="dark"]) .frontend-data-path-list button:focus-visible {
  border-color: rgba(116, 167, 255, 0.42);
  background: rgba(116, 167, 255, 0.12);
}

:global(:root[data-theme="dark"]) .frontend-data-card :deep(.el-input__wrapper),
:global(:root[data-theme="dark"]) .frontend-data-card :deep(.el-textarea__inner),
:global(:root[data-theme="dark"]) .frontend-data-card :deep(.el-select__wrapper) {
  background: #0b1220;
  color: var(--data-panel-ink);
  box-shadow: 0 0 0 1px rgba(255, 255, 255, 0.16) inset;
}

:global(:root[data-theme="dark"]) .frontend-data-card :deep(.el-input__inner),
:global(:root[data-theme="dark"]) .frontend-data-card :deep(.el-select__selected-item) {
  color: var(--data-panel-ink);
}

:global(:root[data-theme="dark"]) .frontend-data-card :deep(.el-input__inner::placeholder),
:global(:root[data-theme="dark"]) .frontend-data-card :deep(.el-textarea__inner::placeholder) {
  color: #718096;
}

:global(:root[data-theme="dark"]) .frontend-data-card :deep(.el-textarea__inner:focus),
:global(:root[data-theme="dark"]) .frontend-data-card :deep(.el-input__wrapper.is-focus),
:global(:root[data-theme="dark"]) .frontend-data-card :deep(.el-select__wrapper.is-focused) {
  box-shadow: 0 0 0 1px rgba(116, 167, 255, 0.46) inset;
}

:global(:root[data-theme="dark"]) .frontend-data-markdown-preview {
  color: var(--data-panel-ink);
}

:global(:root[data-theme="dark"]) .frontend-data-markdown-preview :deep(h1),
:global(:root[data-theme="dark"]) .frontend-data-markdown-preview :deep(h2),
:global(:root[data-theme="dark"]) .frontend-data-markdown-preview :deep(h3),
:global(:root[data-theme="dark"]) .frontend-data-markdown-preview :deep(strong) {
  color: var(--data-panel-ink);
}

:global(:root[data-theme="dark"]) .frontend-data-markdown-preview :deep(p),
:global(:root[data-theme="dark"]) .frontend-data-markdown-preview :deep(li) {
  color: var(--data-panel-muted);
}

:global(:root[data-theme="dark"]) .frontend-data-markdown-preview :deep(code) {
  background: rgba(116, 167, 255, 0.14);
  color: #74a7ff;
}

:global(:root[data-theme="dark"]) .frontend-data-markdown-preview :deep(a) {
  color: #74a7ff;
}

:global(:root[data-theme="dark"] .frontend-data-select-popper) {
  border-color: rgba(255, 255, 255, 0.12);
  background: #111827;
}

:global(:root[data-theme="dark"] .frontend-data-select-popper .el-select-dropdown__item) {
  color: #b7c3d7;
}

:global(:root[data-theme="dark"] .frontend-data-select-popper .el-select-dropdown__item.is-hovering),
:global(:root[data-theme="dark"] .frontend-data-select-popper .el-select-dropdown__item:hover) {
  background: rgba(116, 167, 255, 0.12);
  color: #eef4ff;
}

:global(:root[data-theme="dark"] .frontend-data-select-popper .el-select-dropdown__item.is-selected) {
  color: #74a7ff;
}

:global(:root[data-theme="dark"] .frontend-data-select-popper .el-popper__arrow::before) {
  border-color: rgba(255, 255, 255, 0.12);
  background: #111827;
}

:global(:root[data-theme="dark"] .frontend-tools-page .frontend-data-card) {
  --data-panel-border: rgba(148, 163, 184, 0.22);
  --data-panel-soft: #0b1220;
  --data-panel-ink: #eef4ff;
  --data-panel-muted: #a9b7cc;
  --el-fill-color-blank: #07101f;
  --el-input-bg-color: #07101f;
  --el-input-text-color: #eef4ff;
  --el-text-color-regular: #eef4ff;
  --el-text-color-placeholder: #718096;
}

:global(:root[data-theme="dark"] .frontend-tools-page .frontend-data-card .frontend-data-editor-panel),
:global(:root[data-theme="dark"] .frontend-tools-page .frontend-data-card .frontend-data-result-panel) {
  border-color: var(--data-panel-border) !important;
  background: #0b1220 !important;
  color: var(--data-panel-muted) !important;
}

:global(:root[data-theme="dark"] .frontend-tools-page .frontend-data-card .frontend-data-editor-panel.is-result),
:global(:root[data-theme="dark"] .frontend-tools-page .frontend-data-card .frontend-data-markdown-preview) {
  border-color: rgba(116, 167, 255, 0.28) !important;
  background: #111827 !important;
  color: var(--data-panel-ink) !important;
}

:global(:root[data-theme="dark"] .frontend-tools-page .frontend-data-card .frontend-data-editor-panel > span),
:global(:root[data-theme="dark"] .frontend-tools-page .frontend-data-card .frontend-data-field > span) {
  border: 1px solid rgba(116, 167, 255, 0.34) !important;
  background: rgba(116, 167, 255, 0.16) !important;
  color: #dbeafe !important;
}

:global(:root[data-theme="dark"] .frontend-tools-page .frontend-data-card .frontend-data-editor-panel.is-result > span) {
  border-color: transparent !important;
  background: #74a7ff !important;
  color: #07101f !important;
}

:global(:root[data-theme="dark"] .frontend-tools-page .frontend-data-card .el-input__wrapper),
:global(:root[data-theme="dark"] .frontend-tools-page .frontend-data-card .el-textarea__inner),
:global(:root[data-theme="dark"] .frontend-tools-page .frontend-data-card .el-select__wrapper) {
  border-color: rgba(148, 163, 184, 0.2) !important;
  background: #07101f !important;
  background-color: #07101f !important;
  color: var(--data-panel-ink) !important;
  box-shadow: 0 0 0 1px rgba(148, 163, 184, 0.2) inset !important;
}

:global(:root[data-theme="dark"] .frontend-tools-page .frontend-data-card .el-input__inner),
:global(:root[data-theme="dark"] .frontend-tools-page .frontend-data-card .el-textarea__inner),
:global(:root[data-theme="dark"] .frontend-tools-page .frontend-data-card .el-select__selected-item) {
  color: var(--data-panel-ink) !important;
  caret-color: #74a7ff;
}

:global(:root[data-theme="dark"] .frontend-tools-page .frontend-data-card .el-input__inner::placeholder),
:global(:root[data-theme="dark"] .frontend-tools-page .frontend-data-card .el-textarea__inner::placeholder) {
  color: #718096 !important;
}

:global(:root[data-theme="dark"] .frontend-tools-page .frontend-data-card .el-input__wrapper:hover),
:global(:root[data-theme="dark"] .frontend-tools-page .frontend-data-card .el-input__wrapper.is-focus),
:global(:root[data-theme="dark"] .frontend-tools-page .frontend-data-card .el-textarea__inner:hover),
:global(:root[data-theme="dark"] .frontend-tools-page .frontend-data-card .el-textarea__inner:focus),
:global(:root[data-theme="dark"] .frontend-tools-page .frontend-data-card .el-select__wrapper:hover),
:global(:root[data-theme="dark"] .frontend-tools-page .frontend-data-card .el-select__wrapper.is-focused) {
  box-shadow: 0 0 0 1px rgba(116, 167, 255, 0.46) inset !important;
}

:global(:root[data-theme="dark"] .frontend-tools-page .frontend-data-card .frontend-data-path-list button) {
  border-color: rgba(116, 167, 255, 0.24) !important;
  background: #07101f !important;
  color: #93c5fd !important;
}

:global(:root[data-theme="dark"] .frontend-tools-page .frontend-data-card .frontend-data-path-list button:hover),
:global(:root[data-theme="dark"] .frontend-tools-page .frontend-data-card .frontend-data-path-list button:focus-visible) {
  border-color: rgba(116, 167, 255, 0.48) !important;
  background: rgba(116, 167, 255, 0.12) !important;
}

:global(:root[data-theme="dark"] .frontend-tools-page .frontend-data-card .frontend-data-markdown-preview h1),
:global(:root[data-theme="dark"] .frontend-tools-page .frontend-data-card .frontend-data-markdown-preview h2),
:global(:root[data-theme="dark"] .frontend-tools-page .frontend-data-card .frontend-data-markdown-preview h3),
:global(:root[data-theme="dark"] .frontend-tools-page .frontend-data-card .frontend-data-markdown-preview strong) {
  color: var(--data-panel-ink) !important;
}

:global(:root[data-theme="dark"] .frontend-tools-page .frontend-data-card .frontend-data-markdown-preview p),
:global(:root[data-theme="dark"] .frontend-tools-page .frontend-data-card .frontend-data-markdown-preview li) {
  color: var(--data-panel-muted) !important;
}

:global(:root[data-theme="dark"] .frontend-tools-page .frontend-data-card .frontend-data-markdown-preview code) {
  background: rgba(116, 167, 255, 0.14) !important;
  color: #93c5fd !important;
}

:global(:root[data-theme="dark"] .frontend-tools-page .frontend-data-card .frontend-data-markdown-preview a) {
  color: #93c5fd !important;
}

@media (max-width: 1180px) {
  .frontend-data-span-7,
  .frontend-data-span-6,
  .frontend-data-span-5 {
    grid-column: span 12;
  }
}

@media (max-width: 760px) {
  .frontend-data-workbench,
  .frontend-data-split,
  .frontend-data-io-grid,
  .frontend-data-markdown-layout,
  .frontend-data-control-grid {
    grid-template-columns: 1fr;
  }

  .frontend-data-card .tool-panel-head {
    align-items: stretch;
  }

  .frontend-data-card .tool-actions .el-button {
    flex: 1 1 auto;
  }
}
</style>
