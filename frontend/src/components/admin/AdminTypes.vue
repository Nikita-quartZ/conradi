<script setup>
import { ref, onMounted } from "vue";
import { adminApi } from "@/api";
import Button from "primevue/button";
import InputText from "primevue/inputtext";
import Dialog from "primevue/dialog";
import DataTable from "primevue/datatable";
import Column from "primevue/column";

const items = ref([]);
const loading = ref(true);
const dialogOpen = ref(false);
const editing = ref(null);
const form = ref({ title: "" });
const error = ref(null);

async function load() {
  loading.value = true;
  try {
    const { data } = await adminApi.listTypes();
    items.value = data.items;
  } finally {
    loading.value = false;
  }
}

function openAdd() {
  editing.value = null;
  form.value = { title: "" };
  error.value = null;
  dialogOpen.value = true;
}

function openEdit(item) {
  editing.value = item;
  form.value = { title: item.title };
  error.value = null;
  dialogOpen.value = true;
}

async function save() {
  error.value = null;
  try {
    if (editing.value) await adminApi.updateType(editing.value.id, form.value);
    else await adminApi.createType(form.value);
    dialogOpen.value = false;
    await load();
  } catch (err) {
    error.value = err.response?.data?.error || "Ошибка";
  }
}

async function remove(item) {
  if (!confirm(`Удалить тип "${item.title}"?`)) return;
  try {
    await adminApi.deleteType(item.id);
    await load();
  } catch (err) {
    alert(err.response?.data?.error || "Не удалось удалить");
  }
}

onMounted(load);
</script>

<template>
  <div>
    <header class="section-head">
      <h2>Типы товаров</h2>
      <Button label="Добавить" icon="pi pi-plus" @click="openAdd" />
    </header>

    <DataTable :value="items" :loading="loading" stripedRows>
      <Column field="id" header="ID" style="width: 80px" />
      <Column field="title" header="Название" />
      <Column style="width: 160px">
        <template #body="{ data }">
          <Button icon="pi pi-pencil" text severity="secondary" @click="openEdit(data)" />
          <Button icon="pi pi-trash" text severity="danger" @click="remove(data)" />
        </template>
      </Column>
    </DataTable>

    <Dialog
      v-model:visible="dialogOpen"
      :header="editing ? 'Редактировать' : 'Новый тип'"
      modal
      style="width: 480px"
    >
      <div class="field">
        <label for="adm-type-title">Название</label>
        <InputText id="adm-type-title" v-model="form.title" />
      </div>
      <p v-if="error" class="error">{{ error }}</p>
      <template #footer>
        <Button label="Отмена" text @click="dialogOpen = false" />
        <Button label="Сохранить" @click="save" />
      </template>
    </Dialog>
  </div>
</template>

<style lang="scss" scoped>
.section-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;

  h2 {
    margin: 0;
  }
}

.field {
  margin-bottom: 16px;

  label {
    display: block;
    font-size: 0.85rem;
    text-transform: uppercase;
    letter-spacing: 0.04em;
    color: var(--color-text-muted);
    margin-bottom: 8px;
  }

  :deep(.p-inputtext) {
    width: 100%;
  }
}

.error {
  color: var(--danger, #b85c5c);
  margin: 0;
}
</style>
