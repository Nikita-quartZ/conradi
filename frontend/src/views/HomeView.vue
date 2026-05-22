<script setup>
import { ref, onMounted } from "vue";
import { useRouter } from "vue-router";
import { catalogApi } from "@/api";
import Button from "primevue/button";

const router = useRouter();

const DESCRIPTIONS = {
  2: "Эксклюзивные композиции от наших флористов",
  3: "Одна нота — одно настроение",
  4: "Для самого важного дня",
  5: "Удобный и элегантный подарок",
  6: "Аранжировки из живых цветов",
  7: "Долгоживущие решения",
};

const COVER_PRODUCT_ID = {
  2: 9,
  3: 30,
};

const HERO_PRODUCT_IDS = [13, 21];

const categories = ref([]);
const heroImages = ref([]);

async function loadCategoriesWithCover() {
  const { data } = await catalogApi.categories();
  const result = await Promise.all(
    data.items.map(async (c) => {
      const coverProductId = COVER_PRODUCT_ID[c.id];
      let image = null;
      if (coverProductId) {
        const { data: pd } = await catalogApi.product(coverProductId);
        image = pd.product?.images?.[0]?.url || null;
      } else {
        const r = await catalogApi.products({ category_id: c.id, per_page: 1 });
        image = r.data.items[0]?.images?.[0]?.url || null;
      }
      return {
        id: c.id,
        title: c.title,
        desc: DESCRIPTIONS[c.id] || "",
        image,
      };
    }),
  );
  categories.value = result;
}

async function loadHeroImages() {
  const responses = await Promise.all(
    HERO_PRODUCT_IDS.map((id) => catalogApi.product(id).catch(() => null)),
  );
  heroImages.value = responses
    .map((r) => r?.data?.product?.images?.[0]?.url)
    .filter(Boolean);
}

function openCatalog(categoryId) {
  router.push({ path: "/catalog", query: categoryId ? { category: categoryId } : {} });
}

onMounted(() => {
  loadCategoriesWithCover();
  loadHeroImages();
});
</script>

<template>
  <section class="hero">
    <div class="container hero__inner">
      <div class="hero__text">
        <p class="hero__eyebrow">Conradi · Florist studio</p>
        <h1 class="hero__title">
          Букеты,<br />
          собранные с&nbsp;любовью
        </h1>
        <p class="hero__lead">
          Авторские композиции из&nbsp;свежих цветов с&nbsp;доставкой по&nbsp;городу.
          Подбираем сочетания так, чтобы каждый букет звучал как комплимент.
        </p>
        <div class="hero__cta">
          <Button label="Смотреть каталог" size="large" @click="openCatalog()" />
          <Button
            label="Узнать о доставке"
            severity="secondary"
            text
            size="large"
            @click="router.push('/delivery')"
          />
        </div>
      </div>
      <div class="hero__media">
        <div class="hero__card hero__card--lg">
          <img v-if="heroImages[0]" :src="heroImages[0]" alt="" />
        </div>
        <div class="hero__card hero__card--sm">
          <img v-if="heroImages[1]" :src="heroImages[1]" alt="" />
        </div>
      </div>
    </div>
  </section>

  <section class="categories">
    <div class="container">
      <header class="section-head">
        <h2>Категории</h2>
        <p>Каждая — со своим характером</p>
      </header>
      <div class="categories__grid">
        <article
          v-for="cat in categories"
          :key="cat.id"
          class="category-card"
          @click="openCatalog(cat.id)"
        >
          <div class="category-card__image">
            <img v-if="cat.image" :src="cat.image" :alt="cat.title" />
          </div>
          <div class="category-card__body">
            <h3>{{ cat.title }}</h3>
            <p>{{ cat.desc }}</p>
            <span class="category-card__link">
              Смотреть <i class="pi pi-arrow-right" />
            </span>
          </div>
        </article>
      </div>
    </div>
  </section>

  <section class="promise">
    <div class="container promise__inner">
      <div class="promise__item">
        <i class="pi pi-truck" />
        <h4>Доставка день в день</h4>
        <p>Если заказ оформлен до 17:00 — привезём сегодня</p>
      </div>
      <div class="promise__item">
        <i class="pi pi-heart" />
        <h4>Только свежие цветы</h4>
        <p>Партии каждое утро. Гарантия свежести 3 дня</p>
      </div>
      <div class="promise__item">
        <i class="pi pi-gift" />
        <h4>Бережная упаковка</h4>
        <p>Авторская упаковка и открытка в каждом заказе</p>
      </div>
    </div>
  </section>
