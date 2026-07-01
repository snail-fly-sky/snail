<template>
  <main class="tool-page qrcode-page">
    <header class="tool-header qrcode-header">
      <button class="ghost-action" type="button" @click="goHome">
        <ArrowLeft :size="18" />
        首页
      </button>
      <div class="qrcode-title">
        <p class="eyebrow">QR Code Studio</p>
        <h1>二维码工具</h1>
      </div>
      <div class="qrcode-header-actions">
        <el-button plain @click="saveCurrentHistory">
          <Star :size="18" />
          保存
        </el-button>
        <el-button class="glass-button-blue" plain @click="historyDialogVisible = true">
          <History :size="18" />
          历史记录
        </el-button>
        <el-button type="primary" @click="copyImage">
          <Copy :size="18" />
          复制图片
        </el-button>
      </div>
    </header>

    <section class="qrcode-shell">
      <div class="tool-panel qrcode-input-panel">
        <div class="tool-panel-head">
          <h2>内容</h2>
          <div class="qrcode-panel-actions">
            <el-button class="glass-button-blue" plain @click="loadSample">示例</el-button>
            <el-upload
              accept="image/*"
              :auto-upload="false"
              :show-file-list="false"
              :on-change="handleLogoChange"
            >
              <el-button class="glass-button-teal" plain>
                <ImagePlus :size="18" />
                上传 Logo
              </el-button>
            </el-upload>
            <el-button v-if="logoDataUrl.length > 0" class="glass-button-amber" plain @click="clearLogo">
              清除 Logo
            </el-button>
            <el-button class="glass-button-coral" plain @click="resetStyle">重置样式</el-button>
          </div>
        </div>
        <el-segmented class="qrcode-type-tabs" v-model="contentType" :options="contentTypeOptions" block />

        <div v-if="contentType === 'text' || contentType === 'url'" class="qrcode-form-grid">
          <label class="qrcode-field qrcode-field-full">
            <span>{{ contentType === 'url' ? '链接' : '文本' }}</span>
            <el-input
              v-model="content"
              class="qrcode-textarea"
              type="textarea"
              :rows="7"
              resize="none"
              :placeholder="contentType === 'url' ? 'https://example.com' : '输入要写入二维码的文本'"
            />
          </label>
        </div>

        <div v-if="contentType === 'wifi'" class="qrcode-form-grid">
          <label class="qrcode-field">
            <span>WiFi 名称</span>
            <el-input v-model="wifiSsid" placeholder="SSID" />
          </label>
          <label class="qrcode-field">
            <span>密码</span>
            <el-input v-model="wifiPassword" show-password placeholder="WiFi 密码" />
          </label>
          <label class="qrcode-field">
            <span>加密方式</span>
            <el-segmented class="qrcode-ecc-segmented" v-model="wifiEncryption" :options="wifiEncryptionOptions" />
          </label>
          <label class="qrcode-check-field">
            <el-checkbox v-model="wifiHidden">隐藏网络</el-checkbox>
          </label>
        </div>

        <div v-if="contentType === 'phone'" class="qrcode-form-grid">
          <label class="qrcode-field qrcode-field-full">
            <span>电话号码</span>
            <el-input v-model="phoneNumber" placeholder="13800000000" />
          </label>
        </div>

        <div v-if="contentType === 'sms'" class="qrcode-form-grid">
          <label class="qrcode-field">
            <span>手机号</span>
            <el-input v-model="smsNumber" placeholder="13800000000" />
          </label>
          <label class="qrcode-field qrcode-field-full">
            <span>短信内容</span>
            <el-input v-model="smsBody" type="textarea" :rows="4" resize="none" placeholder="短信内容" />
          </label>
        </div>

        <div class="qrcode-style-grid">
          <label class="qrcode-field">
            <span>尺寸</span>
            <el-slider v-model="size" :min="180" :max="560" :step="20" show-input />
          </label>
          <label class="qrcode-field">
            <span>容错等级</span>
            <el-segmented class="qrcode-type-tabs qrcode-ecc-tabs" v-model="ecc" :options="eccOptions" block />
          </label>
          <label class="qrcode-field">
            <span>前景色</span>
            <el-color-picker v-model="foregroundColor" show-alpha />
          </label>
          <label class="qrcode-field">
            <span>背景色</span>
            <el-color-picker v-model="backgroundColor" show-alpha />
          </label>
          <label class="qrcode-field">
            <span>留白</span>
            <el-slider v-model="margin" :min="1" :max="8" :step="1" show-input />
          </label>
          <label class="qrcode-field">
            <span>圆角</span>
            <el-slider v-model="dotRadius" :min="0" :max="0.45" :step="0.05" show-input />
          </label>
        </div>
      </div>

      <div class="tool-panel qrcode-preview-panel">
        <div class="tool-panel-head">
          <h2>预览</h2>
          <span class="qrcode-version">V{{ qrMeta.version }} · {{ qrMeta.byteLength }} bytes</span>
        </div>
        <div class="qrcode-preview-box" :style="{ '--qr-size': `${size}px` }">
          <el-empty v-if="qrError.length > 0" :description="qrError" :image-size="72" />
          <img v-else :src="qrUrl" alt="二维码预览" />
        </div>
        <div class="qrcode-action-grid">
          <el-button type="primary" plain @click="copyImage">
            <Copy :size="17" />
            复制图片
          </el-button>
          <el-button plain @click="copyPayload">
            <Copy :size="17" />
            复制内容
          </el-button>
          <el-button plain @click="downloadSvg">
            <Download :size="17" />
            SVG
          </el-button>
          <el-button plain @click="downloadRaster('png')">
            <Download :size="17" />
            PNG
          </el-button>
          <el-button plain @click="downloadRaster('webp')">
            <Download :size="17" />
            WebP
          </el-button>
        </div>
        <div class="qrcode-info-card">
          <span>二维码内容</span>
          <strong>{{ payload }}</strong>
        </div>
      </div>

      <aside class="qrcode-side">
        <section class="tool-panel qrcode-side-card">
          <div class="tool-panel-head">
            <h2>识别二维码</h2>
          </div>
          <el-upload
            class="qrcode-scan-upload"
            drag
            accept="image/*"
            :auto-upload="false"
            :show-file-list="false"
            :on-change="handleDecodeFileChange"
          >
            <UploadCloud :size="28" />
            <span>拖入或选择图片</span>
          </el-upload>
          <div v-if="decodedText.length > 0" class="qrcode-info-card">
            <span>识别结果</span>
            <strong>{{ decodedText }}</strong>
          </div>
          <el-empty v-else class="qrcode-empty" description="还没有识别结果" :image-size="54" />
        </section>

        <section class="tool-panel qrcode-side-card">
          <div class="tool-panel-head">
            <h2>安全提示</h2>
            <ShieldCheck :size="18" />
          </div>
          <div class="qrcode-security-card" :class="securityInfo.level">
            <strong>{{ securityInfo.title }}</strong>
            <p>{{ securityInfo.description }}</p>
          </div>
        </section>
      </aside>
    </section>

    <el-dialog
      v-model="historyDialogVisible"
      class="qrcode-history-dialog"
      title="历史记录"
      width="min(520px, calc(100vw - 28px))"
      align-center
    >
      <div class="qrcode-history-dialog-head">
        <span>{{ historyItems.length }} 条保存内容</span>
        <el-button v-if="historyItems.length > 0" type="danger" plain @click="clearHistory">
          <Trash2 :size="17" />
          清空
        </el-button>
      </div>
      <div v-if="historyItems.length > 0" class="qrcode-history-list qrcode-history-dialog-list">
        <button
          v-for="item in historyItems"
          :key="item.id"
          type="button"
          @click="restoreHistory(item)"
        >
          <span>{{ item.type }}</span>
          <strong>{{ item.label }}</strong>
          <small>{{ item.createdAt }}</small>
        </button>
      </div>
      <el-empty v-else class="qrcode-empty" description="保存后会出现在这里" :image-size="64" />
    </el-dialog>
  </main>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import jsQR from 'jsqr'
