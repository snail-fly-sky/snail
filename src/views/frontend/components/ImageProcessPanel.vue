<template>
  <FloatingImageUploadCard v-model="publicImageModel" />
          <div class="frontend-tool-grid frontend-image-grid">
            <section class="frontend-tool-card frontend-tool-card-main">
              <div class="tool-panel-head">
                <h2>图片格式转换</h2>
                <div class="tool-actions frontend-panel-head-actions">
                  <el-button plain @click="copyText(convertedImageDataUrl)">复制最近结果</el-button>
                  <a
                    v-if="convertedImageDataUrl.length > 0"
                    class="ghost-action frontend-inline-link"
                    :href="convertedImageDataUrl"
                    :download="convertedImageName"
                  >
                    <Download :size="16" />
                    下载
                  </a>
                </div>
              </div>
              <div class="frontend-split-tool frontend-overview-tool">
                <div class="frontend-split-controls">
                  <label class="frontend-file-field">
                    <input type="file" accept="image/*" @change="handleFormatImageFile" />
                    <span>选择转换图片</span>
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
                      压缩质量（%）
                      <el-slider
                        v-model="imageQuality"
                        :min="20"
                        :max="100"
                        :step="5"
                        show-input
                      />
                    </label>
                    <label>
                      输出宽度（px）
                      <el-input-number v-model="resizeWidth" :min="1" controls-position="right" />
                    </label>
                    <label>
                      输出高度（px）
                      <el-input-number v-model="resizeHeight" :min="1" controls-position="right" />
                    </label>
                  </div>
                  <div class="tool-actions frontend-split-actions">
                    <el-button type="primary" @click="convertImage">转换</el-button>
                    <el-button plain @click="convertPublicImage">公用图片转换</el-button>
                  </div>
                </div>
                <div class="frontend-split-preview">
                  <div class="frontend-preview-grid frontend-compare-grid frontend-overview-grid">
                    <div class="frontend-preview-box frontend-overview-card frontend-before-box">
                      <span class="frontend-preview-title">转换前</span>
                      <div class="frontend-overview-content">
                        <div class="frontend-overview-media">
                          <el-image
                            v-if="formatImageDataUrl.length > 0"
                            class="frontend-preview-image"
                            :src="formatImageDataUrl"
                            :preview-src-list="[formatImageDataUrl]"
                            fit="contain"
                            preview-teleported
                            alt="转换前图片预览"
                          />
                          <el-empty
                            v-else
                            class="frontend-empty-state"
                            description="未选择图片"
                            :image-size="54"
                          />
                        </div>
                        <div class="frontend-overview-info">
                          <div
                            v-for="item in formatImageOverviewItems"
                            :key="item.label"
                            class="frontend-overview-info-row"
                          >
                            <span>{{ item.label }}</span>
                            <strong>{{ item.value }}</strong>
                          </div>
                        </div>
                      </div>
                    </div>
                    <div class="frontend-preview-box frontend-overview-card frontend-after-box">
                      <span class="frontend-preview-title">转换后</span>
                      <span v-if="convertedImageDataUrl.length > 0" class="frontend-preview-source">{{ formatProcessSourceText }}</span>
                      <div class="frontend-overview-content">
                        <div class="frontend-overview-media">
                          <el-image
                            v-if="convertedImageDataUrl.length > 0"
                            class="frontend-preview-image"
                            :src="convertedImageDataUrl"
                            :preview-src-list="[convertedImageDataUrl]"
                            fit="contain"
                            preview-teleported
                            alt="转换后图片预览"
                          />
                          <el-empty
                            v-else
                            class="frontend-empty-state"
                            description="未生成结果"
                            :image-size="54"
                          />
                        </div>
                        <div class="frontend-overview-info">
                          <div
                            v-for="item in formatConvertedImageOverviewItems"
                            :key="item.label"
                            class="frontend-overview-info-row"
                          >
                            <span>{{ item.label }}</span>
                            <strong>{{ item.value }}</strong>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </section>

            <section class="frontend-tool-card frontend-tool-card-color">
              <div class="tool-panel-head">
                <h2>图片颜色提取</h2>
              </div>
              <div class="frontend-color-tool">
                <div class="frontend-color-controls">
                  <label class="frontend-file-field">
                    <input type="file" accept="image/*" @change="handleToolImageFile($event, 'color')" />
                    <span>选择提取图片</span>
                  </label>
                  <div class="frontend-preview-box compact frontend-color-preview">
                    <el-image
                      v-if="colorPreviewSrc.length > 0"
                      class="frontend-preview-image"
                      :src="colorPreviewSrc"
                      :preview-src-list="[colorPreviewSrc]"
                      fit="contain"
                      preview-teleported
                      alt="颜色提取图片预览"
                    />
                    <el-empty
                      v-else
                      class="frontend-empty-state"
                      description="未选择图片"
                      :image-size="54"
                    />
                  </div>
                  <p class="frontend-muted">{{ colorImageInfoText }}</p>
                  <div class="tool-actions frontend-split-actions">
                    <el-button plain @click="extractImageColors(imageDataUrl, '请先选择公用图片', '公用图片提取')">公用图片提取</el-button>
                    <el-button type="primary" plain @click="extractImageColors(colorImageDataUrl, '请先选择提取图片', '组件私有上传提取')">处理</el-button>
                  </div>
                </div>
                <div class="frontend-color-display">
                  <div v-if="extractedColors.length > 0" class="frontend-color-result">
                    <div class="frontend-color-result-head">
                      <span>提取来源</span>
                      <strong>{{ colorExtractSourceText }}</strong>
                    </div>
                    <div class="frontend-color-grid frontend-color-result-grid">
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
                  </div>
                  <el-empty
                    v-else
                    class="frontend-empty-state frontend-color-empty"
                    description="未提取颜色"
                    :image-size="48"
                  />
                </div>
              </div>
            </section>

            <section class="frontend-tool-card frontend-tool-card-compress">
              <div class="tool-panel-head">
                <h2>图片压缩</h2>
                <div class="tool-actions frontend-panel-head-actions">
                  <a
                    v-if="compressedImageDataUrl.length > 0"
                    class="ghost-action frontend-inline-link"
                    :href="compressedImageDataUrl"
                    :download="compressedImageName"
                  >
                    <Download :size="16" />
                    下载压缩图
                  </a>
                </div>
              </div>
              <div class="frontend-split-tool frontend-compress-tool">
                <div class="frontend-split-controls">
                  <label class="frontend-file-field">
                    <input type="file" accept="image/*" @change="handleToolImageFile($event, 'compress')" />
                    <span>选择压缩图片</span>
                  </label>
                  <div class="frontend-preview-box compact frontend-compress-source-preview">
                    <el-image
                      v-if="compressSourceDataUrl.length > 0"
                      class="frontend-preview-image"
                      :src="compressSourceDataUrl"
                      :preview-src-list="[compressSourceDataUrl]"
                      fit="contain"
                      preview-teleported
                      alt="压缩源图片预览"
                    />
                    <el-empty
                      v-else
                      class="frontend-empty-state"
                      description="未选择图片"
                      :image-size="54"
                    />
                  </div>
                  <p class="frontend-muted">{{ compressSourceInfoText }}</p>
                  <div class="tool-actions frontend-split-actions">
                    <el-button plain @click="compressImage(imageDataUrl, '请先选择公用图片', '公用图片压缩')">公用图片压缩</el-button>
                    <el-button type="primary" plain @click="compressImage(compressSourceDataUrl, '请先选择压缩图片', '组件私有上传压缩')">处理</el-button>
                  </div>
                </div>
                <div class="frontend-split-preview">
                  <div class="frontend-preview-box frontend-overview-card frontend-after-box frontend-compress-preview">
                    <span class="frontend-preview-title">压缩结果</span>
                    <span v-if="compressedImageDataUrl.length > 0" class="frontend-preview-source">{{ compressProcessSourceText }}</span>
                    <div class="frontend-overview-content">
                      <div class="frontend-overview-media">
                        <el-image
                          v-if="compressedImageDataUrl.length > 0"
                          class="frontend-preview-image"
                          :src="compressedImageDataUrl"
                          :preview-src-list="[compressedImageDataUrl]"
                          fit="contain"
                          preview-teleported
                          alt="压缩图片预览"
                        />
                        <el-empty
                          v-else
                          class="frontend-empty-state"
                          description="未生成结果"
                          :image-size="54"
                        />
                      </div>
                      <div class="frontend-overview-info">
                        <div
                          v-for="item in compressedImageOverviewItems"
                          :key="item.label"
                          class="frontend-overview-info-row"
                        >
                          <span>{{ item.label }}</span>
                          <strong>{{ item.value }}</strong>
                        </div>
                      </div>
                    </div>
                  </div>
                  <div class="frontend-control-grid frontend-compress-settings">
                    <label>
                      压缩质量（%）
                      <el-slider v-model="imageQuality" :min="20" :max="100" :step="5" show-input />
                    </label>
                    <label>
                      输出宽度（px）
                      <el-input-number v-model="resizeWidth" :min="1" controls-position="right" />
                    </label>
                    <label>
                      输出高度（px）
                      <el-input-number v-model="resizeHeight" :min="1" controls-position="right" />
                    </label>
                  </div>
                </div>
              </div>
            </section>

            <section class="frontend-tool-card frontend-tool-card-base64">
              <div class="tool-panel-head">
                <h2>图片 / Base64 互转</h2>
              </div>
              <div class="frontend-base64-tool" :style="base64ToolStyle">
                <div class="frontend-base64-panel">
                  <div class="frontend-base64-controls">
                    <div ref="base64HeightSource" class="frontend-base64-height-source">
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
                          输出质量（%）
                          <el-slider v-model="imageQuality" :min="20" :max="100" :step="5" show-input />
                        </label>
                      </div>
                      <div class="tool-actions frontend-split-actions">
                        <el-button type="primary" plain @click="convertPublicImage">转换</el-button>
                        <el-button plain @click="copyText(convertedImageDataUrl)">复制 Data URL</el-button>
                      </div>
                    </div>
                  </div>
                  <div class="frontend-base64-preview-column">
                    <div class="frontend-preview-box compact frontend-result-preview">
                      <span v-if="convertedImageDataUrl.length > 0" class="frontend-preview-source">{{ formatProcessSourceText }}</span>
                      <el-image
                        v-if="convertedImageDataUrl.length > 0"
                        class="frontend-preview-image"
                        :src="convertedImageDataUrl"
                        :preview-src-list="[convertedImageDataUrl]"
                        fit="contain"
                        preview-teleported
                        alt="格式转换图片预览"
                      />
                      <el-empty
                        v-else
                        class="frontend-empty-state"
                        description="未生成结果"
                        :image-size="54"
                      />
                      <a
                        v-if="convertedImageDataUrl.length > 0"
                        class="ghost-action frontend-base64-download-button"
                        :href="convertedImageDataUrl"
                        :download="convertedImageName"
                      >
                        <Download :size="16" />
                        下载
                      </a>
                    </div>
                  </div>
                </div>

                <div class="frontend-base64-panel">
                  <div class="frontend-base64-controls">
                    <div class="frontend-base64-input-wrap">
                      <el-input
                        v-model="base64Input"
                        type="textarea"
                        :rows="5"
                        resize="none"
                        placeholder="粘贴图片 Base64 或 Data URL"
                      />
                      <el-button
                        class="frontend-base64-preview-button"
                        type="primary"
                        plain
                        @click="previewBase64Image"
                      >
                        预览
                      </el-button>
                    </div>
                  </div>
                  <div class="frontend-base64-preview-column">
                    <div class="frontend-preview-box compact frontend-result-preview">
                      <el-image
                        v-if="base64PreviewSrc.length > 0"
                        class="frontend-preview-image"
                        :src="base64PreviewSrc"
                        :preview-src-list="[base64PreviewSrc]"
                        fit="contain"
                        preview-teleported
                        alt="Base64 图片预览"
                      />
                      <el-empty
                        v-else
                        class="frontend-empty-state"
                        description="未预览图片"
                        :image-size="54"
                      />
                      <a
                        v-if="base64PreviewSrc.length > 0"
                        class="ghost-action frontend-base64-download-button"
                        :href="base64PreviewSrc"
                        download="base64-image.png"
                      >
                        <Download :size="16" />
                        下载
                      </a>
                    </div>
                  </div>
                </div>
              </div>
            </section>

            <section class="frontend-tool-card frontend-tool-card-span-2">
              <div class="tool-panel-head">
                <h2>图片水印</h2>
                <div class="tool-actions frontend-panel-head-actions">
                  <el-button plain @click="copyText(watermarkImageDataUrl)">复制 Data URL</el-button>
                  <a
                    v-if="watermarkImageDataUrl.length > 0"
                    class="ghost-action frontend-inline-link"
                    :href="watermarkImageDataUrl"
                    :download="watermarkImageName"
                  >
                    <Download :size="16" />
                    下载
                  </a>
                </div>
              </div>
              <div class="frontend-split-tool frontend-watermark-tool">
                <div class="frontend-split-controls">
                  <label class="frontend-file-field">
                    <input type="file" accept="image/*" @change="handleToolImageFile($event, 'watermark')" />
                    <span>选择水印图片</span>
                  </label>
                  <div class="frontend-preview-box compact frontend-watermark-source-preview">
                    <el-image
                      v-if="watermarkSourceDataUrl.length > 0"
                      class="frontend-preview-image"
                      :src="watermarkSourceDataUrl"
                      :preview-src-list="[watermarkSourceDataUrl]"
                      fit="contain"
                      preview-teleported
                      alt="水印源图片预览"
                    />
                    <el-empty
                      v-else
                      class="frontend-empty-state"
                      description="未选择图片"
                      :image-size="54"
                    />
                  </div>
                  <p class="frontend-muted">{{ watermarkSourceInfoText }}</p>
                  <div class="tool-actions frontend-split-actions">
                    <el-button plain @click="applyWatermark(imageDataUrl, '请先选择公用图片', '公用图片水印')">公用图片水印</el-button>
                    <el-button type="primary" plain @click="applyWatermark(watermarkSourceDataUrl, '请先选择水印图片', '组件私有上传水印')">处理</el-button>
                  </div>
                </div>
                <div class="frontend-split-preview">
                  <div class="frontend-preview-box frontend-overview-card frontend-after-box frontend-watermark-preview">
                    <span class="frontend-preview-title">水印结果</span>
                    <span v-if="watermarkImageDataUrl.length > 0" class="frontend-preview-source">{{ watermarkProcessSourceText }}</span>
                    <div class="frontend-overview-content">
                      <div class="frontend-overview-media">
                        <el-image
                          v-if="watermarkImageDataUrl.length > 0"
                          class="frontend-preview-image"
                          :src="watermarkImageDataUrl"
                          :preview-src-list="[watermarkImageDataUrl]"
                          fit="contain"
                          preview-teleported
                          alt="水印图片预览"
                        />
                        <el-empty
                          v-else
                          class="frontend-empty-state"
                          description="未生成水印图"
                          :image-size="54"
                        />
                      </div>
                      <div class="frontend-overview-info">
                        <div
                          v-for="item in watermarkImageOverviewItems"
                          :key="item.label"
                          class="frontend-overview-info-row"
                        >
                          <span>{{ item.label }}</span>
                          <strong>{{ item.value }}</strong>
                        </div>
                      </div>
                    </div>
                  </div>
                  <div class="frontend-control-grid frontend-watermark-settings">
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
                      字号（px）
                      <el-slider v-model="watermarkFontSize" :min="12" :max="96" :step="2" show-input />
                    </label>
                    <label>
                      透明度（%）
                      <el-slider v-model="watermarkOpacity" :min="10" :max="90" :step="5" show-input />
                    </label>
                    <label>
                      文字颜色
                      <el-color-picker v-model="watermarkColor" color-format="hex" />
                    </label>
                    <label>
                      边距（px）
                      <el-input-number v-model="watermarkPadding" :min="0" controls-position="right" />
                    </label>
                  </div>
                </div>
              </div>
            </section>

            <section class="frontend-tool-card frontend-tool-card-span-2">
              <div class="tool-panel-head">
                <h2>图片 EXIF 查看 / 清理</h2>
                <div class="tool-actions frontend-panel-head-actions">
                  <el-button plain @click="copyText(exifCleanImageDataUrl)">复制 Data URL</el-button>
                  <a
                    v-if="exifCleanImageDataUrl.length > 0"
                    class="ghost-action frontend-inline-link"
                    :href="exifCleanImageDataUrl"
                    :download="exifCleanImageName"
                  >
                    <Download :size="16" />
                    下载
                  </a>
                </div>
              </div>
              <div class="frontend-split-tool frontend-exif-tool">
                <div class="frontend-split-controls">
                  <label class="frontend-file-field">
                    <input type="file" accept="image/*" @change="handleToolImageFile($event, 'exif')" />
                    <span>选择 EXIF 图片</span>
                  </label>
                  <div class="frontend-preview-box compact frontend-exif-source-preview">
                    <el-image
                      v-if="exifSourceDataUrl.length > 0"
                      class="frontend-preview-image"
                      :src="exifSourceDataUrl"
                      :preview-src-list="[exifSourceDataUrl]"
                      fit="contain"
                      preview-teleported
                      alt="EXIF 源图片预览"
                    />
                    <el-empty
                      v-else
                      class="frontend-empty-state"
                      description="未选择 EXIF 图片"
                      :image-size="54"
                    />
                  </div>
                  <p class="frontend-muted">{{ exifSourceInfoText }}</p>
                  <div class="tool-actions frontend-split-actions">
                    <el-button plain @click="viewImageExif">查看信息</el-button>
                    <el-button type="primary" plain @click="cleanImageExif">清理元数据</el-button>
                  </div>
                </div>
                <div class="frontend-split-preview">
                  <div class="frontend-preview-box frontend-overview-card frontend-after-box frontend-exif-preview">
                    <span class="frontend-preview-title">清理结果</span>
                    <div class="frontend-overview-content">
                      <div class="frontend-overview-media">
                        <el-image
                          v-if="exifCleanImageDataUrl.length > 0"
                          class="frontend-preview-image"
                          :src="exifCleanImageDataUrl"
                          :preview-src-list="[exifCleanImageDataUrl]"
                          fit="contain"
                          preview-teleported
                          alt="EXIF 清理图片预览"
                        />
                        <el-empty
                          v-else
                          class="frontend-empty-state"
                          description="未生成清理图"
                          :image-size="54"
                        />
                      </div>
                      <div class="frontend-overview-info">
                        <div
                          v-for="item in exifCleanImageOverviewItems"
                          :key="item.label"
                          class="frontend-overview-info-row"
                        >
                          <span>{{ item.label }}</span>
                          <strong>{{ item.value }}</strong>
                        </div>
                      </div>
                    </div>
                  </div>
                  <p class="frontend-muted">清理会通过 Canvas 重新导出图片，常见 EXIF、拍摄设备、定位等元数据会被移除。</p>
                </div>
              </div>
            </section>
          </div>
          <el-dialog
            v-model="exifDialogVisible"
            title="图片 EXIF 信息"
            width="680px"
            class="frontend-exif-dialog"
            align-center
          >
            <el-descriptions :column="1" border>
              <el-descriptions-item
                v-for="item in exifItems"
                :key="item.label"
                :label="item.label"
              >
                {{ item.value }}
              </el-descriptions-item>
            </el-descriptions>
          </el-dialog>
