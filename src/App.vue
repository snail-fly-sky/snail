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
      <el-dropdown
        ref="userDropdownRef"
        trigger="hover"
        popper-class="app-user-menu-popper"
        @command="handleUserMenuCommand"
      >
        <button class="app-user-avatar-button" type="button" aria-label="用户菜单" @click.stop="openUserMenu">
          <el-avatar v-if="hasUserAvatar" :size="36" :src="userAvatarDataUrl" />
          <el-avatar v-else :size="36" :src="defaultAvatarUrl" />
        </button>
        <template #dropdown>
          <el-dropdown-menu>
            <el-dropdown-item command="avatar">修改头像</el-dropdown-item>
            <el-dropdown-item v-if="hasUserAvatar" command="clear" divided>清除头像</el-dropdown-item>
          </el-dropdown-menu>
        </template>
      </el-dropdown>
    </div>
  </header>
  <el-dialog
    v-model="avatarDialogVisible"
    class="app-avatar-dialog"
    title="修改头像"
    width="420px"
    align-center
  >
    <div class="app-avatar-editor">
      <el-avatar v-if="avatarDraftDataUrl.length > 0" :size="92" :src="avatarDraftDataUrl" />
      <el-avatar v-else :size="92" :src="defaultAvatarUrl" />
      <el-upload
        class="app-avatar-upload"
        accept="image/*"
        :auto-upload="false"
        :show-file-list="false"
        :on-change="handleAvatarFileChange"
      >
        <el-button type="primary" plain>选择头像</el-button>
      </el-upload>
    </div>
    <template #footer>
      <div class="app-avatar-dialog-actions">
        <el-button plain @click="avatarDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="saveUserAvatar">保存</el-button>
      </div>
    </template>
  </el-dialog>
  <RouterView />
</template>

<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import { RouterLink, RouterView } from 'vue-router'
import { Moon, Sun } from 'lucide-vue-next'

const themeStorageKey = 'snail-theme-mode'
const userAvatarStorageKey = 'snail-user-avatar'
const defaultAvatarUrl = new URL('../static/avatar/avatar.gif', import.meta.url).href
const themeMode = ref('light')
const userAvatarDataUrl = ref('')
const avatarDraftDataUrl = ref('')
const avatarDialogVisible = ref(false)
const userDropdownRef = ref()

const isDarkTheme = computed(() => {
  return themeMode.value === 'dark'
})

const hasUserAvatar = computed(() => {
  return userAvatarDataUrl.value.length > 0
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

function openUserMenu() {
  userDropdownRef.value.handleOpen()
}

function handleUserMenuCommand(command) {
  if (command === 'avatar') {
    openAvatarDialog()
    return
  }

  if (command === 'clear') {
    clearUserAvatar()
  }
}

function openAvatarDialog() {
  avatarDraftDataUrl.value = userAvatarDataUrl.value
  avatarDialogVisible.value = true
}

function handleAvatarFileChange(uploadFile) {
  const reader = new FileReader()
  reader.onload = () => {
    avatarDraftDataUrl.value = reader.result
  }
  reader.readAsDataURL(uploadFile.raw)
}

function saveUserAvatar() {
  userAvatarDataUrl.value = avatarDraftDataUrl.value
  localStorage.setItem(userAvatarStorageKey, avatarDraftDataUrl.value)
  avatarDialogVisible.value = false
}

function clearUserAvatar() {
  userAvatarDataUrl.value = ''
  avatarDraftDataUrl.value = ''
  localStorage.removeItem(userAvatarStorageKey)
}

onMounted(() => {
  const storedTheme = localStorage.getItem(themeStorageKey)
  const storedAvatar = localStorage.getItem(userAvatarStorageKey)

  if (storedTheme === 'dark') {
    themeMode.value = 'dark'
  }

  if (storedTheme === 'light') {
    themeMode.value = 'light'
  }

  if (storedAvatar !== null) {
    userAvatarDataUrl.value = storedAvatar
  }

  applyTheme(themeMode.value)
})

watch(themeMode, (value) => {
  applyTheme(value)
})
</script>

<style scoped>
.app-user-avatar-button {
  width: 42px;
  height: 42px;
  display: grid;
  place-items: center;
  padding: 2px;
  border: 1px solid var(--glass-border);
  border-radius: 999px;
  background:
    linear-gradient(135deg, rgba(255, 255, 255, 0.38), rgba(255, 255, 255, 0.08)),
    var(--glass-bg-strong);
  color: var(--ink);
  box-shadow: var(--glass-inner);
  backdrop-filter: var(--glass-blur);
  -webkit-backdrop-filter: var(--glass-blur);
}

.app-user-avatar-button:hover,
.app-user-avatar-button:focus-visible {
  border-color: rgba(37, 87, 246, 0.28);
  outline: none;
}

.app-user-avatar-button :deep(.el-avatar) {
  background: var(--brand-mark-bg);
  color: var(--brand-mark-fg);
  font-weight: 950;
}

.app-avatar-editor {
  display: grid;
  justify-items: center;
  gap: 18px;
  padding: 8px 0 4px;
}

.app-avatar-editor :deep(.el-avatar) {
  background: var(--brand-mark-bg);
  color: var(--brand-mark-fg);
  font-size: 30px;
  font-weight: 950;
  box-shadow: var(--brand-mark-shadow);
}

.app-avatar-dialog-actions {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}

:global(.app-user-menu-popper.el-popper.is-light) {
  border-color: var(--glass-border);
  background:
    linear-gradient(135deg, rgba(255, 255, 255, 0.36), rgba(255, 255, 255, 0.12)),
    var(--glass-bg-strong);
  box-shadow: var(--glass-shadow), var(--glass-inner);
  backdrop-filter: var(--glass-blur);
  -webkit-backdrop-filter: var(--glass-blur);
}

:global(.app-user-menu-popper.el-popper.is-light > .el-popper__arrow::before) {
  border-color: var(--glass-border);
  background: var(--glass-bg-strong);
}

:global(.app-user-menu-popper .el-dropdown-menu) {
  background: transparent;
}

:global(.app-user-menu-popper .el-dropdown-menu__item) {
  color: var(--ink);
  font-weight: 900;
}

:global(.app-user-menu-popper .el-dropdown-menu__item:not(.is-disabled):hover) {
  background: rgba(37, 87, 246, 0.1);
  color: var(--blue);
}

:global(.app-avatar-dialog.el-dialog) {
  border: 1px solid var(--glass-border);
  border-radius: 8px;
  background:
    linear-gradient(135deg, rgba(255, 255, 255, 0.36), rgba(255, 255, 255, 0.1)),
    var(--glass-bg-strong);
  color: var(--ink);
  box-shadow: var(--glass-shadow), var(--glass-inner);
  backdrop-filter: var(--glass-blur);
  -webkit-backdrop-filter: var(--glass-blur);
}

:global(.app-avatar-dialog .el-dialog__title) {
  color: var(--ink);
  font-weight: 950;
}

:global(.app-avatar-dialog .el-dialog__body) {
  color: var(--ink);
}
</style>
