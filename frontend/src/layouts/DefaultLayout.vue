<script setup>
import { onMounted, ref, useTemplateRef, watch } from "vue";
import { RouterLink, useRouter, useRoute } from "vue-router";
import { useAuthStore } from "@/stores/auth";
import { useCartStore } from "@/stores/cart";
import { useFavoritesStore } from "@/stores/favorites";
import Menu from "primevue/menu";
import ConfirmDialog from "primevue/confirmdialog";
import CookieBanner from "@/components/CookieBanner.vue";

const auth = useAuthStore();
const cart = useCartStore();
const favorites = useFavoritesStore();
const router = useRouter();
const route = useRoute();

const userMenu = useTemplateRef("userMenu");
const mobileNavOpen = ref(false);

watch(() => route.fullPath, () => {
  mobileNavOpen.value = false;
});

const userMenuItems = [
  { label: "Личный кабинет", icon: "pi pi-user", command: () => router.push("/account") },
  { label: "Мои заказы", icon: "pi pi-receipt", command: () => router.push("/orders") },
  { label: "Избранное", icon: "pi pi-heart", command: () => router.push("/favorites") },
  { separator: true },
  {
    label: "Админ-панель",
    icon: "pi pi-shield",
    command: () => router.push("/admin"),
    visible: () => auth.isAdmin,
  },
  {
    label: "Выйти",
    icon: "pi pi-sign-out",
    command: () => {
      auth.logout();
      cart.reset();
      favorites.reset();
      router.push("/");
    },
  },
];

function toggleUserMenu(e) {
  userMenu.value.toggle(e);
}

onMounted(() => {
  if (auth.isAuthenticated) {
    cart.load();
    favorites.load();
  }
});

watch(
  () => auth.isAuthenticated,
  (loggedIn) => {
    if (loggedIn) {
      cart.load();
      favorites.load();
    } else {
      cart.reset();
      favorites.reset();
    }
  },
);
</script>

<template>
  <div class="layout">
    <header class="header">
      <div class="container header__inner">
        <button
          class="header__burger"
          :class="{ 'header__burger--open': mobileNavOpen }"
          @click="mobileNavOpen = !mobileNavOpen"
          aria-label="Меню"
        >
          <span></span>
          <span></span>
          <span></span>
        </button>
        <RouterLink to="/" class="header__logo">Conradi</RouterLink>
        <nav class="header__nav" :class="{ 'header__nav--open': mobileNavOpen }">
          <RouterLink to="/catalog" class="header__link">Каталог</RouterLink>
          <RouterLink to="/about" class="header__link">О нас</RouterLink>
          <RouterLink to="/delivery" class="header__link">Доставка</RouterLink>
        </nav>
        <div
          v-if="mobileNavOpen"
          class="header__overlay"
          @click="mobileNavOpen = false"
        ></div>
        <div class="header__actions">
          <template v-if="auth.isAuthenticated">
            <RouterLink to="/favorites" class="header__icon" aria-label="Избранное">
              <i class="pi pi-heart" />
              <span v-if="favorites.ids.length" class="header__badge">
                {{ favorites.ids.length }}
              </span>
            </RouterLink>
            <RouterLink to="/cart" class="header__icon" aria-label="Корзина">
              <i class="pi pi-shopping-bag" />
              <span v-if="cart.count" class="header__badge">{{ cart.count }}</span>
            </RouterLink>
            <button
              class="header__icon header__user"
              @click="toggleUserMenu"
              aria-label="Меню"
            >
              <i class="pi pi-user" />
            </button>
            <Menu ref="userMenu" :model="userMenuItems" :popup="true" />
          </template>
          <template v-else>
            <RouterLink to="/login" class="header__login">Войти</RouterLink>
            <RouterLink
              to="/login"
              class="header__icon header__login-icon"
              aria-label="Войти"
            >
              <i class="pi pi-sign-in" />
            </RouterLink>
            <RouterLink to="/register" class="header__register">Регистрация</RouterLink>
          </template>
        </div>
      </div>
    </header>

    <main class="main">
      <slot />
    </main>

    <footer class="footer">
      <div class="container footer__inner">
        <div class="footer__brand">
          <div class="footer__logo">Conradi</div>
          <p class="footer__tagline">Цветы, которые рассказывают истории</p>
        </div>
        <div class="footer__col">
          <h4>Магазин</h4>
          <RouterLink to="/catalog">Каталог</RouterLink>
          <RouterLink to="/about">О нас</RouterLink>
          <RouterLink to="/delivery">Доставка</RouterLink>
        </div>
        <div class="footer__col">
          <h4>Контакты</h4>
          <a href="tel:+78005553535">+7 800 555 35 35</a>
          <a href="mailto:hello@conradi.ru">hello@conradi.ru</a>
        </div>
      </div>
      <div class="footer__bottom container">
        <span>© 2026 Conradi</span>
        <RouterLink to="/privacy" class="footer__bottom-link">
          Политика конфиденциальности
        </RouterLink>
      </div>
    </footer>

    <CookieBanner />
    <ConfirmDialog />
  </div>