</template>

<script setup>
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'
import { ElMessage } from 'element-plus'
import { Download } from 'lucide-vue-next'
import FloatingImageUploadCard from './FloatingImageUploadCard.vue'

const imageFile = ref()
const imageFileName = ref('')
const imageDataUrl = ref('')
const formatImageFile = ref()
const formatImageFileName = ref('')
const formatImageDataUrl = ref('')
const colorImageFileName = ref('')
const colorImageDataUrl = ref('')
const colorPreviewSrc = ref('')
const compressSourceFileName = ref('')
const compressSourceDataUrl = ref('')
const watermarkSourceFileName = ref('')
const watermarkSourceDataUrl = ref('')
const exifSourceFile = ref()
const exifSourceFileName = ref('')
const exifSourceDataUrl = ref('')
const processedImageDataUrl = ref('')
const compressedImageDataUrl = ref('')
const convertedImageDataUrl = ref('')
const watermarkImageDataUrl = ref('')
const exifCleanImageDataUrl = ref('')
const exifDialogVisible = ref(false)
const imageFormat = ref('image/webp')
const imageQuality = ref(80)
const resizeWidth = ref(320)
const resizeHeight = ref(320)
const imageInfo = ref({
  width: 0,
  height: 0,
  size: 0
})
const formatImageInfo = ref({
  width: 0,
  height: 0,
  size: 0,
  type: '',
  lastModified: 0,
  source: ''
})
const colorImageInfo = ref({
  width: 0,
  height: 0,
  size: 0,
  type: '',
  lastModified: 0
})
const compressSourceInfo = ref({
  width: 0,
  height: 0,
  size: 0,
  type: '',
  lastModified: 0
})
const watermarkSourceInfo = ref({
  width: 0,
  height: 0,
  size: 0,
  type: '',
  lastModified: 0
})
const exifSourceInfo = ref({
  width: 0,
  height: 0,
  size: 0,
  type: '',
  lastModified: 0
})
const processedImageInfo = ref({
  width: 0,
  height: 0,
  size: 0,
  type: '',
  quality: 0,
  name: ''
})
const formatConvertedImageInfo = ref({
  width: 0,
  height: 0,
  size: 0,
  type: '',
  quality: 0,
  name: ''
})
const compressedImageInfo = ref({
  width: 0,
  height: 0,
  size: 0,
  type: '',
  quality: 0,
  name: ''
})
const watermarkImageInfo = ref({
  width: 0,
  height: 0,
  size: 0,
  type: '',
  quality: 0,
  name: ''
})
const exifCleanImageInfo = ref({
  width: 0,
  height: 0,
  size: 0,
  type: '',
  name: ''
})
const base64Input = ref('')
const base64PreviewSrc = ref('')
const extractedColors = ref([])
const colorExtractSourceText = ref('未提取')
const compressProcessSourceText = ref('未压缩')
const watermarkProcessSourceText = ref('未生成')
const watermarkText = ref('Snail Tools')
const watermarkPosition = ref('bottom-right')
const watermarkFontSize = ref(32)
const watermarkOpacity = ref(35)
const watermarkColor = ref('#ffffff')
const watermarkPadding = ref(32)
const exifItems = ref([
  { label: '状态', value: '未选择图片' }
])
const base64HeightSource = ref()
const base64ToolStyle = ref({})
let base64HeightObserver