import {
  ArrowLeft,
  Copy,
  Download,
  History,
  ImagePlus,
  ShieldCheck,
  Star,
  Trash2,
  UploadCloud
} from 'lucide-vue-next'
import { createQrCodeSvgDataUrl } from '../../utils/qrCodeGenerator'

const router = useRouter()
const historyStorageKey = 'snail-qrcode-history'
const contentType = ref('url')
const content = ref('https://example.com/snail')
const size = ref(260)
const ecc = ref('M')
const foregroundColor = ref('#111827')
const backgroundColor = ref('#ffffff')
const margin = ref(4)
const dotRadius = ref(0)
const logoDataUrl = ref('')
const wifiSsid = ref('Snail WiFi')
const wifiPassword = ref('snail-tools')
const wifiEncryption = ref('WPA')
const wifiHidden = ref(false)
const phoneNumber = ref('13800000000')
const smsNumber = ref('13800000000')
const smsBody = ref('你好，这是一条二维码短信。')
const decodedText = ref('')
const historyItems = ref([])
const historyDialogVisible = ref(false)

const contentTypeOptions = [
  { label: '链接', value: 'url' },
  { label: '文本', value: 'text' },
  { label: 'WiFi', value: 'wifi' },
  { label: '电话', value: 'phone' },
  { label: '短信', value: 'sms' }
]

const eccOptions = [
  { label: '低', value: 'L' },
  { label: '中', value: 'M' },
  { label: '高', value: 'Q' },
  { label: '最高', value: 'H' }
]

const wifiEncryptionOptions = [
  { label: 'WPA/WPA2', value: 'WPA' },
  { label: 'WEP', value: 'WEP' },
  { label: '无密码', value: 'nopass' }
]

const payload = computed(() => {
  if (contentType.value === 'wifi') {
    return createWifiPayload()
  }

  if (contentType.value === 'phone') {
    return `tel:${phoneNumber.value}`
  }

  if (contentType.value === 'sms') {
    return `SMSTO:${smsNumber.value}:${smsBody.value}`
  }

  return content.value
})

const qrResult = computed(() => {
  try {
    const result = createQrCodeSvgDataUrl(payload.value, {
      ecc: ecc.value,
      foregroundColor: foregroundColor.value,
      backgroundColor: backgroundColor.value,
      margin: margin.value,
      dotRadius: dotRadius.value
    })

    return {
      ...result,
      svg: injectLogo(result.svg, result.moduleCount),
      error: ''
    }
  } catch (error) {
    return {
      dataUrl: '',
      svg: '',
      version: '-',
      byteLength: new TextEncoder().encode(payload.value).length,
      moduleCount: 0,
      error: error.message
    }
  }
})

const qrUrl = computed(() => {
  if (qrResult.value.error.length > 0) {
    return ''
  }

  return `data:image/svg+xml;charset=utf-8,${encodeURIComponent(qrResult.value.svg)}`
})

const qrError = computed(() => {
  return qrResult.value.error
})

const qrMeta = computed(() => {
  return {
    version: qrResult.value.version,
    byteLength: qrResult.value.byteLength
  }
})

const securityInfo = computed(() => {
  if (contentType.value !== 'url') {
    return {
      level: 'neutral',
      title: '非链接内容',
      description: '当前二维码不是网页链接，扫码后会按设备默认方式处理。'
    }
  }

  try {
    const url = new URL(payload.value)
    if (url.protocol !== 'https:') {
      return {
        level: 'warning',
        title: '建议使用 HTTPS',
        description: `当前协议是 ${url.protocol}，分享前建议确认链接来源。`
      }
    }

    return {
      level: 'safe',
      title: '链接格式正常',
      description: `目标域名：${url.hostname}`
    }
  } catch (error) {
    return {
      level: 'danger',
      title: '链接格式异常',
      description: '请输入完整链接，例如 https://example.com。'
    }
  }
})

function createWifiPayload() {
  return [
    'WIFI:',
    `T:${escapeWifiValue(wifiEncryption.value)};`,
    `S:${escapeWifiValue(wifiSsid.value)};`,
    `P:${escapeWifiValue(wifiPassword.value)};`,
    `H:${wifiHidden.value ? 'true' : 'false'};`,
    ';'
  ].join('')
}

