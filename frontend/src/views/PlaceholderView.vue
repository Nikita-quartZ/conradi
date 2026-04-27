<script setup>
defineProps({
  title: { type: String, required: true },
  subtitle: { type: String, default: "" },
});
</script>

<template>
  <section class="placeholder">
    <div class="container">
      <h1>{{ title }}</h1>
      <p v-if="subtitle">{{ subtitle }}</p>
      <p class="placeholder__hint">Этот раздел появится в следующих этапах.</p>
    </div>
  </section>
</template>

<style lang="scss" scoped>
.placeholder {
  padding: 80px 0;
  min-height: calc(100vh - 80px);

  h1 {
    margin-bottom: 16px;
  }

  p {
    color: var(--color-text-muted);
    font-size: 1.05rem;
    max-width: 560px;
  }

  &__hint {
    margin-top: 24px;
    font-size: 0.9rem;
    opacity: 0.7;
  }
}
</style>
