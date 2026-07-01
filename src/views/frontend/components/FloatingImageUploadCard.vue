<template>
  <Teleport to="body">
    <aside ref="floatingUploadCard" :class="['frontend-floating-upload', { 'is-collapsed': isUploadCollapsed }]" :style="floatingUploadStyle">
      <div class="frontend-floating-upload-head" @pointerdown.stop.prevent="startFloatingUploadDrag">
        <strong>公用图片</strong>
        <span class="frontend-floating-upload-summary">{{ imageInfoText }}</span>
        <button
          class="frontend-floating-icon-button"
          type="button"
          :title="isUploadCollapsed ? '展开' : '收起'"
          :aria-label="isUploadCollapsed ? '展开公用图片上传卡片' : '收起公用图片上传卡片'"
          @pointerdown.stop
          @click.stop="toggleFloatingUploadCollapsed"
        >
          <ChevronUp v-if="isUploadCollapsed" :size="16" />
          <ChevronDown v-else :size="16" />
        </button>
        <span class="frontend-floating-drag-icon" title="拖动位置">
          <Move :size="16" />
        </span>
      </div>
      <template v-if="!isUploadCollapsed">
        <label class="frontend-file-field frontend-floating-file-field">
          <input type="file" accept="image/*" @change="handleImageFile" />
          <span>选择公用图片</span>
        </label>
        <div class="frontend-floating-upload-body">
          <div class="frontend-floating-upload-preview">
            <el-image
              v-if="modelValue.dataUrl.length > 0"
              class="frontend-preview-image"
              :src="modelValue.dataUrl"
              :preview-src-list="[modelValue.dataUrl]"
              fit="contain"
              preview-teleported
              alt="公用图片预览"
            />
            <el-empty
              v-else
              class="frontend-empty-state"
              description="未选择图片"
              :image-size="30"
            />
          </div>
          <div class="frontend-floating-upload-info">
            <div
              v-for="item in imageOverviewItems"
              :key="item.label"
              class="frontend-overview-info-row"
            >
              <span>{{ item.label }}</span>
              <strong>{{ item.value }}</strong>
            </div>
          </div>
        </div>
      </template>
    </aside>
  </Teleport>
</template>

<script setup>
import { computed, nextTick, onBeforeUnmount, ref } from 'vue'
import { ChevronDown, ChevronUp, Move } from 'lucide-vue-next'

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])

const floatingUploadOffset = ref({
  x: 0,
  y: 0
})
const floatingUploadCard = ref()
const isUploadCollapsed = ref(false)
const floatingUploadDragStart = ref({
  pointerX: 0,
  pointerY: 0,
  offsetX: 0,
  offsetY: 0
})

const floatingUploadStyle = computed(() => {
  return {
    transform: `translate(${floatingUploadOffset.value.x}px, ${floatingUploadOffset.value.y}px)`
  }
})

const imageInfoText = computed(() => {
  if (props.modelValue.dataUrl.length === 0) {
    return '未选择图片'
  }

  return `${props.modelValue.name} · ${props.modelValue.width}x${props.modelValue.height} · ${formatFileSize(props.modelValue.size)}`
})

const imageOverviewItems = computed(() => {
  if (props.modelValue.dataUrl.length === 0) {
    return [
      { label: '状态', value: '未选择图片' },
      { label: '信息', value: '选择图片后展示文件详情' }
    ]
  }

  return [
    { label: '文件名', value: props.modelValue.name },
    { label: '格式', value: formatImageType(props.modelValue.type) },
    { label: '大小', value: formatFileSize(props.modelValue.size) },
    { label: '尺寸', value: `${props.modelValue.width} x ${props.modelValue.height}` },
    { label: '修改时间', value: new Date(props.modelValue.lastModified).toLocaleString() }
  ]
})

function handleImageFile(event) {
  const file = event.target.files[0]

  if (!file) {
    return
  }

  const reader = new FileReader()
  reader.onload = () => {
    const dataUrl = reader.result
    const image = new Image()
    image.onload = () => {
      emit('update:modelValue', {
        file,
        name: file.name,
        dataUrl,
        width: image.naturalWidth,
        height: image.naturalHeight,
        size: file.size,
        type: file.type,
        lastModified: file.lastModified
      })
    }
    image.src = dataUrl
  }
  reader.readAsDataURL(file)
}

function formatImageType(value) {
  if (value === 'image/jpeg') {
    return 'JPG'
  }

  if (value.length === 0) {
    return '未知'
  }

  return value.replace('image/', '').toUpperCase()
}

function formatFileSize(value) {
  if (value >= 1024 * 1024) {
    return `${(value / 1024 / 1024).toFixed(2)} MB`
  }

  return `${(value / 1024).toFixed(1)} KB`
}

