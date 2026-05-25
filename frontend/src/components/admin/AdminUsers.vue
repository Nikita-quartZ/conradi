<script setup>
import { computed, reactive, ref } from "vue";
import { useConfirm } from "primevue/useconfirm";
import { adminApi } from "@/api";
import { useAuthStore } from "@/stores/auth";
import { useAsyncData } from "@/composables/useAsyncData";
import { useFlash } from "@/composables/useFlash";
import { formatDate, toIsoDate, pluralizeRu } from "@/utils/format";
import DataTable from "primevue/datatable";
import Column from "primevue/column";
import Button from "primevue/button";
import Tag from "primevue/tag";
import Dialog from "primevue/dialog";
import InputText from "primevue/inputtext";
import DatePicker from "primevue/datepicker";
import Message from "primevue/message";

const confirm = useConfirm();
const auth = useAuthStore();
const { message: flashMessage, success: flashSuccess, error: flashError } = useFlash();

const { data: usersData, refresh } = useAsyncData(
  () => adminApi.listUsers().then((r) => r.data.items),
  { initialValue: [] },
);

const users = computed(() => usersData.value ?? []);
const countLabel = computed(
  () => `${users.value.length} ${pluralizeRu(users.value.length, ["пользователь", "пользователя", "пользователей"])}`,
);

const editDialog = ref(false);
const editing = ref(null);
const fieldErrors = ref({});
const saving = ref(false);

const form = reactive({
  full_name: "",
  phone: "",
  birthday: null,
});

function openEdit(user) {
  editing.value = user;
  form.full_name = user.full_name;
  form.phone = user.phone;
  form.birthday = user.birthday ? new Date(user.birthday) : null;
  fieldErrors.value = {};
  editDialog.value = true;
}

async function saveEdit() {
  if (!editing.value) return;
  saving.value = true;
  fieldErrors.value = {};
  try {
    const { data } = await adminApi.updateUser(editing.value.id, {
      full_name: form.full_name,
      phone: form.phone,
      birthday: toIsoDate(form.birthday),
    });
    Object.assign(editing.value, data.user);
    flashSuccess("Данные пользователя сохранены");
    editDialog.value = false;
  } catch (err) {
    const payload = err.response?.data;
    if (payload?.errors) fieldErrors.value = payload.errors;
    else flashError(payload?.error || "Не удалось сохранить");
  } finally {
    saving.value = false;
  }
}

function toggleAdmin(user) {
  if (user.is_super_admin) return;
  const becomesAdmin = user.role !== "admin";
  const nextRole = becomesAdmin ? "admin" : "user";
  const action = becomesAdmin ? "назначить администратором" : "лишить прав администратора";

  confirm.require({
    message: `Вы точно хотите ${action} пользователя «${user.full_name}»?`,
    header: "Подтверждение",
    icon: "pi pi-shield",
    acceptLabel: becomesAdmin ? "Да, назначить" : "Да, снять",
    rejectLabel: "Отмена",
    accept: async () => {
      try {
        const { data } = await adminApi.changeUserRole(user.id, nextRole);
        Object.assign(user, data.user);
        flashSuccess(becomesAdmin ? "Пользователь стал админом" : "Права админа сняты");
      } catch (err) {
        flashError(err.response?.data?.error || "Не удалось изменить роль");
      }
    },
  });
}
</script>

