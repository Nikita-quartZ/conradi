<script setup>
import { computed, ref } from "vue";

const value = defineModel({ type: Number, default: 0 });
const { readonly = false, size = "md" } = defineProps({
  readonly: Boolean,
  size: { type: String, default: "md" },
});

const hover = ref(0);
const display = computed(() => hover.value || value.value);

function pick(n) {
  if (readonly) return;
  value.value = n;
}

function onEnter(n) {
  if (!readonly) hover.value = n;
}

function onLeave() {
  if (!readonly) hover.value = 0;
}
</script>

<template>
  <div class="stars" :class="`stars--${size}`">
    <button
      v-for="n in 5"
      :key="n"
      type="button"
      class="stars__btn"
      :class="{ 'stars__btn--filled': n <= display, 'stars__btn--readonly': readonly }"
      :tabindex="readonly ? -1 : 0"
      :aria-label="`${n} звёзд`"
      @mouseenter="onEnter(n)"
      @mouseleave="onLeave"
      @click="pick(n)"
    >
      <i class="pi pi-star-fill" />
    </button>
  </div>
</template>

<style lang="scss" scoped>
.stars {
  display: inline-flex;
  gap: 2px;

  &__btn {
    background: none;
    border: 0;
    padding: 2px;
    cursor: pointer;
    color: #e4dccd;
    transition: color 0.15s ease, transform 0.15s ease;

    &--filled {
      color: #d4a55c;
    }

    &:hover:not(.stars__btn--readonly) {
      transform: scale(1.1);
    }

    &--readonly {
      cursor: default;
    }
  }

  &--sm i {
    font-size: 0.85rem;
  }
  &--md i {
    font-size: 1.1rem;
  }
  &--lg i {
    font-size: 1.5rem;
  }
}
</style>
