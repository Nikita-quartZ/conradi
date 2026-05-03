<script setup>
import { ref, computed } from "vue";

const props = defineProps({
  modelValue: { type: Number, default: 0 },
  readonly: { type: Boolean, default: false },
  size: { type: String, default: "md" },
});
const emit = defineEmits(["update:modelValue"]);

const hover = ref(0);
const display = computed(() => hover.value || props.modelValue);

function pick(n) {
  if (props.readonly) return;
  emit("update:modelValue", n);
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
      @mouseenter="!readonly && (hover = n)"
      @mouseleave="!readonly && (hover = 0)"
      @click="pick(n)"
      :tabindex="readonly ? -1 : 0"
      :aria-label="`${n} звёзд`"
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