<template>
  <div class="admin-users">
    <header class="section-head">
      <h2>Пользователи</h2>
      <p>{{ countLabel }}</p>
    </header>

    <Message v-if="flashMessage" :severity="flashMessage.severity" :closable="false">
      {{ flashMessage.text }}
    </Message>

    <DataTable :value="users" stripedRows paginator :rows="20" class="admin-table">
      <Column field="id" header="#" style="width: 60px">
        <template #body="{ data }">{{ data.id }}</template>
      </Column>
      <Column header="Имя">
        <template #body="{ data }">
          <div>{{ data.full_name }}</div>
          <small style="color: var(--color-text-muted)">{{ data.login }}</small>
        </template>
      </Column>
      <Column field="phone" header="Телефон" style="width: 180px" />
      <Column header="День рождения" style="width: 160px">
        <template #body="{ data }">{{ formatDate(data.birthday) }}</template>
      </Column>
      <Column header="Роль" style="width: 200px">
        <template #body="{ data }">
          <Tag
            v-if="data.is_super_admin"
            severity="warn"
            value="Главный админ"
            icon="pi pi-crown"
          />
          <Tag
            v-else-if="data.role === 'admin'"
            severity="info"
            value="Админ"
            icon="pi pi-shield"
          />
          <Tag v-else severity="secondary" value="Пользователь" />
        </template>
      </Column>
      <Column header="Действия" style="width: 280px">
        <template #body="{ data }">
          <div class="admin-users__actions">
            <Button
              icon="pi pi-pencil"
              text
              size="small"
              aria-label="Редактировать"
              @click="openEdit(data)"
            />
            <Button
              v-if="!data.is_super_admin"
              :icon="data.role === 'admin' ? 'pi pi-user-minus' : 'pi pi-user-plus'"
              :label="data.role === 'admin' ? 'Снять админа' : 'Сделать админом'"
              size="small"
              :severity="data.role === 'admin' ? 'danger' : 'info'"
              outlined
              @click="toggleAdmin(data)"
            />
            <span v-else class="admin-users__super-note">
              <i class="pi pi-lock" /> Защищён
            </span>
          </div>
        </template>
      </Column>
    </DataTable>

    <Dialog
      v-model:visible="editDialog"
      modal
      header="Редактирование пользователя"
      :style="{ width: '420px' }"
    >
      <form class="admin-users__form" @submit.prevent="saveEdit">
        <div class="admin-users__field">
          <label for="au-name">Имя и фамилия</label>
          <InputText id="au-name" v-model="form.full_name" />
          <small v-if="fieldErrors.full_name">{{ fieldErrors.full_name[0] }}</small>
        </div>
        <div class="admin-users__field">
          <label for="au-phone">Телефон</label>
          <InputText id="au-phone" v-model="form.phone" />
          <small v-if="fieldErrors.phone">{{ fieldErrors.phone[0] }}</small>
        </div>
        <div class="admin-users__field">
          <label for="au-birthday">Дата рождения</label>
          <DatePicker
            input-id="au-birthday"
            v-model="form.birthday"
            date-format="dd.mm.yy"
            show-icon
            fluid
            :max-date="new Date()"
          />
          <small v-if="fieldErrors.birthday">{{ fieldErrors.birthday[0] }}</small>
        </div>
        <div class="admin-users__dialog-actions">
          <Button label="Отмена" severity="secondary" text @click="editDialog = false" />
          <Button type="submit" label="Сохранить" :loading="saving" />
        </div>
      </form>
    </Dialog>
  </div>
</template>

<style lang="scss" scoped>
.section-head {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  margin-bottom: 20px;

  h2 {
    margin: 0;
  }
  p {
    color: var(--color-text-muted);
    margin: 0;
  }
}

.admin-users {
  &__actions {
    display: flex;
    align-items: center;
    gap: 8px;
  }

  &__super-note {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    color: var(--color-text-muted);
    font-size: 0.85rem;

    i {
      color: var(--color-primary);
    }
  }

  &__form {
    display: flex;
    flex-direction: column;
    gap: 16px;
    padding-top: 8px;
  }

  &__field {
    display: flex;
    flex-direction: column;
    gap: 6px;

    label {
      font-size: 0.78rem;
      text-transform: uppercase;
      letter-spacing: 0.06em;
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

  &__dialog-actions {
    display: flex;
    justify-content: flex-end;
    gap: 8px;
    margin-top: 8px;
  }
}
</style>
