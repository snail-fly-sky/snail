<template>
  <main class="tool-page color-tool-page">
    <header class="tool-header">
      <button class="ghost-action" type="button" @click="goHome">
        <ArrowLeft :size="18" />
        首页
      </button>
      <div>
        <p class="eyebrow">Color Tool</p>
        <h1>颜色取值</h1>
      </div>
      <el-button type="primary" @click="addPaletteColor">
        <Plus :size="18" />
        加入色板
      </el-button>
    </header>

    <section class="tool-grid color-tool-grid">
      <div class="tool-panel color-palette-menu-panel">
        <section class="color-palette-list-section" aria-label="项目色板">
          <div class="color-palette-list-head">
            <span>色板</span>
            <strong>项目色板</strong>
          </div>
          <div class="color-palette-list">
            <button
              v-for="item in palette"
              :key="item.hex"
              class="color-palette-list-item"
              type="button"
              @click="selectColor(item.hex)"
            >
              <span class="color-palette-list-swatch" :style="{ background: item.hex }"></span>
              <strong>{{ item.name }}</strong>
              <small>{{ item.hex }}</small>
            </button>
          </div>
        </section>
      </div>

      <div class="tool-panel color-picker-panel">
        <div class="tool-panel-head">
          <h2>取色</h2>
          <label class="color-picker-field">
            <span class="color-picker-label">
              <strong>取色器</strong>
              <small>{{ selectedColor }}</small>
            </span>
            <el-color-picker
              v-model="selectedColor"
              class="color-picker-control"
              color-format="hex"
              :predefine="predefineColors"
            />
          </label>
        </div>
        <div class="color-hero-swatch" :style="{ background: selectedColor }">
          <span>{{ selectedColor }}</span>
        </div>
        <form class="tool-result-group" @submit.prevent="convertColorInput">
          <label class="eyebrow" for="color-converter-input">颜色转换</label>
          <el-input
            id="color-converter-input"
            v-model="colorInput"
            clearable
            placeholder="HEX / rgb(37, 87, 246) / hsl(224, 93%, 55%)"
          />
          <el-button type="primary" native-type="submit">转换</el-button>
        </form>
        <section class="color-palette-list-section" aria-label="项目色板">
          <div class="color-palette-list-head">
            <span>色板</span>
            <strong>项目色板</strong>
          </div>
          <div class="color-palette-list">
            <button
              v-for="item in palette"
              :key="item.hex"
              class="color-palette-list-item"
              type="button"
              @click="selectColor(item.hex)"
            >
              <span class="color-palette-list-swatch" :style="{ background: item.hex }"></span>
              <strong>{{ item.name }}</strong>
              <small>{{ item.hex }}</small>
            </button>
          </div>
        </section>
      </div>

      <div class="tool-panel">
        <div class="tool-panel-head">
          <h2>色值</h2>
        </div>
        <div class="color-value-list">
          <button
            v-for="item in colorValues"
            :key="item.label"
            class="color-value-item"
            type="button"
            @click="copyText(item.value)"
          >
            <span>{{ item.label }}</span>
            <strong>{{ item.value }}</strong>
            <Copy :size="16" />
          </button>
        </div>
      </div>

      <div class="tool-panel gradient-panel">
        <div class="tool-panel-head">
          <h2>渐变色</h2>
          <el-button type="primary" plain @click="copyText(gradientCss)">
            <Copy :size="16" />
            复制 CSS
          </el-button>
        </div>
        <div class="gradient-builder">
          <div class="gradient-preview" :style="{ background: gradientCss }">
            <span
              role="button"
              tabindex="0"
              @click.stop="copyText(gradientCss)"
              @keydown.enter.stop.prevent="copyText(gradientCss)"
              @keydown.space.stop.prevent="copyText(gradientCss)"
            >
              {{ gradientCss }}
            </span>
          </div>
          <div class="gradient-controls">
            <label class="gradient-control-field">
              <span>起始色</span>
              <strong>{{ selectedColor }}</strong>
              <el-color-picker
                v-model="selectedColor"
                color-format="hex"
                :predefine="predefineColors"
              />
            </label>
            <label class="gradient-control-field">
              <span>结束色</span>
              <strong>{{ gradientEndColor }}</strong>
              <el-color-picker
                v-model="gradientEndColor"
                color-format="hex"
                :predefine="predefineColors"
              />
            </label>
            <label class="gradient-control-field gradient-direction-field">
              <span>方向</span>
              <el-select v-model="gradientDirection">
                <el-option
                  v-for="item in gradientDirections"
                  :key="item.value"
                  :label="item.label"
                  :value="item.value"
                />
              </el-select>
            </label>
          </div>
        </div>
      </div>
    </section>

    <section class="portal-section color-palette-section" aria-label="项目色板">
      <div class="portal-section-head">
        <span>色板</span>
        <h2>项目色板</h2>
      </div>
      <div class="color-palette-grid">
        <button
          v-for="item in palette"
          :key="item.hex"
          class="color-palette-card"
          type="button"
          @click="selectColor(item.hex)"
        >
          <span class="color-palette-swatch" :style="{ background: item.hex }"></span>
          <strong>{{ item.name }}</strong>
          <small>{{ item.hex }}</small>
        </button>
      </div>
    </section>
  </main>