</template>

<style lang="scss" scoped>
@use "@/assets/styles/variables" as *;

.layout {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background: var(--color-surface-alt);
}

.header {
  background: var(--color-surface);
  border-bottom: 1px solid var(--color-border);
  position: sticky;
  top: 0;
  z-index: 50;

  &__inner {
    display: flex;
    align-items: center;
    justify-content: space-between;
    height: 80px;
    gap: 32px;
    position: relative;
  }

  &__burger {
    display: none;
    flex-direction: column;
    justify-content: center;
    gap: 5px;
    width: 40px;
    height: 40px;
    border: 0;
    background: transparent;
    cursor: pointer;
    padding: 0;
    z-index: 60;

    span {
      display: block;
      width: 24px;
      height: 2px;
      background: var(--color-text);
      margin: 0 auto;
      transition: transform 0.2s ease, opacity 0.2s ease;
      transform-origin: center;
    }

    &--open span:nth-child(1) {
      transform: translateY(7px) rotate(45deg);
    }
    &--open span:nth-child(2) {
      opacity: 0;
    }
    &--open span:nth-child(3) {
      transform: translateY(-7px) rotate(-45deg);
    }
  }

  &__overlay {
    display: none;
  }

  &__logo {
    font-family: var(--font-display);
    font-size: 2rem;
    font-weight: 600;
    letter-spacing: 0.04em;
    color: var(--color-primary);
  }

  &__nav {
    display: flex;
    gap: 36px;
    flex: 1;
    justify-content: center;
  }

  &__link {
    font-size: 0.92rem;
    font-weight: 500;
    letter-spacing: 0.04em;
    text-transform: uppercase;
    color: var(--color-text);
    position: relative;

    &.router-link-active::after {
      content: "";
      position: absolute;
      left: 0;
      right: 0;
      bottom: -6px;
      height: 2px;
      background: var(--color-primary);
    }
  }

  &__actions {
    display: flex;
    align-items: center;
    gap: 8px;
  }

  &__icon {
    width: 42px;
    height: 42px;
    border-radius: 50%;
    border: 1px solid transparent;
    background: transparent;
    color: var(--color-text);
    cursor: pointer;
    transition: all 0.15s ease;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    position: relative;
    text-decoration: none;

    i {
      font-size: 1.15rem;
    }

    &:hover {
      background: var(--color-secondary);
      color: var(--color-primary);
    }
  }

  &__badge {
    position: absolute;
    top: 4px;
    right: 4px;
    min-width: 18px;
    height: 18px;
    padding: 0 5px;
    border-radius: 9px;
    background: var(--color-primary);
    color: #fff;
    font-size: 0.7rem;
    line-height: 18px;
    text-align: center;
    font-weight: 600;
  }

  &__login,
  &__register {
    font-size: 0.92rem;
    font-weight: 500;
    padding: 10px 20px;
    border-radius: var(--radius);
    transition: all 0.15s ease;
  }

  &__login {
    color: var(--color-text);

    &:hover {
      color: var(--color-primary);
    }
  }

  &__register {
    background: var(--color-primary);
    color: #fff;

    &:hover {
      background: var(--color-primary-dark);
      color: #fff;
    }
  }
}

.main {
  flex: 1;
}

