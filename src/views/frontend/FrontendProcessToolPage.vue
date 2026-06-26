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
      <el-button type="primary" @click="copyText(activeCopyText)">
        <Copy :size="18" />
        复制当前结果
      </el-button>
    </header>

    <section class="tool-panel frontend-tool-shell">
      <el-tabs v-model="activeTab" class="frontend-tabs">
        <el-tab-pane label="图片处理" name="image">
          <div class="frontend-tool-grid">
            <section class="frontend-tool-card frontend-tool-card-wide">
              <div class="tool-panel-head">
                <h2>图片总览</h2>
                <el-button plain @click="copyText(processedImageDataUrl)">复制最近结果</el-button>
              </div>
              <label class="frontend-file-field">
                <input type="file" accept="image/*" @change="handleImageFile" />
                <span>选择图片</span>
              </label>
              <div class="frontend-control-grid">
                <label>
                  输出格式
                  <el-select v-model="imageFormat">
                    <el-option label="WebP" value="image/webp" />
                    <el-option label="JPG" value="image/jpeg" />
                    <el-option label="PNG" value="image/png" />
                  </el-select>
                </label>
                <label>
                  压缩质量
                  <el-slider v-model="imageQuality" :min="20" :max="100" :step="5" show-input />
                </label>
                <label>
                  输出宽度
                  <el-input-number v-model="resizeWidth" :min="1" controls-position="right" />
                </label>
                <label>
                  输出高度
                  <el-input-number v-model="resizeHeight" :min="1" controls-position="right" />
                </label>
              </div>
              <div class="frontend-preview-grid">
                <div class="frontend-preview-box">
                  <span>原图</span>
                  <el-image
                    v-if="imageDataUrl.length > 0"
                    class="frontend-preview-image"
                    :src="imageDataUrl"
                    :preview-src-list="[imageDataUrl]"
                    fit="contain"
                    preview-teleported
                    alt="原图预览"
                  />
                </div>
                <div class="frontend-preview-box">
                  <span>最近处理结果</span>
                  <el-image
                    v-if="processedImageDataUrl.length > 0"
                    class="frontend-preview-image"
                    :src="processedImageDataUrl"
                    :preview-src-list="[processedImageDataUrl]"
                    fit="contain"
                    preview-teleported
                    alt="处理后图片预览"
                  />
                </div>
              </div>
              <div class="frontend-result-line">
                <strong>{{ imageInfoText }}</strong>
                <a
                  v-if="processedImageDataUrl.length > 0"
                  class="ghost-action"
                  :href="processedImageDataUrl"
                  :download="processedImageName"
                >
                  <Download :size="16" />
                  下载
                </a>
              </div>
            </section>

            <section class="frontend-tool-card">
              <div class="tool-panel-head">
                <h2>图片压缩</h2>
                <div class="tool-actions">
                  <el-button type="primary" plain @click="compressImage">压缩</el-button>
                  <el-button plain @click="copyText(compressedImageDataUrl)">复制 Data URL</el-button>
                </div>
              </div>
              <div class="frontend-preview-box compact">
                <el-image
                  v-if="compressedImageDataUrl.length > 0"
                  class="frontend-preview-image"
                  :src="compressedImageDataUrl"
                  :preview-src-list="[compressedImageDataUrl]"
                  fit="contain"
                  preview-teleported
                  alt="压缩图片预览"
                />
              </div>
              <a
                v-if="compressedImageDataUrl.length > 0"
                class="ghost-action frontend-inline-link"
                :href="compressedImageDataUrl"
                :download="`snail-compressed-image.${imageExtension}`"
              >
                <Download :size="16" />
                下载压缩图
              </a>
            </section>

            <section class="frontend-tool-card">
              <div class="tool-panel-head">
                <h2>图片格式转换 / 转 Base64</h2>
                <div class="tool-actions">
                  <el-button type="primary" plain @click="convertImage">转换</el-button>
                  <el-button plain @click="copyText(convertedImageDataUrl)">复制 Data URL</el-button>
                </div>
              </div>
              <div class="frontend-preview-box compact">
                <el-image
                  v-if="convertedImageDataUrl.length > 0"
                  class="frontend-preview-image"
                  :src="convertedImageDataUrl"
                  :preview-src-list="[convertedImageDataUrl]"
                  fit="contain"
                  preview-teleported
                  alt="格式转换图片预览"
                />
              </div>
              <a
                v-if="convertedImageDataUrl.length > 0"
                class="ghost-action frontend-inline-link"
                :href="convertedImageDataUrl"
                :download="processedImageName"
              >
                <Download :size="16" />
                下载转换图
              </a>
            </section>

            <section class="frontend-tool-card">
              <div class="tool-panel-head">
                <h2>Base64 转图片</h2>
                <el-button plain @click="previewBase64Image">预览</el-button>
              </div>
              <el-input
                v-model="base64Input"
                type="textarea"
                :rows="7"
                resize="none"
                placeholder="粘贴图片 Base64 或 Data URL"
              />
              <div class="frontend-preview-box compact">
                <el-image
                  v-if="base64PreviewSrc.length > 0"
                  class="frontend-preview-image"
                  :src="base64PreviewSrc"
                  :preview-src-list="[base64PreviewSrc]"
                  fit="contain"
                  preview-teleported
                  alt="Base64 图片预览"
                />
              </div>
              <a
                v-if="base64PreviewSrc.length > 0"
                class="ghost-action frontend-inline-link"
                :href="base64PreviewSrc"
                download="base64-image.png"
              >
                <Download :size="16" />
                下载图片
              </a>
            </section>

            <section class="frontend-tool-card">
              <div class="tool-panel-head">
                <h2>裁剪 / 改尺寸</h2>
                <el-button plain @click="cropImage">裁剪</el-button>
              </div>
              <div class="frontend-control-grid compact">
                <label>
                  X
                  <el-input-number v-model="cropX" :min="0" controls-position="right" />
                </label>
                <label>
                  Y
                  <el-input-number v-model="cropY" :min="0" controls-position="right" />
                </label>
                <label>
                  宽
                  <el-input-number v-model="cropWidth" :min="1" controls-position="right" />
                </label>
                <label>
                  高
                  <el-input-number v-model="cropHeight" :min="1" controls-position="right" />
                </label>
              </div>
              <div class="frontend-preview-box compact">
                <el-image
                  v-if="croppedImageDataUrl.length > 0"
                  class="frontend-preview-image"
                  :src="croppedImageDataUrl"
                  :preview-src-list="[croppedImageDataUrl]"
                  fit="contain"
                  preview-teleported
                  alt="裁剪图片预览"
                />
              </div>
              <div class="tool-actions">
                <el-button plain @click="copyText(croppedImageDataUrl)">复制 Data URL</el-button>
                <a
                  v-if="croppedImageDataUrl.length > 0"
                  class="ghost-action frontend-inline-link"
                  :href="croppedImageDataUrl"
                  :download="`snail-cropped-image.${imageExtension}`"
                >
                  <Download :size="16" />
                  下载裁剪图
                </a>
              </div>
            </section>

            <section class="frontend-tool-card">
              <div class="tool-panel-head">
                <h2>雪碧图坐标辅助</h2>
                <el-button plain @click="copyText(spriteCss)">复制 CSS</el-button>
              </div>
              <div class="frontend-control-grid compact">
                <label>
                  X
                  <el-input-number v-model="spriteX" :min="0" controls-position="right" />
                </label>
                <label>
                  Y
                  <el-input-number v-model="spriteY" :min="0" controls-position="right" />
                </label>
                <label>
                  宽
                  <el-input-number v-model="spriteWidth" :min="1" controls-position="right" />
                </label>
                <label>
                  高
                  <el-input-number v-model="spriteHeight" :min="1" controls-position="right" />
                </label>
              </div>
              <pre class="frontend-code">{{ spriteCss }}</pre>
            </section>

            <section class="frontend-tool-card">
              <div class="tool-panel-head">
                <h2>favicon 生成</h2>
                <el-button plain @click="generateFavicons">生成</el-button>
              </div>
              <div class="frontend-chip-grid">
                <a
                  v-for="item in favicons"
                  :key="item.size"
                  class="ghost-action frontend-inline-link"
                  :href="item.url"
                  :download="`favicon-${item.size}.png`"
                >
                  {{ item.size }}px
                </a>
              </div>
              <p class="frontend-muted">使用上方选择的图片生成常见 PNG favicon 尺寸。</p>
            </section>

            <section class="frontend-tool-card">
              <div class="tool-panel-head">
                <h2>图片颜色提取</h2>
                <el-button plain @click="extractImageColors">提取</el-button>
              </div>
              <div class="frontend-color-grid">
                <button
                  v-for="item in extractedColors"
                  :key="item"
                  type="button"
                  class="frontend-color-chip"
                  :style="{ background: item, color: item }"
                  @click="copyText(item)"
                >
                  <span>{{ item }}</span>
                </button>
              </div>
            </section>

            <section class="frontend-tool-card frontend-tool-card-wide">
              <div class="tool-panel-head">
                <h2>图片水印</h2>
                <el-button type="primary" plain @click="applyWatermark">生成水印图</el-button>
              </div>
              <div class="frontend-control-grid">
                <label>
                  水印文字
                  <el-input v-model="watermarkText" placeholder="Snail Tools" />
                </label>
                <label>
                  位置
                  <el-select v-model="watermarkPosition">
                    <el-option label="右下角" value="bottom-right" />
                    <el-option label="左下角" value="bottom-left" />
                    <el-option label="居中" value="center" />
                    <el-option label="平铺" value="tile" />
                  </el-select>
                </label>
                <label>
                  字号
                  <el-slider v-model="watermarkFontSize" :min="12" :max="96" :step="2" show-input />
                </label>
                <label>
                  透明度
                  <el-slider v-model="watermarkOpacity" :min="10" :max="90" :step="5" show-input />
                </label>
              </div>
              <div class="frontend-control-grid compact">
                <label>
                  文字颜色
                  <el-color-picker v-model="watermarkColor" color-format="hex" />
                </label>
                <label>
                  边距
                  <el-input-number v-model="watermarkPadding" :min="0" controls-position="right" />
                </label>
              </div>
              <div class="frontend-preview-box compact">
                <el-image
                  v-if="watermarkImageDataUrl.length > 0"
                  class="frontend-preview-image"
                  :src="watermarkImageDataUrl"
                  :preview-src-list="[watermarkImageDataUrl]"
                  fit="contain"
                  preview-teleported
                  alt="水印图片预览"
                />
              </div>
              <div class="tool-actions">
                <el-button plain @click="copyText(watermarkImageDataUrl)">复制 Data URL</el-button>
                <a
                  v-if="watermarkImageDataUrl.length > 0"
                  class="ghost-action frontend-inline-link"
                  :href="watermarkImageDataUrl"
                  :download="`snail-watermark-image.${imageExtension}`"
                >
                  <Download :size="16" />
                  下载水印图
                </a>
              </div>
            </section>

            <section class="frontend-tool-card frontend-tool-card-wide">
              <div class="tool-panel-head">
                <h2>图片 EXIF 查看 / 清理</h2>
                <div class="tool-actions">
                  <el-button plain @click="viewImageExif">查看信息</el-button>
                  <el-button type="primary" plain @click="cleanImageExif">清理元数据</el-button>
                </div>
              </div>
              <div class="frontend-kv-list frontend-kv-list-wide">
                <template v-for="item in exifItems" :key="item.label">
                  <span>{{ item.label }}</span>
                  <strong>{{ item.value }}</strong>
                </template>
              </div>
              <div class="frontend-preview-box compact">
                <el-image
                  v-if="exifCleanImageDataUrl.length > 0"
                  class="frontend-preview-image"
                  :src="exifCleanImageDataUrl"
                  :preview-src-list="[exifCleanImageDataUrl]"
                  fit="contain"
                  preview-teleported
                  alt="EXIF 清理图片预览"
                />
              </div>
              <div class="tool-actions">
                <el-button plain @click="copyText(exifCleanImageDataUrl)">复制 Data URL</el-button>
                <a
                  v-if="exifCleanImageDataUrl.length > 0"
                  class="ghost-action frontend-inline-link"
                  :href="exifCleanImageDataUrl"
                  :download="`snail-clean-image.${imageExtension}`"
                >
                  <Download :size="16" />
                  下载清理图
                </a>
              </div>
              <p class="frontend-muted">清理会通过 Canvas 重新导出图片，常见 EXIF、拍摄设备、定位等元数据会被移除。</p>
            </section>
          </div>
        </el-tab-pane>

        <el-tab-pane label="文本与 URL" name="text">
          <div class="frontend-tool-grid">
            <section class="frontend-tool-card">
              <div class="tool-panel-head">
                <h2>URL 参数解析</h2>
                <div class="tool-actions">
                  <el-button plain @click="parseUrlParams">解析</el-button>
                  <el-button plain @click="buildUrlFromParams">拼接</el-button>
                </div>
              </div>
              <el-input v-model="urlInput" placeholder="https://example.com?a=1&b=2" />
              <div class="frontend-param-list">
                <div v-for="item in urlParams" :key="item.id" class="frontend-param-row">
                  <el-input v-model="item.key" placeholder="key" />
                  <el-input v-model="item.value" placeholder="value" />
                </div>
              </div>
              <el-input v-model="urlOutput" type="textarea" :rows="3" resize="none" placeholder="拼接结果" />
            </section>

            <section class="frontend-tool-card">
              <div class="tool-panel-head">
                <h2>URL 编码 / 解码</h2>
                <div class="tool-actions">
                  <el-button plain @click="encodeUrlText">编码</el-button>
                  <el-button plain @click="decodeUrlText">解码</el-button>
                </div>
              </div>
              <el-input v-model="urlCodecInput" type="textarea" :rows="5" resize="none" placeholder="输入 URL 或参数文本" />
              <el-input v-model="urlCodecOutput" type="textarea" :rows="5" resize="none" placeholder="处理结果" />
            </section>

            <section class="frontend-tool-card">
              <div class="tool-panel-head">
                <h2>HTML 实体转义</h2>
                <div class="tool-actions">
                  <el-button plain @click="encodeHtmlEntities">转义</el-button>
                  <el-button plain @click="decodeHtmlEntities">反转义</el-button>
                </div>
              </div>
              <el-input v-model="htmlEntityInput" type="textarea" :rows="5" resize="none" placeholder="<div>hello</div>" />
              <el-input v-model="htmlEntityOutput" type="textarea" :rows="5" resize="none" placeholder="处理结果" />
            </section>

            <section class="frontend-tool-card">
              <div class="tool-panel-head">
                <h2>文本批处理</h2>
                <div class="tool-actions">
                  <el-button plain @click="removeEmptyLines">去空行</el-button>
                  <el-button plain @click="uniqueLines">去重复</el-button>
                  <el-button plain @click="sortLines">排序</el-button>
                </div>
              </div>
              <el-input v-model="batchTextInput" type="textarea" :rows="7" resize="none" placeholder="每行一条文本" />
              <div class="tool-actions">
                <el-button plain @click="trimLines">清理首尾空格</el-button>
                <el-button plain @click="upperCaseText">大写</el-button>
                <el-button plain @click="lowerCaseText">小写</el-button>
              </div>
              <el-input v-model="batchTextOutput" type="textarea" :rows="7" resize="none" placeholder="处理结果" />
            </section>

            <section class="frontend-tool-card frontend-tool-card-wide">
              <div class="tool-panel-head">
                <h2>文本差异对比</h2>
                <el-button plain @click="compareText">对比</el-button>
              </div>
              <div class="frontend-preview-grid">
                <el-input v-model="diffLeft" type="textarea" :rows="8" resize="none" placeholder="原文本" />
                <el-input v-model="diffRight" type="textarea" :rows="8" resize="none" placeholder="新文本" />
              </div>
              <div class="frontend-diff-list">
                <div v-for="item in diffRows" :key="item.id" :class="['frontend-diff-row', item.type]">
                  <span>{{ item.label }}</span>
                  <code>{{ item.text }}</code>
                </div>
              </div>
            </section>

            <section class="frontend-tool-card">
              <div class="tool-panel-head">
                <h2>正则匹配测试</h2>
                <div class="tool-actions">
                  <el-button plain @click="runRegex">匹配</el-button>
                  <el-button plain @click="replaceRegex">替换</el-button>
                </div>
              </div>
              <el-input v-model="regexPattern" placeholder="正则表达式，不需要 / /" />
              <div class="frontend-control-grid compact">
                <label>
                  flags
                  <el-input v-model="regexFlags" placeholder="gi" />
                </label>
                <label>
                  替换为
                  <el-input v-model="regexReplacement" placeholder="$1" />
                </label>
              </div>
              <el-input v-model="regexText" type="textarea" :rows="6" resize="none" placeholder="待匹配文本" />
              <pre class="frontend-code">{{ regexOutput }}</pre>
            </section>

            <section class="frontend-tool-card">
              <div class="tool-panel-head">
                <h2>浏览器 UA 解析</h2>
                <el-button plain @click="parseUserAgent">解析</el-button>
              </div>
              <el-input v-model="userAgentInput" type="textarea" :rows="5" resize="none" placeholder="粘贴 User-Agent" />
              <div class="frontend-kv-list">
                <span>浏览器</span><strong>{{ userAgentInfo.browser }}</strong>
                <span>系统</span><strong>{{ userAgentInfo.os }}</strong>
                <span>设备</span><strong>{{ userAgentInfo.device }}</strong>
              </div>
            </section>
          </div>
        </el-tab-pane>

        <el-tab-pane label="数据与预览" name="data">
          <div class="frontend-tool-grid">
            <section class="frontend-tool-card">
              <div class="tool-panel-head">
                <h2>JSON 路径提取</h2>
                <el-button plain @click="extractJsonPaths">提取</el-button>
              </div>
              <el-input v-model="jsonPathInput" type="textarea" :rows="9" resize="none" placeholder="粘贴 JSON" />
              <div class="frontend-path-list">
                <button
                  v-for="item in jsonPaths"
                  :key="item"
                  type="button"
                  @click="copyText(item)"
                >
                  {{ item }}
                </button>
              </div>
            </section>

            <section class="frontend-tool-card">
              <div class="tool-panel-head">
                <h2>CSV / JSON 互转</h2>
                <div class="tool-actions">
                  <el-button plain @click="csvToJson">CSV 转 JSON</el-button>
                  <el-button plain @click="jsonToCsv">JSON 转 CSV</el-button>
                </div>
              </div>
              <el-input v-model="csvJsonInput" type="textarea" :rows="8" resize="none" placeholder="CSV 或 JSON 数组" />
              <el-input v-model="csvJsonOutput" type="textarea" :rows="8" resize="none" placeholder="转换结果" />
            </section>

            <section class="frontend-tool-card">
              <div class="tool-panel-head">
                <h2>Mock 数据生成</h2>
                <div class="tool-actions">
                  <el-button plain @click="generateMockData">生成</el-button>
                  <el-button plain @click="copyText(mockOutput)">复制</el-button>
                </div>
              </div>
              <div class="frontend-control-grid compact">
                <label>
                  数量
                  <el-input-number v-model="mockCount" :min="1" :max="200" controls-position="right" />
                </label>
                <label>
                  场景
                  <el-select v-model="mockScene">
                    <el-option label="用户列表" value="users" />
                    <el-option label="订单列表" value="orders" />
                    <el-option label="文章列表" value="articles" />
                  </el-select>
                </label>
              </div>
              <el-input v-model="mockOutput" type="textarea" :rows="12" resize="none" placeholder="生成结果" />
            </section>

            <section class="frontend-tool-card frontend-tool-card-wide">
              <div class="tool-panel-head">
                <h2>Markdown 预览</h2>
                <el-button plain @click="copyText(markdownHtml)">复制 HTML</el-button>
              </div>
              <div class="frontend-preview-grid">
                <el-input v-model="markdownInput" type="textarea" :rows="14" resize="none" placeholder="# 标题" />
                <article class="frontend-markdown-preview" v-html="markdownHtml"></article>
              </div>
            </section>
          </div>
        </el-tab-pane>
      </el-tabs>
    </section>
  </main>
