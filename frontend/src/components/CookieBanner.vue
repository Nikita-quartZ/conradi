<script setup>
import { computed } from "vue";
import { RouterLink } from "vue-router";
import { useLocalStorage } from "@/composables/useLocalStorage";
import Button from "primevue/button";

const consent = useLocalStorage("cookie-consent", null);
const visible = computed(() => consent.value == null);

function accept() {
  consent.value = "accepted";
}

function decline() {
  consent.value = "declined";
}
</script>

<template>
  <Transition name="cookie">
    <aside v-if="visible" class="cookie-banner" role="dialog" aria-label="Cookies">
      <div class="cookie-banner__inner">
        <div class="cookie-banner__text">
          <strong>Мы используем cookie-файлы</strong>
          <p>
            Они помогают сайту запоминать вас между визитами и&nbsp;корректно работать
            (корзина, авторизация). Подробнее&nbsp;— в&nbsp;<RouterLink to="/privacy">политике конфиденциальности</RouterLink>.
          </p>
        </div>
        <div class="cookie-banner__actions">
          <Button label="Отклонить" severity="secondary" text size="small" @click="decline" />
          <Button label="Принять" size="small" @click="accept" />
        </div>
      </div>
    </aside>
  </Transition>
</template>

<style lang="scss" scoped>
@use "@/assets/styles/variables" as *;

.cookie-banner {
  position: fixed;
  bottom: 16px;
  left: 16px;
  right: 16px;
  z-index: 100;
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  box-shadow: 0 12px 32px rgba(42, 33, 32, 0.12);
  padding: 18px 22px;

  &__inner {
    max-width: 1000px;
    margin: 0 auto;
    display: flex;
    align-items: center;
    gap: 24px;
  }

  &__text {
    flex: 1;
    font-size: 0.92rem;

    strong {
      display: block;
      margin-bottom: 4px;
    }

    p {
      margin: 0;
      color: var(--color-text-muted);
      line-height: 1.5;
    }

    a {
      color: var(--color-primary);

      &:hover {
        text-decoration: underline;
      }
    }
  }

  &__actions {
    display: flex;
    gap: 8px;
    flex-shrink: 0;
  }
}

.cookie-enter-active,
.cookie-leave-active {
  transition: transform 0.3s ease, opacity 0.3s ease;
}

.cookie-enter-from,
.cookie-leave-to {
  opacity: 0;
  transform: translateY(20px);
}

@media (max-width: 700px) {
  .cookie-banner {
    bottom: 8px;
    left: 8px;
    right: 8px;
    padding: 14px 16px;

    &__inner {
      flex-direction: column;
      align-items: stretch;
      gap: 12px;
    }

    &__actions {
      display: grid;
      grid-template-columns: 1fr 1fr;
    }
  }
}
</style>