.footer {
  background: var(--color-secondary);
  padding: 64px 0 24px;
  margin-top: 80px;

  &__inner {
    display: grid;
    grid-template-columns: 2fr 1fr 1fr;
    gap: 48px;
    padding-bottom: 48px;
    border-bottom: 1px solid rgba(168, 152, 116, 0.25);
  }

  &__logo {
    font-family: var(--font-display);
    font-size: 1.8rem;
    font-weight: 600;
    color: var(--color-primary);
    margin-bottom: 12px;
  }

  &__tagline {
    color: var(--color-text-muted);
    margin: 0;
    max-width: 340px;
  }

  &__col {
    display: flex;
    flex-direction: column;
    gap: 10px;

    h4 {
      font-family: var(--font-body);
      text-transform: uppercase;
      letter-spacing: 0.08em;
      font-size: 0.85rem;
      margin-bottom: 4px;
      color: var(--color-text);
    }

    a {
      color: var(--color-text-muted);
      font-size: 0.95rem;

      &:hover {
        color: var(--color-primary);
      }
    }
  }

  &__bottom {
    padding-top: 24px;
    color: var(--color-text-muted);
    font-size: 0.85rem;
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 12px;
    flex-wrap: wrap;

    &-link {
      color: var(--color-text-muted);

      &:hover {
        color: var(--color-primary);
      }
    }
  }
}

@media (max-width: 900px) {
  .footer__inner {
    grid-template-columns: 1fr 1fr;
    gap: 32px;
  }
}

@media (max-width: 768px) {
  .header {
    &__inner {
      gap: 8px;
      height: 60px;
      padding-left: max(16px, env(safe-area-inset-left));
      padding-right: max(16px, env(safe-area-inset-right));
    }

    &__burger {
      display: flex;
      width: 36px;
      height: 36px;
    }

    &__logo {
      position: absolute;
      left: 50%;
      top: 50%;
      transform: translate(-50%, -50%);
      font-size: 1.4rem;
      max-width: 50%;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
      pointer-events: auto;
    }

    &__nav {
      position: fixed;
      top: 0;
      left: 0;
      bottom: 0;
      width: min(80vw, 320px);
      background: var(--color-surface);
      flex-direction: column;
      justify-content: flex-start;
      align-items: stretch;
      padding: 88px 24px 24px;
      gap: 0;
      transform: translateX(-100%);
      transition: transform 0.25s ease;
      z-index: 55;
      box-shadow: 4px 0 16px rgba(0, 0, 0, 0.08);

      &--open {
        transform: translateX(0);
      }
    }

    &__link {
      padding: 16px 0;
      border-bottom: 1px solid var(--color-border);
      font-size: 1rem;

      &.router-link-active::after {
        display: none;
      }
      &.router-link-active {
        color: var(--color-primary);
      }
    }

    &__overlay {
      display: block;
      position: fixed;
      inset: 0;
      background: rgba(42, 33, 32, 0.4);
      z-index: 54;
      animation: fade-in 0.2s ease;
    }

    &__login,
    &__register {
      display: none;
    }

    &__login + .header__register,
    &__register {
      display: inline-block;
    }

    &__actions {
      gap: 2px;
    }

    &__icon {
      width: 36px;
      height: 36px;

      i {
        font-size: 1rem;
      }
    }

    &__login-icon {
      display: none;
    }

    &__badge {
      top: 2px;
      right: 2px;
      min-width: 16px;
      height: 16px;
      line-height: 16px;
      font-size: 0.65rem;
    }
  }
}

@media (max-width: 600px) {
  .footer__inner {
    grid-template-columns: 1fr;
  }

  .header {
    &__inner {
      height: 56px;
    }

    &__logo {
      font-size: 1.25rem;
    }

    &__icon {
      width: 34px;
      height: 34px;
    }

    &__login,
    &__register {
      padding: 6px 10px;
      font-size: 0.8rem;
    }

    &__login {
      display: none;
    }

    &__login-icon {
      display: inline-flex;
    }
  }
}

@media (max-width: 380px) {
  .header {
    &__inner {
      gap: 4px;
    }

    &__burger {
      width: 32px;
      height: 32px;
    }

    &__logo {
      font-size: 1.15rem;
    }

    &__icon {
      width: 32px;
      height: 32px;

      i {
        font-size: 0.95rem;
      }
    }
  }
}

@keyframes fade-in {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}
</style>
