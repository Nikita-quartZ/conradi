<script setup>
import { ref } from "vue";
import { useRouter, useRoute, RouterLink } from "vue-router";
import { useAuthStore } from "@/stores/auth";
import InputText from "primevue/inputtext";
import Button from "primevue/button";
import Message from "primevue/message";

const auth = useAuthStore();
const router = useRouter();
const route = useRoute();

const login = ref("");
const password = ref("");
const error = ref(null);

async function submit() {
  error.value = null;
  try {
    await auth.login({ login: login.value, password: password.value });
    const redirect = route.query.redirect || "/";
    router.push(redirect);
  } catch (err) {
    error.value = err.response?.data?.error || "Не удалось войти";
  }
}
</script>

<template>
  <div class="auth-page">
    <div class="container">
      <div class="auth-card">
        <h1>Вход</h1>
        <p class="auth-card__lead">
          Войдите, чтобы добавлять букеты в&nbsp;корзину и&nbsp;следить за&nbsp;заказами
        </p>

        <form @submit.prevent="submit" class="auth-form">
          <div class="field">
            <label for="login">Логин</label>
            <InputText
              id="login"
              v-model="login"
              autocomplete="username"
              required
            />
          </div>

          <div class="field">
            <label for="password">Пароль</label>
            <InputText
              id="password"
              v-model="password"
              type="password"
              autocomplete="current-password"
              required
            />
          </div>

          <Message v-if="error" severity="error" :closable="false">
            {{ error }}
          </Message>

          <Button
            type="submit"
            label="Войти"
            :loading="auth.loading"
            size="large"
            class="auth-submit"
          />
        </form>

        <p class="auth-footer">
          Нет аккаунта?
          <RouterLink to="/register">Зарегистрироваться</RouterLink>
        </p>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
@use "@/assets/styles/variables" as *;

.auth-page {
  padding: 80px 0;
  min-height: calc(100vh - 80px);
}

.auth-card {
  max-width: 460px;
  margin: 0 auto;
  background: var(--color-surface);
  padding: 48px;
  border-radius: var(--radius-lg);
  box-shadow: $shadow;

  h1 {
    margin: 0 0 8px;
    text-align: center;
  }

  &__lead {
    text-align: center;
    color: var(--color-text-muted);
    margin: 0 0 32px;
  }
}

.auth-form {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.field {
  display: flex;
  flex-direction: column;
  gap: 8px;

  label {
    font-size: 0.85rem;
    font-weight: 500;
    letter-spacing: 0.04em;
    text-transform: uppercase;
    color: var(--color-text-muted);
  }
}

:deep(.p-inputtext) {
  width: 100%;
}

.auth-submit {
  margin-top: 8px;
}

.auth-footer {
  text-align: center;
  color: var(--color-text-muted);
  margin: 24px 0 0;

  a {
    color: var(--color-primary);
    font-weight: 500;
  }
}
</style>
