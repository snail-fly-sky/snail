<template>
  <main ref="homePageRef" class="home-page">
    <section class="home-workbench" aria-label="工具工作台">
      <div class="home-workbench-main">
        <div class="home-workbench-kicker">
          <span>工作台</span>
          <strong>{{ enabledToolCount }} 个工具可用</strong>
        </div>
        <div class="home-workbench-copy">
          <h1>打开工具，继续上次的处理</h1>
          <p>把搜索、收藏和最近使用放到首屏，减少说明内容，把空间留给能直接操作的入口。</p>
        </div>
        <div class="home-command-row">
          <el-input
            v-model="toolSearchInput"
            class="home-command-input"
            clearable
            placeholder="输入工具名称，回车搜索"
            @keyup.enter="commitToolSearch"
            @clear="clearToolSearch"
          >
            <template #prefix>
              <Search :size="15" />
            </template>
          </el-input>
          <el-button class="home-command-button" type="primary" @click="commitToolSearch">
            <Search :size="16" />
            搜索
          </el-button>
        </div>
        <div class="home-stat-row" aria-label="工具统计">
          <span>
            <strong>{{ enabledToolCount }}</strong>
            已上线
          </span>
          <span>
            <strong>{{ favoriteTools.length }}</strong>
            已收藏
          </span>
          <span>
            <strong>{{ recentTools.length }}</strong>
            最近使用
          </span>
          <span>
            <strong>{{ plannedToolCount }}</strong>
            规划中
          </span>
        </div>
        <div class="home-workbench-tools" aria-label="常用工具">
          <button
            v-for="tool in workspaceTools"
            :key="`workspace-${tool.path}`"
            type="button"
            class="home-workbench-tool"
            @click="openTool(tool.path)"
          >
            <span class="home-workbench-tool-icon">
              <component :is="tool.icon" :size="20" />
            </span>
            <span>
              <strong>{{ tool.title }}</strong>
              <small>{{ tool.category }} · {{ tool.kicker }}</small>
            </span>
          </button>
        </div>
      </div>

      <aside class="home-workbench-side" aria-label="快捷信息">
        <section class="home-side-card">
          <div class="home-side-card-head">
            <span>
              <Clock3 :size="15" />
              最近使用
            </span>
            <small class="home-side-count">{{ recentTools.length }}</small>
          </div>
          <div v-if="recentTools.length > 0" class="home-side-list">
            <el-tag
              v-for="tool in recentTools"
              :key="`recent-panel-${tool.path}`"
              class="home-side-tag is-clickable"
              effect="plain"
              role="button"
              round
              tabindex="0"
              @click="openTool(tool.path)"
              @keyup.enter="openTool(tool.path)"
              @keyup.space="openTool(tool.path)"
            >
              <component :is="tool.icon" :size="16" />
              <span>{{ tool.title }}</span>
            </el-tag>
          </div>
          <el-empty v-else class="home-side-empty" description="还没有最近使用" :image-size="48" />
        </section>

        <section class="home-side-card">
          <div class="home-side-card-head">
            <span>
              <Star :size="15" />
              收藏工具
            </span>
            <small class="home-side-count">{{ favoriteTools.length }}</small>
          </div>
          <div v-if="favoriteTools.length > 0" class="home-side-list">
            <el-tag
              v-for="tool in favoriteTools"
              :key="`favorite-panel-${tool.path}`"
              class="home-side-tag is-clickable"
              effect="plain"
              role="button"
              round
              tabindex="0"
              @click="openTool(tool.path)"
              @keyup.enter="openTool(tool.path)"
              @keyup.space="openTool(tool.path)"
            >
              <component :is="tool.icon" :size="16" />
              <span>{{ tool.title }}</span>
            </el-tag>
          </div>
          <el-empty v-else class="home-side-empty" description="收藏后会固定在这里" :image-size="48" />
        </section>

        <section class="home-side-card">
          <div class="home-side-card-head">
            <span>规划工具</span>
            <small class="home-side-count">{{ plannedTools.length }}</small>
          </div>
          <div class="home-side-list">
            <el-tag
              v-for="tool in plannedTools"
              :key="`planned-panel-${tool.path}`"
              class="home-side-tag is-disabled"
              effect="plain"
              round
            >
              <component :is="tool.icon" :size="16" />
              <span>{{ tool.title }}</span>
            </el-tag>
          </div>
        </section>
      </aside>
    </section>

    <section class="portal-section" aria-label="全部工具">
      <div class="portal-section-head">
        <div>
          <span>Toolkit</span>
          <h2>工具箱</h2>
        </div>
        <div class="portal-tool-controls">
          <el-input
            v-model="toolSearchInput"
            class="portal-tool-search"
            clearable
            placeholder="搜索工具"
            @keyup.enter="commitToolSearch"
            @clear="clearToolSearch"
          >
            <template #prefix>
              <Search :size="15" />
            </template>
          </el-input>
          <span class="portal-tool-count">{{ displayedTools.length }} / {{ allTools.length }}</span>
        </div>
      </div>
      <div class="portal-tool-grid">
        <article
          v-for="tool in displayedTools"
          :key="tool.title"
          class="portal-feature-card"
          :class="[
            { available: tool.enabled, planned: !tool.enabled, pinned: isFavorite(tool.path) },
            `tone-${tool.tone}`
          ]"
        >
          <div class="portal-feature-top">
            <span class="portal-feature-icon">
              <component :is="tool.icon" :size="22" />
            </span>
            <div class="portal-card-badges">
              <span class="portal-category-badge">{{ tool.category }}</span>
              <span class="portal-status-badge" :class="{ ready: tool.enabled, pending: !tool.enabled }">
                {{ tool.enabled ? '已上线' : '规划中' }}
              </span>
              <button
                v-if="tool.enabled"
                class="portal-favorite-button"
                :class="{ active: isFavorite(tool.path) }"
                type="button"
                :aria-label="isFavorite(tool.path) ? '取消收藏' : '收藏工具'"
                @click.stop="toggleFavorite(tool.path)"
              >
                <Star :size="15" :fill="isFavorite(tool.path) ? 'currentColor' : 'none'" />
              </button>
            </div>
          </div>
          <h3>{{ tool.title }}</h3>
          <p>{{ tool.description }}</p>
          <el-button
            v-if="tool.enabled"
            class="portal-card-action"
            type="primary"
            plain
            @click="openTool(tool.path)"
          >
            进入
          </el-button>
        </article>
      </div>
      <el-empty
        v-if="displayedTools.length === 0"
        class="portal-empty-result"
        description="没有找到匹配的工具"
      />
    </section>

    <section class="portal-strip" aria-label="项目说明">
      <div>
        <span>Stack</span>
        <strong>Vue 3 + Element Plus + Pinia</strong>
      </div>
      <div>
        <span>Storage</span>
        <strong>本地浏览器保存简历数据</strong>
      </div>
      <div>
        <span>Next</span>
        <strong>后续可以继续接入更多个人工具</strong>
      </div>
    </section>

    <el-backtop class="home-backtop" target=".home-page" :right="28" :bottom="28">
      <ArrowUp :size="20" />
    </el-backtop>
  </main>