</template>

<style lang="scss" scoped>
@use "@/assets/styles/variables" as *;

.hero {
  background: var(--color-surface);
  padding: 80px 0 100px;

  &__inner {
    display: grid;
    grid-template-columns: 1.05fr 1fr;
    align-items: center;
    gap: 64px;
  }

  &__eyebrow {
    text-transform: uppercase;
    letter-spacing: 0.18em;
    font-size: 0.8rem;
    color: var(--color-primary);
    margin: 0 0 24px;
    font-weight: 500;
  }

  &__title {
    margin: 0 0 24px;
    font-weight: 500;
  }

  &__lead {
    color: var(--color-text-muted);
    font-size: 1.05rem;
    max-width: 480px;
    margin: 0 0 36px;
  }

  &__cta {
    display: flex;
    gap: 12px;
    flex-wrap: wrap;
  }

  &__media {
    display: grid;
    grid-template-columns: 1fr 1fr;
    grid-template-rows: 1fr 1fr;
    gap: 16px;
    height: 520px;
  }

  &__card {
    border-radius: var(--radius-lg);
    overflow: hidden;
    background: linear-gradient(
      135deg,
      var(--color-secondary) 0%,
      #e8dcc1 50%,
      var(--color-primary-light) 100%
    );

    img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }

    &--lg {
      grid-row: span 2;
    }

    &--sm {
      background: linear-gradient(
        135deg,
        var(--color-primary-light) 0%,
        var(--color-primary) 100%
      );
    }
  }
}

.section-head {
  text-align: center;
  margin-bottom: 56px;

  h2 {
    margin: 0 0 8px;
  }

  p {
    color: var(--color-text-muted);
    margin: 0;
  }
}

.categories {
  padding: 96px 0;

  &__grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 24px;
  }
}

.category-card {
  background: var(--color-surface);
  border-radius: var(--radius-lg);
  overflow: hidden;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
  cursor: pointer;

  &:hover {
    transform: translateY(-4px);
    box-shadow: $shadow-lg;

    .category-card__link i {
      transform: translateX(4px);
    }
  }

  &__image {
    height: 240px;
    overflow: hidden;
    background: linear-gradient(
      135deg,
      var(--color-secondary),
      var(--color-primary-light)
    );

    img {
      width: 100%;
      height: 100%;
      object-fit: cover;
      transition: transform 0.4s ease;
    }
  }

  &:hover &__image img {
    transform: scale(1.05);
  }

  &__body {
    padding: 24px 28px 28px;

    h3 {
      font-size: 1.5rem;
      margin: 0 0 8px;
    }

    p {
      color: var(--color-text-muted);
      margin: 0 0 16px;
      font-size: 0.95rem;
    }
  }

  &__link {
    color: var(--color-primary);
    font-weight: 500;
    font-size: 0.92rem;
    display: inline-flex;
    align-items: center;
    gap: 8px;

    i {
      transition: transform 0.2s ease;
      font-size: 0.8rem;
    }
  }
}

.promise {
  background: var(--color-secondary);
  padding: 64px 0;

  &__inner {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 48px;
  }

  &__item {
    text-align: center;

    i {
      font-size: 2rem;
      color: var(--color-primary);
      margin-bottom: 16px;
      display: inline-block;
    }

    h4 {
      font-family: var(--font-display);
      font-size: 1.3rem;
      margin: 0 0 8px;
    }

    p {
      color: var(--color-text-muted);
      margin: 0;
    }
  }
}

@media (max-width: 960px) {
  .hero__inner,
  .categories__grid,
  .promise__inner {
    grid-template-columns: 1fr;
  }
  .hero__media {
    height: 360px;
  }
}

@media (max-width: 600px) {
  .hero {
    padding: 48px 0 64px;

    &__media {
      height: 240px;
      gap: 8px;
    }

    &__cta {
      flex-direction: column;
      align-items: stretch;

      :deep(.p-button) {
        width: 100%;
        justify-content: center;
      }
    }
  }

  .categories {
    padding: 64px 0;

    &__grid {
      gap: 16px;
    }
  }

  .category-card__image {
    height: 180px;
  }

  .promise {
    padding: 48px 0;

    &__inner {
      gap: 32px;
    }
  }

  .section-head {
    margin-bottom: 32px;
  }
}
</style>
