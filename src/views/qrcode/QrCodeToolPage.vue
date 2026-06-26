<template>
  <main class="tool-page">
    <header class="tool-header">
      <button class="ghost-action" type="button" @click="goHome">
        <ArrowLeft :size="18" />
        首页
      </button>
      <div>
        <p class="eyebrow">QR Code Tool</p>
        <h1>二维码工具</h1>
      </div>
      <el-button type="primary" @click="copyQrUrl">
        <Copy :size="18" />
        复制图片链接
      </el-button>
    </header>

    <section class="tool-grid qrcode-tool-grid">
      <div class="tool-panel">
        <div class="tool-panel-head">
          <h2>内容</h2>
          <el-button plain @click="loadSample">示例</el-button>
        </div>
        <label>
          文本或链接
          <el-input
            v-model="content"
            type="textarea"
            :rows="8"
            resize="none"
            placeholder="输入需要生成二维码的内容"
          />
        </label>
        <label>
          尺寸
          <el-slider v-model="size" :min="160" :max="420" :step="20" show-input />
        </label>
        <label>
          容错等级
          <el-segmented v-model="ecc" :options="eccOptions" />
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
        <div class="qrcode-preview-box">
          <img :src="qrUrl" alt="二维码预览" />
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