</template>

<script setup>
import { computed, markRaw, nextTick, onMounted, ref } from 'vue'
import { onBeforeRouteLeave, useRouter } from 'vue-router'
import {
  Braces,
  CalendarClock,
  Clock3,
  ArrowUp,
  FileText,
  Palette,
  QrCode,
  Search,
  Star,
  TimerReset,
  Wrench
} from 'lucide-vue-next'

const router = useRouter()
const homePageRef = ref()
const homeScrollStorageKey = 'snail-home-scroll-top'
const favoriteToolsStorageKey = 'snail-home-favorite-tools'
const recentToolsStorageKey = 'snail-home-recent-tools'
const toolSearchInput = ref('')
const toolSearchKeyword = ref('')
const favoriteToolPaths = ref([])
const recentToolPaths = ref([])
const allTools = [
  {
    title: '简历工作台',
    kicker: 'Resume',
    category: '文档',
    description: '编辑多份简历，实时预览，并导出 PDF 或 Word。',
    path: '/ResumeWorkbench',
    icon: markRaw(FileText),
    tone: 'resume',
    enabled: true
  },
  {
    title: 'JSON 处理',
    kicker: 'JSON',
    category: '开发',
    description: '格式化、压缩 JSON，并在解析失败时给出明确错误。',
    path: '/JsonToolPage',
    icon: markRaw(Braces),
    tone: 'json',
    enabled: true
  },
  {
    title: '时间转换',
    kicker: 'Time',
    category: '日常',
    description: '时间戳与本地时间互转，支持秒级和毫秒级输入。',
    path: '/TimeToolPage',
    icon: markRaw(CalendarClock),
    tone: 'time',
    enabled: true
  },
  {
    title: '下班倒计时',
    kicker: 'Offwork',
    category: '日常',
    description: '实时显示距离下班还有多久，支持自定义上下班时间和今日进度。',
    path: '/OffworkCountdownPage',
    icon: markRaw(TimerReset),
    tone: 'offwork',
    enabled: true
  },
  {
    title: '颜色取值',
    kicker: 'Color',
    category: '视觉',
    description: '收集常用色值、复制 HEX，并记录项目调色板。',
    path: '/ColorToolPage',
    icon: markRaw(Palette),
    tone: 'color',
    enabled: true
  },
  {
    title: '二维码工具',
    kicker: 'QR',
    category: '视觉',
    description: '把链接或文本快速生成二维码图片。',
    path: '/QrCodeToolPage',
    icon: markRaw(QrCode),
    tone: 'qrcode',
    enabled: true
  },
  {
    title: '前端处理工具箱',
    kicker: 'Process',
    category: '开发',
    description: '处理图片、Base64、URL、文本、CSV、Markdown 和浏览器 UA。',
    path: '/FrontendProcessToolPage',
    icon: markRaw(Wrench),
    tone: 'frontend',
    enabled: true
  },
  {
    title: '开发备忘',
    kicker: 'Dev',
    category: '开发',
    description: '沉淀常用命令、代码片段和排查记录。',
    path: '/notes',
    icon: markRaw(Wrench),
    tone: 'notes',
    enabled: false
  }
]

