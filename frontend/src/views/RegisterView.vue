<script setup>
import { ref } from "vue";
import { useRouter, RouterLink } from "vue-router";
import { useAuthStore } from "@/stores/auth";
import InputText from "primevue/inputtext";
import DatePicker from "primevue/datepicker";
import Button from "primevue/button";
import Message from "primevue/message";

const auth = useAuthStore();
const router = useRouter();

const form = ref({
  full_name: "",
  login: "",
  password: "",
  phone: "",
  birthday: null,
});
const error = ref(null);
const fieldErrors = ref({});

function fmtDate(d) {
  if (!d) return null;
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, "0");
  const day = String(d.getDate()).padStart(2, "0");
  return `${y}-${m}-${day}`;
}

async function submit() {
  error.value = null;
  fieldErrors.value = {};
  try {
    await auth.register({
      full_name: form.value.full_name,
      login: form.value.login,
      password: form.value.password,
      phone: form.value.phone,
      birthday: fmtDate(form.value.birthday),
    });
    router.push("/");
  } catch (err) {
    const payload = err.response?.data;
    if (payload?.errors) {
      fieldErrors.value = payload.errors;
    } else {
      error.value = payload?.error || "Не удалось зарегистрироваться";
    }
  }
}
</script>

<template>
  <div class="auth-page">
    <div class="container">
      <div class="auth-card">
        <h1>Регистрация</h1>
        <p class="auth-card__lead">
          Заведите аккаунт — это даст доступ к&nbsp;корзине, избранному и&nbsp;истории заказов
        </p>

        <form @submit.prevent="submit" class="auth-form">
          <div class="field">
            <label for="reg-name">Имя и фамилия</label>
            <InputText id="reg-name" v-model="form.full_name" required />
            <small v-if="fieldErrors.full_name">{{ fieldErrors.full_name[0] }}</small>
          </div>

          <div class="field">
            <label for="reg-login">Логин</label>
            <InputText id="reg-login" v-model="form.login" autocomplete="username" required />
            <small v-if="fieldErrors.login">{{ fieldErrors.login[0] }}</small>
          </div>

          <div class="field">
            <label for="reg-password">Пароль</label>
            <InputText
              id="reg-password"
              v-model="form.password"
              type="password"
              autocomplete="new-password"
              required
            />
            <small v-if="fieldErrors.password">{{ fieldErrors.password[0] }}</small>
          </div>

          <div class="field">
            <label for="reg-phone">Телефон</label>
            <InputText id="reg-phone" v-model="form.phone" placeholder="+7 999 123 45 67" required />
            <small v-if="fieldErrors.phone">{{ fieldErrors.phone[0] }}</small>
          </div>

          <div class="field">
            <label for="reg-birthday">Дата рождения</label>
            <DatePicker
              inputId="reg-birthday"
              v-model="form.birthday"
              dateFormat="dd.mm.yy"
              showIcon
              fluid
              :maxDate="new Date()"
            />
            <small v-if="fieldErrors.birthday">{{ fieldErrors.birthday[0] }}</small>
          </div>

          <Message v-if="error" severity="error" :closable="false">
            {{ error }}
          </Message>

          <Button
            type="submit"
            label="Создать аккаунт"
            :loading="auth.loading"
            size="large"
            class="auth-submit"
          />
        </form>

        <p class="auth-footer">
          Уже зарегистрированы?
          <RouterLink to="/login">Войти</RouterLink>
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
  gap: 16px;
}

.field {
  display: flex;
  flex-direction: column;
  gap: 6px;

  label {
    font-size: 0.85rem;
    font-weight: 500;
    letter-spacing: 0.04em;
    text-transform: uppercase;
    color: var(--color-text-muted);
  }

  small {
    color: var(--p-message-error-color, #b85c5c);
    font-size: 0.8rem;
  }
}

:deep(.p-inputtext),
:deep(.p-datepicker) {
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