async function toggleFloatingUploadCollapsed() {
  const previousHeight = floatingUploadCard.value.getBoundingClientRect().height
  isUploadCollapsed.value = !isUploadCollapsed.value
  await nextTick()
  const nextHeight = floatingUploadCard.value.getBoundingClientRect().height
  floatingUploadOffset.value = {
    x: floatingUploadOffset.value.x,
    y: floatingUploadOffset.value.y + nextHeight - previousHeight
  }
}

function startFloatingUploadDrag(event) {
  if (event.button !== 0) {
    return
  }

  event.preventDefault()
  floatingUploadDragStart.value = {
    pointerX: event.clientX,
    pointerY: event.clientY,
    offsetX: floatingUploadOffset.value.x,
    offsetY: floatingUploadOffset.value.y
  }
  window.addEventListener('pointermove', moveFloatingUpload)
  window.addEventListener('pointerup', stopFloatingUploadDrag)
  window.addEventListener('pointercancel', stopFloatingUploadDrag)
}

function moveFloatingUpload(event) {
  event.preventDefault()
  floatingUploadOffset.value = {
    x: floatingUploadDragStart.value.offsetX + event.clientX - floatingUploadDragStart.value.pointerX,
    y: floatingUploadDragStart.value.offsetY + event.clientY - floatingUploadDragStart.value.pointerY
  }
}

function stopFloatingUploadDrag() {
  window.removeEventListener('pointermove', moveFloatingUpload)
  window.removeEventListener('pointerup', stopFloatingUploadDrag)
  window.removeEventListener('pointercancel', stopFloatingUploadDrag)
}

onBeforeUnmount(() => {
  stopFloatingUploadDrag()
})
</script>

<style scoped>
.frontend-floating-upload {
  --ink: #15191f;
  --blue: #2557f6;
  --muted: #526071;
  position: fixed;
  right: 24px;
  bottom: 24px;
  z-index: 30;
  width: 348px;
  display: grid;
  gap: 10px;
  padding: 12px;
  border: 1px solid rgba(21, 25, 31, 0.1);
  border-radius: 8px;
  background:
    linear-gradient(135deg, rgba(255, 255, 255, 0.34), rgba(255, 255, 255, 0.08)),
    rgba(255, 255, 255, 0.72);
  color: var(--ink);
  box-shadow:
    0 18px 48px rgba(44, 55, 67, 0.14),
    inset 0 1px 0 rgba(255, 255, 255, 0.42);
  backdrop-filter: blur(16px) saturate(1.18);
  -webkit-backdrop-filter: blur(16px) saturate(1.18);
}

.frontend-floating-upload.is-collapsed {
  width: 320px;
  gap: 0;
}

.frontend-floating-upload-head {
  display: grid;
  grid-template-columns: 72px minmax(0, 1fr) 28px 28px;
  gap: 8px;
  align-items: center;
  cursor: grab;
  touch-action: none;
  user-select: none;
}

.frontend-floating-upload-head:active {
  cursor: grabbing;
}

.frontend-floating-upload-head strong {
  color: var(--ink);
  font-size: 13px;
  font-weight: 950;
}