function syncBase64PanelHeight() {
  base64ToolStyle.value = {
    '--frontend-base64-panel-height': `${base64HeightSource.value.offsetHeight}px`
  }
}

onMounted(() => {
  syncBase64PanelHeight()
  base64HeightObserver = new ResizeObserver(syncBase64PanelHeight)
  base64HeightObserver.observe(base64HeightSource.value)
})

onBeforeUnmount(() => {
  base64HeightObserver.disconnect()
})

const publicImageModel = computed({
  get() {
    if (imageDataUrl.value.length === 0) {
      return createEmptyImageUploadModel()
    }

    return {
      file: imageFile.value,
      name: imageFileName.value,
      dataUrl: imageDataUrl.value,
      width: imageInfo.value.width,
      height: imageInfo.value.height,
      size: imageInfo.value.size,
      type: imageFile.value.type,
      lastModified: imageFile.value.lastModified
    }
  },
  set(value) {
    imageFileName.value = value.name
    imageFile.value = value.file
    imageDataUrl.value = value.dataUrl
    imageInfo.value = {
      width: value.width,
      height: value.height,
      size: value.size
    }
    resizeWidth.value = value.width
    resizeHeight.value = value.height
    resetPublicImageResults()
  }
})

const formatImageOverviewItems = computed(() => {
  if (formatImageDataUrl.value.length === 0) {
    return [
      { label: '状态', value: '未选择图片' },
      { label: '信息', value: '选择图片后展示转换详情' }
    ]
  }

  return [
    { label: '来源', value: formatImageInfo.value.source },
    { label: '文件名', value: formatImageFileName.value },
    { label: '格式', value: formatImageType(formatImageInfo.value.type) },
    { label: '大小', value: formatFileSize(formatImageInfo.value.size) },
    { label: '尺寸', value: `${formatImageInfo.value.width} x ${formatImageInfo.value.height}` },
    { label: '修改时间', value: new Date(formatImageInfo.value.lastModified).toLocaleString() }
  ]
})

