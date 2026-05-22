<script setup>
import { ref, onMounted } from "vue";
import { useRouter } from "vue-router";
import { catalogApi } from "@/api";
import Button from "primevue/button";

const router = useRouter();
const heroImage = ref(null);

onMounted(async () => {
  try {
    const { data } = await catalogApi.product(22);
    heroImage.value = data.product?.images?.[0]?.url || null;
  } catch (e) {
    heroImage.value = null;
  }
});

const facts = [
  { icon: "pi pi-calendar", number: "12+", label: "лет на рынке" },
  { icon: "pi pi-users", number: "20", label: "флористов в команде" },
  { icon: "pi pi-heart", number: "10 000+", label: "довольных клиентов" },
  { icon: "pi pi-globe", number: "24/7", label: "приём заказов" },
];

const values = [
  {
    icon: "pi pi-sparkles",
    title: "Только свежие цветы",
    text:
      "Каждое утро поставка из голландского и эквадорского аукционов. Букет, который вы получите, был на стебле 2–3 дня назад.",
  },
  {
    icon: "pi pi-palette",
    title: "Авторские композиции",
    text:
      "Наши флористы — выпускники европейских школ. Каждый букет собирается вручную, как маленькая картина.",
  },
  {
    icon: "pi pi-comment",
    title: "Внимание к деталям",
    text:
      "Подбираем упаковку, пишем открытку от руки, заворачиваем стебли во влажную марлю. Цветы любят заботу.",
  },
];
</script>

<template>
  <section class="about-hero">
    <div class="container about-hero__inner">
      <div>
        <p class="about-hero__eyebrow">О студии</p>
        <h1>Conradi — это про цветы и&nbsp;людей</h1>
        <p class="about-hero__lead">
          Мы&nbsp;собираем букеты с&nbsp;2014&nbsp;года.
          Начинали как маленькая студия в&nbsp;центре города, сегодня
          — команда из&nbsp;20&nbsp;флористов и&nbsp;собственная цветочная база.
          Но&nbsp;принцип тот&nbsp;же: каждый букет&nbsp;— как комплимент.
        </p>
        <Button label="Смотреть каталог" size="large" @click="router.push('/catalog')" />
      </div>
      <div class="about-hero__visual">
        <img v-if="heroImage" :src="heroImage" alt="" />
      </div>
    </div>
  </section>

  <section class="facts">
    <div class="container">
      <div class="facts__grid">
        <article v-for="f in facts" :key="f.label" class="facts__item">
          <i :class="f.icon" />
          <div class="facts__number">{{ f.number }}</div>
          <div class="facts__label">{{ f.label }}</div>
        </article>
      </div>
    </div>
  </section>

  <section class="values">
    <div class="container">
      <header class="section-head">
        <h2>Наши принципы</h2>
        <p>То, что мы повторяем себе каждое утро на летучке</p>
      </header>
      <div class="values__grid">
        <article v-for="v in values" :key="v.title" class="values__item">
          <i :class="v.icon" />
          <h3>{{ v.title }}</h3>
          <p>{{ v.text }}</p>
        </article>
      </div>
    </div>
  </section>

  <section class="contact-cta">
    <div class="container contact-cta__inner">
      <div>
        <h2>Не нашли подходящего букета?</h2>
        <p>Напишите нам, и мы соберём индивидуальную композицию под ваш повод</p>
      </div>
      <div class="contact-cta__actions">
        <a href="tel:+78005553535" class="contact-cta__phone">+7 800 555 35 35</a>
        <a href="mailto:hello@conradi.ru">hello@conradi.ru</a>
      </div>
    </div>
  </section>
</template>

<style lang="scss" scoped>
@use "@/assets/styles/variables" as *;

.about-hero {
  background: var(--color-surface);
  padding: 80px 0 100px;

  &__inner {
    display: grid;
    grid-template-columns: 1.1fr 1fr;
    gap: 64px;
    align-items: center;
  }

  &__eyebrow {
    text-transform: uppercase;
    letter-spacing: 0.18em;
    font-size: 0.8rem;
    color: var(--color-primary);
    margin: 0 0 24px;
    font-weight: 500;
  }

  h1 {
    margin: 0 0 24px;
  }

  &__lead {
    color: var(--color-text-muted);
    font-size: 1.05rem;
    margin: 0 0 36px;
    max-width: 520px;
  }

  &__visual {
    height: 480px;
    border-radius: var(--radius-lg);
    overflow: hidden;
    background:
      linear-gradient(
        135deg,
        var(--color-secondary) 0%,
        var(--color-primary-light) 100%
      );

    img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }
  }
}

.facts {
  background: var(--color-surface-alt);
  padding: 64px 0;

  &__grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 24px;
  }

  &__item {
    text-align: center;
    background: var(--color-surface);
    padding: 32px 24px;
    border-radius: var(--radius-lg);

    i {
      font-size: 2rem;
      color: var(--color-primary);
      margin-bottom: 16px;
      display: inline-block;
    }
  }

  &__number {
    font-family: var(--font-display);
    font-size: 2.6rem;
    font-weight: 600;
    color: var(--color-text);
    line-height: 1;
    margin-bottom: 8px;
  }

  &__label {
    color: var(--color-text-muted);
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

.values {
  padding: 96px 0;

  &__grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 24px;
  }

  &__item {
    background: var(--color-surface);
    border-radius: var(--radius-lg);
    padding: 32px;

    i {
      width: 56px;
      height: 56px;
      border-radius: 50%;
      background: var(--color-secondary);
      color: var(--color-primary);
      display: inline-flex;
      align-items: center;
      justify-content: center;
      font-size: 1.4rem;
      margin-bottom: 24px;
    }

    h3 {
      margin: 0 0 12px;
    }

    p {
      color: var(--color-text-muted);
      margin: 0;
      line-height: 1.6;
    }
  }
}

.contact-cta {
  padding: 64px 0;

  &__inner {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 32px;

    h2 {
      margin: 0 0 8px;
    }

    p {
      margin: 0;
      color: var(--color-text-muted);
    }
  }

  &__actions {
    display: flex;
    flex-direction: column;
    align-items: flex-end;
    gap: 4px;
  }

  &__phone {
    font-size: 1.4rem;
    font-family: var(--font-display);
    color: var(--color-primary);
  }

  a {
    color: var(--color-text);

    &:hover {
      color: var(--color-primary);
    }
  }
}

@media (max-width: 960px) {
  .about-hero__inner,
  .facts__grid,
  .values__grid,
  .contact-cta__inner {
    grid-template-columns: 1fr;
    flex-direction: column;
    align-items: stretch;
  }
  .facts__grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 600px) {
  .about-hero {
    padding: 48px 0 64px;

    &__visual {
      height: 280px;
    }
  }

  .facts {
    padding: 48px 0;

    &__grid {
      grid-template-columns: 1fr;
    }

    &__number {
      font-size: 2.2rem;
    }
  }

  .values {
    padding: 64px 0;

    &__item {
      padding: 24px 20px;
    }
  }

  .contact-cta {
    padding: 48px 0;

    &__actions {
      align-items: flex-start;
    }

    &__phone {
      font-size: 1.2rem;
    }
  }
}
</style>
