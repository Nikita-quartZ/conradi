<script setup>
import { ref, onMounted } from "vue";
import { useRouter, RouterLink } from "vue-router";
import { ordersApi } from "@/api";
import Button from "primevue/button";

const router = useRouter();
const orders = ref([]);
const loading = ref(true);

const STATUS_BADGE = {
  created: "badge--created",
  assembling: "badge--assembling",
  issued: "badge--issued",
  delivered: "badge--delivered",
  canceled: "badge--canceled",
};

const fmt = (p) => new Intl.NumberFormat("ru-RU").format(p) + " ₽";

async function load() {
  loading.value = true;
  try {
    const { data } = await ordersApi.list();
    orders.value = data.items;
  } finally {
    loading.value = false;
  }
}

onMounted(load);
</script>

<template>
  <section class="orders">
    <div class="container">
      <header class="orders__head">
        <h1>Мои заказы</h1>
        <p v-if="!loading">{{ orders.length }} {{ orders.length === 1 ? "заказ" : "заказов" }}</p>
      </header>

      <div v-if="loading" class="orders__loading">Загружаем…</div>

      <div v-else-if="!orders.length" class="orders__empty">
        <i class="pi pi-receipt" />
        <h2>Заказов пока нет</h2>
        <p>Когда вы оформите первый заказ, он появится здесь</p>
        <Button label="К каталогу" @click="router.push('/catalog')" />
      </div>

      <div v-else class="orders__list">
        <article v-for="o in orders" :key="o.id" class="order">
          <header class="order__head">
            <div class="order__id">Заказ #{{ o.id }}</div>
            <span class="order__badge" :class="STATUS_BADGE[o.status]">
              {{ o.status_label }}
            </span>
          </header>

          <div class="order__items">
            <div v-for="it in o.items" :key="it.id" class="order__item">
              <span>{{ it.title_snapshot }} ×{{ it.quantity }}</span>
              <span>{{ fmt(it.price_snapshot * it.quantity) }}</span>
            </div>
          </div>

          <div class="order__meta">
            <div class="order__meta-col">
              <span>Доставка</span>
              <strong>{{ o.delivery_date }}, {{ o.delivery_time }}</strong>
            </div>
            <div class="order__meta-col">
              <span>Адрес</span>
              <strong>{{ o.address }}</strong>
            </div>
            <div class="order__meta-col">
              <span>Оплата</span>
              <strong>{{ o.pay_method === "card" ? "Картой" : "Курьеру" }}</strong>
            </div>
          </div>

          <div class="order__footer">
            <span class="order__date">{{ new Date(o.created_at).toLocaleString("ru-RU") }}</span>
            <span class="order__total">{{ fmt(o.total) }}</span>
          </div>
        </article>
      </div>
    </div>
  </section>
</template>

<style lang="scss" scoped>
@use "@/assets/styles/variables" as *;

.orders {
  padding: 48px 0 80px;
  min-height: 60vh;

  &__head {
    text-align: center;
    margin-bottom: 48px;

    h1 {
      margin: 0 0 8px;
    }
    p {
      color: var(--color-text-muted);
      margin: 0;
    }
  }

  &__loading {
    text-align: center;
    color: var(--color-text-muted);
    padding: 60px 0;
  }

  &__empty {
    text-align: center;
    padding: 60px 20px;
    background: var(--color-surface);
    border-radius: var(--radius-lg);

    i {
      font-size: 4rem;
      color: var(--color-primary-light);
      margin-bottom: 20px;
      display: inline-block;
    }

    h2 {
      margin: 0 0 8px;
    }

    p {
      color: var(--color-text-muted);
      margin: 0 0 28px;
    }
  }

  &__list {
    display: flex;
    flex-direction: column;
    gap: 16px;
  }
}

.order {
  background: var(--color-surface);
  border-radius: var(--radius-lg);
  padding: 24px 28px;

  &__head {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 16px;
  }

  &__id {
    font-family: var(--font-display);
    font-size: 1.4rem;
  }

  &__badge {
    padding: 6px 14px;
    border-radius: 999px;
    font-size: 0.85rem;
    font-weight: 500;
    letter-spacing: 0.02em;

    &.badge--created {
      background: #f0ebd5;
      color: #856864;
    }
    &.badge--assembling {
      background: #fde8d8;
      color: #a06840;
    }
    &.badge--issued {
      background: #d8e8f0;
      color: #4a6f80;
    }
    &.badge--delivered {
      background: #d8e8d8;
      color: #5a7d52;
    }
    &.badge--canceled {
      background: #f0d8d8;
      color: #8a4a4a;
    }
  }

  &__items {
    background: var(--color-surface-alt);
    border-radius: var(--radius);
    padding: 14px 18px;
    margin-bottom: 16px;
  }

  &__item {
    display: flex;
    justify-content: space-between;
    padding: 6px 0;
    color: var(--color-text);

    & + & {
      border-top: 1px solid var(--color-border);
    }
  }

  &__meta {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 16px;
    margin-bottom: 16px;
  }

  &__meta-col {
    display: flex;
    flex-direction: column;
    gap: 4px;

    span {
      font-size: 0.75rem;
      text-transform: uppercase;
      letter-spacing: 0.08em;
      color: var(--color-text-muted);
    }
  }

  &__footer {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding-top: 16px;
    border-top: 1px solid var(--color-border);
  }

  &__date {
    color: var(--color-text-muted);
    font-size: 0.9rem;
  }

  &__total {
    font-size: 1.3rem;
    font-weight: 600;
  }
}
</style>
