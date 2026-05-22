<script setup>
import { computed, ref, toRef } from "vue";
import { useRoute, useRouter } from "vue-router";
import { catalogApi, ratingsApi } from "@/api";
import { useAuthStore } from "@/stores/auth";
import { useFavoritesStore } from "@/stores/favorites";
import { useCartStore } from "@/stores/cart";
import { useAsyncData } from "@/composables/useAsyncData";
import { useFlash } from "@/composables/useFlash";
import { formatPrice } from "@/utils/format";
import StarRating from "@/components/StarRating.vue";
import Button from "primevue/button";
import InputNumber from "primevue/inputnumber";
import Message from "primevue/message";

const route = useRoute();
const router = useRouter();
const auth = useAuthStore();
const favorites = useFavoritesStore();
const cart = useCartStore();
const { message: flashMessage, success: flashSuccess } = useFlash();

const productId = toRef(() => route.params.id);

const activeImage = ref(0);
const quantity = ref(1);
const myStars = ref(0);

const { data: product, pending } = useAsyncData(
  async () => {
    const { data } = await catalogApi.product(productId.value);
    activeImage.value = 0;
    quantity.value = 1;
    if (auth.isAuthenticated) {
      const r = await ratingsApi.mine(data.product.id);
      myStars.value = r.data.stars || 0;
    } else {
      myStars.value = 0;
    }
    return data.product;
  },
  { watch: [productId], onError: () => null },
);

const isFav = computed(() => product.value && favorites.isFavorite(product.value.id));
const inStock = computed(() => (product.value?.stock ?? 0) > 0);

function ensureAuth() {
  if (auth.isAuthenticated) return true;
  router.push({ path: "/login", query: { redirect: route.fullPath } });
  return false;
}

async function addToCart() {
  if (!ensureAuth()) return;
  await cart.add(product.value.id, quantity.value);
  flashSuccess("Добавлено в корзину");
}

async function toggleFav() {
  if (!ensureAuth()) return;
  await favorites.toggle(product.value.id);
}

async function setRating(stars) {
  if (!ensureAuth()) return;
  myStars.value = stars;
  const { data } = await ratingsApi.set(product.value.id, stars);
  product.value.average_rating = data.average_rating;
  flashSuccess("Спасибо за оценку!");
}
</script>

<template>
  <section v-if="pending" class="product-page">
    <div class="container">Загружаем…</div>
  </section>

  <section v-else-if="!product" class="product-page">
    <div class="container">
      <h1>Товар не найден</h1>
      <Button label="К каталогу" @click="router.push('/catalog')" />
    </div>
  </section>

  <section v-else class="product-page">
    <div class="container product-page__grid">
      <div class="gallery">
        <div class="gallery__main">
          <img
            v-if="product.images.length"
            :src="product.images[activeImage].url"
            :alt="product.title"
          />
          <div v-else class="gallery__placeholder">
            <i class="pi pi-image" />
          </div>
        </div>
        <div v-if="product.images.length > 1" class="gallery__thumbs">
          <button
            v-for="(img, idx) in product.images"
            :key="img.id"
            :class="{ active: idx === activeImage }"
            @click="activeImage = idx"
          >
            <img :src="img.url" :alt="`${product.title} ${idx + 1}`" />
          </button>
        </div>
      </div>

      <div class="info">
        <div class="info__meta">
          <span class="info__category">{{ product.category.title }}</span>
          <span class="info__type">{{ product.product_type.title }}</span>
        </div>
        <h1 class="info__title">{{ product.title }}</h1>

        <div class="info__rating">
          <StarRating :model-value="product.average_rating" readonly />
          <span class="info__rating-value">
            {{ product.average_rating > 0 ? product.average_rating : "Нет оценок" }}
          </span>
        </div>

        <div class="info__price">{{ formatPrice(product.price) }}</div>

        <div class="info__stock" :class="{ 'info__stock--out': !inStock }">
          <i :class="inStock ? 'pi pi-check-circle' : 'pi pi-times-circle'" />
          <span v-if="inStock">В наличии: {{ product.stock }} шт.</span>
          <span v-else>Нет в наличии</span>
        </div>

        <Message v-if="flashMessage" :severity="flashMessage.severity" :closable="false">
          {{ flashMessage.text }}
        </Message>

        <div v-if="inStock" class="info__cta">
          <InputNumber
            v-model="quantity"
            :min="1"
            :max="product.stock"
            show-buttons
            button-layout="horizontal"
          />
          <Button
            label="В корзину"
            icon="pi pi-shopping-bag"
            size="large"
            class="info__add"
            @click="addToCart"
          />
          <Button
            :icon="isFav ? 'pi pi-heart-fill' : 'pi pi-heart'"
            severity="secondary"
            outlined
            size="large"
            aria-label="В избранное"
            @click="toggleFav"
          />
        </div>

        <div v-if="auth.isAuthenticated" class="info__rate">
          <h4>Оцените букет</h4>
          <StarRating :model-value="myStars" size="lg" @update:model-value="setRating" />
        </div>

        <div class="info__description">
          <h4>Описание</h4>
          <p>{{ product.description }}</p>
        </div>
      </div>
    </div>
  </section>