const enabledTools = computed(() => {
  return allTools.filter((tool) => tool.enabled)
})
const plannedTools = computed(() => {
  return allTools.filter((tool) => !tool.enabled)
})
const enabledToolCount = computed(() => {
  return enabledTools.value.length
})
const plannedToolCount = computed(() => {
  return plannedTools.value.length
})
const normalizedToolSearch = computed(() => {
  return toolSearchKeyword.value.trim().toLowerCase()
})
const searchedTools = computed(() => {
  if (normalizedToolSearch.value.length === 0) {
    return allTools
  }

  return allTools.filter((tool) => {
    return createToolSearchContent(tool).includes(normalizedToolSearch.value)
  })
})
const displayedTools = computed(() => {
  return searchedTools.value.slice().sort((firstTool, secondTool) => {
    return Number(isFavorite(secondTool.path)) - Number(isFavorite(firstTool.path))
  })
})
const favoriteTools = computed(() => {
  return favoriteToolPaths.value
    .map((path) => findToolByPath(path))
    .filter((tool) => tool && tool.enabled)
})
const recentTools = computed(() => {
  return recentToolPaths.value
    .map((path) => findToolByPath(path))
    .filter((tool) => tool && tool.enabled)
    .slice(0, 4)
})
const workspaceTools = computed(() => {
  if (favoriteTools.value.length > 0) {
    return favoriteTools.value.slice(0, 4)
  }

  return enabledTools.value.slice(0, 4)
})

function openTool(path) {
  recordRecentTool(path)
  saveHomeScroll()
  router.push(path)
}

function commitToolSearch() {
  toolSearchKeyword.value = toolSearchInput.value
}

function clearToolSearch() {
  toolSearchInput.value = ''
  toolSearchKeyword.value = ''
}

function createToolSearchContent(tool) {
  return `${tool.title} ${tool.kicker} ${tool.category} ${tool.description}`.toLowerCase()
}

function findToolByPath(path) {
  return allTools.find((tool) => tool.path === path)
}

function isFavorite(path) {
  return favoriteToolPaths.value.includes(path)
}