</template>

<script setup>
import { computed, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { ArrowLeft, Copy, Plus } from 'lucide-vue-next'

const router = useRouter()
const selectedColor = ref('#2557f6')
const colorInput = ref('rgb(37, 87, 246)')
const gradientEndColor = ref('#c7ef38')
const gradientDirection = ref('135deg')
const gradientDirections = [
  { label: '左到右', value: '90deg' },
  { label: '右到左', value: '270deg' },
  { label: '上到下', value: '180deg' },
  { label: '下到上', value: '0deg' },
  { label: '左上到右下', value: '135deg' },
  { label: '右上到左下', value: '225deg' }
]
const predefineColors = [
  '#2557f6',
  '#c7ef38',
  '#ff684f',
  '#15191f',
  '#567464',
  '#14b8a6',
  '#38bdf8',
  '#8b5cf6',
  '#f43f5e',
  '#f59e0b',
  '#64748b',
  '#ffffff',
  '#000000'
]
const palette = ref([
  { name: '品牌蓝', hex: '#2557f6' },
  { name: '荧光绿', hex: '#c7ef38' },
  { name: '珊瑚橙', hex: '#ff684f' },
  { name: '墨色', hex: '#15191f' },
  { name: '苔藓绿', hex: '#567464' },
  { name: '湖水青', hex: '#14b8a6' },
  { name: '天空蓝', hex: '#38bdf8' },
  { name: '紫罗兰', hex: '#8b5cf6' },
  { name: '玫瑰红', hex: '#f43f5e' },
  { name: '琥珀黄', hex: '#f59e0b' },
  { name: '石板灰', hex: '#64748b' },
  { name: '纯白', hex: '#ffffff' }
])

const rgbValue = computed(() => {
  const rgb = hexToRgb(selectedColor.value)
  return `rgb(${rgb.red}, ${rgb.green}, ${rgb.blue})`
})

const hslValue = computed(() => {
  const rgb = hexToRgb(selectedColor.value)
  const hsl = rgbToHsl(rgb.red, rgb.green, rgb.blue)
  return `hsl(${hsl.hue}, ${hsl.saturation}%, ${hsl.lightness}%)`
})

const cssVariableValue = computed(() => {
  return `--color: ${selectedColor.value};`
})

const gradientCss = computed(() => {
  return `linear-gradient(${gradientDirection.value}, ${selectedColor.value}, ${gradientEndColor.value})`
})

const colorValues = computed(() => {
  return [
    { label: 'HEX', value: selectedColor.value },
    { label: 'RGB', value: rgbValue.value },
    { label: 'HSL', value: hslValue.value },
    { label: 'CSS 变量', value: cssVariableValue.value }
  ]
})

function hexToRgb(hex) {
  const value = hex.replace('#', '')
  return {
    red: parseInt(value.slice(0, 2), 16),
    green: parseInt(value.slice(2, 4), 16),
    blue: parseInt(value.slice(4, 6), 16)
  }
}

function colorTextToHex(text) {
  const value = text.trim()
  const lowerValue = value.toLowerCase()

  if (/^#?[0-9a-f]{3}$|^#?[0-9a-f]{6}$/i.test(value)) {
    return normalizeHexColor(value)
  }

  if (lowerValue.startsWith('rgb')) {
    return rgbTextToHex(value)
  }

  if (lowerValue.startsWith('hsl')) {
    return hslTextToHex(value)
  }

  if (/^-?\d+(\.\d+)?\s*,\s*-?\d+(\.\d+)?\s*,\s*-?\d+(\.\d+)?$/.test(value)) {
    return rgbChannelsTextToHex(value)
  }

  throw new Error('请输入 HEX、RGB 或 HSL 色值')
}

function normalizeHexColor(value) {
  const hex = value.replace('#', '').toLowerCase()

  if (hex.length === 3) {
    const red = hex.charAt(0)
    const green = hex.charAt(1)
    const blue = hex.charAt(2)
    return `#${red}${red}${green}${green}${blue}${blue}`
  }

  return `#${hex}`
}

function rgbTextToHex(value) {
  const channels = colorFunctionChannels(value, /^rgba?\((.+)\)$/i, '请输入 rgb(255, 255, 255) 格式')
  return rgbChannelsToHex(Number(channels[0]), Number(channels[1]), Number(channels[2]))
}

function rgbChannelsTextToHex(value) {
  const channels = value.split(',').map((item) => item.trim())
  return rgbChannelsToHex(Number(channels[0]), Number(channels[1]), Number(channels[2]))
}

function hslTextToHex(value) {
  const channels = colorFunctionChannels(value, /^hsla?\((.+)\)$/i, '请输入 hsl(224, 93%, 55%) 格式')
  const hue = Number(channels[0])
  const saturation = Number(channels[1].replace('%', ''))
  const lightness = Number(channels[2].replace('%', ''))
  const rgb = hslToRgb(hue, saturation, lightness)
  return rgbChannelsToHex(rgb.red, rgb.green, rgb.blue)
}

function colorFunctionChannels(value, pattern, message) {
  const match = value.match(pattern)

  if (!match) {
    throw new Error(message)
  }

  const channels = match[1].split(',').map((item) => item.trim())

  if (channels.length < 3) {
    throw new Error(message)
  }

  return channels
}

function rgbChannelsToHex(red, green, blue) {
  validateRgbChannel(red)
  validateRgbChannel(green)
  validateRgbChannel(blue)
  return `#${componentToHex(red)}${componentToHex(green)}${componentToHex(blue)}`
}

function componentToHex(value) {
  return value.toString(16).padStart(2, '0')
}

function validateRgbChannel(value) {
  if (!Number.isInteger(value) || value < 0 || value > 255) {
    throw new Error('RGB 数值需要在 0 到 255 之间')
  }
}

function hslToRgb(hue, saturation, lightness) {
  validateHslChannels(hue, saturation, lightness)

  const normalizedHue = ((hue % 360) + 360) % 360
  const s = saturation / 100
  const l = lightness / 100

  if (s === 0) {
    const gray = Math.round(l * 255)
    return {
      red: gray,
      green: gray,
      blue: gray
    }
  }

  let q = 0
  if (l < 0.5) {
    q = l * (1 + s)
  } else {
    q = l + s - l * s
  }
  const p = 2 * l - q
  const red = hueToRgb(p, q, normalizedHue / 360 + 1 / 3)
  const green = hueToRgb(p, q, normalizedHue / 360)
  const blue = hueToRgb(p, q, normalizedHue / 360 - 1 / 3)

  return {
    red: Math.round(red * 255),
    green: Math.round(green * 255),
    blue: Math.round(blue * 255)
  }
}

function validateHslChannels(hue, saturation, lightness) {
  if (!Number.isFinite(hue)) {
    throw new Error('HSL 色相需要是数字')
  }

  if (!Number.isFinite(saturation) || saturation < 0 || saturation > 100) {
    throw new Error('HSL 饱和度需要在 0% 到 100% 之间')
  }

  if (!Number.isFinite(lightness) || lightness < 0 || lightness > 100) {
    throw new Error('HSL 亮度需要在 0% 到 100% 之间')
  }
}

function hueToRgb(p, q, value) {
  let hue = value

  if (hue < 0) {
    hue += 1
  }

  if (hue > 1) {
    hue -= 1
  }

  if (hue < 1 / 6) {
    return p + (q - p) * 6 * hue
  }

  if (hue < 1 / 2) {
    return q
  }

  if (hue < 2 / 3) {
    return p + (q - p) * (2 / 3 - hue) * 6
  }

  return p
}

function rgbToHsl(red, green, blue) {
  const r = red / 255
  const g = green / 255
  const b = blue / 255
  const max = Math.max(r, g, b)
  const min = Math.min(r, g, b)
  let hue = 0
  let saturation = 0
  const lightness = (max + min) / 2

  if (max !== min) {
    const delta = max - min
    if (lightness > 0.5) {
      saturation = delta / (2 - max - min)
    } else {
      saturation = delta / (max + min)
    }

    if (max === r) {
      hue = (g - b) / delta
      if (g < b) {
        hue += 6
      }
    }
    if (max === g) {
      hue = (b - r) / delta + 2
    }
    if (max === b) {
      hue = (r - g) / delta + 4
    }
    hue *= 60
  }

  return {
    hue: Math.round(hue),
    saturation: Math.round(saturation * 100),
    lightness: Math.round(lightness * 100)
  }
}

function convertColorInput() {
  try {
    selectedColor.value = colorTextToHex(colorInput.value)
  } catch (error) {
    ElMessage.error(error.message)
  }
}

async function copyText(value) {
  await navigator.clipboard.writeText(value)
  ElMessage.success('已复制色值')
}

function addPaletteColor() {
  const existing = palette.value.some((item) => item.hex === selectedColor.value)
  if (existing) {
    ElMessage.info('色板中已存在该颜色')
    return
  }

  palette.value.unshift({
    name: `颜色 ${palette.value.length + 1}`,
    hex: selectedColor.value
  })
}

function selectColor(hex) {
  selectedColor.value = hex
}

function goHome() {
  router.push('/')
}
</script>

<style scoped>
.color-tool-page {
  --color-card-gap: 12px;
  --color-card-padding: 14px;
}

.color-tool-page :deep(.tool-header) {
  margin-bottom: 14px;
  padding: 12px;
}

.color-tool-page :deep(.tool-header h1) {
  font-size: 26px;
}

.color-tool-page :deep(.tool-grid) {
  gap: var(--color-card-gap);
}

.color-tool-page :deep(.color-tool-grid) {
  grid-template-columns: minmax(210px, 250px) minmax(280px, 0.78fr) minmax(260px, 0.72fr);
  align-items: stretch;
}

.color-tool-page :deep(.tool-panel),
.color-tool-page :deep(.portal-section) {
  gap: var(--color-card-gap);
  padding: var(--color-card-padding);
}

.color-tool-page :deep(.tool-panel-head) {
  gap: 10px;
}

.color-tool-page :deep(.tool-panel-head h2) {
  font-size: 18px;
}

.color-tool-page :deep(.color-picker-field) {
  min-height: 38px;
  padding: 5px 7px 5px 10px;
}

.color-tool-page :deep(.color-hero-swatch) {
  min-height: 170px;
  padding: 14px;
}

.color-tool-page :deep(.color-hero-swatch span) {
  padding: 6px 10px;
  font-size: 13px;
}

.color-tool-page :deep(.tool-result-group) {
  gap: 8px;
}

.color-tool-page :deep(.color-picker-panel > .color-palette-list-section) {
  display: none;
}

.color-tool-page :deep(.color-palette-menu-panel) {
  grid-column: 1;
  grid-row: 1 / span 2;
  align-content: stretch;
  min-height: 0;
}

.color-tool-page :deep(.color-picker-panel) {
  grid-column: 2;
  align-self: stretch;
}

.color-tool-page :deep(.color-tool-grid > .tool-panel:nth-child(3)) {
  grid-column: 3;
  align-self: stretch;
}

.color-tool-page :deep(.gradient-panel) {
  grid-column: 2 / 4;
}

.color-palette-menu-panel .color-palette-list-section {
  flex: 1;
  height: 100%;
  min-height: 0;
  grid-template-rows: auto minmax(0, 1fr);
  padding-top: 0;
  border-top: 0;
}

.color-palette-menu-panel .color-palette-list {
  max-height: none;
  min-height: 0;
}

.color-palette-menu-panel .color-palette-list-head strong {
  font-size: 0;
}

.color-palette-menu-panel .color-palette-list-head strong::before {
  content: "项目色板";
  color: var(--ink);
  font-size: 14px;
  font-weight: 950;
}

.color-palette-list-section {
  display: grid;
  gap: 8px;
  min-height: 0;
  padding-top: 10px;
  border-top: 1px solid rgba(21, 25, 31, 0.1);
}

.color-palette-list-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
  min-width: 0;
}