const formatConvertedImageOverviewItems = computed(() => {
  if (convertedImageDataUrl.value.length === 0) {
    return [
      { label: '状态', value: '未生成结果' },
      { label: '输出格式', value: formatImageType(imageFormat.value) },
      { label: '输出尺寸', value: `${resizeWidth.value} x ${resizeHeight.value}` },
      { label: '输出质量', value: `${imageQuality.value}%` }
    ]
  }

  return [
    { label: '文件名', value: formatConvertedImageInfo.value.name },
    { label: '格式', value: formatImageType(formatConvertedImageInfo.value.type) },
    { label: '大小', value: formatFileSize(formatConvertedImageInfo.value.size) },
    { label: '尺寸', value: `${formatConvertedImageInfo.value.width} x ${formatConvertedImageInfo.value.height}` },
    { label: '质量', value: `${formatConvertedImageInfo.value.quality}%` }
  ]
})

const formatProcessSourceText = computed(() => {
  if (convertedImageDataUrl.value.length === 0) {
    return '未转换'
  }

  if (formatImageInfo.value.source === '公用图片') {
    return '公用图片转换'
  }

  if (formatImageInfo.value.source === '组件私有上传') {
    return '组件私有上传转换'
  }

  return '未转换'
})

const processedImageOverviewItems = computed(() => {
  if (processedImageDataUrl.value.length === 0) {
    return [
      { label: '状态', value: '未生成结果' },
      { label: '输出格式', value: formatImageType(imageFormat.value) },
      { label: '输出质量', value: `${imageQuality.value}%` }
    ]
  }

  return [
    { label: '文件名', value: processedImageInfo.value.name },
    { label: '格式', value: formatImageType(processedImageInfo.value.type) },
    { label: '大小', value: formatFileSize(processedImageInfo.value.size) },
    { label: '尺寸', value: `${processedImageInfo.value.width} x ${processedImageInfo.value.height}` },
    { label: '质量', value: `${processedImageInfo.value.quality}%` }
  ]
})

