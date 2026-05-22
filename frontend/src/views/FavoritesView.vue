<script setup>
import { computed } from "vue";
import { useRouter } from "vue-router";
import { favoritesApi } from "@/api";
import { useFavoritesStore } from "@/stores/favorites";
import { useCartStore } from "@/stores/cart";
import { useAsyncData } from "@/composables/useAsyncData";
import { formatPrice, pluralizeRu } from "@/utils/format";
import Button from "primevue/button";

const router = useRouter();
const favStore = useFavoritesStore();
const cart = useCartStore();

const { data: items, pending, refresh } = useAsyncData(
  async () => {
    const { data } = await favoritesApi.list();
    return data.items;
  },
  { initialValue: [] },
);

const itemsList = computed(() => items.value ?? []);
const countLabel = computed(() =>
  `${itemsList.value.length} ${pluralizeRu(itemsList.value.length, ["товар", "товара", "товаров"])}`,
);

async function remove(productId) {
  await favStore.toggle(productId);
  await refresh();
}

function addToCart(productId) {
  return cart.add(productId, 1);
}
</script>

<template>
  <section class="favorites">
    <div class="container">
      <header class="favorites__head">
        <h1>Избранное</h1>
        <p v-if="!pending">{{ countLabel }}</p>
      </header>

      <div v-if="pending" class="favorites__loading">Загружаем…</div>

      <div v-else-if="!itemsList.length" class="favorites__empty">
        <i class="pi pi-heart" />
        <h2>Пока ничего не добавлено</h2>
        <p>Сохраняйте понравившиеся букеты, чтобы вернуться к ним позже</p>
        <Button label="К каталогу" @click="router.push('/catalog')" />
      </div>

      <div v-else class="favorites__grid">
        <article v-for="fav in itemsList" :key="fav.id" class="fav-item">
          <div class="fav-item__media" @click="router.push(`/product/${fav.product.id}`)">
            <img
              v-if="fav.product.images?.[0]"
              :src="fav.product.images[0].url"
              :alt="fav.product.title"
            />
            <div v-else class="fav-item__placeholder">
              <i class="pi pi-image" />
            </div>
            <button
              class="fav-item__remove"
              aria-label="Убрать"
              @click.stop="remove(fav.product.id)"
            >
              <i class="pi pi-heart-fill" />
            </button>
          </div>
          <div class="fav-item__body">
            <h3 @click="router.push(`/product/${fav.product.id}`)">
              {{ fav.product.title }}
            </h3>
            <div class="fav-item__bottom">
              <div class="fav-item__price">{{ formatPrice(fav.product.price) }}</div>
              <Button
                icon="pi pi-shopping-bag"
                severity="secondary"
                rounded
                :disabled="!fav.product.in_stock"
                @click="addToCart(fav.product.id)"
              />
            </div>
            <div v-if="!fav.product.in_stock" class="fav-item__out">
              Нет в наличии
            </div>
          </div>
        </article>
      </div>
    </div>
  </section>
</template>

<style lang="scss" scoped>
@use "@/assets/styles/variables" as *;

.favorites {
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

  &__grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
    gap: 24px;
  }
}

.fav-item {
  background: var(--color-surface);
  border-radius: var(--radius-lg);
  overflow: hidden;
  display: flex;
  flex-direction: column;

  &__media {
    aspect-ratio: 1 / 1;
    background: var(--color-secondary);
    position: relative;
    cursor: pointer;
    overflow: hidden;

    img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }
  }

  &__placeholder {
    width: 100%;
    height: 100%;
    display: flex;
    align-items: center;
    justify-content: center;

    i {
      font-size: 3rem;
      color: var(--color-primary-light);
      opacity: 0.5;
    }
  }

  &__remove {
    position: absolute;
    top: 12px;
    right: 12px;
    width: 36px;
    height: 36px;
    border-radius: 50%;
    border: 0;
    background: rgba(255, 255, 255, 0.95);
    color: var(--color-primary);
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: transform 0.15s ease;

    &:hover {
      transform: scale(1.1);
    }
  }

  &__body {
    padding: 20px 22px 22px;
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: 12px;
  }

  h3 {
    font-size: 1.15rem;
    margin: 0;
    cursor: pointer;

    &:hover {
      color: var(--color-primary);
    }
  }

  &__bottom {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-top: auto;
  }

  &__price {
    font-size: 1.2rem;
    font-weight: 600;
  }

  &__out {
    color: var(--danger, #b85c5c);
    font-size: 0.85rem;
  }
}

@media (max-width: 600px) {
  .favorites {
    padding: 24px 0 56px;

    &__grid {
      grid-template-columns: 1fr;
      gap: 16px;
    }
  }
}
</style>
