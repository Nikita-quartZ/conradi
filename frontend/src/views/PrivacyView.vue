<script setup>
import { formatDate } from "@/utils/format";

const updatedAt = new Date("2026-05-25");
</script>

<template>
  <section class="privacy">
    <div class="container privacy__inner">
      <header class="privacy__head">
        <h1>Политика конфиденциальности</h1>
        <p>Последнее обновление: {{ formatDate(updatedAt) }}</p>
      </header>

      <article class="privacy__body">
        <h2>1. Общие положения</h2>
        <p>
          Настоящая Политика конфиденциальности (далее&nbsp;— «Политика») описывает, какую
          информацию о&nbsp;посетителях и&nbsp;клиентах магазина Conradi мы&nbsp;собираем,
          как используем и&nbsp;на&nbsp;каких основаниях храним.
        </p>

        <h2>2. Какие данные мы собираем</h2>
        <ul>
          <li>
            При регистрации&nbsp;— ФИО, логин, телефон, дата&nbsp;рождения. Пароль хранится
            только в&nbsp;виде хеша и&nbsp;никому не&nbsp;передаётся.
          </li>
          <li>
            При оформлении заказа&nbsp;— адрес доставки, желаемая дата и&nbsp;время,
            способ оплаты. Данные карты в&nbsp;демо-проекте не&nbsp;сохраняются.
          </li>
          <li>
            При посещении сайта&nbsp;— технические данные браузера и&nbsp;cookie-файлы,
            если вы&nbsp;дали на&nbsp;это согласие.
          </li>
        </ul>

        <h2>3. Cookie-файлы</h2>
        <p>
          Cookies используются для&nbsp;авторизации, корзины и&nbsp;избранного. Без&nbsp;них
          сайт работает в&nbsp;ограниченном режиме. Вы&nbsp;можете отозвать согласие
          в&nbsp;любой момент, очистив данные сайта в&nbsp;настройках браузера.
        </p>

        <h2>4. Как мы используем данные</h2>
        <ul>
          <li>Для&nbsp;обработки и&nbsp;доставки ваших заказов.</li>
          <li>Для&nbsp;уведомлений о&nbsp;статусе заказа.</li>
          <li>Для&nbsp;улучшения сервиса и&nbsp;ассортимента.</li>
        </ul>

        <h2>5. Передача третьим лицам</h2>
        <p>
          Мы&nbsp;не&nbsp;передаём ваши персональные данные третьим лицам, кроме случаев,
          необходимых для&nbsp;исполнения заказа (служба доставки) или&nbsp;предусмотренных
          законом.
        </p>

        <h2>6. Ваши права</h2>
        <p>
          Вы&nbsp;можете в&nbsp;любой момент:
        </p>
        <ul>
          <li>Изменить свои данные в&nbsp;личном&nbsp;кабинете.</li>
          <li>Запросить удаление аккаунта, написав на&nbsp;<a href="mailto:hello@conradi.ru">hello@conradi.ru</a>.</li>
          <li>Отозвать согласие на&nbsp;обработку данных.</li>
        </ul>

        <h2>7. Контакты</h2>
        <p>
          По&nbsp;вопросам, связанным с&nbsp;обработкой персональных данных, пишите
          на&nbsp;<a href="mailto:hello@conradi.ru">hello@conradi.ru</a> или
          звоните <a href="tel:+78005553535">+7 800 555 35 35</a>.
        </p>
      </article>
    </div>
  </section>
</template>

<style lang="scss" scoped>
@use "@/assets/styles/variables" as *;

.privacy {
  padding: 48px 0 80px;

  &__inner {
    max-width: 760px;
  }

  &__head {
    margin-bottom: 40px;

    h1 {
      margin: 0 0 8px;
    }

    p {
      color: var(--color-text-muted);
      margin: 0;
      font-size: 0.95rem;
    }
  }

  &__body {
    background: var(--color-surface);
    border-radius: var(--radius-lg);
    padding: 40px 44px;
    line-height: 1.7;

    h2 {
      font-size: 1.2rem;
      margin: 32px 0 12px;

      &:first-child {
        margin-top: 0;
      }
    }

    p,
    ul {
      color: var(--color-text);
      margin: 0 0 12px;
    }

    ul {
      padding-left: 22px;

      li {
        margin-bottom: 6px;
      }
    }

    a {
      color: var(--color-primary);

      &:hover {
        text-decoration: underline;
      }
    }
  }
}

@media (max-width: 600px) {
  .privacy {
    padding: 24px 0 56px;

    &__body {
      padding: 24px 20px;
    }

    &__head {
      margin-bottom: 24px;

      h1 {
        font-size: 1.6rem;
      }
    }
  }
}
</style>