const compressedImageOverviewItems = computed(() => {
  if (compressedImageDataUrl.value.length === 0) {
    return [
      { label: '状态', value: '未生成结果' },
      { label: '输出尺寸', value: `${resizeWidth.value} x ${resizeHeight.value}` },
      { label: '压缩质量', value: `${imageQuality.value}%` }
    ]
  }

  return [
    { label: '文件名', value: compressedImageInfo.value.name },
    { label: '格式', value: formatImageType(compressedImageInfo.value.type) },
    { label: '大小', value: formatFileSize(compressedImageInfo.value.size) },
    { label: '尺寸', value: `${compressedImageInfo.value.width} x ${compressedImageInfo.value.height}` },
    { label: '质量', value: `${compressedImageInfo.value.quality}%` }
  ]
})

const watermarkImageOverviewItems = computed(() => {
  if (watermarkImageDataUrl.value.length === 0) {
    return [
      { label: '状态', value: '未生成结果' },
      { label: '水印文字', value: watermarkText.value },
      { label: '位置', value: watermarkPositionText.value },
      { label: '透明度', value: `${watermarkOpacity.value}%` }
    ]
  }

  return [
    { label: '文件名', value: watermarkImageInfo.value.name },
    { label: '格式', value: formatImageType(watermarkImageInfo.value.type) },
    { label: '大小', value: formatFileSize(watermarkImageInfo.value.size) },
    { label: '尺寸', value: `${watermarkImageInfo.value.width} x ${watermarkImageInfo.value.height}` },
    { label: '透明度', value: `${watermarkImageInfo.value.quality}%` }
  ]
})