function toggleFavorite(path) {
  if (isFavorite(path)) {
    const nextPaths = favoriteToolPaths.value.filter((toolPath) => toolPath !== path)
    favoriteToolPaths.value = nextPaths
    writeStoredToolPaths(favoriteToolsStorageKey, nextPaths)
    return
  }

  const nextPaths = [...favoriteToolPaths.value, path]
  favoriteToolPaths.value = nextPaths
  writeStoredToolPaths(favoriteToolsStorageKey, nextPaths)
}

function recordRecentTool(path) {
  const tool = findToolByPath(path)

  if (!tool || !tool.enabled) {
    return
  }

  const nextPaths = [path, ...recentToolPaths.value.filter((toolPath) => toolPath !== path)].slice(0, 5)
  recentToolPaths.value = nextPaths
  writeStoredToolPaths(recentToolsStorageKey, nextPaths)
}

function readStoredToolPaths(storageKey) {
  const storedValue = localStorage.getItem(storageKey)

  if (storedValue === null) {
    return []
  }

  try {
    const parsedValue = JSON.parse(storedValue)

    if (Array.isArray(parsedValue)) {
      return parsedValue
    }

    localStorage.removeItem(storageKey)
    return []
  } catch (error) {
    localStorage.removeItem(storageKey)
    return []
  }
}

function writeStoredToolPaths(storageKey, paths) {
  localStorage.setItem(storageKey, JSON.stringify(paths))
}

function saveHomeScroll() {
  sessionStorage.setItem(homeScrollStorageKey, String(homePageRef.value.scrollTop))
}

onMounted(() => {
  favoriteToolPaths.value = readStoredToolPaths(favoriteToolsStorageKey)
  recentToolPaths.value = readStoredToolPaths(recentToolsStorageKey)

  nextTick(() => {
    const scrollTop = Number(sessionStorage.getItem(homeScrollStorageKey))
    requestAnimationFrame(() => {
      homePageRef.value.scrollTop = scrollTop
    })
  })
})

onBeforeRouteLeave(() => {
  saveHomeScroll()
})
</script>

<style scoped>
.home-workbench {
  --home-board-bg:
    linear-gradient(135deg, rgba(255, 255, 255, 0.82), rgba(255, 255, 255, 0.38)),
    rgba(255, 255, 255, 0.72);
  --home-card-bg:
    linear-gradient(135deg, rgba(255, 255, 255, 0.78), rgba(255, 255, 255, 0.34)),
    rgba(255, 255, 255, 0.66);
  --home-border: rgba(79, 93, 120, 0.2);
  --home-muted: #4a5667;
  min-height: 430px;
  display: grid;
  grid-template-columns: minmax(0, 1.45fr) minmax(300px, 0.72fr);
  gap: 14px;
  padding: 16px;
  border: 1px solid var(--home-border);
  border-radius: 8px;
  background: var(--home-board-bg);
  color: var(--ink);
  box-shadow: var(--glass-shadow), var(--glass-inner);
  backdrop-filter: var(--glass-blur);
  -webkit-backdrop-filter: var(--glass-blur);
}

.home-workbench-main {
  min-width: 0;
  display: grid;
  align-content: start;
  gap: 16px;
  padding: 8px;
}

.home-workbench-kicker {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  color: var(--home-muted);
  font-size: 12px;
  font-weight: 950;
}

.home-workbench-kicker span,
.home-workbench-kicker strong {
  min-height: 30px;
  display: inline-flex;
  align-items: center;
  padding: 0 10px;
  border: 1px solid var(--home-border);
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.42);
}

.home-workbench-kicker strong {
  color: var(--blue);
}

.home-workbench-copy {
  display: grid;
  gap: 10px;
  max-width: 760px;
}

.home-workbench-copy h1 {
  margin: 0;
  color: var(--ink);
  font-size: clamp(34px, 4vw, 56px);
  line-height: 1.04;
  letter-spacing: 0;
  font-weight: 950;
}

.home-workbench-copy p {
  max-width: 680px;
  margin: 0;
  color: var(--home-muted);
  font-size: 16px;
  line-height: 1.75;
  font-weight: 850;
}

.home-command-row {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 104px;
  gap: 10px;
  max-width: 760px;
}

.home-command-button {
  gap: 6px;
}

