<script setup>
import { computed, onMounted } from "vue";
import { useRouter, RouterLink } from "vue-router";
import { useCartStore } from "@/stores/cart";
import { formatPrice, pluralizeRu } from "@/utils/format";
import Button from "primevue/button";
import InputNumber from "primevue/inputnumber";

const cart = useCartStore();
const router = useRouter();

const hasItems = computed(() => cart.items.length > 0);
const countLabel = computed(
  () => `${cart.count} ${pluralizeRu(cart.count, ["товар", "товара", "товаров"])}`,
);

function updateQty(itemId, value) {
  if (!value || value < 1) return;
  return cart.update(itemId, value);
}

onMounted(() => cart.load());
</script>

<template>
  <section class="cart-page">
    <div class="container">
      <header class="cart-page__head">
        <h1>Корзина</h1>
        <p v-if="hasItems">{{ countLabel }} на сумму {{ formatPrice(cart.total) }}</p>
      </header>

      <div v-if="!hasItems" class="cart-empty">
        <i class="pi pi-shopping-bag" />
        <h2>В корзине пока пусто</h2>
        <p>Загляните в каталог — там много красивых букетов</p>
        <Button label="К каталогу" size="large" @click="router.push('/catalog')" />
      </div>

      <div v-else class="cart-layout">
        <div class="cart-items">
          <article v-for="item in cart.items" :key="item.id" class="cart-item">
            <RouterLink :to="`/product/${item.product.id}`" class="cart-item__media">
              <img
                v-if="item.product.images?.[0]"
                :src="item.product.images[0].url"
                :alt="item.product.title"
              />
              <div v-else class="cart-item__placeholder">
                <i class="pi pi-image" />
              </div>
            </RouterLink>
            <div class="cart-item__body">
              <RouterLink :to="`/product/${item.product.id}`" class="cart-item__title">
                {{ item.product.title }}
              </RouterLink>
              <div class="cart-item__price">{{ formatPrice(item.product.price) }} за шт.</div>
              <div v-if="!item.product.in_stock" class="cart-item__warning">
                Нет в наличии
              </div>
            </div>
            <div class="cart-item__qty">
              <InputNumber
                :modelValue="item.quantity"
                @update:modelValue="(v) => updateQty(item.id, v)"
                :min="1"
                :max="item.product.stock"
                showButtons
                buttonLayout="horizontal"
              />
            </div>
            <div class="cart-item__total">
              {{ formatPrice(item.product.price * item.quantity) }}
            </div>
            <Button
              icon="pi pi-trash"
              text
              severity="secondary"
              @click="cart.remove(item.id)"
              aria-label="Удалить"
            />
          </article>
        </div>

        <aside class="cart-summary">
          <h3>Итого</h3>
          <div class="cart-summary__row">
            <span>Товаров</span>
            <span>{{ cart.count }} шт.</span>
          </div>
          <div class="cart-summary__row cart-summary__row--total">
            <span>К оплате</span>
            <span>{{ formatPrice(cart.total) }}</span>
          </div>
          <Button
            label="Оформить заказ"
            size="large"
            class="cart-summary__cta"
            @click="router.push('/checkout')"
          />
          <Button
            label="Очистить корзину"
            severity="secondary"
            text
            @click="cart.clear()"
          />
        </aside>
      </div>
    </div>
  </section>
</template>

<style lang="scss" scoped>
@use "@/assets/styles/variables" as *;

.cart-page {
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
}

.cart-empty {
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

.cart-layout {
  display: grid;
  grid-template-columns: 1fr 340px;
  gap: 32px;
  align-items: start;
}

.cart-items {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.cart-item {
  display: grid;
  grid-template-columns: 110px 1fr 140px 120px 40px;
  align-items: center;
  gap: 20px;
  background: var(--color-surface);
  padding: 16px 20px 16px 16px;
  border-radius: var(--radius-lg);

  &__media {
    width: 110px;
    height: 110px;
    border-radius: var(--radius);
    overflow: hidden;
    background: var(--color-secondary);

    img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }
  }

  &__qty :deep(.p-inputnumber) {
    width: 100%;
  }
  &__qty :deep(.p-inputnumber-input) {
    width: 100%;
    min-width: 0;
  }

  &__placeholder {
    width: 100%;
    height: 100%;
    display: flex;
    align-items: center;
    justify-content: center;

    i {
      font-size: 2rem;
      color: var(--color-primary-light);
      opacity: 0.5;
    }
  }

  &__body {
    min-width: 0;
  }

  &__title {
    font-family: var(--font-display);
    font-size: 1.25rem;
    display: block;
    margin-bottom: 4px;

    &:hover {
      color: var(--color-primary);
    }
  }

  &__price {
    color: var(--color-text-muted);
    font-size: 0.92rem;
  }

  &__warning {
    color: var(--danger, #b85c5c);
    font-size: 0.85rem;
    margin-top: 4px;
  }

  &__total {
    text-align: right;
    font-weight: 600;
    font-size: 1.15rem;
  }
}

.cart-summary {
  background: var(--color-surface);
  border-radius: var(--radius-lg);
  padding: 28px;
  display: flex;
  flex-direction: column;
  gap: 16px;
  position: sticky;
  top: 100px;

  h3 {
    margin: 0 0 8px;
    font-size: 1.4rem;
  }

  &__row {
    display: flex;
    justify-content: space-between;
    color: var(--color-text-muted);
    font-size: 0.95rem;

    &--total {
      color: var(--color-text);
      font-size: 1.2rem;
      font-weight: 600;
      padding-top: 16px;
      border-top: 1px solid var(--color-border);
    }
  }

  &__cta {
    margin-top: 8px;
  }
}

@media (max-width: 900px) {
  .cart-layout {
    grid-template-columns: 1fr;
  }
  .cart-item {
    grid-template-columns: 90px 1fr 130px 40px;

    &__total {
      display: none;
    }
  }
}

@media (max-width: 600px) {
  .cart-item {
    grid-template-columns: 80px 1fr 40px;
    gap: 12px;
    padding: 12px;

    &__media {
      width: 80px;
      height: 80px;
      grid-row: span 2;
    }

    &__body {
      grid-column: 2 / 3;
    }

    &__qty {
      grid-column: 2 / 3;
    }
  }
}
</style>
