<template>
  <main class="tool-page frontend-tools-page">
    <header class="tool-header">
      <button class="ghost-action" type="button" @click="goHome">
        <ArrowLeft :size="18" />
        首页
      </button>
      <div>
        <p class="eyebrow">Frontend Tools</p>
        <h1>前端处理工具箱</h1>
      </div>
      <el-button type="primary" @click="copyCurrentResult">
        <Copy :size="18" />
        复制当前结果
      </el-button>
    </header>

    <section class="tool-panel frontend-tool-shell">
      <el-tabs v-model="activeTab" :class="['frontend-tabs', 'frontend-tabs-active-' + activeTab]">
        <el-tab-pane label="图片处理" name="image">
          <ImageProcessPanel ref="imageProcessPanelRef" />
        </el-tab-pane>
        <el-tab-pane label="文本与 URL" name="text">
          <TextUrlProcessPanel ref="textUrlProcessPanelRef" />
        </el-tab-pane>
        <el-tab-pane label="数据与预览" name="data">
          <DataPreviewProcessPanel ref="dataPreviewProcessPanelRef" />
        </el-tab-pane>
      </el-tabs>
    </section>
  </main>
</template>

<script setup>
import { computed, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { ArrowLeft, Copy } from 'lucide-vue-next'
import ImageProcessPanel from './components/ImageProcessPanel.vue'
import TextUrlProcessPanel from './components/TextUrlProcessPanel.vue'
import DataPreviewProcessPanel from './components/DataPreviewProcessPanel.vue'
import './components/frontend-process-tool-page.css'

const router = useRouter()
const activeTab = ref('image')
const imageProcessPanelRef = ref()
const textUrlProcessPanelRef = ref()
const dataPreviewProcessPanelRef = ref()

const activeCopyText = computed(() => {
  if (activeTab.value === 'image') {
    if (imageProcessPanelRef.value) {
      return imageProcessPanelRef.value.getActiveCopyText()
    }

    return ''
  }

  if (activeTab.value === 'text') {
    if (textUrlProcessPanelRef.value) {
      return textUrlProcessPanelRef.value.getActiveCopyText()
    }

    return ''
  }

  if (dataPreviewProcessPanelRef.value) {
    return dataPreviewProcessPanelRef.value.getActiveCopyText()
  }

  return ''
})

async function copyCurrentResult() {
  await copyText(activeCopyText.value)
}

async function copyText(value) {
  if (value.length === 0) {
    ElMessage.warning('暂无可复制内容')
    return
  }

  await navigator.clipboard.writeText(value)
  ElMessage.success('已复制')
}

function goHome() {
  router.push('/')
}
</script>