.home-command-input :deep(.el-input__wrapper) {
  min-height: 46px;
}

.home-stat-row {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 10px;
  max-width: 760px;
}

.home-stat-row span {
  min-width: 0;
  display: grid;
  gap: 4px;
  min-height: 74px;
  padding: 12px;
  border: 1px solid var(--home-border);
  border-radius: 8px;
  background: var(--home-card-bg);
  color: var(--home-muted);
  font-size: 12px;
  font-weight: 900;
  backdrop-filter: blur(18px) saturate(1.2);
  -webkit-backdrop-filter: blur(18px) saturate(1.2);
}

.home-stat-row strong {
  color: var(--ink);
  font-size: 28px;
  line-height: 1;
  font-weight: 950;
}

.home-workbench-tools {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 10px;
  max-width: 760px;
}

.home-workbench-tool {
  min-width: 0;
  display: grid;
  grid-template-columns: auto minmax(0, 1fr);
  align-items: center;
  gap: 10px;
  padding: 12px;
  border: 1px solid var(--home-border);
  border-radius: 8px;
  background: var(--home-card-bg);
  color: var(--ink);
  text-align: left;
  backdrop-filter: blur(18px) saturate(1.2);
  -webkit-backdrop-filter: blur(18px) saturate(1.2);
}

.home-workbench-tool:hover,
.home-workbench-tool:focus-visible {
  border-color: rgba(37, 87, 246, 0.32);
  outline: none;
}

.home-workbench-tool-icon {
  width: 38px;
  height: 38px;
  display: grid;
  place-items: center;
  border-radius: 8px;
  background: rgba(37, 87, 246, 0.12);
  color: var(--blue);
}