const exifCleanImageOverviewItems = computed(() => {
  if (exifCleanImageDataUrl.value.length === 0) {
    return [
      { label: '状态', value: '未生成清理图' },
      { label: '来源', value: '组件私有上传' },
      { label: '处理', value: '点击清理元数据后展示结果' }
    ]
  }

  return [
    { label: '文件名', value: exifCleanImageInfo.value.name },
    { label: '格式', value: formatImageType(exifCleanImageInfo.value.type) },
    { label: '大小', value: formatFileSize(exifCleanImageInfo.value.size) },
    { label: '尺寸', value: `${exifCleanImageInfo.value.width} x ${exifCleanImageInfo.value.height}` },
    { label: '状态', value: '已重新导出' }
  ]
})

const watermarkPositionText = computed(() => {
  if (watermarkPosition.value === 'bottom-right') {
    return '右下角'
  }

  if (watermarkPosition.value === 'bottom-left') {
    return '左下角'
  }

  if (watermarkPosition.value === 'center') {
    return '居中'
  }

  return '平铺'
})

const colorImageInfoText = computed(() => {
  if (colorImageDataUrl.value.length === 0) {
    return '未选择提取图片'
  }

  return `${colorImageFileName.value} · ${colorImageInfo.value.width}x${colorImageInfo.value.height} · ${formatFileSize(colorImageInfo.value.size)}`
})

const compressSourceInfoText = computed(() => {
  if (compressSourceDataUrl.value.length === 0) {
    return '未选择压缩图片'
  }

  return `${compressSourceFileName.value} · ${compressSourceInfo.value.width}x${compressSourceInfo.value.height} · ${formatFileSize(compressSourceInfo.value.size)}`
})

const watermarkSourceInfoText = computed(() => {
  if (watermarkSourceDataUrl.value.length === 0) {
    return '未选择水印图片'
  }

  return `${watermarkSourceFileName.value} · ${watermarkSourceInfo.value.width}x${watermarkSourceInfo.value.height} · ${formatFileSize(watermarkSourceInfo.value.size)}`
})

const exifSourceInfoText = computed(() => {
  if (exifSourceDataUrl.value.length === 0) {
    return '未选择 EXIF 图片'
  }

  return `${exifSourceFileName.value} · ${exifSourceInfo.value.width}x${exifSourceInfo.value.height} · ${formatFileSize(exifSourceInfo.value.size)}`
})

const imageExtension = computed(() => {
  if (imageFormat.value === 'image/jpeg') {
    return 'jpg'
  }

  return imageFormat.value.replace('image/', '')
})

const processedImageName = computed(() => {
  if (processedImageDataUrl.value.length > 0) {
    return processedImageInfo.value.name
  }

  return `snail-image.${imageExtension.value}`
})

const convertedImageName = computed(() => {
  if (convertedImageDataUrl.value.length > 0) {
    return formatConvertedImageInfo.value.name
  }

  return `snail-converted-image.${imageExtension.value}`
})

const compressedImageName = computed(() => {
  if (compressedImageDataUrl.value.length > 0) {
    return compressedImageInfo.value.name
  }

  return `snail-compressed-image.${imageExtension.value}`
})

const watermarkImageName = computed(() => {
  if (watermarkImageDataUrl.value.length > 0) {
    return watermarkImageInfo.value.name
  }

  return `snail-watermark-image.${imageExtension.value}`
})

const exifCleanImageName = computed(() => {
  if (exifCleanImageDataUrl.value.length > 0) {
    return exifCleanImageInfo.value.name
  }

  return `snail-clean-image.${imageExtension.value}`
})

function createEmptyImageUploadModel() {
  return {
    file: undefined,
    name: '',
    dataUrl: '',
    width: 0,
    height: 0,
    size: 0,
    type: '',
    lastModified: 0
  }
}

function resetPublicImageResults() {
  processedImageDataUrl.value = ''
  processedImageInfo.value = {
    width: 0,
    height: 0,
    size: 0,
    type: '',
    quality: 0,
    name: ''
  }
  resetCompressedImageResult()
  resetWatermarkImageResult()
  extractedColors.value = []
  colorExtractSourceText.value = '未提取'
}

function resetCompressedImageResult() {
  compressedImageDataUrl.value = ''
  compressProcessSourceText.value = '未压缩'
  compressedImageInfo.value = {
    width: 0,
    height: 0,
    size: 0,
    type: '',
    quality: 0,
    name: ''
  }
}

function resetExifCleanImageResult() {
  exifCleanImageDataUrl.value = ''
  exifCleanImageInfo.value = {
    width: 0,
    height: 0,
    size: 0,
    type: '',
    name: ''
  }
}

function resetWatermarkImageResult() {
  watermarkImageDataUrl.value = ''
  watermarkProcessSourceText.value = '未生成'
  watermarkImageInfo.value = {
    width: 0,
    height: 0,
    size: 0,
    type: '',
    quality: 0,
    name: ''
  }
}

function handleFormatImageFile(event) {
  const file = event.target.files[0]

  if (!file) {
    return
  }

  formatImageFileName.value = file.name
  formatImageFile.value = file
  formatImageInfo.value = {
    width: 0,
    height: 0,
    size: file.size,
    type: file.type,
    lastModified: file.lastModified,
    source: '组件私有上传'
  }

  const reader = new FileReader()
  reader.onload = () => {
    formatImageDataUrl.value = reader.result
    resetFormatConvertedImageResult()
    readFormatImageSize(reader.result)
  }
  reader.readAsDataURL(file)
}

function readFormatImageSize(src) {
  const image = new Image()
  image.onload = () => {
    formatImageInfo.value.width = image.naturalWidth
    formatImageInfo.value.height = image.naturalHeight
    resizeWidth.value = image.naturalWidth
    resizeHeight.value = image.naturalHeight
  }
  image.src = src
}

