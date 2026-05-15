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
const form = ref({ title: "", slug: "" });
const error = ref(null);

async function load() {
  loading.value = true;
  try {
    const { data } = await adminApi.listCategories();
    items.value = data.items;
  } finally {
    loading.value = false;
  }
}

function openAdd() {
  editing.value = null;
  form.value = { title: "", slug: "" };
  error.value = null;
  dialogOpen.value = true;
}

function openEdit(cat) {
  editing.value = cat;
  form.value = { title: cat.title, slug: cat.slug };
  error.value = null;
  dialogOpen.value = true;
}

async function save() {
  error.value = null;
  try {
    if (editing.value) {
      await adminApi.updateCategory(editing.value.id, form.value);
    } else {
      await adminApi.createCategory(form.value);
    }
    dialogOpen.value = false;
    await load();
  } catch (err) {
    error.value =
      err.response?.data?.error ||
      Object.values(err.response?.data?.errors || {})[0]?.[0] ||
      "Ошибка";
  }
}

async function remove(cat) {
  if (!confirm(`Удалить категорию "${cat.title}"?`)) return;
  try {
    await adminApi.deleteCategory(cat.id);
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
      <h2>Категории</h2>
      <Button label="Добавить" icon="pi pi-plus" @click="openAdd" />
    </header>

    <DataTable :value="items" :loading="loading" stripedRows>
      <Column field="id" header="ID" style="width: 80px" />
      <Column field="title" header="Название" />
      <Column field="slug" header="Slug" />
      <Column style="width: 160px">
        <template #body="{ data }">
          <Button icon="pi pi-pencil" text severity="secondary" @click="openEdit(data)" />
          <Button icon="pi pi-trash" text severity="danger" @click="remove(data)" />
        </template>
      </Column>
    </DataTable>

    <Dialog
      v-model:visible="dialogOpen"
      :header="editing ? 'Редактировать' : 'Новая категория'"
      modal
      style="width: 480px"
    >
      <div class="field">
        <label for="adm-cat-title">Название</label>
        <InputText id="adm-cat-title" v-model="form.title" />
      </div>
      <div class="field">
        <label for="adm-cat-slug">Slug (латиница)</label>
        <InputText id="adm-cat-slug" v-model="form.slug" />
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
