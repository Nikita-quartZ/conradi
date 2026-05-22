<script setup>
import { computed } from "vue";
import { useRouter } from "vue-router";
import { useAuthStore } from "@/stores/auth";
import { useFavoritesStore } from "@/stores/favorites";
import { useCartStore } from "@/stores/cart";
import { formatPrice } from "@/utils/format";
import StarRating from "./StarRating.vue";
import Button from "primevue/button";

const { product } = defineProps({
  product: { type: Object, required: true },
});

const router = useRouter();
const auth = useAuthStore();
const favorites = useFavoritesStore();
const cart = useCartStore();

const image = computed(() => product.images?.[0]?.url ?? null);
const isFav = computed(() => favorites.isFavorite(product.id));
const inStock = computed(() => product.stock > 0);

function open() {
  router.push(`/product/${product.id}`);
}

function ensureAuth() {
  if (auth.isAuthenticated) return true;
  router.push({ path: "/login", query: { redirect: router.currentRoute.value.fullPath } });
  return false;
}

async function toggleFav(event) {
  event.stopPropagation();
  if (!ensureAuth()) return;
  await favorites.toggle(product.id);
}

async function addToCart(event) {
  event.stopPropagation();
  if (!ensureAuth()) return;
  await cart.add(product.id, 1);
}
</script>

<template>
  <article class="card" @click="open">
    <div class="card__media">
      <img v-if="image" :src="image" :alt="product.title" loading="lazy" />
      <div v-else class="card__placeholder">
        <i class="pi pi-image" />
      </div>
      <button
        class="card__fav"
        :class="{ 'card__fav--active': isFav }"
        :aria-label="isFav ? 'Убрать из избранного' : 'В избранное'"
        @click="toggleFav"
      >
        <i :class="isFav ? 'pi pi-heart-fill' : 'pi pi-heart'" />
      </button>
      <div v-if="!inStock" class="card__badge card__badge--out">Нет в наличии</div>
    </div>

    <div class="card__body">
      <div class="card__meta">
        <span class="card__category">{{ product.category?.title }}</span>
        <StarRating
          v-if="product.average_rating > 0"
          :model-value="product.average_rating"
          readonly
          size="sm"
        />
      </div>
      <h3 class="card__title">{{ product.title }}</h3>
      <div class="card__bottom">
        <div class="card__price">{{ formatPrice(product.price) }}</div>
        <Button
          icon="pi pi-shopping-bag"
          severity="secondary"
          rounded
          aria-label="В корзину"
          :disabled="!inStock"
          @click="addToCart"
        />
      </div>
    </div>
  </article>
</template>

<style lang="scss" scoped>
@use "@/assets/styles/variables" as *;

.card {
  background: var(--color-surface);
  border-radius: var(--radius-lg);
  overflow: hidden;
  cursor: pointer;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
  display: flex;
  flex-direction: column;

  &:hover {
    transform: translateY(-4px);
    box-shadow: $shadow-lg;
  }

  &__media {
    aspect-ratio: 1 / 1;
    position: relative;
    background: var(--color-secondary);
    overflow: hidden;

    img {
      width: 100%;
      height: 100%;
      object-fit: cover;
      transition: transform 0.4s ease;
    }
  }

  &:hover .card__media img {
    transform: scale(1.04);
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

  &__fav {
    position: absolute;
    top: 12px;
    right: 12px;
    width: 36px;
    height: 36px;
    border-radius: 50%;
    border: 0;
    background: rgba(255, 255, 255, 0.9);
    color: var(--color-text);
    cursor: pointer;
    backdrop-filter: blur(4px);
    transition: all 0.15s ease;
    display: flex;
    align-items: center;
    justify-content: center;

    &:hover {
      background: #fff;
      color: var(--color-primary);
    }

    &--active {
      color: var(--color-primary);

      i {
        animation: heartbeat 0.4s ease;
      }
    }

    i {
      font-size: 1rem;
    }
  }

  &__badge {
    position: absolute;
    top: 12px;
    left: 12px;
    padding: 4px 12px;
    border-radius: 999px;
    font-size: 0.75rem;
    font-weight: 500;
    background: rgba(255, 255, 255, 0.9);
    backdrop-filter: blur(4px);

    &--out {
      color: var(--color-text-muted);
    }
  }

  &__body {
    padding: 20px 20px 24px;
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: 8px;
  }

  &__meta {
    display: flex;
    align-items: center;
    justify-content: space-between;
    min-height: 18px;
  }

  &__category {
    font-size: 0.75rem;
    text-transform: uppercase;
    letter-spacing: 0.08em;
    color: var(--color-text-muted);
  }

  &__title {
    font-size: 1.15rem;
    line-height: 1.3;
    margin: 0;
    min-height: 2.6em;
    overflow: hidden;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
  }

  &__bottom {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-top: auto;
    padding-top: 12px;
  }

  &__price {
    font-size: 1.25rem;
    font-weight: 600;
    color: var(--color-text);
  }
}

@keyframes heartbeat {
  0%, 100% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.3);
  }
}
</style>
