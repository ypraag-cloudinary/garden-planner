<script setup lang="ts">
import { ref } from 'vue'

defineProps<{
  open: boolean
}>()

const emit = defineEmits<{
  close: []
}>()

const scale = ref(1)
const dragging = ref(false)
const startX = ref(0)
const startY = ref(0)
const translateX = ref(0)
const translateY = ref(0)
const lastTranslateX = ref(0)
const lastTranslateY = ref(0)

function zoomIn() {
  scale.value = Math.min(scale.value + 0.5, 5)
}

function zoomOut() {
  scale.value = Math.max(scale.value - 0.5, 0.5)
}

function resetView() {
  scale.value = 1
  translateX.value = 0
  translateY.value = 0
  lastTranslateX.value = 0
  lastTranslateY.value = 0
}

function onPointerDown(e: PointerEvent) {
  dragging.value = true
  startX.value = e.clientX - lastTranslateX.value
  startY.value = e.clientY - lastTranslateY.value
  ;(e.target as HTMLElement).setPointerCapture(e.pointerId)
}

function onPointerMove(e: PointerEvent) {
  if (!dragging.value) return
  translateX.value = e.clientX - startX.value
  translateY.value = e.clientY - startY.value
}

function onPointerUp() {
  dragging.value = false
  lastTranslateX.value = translateX.value
  lastTranslateY.value = translateY.value
}
</script>

<template>
  <Teleport to="body">
    <Transition name="aerial">
      <div
        v-if="open"
        class="fixed inset-0 z-50 bg-neutral/85 flex flex-col"
        @click.self="emit('close')"
      >
        <div class="flex items-center justify-between px-4 py-3 bg-neutral/60">
          <span class="text-neutral-content/90 font-medium text-sm">מבט אווירי על הגינה</span>
          <div class="flex items-center gap-1.5">
            <button @click="zoomOut" class="btn btn-ghost btn-square btn-sm text-neutral-content text-lg">−</button>
            <button @click="resetView" class="btn btn-ghost btn-sm text-neutral-content text-xs tabular-nums">{{ Math.round(scale * 100) }}%</button>
            <button @click="zoomIn" class="btn btn-ghost btn-square btn-sm text-neutral-content text-lg">+</button>
            <button @click="emit('close')" class="btn btn-ghost btn-square btn-sm text-neutral-content mr-1">✕</button>
          </div>
        </div>
        <div
          class="flex-1 overflow-hidden flex items-center justify-center touch-none"
          @pointerdown="onPointerDown"
          @pointermove="onPointerMove"
          @pointerup="onPointerUp"
        >
          <img
            src="/garden-aerial.png"
            alt="מבט אווירי על הגינה"
            class="max-w-none select-none"
            :class="{ 'cursor-grabbing': dragging, 'cursor-grab': !dragging }"
            :style="{
              transform: `translate(${translateX}px, ${translateY}px) scale(${scale})`,
              transition: dragging ? 'none' : 'transform 0.2s cubic-bezier(0.16, 1, 0.3, 1)',
            }"
            draggable="false"
          />
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<style scoped>
.aerial-enter-active {
  transition: opacity 0.2s ease;
}
.aerial-leave-active {
  transition: opacity 0.15s ease;
}
.aerial-enter-from,
.aerial-leave-to {
  opacity: 0;
}
</style>
