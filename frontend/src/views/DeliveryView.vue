<script setup>
import { useRouter } from "vue-router";
import Button from "primevue/button";

const router = useRouter();

const zones = [
  { name: "Исторический центр СПб", time: "60–90 мин", price: "Бесплатно от 3 000 ₽" },
  { name: "В пределах КАД", time: "2 часа", price: "400 ₽" },
  { name: "За КАД (до 10 км)", time: "2,5 часа", price: "600 ₽" },
  { name: "Ленобласть (10–30 км)", time: "по согласованию", price: "от 1 200 ₽" },
];

const steps = [
  { icon: "pi pi-shopping-bag", title: "Оформите заказ", text: "Выберите букет, заполните адрес, дату и время" },
  { icon: "pi pi-credit-card", title: "Оплатите удобным способом", text: "Картой онлайн или курьеру при получении" },
  { icon: "pi pi-sparkles", title: "Мы соберём букет", text: "Флорист соберёт композицию в день доставки" },
  { icon: "pi pi-truck", title: "Курьер привезёт точно в срок", text: "С точностью до 15 минут в выбранном окне" },
];
</script>

<template>
  <section class="delivery-hero">
    <div class="container delivery-hero__inner">
      <div>
        <p class="delivery-hero__eyebrow">Доставка</p>
        <h1>Привозим букеты день в&nbsp;день</h1>
        <p class="delivery-hero__lead">
          Если оформить заказ до&nbsp;17:00&nbsp;— привезём сегодня.
          Можно выбрать любое окно с&nbsp;шагом 15&nbsp;минут с&nbsp;9:00 до&nbsp;21:00.
          Бесплатно от&nbsp;3&nbsp;000&nbsp;₽ в&nbsp;историческом центре Санкт-Петербурга.
        </p>
        <Button label="Перейти в каталог" size="large" @click="router.push('/catalog')" />
      </div>
      <div class="delivery-hero__visual">
        <iframe
          class="delivery-hero__map"
          src="https://yandex.ru/map-widget/v1/?from=mapframe&ll=30.335100%2C59.934300&mode=whatshere&utm_source=mapframe&z=15&whatshere%5Bpoint%5D=30.335100%2C59.934300&whatshere%5Bzoom%5D=15"
          loading="lazy"
          title="Цветочный магазин в центре Санкт-Петербурга"
          allowfullscreen
        />
      </div>
    </div>
  </section>

  <section class="zones">
    <div class="container">
      <header class="section-head">
        <h2>Зоны и стоимость</h2>
        <p>Санкт-Петербург и Ленобласть</p>
      </header>
      <div class="zones__table">
        <article v-for="z in zones" :key="z.name" class="zones__row">
          <div class="zones__name">
            <i class="pi pi-map-marker" />
            <strong>{{ z.name }}</strong>
          </div>
          <div class="zones__time">{{ z.time }}</div>
          <div class="zones__price">{{ z.price }}</div>
        </article>
      </div>
    </div>
  </section>

  <section class="how">
    <div class="container">
      <header class="section-head">
        <h2>Как это работает</h2>
      </header>
      <div class="how__grid">
        <article v-for="(s, idx) in steps" :key="s.title" class="how__step">
          <div class="how__num">0{{ idx + 1 }}</div>
          <i :class="s.icon" />
          <h3>{{ s.title }}</h3>
          <p>{{ s.text }}</p>
        </article>
      </div>
    </div>
  </section>

  <section class="faq">
    <div class="container">
      <header class="section-head">
        <h2>Частые вопросы</h2>
      </header>
      <div class="faq__list">
        <details class="faq__item">
          <summary>Можно заказать букет к конкретному часу?</summary>
          <p>
            Да, при оформлении выбирайте окно с&nbsp;шагом 15 минут с&nbsp;9:00 до&nbsp;21:00.
            Курьер приедет в&nbsp;это окно с&nbsp;точностью до&nbsp;15&nbsp;минут.
          </p>
        </details>
        <details class="faq__item">
          <summary>А если меня не будет дома?</summary>
          <p>
            Курьер позвонит за&nbsp;30 минут до&nbsp;приезда. Если адресата не&nbsp;будет —
            можем оставить букет соседям или на&nbsp;ресепшене (по&nbsp;договорённости).
          </p>
        </details>
        <details class="faq__item">
          <summary>Можно ли отменить заказ?</summary>
          <p>
            Да, если букет ещё не&nbsp;собран. После начала сборки отмена невозможна
            — цветы уже не&nbsp;вернуть к&nbsp;поставщику.
          </p>
        </details>
        <details class="faq__item">
          <summary>Что если букет не понравится получателю?</summary>
          <p>
            Свяжитесь с&nbsp;нами в&nbsp;течение 4&nbsp;часов после доставки. Заменим букет
            или вернём деньги&nbsp;— ваш комфорт важнее.
          </p>
        </details>
      </div>
    </div>
  </section>