function escapeWifiValue(value) {
  return String(value).replace(/[\\;,":]/g, '\\$&')
}

function injectLogo(svg, moduleCount) {
  if (logoDataUrl.value.length === 0) {
    return svg
  }

  const viewSize = moduleCount + margin.value * 2
  const logoSize = viewSize * 0.2
  const logoOffset = (viewSize - logoSize) / 2
  const safeLogo = logoDataUrl.value.replace(/"/g, '&quot;')
  const logoMarkup = [
    `<rect x="${logoOffset - 1}" y="${logoOffset - 1}" width="${logoSize + 2}" height="${logoSize + 2}" rx="2" fill="${backgroundColor.value}"/>`,
    `<image href="${safeLogo}" x="${logoOffset}" y="${logoOffset}" width="${logoSize}" height="${logoSize}" preserveAspectRatio="xMidYMid meet"/>`
  ].join('')
  return svg.replace('</svg>', `${logoMarkup}</svg>`)
}

async function copyImage() {
  if (!('ClipboardItem' in window)) {
    ElMessage.warning('当前浏览器不支持复制图片，请使用下载')
    return
  }

  try {
    const blob = await createRasterBlob('png')
    await navigator.clipboard.write([new ClipboardItem({ 'image/png': blob })])
    saveCurrentHistory()
    ElMessage.success('已复制二维码图片')
  } catch (error) {
    ElMessage.error(error.message)
  }
}

async function copyPayload() {
  await navigator.clipboard.writeText(payload.value)
  ElMessage.success('已复制二维码内容')
}

function downloadSvg() {
  if (qrError.value.length > 0) {
    ElMessage.warning(qrError.value)
    return
  }

  const blob = new Blob([qrResult.value.svg], { type: 'image/svg+xml;charset=utf-8' })
  downloadBlob(blob, 'snail-qrcode.svg')
  saveCurrentHistory()
}

async function downloadRaster(format) {
  try {
    const blob = await createRasterBlob(format)
    downloadBlob(blob, `snail-qrcode.${format}`)
    saveCurrentHistory()
  } catch (error) {
    ElMessage.error(error.message)
  }
}

async function createRasterBlob(format) {
  if (qrError.value.length > 0) {
    throw new Error(qrError.value)
  }

  const image = await loadSvgImage(qrResult.value.svg)
  const canvas = document.createElement('canvas')
  canvas.width = size.value
  canvas.height = size.value
  const context = canvas.getContext('2d')
  context.drawImage(image, 0, 0, size.value, size.value)
  const mimeType = format === 'webp' ? 'image/webp' : 'image/png'
  return await new Promise((resolve) => {
    canvas.toBlob((blob) => {
      resolve(blob)
    }, mimeType, 0.92)
  })
}

function loadSvgImage(svg) {
  return new Promise((resolve, reject) => {
    const blob = new Blob([svg], { type: 'image/svg+xml;charset=utf-8' })
    const objectUrl = URL.createObjectURL(blob)
    const image = new Image()
    image.onload = () => {
      URL.revokeObjectURL(objectUrl)
      resolve(image)
    }
    image.onerror = () => {
      URL.revokeObjectURL(objectUrl)
      reject(new Error('二维码图片加载失败'))
    }
    image.src = objectUrl
  })
}

function downloadBlob(blob, filename) {
  const objectUrl = URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = objectUrl
  link.download = filename
  link.click()
  URL.revokeObjectURL(objectUrl)
}

function saveCurrentHistory() {
  if (qrError.value.length > 0) {
    ElMessage.warning(qrError.value)
    return
  }

  const item = {
    id: `${Date.now()}`,
    type: getContentTypeLabel(),
    label: createHistoryLabel(),
    contentType: contentType.value,
    payload: payload.value,
    createdAt: new Date().toLocaleString('zh-CN', { hour12: false })
  }
  historyItems.value = [item, ...historyItems.value.filter((historyItem) => historyItem.payload !== item.payload)].slice(0, 12)
  writeHistory()
  ElMessage.success('已保存到历史记录')
}

function restoreHistory(item) {
  contentType.value = 'text'
  content.value = item.payload
  historyDialogVisible.value = false
  ElMessage.success('已恢复历史内容')
}

function clearHistory() {
  historyItems.value = []
  localStorage.removeItem(historyStorageKey)
}

function getContentTypeLabel() {
  const option = contentTypeOptions.find((item) => item.value === contentType.value)
  return option.label
}

function createHistoryLabel() {
  const value = payload.value.trim()
  if (value.length <= 28) {
    return value
  }

  return `${value.slice(0, 28)}...`
}

function writeHistory() {
  localStorage.setItem(historyStorageKey, JSON.stringify(historyItems.value))
}

function readHistory() {
  const storedValue = localStorage.getItem(historyStorageKey)
  if (storedValue === null) {
    historyItems.value = []
    return
  }

  try {
    const parsedValue = JSON.parse(storedValue)
    if (Array.isArray(parsedValue)) {
      historyItems.value = parsedValue
      return
    }
    historyItems.value = []
  } catch (error) {
    historyItems.value = []
  }
}

function handleLogoChange(uploadFile) {
  const reader = new FileReader()
  reader.onload = () => {
    logoDataUrl.value = reader.result
  }
  reader.readAsDataURL(uploadFile.raw)
}

function clearLogo() {
  logoDataUrl.value = ''
}

async function handleDecodeFileChange(uploadFile) {
  try {
    const image = await loadDecodeImage(uploadFile.raw)
    const result = await decodeQrImage(image)
    if (result.length === 0) {
      decodedText.value = ''
      ElMessage.warning('没有识别到二维码')
      return
    }

    decodedText.value = result
    ElMessage.success('识别完成')
  } catch (error) {
    decodedText.value = ''
    ElMessage.error(error.message)
  }
}

function loadDecodeImage(file) {
  return new Promise((resolve, reject) => {
    const objectUrl = URL.createObjectURL(file)
    const image = new Image()
    image.onload = () => {
      URL.revokeObjectURL(objectUrl)
      resolve(image)
    }
    image.onerror = () => {
      URL.revokeObjectURL(objectUrl)
      reject(new Error('二维码图片加载失败'))
    }
    image.src = objectUrl
  })
}

async function decodeQrImage(image) {
  const nativeResult = await decodeQrWithBarcodeDetector(image)
  if (nativeResult.length > 0) {
    return nativeResult
  }

  return decodeQrWithJsQr(image)
}

async function decodeQrWithBarcodeDetector(image) {
  if (!('BarcodeDetector' in window)) {
    return ''
  }

  try {
    const detector = new BarcodeDetector({ formats: ['qr_code'] })
    const results = await detector.detect(image)
    if (results.length > 0) {
      return results[0].rawValue
    }
  } catch (error) {
    return ''
  }

  return ''
}

function decodeQrWithJsQr(image) {
  const canvas = document.createElement('canvas')
  canvas.width = image.naturalWidth
  canvas.height = image.naturalHeight
  const context = canvas.getContext('2d')
  context.drawImage(image, 0, 0)
  const imageData = context.getImageData(0, 0, canvas.width, canvas.height)
  const result = jsQR(imageData.data, imageData.width, imageData.height)
  if (result === null) {
    return ''
  }

  return result.data
}

function loadSample() {
  contentType.value = 'url'
  content.value = 'https://example.com/snail'
  wifiSsid.value = 'Snail WiFi'
  wifiPassword.value = 'snail-tools'
  size.value = 260
  ecc.value = 'M'
}

function resetStyle() {
  size.value = 260
  ecc.value = 'M'
  foregroundColor.value = '#111827'
  backgroundColor.value = '#ffffff'
  margin.value = 4
  dotRadius.value = 0
  logoDataUrl.value = ''
}

function goHome() {
  router.push('/')
}

onMounted(() => {
  readHistory()
})
</script>

<style scoped>
.qrcode-page {
  --qrcode-accent: #0f766e;
  --qrcode-accent-strong: #2557f6;
  --qrcode-accent-warm: #ff684f;
  display: flex;
  flex-direction: column;
}

.qrcode-page .tool-header {
  flex: 0 0 auto;
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

.qrcode-input-panel,
.qrcode-preview-panel {
  gap: 18px;
  height: 100%;
  min-height: 0;
}

.qrcode-input-panel {
  align-content: start;
  overflow: auto;
}

.qrcode-textarea {
  min-height: 0;
}

.qrcode-field {
  position: relative;
  isolation: isolate;
  display: grid;
  gap: 10px;
  padding: 12px;
  border: 1px solid rgba(120, 138, 168, 0.24);
  border-radius: 8px;
  background:
    linear-gradient(145deg, rgba(255, 255, 255, 0.42), rgba(255, 255, 255, 0.12)),
    rgba(255, 255, 255, 0.32);
  box-shadow:
    0 12px 30px rgba(31, 41, 55, 0.06),
    inset 0 1px 0 rgba(255, 255, 255, 0.72),
    inset 0 0 0 1px rgba(255, 255, 255, 0.28);
  backdrop-filter: blur(24px) saturate(1.28);
  -webkit-backdrop-filter: blur(24px) saturate(1.28);
  overflow: hidden;
}

.qrcode-field::before {
  position: absolute;
  inset: 0;
  z-index: 0;
  background:
    radial-gradient(circle at 16% 0%, rgba(255, 255, 255, 0.56), transparent 42%),
    linear-gradient(180deg, rgba(255, 255, 255, 0.18), transparent 62%);
  content: "";
  pointer-events: none;
}

.qrcode-field > span {
  position: relative;
  z-index: 1;
  color: var(--ink);
  font-size: 13px;
  font-weight: 950;
}

.qrcode-field > :not(span) {
  position: relative;
  z-index: 1;
}

.qrcode-field :deep(.el-input__wrapper),
.qrcode-field :deep(.el-textarea__inner),
.qrcode-field :deep(.el-select__wrapper) {
  background:
    linear-gradient(145deg, rgba(255, 255, 255, 0.34), rgba(255, 255, 255, 0.08)),
    rgba(255, 255, 255, 0.22) !important;
}

.qrcode-field :deep(.el-input__wrapper.is-focus),
.qrcode-field :deep(.el-input.is-focus .el-input__wrapper),
.qrcode-field :deep(.el-textarea__inner:focus),
.qrcode-field :deep(.el-textarea__inner:focus-visible),
.qrcode-field :deep(.el-select__wrapper.is-focused) {
  background:
    linear-gradient(145deg, rgba(255, 255, 255, 0.34), rgba(255, 255, 255, 0.08)),
    rgba(255, 255, 255, 0.22) !important;
}

.qrcode-textarea :deep(.el-textarea__inner) {
  min-height: 220px;
  font-family: "SFMono-Regular", "SF Mono", Menlo, Monaco, Consolas, monospace;
  font-size: 13px;
  line-height: 1.68;
}

.qrcode-ecc-segmented {
  width: 100%;
  --el-segmented-bg-color: var(--glass-bg);
  --el-segmented-item-hover-bg-color: rgba(37, 87, 246, 0.1);
  --el-segmented-item-hover-color: var(--ink);
  --el-segmented-item-active-bg-color: rgba(15, 118, 110, 0.14);
  --el-segmented-item-selected-bg-color: var(--glass-bg-strong);
  --el-segmented-item-selected-color: var(--ink);
  border: 1px solid var(--glass-border);
  border-radius: 8px;
  box-shadow: var(--glass-inner);
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
  border-radius: 8px !important;
  overflow: hidden;
  box-shadow:
    0 8px 18px rgba(31, 41, 55, 0.08),
    var(--glass-inner);
}

.qrcode-ecc-segmented :deep(.el-segmented__item-selected .el-segmented__item-label) {
  color: var(--ink) !important;
}

.qrcode-ecc-segmented :deep(.el-segmented__item.is-selected),
.qrcode-ecc-segmented :deep(.el-segmented__item.is-selected .el-segmented__item-label) {
  color: var(--ink) !important;
}

:global(:root[data-theme="dark"]) .qrcode-ecc-segmented {
  --el-segmented-bg-color: rgba(15, 23, 42, 0.66);
  --el-segmented-item-hover-bg-color: rgba(116, 167, 255, 0.16);
  --el-segmented-item-hover-color: #e5eefb;
  --el-segmented-item-active-bg-color: rgba(20, 184, 166, 0.18);
  --el-segmented-item-selected-bg-color: var(--glass-bg-strong);
  --el-segmented-item-selected-color: #ffffff;
  border-color: rgba(255, 255, 255, 0.14);
  box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.08);
}

:global(:root[data-theme="dark"]) .qrcode-ecc-segmented :deep(.el-segmented__item) {
  color: #d9e5f6;
}

:global(:root[data-theme="dark"]) .qrcode-ecc-segmented :deep(.el-segmented__item-selected) {
  box-shadow:
    0 12px 28px rgba(0, 0, 0, 0.24),
    var(--glass-inner);
}

:global(:root[data-theme="dark"]) .qrcode-ecc-segmented :deep(.el-segmented__item-selected .el-segmented__item-label),
:global(:root[data-theme="dark"]) .qrcode-ecc-segmented :deep(.el-segmented__item.is-selected),
:global(:root[data-theme="dark"]) .qrcode-ecc-segmented :deep(.el-segmented__item.is-selected .el-segmented__item-label) {
  color: #ffffff !important;
}

.qrcode-preview-panel {
  position: sticky;
  top: 18px;
  overflow: auto;
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

.qrcode-header {
  gap: 16px;
}

.qrcode-header-actions {
  display: inline-flex;
  align-items: center;
  gap: 10px;
}

.qrcode-shell {
  flex: 1 1 auto;
  display: grid;
  grid-template-columns: minmax(320px, 1.05fr) minmax(360px, 0.9fr) minmax(280px, 0.68fr);
  gap: 14px;
  align-items: stretch;
  min-height: 0;
}

.qrcode-card,
.qrcode-input-panel,
.qrcode-side-card,
.qrcode-preview-panel {
  border-radius: 18px;
}

.qrcode-input-panel {
  grid-template-rows: none;
}

.qrcode-form-grid,
.qrcode-style-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 10px;
}

.qrcode-field-full {
  grid-column: 1 / -1;
}

.qrcode-type-tabs {
  --qrcode-type-count: 5;
  --el-segmented-bg-color: #eaf1ff;
  --el-segmented-item-hover-bg-color: #dbe8ff;
  --el-segmented-item-hover-color: var(--blue);
  --el-segmented-item-active-bg-color: #cfddff;
  --el-segmented-item-selected-bg-color: var(--blue);
  --el-segmented-item-selected-color: #ffffff;
  border: 1px solid rgba(37, 87, 246, 0.18);
  border-radius: 999px;
  width: 100%;
  max-width: 100%;
  height: 44px;
  min-height: 44px;
  display: flex !important;
  flex: 0 0 auto;
  align-self: stretch;
  box-sizing: border-box;
  line-height: 1;
  background: #eaf1ff !important;
  padding: 4px;
  box-shadow:
    inset 0 0 0 1px rgba(255, 255, 255, 0.7),
    0 10px 24px rgba(37, 87, 246, 0.1);
  overflow: hidden;
}

.qrcode-type-tabs :deep(.el-segmented__group) {
  width: 100%;
  height: 100%;
  min-width: 0;
  display: flex;
  position: relative;
  overflow: hidden;
}

.qrcode-type-tabs :deep(.el-segmented__item) {
  flex: 1 1 0;
  min-width: 0;
  height: 100%;
  min-height: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 999px;
  color: #1f4ed8;
  font-weight: 900;
  overflow: hidden;
  position: relative;
  z-index: 1;
  transition:
    background-color 160ms ease,
    color 160ms ease;
}

.qrcode-type-tabs :deep(.el-segmented__item-selected) {
  width: calc(100% / var(--qrcode-type-count)) !important;
  min-width: 0 !important;
  height: 100% !important;
  top: 0 !important;
  border-radius: 999px !important;
  background: var(--blue) !important;
  box-shadow:
    inset 0 1px 0 rgba(255, 255, 255, 0.26),
    0 8px 16px rgba(37, 87, 246, 0.18);
  transition:
    transform 220ms cubic-bezier(0.2, 0.8, 0.2, 1),
    width 220ms cubic-bezier(0.2, 0.8, 0.2, 1),
    background-color 160ms ease,
    box-shadow 160ms ease;
}

.qrcode-type-tabs :deep(.el-segmented__item-selected .el-segmented__item-label),
.qrcode-type-tabs :deep(.el-segmented__item.is-selected),
.qrcode-type-tabs :deep(.el-segmented__item.is-selected .el-segmented__item-label) {
  color: #ffffff !important;
}

.qrcode-ecc-tabs {
  --qrcode-type-count: 4;
}

.qrcode-check-field {
  min-height: 66px;
  display: flex;
  align-items: center;
  padding: 12px;
  border: 1px solid rgba(120, 138, 168, 0.22);
  border-radius: 14px;
  background:
    linear-gradient(145deg, rgba(255, 255, 255, 0.36), rgba(255, 255, 255, 0.1)),
    rgba(255, 255, 255, 0.28);
  box-shadow:
    0 10px 24px rgba(31, 41, 55, 0.05),
    inset 0 1px 0 rgba(255, 255, 255, 0.64);
  backdrop-filter: blur(22px) saturate(1.22);
  -webkit-backdrop-filter: blur(22px) saturate(1.22);
}

.qrcode-panel-actions,
.qrcode-action-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.qrcode-action-grid .el-button + .el-button,
.qrcode-panel-actions .el-button + .el-button {
  margin-left: 0;
}

.qrcode-panel-actions {
  align-items: center;
  justify-content: flex-end;
}

.qrcode-panel-actions :deep(.el-upload) {
  display: inline-flex;
}

.qrcode-version {
  min-height: 28px;
  display: inline-flex;
  align-items: center;
  padding: 0 10px;
  border-radius: 999px;
  background: rgba(37, 87, 246, 0.1);
  color: var(--blue);
  font-size: 12px;
  font-weight: 900;
}

.qrcode-preview-box {
  min-height: 390px;
  display: grid;
  place-items: center;
  padding: 20px;
  border: 0;
  border-radius: 22px;
  box-shadow:
    0 18px 44px rgba(31, 41, 55, 0.08),
    inset 0 1px 0 rgba(255, 255, 255, 0.62);
}

.qrcode-preview-box img {
  width: min(100%, var(--qr-size));
  max-width: 560px;
  border-radius: 18px;
  box-shadow: 0 20px 56px rgba(31, 41, 55, 0.14);
}

.qrcode-info-card,
.qrcode-security-card {
  display: grid;
  gap: 8px;
  padding: 14px;
  border: 1px solid rgba(120, 138, 168, 0.22);
  border-radius: 16px;
  background:
    linear-gradient(145deg, rgba(255, 255, 255, 0.36), rgba(255, 255, 255, 0.1)),
    rgba(255, 255, 255, 0.28);
  box-shadow:
    0 10px 24px rgba(31, 41, 55, 0.05),
    inset 0 1px 0 rgba(255, 255, 255, 0.64);
  backdrop-filter: blur(22px) saturate(1.22);
  -webkit-backdrop-filter: blur(22px) saturate(1.22);
}

.qrcode-info-card span {
  color: var(--muted);
  font-size: 12px;
  font-weight: 900;
}

.qrcode-info-card strong {
  max-height: 118px;
  overflow: auto;
  color: var(--ink);
  font-size: 13px;
  line-height: 1.58;
  word-break: break-word;
}

.qrcode-security-card strong {
  color: var(--ink);
  font-size: 14px;
  font-weight: 950;
}

.qrcode-security-card p {
  margin: 0;
  color: var(--muted);
  font-size: 13px;
  line-height: 1.6;
}

.qrcode-security-card.safe {
  border-color: rgba(22, 163, 74, 0.2);
  background:
    linear-gradient(135deg, rgba(22, 163, 74, 0.12), rgba(255, 255, 255, 0.08)),
    rgba(255, 255, 255, 0.26);
}

.qrcode-security-card.warning {
  border-color: rgba(245, 158, 11, 0.24);
  background:
    linear-gradient(135deg, rgba(245, 158, 11, 0.14), rgba(255, 255, 255, 0.08)),
    rgba(255, 255, 255, 0.26);
}

.qrcode-security-card.danger {
  border-color: rgba(225, 29, 72, 0.22);
  background:
    linear-gradient(135deg, rgba(225, 29, 72, 0.12), rgba(255, 255, 255, 0.08)),
    rgba(255, 255, 255, 0.26);
}

.qrcode-side {
  display: grid;
  grid-template-rows: minmax(0, 1fr) auto;
  gap: 14px;
  height: 100%;
  min-height: 0;
}

.qrcode-side-card {
  min-height: 0;
  align-content: start;
}

.qrcode-side-card:first-child {
  overflow: auto;
}

.qrcode-scan-upload :deep(.el-upload-dragger) {
  display: grid;
  place-items: center;
  gap: 8px;
  min-height: 126px;
  border: 1px dashed rgba(37, 87, 246, 0.28);
  border-radius: 18px;
  background:
    linear-gradient(145deg, rgba(255, 255, 255, 0.34), rgba(255, 255, 255, 0.1)),
    rgba(255, 255, 255, 0.26);
  color: var(--blue);
  font-weight: 900;
  box-shadow:
    0 10px 24px rgba(31, 41, 55, 0.05),
    inset 0 1px 0 rgba(255, 255, 255, 0.64);
  backdrop-filter: blur(22px) saturate(1.22);
  -webkit-backdrop-filter: blur(22px) saturate(1.22);
}

.qrcode-history-list {
  display: grid;
  gap: 8px;
  max-height: 280px;
  overflow: auto;
}

.qrcode-history-dialog-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 12px;
}

.qrcode-history-dialog-head span {
  color: var(--muted);
  font-size: 13px;
  font-weight: 900;
}

.qrcode-history-dialog-list {
  max-height: min(56vh, 420px);
  padding-right: 4px;
}

.qrcode-history-list button {
  display: grid;
  gap: 4px;
  padding: 10px 12px;
  border: 1px solid rgba(120, 138, 168, 0.22);
  border-radius: 14px;
  background:
    linear-gradient(145deg, rgba(255, 255, 255, 0.36), rgba(255, 255, 255, 0.1)),
    rgba(255, 255, 255, 0.28);
  color: var(--ink);
  text-align: left;
  box-shadow:
    0 10px 24px rgba(31, 41, 55, 0.05),
    inset 0 1px 0 rgba(255, 255, 255, 0.64);
  backdrop-filter: blur(22px) saturate(1.22);
  -webkit-backdrop-filter: blur(22px) saturate(1.22);
}

.qrcode-history-list button:hover,
.qrcode-history-list button:focus-visible {
  box-shadow:
    0 14px 30px rgba(37, 87, 246, 0.1),
    inset 0 0 0 1px rgba(37, 87, 246, 0.22);
  outline: none;
}

.qrcode-history-list span {
  color: var(--blue);
  font-size: 11px;
  font-weight: 950;
}

.qrcode-history-list strong {
  overflow: hidden;
  color: var(--ink);
  font-size: 13px;
  font-weight: 950;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.qrcode-history-list small {
  color: var(--muted);
  font-size: 12px;
  font-weight: 800;
}

:global(.qrcode-history-dialog.el-dialog) {
  border: 1px solid rgba(21, 25, 31, 0.08);
  border-radius: 22px;
  background:
    linear-gradient(135deg, rgba(255, 255, 255, 0.82), rgba(255, 255, 255, 0.58)),
    rgba(255, 255, 255, 0.72);
  box-shadow: 0 30px 80px rgba(31, 41, 55, 0.2);
  backdrop-filter: blur(22px);
}

:global(.qrcode-history-dialog .el-dialog__header) {
  padding: 18px 20px 8px;
  margin-right: 0;
}

:global(.qrcode-history-dialog .el-dialog__title) {
  color: var(--ink);
  font-size: 18px;
  font-weight: 950;
}

:global(.qrcode-history-dialog .el-dialog__body) {
  padding: 8px 20px 20px;
}

.qrcode-empty {
  min-height: 120px;
}

:global(:root[data-theme="dark"]) .qrcode-type-tabs {
  --el-segmented-bg-color: #10264d;
  --el-segmented-item-hover-bg-color: #18376b;
  --el-segmented-item-hover-color: #ffffff;
  --el-segmented-item-active-bg-color: #1d417d;
  --el-segmented-item-selected-bg-color: var(--blue);
  --el-segmented-item-selected-color: #ffffff;
  border-color: rgba(116, 167, 255, 0.28);
  background: #10264d !important;
  box-shadow:
    inset 0 0 0 1px rgba(255, 255, 255, 0.06),
    0 12px 28px rgba(0, 0, 0, 0.24);
}

:global(:root[data-theme="dark"]) .qrcode-page .qrcode-type-tabs :deep(.el-segmented__item) {
  color: #cfe0ff;
}

:global(:root[data-theme="dark"]) .qrcode-page .qrcode-type-tabs :deep(.el-segmented__item-selected) {
  background: var(--blue) !important;
  box-shadow:
    inset 0 1px 0 rgba(255, 255, 255, 0.2),
    0 8px 16px rgba(116, 167, 255, 0.18);
}

:global(:root[data-theme="dark"]) .qrcode-page .qrcode-type-tabs :deep(.el-segmented__item-selected .el-segmented__item-label),
:global(:root[data-theme="dark"]) .qrcode-page .qrcode-type-tabs :deep(.el-segmented__item.is-selected),
:global(:root[data-theme="dark"]) .qrcode-page .qrcode-type-tabs :deep(.el-segmented__item.is-selected .el-segmented__item-label) {
  color: #ffffff !important;
}

:global(:root[data-theme="dark"]) .qrcode-page .qrcode-field {
  border-color: rgba(255, 255, 255, 0.12);
  background:
    linear-gradient(145deg, rgba(255, 255, 255, 0.08), rgba(255, 255, 255, 0.02)),
    rgba(15, 23, 42, 0.5);
  box-shadow:
    0 14px 30px rgba(0, 0, 0, 0.16),
    inset 0 1px 0 rgba(255, 255, 255, 0.08),
    inset 0 0 0 1px rgba(255, 255, 255, 0.04);
}

:global(:root[data-theme="dark"]) .qrcode-page .qrcode-field::before {
  background:
    radial-gradient(circle at 16% 0%, rgba(255, 255, 255, 0.08), transparent 42%),
    linear-gradient(180deg, rgba(255, 255, 255, 0.04), transparent 62%);
}

:global(:root[data-theme="dark"]) .qrcode-page .qrcode-field :deep(.el-input__wrapper),
:global(:root[data-theme="dark"]) .qrcode-page .qrcode-field :deep(.el-textarea__inner),
:global(:root[data-theme="dark"]) .qrcode-page .qrcode-field :deep(.el-select__wrapper),
:global(:root[data-theme="dark"]) .qrcode-page .qrcode-field :deep(.el-input__wrapper.is-focus),
:global(:root[data-theme="dark"]) .qrcode-page .qrcode-field :deep(.el-input.is-focus .el-input__wrapper),
:global(:root[data-theme="dark"]) .qrcode-page .qrcode-field :deep(.el-textarea__inner:focus),
:global(:root[data-theme="dark"]) .qrcode-page .qrcode-field :deep(.el-textarea__inner:focus-visible),
:global(:root[data-theme="dark"]) .qrcode-page .qrcode-field :deep(.el-select__wrapper.is-focused) {
  background:
    linear-gradient(145deg, rgba(255, 255, 255, 0.07), rgba(255, 255, 255, 0.02)),
    rgba(15, 23, 42, 0.42) !important;
}

:global(:root[data-theme="dark"]) .qrcode-page .qrcode-field > span,
:global(:root[data-theme="dark"]) .qrcode-page .qrcode-info-card strong,
:global(:root[data-theme="dark"]) .qrcode-page .qrcode-security-card strong,
:global(:root[data-theme="dark"]) .qrcode-page .qrcode-history-list strong {
  color: #eef4ff;
}

:global(:root[data-theme="dark"]) .qrcode-page .qrcode-info-card span,
:global(:root[data-theme="dark"]) .qrcode-page .qrcode-security-card p,
:global(:root[data-theme="dark"]) .qrcode-page .qrcode-history-list small {
  color: #b7c3d7;
}

:global(:root[data-theme="dark"]) .qrcode-check-field,
:global(:root[data-theme="dark"]) .qrcode-info-card,
:global(:root[data-theme="dark"]) .qrcode-history-list button,
:global(:root[data-theme="dark"]) .qrcode-scan-upload .el-upload-dragger {
  border-color: var(--glass-border);
  background:
    linear-gradient(135deg, rgba(255, 255, 255, 0.08), rgba(255, 255, 255, 0.02)),
    var(--glass-bg);
  color: var(--ink);
}

:global(:root[data-theme="dark"]) .qrcode-preview-box {
  background:
    linear-gradient(90deg, rgba(116, 167, 255, 0.08) 1px, transparent 1px),
    linear-gradient(rgba(20, 184, 166, 0.08) 1px, transparent 1px),
    linear-gradient(135deg, rgba(15, 23, 42, 0.96), rgba(17, 24, 39, 0.86));
  background-size: 26px 26px, 26px 26px, 100% 100%;
  box-shadow:
    0 20px 52px rgba(0, 0, 0, 0.24),
    inset 0 1px 0 rgba(255, 255, 255, 0.08);
}

:global(:root[data-theme="dark"]) .qrcode-page .qrcode-scan-upload .el-upload-dragger {
  border-color: rgba(116, 167, 255, 0.28);
  background:
    linear-gradient(135deg, rgba(116, 167, 255, 0.12), rgba(255, 255, 255, 0.02) 62%),
    var(--glass-bg);
  color: #d9e5f6;
}

:global(:root[data-theme="dark"]) .qrcode-page .qrcode-version {
  background: rgba(116, 167, 255, 0.16);
  color: #d9e5f6;
}

:global(:root[data-theme="dark"] .qrcode-history-dialog.el-dialog) {
  border-color: rgba(255, 255, 255, 0.12);
  background:
    linear-gradient(135deg, rgba(30, 41, 59, 0.9), rgba(15, 23, 42, 0.78)),
    rgba(15, 23, 42, 0.86);
  box-shadow: 0 30px 80px rgba(0, 0, 0, 0.38);
}

:global(:root[data-theme="dark"] .qrcode-history-dialog .el-dialog__title) {
  color: #eef4ff;
}

:global(:root[data-theme="dark"] .qrcode-history-dialog .qrcode-history-dialog-head span) {
  color: #b7c3d7;
}

:global(:root[data-theme="dark"] .qrcode-history-dialog .qrcode-history-list span) {
  color: #d9e5f6;
}

:global(:root[data-theme="dark"] .qrcode-history-dialog .qrcode-history-list strong) {
  color: #eef4ff;
}

:global(:root[data-theme="dark"] .qrcode-history-dialog .qrcode-history-list small) {
  color: #b7c3d7;
}

:global(:root[data-theme="dark"]) .qrcode-page .qrcode-security-card.neutral {
  border-color: var(--glass-border);
  background:
    linear-gradient(135deg, rgba(255, 255, 255, 0.08), rgba(255, 255, 255, 0.02)),
    var(--glass-bg);
}

:global(:root[data-theme="dark"]) .qrcode-security-card.safe {
  border-color: rgba(34, 197, 94, 0.18);
  background:
    linear-gradient(135deg, rgba(34, 197, 94, 0.14), rgba(255, 255, 255, 0.02)),
    var(--glass-bg);
}

:global(:root[data-theme="dark"]) .qrcode-security-card.warning {
  border-color: rgba(245, 158, 11, 0.22);
  background:
    linear-gradient(135deg, rgba(245, 158, 11, 0.16), rgba(255, 255, 255, 0.02)),
    var(--glass-bg);
}

:global(:root[data-theme="dark"]) .qrcode-security-card.danger {
  border-color: rgba(251, 113, 133, 0.2);
  background:
    linear-gradient(135deg, rgba(251, 113, 133, 0.14), rgba(255, 255, 255, 0.02)),
    var(--glass-bg);
}

:global(:root[data-theme="dark"] .qrcode-page .qrcode-field) {
  border-color: rgba(255, 255, 255, 0.12) !important;
  background:
    linear-gradient(145deg, rgba(255, 255, 255, 0.08), rgba(255, 255, 255, 0.02)),
    rgba(15, 23, 42, 0.5) !important;
  box-shadow:
    0 14px 30px rgba(0, 0, 0, 0.16),
    inset 0 1px 0 rgba(255, 255, 255, 0.08),
    inset 0 0 0 1px rgba(255, 255, 255, 0.04) !important;
}

:global(:root[data-theme="dark"] .qrcode-page .qrcode-field::before) {
  background:
    radial-gradient(circle at 16% 0%, rgba(255, 255, 255, 0.08), transparent 42%),
    linear-gradient(180deg, rgba(255, 255, 255, 0.04), transparent 62%) !important;
}

:global(:root[data-theme="dark"] .qrcode-page .qrcode-field .el-input__wrapper),
:global(:root[data-theme="dark"] .qrcode-page .qrcode-field .el-textarea__inner),
:global(:root[data-theme="dark"] .qrcode-page .qrcode-field .el-select__wrapper),
:global(:root[data-theme="dark"] .qrcode-page .qrcode-field .el-input__wrapper.is-focus),
:global(:root[data-theme="dark"] .qrcode-page .qrcode-field .el-input.is-focus .el-input__wrapper),
:global(:root[data-theme="dark"] .qrcode-page .qrcode-field .el-textarea__inner:focus),
:global(:root[data-theme="dark"] .qrcode-page .qrcode-field .el-textarea__inner:focus-visible),
:global(:root[data-theme="dark"] .qrcode-page .qrcode-field .el-select__wrapper.is-focused) {
  border-color: rgba(255, 255, 255, 0.14) !important;
  background:
    linear-gradient(145deg, rgba(255, 255, 255, 0.07), rgba(255, 255, 255, 0.02)),
    rgba(15, 23, 42, 0.42) !important;
  color: #eef4ff !important;
  box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.08) !important;
}

:global(:root[data-theme="dark"] .qrcode-page .qrcode-check-field),
:global(:root[data-theme="dark"] .qrcode-page .qrcode-info-card),
:global(:root[data-theme="dark"] .qrcode-page .qrcode-history-list button),
:global(:root[data-theme="dark"] .qrcode-page .qrcode-scan-upload .el-upload-dragger) {
  border-color: rgba(255, 255, 255, 0.12) !important;
  background:
    linear-gradient(135deg, rgba(255, 255, 255, 0.08), rgba(255, 255, 255, 0.02)),
    rgba(15, 23, 42, 0.58) !important;
  box-shadow:
    0 14px 30px rgba(0, 0, 0, 0.16),
    inset 0 1px 0 rgba(255, 255, 255, 0.08) !important;
}

:global(:root[data-theme="dark"] .qrcode-page .qrcode-security-card.safe) {
  border-color: rgba(34, 197, 94, 0.18) !important;
  background:
    linear-gradient(135deg, rgba(34, 197, 94, 0.14), rgba(255, 255, 255, 0.02)),
    rgba(15, 23, 42, 0.58) !important;
}

:global(:root[data-theme="dark"] .qrcode-page .qrcode-security-card.warning) {
  border-color: rgba(245, 158, 11, 0.22) !important;
  background:
    linear-gradient(135deg, rgba(245, 158, 11, 0.16), rgba(255, 255, 255, 0.02)),
    rgba(15, 23, 42, 0.58) !important;
}

:global(:root[data-theme="dark"] .qrcode-page .qrcode-security-card.danger) {
  border-color: rgba(251, 113, 133, 0.2) !important;
  background:
    linear-gradient(135deg, rgba(251, 113, 133, 0.14), rgba(255, 255, 255, 0.02)),
    rgba(15, 23, 42, 0.58) !important;
}

@media (max-width: 1180px) {
  .qrcode-shell {
    grid-template-columns: 1fr;
    align-items: start;
  }

  .qrcode-preview-panel {
    position: static;
  }

  .qrcode-input-panel,
  .qrcode-preview-panel,
  .qrcode-side {
    height: auto;
  }

  .qrcode-side {
    grid-template-rows: none;
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
