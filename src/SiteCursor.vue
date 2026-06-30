<template>
  <div ref="siteCursorRef" class="site-cursor" :class="{ visible: isCursorVisible, active: isCursorActive }" aria-hidden="true">
    <span></span>
  </div>
</template>

<script setup>
import { onBeforeUnmount, onMounted, ref } from 'vue'

const siteCursorRef = ref()
const isCursorVisible = ref(false)
const isCursorActive = ref(false)
const cursorTargetSelector = 'a, button, input, textarea, select, [role="button"], .portal-feature-card, .tool-panel, .resume-list-item, .icon-button, .small-action'
let cursorMediaQuery

function moveSiteCursor(event) {
  isCursorVisible.value = true
  siteCursorRef.value.style.transform = `translate3d(${event.clientX}px, ${event.clientY}px, 0)`
}

function updateSiteCursorTarget(event) {
  isCursorActive.value = Boolean(event.target.closest(cursorTargetSelector))
}

function hideSiteCursor() {
  isCursorVisible.value = false
  isCursorActive.value = false
}

function enableSiteCursor() {
  document.documentElement.classList.add('custom-cursor-enabled')
  window.addEventListener('pointermove', moveSiteCursor)
  window.addEventListener('pointerover', updateSiteCursorTarget)
  window.addEventListener('pointerout', updateSiteCursorTarget)
  window.addEventListener('pointerleave', hideSiteCursor)
}

function disableSiteCursor() {
  document.documentElement.classList.remove('custom-cursor-enabled')
  window.removeEventListener('pointermove', moveSiteCursor)
  window.removeEventListener('pointerover', updateSiteCursorTarget)
  window.removeEventListener('pointerout', updateSiteCursorTarget)
  window.removeEventListener('pointerleave', hideSiteCursor)
}

onMounted(() => {
  cursorMediaQuery = window.matchMedia('(pointer: fine)')

  if (cursorMediaQuery.matches) {
    enableSiteCursor()
  }
})

onBeforeUnmount(() => {
  disableSiteCursor()
})
</script>

<style scoped>
:global(html.custom-cursor-enabled),
:global(html.custom-cursor-enabled *) {
  cursor: none !important;
}

.site-cursor {
  position: fixed;
  top: 0;
  left: 0;
  z-index: 2147483647;
  width: 24px;
  height: 30px;
  background: #ffffff;
  clip-path: polygon(0 0, 0 23px, 6px 18px, 10px 29px, 15px 27px, 11px 17px, 21px 17px);
  filter:
    drop-shadow(0 0 1px rgba(0, 0, 0, 0.82))
    drop-shadow(0 2px 2px rgba(0, 0, 0, 0.24));
  opacity: 0;
  pointer-events: none;
  transform: translate3d(-120px, -120px, 0);
  transition:
    opacity 120ms ease,
    filter 150ms ease,
    background 150ms ease;
}

.site-cursor span {
  display: none;
}

.site-cursor.visible {
  opacity: 1;
}

.site-cursor.active {
  background: #f8fff9;
  filter:
    drop-shadow(0 0 1px rgba(0, 0, 0, 0.9))
    drop-shadow(0 2px 3px rgba(22, 163, 74, 0.28));
}

:global(:root[data-theme="dark"]) .site-cursor {
  background: #ffffff;
  filter:
    drop-shadow(0 0 1px rgba(0, 0, 0, 0.92))
    drop-shadow(0 2px 3px rgba(255, 255, 255, 0.2));
}

:global(:root[data-theme="dark"]) .site-cursor.active {
  background: #f5fff7;
  filter:
    drop-shadow(0 0 1px rgba(0, 0, 0, 0.94))
    drop-shadow(0 2px 4px rgba(34, 197, 94, 0.28));
}

@media (pointer: coarse) {
  :global(html.custom-cursor-enabled),
  :global(html.custom-cursor-enabled *) {
    cursor: auto !important;
  }

  .site-cursor {
    display: none;
  }
}
</style>
