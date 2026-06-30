<template>
  <main class="tool-page qrcode-page">
    <header class="tool-header">
      <button class="ghost-action" type="button" @click="goHome">
        <ArrowLeft :size="18" />
        首页
      </button>
      <div class="qrcode-title">
        <p class="eyebrow">QR Code Tool</p>
        <h1>二维码工具</h1>
      </div>
      <el-button class="qrcode-header-action" type="primary" @click="copyQrUrl">
        <Copy :size="18" />
        复制图片链接
      </el-button>
    </header>

    <section class="tool-grid qrcode-tool-grid">
      <div class="tool-panel qrcode-input-panel">
        <div class="tool-panel-head">
          <h2>内容</h2>
          <el-button plain @click="loadSample">示例</el-button>
        </div>
        <label class="qrcode-field">
          <span>文本或链接</span>
          <el-input
            v-model="content"
            class="qrcode-textarea"
            type="textarea"
            :rows="8"
            resize="none"
            placeholder="输入需要生成二维码的内容"
          />
        </label>
        <label class="qrcode-field qrcode-size-field">
          <span>尺寸</span>
          <el-slider class="qrcode-size-slider" v-model="size" :min="160" :max="420" :step="20" show-input />
        </label>
        <label class="qrcode-field">
          <span>容错等级</span>
          <el-segmented class="qrcode-ecc-segmented" v-model="ecc" :options="eccOptions" />
        </label>
      </div>

      <div class="tool-panel qrcode-preview-panel">
        <div class="tool-panel-head">
          <h2>预览</h2>
          <a class="ghost-action qrcode-download-link" :href="qrUrl" download="snail-qrcode.png">
            <Download :size="18" />
            下载
          </a>
        </div>
        <div class="qrcode-preview-box" :style="{ '--qr-size': `${size}px` }">
          <span class="qrcode-corner qrcode-corner-top" aria-hidden="true"></span>
          <img :src="qrUrl" alt="二维码预览" />
          <span class="qrcode-corner qrcode-corner-bottom" aria-hidden="true"></span>
        </div>
        <div class="tool-result">
          <span>图片地址</span>
          <strong>{{ qrUrl }}</strong>
        </div>
      </div>
    </section>
  </main>
</template>

<script setup>
import { computed, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { ArrowLeft, Copy, Download } from 'lucide-vue-next'

const router = useRouter()
const content = ref('https://example.com/snail')
const size = ref(260)
const ecc = ref('M')
const eccOptions = [
  { label: '低', value: 'L' },
  { label: '中', value: 'M' },
  { label: '高', value: 'Q' }
]

const qrUrl = computed(() => {
  const encodedContent = encodeURIComponent(content.value)
  return `https://api.qrserver.com/v1/create-qr-code/?size=${size.value}x${size.value}&ecc=${ecc.value}&data=${encodedContent}`
})

async function copyQrUrl() {
  await navigator.clipboard.writeText(qrUrl.value)
  ElMessage.success('已复制图片链接')
}

function loadSample() {
  content.value = 'https://example.com/snail'
  size.value = 260
  ecc.value = 'M'
}

function goHome() {
  router.push('/')
}
</script>

<style scoped>
.qrcode-page {
  --qrcode-accent: #0f766e;
  --qrcode-accent-strong: #2557f6;
  --qrcode-accent-warm: #ff684f;
}

.qrcode-page .tool-header {
  position: relative;
  overflow: hidden;
}

.qrcode-page .tool-header::after {
  content: "";
  position: absolute;
  inset: auto 18px 0 auto;
  width: 168px;
  height: 3px;
  background: linear-gradient(90deg, var(--qrcode-accent), var(--qrcode-accent-warm));
}

.qrcode-title {
  display: grid;
  gap: 4px;
  min-width: 0;
}

.qrcode-header-action {
  min-height: 42px;
}

.qrcode-tool-grid {
  align-items: stretch;
}

.qrcode-input-panel,
.qrcode-preview-panel {
  gap: 18px;
}

.qrcode-input-panel {
  align-content: start;
  grid-template-rows: auto minmax(0, 1fr) auto auto;
  height: 100%;
}

.qrcode-input-panel .qrcode-field:first-of-type {
  grid-template-rows: auto minmax(0, 1fr);
  min-height: 0;
}

.qrcode-textarea {
  min-height: 0;
}

.qrcode-field {
  display: grid;
  gap: 10px;
  padding: 12px;
  border: 1px solid rgba(21, 25, 31, 0.08);
  border-radius: 8px;
  background:
    linear-gradient(135deg, rgba(15, 118, 110, 0.08), transparent 54%),
    rgba(255, 255, 255, 0.46);
}

.qrcode-field > span {
  color: var(--ink);
  font-size: 13px;
  font-weight: 950;
}

.qrcode-textarea :deep(.el-textarea__inner) {
  min-height: 220px;
  font-family: "SFMono-Regular", "SF Mono", Menlo, Monaco, Consolas, monospace;
  font-size: 13px;
  line-height: 1.68;
}

.qrcode-size-slider {
  padding: 2px 4px 0;
}

.qrcode-ecc-segmented {
  width: 100%;
  --el-segmented-bg-color: rgba(255, 255, 255, 0.52);
  --el-segmented-item-hover-bg-color: rgba(37, 87, 246, 0.1);
  --el-segmented-item-hover-color: var(--ink);
  --el-segmented-item-active-bg-color: rgba(15, 118, 110, 0.14);
  --el-segmented-item-selected-bg-color: var(--qrcode-accent-strong);
  --el-segmented-item-selected-color: #ffffff;
  border: 1px solid rgba(21, 25, 31, 0.08);
  border-radius: 8px;
  box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.38);
}