.color-palette-list-head span {
  color: var(--blue);
  font-size: 11px;
  font-weight: 950;
  text-transform: uppercase;
}

.color-palette-list-head strong {
  min-width: 0;
  color: var(--ink);
  font-size: 14px;
  font-weight: 950;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.color-palette-list {
  max-height: 188px;
  display: grid;
  gap: 7px;
  overflow: auto;
  padding-right: 2px;
}

.color-palette-list-item {
  width: 100%;
  min-height: 42px;
  display: grid;
  grid-template-columns: 32px minmax(0, 1fr) auto;
  gap: 9px;
  align-items: center;
  padding: 7px 9px;
  border: 1px solid rgba(21, 25, 31, 0.1);
  border-radius: 8px;
  background: rgba(255, 255, 255, 0.58);
  color: var(--ink);
  text-align: left;
}

.color-palette-list-item:hover,
.color-palette-list-item:focus-visible {
  border-color: rgba(37, 87, 246, 0.28);
  outline: none;
}

.color-palette-list-swatch {
  width: 28px;
  height: 28px;
  border: 1px solid rgba(21, 25, 31, 0.12);
  border-radius: 8px;
}

.color-palette-list-item strong {
  min-width: 0;
  overflow: hidden;
  font-size: 13px;
  font-weight: 950;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.color-palette-list-item small {
  color: var(--muted);
  font-family: "SFMono-Regular", "SF Mono", Menlo, Monaco, Consolas, monospace;
  font-size: 11px;
  font-weight: 900;
  text-transform: uppercase;
}

:global(:root[data-theme="dark"]) .color-palette-list-section {
  border-color: rgba(255, 255, 255, 0.12);
}

:global(:root[data-theme="dark"]) .color-palette-list-item {
  border-color: rgba(255, 255, 255, 0.12);
  background: rgba(15, 23, 42, 0.58);
}

:global(:root[data-theme="dark"]) .color-palette-list-item:hover,
:global(:root[data-theme="dark"]) .color-palette-list-item:focus-visible {
  border-color: rgba(116, 167, 255, 0.32);
}

:global(:root[data-theme="dark"]) .color-palette-list-swatch {
  border-color: rgba(255, 255, 255, 0.16);
}

.color-tool-page :deep(.color-value-list) {
  gap: 8px;
}

.color-tool-page :deep(.color-value-item) {
  min-height: 48px;
  grid-template-columns: 62px minmax(0, 1fr) auto;
  gap: 10px;
  padding: 9px 11px;
}

.color-tool-page :deep(.color-value-item strong) {
  font-size: 13px;
}

.gradient-builder {
  display: grid;
  grid-template-columns: minmax(280px, 1fr) minmax(260px, 0.72fr);
  gap: 12px;
  align-items: stretch;
}

.gradient-preview {
  position: relative;
  isolation: isolate;
  min-height: 150px;
  display: flex;
  align-items: flex-end;
  padding: 12px;
  border: 0;
  border-radius: 8px;
  box-shadow:
    inset 0 0 0 1px rgba(255, 255, 255, 0.42),
    0 12px 30px rgba(31, 41, 55, 0.08);
  overflow: hidden;
}

.gradient-preview::after {
  position: absolute;
  inset: 0;
  z-index: 0;
  border-radius: inherit;
  background:
    linear-gradient(135deg, rgba(255, 255, 255, 0.22), transparent 42%),
    linear-gradient(0deg, rgba(21, 25, 31, 0.08), transparent 34%);
  content: "";
  pointer-events: none;
}

.gradient-preview span {
  position: relative;
  z-index: 1;
  max-width: 100%;
  padding: 7px 10px;
  border: 1px solid rgba(255, 255, 255, 0.48);
  border-radius: 8px;
  background: rgba(255, 255, 255, 0.72);
  color: var(--ink);
  font-family: "SFMono-Regular", "SF Mono", Menlo, Monaco, Consolas, monospace;
  font-size: 12px;
  font-weight: 900;
  line-height: 1.5;
  cursor: pointer;
  transition:
    background 160ms ease,
    border-color 160ms ease,
    box-shadow 160ms ease,
    transform 160ms ease;
  word-break: break-all;
}

.gradient-preview span:hover,
.gradient-preview span:focus-visible {
  border-color: rgba(37, 87, 246, 0.34);
  background: rgba(255, 255, 255, 0.86);
  box-shadow: 0 10px 24px rgba(31, 41, 55, 0.12);
  outline: none;
  transform: translateY(-1px);
}

.color-tool-page :deep(.color-hero-swatch span),
.gradient-preview span {
  border-color: rgba(255, 255, 255, 0.32) !important;
  background:
    linear-gradient(135deg, rgba(255, 255, 255, 0.16), rgba(255, 255, 255, 0.04)),
    rgba(8, 13, 24, 0.72) !important;
  color: #ffffff !important;
  box-shadow:
    0 12px 28px rgba(0, 0, 0, 0.2),
    inset 0 1px 0 rgba(255, 255, 255, 0.16) !important;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.28);
  backdrop-filter: blur(16px) saturate(140%);
}

.color-tool-page :deep(.color-hero-swatch span:hover),
.gradient-preview span:hover,
.gradient-preview span:focus-visible {
  border-color: rgba(255, 255, 255, 0.46) !important;
  background:
    linear-gradient(135deg, rgba(255, 255, 255, 0.2), rgba(255, 255, 255, 0.06)),
    rgba(8, 13, 24, 0.82) !important;
  color: #ffffff !important;
}

.gradient-controls {
  display: grid;
  gap: 8px;
}

.gradient-control-field {
  min-height: 46px;
  display: grid;
  grid-template-columns: 64px minmax(0, 1fr) auto;
  gap: 10px;
  align-items: center;
  padding: 8px 10px;
  border: 1px solid rgba(21, 25, 31, 0.1);
  border-radius: 8px;
  background: rgba(255, 255, 255, 0.58);
}

.gradient-control-field span {
  color: var(--muted);
  font-size: 12px;
  font-weight: 900;
}

.gradient-control-field strong {
  min-width: 0;
  color: var(--ink);
  font-family: "SFMono-Regular", "SF Mono", Menlo, Monaco, Consolas, monospace;
  font-size: 12px;
  font-weight: 900;
  overflow: hidden;
  text-overflow: ellipsis;
  text-transform: uppercase;
  white-space: nowrap;
}

.gradient-direction-field {
  grid-template-columns: 64px minmax(0, 1fr);
}

.gradient-direction-field :deep(.el-select) {
  width: 100%;
}

:global(:root[data-theme="dark"]) .gradient-preview {
  box-shadow:
    inset 0 0 0 1px rgba(255, 255, 255, 0.14),
    0 14px 34px rgba(0, 0, 0, 0.24);
}

:global(:root[data-theme="dark"]) .gradient-preview span {
  border-color: rgba(255, 255, 255, 0.16);
  background: rgba(15, 23, 42, 0.72);
}

:global(:root[data-theme="dark"]) .gradient-preview span:hover,
:global(:root[data-theme="dark"]) .gradient-preview span:focus-visible {
  border-color: rgba(116, 167, 255, 0.34);
  background: rgba(15, 23, 42, 0.86);
  box-shadow: 0 12px 28px rgba(0, 0, 0, 0.28);
}

:global(:root[data-theme="dark"]) .gradient-control-field {
  border-color: rgba(255, 255, 255, 0.12);
  background: rgba(15, 23, 42, 0.58);
}

:global(:root[data-theme="dark"] .color-tool-page .tool-panel),
:global(:root[data-theme="dark"] .color-tool-page .portal-section) {
  border-color: rgba(255, 255, 255, 0.12) !important;
  background:
    linear-gradient(135deg, rgba(255, 255, 255, 0.08), rgba(255, 255, 255, 0.02)),
    rgba(12, 18, 30, 0.72) !important;
  box-shadow:
    0 18px 42px rgba(0, 0, 0, 0.22),
    inset 0 1px 0 rgba(255, 255, 255, 0.08) !important;
}

:global(:root[data-theme="dark"] .color-tool-page .color-picker-field),
:global(:root[data-theme="dark"] .color-tool-page .color-palette-list-item),
:global(:root[data-theme="dark"] .color-tool-page .color-value-item),
:global(:root[data-theme="dark"] .color-tool-page .gradient-control-field) {
  border-color: rgba(255, 255, 255, 0.12) !important;
  background:
    linear-gradient(135deg, rgba(255, 255, 255, 0.08), rgba(255, 255, 255, 0.02)),
    rgba(15, 23, 42, 0.6) !important;
  box-shadow:
    0 10px 26px rgba(0, 0, 0, 0.16),
    inset 0 1px 0 rgba(255, 255, 255, 0.08) !important;
}

:global(:root[data-theme="dark"] .color-tool-page .tool-result-group .el-input__wrapper),
:global(:root[data-theme="dark"] .color-tool-page .gradient-direction-field .el-select__wrapper) {
  border-color: rgba(255, 255, 255, 0.12) !important;
  background: rgba(15, 23, 42, 0.58) !important;
  box-shadow:
    inset 0 0 0 1px rgba(255, 255, 255, 0.12),
    inset 0 1px 0 rgba(255, 255, 255, 0.08) !important;
}

:global(:root[data-theme="dark"] .color-tool-page .tool-result-group .el-input__wrapper.is-focus),
:global(:root[data-theme="dark"] .color-tool-page .gradient-direction-field .el-select__wrapper.is-focused),
:global(:root[data-theme="dark"] .color-tool-page .gradient-direction-field .el-select__wrapper:hover) {
  border-color: rgba(116, 167, 255, 0.34) !important;
  background: rgba(15, 23, 42, 0.58) !important;
  box-shadow:
    inset 0 0 0 1px rgba(116, 167, 255, 0.34),
    0 0 0 3px rgba(116, 167, 255, 0.12) !important;
}

:global(:root[data-theme="dark"] .color-tool-page .color-picker-label strong),
:global(:root[data-theme="dark"] .color-tool-page .color-palette-list-head strong),
:global(:root[data-theme="dark"] .color-tool-page .color-palette-list-head strong::before),
:global(:root[data-theme="dark"] .color-tool-page .color-palette-list-item strong),
:global(:root[data-theme="dark"] .color-tool-page .color-value-item strong),
:global(:root[data-theme="dark"] .color-tool-page .gradient-control-field strong),
:global(:root[data-theme="dark"] .color-tool-page .tool-panel-head h2),
:global(:root[data-theme="dark"] .color-tool-page .tool-result-group .el-input__inner),
:global(:root[data-theme="dark"] .color-tool-page .gradient-direction-field .el-select__selected-item) {
  color: #eef4ff !important;
}

:global(:root[data-theme="dark"] .color-tool-page .color-picker-label small),
:global(:root[data-theme="dark"] .color-tool-page .color-palette-list-item small),
:global(:root[data-theme="dark"] .color-tool-page .color-value-item span),
:global(:root[data-theme="dark"] .color-tool-page .gradient-control-field span),
:global(:root[data-theme="dark"] .color-tool-page .tool-result-group .eyebrow),
:global(:root[data-theme="dark"] .color-tool-page .gradient-direction-field .el-select__placeholder),
:global(:root[data-theme="dark"] .color-tool-page .gradient-direction-field .el-select__caret) {
  color: #b7c3d7 !important;
}

:global(:root[data-theme="dark"] .color-tool-page .tool-result-group .el-input__inner::placeholder) {
  color: rgba(183, 195, 215, 0.68) !important;
}

:global(:root[data-theme="dark"] .color-tool-page .gradient-preview span) {
  color: #eef4ff !important;
}

:global(:root[data-theme="dark"] .color-tool-page .gradient-panel .el-button.is-plain) {
  border-color: rgba(116, 167, 255, 0.28) !important;
  background: rgba(116, 167, 255, 0.12) !important;
  color: #d9e8ff !important;
}

:global(:root[data-theme="dark"] .color-tool-page .gradient-panel .el-button.is-plain:hover),
:global(:root[data-theme="dark"] .color-tool-page .gradient-panel .el-button.is-plain:focus) {
  border-color: rgba(116, 167, 255, 0.42) !important;
  background: rgba(116, 167, 255, 0.18) !important;
  color: #ffffff !important;
}

.color-tool-page :deep(.color-palette-section) {
  display: none;
}

.color-tool-page :deep(.portal-section-head) {
  gap: 10px;
  margin-bottom: 10px;
}

.color-tool-page :deep(.portal-section-head h2) {
  font-size: 22px;
}

.color-tool-page :deep(.color-palette-grid) {
  grid-template-columns: repeat(auto-fit, minmax(142px, 1fr));
  gap: 8px;
}

.color-tool-page :deep(.color-palette-card) {
  min-height: 96px;
  gap: 6px;
  padding: 8px;
}

.color-tool-page :deep(.color-palette-swatch) {
  min-height: 44px;
}

.color-tool-page :deep(.color-palette-card strong) {
  font-size: 13px;
}

.color-tool-page :deep(.color-palette-card small) {
  font-size: 11px;
}

@media (max-width: 1180px) {
  .color-tool-page :deep(.color-tool-grid) {
    grid-template-columns: 1fr;
  }

  .color-tool-page :deep(.color-palette-menu-panel),
  .color-tool-page :deep(.color-picker-panel),
  .color-tool-page :deep(.color-tool-grid > .tool-panel:nth-child(3)),
  .color-tool-page :deep(.gradient-panel) {
    grid-column: auto;
    grid-row: auto;
  }

  .gradient-builder {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 760px) {
  .color-tool-page {
    --color-card-padding: 12px;
  }

  .color-tool-page :deep(.tool-header h1) {
    font-size: 24px;
  }

  .color-tool-page :deep(.color-hero-swatch) {
    min-height: 140px;
  }

  .color-tool-page :deep(.color-value-item) {
    grid-template-columns: 1fr auto;
  }

  .color-tool-page :deep(.color-value-item span) {
    grid-column: 1 / -1;
  }

  .gradient-control-field,
  .gradient-direction-field {
    grid-template-columns: 1fr auto;
  }

  .gradient-direction-field :deep(.el-select) {
    grid-column: 1 / -1;
  }
}
</style>
