<script setup>
import { ref, onMounted, computed } from "vue";
import { useRoute, useRouter } from "vue-router";
import { ordersApi } from "@/api";
import Button from "primevue/button";

const route = useRoute();
const router = useRouter();
const order = ref(null);

const fmt = (n) => new Intl.NumberFormat("ru-RU").format(n) + " ₽";

onMounted(async () => {
  try {
    const { data } = await ordersApi.detail(route.params.id);
    order.value = data.order;
  } catch {
    order.value = null;
  }
});
</script>

<template>
  <section class="success">
    <div class="container">
      <div v-if="order" class="success__card">
        <div class="success__icon">
          <i class="pi pi-check-circle" />
        </div>
        <h1>Заказ успешно оплачен</h1>
        <p class="success__lead">
          Спасибо за заказ! Букет уже собирается.<br />
          Мы свяжемся с вами для уточнения деталей доставки.
        </p>

        <div class="success__details">
          <div class="success__row">
            <span>Номер заказа</span>
            <strong>#{{ order.id }}</strong>
          </div>
          <div class="success__row">
            <span>Сумма</span>
            <strong>{{ fmt(order.total) }}</strong>
          </div>
          <div class="success__row">
            <span>Способ оплаты</span>
            <strong>{{ order.pay_method === "card" ? "Картой онлайн" : "Курьеру" }}</strong>
          </div>
          <div class="success__row">
            <span>Доставка</span>
            <strong>{{ order.delivery_date }}, {{ order.delivery_time }}</strong>
          </div>
          <div class="success__row">
            <span>Адрес</span>
            <strong>{{ order.address }}</strong>
          </div>
          <div class="success__row">
            <span>Статус</span>
            <strong>{{ order.status_label }}</strong>
          </div>
        </div>

        <div class="success__actions">
          <Button label="Мои заказы" outlined @click="router.push('/orders')" />
          <Button label="К каталогу" @click="router.push('/catalog')" />
        </div>
      </div>

      <div v-else class="success__loading">Загружаем…</div>
    </div>
  </section>
</template>

<style lang="scss" scoped>
@use "@/assets/styles/variables" as *;

.success {
  padding: 80px 0;
  min-height: 60vh;

  &__card {
    max-width: 600px;
    margin: 0 auto;
    background: var(--color-surface);
    border-radius: var(--radius-lg);
    padding: 56px 48px;
    text-align: center;
    box-shadow: $shadow;
  }

  &__icon {
    i {
      font-size: 4rem;
      color: var(--success, #6f8f6a);
      animation: pop 0.4s ease;
    }
    margin-bottom: 24px;
  }

  h1 {
    margin: 0 0 16px;
  }

  &__lead {
    color: var(--color-text-muted);
    margin: 0 0 36px;
  }

  &__details {
    background: var(--color-surface-alt);
    border-radius: var(--radius);
    padding: 24px 28px;
    margin-bottom: 32px;
    text-align: left;
  }

  &__row {
    display: flex;
    justify-content: space-between;
    padding: 10px 0;
    border-bottom: 1px solid var(--color-border);
    font-size: 0.95rem;

    &:last-child {
      border-bottom: 0;
    }

    span {
      color: var(--color-text-muted);
    }
  }

  &__actions {
    display: flex;
    gap: 12px;
    justify-content: center;
  }

  &__loading {
    text-align: center;
    color: var(--color-text-muted);
  }
}

@keyframes pop {
  0% {
    transform: scale(0);
    opacity: 0;
  }
  60% {
    transform: scale(1.15);
  }
  100% {
    transform: scale(1);
    opacity: 1;
  }
}
</style>
