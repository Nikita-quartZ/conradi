<script setup>
import { ref, onMounted } from "vue";
import { adminApi } from "@/api";
import Button from "primevue/button";
import InputText from "primevue/inputtext";
import InputNumber from "primevue/inputnumber";
import Textarea from "primevue/textarea";
import Select from "primevue/select";
import Dialog from "primevue/dialog";
import DataTable from "primevue/datatable";
import Column from "primevue/column";

const items = ref([]);
const categories = ref([]);
const types = ref([]);
const loading = ref(true);

const dialogOpen = ref(false);
const editing = ref(null);
const form = ref({
  title: "",
  description: "",
  price: 0,
  stock: 0,
  category_id: null,
  product_type_id: null,
});
const error = ref(null);
const fileInput = ref(null);

async function load() {
  loading.value = true;
  try {
    const [p, c, t] = await Promise.all([
      adminApi.listProducts(),
      adminApi.listCategories(),
      adminApi.listTypes(),
    ]);
    items.value = p.data.items;
    categories.value = c.data.items;
    types.value = t.data.items;
  } finally {
    loading.value = false;
  }
}

function openAdd() {
  editing.value = null;
  form.value = {
    title: "",
    description: "",
    price: 0,
    stock: 0,
    category_id: categories.value[0]?.id || null,
    product_type_id: types.value[0]?.id || null,
  };
  error.value = null;
  dialogOpen.value = true;
}

function openEdit(p) {
  editing.value = p;
  form.value = {
    title: p.title,
    description: p.description,
    price: parseFloat(p.price),
    stock: p.stock,
    category_id: p.category.id,
    product_type_id: p.product_type.id,
  };
  error.value = null;
  dialogOpen.value = true;
}

async function save() {
  error.value = null;
  try {
    if (editing.value) await adminApi.updateProduct(editing.value.id, form.value);
    else await adminApi.createProduct(form.value);
    dialogOpen.value = false;
    await load();
  } catch (err) {
    error.value =
      err.response?.data?.error ||
      Object.values(err.response?.data?.errors || {})[0]?.[0] ||
      "Ошибка";
  }
}

async function remove(p) {
  if (!confirm(`Удалить товар "${p.title}"?`)) return;
  try {
    await adminApi.deleteProduct(p.id);
    await load();
  } catch (err) {
    alert(err.response?.data?.error || "Не удалось удалить");
  }
}

async function onFileSelected(event, productId) {
  const file = event.target.files?.[0];
  if (!file) return;
  try {
    await adminApi.uploadImage(productId, file);
    await load();
  } catch (err) {
    alert(err.response?.data?.error || "Не удалось загрузить");
  }
  event.target.value = "";
}

async function deleteImage(imageId) {
  if (!confirm("Удалить картинку?")) return;
  await adminApi.deleteImage(imageId);
  await load();
}

const fmt = (n) => new Intl.NumberFormat("ru-RU").format(n) + " ₽";

onMounted(load);
</script>

