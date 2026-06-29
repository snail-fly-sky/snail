<template>
  <header class="app-topbar">
    <div class="app-topbar-brand">
      <span class="app-topbar-logo">S</span>
      <div>
        <strong>Snail Tools</strong>
        <small>前端工具箱</small>
      </div>
    </div>
    <div class="app-topbar-actions">
      <nav class="app-topbar-menu" aria-label="顶部菜单">
        <RouterLink to="/">首页</RouterLink>
        <RouterLink to="/ResumeWorkbench">简历</RouterLink>
        <RouterLink to="/JsonToolPage">JSON</RouterLink>
        <RouterLink to="/TimeToolPage">时间</RouterLink>
        <RouterLink to="/ColorToolPage">颜色</RouterLink>
        <RouterLink to="/QrCodeToolPage">二维码</RouterLink>
        <RouterLink to="/FrontendProcessToolPage">前端工具</RouterLink>
        <RouterLink to="/OffworkCountdownPage">下班倒计时</RouterLink>
      </nav>
      <button class="theme-toggle" type="button" :aria-label="themeLabel" @click="toggleTheme">
        <component :is="themeIcon" :size="18" />
        <span>{{ themeLabel }}</span>
      </button>
    </div>
  </header>
  <RouterView />
</template>

<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import { RouterLink, RouterView } from 'vue-router'
import { Moon, Sun } from 'lucide-vue-next'

const themeStorageKey = 'snail-theme-mode'
const themeMode = ref('light')

const isDarkTheme = computed(() => {
  return themeMode.value === 'dark'
})

const themeLabel = computed(() => {
  if (isDarkTheme.value) {
    return '白天'
  }

  return '夜间'
})

const themeIcon = computed(() => {
  if (isDarkTheme.value) {
    return Sun
  }

  return Moon
})

function applyTheme(value) {
  document.documentElement.dataset.theme = value
  localStorage.setItem(themeStorageKey, value)
}

function toggleTheme() {
  if (isDarkTheme.value) {
    themeMode.value = 'light'
    return
  }

  themeMode.value = 'dark'
}

onMounted(() => {
  const storedTheme = localStorage.getItem(themeStorageKey)

  if (storedTheme === 'dark') {
    themeMode.value = 'dark'
  }

  if (storedTheme === 'light') {
    themeMode.value = 'light'
  }

  applyTheme(themeMode.value)
})

watch(themeMode, (value) => {
  applyTheme(value)
})
</script>