function handleToolImageFile(event, target) {
  const file = event.target.files[0]

  if (!file) {
    return
  }

  if (target === 'color') {
    colorImageFileName.value = file.name
    colorImageInfo.value = {
      width: 0,
      height: 0,
      size: file.size,
      type: file.type,
      lastModified: file.lastModified
    }
  }

  if (target === 'compress') {
    compressSourceFileName.value = file.name
    compressSourceInfo.value = {
      width: 0,
      height: 0,
      size: file.size,
      type: file.type,
      lastModified: file.lastModified
    }
  }

  if (target === 'watermark') {
    watermarkSourceFileName.value = file.name
    watermarkSourceInfo.value = {
      width: 0,
      height: 0,
      size: file.size,
      type: file.type,
      lastModified: file.lastModified
    }
  }

  if (target === 'exif') {
    exifSourceFile.value = file
    exifSourceFileName.value = file.name
    exifSourceInfo.value = {
      width: 0,
      height: 0,
      size: file.size,
      type: file.type,
      lastModified: file.lastModified
    }
  }

  const reader = new FileReader()
  reader.onload = () => {
    if (target === 'color') {
      colorImageDataUrl.value = reader.result
      colorPreviewSrc.value = reader.result
      extractedColors.value = []
      colorExtractSourceText.value = '未提取'
      readToolImageSize(reader.result, target)
      return
    }

    if (target === 'compress') {
      compressSourceDataUrl.value = reader.result
      resetCompressedImageResult()
      readToolImageSize(reader.result, target)
    }

    if (target === 'watermark') {
      watermarkSourceDataUrl.value = reader.result
      resetWatermarkImageResult()
      readToolImageSize(reader.result, target)
    }

    if (target === 'exif') {
      exifSourceDataUrl.value = reader.result
      resetExifCleanImageResult()
      exifItems.value = [
        { label: '状态', value: '已选择图片，点击查看信息' }
      ]
      readToolImageSize(reader.result, target)
    }
  }
  reader.readAsDataURL(file)
}

function readToolImageSize(src, target) {
  const image = new Image()
  image.onload = () => {
    if (target === 'color') {
      colorImageInfo.value.width = image.naturalWidth
      colorImageInfo.value.height = image.naturalHeight
    }

    if (target === 'compress') {
      compressSourceInfo.value.width = image.naturalWidth
      compressSourceInfo.value.height = image.naturalHeight
      resizeWidth.value = image.naturalWidth
      resizeHeight.value = image.naturalHeight
    }

    if (target === 'watermark') {
      watermarkSourceInfo.value.width = image.naturalWidth
      watermarkSourceInfo.value.height = image.naturalHeight
    }

    if (target === 'exif') {
      exifSourceInfo.value.width = image.naturalWidth
      exifSourceInfo.value.height = image.naturalHeight
    }
  }
  image.src = src
}

async function compressImage(src, emptyMessage, sourceText) {
  if (src.length === 0) {
    ElMessage.warning(emptyMessage)
    return
  }

  const dataUrl = await new Promise((resolve) => {
    const image = new Image()
    image.onload = () => {
      const canvas = document.createElement('canvas')
      canvas.width = resizeWidth.value
      canvas.height = resizeHeight.value
      const context = canvas.getContext('2d')
      context.clearRect(0, 0, canvas.width, canvas.height)
      context.drawImage(image, 0, 0, image.naturalWidth, image.naturalHeight, 0, 0, canvas.width, canvas.height)
      resolve(canvas.toDataURL(imageFormat.value, imageQuality.value / 100))
    }
    image.src = src
  })

  setCompressedImageResult(dataUrl, resizeWidth.value, resizeHeight.value)
  setProcessedImageResult(dataUrl, resizeWidth.value, resizeHeight.value)
  compressProcessSourceText.value = sourceText
  ElMessage.success('图片压缩完成')
}

async function convertImage() {
  const dataUrl = await renderFormatImageDataUrl()
  if (dataUrl.length === 0) {
    return
  }

  setFormatConvertedImageResult(dataUrl, resizeWidth.value, resizeHeight.value)
  setProcessedImageResult(dataUrl, resizeWidth.value, resizeHeight.value)
  ElMessage.success('图片格式转换完成')
}

async function convertPublicImage() {
  if (imageDataUrl.value.length === 0) {
    ElMessage.warning('请先选择公用图片')
    return
  }

  usePublicImageForFormatConversion()
  await convertImage()
}

function usePublicImageForFormatConversion() {
  formatImageFileName.value = imageFileName.value
  formatImageFile.value = imageFile.value
  formatImageDataUrl.value = imageDataUrl.value
  formatImageInfo.value = {
    width: imageInfo.value.width,
    height: imageInfo.value.height,
    size: imageInfo.value.size,
    type: imageFile.value.type,
    lastModified: imageFile.value.lastModified,
    source: '公用图片'
  }
  resizeWidth.value = imageInfo.value.width
  resizeHeight.value = imageInfo.value.height
  resetFormatConvertedImageResult()
}

function renderImageDataUrl(src, sourceX, sourceY, sourceWidth, sourceHeight, targetWidth, targetHeight) {
  if (src.length === 0) {
    ElMessage.warning('请先选择 EXIF 图片')
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
    image.src = src
  })
}

