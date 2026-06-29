<template>
  <main ref="homePageRef" class="home-page">
    <section class="portal-hero">
      <nav class="home-nav" aria-label="首页导航">
        <div class="home-brand">
          <span class="home-brand-mark">S</span>
          <span>Snail Tools</span>
        </div>
        <div class="portal-nav-actions">
          <el-button round @click="openTool('/JsonToolPage')">
            JSON 处理
          </el-button>
          <el-button class="home-nav-action" type="primary" round @click="openTool('/ResumeWorkbench')">
            简历工作台
          </el-button>
        </div>
      </nav>

      <div class="portal-hero-grid">
        <div class="portal-copy">
          <el-tag class="home-kicker" effect="plain" type="info">Personal Console</el-tag>
          <h1>个人项目的功能入口台</h1>
          <p>
            把常用的小工具集中在一个安静、直接的页面里。简历制作、JSON 处理、时间转换和后续功能都从这里进入。
          </p>
          <div class="portal-actions">
            <el-button class="home-primary-button" type="primary" size="large" @click="openTool('/ResumeWorkbench')">
              <FileText :size="18" />
              制作简历
            </el-button>
            <el-button class="home-secondary-button" size="large" @click="openTool('/JsonToolPage')">
              <Braces :size="18" />
              格式化 JSON
            </el-button>
          </div>
          <div class="portal-signal-strip" aria-label="工具状态">
            <span><strong>{{ enabledToolCount }}</strong>已接入</span>
            <span><strong>Vue3</strong>前端栈</span>
            <span><strong>Element Plus</strong>组件</span>
          </div>
        </div>

        <div class="portal-board portal-overview-card" aria-label="项目概况">
          <div class="portal-overview-head">
            <span class="portal-overview-mark">S</span>
            <div>
              <small>Project Overview</small>
              <strong>Snail Tools</strong>
            </div>
          </div>
          <p>
            这是一个面向个人日常工作的轻量工具集合，优先沉淀高频、低依赖、打开即用的功能。首页负责聚合入口，具体能力按类别拆分到独立页面。
          </p>
          <div class="portal-overview-metrics" aria-label="项目数据">
            <span>
              <b>{{ enabledToolCount }}</b>
              <small>已上线工具</small>
            </span>
            <span>
              <b>{{ plannedToolCount }}</b>
              <small>规划中</small>
            </span>
            <span>
              <b>{{ allTools.length }}</b>
              <small>总入口</small>
            </span>
          </div>
          <div class="portal-overview-stack" aria-label="技术栈">
            <span>Vue 3</span>
            <span>Element Plus</span>
            <span>Pinia</span>
            <span>Vite</span>
          </div>
        </div>
      </div>
    </section>

    <section class="portal-section" aria-label="全部工具">
      <div class="portal-section-head">
        <span>Toolkit</span>
        <h2>工具箱</h2>
      </div>
      <div class="portal-tool-grid">
        <article
          v-for="tool in allTools"
          :key="tool.title"
          class="portal-feature-card"
          :class="[{ available: tool.enabled, planned: !tool.enabled }, `tone-${tool.tone}`]"
        >
          <div class="portal-feature-top">
            <span class="portal-feature-icon">
              <component :is="tool.icon" :size="22" />
            </span>
            <span class="portal-status-badge" :class="{ ready: tool.enabled, pending: !tool.enabled }">
              {{ tool.enabled ? '已上线' : '规划中' }}
            </span>
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
  ArrowUp,
  FileText,
  Palette,
  QrCode,
  TimerReset,
  Wrench
} from 'lucide-vue-next'

const router = useRouter()
const homePageRef = ref()
const homeScrollStorageKey = 'snail-home-scroll-top'
const allTools = [
  {
    title: '简历工作台',
    kicker: 'Resume',
    description: '编辑多份简历，实时预览，并导出 PDF 或 Word。',
    path: '/ResumeWorkbench',
    icon: markRaw(FileText),
    tone: 'resume',
    enabled: true
  },
  {
    title: 'JSON 处理',
    kicker: 'JSON',
    description: '格式化、压缩 JSON，并在解析失败时给出明确错误。',
    path: '/JsonToolPage',
    icon: markRaw(Braces),
    tone: 'json',
    enabled: true
  },
  {
    title: '时间转换',
    kicker: 'Time',
    description: '时间戳与本地时间互转，支持秒级和毫秒级输入。',
    path: '/TimeToolPage',
    icon: markRaw(CalendarClock),
    tone: 'time',
    enabled: true
  },
  {
    title: '下班倒计时',
    kicker: 'Offwork',
    description: '实时显示距离下班还有多久，支持自定义上下班时间和今日进度。',
    path: '/OffworkCountdownPage',
    icon: markRaw(TimerReset),
    tone: 'offwork',
    enabled: true
  },
  {
    title: '颜色取值',
    kicker: 'Color',
    description: '收集常用色值、复制 HEX，并记录项目调色板。',
    path: '/ColorToolPage',
    icon: markRaw(Palette),
    tone: 'color',
    enabled: true
  },
  {
    title: '二维码工具',
    kicker: 'QR',
    description: '把链接或文本快速生成二维码图片。',
    path: '/QrCodeToolPage',
    icon: markRaw(QrCode),
    tone: 'qrcode',
    enabled: true
  },
  {
    title: '前端处理工具箱',
    kicker: 'Process',
    description: '处理图片、Base64、URL、文本、CSV、Markdown 和浏览器 UA。',
    path: '/FrontendProcessToolPage',
    icon: markRaw(Wrench),
    tone: 'frontend',
    enabled: true
  },
  {
    title: '开发备忘',
    kicker: 'Dev',
    description: '沉淀常用命令、代码片段和排查记录。',
    path: '/notes',
    icon: markRaw(Wrench),
    tone: 'notes',
    enabled: false
  }
]

const enabledToolCount = computed(() => {
  return allTools.filter((tool) => tool.enabled).length
})
const plannedToolCount = computed(() => {
  return allTools.filter((tool) => !tool.enabled).length
})

function openTool(path) {
  saveHomeScroll()
  router.push(path)
}

function saveHomeScroll() {
  sessionStorage.setItem(homeScrollStorageKey, String(homePageRef.value.scrollTop))
}

onMounted(() => {
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