.frontend-floating-upload-summary {
  min-width: 0;
  color: #526071;
  font-size: 12px;
  font-weight: 900;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.frontend-floating-icon-button,
.frontend-floating-drag-icon {
  width: 28px;
  height: 28px;
  display: grid;
  place-items: center;
  justify-self: end;
  padding: 0;
  border: 1px solid rgba(37, 87, 246, 0.18);
  border-radius: 7px;
  background: rgba(37, 87, 246, 0.08);
  color: var(--blue);
}

.frontend-floating-icon-button {
  cursor: pointer;
}

.frontend-floating-icon-button:hover,
.frontend-floating-icon-button:focus-visible {
  border-color: rgba(37, 87, 246, 0.34);
  background: rgba(37, 87, 246, 0.14);
  outline: none;
}

.frontend-floating-upload-head:active .frontend-floating-drag-icon {
  transform: scale(0.96);
}

.frontend-file-field {
  min-height: 46px;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 1px dashed rgba(37, 87, 246, 0.36);
  border-radius: 8px;
  background: rgba(37, 87, 246, 0.06);
  color: var(--blue);
  font-weight: 950;
  cursor: pointer;
}

.frontend-file-field input {
  display: none;
}

.frontend-floating-file-field {
  min-height: 38px;
}

.frontend-floating-upload-body {
  display: grid;
  grid-template-columns: 104px minmax(0, 1fr);
  gap: 10px;
  min-width: 0;
}

.frontend-floating-upload-preview {
  min-width: 0;
  height: 104px;
  display: grid;
  place-items: center;
  overflow: hidden;
  border: 1px solid rgba(21, 25, 31, 0.1);
  border-radius: 8px;
  background:
    linear-gradient(45deg, rgba(21, 25, 31, 0.04) 25%, transparent 25%),
    linear-gradient(-45deg, rgba(21, 25, 31, 0.04) 25%, transparent 25%),
    linear-gradient(135deg, rgba(255, 255, 255, 0.48), rgba(239, 246, 255, 0.18)),
    rgba(255, 255, 255, 0.38);
  background-size: 16px 16px, 16px 16px, auto, auto;
}

.frontend-preview-image {
  width: 100%;
  height: 100%;
  max-width: 100%;
  max-height: 100%;
  cursor: zoom-in;
}

.frontend-floating-upload-preview :deep(.el-image__inner) {
  width: 100%;
  height: 100%;
  object-fit: contain;
}

.frontend-empty-state {
  width: 100%;
  min-width: 0;
  padding: 0;
}

.frontend-empty-state :deep(.el-empty__image) {
  margin: 0 auto;
}

.frontend-empty-state :deep(.el-empty__description) {
  margin-top: 4px;
}

.frontend-empty-state :deep(.el-empty__description p) {
  color: #526071;
  font-size: 12px;
  font-weight: 950;
  line-height: 1.35;
}

.frontend-floating-upload-info {
  min-width: 0;
  display: grid;
  align-content: start;
  gap: 6px;
  max-height: 104px;
  overflow: auto;
}

.frontend-overview-info-row {
  display: grid;
  grid-template-columns: 54px minmax(0, 1fr);
  gap: 6px;
  align-items: start;
  min-width: 0;
}

.frontend-overview-info-row span {
  color: #526071;
  font-size: 12px;
  font-weight: 950;
  line-height: 1.4;
}

.frontend-overview-info-row strong {
  min-width: 0;
  color: var(--ink);
  font-size: 12px;
  font-weight: 950;
  line-height: 1.45;
  overflow-wrap: anywhere;
  word-break: break-word;
}

:global(:root[data-theme="dark"] .frontend-floating-upload) {
  --ink: #eef4ff;
  --blue: #74a7ff;
  --muted: #b7c3d7;
  border-color: rgba(255, 255, 255, 0.14);
  background:
    linear-gradient(135deg, rgba(255, 255, 255, 0.08), rgba(255, 255, 255, 0.02)),
    rgba(15, 23, 42, 0.72);
  box-shadow:
    0 18px 48px rgba(0, 0, 0, 0.32),
    inset 0 1px 0 rgba(255, 255, 255, 0.08);
}

:global(:root[data-theme="dark"] .frontend-floating-upload .frontend-floating-file-field) {
  border-color: rgba(116, 167, 255, 0.36);
  background: rgba(116, 167, 255, 0.1);
  color: var(--blue);
}

:global(:root[data-theme="dark"] .frontend-floating-upload .frontend-floating-upload-preview) {
  border-color: rgba(255, 255, 255, 0.12);
  background:
    linear-gradient(45deg, rgba(255, 255, 255, 0.05) 25%, transparent 25%),
    linear-gradient(-45deg, rgba(255, 255, 255, 0.05) 25%, transparent 25%),
    #111827;
  background-size: 16px 16px;
}

:global(:root[data-theme="dark"] .frontend-floating-upload .frontend-floating-upload-summary),
:global(:root[data-theme="dark"] .frontend-floating-upload .frontend-overview-info-row span) {
  color: #b7c3d7;
}

:global(:root[data-theme="dark"] .frontend-floating-upload .frontend-empty-state .el-empty__description p) {
  color: #b7c3d7;
}

:global(:root[data-theme="dark"] .frontend-floating-upload .frontend-floating-icon-button),
:global(:root[data-theme="dark"] .frontend-floating-upload .frontend-floating-drag-icon) {
  border-color: rgba(116, 167, 255, 0.28);
  background: rgba(116, 167, 255, 0.12);
  color: var(--blue);
}

:global(:root[data-theme="dark"] .frontend-floating-upload .frontend-floating-icon-button:hover),
:global(:root[data-theme="dark"] .frontend-floating-upload .frontend-floating-icon-button:focus-visible) {
  border-color: rgba(116, 167, 255, 0.42);
  background: rgba(116, 167, 255, 0.18);
}

:global(:root[data-theme="dark"] .frontend-floating-upload .frontend-floating-upload-head strong),
:global(:root[data-theme="dark"] .frontend-floating-upload .frontend-overview-info-row strong) {
  color: var(--ink);
}

@media (max-width: 760px) {
  .frontend-floating-upload {
    right: 12px;
    bottom: 12px;
    width: calc(100vw - 24px);
  }

  .frontend-floating-upload-body {
    grid-template-columns: 84px minmax(0, 1fr);
  }

  .frontend-floating-upload-preview {
    height: 84px;
  }

  .frontend-floating-upload-info {
    max-height: 84px;
  }
}
</style>