</template>

<style lang="scss" scoped>
@use "@/assets/styles/variables" as *;

.product-page {
  padding: 48px 0 80px;
  min-height: 60vh;

  &__grid {
    display: grid;
    grid-template-columns: 1.1fr 1fr;
    gap: 64px;
  }
}

.gallery {
  &__main {
    aspect-ratio: 1 / 1;
    background: var(--color-secondary);
    border-radius: var(--radius-lg);
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
      font-size: 5rem;
      color: var(--color-primary-light);
      opacity: 0.5;
    }
  }

  &__thumbs {
    display: flex;
    gap: 8px;
    margin-top: 12px;

    button {
      width: 72px;
      height: 72px;
      border-radius: var(--radius);
      overflow: hidden;
      border: 2px solid transparent;
      padding: 0;
      cursor: pointer;
      background: var(--color-secondary);
      transition: border-color 0.15s ease;

      img {
        width: 100%;
        height: 100%;
        object-fit: cover;
      }

      &.active {
        border-color: var(--color-primary);
      }
    }
  }
}

.info {
  display: flex;
  flex-direction: column;
  gap: 24px;

  &__meta {
    display: flex;
    gap: 16px;
    text-transform: uppercase;
    letter-spacing: 0.1em;
    font-size: 0.75rem;
    color: var(--color-text-muted);
  }

  &__category {
    color: var(--color-primary);
    font-weight: 500;
  }

  &__title {
    margin: 0;
  }

  &__rating {
    display: flex;
    align-items: center;
    gap: 12px;

    &-value {
      font-size: 0.95rem;
      color: var(--color-text-muted);
    }
  }

  &__price {
    font-size: 2.2rem;
    font-family: var(--font-display);
    color: var(--color-text);
  }

  &__stock {
    display: flex;
    align-items: center;
    gap: 8px;
    color: var(--success, #6f8f6a);
    font-weight: 500;

    &--out {
      color: var(--danger, #b85c5c);
    }
  }

  &__cta {
    display: flex;
    align-items: center;
    gap: 12px;
    flex-wrap: wrap;
  }

  &__add {
    flex: 1;
    min-width: 200px;
  }

  &__rate {
    padding: 20px 24px;
    background: var(--color-surface);
    border-radius: var(--radius-lg);

    h4 {
      font-family: var(--font-body);
      font-size: 0.85rem;
      text-transform: uppercase;
      letter-spacing: 0.08em;
      color: var(--color-text-muted);
      margin: 0 0 12px;
    }
  }

  &__description {
    padding: 24px 28px;
    background: var(--color-surface);
    border-radius: var(--radius-lg);

    h4 {
      font-family: var(--font-display);
      font-size: 1.2rem;
      margin: 0 0 12px;
    }

    p {
      margin: 0;
      white-space: pre-line;
      color: var(--color-text-muted);
      line-height: 1.7;
    }
  }
}

@media (max-width: 900px) {
  .product-page__grid {
    grid-template-columns: 1fr;
    gap: 32px;
  }
}

@media (max-width: 600px) {
  .product-page {
    padding: 24px 0 56px;
  }

  .info {
    gap: 16px;

    &__price {
      font-size: 1.8rem;
    }

    &__cta {
      gap: 8px;
    }

    &__add {
      flex: 1 1 auto;
      min-width: 0;
    }

    &__description {
      padding: 20px;
    }

    &__rate {
      padding: 16px 20px;
    }
  }

  .gallery__thumbs {
    overflow-x: auto;
    padding-bottom: 4px;

    button {
      flex-shrink: 0;
    }
  }
}
</style>
