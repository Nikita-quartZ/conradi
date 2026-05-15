<script setup>
import { ref } from "vue";
import AdminOrders from "@/components/admin/AdminOrders.vue";
import AdminProducts from "@/components/admin/AdminProducts.vue";
import AdminCategories from "@/components/admin/AdminCategories.vue";
import AdminTypes from "@/components/admin/AdminTypes.vue";

const tab = ref("orders");

const tabs = [
  { id: "orders", label: "Заказы", icon: "pi pi-receipt" },
  { id: "products", label: "Товары", icon: "pi pi-tag" },
  { id: "categories", label: "Категории", icon: "pi pi-th-large" },
  { id: "types", label: "Типы", icon: "pi pi-bookmark" },
];
</script>

<template>
  <section class="admin">
    <div class="container">
      <header class="admin__head">
        <h1>Админ-панель</h1>
        <p>Управление магазином</p>
      </header>

      <nav class="admin__tabs">
        <button
          v-for="t in tabs"
          :key="t.id"
          class="admin__tab"
          :class="{ active: tab === t.id }"
          @click="tab = t.id"
        >
          <i :class="t.icon" />
          {{ t.label }}
        </button>
      </nav>

      <div class="admin__panel">
        <AdminOrders v-if="tab === 'orders'" />
        <AdminProducts v-if="tab === 'products'" />
        <AdminCategories v-if="tab === 'categories'" />
        <AdminTypes v-if="tab === 'types'" />
      </div>
    </div>
  </section>
</template>

<style lang="scss" scoped>
@use "@/assets/styles/variables" as *;

.admin {
  padding: 48px 0 80px;
  min-height: 80vh;

  &__head {
    text-align: center;
    margin-bottom: 40px;

    h1 {
      margin: 0 0 8px;
    }
    p {
      color: var(--color-text-muted);
      margin: 0;
    }
  }

  &__tabs {
    display: flex;
    gap: 8px;
    background: var(--color-surface);
    border-radius: var(--radius-lg);
    padding: 6px;
    margin-bottom: 24px;
    width: fit-content;
    margin-left: auto;
    margin-right: auto;
  }

  &__tab {
    padding: 10px 20px;
    border: 0;
    background: transparent;
    border-radius: var(--radius);
    cursor: pointer;
    font-family: inherit;
    font-size: 0.95rem;
    display: inline-flex;
    align-items: center;
    gap: 8px;
    transition: all 0.15s ease;
    color: var(--color-text);

    &:hover {
      background: var(--color-secondary);
    }

    &.active {
      background: var(--color-primary);
      color: #fff;
    }
  }

  &__panel {
    background: var(--color-surface);
    border-radius: var(--radius-lg);
    padding: 32px;
  }
}
</style>
