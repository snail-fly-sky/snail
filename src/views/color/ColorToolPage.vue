<template>
  <main class="tool-page">
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
    </section>

    <section class="portal-section color-palette-section" aria-label="项目色板">
      <div class="portal-section-head">
        <span>Palette</span>
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
const predefineColors = [
  '#2557f6',
  '#c7ef38',
  '#ff684f',
  '#15191f',
  '#567464',
  '#ffffff',
  '#000000'
]
const palette = ref([
  { name: '主蓝', hex: '#2557f6' },
  { name: '酸橙', hex: '#c7ef38' },
  { name: '珊瑚', hex: '#ff684f' },
  { name: '墨色', hex: '#15191f' },
  { name: '苔绿', hex: '#567464' }
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
