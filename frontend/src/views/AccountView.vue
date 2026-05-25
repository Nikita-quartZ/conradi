<script setup>
import { computed, reactive, ref } from "vue";
import { useRouter, RouterLink } from "vue-router";
import { useAuthStore } from "@/stores/auth";
import { useFlash } from "@/composables/useFlash";
import { formatDate, toIsoDate } from "@/utils/format";
import InputText from "primevue/inputtext";
import DatePicker from "primevue/datepicker";
import Button from "primevue/button";
import Message from "primevue/message";

const auth = useAuthStore();
const router = useRouter();
const { message: flashMessage, success: flashSuccess, error: flashError } = useFlash();

const editing = ref(false);
const saving = ref(false);
const fieldErrors = ref({});

const form = reactive({
  full_name: "",
  phone: "",
  birthday: null,
});

const birthdayDate = computed(() => (auth.user?.birthday ? new Date(auth.user.birthday) : null));

function startEdit() {
  form.full_name = auth.user?.full_name ?? "";
  form.phone = auth.user?.phone ?? "";
  form.birthday = birthdayDate.value;
  fieldErrors.value = {};
  editing.value = true;
}

function cancelEdit() {
  editing.value = false;
  fieldErrors.value = {};
}

async function save() {
  saving.value = true;
  fieldErrors.value = {};
  try {
    await auth.updateProfile({
      full_name: form.full_name,
      phone: form.phone,
      birthday: toIsoDate(form.birthday),
    });
    flashSuccess("Данные сохранены");
    editing.value = false;
  } catch (err) {
    const payload = err.response?.data;
    if (payload?.errors) fieldErrors.value = payload.errors;
    else flashError(payload?.error || "Не удалось сохранить");
  } finally {
    saving.value = false;
  }
}

function logout() {
  auth.logout();
  router.push("/");
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

        <Message v-if="flashMessage" :severity="flashMessage.severity" :closable="false">
          {{ flashMessage.text }}
        </Message>

        <div class="account__card">
          <header class="account__card-head">
            <h3>Контакты</h3>
            <Button
              v-if="!editing"
              label="Редактировать"
              icon="pi pi-pencil"
              text
              size="small"
              @click="startEdit"
            />
          </header>

          <template v-if="!editing">
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
              <strong>{{ formatDate(auth.user?.birthday) }}</strong>
            </div>
            <div class="account__row">
              <span>Зарегистрирован</span>
              <strong>{{ formatDate(auth.user?.created_at) }}</strong>
            </div>
            <div v-if="auth.isAdmin" class="account__row">
              <span>Роль</span>
              <strong>Администратор</strong>
            </div>
          </template>

          <form v-else class="account__form" @submit.prevent="save">
            <div class="account__field">
              <label for="acc-name">Имя и фамилия</label>
              <InputText id="acc-name" v-model="form.full_name" />
              <small v-if="fieldErrors.full_name">{{ fieldErrors.full_name[0] }}</small>
            </div>
            <div class="account__field">
              <label for="acc-phone">Телефон</label>
              <InputText id="acc-phone" v-model="form.phone" />
              <small v-if="fieldErrors.phone">{{ fieldErrors.phone[0] }}</small>
            </div>
            <div class="account__field">
              <label for="acc-birthday">Дата рождения</label>
              <DatePicker
                input-id="acc-birthday"
                v-model="form.birthday"
                date-format="dd.mm.yy"
                show-icon
                fluid
                :max-date="new Date()"
              />
              <small v-if="fieldErrors.birthday">{{ fieldErrors.birthday[0] }}</small>
            </div>
            <div class="account__actions">
              <Button type="submit" label="Сохранить" :loading="saving" />
              <Button label="Отмена" severity="secondary" text @click="cancelEdit" />
            </div>
          </form>
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
      margin: 0;
    }
  }

  &__card-head {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
  }

  &__form {
    display: flex;
    flex-direction: column;
    gap: 16px;
  }

  &__field {
    display: flex;
    flex-direction: column;
    gap: 6px;

    label {
      font-size: 0.78rem;
      font-weight: 500;
      letter-spacing: 0.06em;
      text-transform: uppercase;
      color: var(--color-text-muted);
    }

    small {
      color: var(--danger, #b85c5c);
      font-size: 0.8rem;
    }

    :deep(.p-inputtext),
    :deep(.p-datepicker) {
      width: 100%;
    }
  }

  &__actions {
    display: flex;
    gap: 12px;
    margin-top: 8px;
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