function renderFormatImageDataUrl() {
  if (formatImageDataUrl.value.length === 0) {
    ElMessage.warning('请先选择转换图片')
    return Promise.resolve('')
  }

  return new Promise((resolve) => {
    const image = new Image()
    image.onload = () => {
      const canvas = document.createElement('canvas')
      canvas.width = resizeWidth.value
      canvas.height = resizeHeight.value
      const context = canvas.getContext('2d')
      context.clearRect(0, 0, canvas.width, canvas.height)
      context.drawImage(image, 0, 0, image.naturalWidth, image.naturalHeight, 0, 0, canvas.width, canvas.height)
      resolve(canvas.toDataURL(imageFormat.value, imageQuality.value / 100))
    }
    image.src = formatImageDataUrl.value
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

function extractImageColors(src, emptyMessage, sourceText) {
  if (src.length === 0) {
    ElMessage.warning(emptyMessage)
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
    colorExtractSourceText.value = sourceText
  }
  image.src = src
}

function applyWatermark(src, emptyMessage, sourceText) {
  if (src.length === 0) {
    ElMessage.warning(emptyMessage)
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
    const dataUrl = canvas.toDataURL(imageFormat.value, imageQuality.value / 100)
    setWatermarkImageResult(dataUrl, canvas.width, canvas.height)
    setProcessedImageResult(dataUrl, canvas.width, canvas.height)
    watermarkProcessSourceText.value = sourceText
    ElMessage.success('水印图片已生成')
  }
  image.src = src
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
  if (!exifSourceFile.value) {
    ElMessage.warning('请先选择 EXIF 图片')
    return
  }

  const items = [
    { label: '文件名', value: exifSourceFile.value.name },
    { label: '类型', value: exifSourceFile.value.type },
    { label: '大小', value: formatFileSize(exifSourceFile.value.size) },
    { label: '尺寸', value: `${exifSourceInfo.value.width}x${exifSourceInfo.value.height}` },
    { label: '修改时间', value: new Date(exifSourceFile.value.lastModified).toLocaleString() }
  ]

  if (exifSourceFile.value.type === 'image/jpeg') {
    const buffer = await exifSourceFile.value.arrayBuffer()
    parseJpegExif(buffer).forEach((item) => {
      items.push(item)
    })
  } else {
    items.push({ label: 'EXIF', value: '当前仅解析 JPEG EXIF；可直接清理元数据' })
  }

  exifItems.value = items
  exifDialogVisible.value = true
}

async function cleanImageExif() {
  if (exifSourceDataUrl.value.length === 0) {
    ElMessage.warning('请先选择 EXIF 图片')
    return
  }

  const dataUrl = await renderImageDataUrl(
    exifSourceDataUrl.value,
    0,
    0,
    exifSourceInfo.value.width,
    exifSourceInfo.value.height,
    exifSourceInfo.value.width,
    exifSourceInfo.value.height
  )
  if (dataUrl.length === 0) {
    return
  }

  setExifCleanImageResult(dataUrl, exifSourceInfo.value.width, exifSourceInfo.value.height)
  setProcessedImageResult(dataUrl, exifSourceInfo.value.width, exifSourceInfo.value.height)
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

function setProcessedImageResult(dataUrl, width, height) {
  const type = dataUrlMimeType(dataUrl)
  processedImageInfo.value = {
    width,
    height,
    size: dataUrlFileSize(dataUrl),
    type,
    quality: imageQuality.value,
    name: `snail-image.${imageTypeExtension(type)}`
  }
  processedImageDataUrl.value = dataUrl
}

function resetFormatConvertedImageResult() {
  convertedImageDataUrl.value = ''
  formatConvertedImageInfo.value = {
    width: 0,
    height: 0,
    size: 0,
    type: '',
    quality: 0,
    name: ''
  }
}

function setFormatConvertedImageResult(dataUrl, width, height) {
  const type = dataUrlMimeType(dataUrl)
  formatConvertedImageInfo.value = {
    width,
    height,
    size: dataUrlFileSize(dataUrl),
    type,
    quality: imageQuality.value,
    name: `snail-converted-image.${imageTypeExtension(type)}`
  }
  convertedImageDataUrl.value = dataUrl
}

function setCompressedImageResult(dataUrl, width, height) {
  const type = dataUrlMimeType(dataUrl)
  compressedImageInfo.value = {
    width,
    height,
    size: dataUrlFileSize(dataUrl),
    type,
    quality: imageQuality.value,
    name: `snail-compressed-image.${imageTypeExtension(type)}`
  }
  compressedImageDataUrl.value = dataUrl
}

function setWatermarkImageResult(dataUrl, width, height) {
  const type = dataUrlMimeType(dataUrl)
  watermarkImageInfo.value = {
    width,
    height,
    size: dataUrlFileSize(dataUrl),
    type,
    quality: watermarkOpacity.value,
    name: `snail-watermark-image.${imageTypeExtension(type)}`
  }
  watermarkImageDataUrl.value = dataUrl
}

function setExifCleanImageResult(dataUrl, width, height) {
  const type = dataUrlMimeType(dataUrl)
  exifCleanImageInfo.value = {
    width,
    height,
    size: dataUrlFileSize(dataUrl),
    type,
    name: `snail-clean-image.${imageTypeExtension(type)}`
  }
  exifCleanImageDataUrl.value = dataUrl
}

function dataUrlFileSize(dataUrl) {
  const base64 = dataUrl.slice(dataUrl.indexOf(',') + 1)
  let padding = 0

  if (base64.endsWith('==')) {
    padding = 2
  }

  if (base64.endsWith('=') && padding === 0) {
    padding = 1
  }

  return Math.round(base64.length * 3 / 4 - padding)
}

function dataUrlMimeType(dataUrl) {
  return dataUrl.slice(5, dataUrl.indexOf(';'))
}

function formatImageType(value) {
  if (value === 'image/jpeg') {
    return 'JPG'
  }

  if (value === 'image/png') {
    return 'PNG'
  }

  if (value === 'image/webp') {
    return 'WebP'
  }

  if (value === 'image/gif') {
    return 'GIF'
  }

  if (value === 'image/svg+xml') {
    return 'SVG'
  }

  return value
}

function imageTypeExtension(value) {
  if (value === 'image/jpeg') {
    return 'jpg'
  }

  return value.replace('image/', '')
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

function getActiveCopyText() {
  return processedImageDataUrl.value
}

defineExpose({
  getActiveCopyText
})
</script>
