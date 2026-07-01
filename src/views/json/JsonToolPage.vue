<template>
  <main class="tool-page json-tool-page" @click="hideTreeMenu">
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
      <div class="tool-panel json-editor-panel">
        <div class="tool-panel-head">
          <h2>输入</h2>
        </div>
        <el-input
          v-model="jsonInput"
          class="tool-textarea"
          type="textarea"
          :rows="10"
          resize="none"
          placeholder="粘贴 JSON 内容"
        />
        <div class="json-status-card" :class="`is-${jsonStatus}`">
          <div>
            <span>{{ jsonStatusLabel }}</span>
            <strong>{{ jsonStatusText }}</strong>
          </div>
          <small v-if="jsonError.length > 0">{{ jsonError }}</small>
          <small v-else>{{ jsonMetaText }}</small>
        </div>
      </div>

      <div class="tool-panel json-editor-panel">
        <div class="tool-panel-head">
          <h2>输出</h2>
          <div class="tool-actions json-output-actions">
            <el-button class="json-action-button is-info" type="info" @click="loadSample">示例</el-button>
            <el-button class="json-action-button is-danger" type="danger" @click="clearJson">清空</el-button>
            <el-button class="json-action-button is-success" type="success" @click="validateJson">校验</el-button>
            <el-button class="json-action-button is-primary" type="primary" @click="beautifyJson">
              <Braces :size="18" />
              美化
            </el-button>
            <el-button class="json-action-button is-warning" type="warning" @click="minifyJson">压缩</el-button>
            <el-button class="json-action-button is-success" type="success" @click="copyOutput">复制</el-button>
          </div>
        </div>
        <el-input
          v-model="jsonOutput"
          class="tool-textarea"
          type="textarea"
          :rows="10"
          resize="none"
          placeholder="处理结果会显示在这里"
        />
      </div>

      <div class="tool-panel json-tree-panel">
        <div class="tool-panel-head">
          <h2>树形预览</h2>
          <div class="tool-actions">
            <el-button plain @click="expandTree">展开</el-button>
            <el-button plain @click="collapseTree">收起</el-button>
          </div>
        </div>
        <div v-if="treeLines.length > 0" class="json-code-tree">
          <div
            v-for="line in treeLines"
            :key="line.id"
            class="json-code-line"
            :class="{ 'is-close': line.closeLine }"
            :style="{ '--indent': line.indent }"
            @contextmenu.prevent.stop="openTreeMenu($event, line)"
          >
            <span class="json-line-number">{{ line.lineNumber }}</span>
            <span class="json-code-indent">
              <button
                v-if="line.expandable"
                class="json-fold-toggle"
                type="button"
                @click.stop="toggleTreeLine(line)"
              >
                <el-icon :size="12">
                  <CaretRight v-if="line.collapsed" />
                  <CaretBottom v-else />
                </el-icon>
              </button>
              <span v-else class="json-fold-spacer"></span>
              <span class="json-code-text"><span v-for="segment in line.segments" :key="segment.id" :class="segment.className">{{ segment.text }}</span></span>
            </span>
          </div>
        </div>
        <el-empty
          v-else
          class="json-empty-state"
          description="校验 JSON 后显示树形结构"
        />
      </div>
    </section>

    <div
      v-if="treeMenu.visible"
      class="json-tree-menu"
      :style="{ left: `${treeMenu.x}px`, top: `${treeMenu.y}px` }"
      @click.stop
    >
      <button type="button" @click="copyTreeMenuObject">复制对象</button>
      <button type="button" @click="copyTreeMenuJson">复制 JSON</button>
    </div>

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
import { computed, ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { CaretBottom, CaretRight } from '@element-plus/icons-vue'
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
const jsonStatus = ref('idle')
const jsonMeta = ref({
  line: 0,
  column: 0,
  position: 0
})
const treeData = ref([])
const collapsedTreePaths = ref(new Set())
const treeMenu = ref({
  visible: false,
  x: 0,
  y: 0,
  node: null
})

const jsonStatusLabel = computed(() => {
  if (jsonStatus.value === 'valid') {
    return '校验通过'
  }

  if (jsonStatus.value === 'error') {
    return '格式错误'
  }

  return '等待校验'
})

const jsonStatusText = computed(() => {
  if (jsonStatus.value === 'valid') {
    return 'JSON 格式有效'
  }

  if (jsonStatus.value === 'error') {
    return `第 ${jsonMeta.value.line} 行，第 ${jsonMeta.value.column} 列`
  }

  return '粘贴或编辑 JSON 后点击校验'
})

const jsonMetaText = computed(() => {
  if (jsonStatus.value === 'valid') {
    return `字符数 ${jsonInput.value.length}，树节点 ${countTreeNodes(treeData.value)}`
  }

  return '支持美化、压缩和树形预览'
})

const treeLines = computed(() => {
  return createJsonCodeLines(treeData.value)
})

watch(jsonInput, () => {
  validateJsonInputChange()
})

function transformJson(space) {
  try {
    const parsed = parseJsonInput()
    jsonOutput.value = JSON.stringify(parsed, null, space)
    syncJsonTools(parsed)
  } catch (error) {
    jsonOutput.value = ''
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
  await copyText(jsonOutput.value, '已复制结果')
}

async function copyText(value, message) {
  await navigator.clipboard.writeText(value)
  ElMessage.success(message)
}

function loadSample() {
  jsonInput.value = sampleJson
  jsonOutput.value = ''
  jsonError.value = ''
  const parsed = parseJsonInput()
  syncJsonTools(parsed)
}

function clearJson() {
  jsonInput.value = ''
  jsonOutput.value = ''
  jsonError.value = ''
  jsonStatus.value = 'idle'
  jsonMeta.value = {
    line: 0,
    column: 0,
    position: 0
  }
  treeData.value = []
  collapsedTreePaths.value = new Set()
}

function goHome() {
  router.push('/')
}

function validateJson() {
  try {
    const parsed = parseJsonInput()
    syncJsonTools(parsed)
    ElMessage.success('JSON 格式有效')
  } catch (error) {
    treeData.value = []
    collapsedTreePaths.value = new Set()
  }
}

function expandTree() {
  collapsedTreePaths.value = new Set()
}

function collapseTree() {
  const paths = new Set()
  collectCollapsibleTreePaths(treeData.value, paths)
  collapsedTreePaths.value = paths
}

function toggleTreeLine(line) {
  const paths = new Set(collapsedTreePaths.value)

  if (paths.has(line.path)) {
    paths.delete(line.path)
    collapsedTreePaths.value = paths
    return
  }

  paths.add(line.path)
  collapsedTreePaths.value = paths
}

function openTreeMenu(event, node) {
  treeMenu.value = {
    visible: true,
    x: event.clientX,
    y: event.clientY,
    node
  }
}

function hideTreeMenu() {
  treeMenu.value.visible = false
}

async function copyTreeMenuObject() {
  const value = stringifyTreeObject(treeMenu.value.node.rawValue)
  await copyText(value, '已复制对象')
  hideTreeMenu()
}

async function copyTreeMenuJson() {
  const value = stringifyTreeJson(treeMenu.value.node.rawValue)
  await copyText(value, '已复制 JSON')
  hideTreeMenu()
}

function stringifyTreeJson(value) {
  return JSON.stringify(value, null, 2)
}

function stringifyTreeObject(value) {
  const kind = getJsonKind(value)

  if (kind === 'array') {
    return `[${value.map((item) => stringifyTreeObject(item)).join(', ')}]`
  }

  if (kind === 'object') {
    const entries = Object.entries(value).map(([key, itemValue]) => {
      return `${formatObjectKey(key)}: ${stringifyTreeObject(itemValue)}`
    })
    return `{ ${entries.join(', ')} }`
  }

  return formatPrimitiveValue(value)
}

function validateJsonInputChange() {
  if (jsonInput.value.length === 0) {
    jsonError.value = ''
    jsonStatus.value = 'idle'
    jsonMeta.value = {
      line: 0,
      column: 0,
      position: 0
    }
    treeData.value = []
    collapsedTreePaths.value = new Set()
    return
  }

  try {
    const parsed = parseJsonInput()
    syncJsonTools(parsed)
  } catch (error) {
    treeData.value = []
    collapsedTreePaths.value = new Set()
  }
}

function formatObjectKey(key) {
  if (/^[A-Za-z_$][\w$]*$/.test(key)) {
    return key
  }

  return JSON.stringify(key)
}

function parseJsonInput() {
  try {
    const parsed = JSON.parse(jsonInput.value)
    jsonError.value = ''
    jsonStatus.value = 'valid'
    jsonMeta.value = {
      line: 0,
      column: 0,
      position: 0
    }
    return parsed
  } catch (error) {
    setJsonParseError(error)
    throw error
  }
}

function setJsonParseError(error) {
  const message = error.message
  const match = message.match(/position (\d+)/i)

  if (match) {
    const position = Number(match[1])
    const location = getLineColumn(jsonInput.value, position)
    jsonMeta.value = {
      line: location.line,
      column: location.column,
      position
    }
    jsonError.value = `JSON 格式错误：第 ${location.line} 行，第 ${location.column} 列（${message}）`
    jsonStatus.value = 'error'
    return
  }

  jsonMeta.value = {
    line: 1,
    column: 1,
    position: 0
  }
  jsonError.value = `JSON 格式错误：${message}`
  jsonStatus.value = 'error'
}

function getLineColumn(text, position) {
  const beforeError = text.slice(0, position)
  const lines = beforeError.split('\n')
  const line = lines.length
  const column = lines[lines.length - 1].length + 1
  return {
    line,
    column
  }
}

function syncJsonTools(parsed) {
  syncJsonTree(parsed)
}

function syncJsonTree(parsed) {
  treeData.value = [createTreeNode('root', parsed, '$', true)]
  collapsedTreePaths.value = new Set()
}

function createTreeNode(key, value, path, isRoot = false, parentKind = '') {
  const kind = getJsonKind(value)
  const node = {
    key,
    isRoot,
    kind,
    parentKind,
    path,
    rawValue: value,
    children: []
  }

  if (kind === 'array') {
    node.children = value.map((item, index) => {
      return createTreeNode(String(index), item, `${path}[${index}]`, false, 'array')
    })
  }

  if (kind === 'object') {
    node.children = Object.entries(value).map(([itemKey, itemValue]) => {
      return createTreeNode(itemKey, itemValue, `${path}.${itemKey}`, false, 'object')
    })
  }

  return node
}

function createJsonCodeLines(nodes) {
  const lines = []

  nodes.forEach((node, index) => {
    appendJsonCodeNode(lines, node, 0, index === nodes.length - 1)
  })

  return lines.map((line, index) => {
    return {
      ...line,
      indent: `${line.depth * 18}px`,
      lineNumber: index + 1
    }
  })
}

function appendJsonCodeNode(lines, node, depth, isLast) {
  const hasComma = !isLast

  if (isJsonContainer(node.kind)) {
    appendJsonContainerLine(lines, node, depth, hasComma)
    return
  }

  lines.push({
    id: `${node.path}:value`,
    path: node.path,
    rawValue: node.rawValue,
    depth,
    segments: createJsonLineSegments(node, [
      createJsonValueSegment(formatPrimitiveValue(node.rawValue), node.kind),
      createJsonPunctuationSegment(createTrailingComma(hasComma), 'comma')
    ]),
    expandable: false,
    collapsed: false,
    closeLine: false
  })
}

function appendJsonContainerLine(lines, node, depth, hasComma) {
  const collapsed = collapsedTreePaths.value.has(node.path)
  const openToken = createOpenToken(node.kind)
  const closeToken = createCloseToken(node.kind)

  if (node.children.length === 0) {
    lines.push({
      id: `${node.path}:empty`,
      path: node.path,
      rawValue: node.rawValue,
      depth,
      segments: createJsonLineSegments(node, [
        createJsonPunctuationSegment(`${openToken}${closeToken}`, 'empty'),
        createJsonPunctuationSegment(createTrailingComma(hasComma), 'comma')
      ]),
      expandable: false,
      collapsed: false,
      closeLine: false
    })
    return
  }

  if (collapsed) {
    lines.push({
      id: `${node.path}:collapsed`,
      path: node.path,
      rawValue: node.rawValue,
      depth,
      segments: createJsonLineSegments(node, [
        createJsonPunctuationSegment(`${openToken} `, 'open'),
        createJsonPunctuationSegment('... ', 'ellipsis'),
        createJsonPunctuationSegment(closeToken, 'close'),
        createJsonPunctuationSegment(createTrailingComma(hasComma), 'comma')
      ]),
      expandable: true,
      collapsed: true,
      closeLine: false
    })
    return
  }

  lines.push({
    id: `${node.path}:open`,
    path: node.path,
    rawValue: node.rawValue,
    depth,
    segments: createJsonLineSegments(node, [
      createJsonPunctuationSegment(openToken, 'open')
    ]),
    expandable: true,
    collapsed: false,
    closeLine: false
  })

  node.children.forEach((childNode, index) => {
    appendJsonCodeNode(lines, childNode, depth + 1, index === node.children.length - 1)
  })

  lines.push({
    id: `${node.path}:close`,
    path: node.path,
    rawValue: node.rawValue,
    depth,
    segments: [
      createJsonPunctuationSegment(closeToken, 'close'),
      createJsonPunctuationSegment(createTrailingComma(hasComma), 'comma')
    ],
    expandable: false,
    collapsed: false,
    closeLine: true
  })
}

function createJsonLineSegments(node, valueSegments) {
  const segments = []

  if (node.isRoot) {
    return valueSegments
  }

  if (node.parentKind === 'array') {
    return valueSegments
  }

  segments.push({
    id: 'key',
    text: node.key,
    className: 'json-token json-token-key'
  })
  segments.push(createJsonPunctuationSegment(': ', 'colon'))
  valueSegments.forEach((segment) => {
    segments.push(segment)
  })
  return segments
}

function createJsonValueSegment(text, kind) {
  return {
    id: 'value',
    text,
    className: `json-token json-token-${kind}`
  }
}

function createJsonPunctuationSegment(text, id) {
  return {
    id,
    text,
    className: 'json-token json-token-punctuation'
  }
}

function createOpenToken(kind) {
  if (kind === 'array') {
    return '['
  }

  return '{'
}

function createCloseToken(kind) {
  if (kind === 'array') {
    return ']'
  }

  return '}'
}

function createTrailingComma(hasComma) {
  if (hasComma) {
    return ','
  }

  return ''
}

function isJsonContainer(kind) {
  return kind === 'array' || kind === 'object'
}

function collectCollapsibleTreePaths(nodes, paths) {
  nodes.forEach((node) => {
    if (isJsonContainer(node.kind) && node.children.length > 0) {
      paths.add(node.path)
    }

    collectCollapsibleTreePaths(node.children, paths)
  })
}

function formatPrimitiveValue(value) {
  if (typeof value === 'string') {
    return JSON.stringify(value)
  }

  if (value === null) {
    return 'null'
  }

  return String(value)
}

function getJsonKind(value) {
  if (Array.isArray(value)) {
    return 'array'
  }

  if (value === null) {
    return 'null'
  }

  return typeof value
}

function countTreeNodes(nodes) {
  let total = 0
  nodes.forEach((node) => {
    total += 1
    total += countTreeNodes(node.children)
  })
  return total
}

syncJsonTools(JSON.parse(sampleJson))
</script>

<style scoped>
.json-tool-page {
  --json-glass-bg: rgba(255, 255, 255, 0.74);
  --json-glass-border: rgba(120, 138, 168, 0.22);
  --json-soft-bg: rgba(255, 255, 255, 0.5);
  --json-code-bg: rgba(248, 251, 255, 0.68);
  display: grid;
  grid-template-rows: auto minmax(0, 1fr) auto;
  gap: 10px;
  overflow: hidden;
}

.json-tool-page :deep(.tool-header),
.json-tool-page :deep(.tool-panel) {
  border-color: var(--json-glass-border);
  background: var(--json-glass-bg);
  box-shadow: 0 18px 54px rgba(44, 55, 67, 0.1);
  backdrop-filter: blur(18px);
}

.json-tool-page :deep(.tool-header) {
  padding: 10px 12px;
}

.json-tool-page :deep(.tool-panel) {
  gap: 8px;
  padding: 10px;
}

.json-tool-page :deep(.tool-panel-head) {
  gap: 8px;
  min-height: 30px;
}

.json-tool-page :deep(.tool-panel-head h2) {
  font-size: 16px;
}

.json-tool-page :deep(.tool-actions) {
  gap: 6px;
  flex-wrap: wrap;
  justify-content: flex-end;
}

.json-tool-page :deep(.tool-actions .el-button) {
  height: 28px;
  min-height: 28px;
  padding: 0 9px;
  font-size: 12px;
  margin-left: 0;
}

.json-output-actions :deep(.el-button) {
  border-width: 1px;
  border-style: solid;
  font-weight: 950;
  box-shadow: 0 7px 16px rgba(31, 41, 55, 0.08);
}

.json-output-actions :deep(.json-action-button span),
.json-output-actions :deep(.json-action-button .el-icon) {
  color: inherit !important;
}

.json-output-actions :deep(.json-action-button.is-info) {
  --el-button-bg-color: #e2e8f0;
  --el-button-border-color: #cbd5e1;
  --el-button-hover-bg-color: #cbd5e1;
  --el-button-hover-border-color: #94a3b8;
  background: #e2e8f0 !important;
  border-color: #cbd5e1 !important;
  color: #334155 !important;
}

.json-output-actions :deep(.json-action-button.is-danger) {
  --el-button-bg-color: #fee2e2;
  --el-button-border-color: #fecaca;
  --el-button-hover-bg-color: #fecaca;
  --el-button-hover-border-color: #f87171;
  background: #fee2e2 !important;
  border-color: #fecaca !important;
  color: #b91c1c !important;
}

.json-output-actions :deep(.json-action-button.is-success) {
  --el-button-bg-color: #d1fae5;
  --el-button-border-color: #a7f3d0;
  --el-button-hover-bg-color: #a7f3d0;
  --el-button-hover-border-color: #34d399;
  background: #d1fae5 !important;
  border-color: #a7f3d0 !important;
  color: #047857 !important;
}

.json-output-actions :deep(.json-action-button.is-primary) {
  --el-button-bg-color: #dbeafe;
  --el-button-border-color: #bfdbfe;
  --el-button-hover-bg-color: #bfdbfe;
  --el-button-hover-border-color: #60a5fa;
  background: #dbeafe !important;
  border-color: #bfdbfe !important;
  color: #1d4ed8 !important;
}

.json-output-actions :deep(.json-action-button.is-warning) {
  --el-button-bg-color: #ffedd5;
  --el-button-border-color: #fed7aa;
  --el-button-hover-bg-color: #fed7aa;
  --el-button-hover-border-color: #fb923c;
  background: #ffedd5 !important;
  border-color: #fed7aa !important;
  color: #c2410c !important;
}

.json-output-actions :deep(.json-action-button.is-info:hover),
.json-output-actions :deep(.json-action-button.is-info:focus-visible) {
  background: #cbd5e1 !important;
  border-color: #94a3b8 !important;
  color: #1e293b !important;
}

.json-output-actions :deep(.json-action-button.is-danger:hover),
.json-output-actions :deep(.json-action-button.is-danger:focus-visible) {
  background: #fecaca !important;
  border-color: #f87171 !important;
  color: #991b1b !important;
}

.json-output-actions :deep(.json-action-button.is-success:hover),
.json-output-actions :deep(.json-action-button.is-success:focus-visible) {
  background: #a7f3d0 !important;
  border-color: #34d399 !important;
  color: #065f46 !important;
}

.json-output-actions :deep(.json-action-button.is-primary:hover),
.json-output-actions :deep(.json-action-button.is-primary:focus-visible) {
  background: #bfdbfe !important;
  border-color: #60a5fa !important;
  color: #1e40af !important;
}

.json-output-actions :deep(.json-action-button.is-warning:hover),
.json-output-actions :deep(.json-action-button.is-warning:focus-visible) {
  background: #fed7aa !important;
  border-color: #fb923c !important;
  color: #9a3412 !important;
}

.json-output-actions :deep(.el-button:hover),
.json-output-actions :deep(.el-button:focus-visible) {
  opacity: 1;
}

.json-tool-grid {
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 10px;
  align-items: stretch;
  min-height: 0;
  height: 100%;
}

.json-editor-panel {
  grid-template-rows: auto minmax(0, 1fr) auto;
  align-content: stretch;
  min-height: 0;
}

.json-tool-page :deep(.json-editor-panel),
.json-tool-page :deep(.json-tree-panel) {
  height: 100%;
}

.json-tool-page :deep(.tool-textarea textarea) {
  min-height: 0;
}

.json-editor-panel :deep(.tool-textarea textarea) {
  height: 100%;
}

.json-editor-panel :deep(.tool-textarea),
.json-editor-panel :deep(.el-textarea) {
  min-height: 0;
  height: 100%;
}

.json-editor-panel :deep(.el-textarea__inner) {
  border-color: rgba(120, 138, 168, 0.22);
  background: var(--json-code-bg);
  font-family: "SFMono-Regular", "SF Mono", Menlo, Monaco, Consolas, monospace;
  font-size: 12px;
  line-height: 1.45;
  box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.42);
}

.json-status-card {
  display: grid;
  gap: 4px;
  max-height: 58px;
  overflow: auto;
  padding: 7px 8px;
  border: 1px solid rgba(120, 138, 168, 0.2);
  border-radius: 8px;
  background: var(--json-soft-bg);
}

.json-status-card div {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
}

.json-status-card span {
  color: var(--muted);
  font-size: 11px;
  font-weight: 900;
}

.json-status-card strong {
  color: var(--ink);
  font-size: 12px;
  font-weight: 950;
  text-align: right;
}

.json-status-card small {
  color: var(--muted);
  font-size: 11px;
  font-weight: 800;
  line-height: 1.35;
}

.json-status-card.is-valid {
  border-color: rgba(16, 185, 129, 0.28);
  background: rgba(236, 253, 245, 0.66);
}

.json-status-card.is-error {
  border-color: rgba(239, 68, 68, 0.28);
  background: rgba(254, 242, 242, 0.72);
}

.json-status-card.is-error strong,
.json-status-card.is-error small {
  color: #b42318;
}

.json-tree-panel {
  min-width: 0;
  min-height: 0;
}

.json-tree-panel {
  grid-template-rows: auto minmax(0, 1fr);
  align-content: stretch;
}

.json-code-tree {
  height: 100%;
  max-height: none;
  overflow: auto;
  padding: 8px 0;
  border: 1px solid rgba(120, 138, 168, 0.18);
  border-radius: 8px;
  background: var(--json-soft-bg);
  font-family: "SFMono-Regular", "SF Mono", Menlo, Monaco, Consolas, monospace;
  font-size: 12px;
  line-height: 1.55;
}

.json-code-line {
  width: max-content;
  min-width: 100%;
  min-height: 22px;
  display: grid;
  grid-template-columns: 42px max-content;
  align-items: center;
  padding-right: 12px;
  cursor: default;
}

.json-code-line:hover {
  background: rgba(37, 87, 246, 0.08);
}

.json-line-number {
  position: sticky;
  left: 0;
  z-index: 1;
  height: 100%;
  display: grid;
  place-items: center end;
  padding-right: 10px;
  background: rgba(248, 251, 255, 0.68);
  color: var(--muted);
  font-size: 11px;
  font-weight: 800;
  user-select: none;
}

.json-code-indent {
  display: inline-flex;
  align-items: center;
  padding-left: calc(var(--indent) + 8px);
}

.json-fold-toggle,
.json-fold-spacer {
  width: 18px;
  height: 20px;
  flex: 0 0 18px;
  margin-right: 3px;
}

.json-fold-toggle {
  display: grid;
  place-items: center;
  border: 0;
  border-radius: 4px;
  background: transparent;
  color: var(--ink);
  font-size: 10px;
  line-height: 1;
  cursor: pointer;
}

.json-fold-toggle:hover {
  background: rgba(37, 87, 246, 0.12);
}

.json-code-text {
  color: var(--ink);
  font-weight: 800;
  white-space: pre;
}

.json-token-key,
.json-token-punctuation {
  color: var(--ink);
}

.json-token-string {
  color: #047857;
}

.json-token-number {
  color: #2563eb;
}

.json-token-boolean {
  color: #b45309;
}

.json-token-null {
  color: #7c3aed;
}

.json-empty-state {
  height: 100%;
  min-height: 120px;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 1px dashed rgba(120, 138, 168, 0.28);
  border-radius: 8px;
  background: var(--json-soft-bg);
}

.json-tree-menu {
  position: fixed;
  z-index: 30;
  min-width: 128px;
  display: grid;
  gap: 4px;
  padding: 6px;
  border: 1px solid rgba(120, 138, 168, 0.24);
  border-radius: 8px;
  background: rgba(255, 255, 255, 0.92);
  box-shadow: 0 18px 42px rgba(44, 55, 67, 0.18);
  backdrop-filter: blur(18px);
}

.json-tree-menu button {
  width: 100%;
  height: 30px;
  padding: 0 9px;
  border: 0;
  border-radius: 7px;
  background: transparent;
  color: var(--ink);
  font-size: 12px;
  font-weight: 900;
  text-align: left;
  cursor: pointer;
}

.json-tree-menu button:hover {
  background: rgba(37, 87, 246, 0.1);
}

:global(:root[data-theme="dark"]) .json-tool-page {
  --json-glass-bg: rgba(15, 23, 42, 0.72);
  --json-glass-border: rgba(255, 255, 255, 0.12);
  --json-soft-bg: rgba(8, 17, 31, 0.68);
  --json-code-bg: rgba(8, 17, 31, 0.74);
}

:global(:root[data-theme="dark"]) .json-tool-page :deep(.tool-header),
:global(:root[data-theme="dark"]) .json-tool-page :deep(.tool-panel) {
  border-color: rgba(255, 255, 255, 0.12);
  background:
    linear-gradient(135deg, rgba(255, 255, 255, 0.07), rgba(255, 255, 255, 0.02)),
    rgba(15, 23, 42, 0.72);
  box-shadow:
    0 18px 48px rgba(0, 0, 0, 0.28),
    inset 0 1px 0 rgba(255, 255, 255, 0.08);
}

:global(:root[data-theme="dark"]) .json-editor-panel :deep(.el-textarea__inner) {
  border-color: rgba(255, 255, 255, 0.14);
  background:
    linear-gradient(135deg, rgba(255, 255, 255, 0.04), rgba(8, 17, 31, 0.8)),
    rgba(8, 17, 31, 0.74);
  color: #e5eefc;
  box-shadow: inset 0 0 0 1px rgba(255, 255, 255, 0.1);
  -webkit-text-fill-color: #e5eefc;
}

:global(:root[data-theme="dark"]) .json-status-card,
:global(:root[data-theme="dark"]) .json-code-tree,
:global(:root[data-theme="dark"]) .json-empty-state {
  border-color: rgba(255, 255, 255, 0.12);
  background:
    linear-gradient(135deg, rgba(255, 255, 255, 0.045), rgba(8, 17, 31, 0.72)),
    rgba(8, 17, 31, 0.68);
  color: var(--ink);
}

:global(:root[data-theme="dark"]) .json-status-card.is-valid {
  background: rgba(6, 78, 59, 0.34);
}

:global(:root[data-theme="dark"]) .json-status-card.is-error {
  background: rgba(127, 29, 29, 0.32);
}

:global(:root[data-theme="dark"]) .json-status-card.is-error strong,
:global(:root[data-theme="dark"]) .json-status-card.is-error small {
  color: #fca5a5;
}

:global(:root[data-theme="dark"]) .json-tree-menu {
  border-color: rgba(255, 255, 255, 0.12);
  background: rgba(15, 23, 42, 0.92);
}

:global(:root[data-theme="dark"]) .json-code-line:hover {
  background: rgba(116, 167, 255, 0.12);
}

:global(:root[data-theme="dark"]) .json-line-number {
  background: rgba(8, 17, 31, 0.9);
  color: #8fa0b7;
}

:global(:root[data-theme="dark"]) .json-fold-toggle {
  color: #dbeafe;
}

:global(:root[data-theme="dark"]) .json-fold-toggle:hover {
  background: rgba(116, 167, 255, 0.16);
}

:global(:root[data-theme="dark"]) .json-output-actions :deep(.json-action-button.is-info) {
  background: rgba(100, 116, 139, 0.28) !important;
  border-color: rgba(148, 163, 184, 0.42) !important;
  color: #cbd5e1 !important;
}

:global(:root[data-theme="dark"]) .json-output-actions :deep(.json-action-button.is-danger) {
  background: rgba(220, 38, 38, 0.22) !important;
  border-color: rgba(248, 113, 113, 0.42) !important;
  color: #fca5a5 !important;
}

:global(:root[data-theme="dark"]) .json-output-actions :deep(.json-action-button.is-success) {
  background: rgba(5, 150, 105, 0.22) !important;
  border-color: rgba(52, 211, 153, 0.42) !important;
  color: #6ee7b7 !important;
}

:global(:root[data-theme="dark"]) .json-output-actions :deep(.json-action-button.is-primary) {
  background: rgba(37, 99, 235, 0.24) !important;
  border-color: rgba(96, 165, 250, 0.46) !important;
  color: #93c5fd !important;
}

:global(:root[data-theme="dark"]) .json-output-actions :deep(.json-action-button.is-warning) {
  background: rgba(217, 119, 6, 0.24) !important;
  border-color: rgba(251, 146, 60, 0.46) !important;
  color: #fdba74 !important;
}

:global(:root[data-theme="dark"]) .json-token-string {
  color: #34d399;
}

:global(:root[data-theme="dark"]) .json-token-number {
  color: #60a5fa;
}

:global(:root[data-theme="dark"]) .json-token-boolean {
  color: #fbbf24;
}

:global(:root[data-theme="dark"]) .json-token-null {
  color: #c084fc;
}

:global(:root[data-theme="dark"]) .json-tree-menu button:hover {
  background: rgba(116, 167, 255, 0.14);
}

:global(:root[data-theme="dark"]) .json-tool-page.json-tool-page .json-code-tree,
:global(:root[data-theme="dark"]) .json-tool-page.json-tool-page .json-empty-state,
:global(:root[data-theme="dark"]) .json-tool-page.json-tool-page .json-status-card {
  border-color: rgba(255, 255, 255, 0.12) !important;
  background:
    linear-gradient(135deg, rgba(255, 255, 255, 0.045), rgba(8, 17, 31, 0.8)),
    rgba(8, 17, 31, 0.78) !important;
  color: #e5eefc !important;
}

:global(:root[data-theme="dark"]) .json-tool-page.json-tool-page .json-line-number {
  background: rgba(8, 17, 31, 0.96) !important;
  color: #9aa8bd !important;
}

:global(:root[data-theme="dark"]) .json-tool-page.json-tool-page .json-code-line:hover {
  background: rgba(116, 167, 255, 0.12) !important;
}

:global(:root[data-theme="dark"]) .json-tool-page.json-tool-page .json-status-card span,
:global(:root[data-theme="dark"]) .json-tool-page.json-tool-page .json-status-card small {
  color: #9aa8bd !important;
}

:global(:root[data-theme="dark"]) .json-tool-page.json-tool-page .json-status-card strong,
:global(:root[data-theme="dark"]) .json-tool-page.json-tool-page .json-code-text,
:global(:root[data-theme="dark"]) .json-tool-page.json-tool-page .json-token-key,
:global(:root[data-theme="dark"]) .json-tool-page.json-tool-page .json-token-punctuation {
  color: #e5eefc !important;
}

:global(:root[data-theme="dark"]) .json-tool-page.json-tool-page .json-editor-panel .el-textarea__inner {
  border-color: rgba(255, 255, 255, 0.14) !important;
  background:
    linear-gradient(135deg, rgba(255, 255, 255, 0.04), rgba(8, 17, 31, 0.84)),
    rgba(8, 17, 31, 0.78) !important;
  color: #e5eefc !important;
  box-shadow: inset 0 0 0 1px rgba(255, 255, 255, 0.1) !important;
  -webkit-text-fill-color: #e5eefc !important;
}

:global(:root[data-theme="dark"]) .json-tool-page.json-tool-page .json-output-actions .json-action-button {
  color: #e5eefc !important;
}

:global(:root[data-theme="dark"]) .json-tool-page.json-tool-page .json-output-actions .json-action-button span,
:global(:root[data-theme="dark"]) .json-tool-page.json-tool-page .json-output-actions .json-action-button .el-icon {
  color: inherit !important;
}

:global(:root[data-theme="dark"]) .json-tool-page.json-tool-page .json-output-actions .json-action-button.is-info {
  background: rgba(100, 116, 139, 0.28) !important;
  border-color: rgba(148, 163, 184, 0.42) !important;
  color: #cbd5e1 !important;
}

:global(:root[data-theme="dark"]) .json-tool-page.json-tool-page .json-output-actions .json-action-button.is-danger {
  background: rgba(220, 38, 38, 0.24) !important;
  border-color: rgba(248, 113, 113, 0.46) !important;
  color: #fecaca !important;
}

:global(:root[data-theme="dark"]) .json-tool-page.json-tool-page .json-output-actions .json-action-button.is-success {
  background: rgba(5, 150, 105, 0.24) !important;
  border-color: rgba(52, 211, 153, 0.46) !important;
  color: #a7f3d0 !important;
}

:global(:root[data-theme="dark"]) .json-tool-page.json-tool-page .json-output-actions .json-action-button.is-primary {
  background: rgba(37, 99, 235, 0.28) !important;
  border-color: rgba(96, 165, 250, 0.5) !important;
  color: #bfdbfe !important;
}

:global(:root[data-theme="dark"]) .json-tool-page.json-tool-page .json-output-actions .json-action-button.is-warning {
  background: rgba(217, 119, 6, 0.26) !important;
  border-color: rgba(251, 146, 60, 0.5) !important;
  color: #fed7aa !important;
}

@media (max-width: 1180px) {
  .json-tool-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}

@media (max-width: 900px) {
  .json-tool-page {
    overflow: auto;
  }

  .json-tool-grid {
    grid-template-columns: 1fr;
  }

  .json-tool-page :deep(.json-editor-panel),
  .json-tool-page :deep(.json-tree-panel) {
    height: auto;
  }

  .json-editor-panel :deep(.tool-textarea textarea) {
    height: 260px;
  }

  .json-code-tree {
    max-height: 260px;
  }
}

@media (max-width: 760px) {
  .json-tool-page :deep(.tool-panel-head) {
    align-items: flex-start;
  }

  .json-status-card div {
    grid-template-columns: 1fr;
  }

  .json-status-card div {
    display: grid;
  }

  .json-status-card strong {
    text-align: left;
  }
}
</style>

<style>
:root[data-theme="dark"] .json-tool-page .json-code-tree,
:root[data-theme="dark"] .json-tool-page .json-empty-state,
:root[data-theme="dark"] .json-tool-page .json-status-card {
  border-color: rgba(255, 255, 255, 0.12) !important;
  background:
    linear-gradient(135deg, rgba(255, 255, 255, 0.045), rgba(8, 17, 31, 0.82)),
    rgba(8, 17, 31, 0.82) !important;
  background-color: rgba(8, 17, 31, 0.82) !important;
  color: #e5eefc !important;
}

:root[data-theme="dark"] .json-tool-page .json-line-number {
  background: rgba(8, 17, 31, 0.96) !important;
  background-color: rgba(8, 17, 31, 0.96) !important;
  color: #9aa8bd !important;
}

:root[data-theme="dark"] .json-tool-page .json-code-line:hover {
  background: rgba(116, 167, 255, 0.12) !important;
}

:root[data-theme="dark"] .json-tool-page .json-code-text,
:root[data-theme="dark"] .json-tool-page .json-token-key,
:root[data-theme="dark"] .json-tool-page .json-token-punctuation,
:root[data-theme="dark"] .json-tool-page .json-status-card strong {
  color: #e5eefc !important;
}

:root[data-theme="dark"] .json-tool-page .json-status-card span,
:root[data-theme="dark"] .json-tool-page .json-status-card small {
  color: #9aa8bd !important;
}

:root[data-theme="dark"] .json-tool-page .json-editor-panel .el-textarea__inner {
  border-color: rgba(255, 255, 255, 0.14) !important;
  background:
    linear-gradient(135deg, rgba(255, 255, 255, 0.04), rgba(8, 17, 31, 0.86)),
    rgba(8, 17, 31, 0.82) !important;
  background-color: rgba(8, 17, 31, 0.82) !important;
  color: #e5eefc !important;
  box-shadow: inset 0 0 0 1px rgba(255, 255, 255, 0.1) !important;
  -webkit-text-fill-color: #e5eefc !important;
}

:root[data-theme="dark"] .json-tool-page .json-output-actions .json-action-button,
:root[data-theme="dark"] .json-tool-page .json-output-actions .json-action-button span,
:root[data-theme="dark"] .json-tool-page .json-output-actions .json-action-button .el-icon {
  color: inherit !important;
}

:root[data-theme="dark"] .json-tool-page .json-output-actions .json-action-button.is-info {
  background: rgba(100, 116, 139, 0.28) !important;
  border-color: rgba(148, 163, 184, 0.42) !important;
  color: #cbd5e1 !important;
}

:root[data-theme="dark"] .json-tool-page .json-output-actions .json-action-button.is-danger {
  background: rgba(220, 38, 38, 0.24) !important;
  border-color: rgba(248, 113, 113, 0.46) !important;
  color: #fecaca !important;
}

:root[data-theme="dark"] .json-tool-page .json-output-actions .json-action-button.is-success {
  background: rgba(5, 150, 105, 0.24) !important;
  border-color: rgba(52, 211, 153, 0.46) !important;
  color: #a7f3d0 !important;
}

:root[data-theme="dark"] .json-tool-page .json-output-actions .json-action-button.is-primary {
  background: rgba(37, 99, 235, 0.28) !important;
  border-color: rgba(96, 165, 250, 0.5) !important;
  color: #bfdbfe !important;
}

:root[data-theme="dark"] .json-tool-page .json-output-actions .json-action-button.is-warning {
  background: rgba(217, 119, 6, 0.26) !important;
  border-color: rgba(251, 146, 60, 0.5) !important;
  color: #fed7aa !important;
}
</style>