</template>

<style lang="scss" scoped>
@use "@/assets/styles/variables" as *;

.delivery-hero {
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
    max-width: 520px;
    margin: 0 0 36px;
  }

  &__visual {
    height: 420px;
    border-radius: var(--radius-lg);
    overflow: hidden;
    position: relative;
    background: var(--color-secondary);
  }

  &__map {
    width: 100%;
    height: 100%;
    border: 0;
    display: block;
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

.zones {
  padding: 96px 0;

  &__table {
    background: var(--color-surface);
    border-radius: var(--radius-lg);
    overflow: hidden;
    max-width: 880px;
    margin: 0 auto;
  }

  &__row {
    display: grid;
    grid-template-columns: 1.6fr 1fr 1fr;
    padding: 24px 32px;
    align-items: center;
    border-bottom: 1px solid var(--color-border);
    gap: 24px;

    &:last-child {
      border-bottom: 0;
    }
  }

  &__name {
    display: flex;
    align-items: center;
    gap: 12px;

    i {
      color: var(--color-primary);
    }
  }

  &__time {
    color: var(--color-text-muted);
  }

  &__price {
    text-align: right;
    font-weight: 600;
    color: var(--color-text);
  }
}

.how {
  background: var(--color-surface-alt);
  padding: 96px 0;

  &__grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 24px;
  }

  &__step {
    background: var(--color-surface);
    border-radius: var(--radius-lg);
    padding: 32px 28px;
    position: relative;

    i {
      width: 48px;
      height: 48px;
      border-radius: 50%;
      background: var(--color-secondary);
      color: var(--color-primary);
      display: inline-flex;
      align-items: center;
      justify-content: center;
      font-size: 1.2rem;
      margin-bottom: 16px;
    }

    h3 {
      font-size: 1.2rem;
      margin: 0 0 8px;
    }

    p {
      color: var(--color-text-muted);
      margin: 0;
      font-size: 0.95rem;
    }
  }

  &__num {
    position: absolute;
    top: 24px;
    right: 28px;
    font-family: var(--font-display);
    font-size: 1.2rem;
    color: var(--color-primary-light);
  }
}

.faq {
  padding: 96px 0;

  &__list {
    max-width: 720px;
    margin: 0 auto;
    display: flex;
    flex-direction: column;
    gap: 12px;
  }

  &__item {
    background: var(--color-surface);
    border-radius: var(--radius-lg);
    padding: 20px 28px;

    summary {
      cursor: pointer;
      font-weight: 500;
      font-size: 1.05rem;
      list-style: none;
      padding-right: 24px;
      position: relative;

      &::after {
        content: "+";
        position: absolute;
        right: 0;
        top: 50%;
        transform: translateY(-50%);
        color: var(--color-primary);
        font-size: 1.4rem;
        transition: transform 0.2s ease;
      }
    }

    &[open] summary::after {
      transform: translateY(-50%) rotate(45deg);
    }

    p {
      margin: 16px 0 0;
      color: var(--color-text-muted);
      line-height: 1.6;
    }
  }
}

@media (max-width: 900px) {
  .delivery-hero__inner,
  .how__grid {
    grid-template-columns: 1fr;
  }
  .zones__row {
    grid-template-columns: 1fr;
    text-align: left;
  }
  .zones__price {
    text-align: left;
  }
}

@media (max-width: 600px) {
  .delivery-hero {
    padding: 48px 0 64px;

    &__visual {
      height: 280px;
    }
  }

  .zones,
  .how,
  .faq {
    padding: 64px 0;
  }

  .zones__row {
    padding: 16px 20px;
  }

  .how__step {
    padding: 24px 20px;
  }

  .faq__item {
    padding: 16px 20px;

    summary {
      font-size: 0.95rem;
    }
  }
}
</style>
