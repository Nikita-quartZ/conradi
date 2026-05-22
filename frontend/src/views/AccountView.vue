<script setup>
import { useRouter, RouterLink } from "vue-router";
import { useAuthStore } from "@/stores/auth";
import Button from "primevue/button";

const auth = useAuthStore();
const router = useRouter();

function logout() {
  auth.logout();
  router.push("/");
}

function fmtDate(d) {
  if (!d) return "";
  return new Date(d).toLocaleDateString("ru-RU");
}
</script>

<template>
  <section class="account">
    <div class="container account__layout">
      <aside class="account__sidebar">
        <div class="account__avatar">
          <i class="pi pi-user" />
        </div>
        <h2>{{ auth.user?.full_name }}</h2>
        <p>{{ auth.user?.login }}</p>
        <nav class="account__nav">
          <RouterLink to="/account">Личные данные</RouterLink>
          <RouterLink to="/orders">Мои заказы</RouterLink>
          <RouterLink to="/favorites">Избранное</RouterLink>
          <RouterLink v-if="auth.isAdmin" to="/admin">Админ-панель</RouterLink>
        </nav>
        <Button label="Выйти" severity="secondary" outlined @click="logout" />
      </aside>

      <div class="account__main">
        <h1>Личный кабинет</h1>
        <div class="account__card">
          <h3>Контакты</h3>
          <div class="account__row">
            <span>Имя</span>
            <strong>{{ auth.user?.full_name }}</strong>
          </div>
          <div class="account__row">
            <span>Логин</span>
            <strong>{{ auth.user?.login }}</strong>
          </div>
          <div class="account__row">
            <span>Телефон</span>
            <strong>{{ auth.user?.phone }}</strong>
          </div>
          <div class="account__row">
            <span>Дата рождения</span>
            <strong>{{ fmtDate(auth.user?.birthday) }}</strong>
          </div>
          <div class="account__row">
            <span>Зарегистрирован</span>
            <strong>{{ fmtDate(auth.user?.created_at) }}</strong>
          </div>
          <div v-if="auth.isAdmin" class="account__row">
            <span>Роль</span>
            <strong>Администратор</strong>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<style lang="scss" scoped>
@use "@/assets/styles/variables" as *;

.account {
  padding: 48px 0 80px;
  min-height: 60vh;

  &__layout {
    display: grid;
    grid-template-columns: 280px 1fr;
    gap: 32px;
    align-items: start;
  }

  &__sidebar {
    background: var(--color-surface);
    border-radius: var(--radius-lg);
    padding: 32px 24px;
    text-align: center;
    position: sticky;
    top: 100px;

    h2 {
      font-size: 1.3rem;
      margin: 0 0 4px;
    }

    p {
      color: var(--color-text-muted);
      margin: 0 0 20px;
      font-size: 0.9rem;
    }
  }

  &__avatar {
    width: 80px;
    height: 80px;
    border-radius: 50%;
    background: var(--color-secondary);
    color: var(--color-primary);
    display: flex;
    align-items: center;
    justify-content: center;
    margin: 0 auto 20px;

    i {
      font-size: 2rem;
    }
  }

  &__nav {
    display: flex;
    flex-direction: column;
    margin-bottom: 20px;

    a {
      padding: 10px 16px;
      border-radius: var(--radius);
      color: var(--color-text);
      text-align: left;

      &:hover {
        background: var(--color-secondary);
      }

      &.router-link-exact-active {
        background: var(--color-primary);
        color: #fff;
      }
    }
  }

  &__main {
    h1 {
      margin: 0 0 24px;
    }
  }

  &__card {
    background: var(--color-surface);
    border-radius: var(--radius-lg);
    padding: 28px;

    h3 {
      font-size: 1.3rem;
      margin: 0 0 20px;
    }
  }

  &__row {
    display: flex;
    justify-content: space-between;
    padding: 12px 0;
    border-bottom: 1px solid var(--color-border);

    &:last-child {
      border-bottom: 0;
    }

    span {
      color: var(--color-text-muted);
    }
  }
}

@media (max-width: 800px) {
  .account__layout {
    grid-template-columns: 1fr;
  }

  .account__sidebar {
    position: static;
  }
}

@media (max-width: 600px) {
  .account {
    padding: 24px 0 56px;
  }

  .account__main h1 {
    font-size: 1.8rem;
  }

  .account__card {
    padding: 20px;
  }

  .account__row {
    flex-direction: column;
    gap: 4px;
    align-items: flex-start;
  }
}
</style>