.home-workbench-tool strong {
  display: block;
  overflow: hidden;
  color: var(--ink);
  font-size: 14px;
  font-weight: 950;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.home-workbench-tool small {
  display: block;
  margin-top: 2px;
  overflow: hidden;
  color: var(--home-muted);
  font-size: 12px;
  font-weight: 850;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.home-workbench-side {
  min-width: 0;
  display: grid;
  align-content: start;
  grid-template-rows: repeat(3, auto);
  gap: 12px;
}

.home-side-card {
  min-width: 0;
  min-height: 0;
  display: grid;
  grid-template-rows: auto auto;
  gap: 14px;
  padding: 16px;
  border: 1px solid var(--home-border);
  border-radius: 18px;
  background:
    linear-gradient(145deg, rgba(255, 255, 255, 0.72), rgba(255, 255, 255, 0.34)),
    rgba(255, 255, 255, 0.58);
  overflow: hidden;
  box-shadow:
    0 18px 44px rgba(31, 41, 55, 0.08),
    inset 0 1px 0 rgba(255, 255, 255, 0.76);
  backdrop-filter: blur(18px) saturate(1.2);
  -webkit-backdrop-filter: blur(18px) saturate(1.2);
}

.home-side-card-head {
  min-height: 28px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
  color: var(--ink);
  font-size: 13px;
  font-weight: 950;
}

.home-side-card-head span {
  display: inline-flex;
  align-items: center;
  gap: 6px;
}

.home-side-card-head svg {
  color: var(--blue);
}

.home-side-count {
  min-width: 24px;
  height: 24px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 0 8px;
  border: 1px solid rgba(120, 138, 168, 0.2);
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.58);
  color: var(--home-muted);
  font-size: 12px;
  font-weight: 900;
  line-height: 1;
}

.home-side-list {
  min-height: 0;
  display: flex;
  align-content: flex-start;
  align-items: flex-start;
  flex-wrap: wrap;
  gap: 10px;
  overflow: auto;
}

.home-side-tag {
  max-width: 100%;
  height: auto;
  min-height: 38px;
  padding: 6px 12px 6px 8px;
  --el-tag-border-color: rgba(120, 138, 168, 0.22);
  --el-tag-hover-border-color: rgba(37, 87, 246, 0.34);
  --el-tag-bg-color: rgba(255, 255, 255, 0.64);
  --el-tag-text-color: var(--ink);
  border-radius: 999px;
  box-shadow:
    0 10px 26px rgba(31, 41, 55, 0.08),
    inset 0 1px 0 rgba(255, 255, 255, 0.72);
  backdrop-filter: blur(16px) saturate(1.18);
  -webkit-backdrop-filter: blur(16px) saturate(1.18);
  transition: transform 160ms ease, box-shadow 160ms ease;
}

.home-side-tag.is-clickable {
  cursor: pointer;
}

.home-side-tag.is-clickable:hover,
.home-side-tag.is-clickable:focus-visible {
  box-shadow:
    0 14px 30px rgba(37, 87, 246, 0.12),
    inset 0 0 0 1px var(--el-tag-hover-border-color),
    inset 0 1px 0 rgba(255, 255, 255, 0.82);
  outline: none;
}

.home-side-tag.is-disabled {
  cursor: default;
  opacity: 0.72;
}

.home-side-tag :deep(.el-tag__content) {
  min-width: 0;
  display: inline-flex;
  align-items: center;
  gap: 8px;
}

.home-side-tag :deep(.el-tag__content > svg) {
  width: 24px;
  height: 24px;
  flex: 0 0 auto;
  padding: 5px;
  border-radius: 999px;
  background: rgba(37, 87, 246, 0.1);
  color: var(--blue);
}

.home-side-tag span {
  min-width: 0;
  overflow: hidden;
  color: var(--ink);
  font-size: 13px;
  font-weight: 850;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.home-side-empty {
  min-height: 0;
  padding: 4px 0;
}

.home-side-empty :deep(.el-empty__image) {
  opacity: 0.58;
  filter: contrast(1.08) saturate(0.72);
}

.home-side-empty :deep(.el-empty__description p) {
  color: var(--home-muted) !important;
}

.portal-section {
  margin-top: 14px;
  padding: 16px;
}

.portal-tool-grid {
  gap: 12px;
}

.portal-feature-card {
  min-height: 178px;
  border: 0;
  box-shadow: 0 14px 38px rgba(31, 41, 55, 0.08);
}

.portal-feature-card.available,
.portal-feature-card.planned,
.portal-feature-card.pinned {
  border: 0;
  box-shadow: 0 14px 38px rgba(31, 41, 55, 0.08);
}

.portal-feature-card.planned {
  border-style: none;
}

.portal-feature-card:hover,
.portal-feature-card:focus-within,
.portal-feature-card.available:hover,
.portal-feature-card.available:focus-within,
.portal-feature-card.planned:hover,
.portal-feature-card.planned:focus-within,
.portal-feature-card.pinned:hover,
.portal-feature-card.pinned:focus-within {
  border: 0;
  box-shadow:
    0 24px 58px var(--tool-shadow),
    inset 0 0 0 1px var(--tool-accent-border);
}

.portal-strip {
  margin-top: 14px;
}

:global(:root[data-theme="dark"] .home-page .home-workbench) {
  --home-board-bg:
    linear-gradient(135deg, rgba(17, 30, 51, 0.92), rgba(7, 12, 22, 0.86)),
    rgba(7, 12, 22, 0.9);
  --home-card-bg:
    linear-gradient(135deg, rgba(30, 45, 72, 0.86), rgba(10, 18, 32, 0.78)),
    rgba(10, 18, 32, 0.86);
  --home-border: rgba(148, 163, 184, 0.22);
  --home-muted: #c6d2e4;
  color: #eef4ff;
}

:global(:root[data-theme="dark"] .home-page .home-workbench-kicker span),
:global(:root[data-theme="dark"] .home-page .home-workbench-kicker strong) {
  background: rgba(8, 14, 26, 0.72);
}

:global(:root[data-theme="dark"] .home-page .home-workbench-tool-icon) {
  background: rgba(116, 167, 255, 0.14);
  color: var(--blue);
}

:global(:root[data-theme="dark"] .home-page .home-workbench-tool:hover),
:global(:root[data-theme="dark"] .home-page .home-workbench-tool:focus-visible) {
  border-color: rgba(116, 167, 255, 0.36);
}

:global(:root[data-theme="dark"] .home-page .home-side-card) {
  border-color: rgba(148, 163, 184, 0.18);
  background:
    linear-gradient(145deg, rgba(22, 34, 56, 0.84), rgba(8, 14, 26, 0.74)),
    rgba(8, 14, 26, 0.82);
  box-shadow:
    0 18px 44px rgba(0, 0, 0, 0.24),
    inset 0 1px 0 rgba(255, 255, 255, 0.08);
}

:global(:root[data-theme="dark"] .home-page .home-side-count) {
  border-color: rgba(148, 163, 184, 0.16);
  background: rgba(8, 14, 26, 0.58);
  color: #c6d2e4;
}

:global(:root[data-theme="dark"] .home-page .home-side-tag) {
  --el-tag-bg-color: rgba(14, 24, 42, 0.72);
  --el-tag-border-color: rgba(148, 163, 184, 0.22);
  --el-tag-hover-border-color: rgba(116, 167, 255, 0.44);
  --el-tag-text-color: #eef4ff;
  box-shadow:
    0 12px 28px rgba(0, 0, 0, 0.22),
    inset 0 1px 0 rgba(255, 255, 255, 0.08);
}

:global(:root[data-theme="dark"] .home-page .home-side-tag.is-clickable:hover),
:global(:root[data-theme="dark"] .home-page .home-side-tag.is-clickable:focus-visible) {
  box-shadow:
    0 16px 34px rgba(0, 0, 0, 0.28),
    inset 0 0 0 1px var(--el-tag-hover-border-color),
    inset 0 1px 0 rgba(255, 255, 255, 0.12);
}

:global(:root[data-theme="dark"] .home-page .home-side-tag .el-tag__content > svg) {
  background: rgba(116, 167, 255, 0.14);
}

:global(:root[data-theme="dark"] .home-page .home-side-empty .el-empty__image) {
  opacity: 0.72;
  filter: brightness(1.18) contrast(1.05) saturate(0.76);
}

:global(:root[data-theme="dark"] .home-page .home-side-empty .el-empty__description p) {
  color: #c6d2e4 !important;
}

:global(:root[data-theme="dark"] .home-page .portal-section) {
  border-color: rgba(148, 163, 184, 0.18);
  background:
    linear-gradient(135deg, rgba(18, 30, 50, 0.78), rgba(8, 13, 24, 0.72)),
    rgba(8, 13, 24, 0.8);
  color: #eef4ff;
}

:global(:root[data-theme="dark"] .home-page .portal-feature-card.available),
:global(:root[data-theme="dark"] .home-page .portal-feature-card.planned) {
  border: 0;
  background:
    linear-gradient(135deg, var(--tool-accent-soft), rgba(9, 16, 30, 0.78)),
    rgba(9, 16, 30, 0.88);
  box-shadow: 0 18px 42px rgba(0, 0, 0, 0.22);
}

:global(:root[data-theme="dark"] .home-page .portal-feature-card:hover),
:global(:root[data-theme="dark"] .home-page .portal-feature-card:focus-within),
:global(:root[data-theme="dark"] .home-page .portal-feature-card.available:hover),
:global(:root[data-theme="dark"] .home-page .portal-feature-card.available:focus-within),
:global(:root[data-theme="dark"] .home-page .portal-feature-card.planned:hover),
:global(:root[data-theme="dark"] .home-page .portal-feature-card.planned:focus-within),
:global(:root[data-theme="dark"] .home-page .portal-feature-card.pinned:hover),
:global(:root[data-theme="dark"] .home-page .portal-feature-card.pinned:focus-within) {
  border: 0;
  box-shadow:
    0 24px 58px rgba(0, 0, 0, 0.3),
    inset 0 0 0 1px rgba(148, 163, 184, 0.28);
}

@media (max-width: 1180px) {
  .home-workbench {
    grid-template-columns: 1fr;
  }

  .home-workbench-side {
    grid-template-columns: repeat(3, minmax(0, 1fr));
    grid-template-rows: auto;
  }
}

@media (max-width: 760px) {
  .home-workbench {
    padding: 12px;
  }

  .home-workbench-main {
    padding: 0;
  }

  .home-command-row,
  .home-stat-row,
  .home-workbench-tools,
  .home-workbench-side {
    grid-template-columns: 1fr;
  }

  .home-workbench-side {
    grid-template-rows: none;
  }
}
</style>