</template>

<script setup>
import { computed, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { ArrowLeft, Copy, Download } from 'lucide-vue-next'

const router = useRouter()
const activeTab = ref('image')

const imageFile = ref()
const imageFileName = ref('')
const imageDataUrl = ref('')
const processedImageDataUrl = ref('')
const compressedImageDataUrl = ref('')
const convertedImageDataUrl = ref('')
const croppedImageDataUrl = ref('')
const watermarkImageDataUrl = ref('')
const exifCleanImageDataUrl = ref('')
const imageFormat = ref('image/webp')
const imageQuality = ref(80)
const resizeWidth = ref(320)
const resizeHeight = ref(320)
const imageInfo = ref({
  width: 0,
  height: 0,
  size: 0
})
const base64Input = ref('')
const base64PreviewSrc = ref('')
const cropX = ref(0)
const cropY = ref(0)
const cropWidth = ref(160)
const cropHeight = ref(160)
const spriteX = ref(0)
const spriteY = ref(0)
const spriteWidth = ref(48)
const spriteHeight = ref(48)
const favicons = ref([])
const extractedColors = ref([])
const watermarkText = ref('Snail Tools')
const watermarkPosition = ref('bottom-right')
const watermarkFontSize = ref(32)
const watermarkOpacity = ref(35)
const watermarkColor = ref('#ffffff')
const watermarkPadding = ref(32)
const exifItems = ref([
  { label: '状态', value: '未选择图片' }
])

const urlInput = ref('https://example.com/search?keyword=snail&page=1')
const urlParams = ref([])
const urlBase = ref('https://example.com/search')
const urlHash = ref('')
const urlOutput = ref('')
const urlCodecInput = ref('https://example.com/?q=前端工具')
const urlCodecOutput = ref('')
const htmlEntityInput = ref('<button class="primary">保存</button>')
const htmlEntityOutput = ref('')
const batchTextInput = ref('apple\n\nbanana\napple\n  orange  ')
const batchTextOutput = ref('')
const diffLeft = ref('首页\nJSON 工具\n二维码')
const diffRight = ref('首页\nJSON 工具\n图片处理')
const diffRows = ref([])
const regexPattern = ref('\\btool\\b')
const regexFlags = ref('gi')
const regexReplacement = ref('utility')
const regexText = ref('tool, frontend tool, toolbar')
const regexOutput = ref('')
const userAgentInput = ref(navigator.userAgent)
const userAgentInfo = ref({
  browser: '',
  os: '',
  device: ''
})

const jsonPathInput = ref('{"user":{"name":"snail","tags":["vue","tools"]}}')
const jsonPaths = ref([])
const csvJsonInput = ref('name,type\nsnail,tool\nvue,framework')
const csvJsonOutput = ref('')
const mockCount = ref(10)
const mockScene = ref('users')
const mockOutput = ref('')
const markdownInput = ref('# 前端工具\n\n- 图片处理\n- 文本处理\n\n**复制结果** 后即可使用。')

const imageInfoText = computed(() => {
  if (imageDataUrl.value.length === 0) {
    return '未选择图片'
  }

  return `${imageFileName.value} · ${imageInfo.value.width}x${imageInfo.value.height} · ${formatFileSize(imageInfo.value.size)}`
})

const imageExtension = computed(() => {
  if (imageFormat.value === 'image/jpeg') {
    return 'jpg'
  }

  return imageFormat.value.replace('image/', '')
})

const processedImageName = computed(() => {
  return `snail-image.${imageExtension.value}`
})

const spriteCss = computed(() => {
  return `.icon {
  width: ${spriteWidth.value}px;
  height: ${spriteHeight.value}px;
  background-position: -${spriteX.value}px -${spriteY.value}px;
}`
})

const markdownHtml = computed(() => {
  return renderMarkdown(markdownInput.value)
})

const activeCopyText = computed(() => {
  if (activeTab.value === 'image') {
    return processedImageDataUrl.value
  }

  if (activeTab.value === 'text') {
    return batchTextOutput.value
  }

  return csvJsonOutput.value
})

function handleImageFile(event) {
  const file = event.target.files[0]

  if (!file) {
    return
  }

  imageFileName.value = file.name
  imageFile.value = file
  imageInfo.value.size = file.size

  const reader = new FileReader()
  reader.onload = () => {
    imageDataUrl.value = reader.result
    processedImageDataUrl.value = ''
    compressedImageDataUrl.value = ''
    convertedImageDataUrl.value = ''
    croppedImageDataUrl.value = ''
    watermarkImageDataUrl.value = ''
    exifCleanImageDataUrl.value = ''
    favicons.value = []
    extractedColors.value = []
    exifItems.value = [
      { label: '状态', value: '已选择图片，点击查看信息' }
    ]
    readImageSize(reader.result)
  }
  reader.readAsDataURL(file)
}

function readImageSize(src) {
  const image = new Image()
  image.onload = () => {
    imageInfo.value.width = image.naturalWidth
    imageInfo.value.height = image.naturalHeight
    resizeWidth.value = image.naturalWidth
    resizeHeight.value = image.naturalHeight
    cropWidth.value = image.naturalWidth
    cropHeight.value = image.naturalHeight
  }
  image.src = src
}

async function compressImage() {
  const dataUrl = await renderImageDataUrl(0, 0, imageInfo.value.width, imageInfo.value.height, resizeWidth.value, resizeHeight.value)
  if (dataUrl.length === 0) {
    return
  }

  compressedImageDataUrl.value = dataUrl
  processedImageDataUrl.value = dataUrl
  ElMessage.success('图片压缩完成')
}

async function convertImage() {
  const dataUrl = await renderImageDataUrl(0, 0, imageInfo.value.width, imageInfo.value.height, imageInfo.value.width, imageInfo.value.height)
  if (dataUrl.length === 0) {
    return
  }

  convertedImageDataUrl.value = dataUrl
  processedImageDataUrl.value = dataUrl
  ElMessage.success('图片格式转换完成')
}

async function cropImage() {
  const dataUrl = await renderImageDataUrl(cropX.value, cropY.value, cropWidth.value, cropHeight.value, cropWidth.value, cropHeight.value)
  if (dataUrl.length === 0) {
    return
  }

  croppedImageDataUrl.value = dataUrl
  processedImageDataUrl.value = dataUrl
  ElMessage.success('图片裁剪完成')
}

function renderImageDataUrl(sourceX, sourceY, sourceWidth, sourceHeight, targetWidth, targetHeight) {
  if (imageDataUrl.value.length === 0) {
    ElMessage.warning('请先选择图片')
    return Promise.resolve('')
  }

  return new Promise((resolve) => {
    const image = new Image()
    image.onload = () => {
      const canvas = document.createElement('canvas')
      canvas.width = targetWidth
      canvas.height = targetHeight
      const context = canvas.getContext('2d')
      context.clearRect(0, 0, targetWidth, targetHeight)
      context.drawImage(image, sourceX, sourceY, sourceWidth, sourceHeight, 0, 0, targetWidth, targetHeight)
      resolve(canvas.toDataURL(imageFormat.value, imageQuality.value / 100))
    }
    image.src = imageDataUrl.value
  })
}

function previewBase64Image() {
  const value = base64Input.value.trim()

  if (value.length === 0) {
    ElMessage.warning('请粘贴 Base64 内容')
    return
  }

  if (value.startsWith('data:image/')) {
    base64PreviewSrc.value = value
    return
  }

  base64PreviewSrc.value = `data:image/png;base64,${value}`
}

function generateFavicons() {
  if (imageDataUrl.value.length === 0) {
    ElMessage.warning('请先选择图片')
    return
  }

  const sizes = [16, 32, 48, 64, 180]
  const image = new Image()
  image.onload = () => {
    favicons.value = sizes.map((size) => {
      const canvas = document.createElement('canvas')
      canvas.width = size
      canvas.height = size
      const context = canvas.getContext('2d')
      context.drawImage(image, 0, 0, size, size)
      return {
        size,
        url: canvas.toDataURL('image/png')
      }
    })
    ElMessage.success('favicon 已生成')
  }
  image.src = imageDataUrl.value
}

function extractImageColors() {
  if (imageDataUrl.value.length === 0) {
    ElMessage.warning('请先选择图片')
    return
  }

  const image = new Image()
  image.onload = () => {
    const sampleSize = 120
    const canvas = document.createElement('canvas')
    canvas.width = sampleSize
    canvas.height = sampleSize
    const context = canvas.getContext('2d')
    context.drawImage(image, 0, 0, sampleSize, sampleSize)
    const pixels = context.getImageData(0, 0, sampleSize, sampleSize).data
    const bucket = new Map()

    for (let index = 0; index < pixels.length; index += 16) {
      const red = quantizeColor(pixels[index])
      const green = quantizeColor(pixels[index + 1])
      const blue = quantizeColor(pixels[index + 2])
      const alpha = pixels[index + 3]

      if (alpha > 128) {
        const hex = rgbToHex(red, green, blue)
        const count = bucket.get(hex)
        if (count) {
          bucket.set(hex, count + 1)
        } else {
          bucket.set(hex, 1)
        }
      }
    }

    extractedColors.value = Array.from(bucket.entries())
      .sort((left, right) => right[1] - left[1])
      .slice(0, 8)
      .map((item) => item[0])
  }
  image.src = imageDataUrl.value
}

function applyWatermark() {
  if (imageDataUrl.value.length === 0) {
    ElMessage.warning('请先选择图片')
    return
  }

  const image = new Image()
  image.onload = () => {
    const canvas = document.createElement('canvas')
    canvas.width = image.naturalWidth
    canvas.height = image.naturalHeight
    const context = canvas.getContext('2d')
    context.drawImage(image, 0, 0)
    drawWatermark(context, canvas.width, canvas.height)
    watermarkImageDataUrl.value = canvas.toDataURL(imageFormat.value, imageQuality.value / 100)
    processedImageDataUrl.value = watermarkImageDataUrl.value
    ElMessage.success('水印图片已生成')
  }
  image.src = imageDataUrl.value
}

function drawWatermark(context, canvasWidth, canvasHeight) {
  const padding = watermarkPadding.value
  const fontSize = watermarkFontSize.value
  const text = watermarkText.value
  context.save()
  context.globalAlpha = watermarkOpacity.value / 100
  context.fillStyle = watermarkColor.value
  context.font = `900 ${fontSize}px "Microsoft YaHei", sans-serif`
  context.textBaseline = 'middle'

  if (watermarkPosition.value === 'tile') {
    context.rotate(-Math.PI / 8)
    const stepX = Math.max(180, fontSize * text.length)
    const stepY = fontSize * 4
    for (let y = -canvasHeight; y < canvasHeight * 2; y += stepY) {
      for (let x = -canvasWidth; x < canvasWidth * 2; x += stepX) {
        context.fillText(text, x, y)
      }
    }
    context.restore()
    return
  }

  const metrics = context.measureText(text)
  let x = canvasWidth - metrics.width - padding
  let y = canvasHeight - padding - fontSize / 2
  context.textAlign = 'left'

  if (watermarkPosition.value === 'bottom-left') {
    x = padding
  }

  if (watermarkPosition.value === 'center') {
    x = canvasWidth / 2
    y = canvasHeight / 2
    context.textAlign = 'center'
  }

  context.fillText(text, x, y)
  context.restore()
}

async function viewImageExif() {
  if (!imageFile.value) {
    ElMessage.warning('请先选择图片')
    return
  }

  const items = [
    { label: '文件名', value: imageFile.value.name },
    { label: '类型', value: imageFile.value.type },
    { label: '大小', value: formatFileSize(imageFile.value.size) },
    { label: '尺寸', value: `${imageInfo.value.width}x${imageInfo.value.height}` },
    { label: '修改时间', value: new Date(imageFile.value.lastModified).toLocaleString() }
  ]

  if (imageFile.value.type === 'image/jpeg') {
    const buffer = await imageFile.value.arrayBuffer()
    parseJpegExif(buffer).forEach((item) => {
      items.push(item)
    })
  } else {
    items.push({ label: 'EXIF', value: '当前仅解析 JPEG EXIF；可直接清理元数据' })
  }

  exifItems.value = items
}

async function cleanImageExif() {
  if (imageDataUrl.value.length === 0) {
    ElMessage.warning('请先选择图片')
    return
  }

  const dataUrl = await renderImageDataUrl(0, 0, imageInfo.value.width, imageInfo.value.height, imageInfo.value.width, imageInfo.value.height)
  if (dataUrl.length === 0) {
    return
  }

  exifCleanImageDataUrl.value = dataUrl
  processedImageDataUrl.value = dataUrl
  ElMessage.success('已通过重新导出清理元数据')
}

function parseJpegExif(buffer) {
  const view = new DataView(buffer)
  const items = []

  if (view.getUint16(0) !== 0xffd8) {
    return items
  }

  let offset = 2
  while (offset < view.byteLength) {
    const marker = view.getUint16(offset)
    const size = view.getUint16(offset + 2)

    if (marker === 0xffe1) {
      return readExifSegment(view, offset + 4, size - 2)
    }

    offset += size + 2
  }

  return items
}

function readExifSegment(view, start, length) {
  const signature = readAscii(view, start, 6)
  const items = []

  if (signature !== 'Exif\u0000\u0000') {
    return items
  }

  const tiffStart = start + 6
  const littleEndian = readAscii(view, tiffStart, 2) === 'II'
  const firstIfdOffset = view.getUint32(tiffStart + 4, littleEndian)
  readExifDirectory(view, tiffStart, tiffStart + firstIfdOffset, littleEndian, items)

  if (items.length === 0) {
    items.push({ label: 'EXIF', value: `存在 EXIF 段，长度 ${length} bytes` })
  }

  return items
}

function readExifDirectory(view, tiffStart, directoryOffset, littleEndian, items) {
  const fieldCount = view.getUint16(directoryOffset, littleEndian)
  const tagNames = {
    0x010f: '相机品牌',
    0x0110: '相机型号',
    0x0112: '方向',
    0x0131: '软件',
    0x0132: '拍摄时间',
    0x9003: '原始时间'
  }

  for (let index = 0; index < fieldCount; index += 1) {
    const entryOffset = directoryOffset + 2 + index * 12
    const tag = view.getUint16(entryOffset, littleEndian)
    const type = view.getUint16(entryOffset + 2, littleEndian)
    const count = view.getUint32(entryOffset + 4, littleEndian)
    const valueOffset = entryOffset + 8
    const label = tagNames[tag]

    if (label) {
      items.push({
        label,
        value: readExifValue(view, tiffStart, valueOffset, type, count, littleEndian)
      })
    }

    if (tag === 0x8769) {
      const exifOffset = view.getUint32(valueOffset, littleEndian)
      readExifDirectory(view, tiffStart, tiffStart + exifOffset, littleEndian, items)
    }
  }
}

function readExifValue(view, tiffStart, valueOffset, type, count, littleEndian) {
  if (type === 2) {
    const offset = count <= 4 ? valueOffset : tiffStart + view.getUint32(valueOffset, littleEndian)
    return readAscii(view, offset, count).replace(/\u0000/g, '')
  }

  if (type === 3) {
    return String(view.getUint16(valueOffset, littleEndian))
  }

  if (type === 4) {
    return String(view.getUint32(valueOffset, littleEndian))
  }

  return '已记录'
}

function readAscii(view, offset, length) {
  let text = ''
  for (let index = 0; index < length; index += 1) {
    text += String.fromCharCode(view.getUint8(offset + index))
  }
  return text
}

function quantizeColor(value) {
  return Math.min(255, Math.round(value / 32) * 32)
}

function rgbToHex(red, green, blue) {
  return `#${colorComponentToHex(red)}${colorComponentToHex(green)}${colorComponentToHex(blue)}`
}

function colorComponentToHex(value) {
  return value.toString(16).padStart(2, '0')
}

function parseUrlParams() {
  try {
    const url = new URL(urlInput.value, window.location.origin)
    urlBase.value = `${url.origin}${url.pathname}`
    urlHash.value = url.hash
    urlParams.value = Array.from(url.searchParams.entries()).map((item, index) => {
      return {
        id: index,
        key: item[0],
        value: item[1]
      }
    })
    urlOutput.value = url.href
  } catch (error) {
    ElMessage.error(error.message)
  }
}

function buildUrlFromParams() {
  const params = new URLSearchParams()
  urlParams.value.forEach((item) => {
    if (item.key.length > 0) {
      params.append(item.key, item.value)
    }
  })

  const query = params.toString()
  if (query.length > 0) {
    urlOutput.value = `${urlBase.value}?${query}${urlHash.value}`
  } else {
    urlOutput.value = `${urlBase.value}${urlHash.value}`
  }
}

function encodeUrlText() {
  urlCodecOutput.value = encodeURIComponent(urlCodecInput.value)
}

function decodeUrlText() {
  try {
    urlCodecOutput.value = decodeURIComponent(urlCodecInput.value)
  } catch (error) {
    ElMessage.error(error.message)
  }
}

function encodeHtmlEntities() {
  htmlEntityOutput.value = htmlEntityInput.value
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;')
}

function decodeHtmlEntities() {
  const textarea = document.createElement('textarea')
  textarea.innerHTML = htmlEntityInput.value
  htmlEntityOutput.value = textarea.value
}

function trimLines() {
  batchTextOutput.value = batchTextInput.value.split('\n').map((line) => line.trim()).join('\n')
}

function removeEmptyLines() {
  batchTextOutput.value = batchTextInput.value.split('\n').filter((line) => line.trim().length > 0).join('\n')
}

function uniqueLines() {
  const seen = new Set()
  const lines = []
  batchTextInput.value.split('\n').forEach((line) => {
    if (!seen.has(line)) {
      seen.add(line)
      lines.push(line)
    }
  })
  batchTextOutput.value = lines.join('\n')
}

function sortLines() {
  batchTextOutput.value = batchTextInput.value.split('\n').sort((left, right) => left.localeCompare(right)).join('\n')
}

function upperCaseText() {
  batchTextOutput.value = batchTextInput.value.toUpperCase()
}

function lowerCaseText() {
  batchTextOutput.value = batchTextInput.value.toLowerCase()
}

function compareText() {
  const leftLines = diffLeft.value.split('\n')
  const rightLines = diffRight.value.split('\n')
  const maxLength = Math.max(leftLines.length, rightLines.length)
  const rows = []

  for (let index = 0; index < maxLength; index += 1) {
    const left = leftLines[index]
    const right = rightLines[index]

    if (left === right) {
      rows.push({
        id: `same-${index}`,
        type: 'same',
        label: '=',
        text: left
      })
    } else {
      if (left !== undefined) {
        rows.push({
          id: `remove-${index}`,
          type: 'remove',
          label: '-',
          text: left
        })
      }

      if (right !== undefined) {
        rows.push({
          id: `add-${index}`,
          type: 'add',
          label: '+',
          text: right
        })
      }
    }
  }

  diffRows.value = rows
}

function runRegex() {
  try {
    const flags = regexFlags.value.includes('g') ? regexFlags.value : `${regexFlags.value}g`
    const regex = new RegExp(regexPattern.value, flags)
    const matches = []
    let match = regex.exec(regexText.value)

    while (match) {
      matches.push({
        index: match.index,
        value: match[0],
        groups: match.slice(1)
      })
      match = regex.exec(regexText.value)
    }

    regexOutput.value = JSON.stringify(matches, null, 2)
  } catch (error) {
    ElMessage.error(error.message)
  }
}

function replaceRegex() {
  try {
    const regex = new RegExp(regexPattern.value, regexFlags.value)
    regexOutput.value = regexText.value.replace(regex, regexReplacement.value)
  } catch (error) {
    ElMessage.error(error.message)
  }
}

function parseUserAgent() {
  userAgentInfo.value = {
    browser: parseBrowser(userAgentInput.value),
    os: parseOperatingSystem(userAgentInput.value),
    device: parseDevice(userAgentInput.value)
  }
}

function parseBrowser(value) {
  if (value.includes('Edg/')) {
    return browserVersion(value, /Edg\/([\d.]+)/, 'Edge')
  }

  if (value.includes('Chrome/')) {
    return browserVersion(value, /Chrome\/([\d.]+)/, 'Chrome')
  }

  if (value.includes('Firefox/')) {
    return browserVersion(value, /Firefox\/([\d.]+)/, 'Firefox')
  }

  if (value.includes('Safari/') && value.includes('Version/')) {
    return browserVersion(value, /Version\/([\d.]+)/, 'Safari')
  }

  return '未知浏览器'
}

function browserVersion(value, pattern, name) {
  const match = value.match(pattern)
  if (match) {
    return `${name} ${match[1]}`
  }

  return name
}

function parseOperatingSystem(value) {
  if (value.includes('Windows NT 10.0')) {
    return 'Windows 10 / 11'
  }

  if (value.includes('Mac OS X')) {
    return 'macOS'
  }

  if (value.includes('Android')) {
    return 'Android'
  }

  if (value.includes('iPhone') || value.includes('iPad')) {
    return 'iOS / iPadOS'
  }

  if (value.includes('Linux')) {
    return 'Linux'
  }

  return '未知系统'
}

function parseDevice(value) {
  if (value.includes('Mobile')) {
    return '移动设备'
  }

  if (value.includes('Tablet') || value.includes('iPad')) {
    return '平板设备'
  }

  return '桌面设备'
}

function extractJsonPaths() {
  try {
    const data = JSON.parse(jsonPathInput.value)
    const paths = []
    walkJsonPaths(data, '', paths)
    jsonPaths.value = paths
  } catch (error) {
    ElMessage.error(error.message)
  }
}

function walkJsonPaths(value, path, paths) {
  if (Array.isArray(value)) {
    value.forEach((item, index) => {
      const nextPath = `${path}[${index}]`
      paths.push(nextPath)
      walkJsonPaths(item, nextPath, paths)
    })
    return
  }

  if (value !== null && typeof value === 'object') {
    Object.keys(value).forEach((key) => {
      const nextPath = path.length > 0 ? `${path}.${key}` : key
      paths.push(nextPath)
      walkJsonPaths(value[key], nextPath, paths)
    })
  }
}

function csvToJson() {
  try {
    const rows = parseCsv(csvJsonInput.value)
    const headers = rows[0]
    const data = rows.slice(1).map((row) => {
      const item = {}
      headers.forEach((header, index) => {
        item[header] = row[index]
      })
      return item
    })
    csvJsonOutput.value = JSON.stringify(data, null, 2)
  } catch (error) {
    ElMessage.error(error.message)
  }
}

function jsonToCsv() {
  try {
    const data = JSON.parse(csvJsonInput.value)
    const headers = Object.keys(data[0])
    const rows = data.map((item) => headers.map((header) => csvCell(item[header])).join(','))
    csvJsonOutput.value = [headers.join(','), ...rows].join('\n')
  } catch (error) {
    ElMessage.error(error.message)
  }
}

function generateMockData() {
  const data = []
  for (let index = 0; index < mockCount.value; index += 1) {
    if (mockScene.value === 'users') {
      data.push(mockUser(index))
    }

    if (mockScene.value === 'orders') {
      data.push(mockOrder(index))
    }

    if (mockScene.value === 'articles') {
      data.push(mockArticle(index))
    }
  }
  mockOutput.value = JSON.stringify(data, null, 2)
}

function mockUser(index) {
  const names = ['林舟', '陈一诺', '周宁', '许然', '沈清', '顾南', '叶安', '赵川']
  const cities = ['上海', '杭州', '深圳', '成都', '南京', '广州', '北京', '苏州']
  return {
    id: index + 1,
    name: names[index % names.length],
    phone: `13${String(800000000 + index * 731).slice(0, 9)}`,
    email: `user${index + 1}@example.com`,
    city: cities[index % cities.length],
    status: index % 3 === 0 ? 'inactive' : 'active',
    createdAt: mockDate(index)
  }
}

function mockOrder(index) {
  const statuses = ['pending', 'paid', 'shipped', 'completed']
  return {
    id: `OD${String(index + 1).padStart(6, '0')}`,
    amount: Number((99 + index * 17.6).toFixed(2)),
    quantity: index % 5 + 1,
    status: statuses[index % statuses.length],
    buyer: `客户 ${index + 1}`,
    createdAt: mockDate(index)
  }
}

function mockArticle(index) {
  const categories = ['设计', '前端', '工具', '效率']
  return {
    id: index + 1,
    title: `示例文章 ${index + 1}`,
    category: categories[index % categories.length],
    author: `作者 ${index % 6 + 1}`,
    views: 120 + index * 37,
    published: index % 4 !== 0,
    createdAt: mockDate(index)
  }
}

function mockDate(index) {
  const date = new Date()
  date.setDate(date.getDate() - index)
  return date.toISOString().slice(0, 10)
}

function parseCsv(text) {
  const rows = []
  let row = []
  let cell = ''
  let quoted = false

  for (let index = 0; index < text.length; index += 1) {
    const char = text[index]
    const nextChar = text[index + 1]

    if (char === '"' && quoted && nextChar === '"') {
      cell += '"'
      index += 1
    } else if (char === '"') {
      quoted = !quoted
    } else if (char === ',' && !quoted) {
      row.push(cell)
      cell = ''
    } else if (char === '\n' && !quoted) {
      row.push(cell)
      rows.push(row)
      row = []
      cell = ''
    } else if (char !== '\r') {
      cell += char
    }
  }

  row.push(cell)
  rows.push(row)
  return rows
}

function csvCell(value) {
  const text = String(value)
  if (text.includes(',') || text.includes('"') || text.includes('\n')) {
    return `"${text.replace(/"/g, '""')}"`
  }

  return text
}

function renderMarkdown(text) {
  const lines = escapeHtml(text).split('\n')
  const html = []
  let listOpen = false

  lines.forEach((line) => {
    if (line.startsWith('- ')) {
      if (!listOpen) {
        html.push('<ul>')
        listOpen = true
      }
      html.push(`<li>${inlineMarkdown(line.slice(2))}</li>`)
      return
    }

    if (listOpen) {
      html.push('</ul>')
      listOpen = false
    }

    if (line.startsWith('### ')) {
      html.push(`<h3>${inlineMarkdown(line.slice(4))}</h3>`)
    } else if (line.startsWith('## ')) {
      html.push(`<h2>${inlineMarkdown(line.slice(3))}</h2>`)
    } else if (line.startsWith('# ')) {
      html.push(`<h1>${inlineMarkdown(line.slice(2))}</h1>`)
    } else if (line.length === 0) {
      html.push('<br>')
    } else {
      html.push(`<p>${inlineMarkdown(line)}</p>`)
    }
  })

  if (listOpen) {
    html.push('</ul>')
  }

  return html.join('')
}

function inlineMarkdown(text) {
  return text
    .replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')
    .replace(/`(.+?)`/g, '<code>$1</code>')
    .replace(/\[(.+?)\]\((.+?)\)/g, '<a href="$2" target="_blank" rel="noreferrer">$1</a>')
}

function escapeHtml(text) {
  return text
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;')
}

function formatFileSize(value) {
  if (value >= 1024 * 1024) {
    return `${(value / 1024 / 1024).toFixed(2)} MB`
  }

  return `${(value / 1024).toFixed(1)} KB`
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

parseUrlParams()
compareText()
runRegex()
parseUserAgent()
extractJsonPaths()
csvToJson()
generateMockData()
</script>

<style scoped>
.frontend-tool-shell {
  align-content: start;
}

.frontend-tabs :deep(.el-tabs__header) {
  margin-bottom: 16px;
}

.frontend-tool-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 14px;
}

.frontend-tool-card {
  display: grid;
  align-content: start;
  gap: 12px;
  min-width: 0;
  padding: 14px;
  border: 1px solid rgba(21, 25, 31, 0.1);
  border-radius: 8px;
  background: rgba(255, 255, 255, 0.78);
  box-shadow: 0 10px 24px rgba(44, 55, 67, 0.05);
}

.frontend-tool-card-wide {
  grid-column: 1 / -1;
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

.frontend-control-grid,
.frontend-preview-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 12px;
}

.frontend-control-grid.compact {
  grid-template-columns: repeat(4, minmax(0, 1fr));
}

.frontend-control-grid label,
.frontend-tool-card label {
  display: grid;
  gap: 7px;
  color: #526071;
  font-size: 12px;
  font-weight: 900;
}

.frontend-preview-box {
  min-height: 220px;
  display: grid;
  place-items: center;
  gap: 8px;
  padding: 12px;
  border: 1px solid rgba(21, 25, 31, 0.1);
  border-radius: 8px;
  background:
    linear-gradient(45deg, rgba(21, 25, 31, 0.04) 25%, transparent 25%),
    linear-gradient(-45deg, rgba(21, 25, 31, 0.04) 25%, transparent 25%),
    #ffffff;
  background-size: 18px 18px;
}

.frontend-preview-box.compact {
  min-height: 180px;
}

.frontend-preview-box span {
  color: var(--muted);
  font-size: 12px;
  font-weight: 950;
}

.frontend-preview-image {
  max-width: 100%;
  max-height: 260px;
  cursor: zoom-in;
}

.frontend-preview-box :deep(.el-image__inner) {
  max-width: 100%;
  max-height: 260px;
  object-fit: contain;
}

.frontend-result-line {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
}

.frontend-result-line strong,
.frontend-muted {
  color: #526071;
  font-size: 13px;
  line-height: 1.6;
}

.frontend-inline-link {
  min-height: 38px;
  padding: 0 12px;
  color: var(--ink);
  text-decoration: none;
}

.frontend-chip-grid,
.frontend-color-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.frontend-color-chip {
  min-width: 92px;
  min-height: 54px;
  padding: 8px;
  border: 1px solid rgba(21, 25, 31, 0.1);
  border-radius: 8px;
}

.frontend-color-chip span {
  display: inline-flex;
  padding: 4px 6px;
  border-radius: 6px;
  background: rgba(255, 255, 255, 0.9);
  font-family: "Cascadia Code", "Consolas", monospace;
  font-size: 12px;
  font-weight: 950;
}

.frontend-code {
  min-height: 74px;
  margin: 0;
  padding: 12px;
  border: 1px solid rgba(21, 25, 31, 0.1);
  border-radius: 8px;
  background: #15191f;
  color: #f7ffdc;
  font-family: "Cascadia Code", "Consolas", monospace;
  font-size: 12px;
  line-height: 1.6;
  overflow: auto;
}

.frontend-param-list,
.frontend-path-list,
.frontend-diff-list {
  display: grid;
  gap: 8px;
  max-height: 260px;
  overflow: auto;
}

.frontend-param-row {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 8px;
}

.frontend-diff-row {
  display: grid;
  grid-template-columns: 28px minmax(0, 1fr);
  gap: 8px;
  padding: 8px;
  border-radius: 8px;
  background: #ffffff;
}

.frontend-diff-row.add {
  background: rgba(46, 125, 86, 0.12);
}

.frontend-diff-row.remove {
  background: rgba(255, 104, 79, 0.12);
}

.frontend-diff-row span {
  font-weight: 950;
}

.frontend-diff-row code {
  white-space: pre-wrap;
  word-break: break-word;
}

.frontend-kv-list {
  display: grid;
  grid-template-columns: 72px minmax(0, 1fr);
  gap: 9px;
  padding: 12px;
  border-radius: 8px;
  background: #ffffff;
}

.frontend-kv-list-wide {
  grid-template-columns: 108px minmax(0, 1fr);
}

.frontend-kv-list span {
  color: var(--muted);
  font-size: 12px;
  font-weight: 950;
}

.frontend-kv-list strong {
  color: var(--ink);
  font-weight: 950;
}

.frontend-path-list button {
  width: 100%;
  padding: 8px 10px;
  border: 1px solid rgba(21, 25, 31, 0.1);
  border-radius: 8px;
  background: #ffffff;
  color: var(--blue);
  font-family: "Cascadia Code", "Consolas", monospace;
  font-size: 12px;
  font-weight: 900;
  text-align: left;
}

.frontend-markdown-preview {
  min-height: 432px;
  padding: 16px;
  border: 1px solid rgba(21, 25, 31, 0.1);
  border-radius: 8px;
  background: #ffffff;
  overflow: auto;
}

.frontend-markdown-preview :deep(h1),
.frontend-markdown-preview :deep(h2),
.frontend-markdown-preview :deep(h3) {
  margin: 0 0 12px;
  line-height: 1.18;
}

.frontend-markdown-preview :deep(p) {
  margin: 0 0 10px;
  color: #526071;
  line-height: 1.7;
}

.frontend-markdown-preview :deep(code) {
  padding: 2px 5px;
  border-radius: 5px;
  background: #eef3ff;
  color: var(--blue);
}

@media (max-width: 1180px) {
  .frontend-tool-grid,
  .frontend-preview-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 760px) {
  .frontend-control-grid,
  .frontend-control-grid.compact,
  .frontend-param-row {
    grid-template-columns: 1fr;
  }
}
</style>