.qrcode-ecc-segmented :deep(.el-segmented__group) {
  width: 100%;
}

.qrcode-ecc-segmented :deep(.el-segmented__item) {
  flex: 1;
  min-height: 34px;
  color: var(--ink);
  font-weight: 900;
  transition:
    color 0.2s ease,
    background-color 0.2s ease;
}

.qrcode-ecc-segmented :deep(.el-segmented__item-selected) {
  box-shadow: 0 10px 24px rgba(37, 87, 246, 0.22);
}

.qrcode-ecc-segmented :deep(.el-segmented__item-selected .el-segmented__item-label) {
  color: #ffffff;
}

.qrcode-ecc-segmented :deep(.el-segmented__item.is-selected),
.qrcode-ecc-segmented :deep(.el-segmented__item.is-selected .el-segmented__item-label) {
  color: #ffffff;
}

:global(:root[data-theme="dark"]) .qrcode-ecc-segmented {
  --el-segmented-bg-color: rgba(15, 23, 42, 0.66);
  --el-segmented-item-hover-bg-color: rgba(116, 167, 255, 0.16);
  --el-segmented-item-hover-color: #e5eefb;
  --el-segmented-item-active-bg-color: rgba(20, 184, 166, 0.18);
  --el-segmented-item-selected-bg-color: #74a7ff;
  --el-segmented-item-selected-color: #07111f;
  border-color: rgba(255, 255, 255, 0.14);
  box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.08);
}

:global(:root[data-theme="dark"]) .qrcode-ecc-segmented :deep(.el-segmented__item) {
  color: #d9e5f6;
}

:global(:root[data-theme="dark"]) .qrcode-ecc-segmented :deep(.el-segmented__item-selected) {
  box-shadow: 0 12px 28px rgba(116, 167, 255, 0.24);
}

:global(:root[data-theme="dark"]) .qrcode-ecc-segmented :deep(.el-segmented__item-selected .el-segmented__item-label) {
  color: #07111f;
}

.qrcode-preview-panel {
  position: sticky;
  top: 18px;
}

.qrcode-preview-box {
  position: relative;
  min-height: 430px;
  overflow: hidden;
  background:
    linear-gradient(90deg, rgba(37, 87, 246, 0.08) 1px, transparent 1px),
    linear-gradient(rgba(15, 118, 110, 0.1) 1px, transparent 1px),
    linear-gradient(135deg, rgba(255, 104, 79, 0.1), rgba(255, 255, 255, 0.72) 46%, rgba(15, 118, 110, 0.12));
  background-size: 26px 26px, 26px 26px, 100% 100%;
}

.qrcode-preview-box img {
  position: relative;
  z-index: 1;
  width: min(100%, var(--qr-size));
  max-width: 420px;
}

.qrcode-corner {
  position: absolute;
  width: 72px;
  height: 72px;
  border-color: var(--qrcode-accent);
  opacity: 0.82;
}

.qrcode-corner-top {
  top: 18px;
  left: 18px;
  border-top: 3px solid;
  border-left: 3px solid;
}

.qrcode-corner-bottom {
  right: 18px;
  bottom: 18px;
  border-right: 3px solid;
  border-bottom: 3px solid;
}

.qrcode-preview-panel .tool-result {
  min-height: auto;
}

.qrcode-preview-panel .tool-result strong {
  font-family: "SFMono-Regular", "SF Mono", Menlo, Monaco, Consolas, monospace;
  font-size: 13px;
  line-height: 1.55;
}

@media (max-width: 1180px) {
  .qrcode-preview-panel {
    position: static;
  }
}

@media (max-width: 760px) {
  .qrcode-page .tool-header::after {
    inset: auto 14px 0 14px;
    width: auto;
  }

  .qrcode-preview-box {
    min-height: 320px;
    padding: 18px;
  }

  .qrcode-field {
    padding: 10px;
  }
}
</style>