<template>
  <div>
    <header class="section-head">
      <h2>Товары</h2>
      <Button label="Добавить" icon="pi pi-plus" @click="openAdd" />
    </header>

    <DataTable
      :value="items"
      :loading="loading"
      stripedRows
      paginator
      :rows="15"
      class="admin-table"
    >
      <Column header="Фото" style="width: 70px">
        <template #body="{ data }">
          <img
            v-if="data.images?.[0]"
            :src="data.images[0].url"
            style="width: 48px; height: 48px; object-fit: cover; border-radius: 6px"
          />
          <div v-else class="no-img"><i class="pi pi-image" /></div>
        </template>
      </Column>
      <Column field="title" header="Название" />
      <Column header="Категория">
        <template #body="{ data }">{{ data.category.title }}</template>
      </Column>
      <Column header="Тип" style="width: 100px">
        <template #body="{ data }">{{ data.product_type.title }}</template>
      </Column>
      <Column field="price" header="Цена" style="width: 110px">
        <template #body="{ data }">{{ fmt(data.price) }}</template>
      </Column>
      <Column field="stock" header="Остаток" style="width: 100px">
        <template #body="{ data }">
          <span :class="{ 'out-stock': data.stock === 0 }">
            {{ data.stock === 0 ? "Нет" : data.stock }}
          </span>
        </template>
      </Column>
      <Column style="width: 200px">
        <template #body="{ data }">
          <label class="upload-btn" :title="'Загрузить картинку'">
            <i class="pi pi-upload" />
            <input
              type="file"
              accept="image/png,image/jpeg,image/webp"
              @change="onFileSelected($event, data.id)"
              hidden
            />
          </label>
          <Button icon="pi pi-pencil" text severity="secondary" @click="openEdit(data)" />
          <Button icon="pi pi-trash" text severity="danger" @click="remove(data)" />
        </template>
      </Column>
    </DataTable>

    <Dialog
      v-model:visible="dialogOpen"
      :header="editing ? `Редактировать: ${editing.title}` : 'Новый товар'"
      modal
      style="width: 640px"
    >
      <div class="field">
        <label for="adm-prod-title">Название</label>
        <InputText id="adm-prod-title" v-model="form.title" />
      </div>
      <div class="field-row">
        <div class="field">
          <label for="adm-prod-category">Категория</label>
          <Select
            inputId="adm-prod-category"
            v-model="form.category_id"
            :options="categories"
            optionLabel="title"
            optionValue="id"
          />
        </div>
        <div class="field">
          <label for="adm-prod-type">Тип</label>
          <Select
            inputId="adm-prod-type"
            v-model="form.product_type_id"
            :options="types"
            optionLabel="title"
            optionValue="id"
          />
        </div>
      </div>
      <div class="field-row">
        <div class="field">
          <label for="adm-prod-price">Цена, ₽</label>
          <InputNumber inputId="adm-prod-price" v-model="form.price" :min="0" />
        </div>
        <div class="field">
          <label for="adm-prod-stock">Остаток, шт.</label>
          <InputNumber inputId="adm-prod-stock" v-model="form.stock" :min="0" />
        </div>
      </div>
      <div class="field">
        <label for="adm-prod-desc">Описание</label>
        <Textarea id="adm-prod-desc" v-model="form.description" rows="6" />
      </div>

      <div v-if="editing && editing.images?.length" class="images-block">
        <label>Картинки</label>
        <div class="images-grid">
          <div v-for="img in editing.images" :key="img.id" class="img-card">
            <img :src="img.url" />
            <button @click="deleteImage(img.id)" type="button" aria-label="Удалить">
              <i class="pi pi-times" />
            </button>
          </div>
        </div>
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

  :deep(.p-inputtext),
  :deep(.p-inputnumber),
  :deep(.p-select),
  :deep(.p-textarea) {
    width: 100%;
  }
}

.field-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

.upload-btn {
  display: inline-flex;
  width: 36px;
  height: 36px;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  cursor: pointer;
  color: var(--color-text);
  transition: all 0.15s ease;

  &:hover {
    background: var(--color-secondary);
    color: var(--color-primary);
  }
}

.no-img {
  width: 48px;
  height: 48px;
  background: var(--color-secondary);
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 6px;
  color: var(--color-primary-light);
}

.out-stock {
  color: var(--danger, #b85c5c);
  font-weight: 500;
}

.error {
  color: var(--danger, #b85c5c);
  margin: 12px 0 0;
}

.images-block {
  margin-top: 16px;

  label {
    display: block;
    font-size: 0.85rem;
    text-transform: uppercase;
    letter-spacing: 0.04em;
    color: var(--color-text-muted);
    margin-bottom: 8px;
  }
}

.images-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 8px;
}

.img-card {
  position: relative;
  aspect-ratio: 1 / 1;
  border-radius: 6px;
  overflow: hidden;
  background: var(--color-secondary);

  img {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }

  button {
    position: absolute;
    top: 4px;
    right: 4px;
    width: 24px;
    height: 24px;
    border-radius: 50%;
    border: 0;
    background: rgba(0, 0, 0, 0.6);
    color: #fff;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
  }
}
</style>
