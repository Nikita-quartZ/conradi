<script setup>
import { computed, reactive, ref } from "vue";
import { useConfirm } from "primevue/useconfirm";
import { adminApi } from "@/api";
import { useAsyncData } from "@/composables/useAsyncData";
import { useFlash } from "@/composables/useFlash";
import { formatDate, pluralizeRu } from "@/utils/format";
import StarRating from "@/components/StarRating.vue";
import DataTable from "primevue/datatable";
import Column from "primevue/column";
import Button from "primevue/button";
import Dialog from "primevue/dialog";
import InputText from "primevue/inputtext";
import Textarea from "primevue/textarea";
import Select from "primevue/select";
import Checkbox from "primevue/checkbox";
import Tag from "primevue/tag";
import Message from "primevue/message";

const confirm = useConfirm();
const { message: flashMessage, success: flashSuccess, error: flashError } = useFlash();

const { data: reviewsData, refresh } = useAsyncData(
  () => adminApi.listReviews().then((r) => r.data.items),
  { initialValue: [] },
);

const { data: productsData } = useAsyncData(
  () => adminApi.listProducts().then((r) => r.data.items),
  { initialValue: [] },
);

const reviews = computed(() => reviewsData.value ?? []);
const products = computed(() => productsData.value ?? []);
const countLabel = computed(
  () => `${reviews.value.length} ${pluralizeRu(reviews.value.length, ["отзыв", "отзыва", "отзывов"])}`,
);

const createDialog = ref(false);
const saving = ref(false);
const fieldErrors = ref({});

const form = reactive({
  product_id: null,
  author_name: "",
  stars: 5,
  text: "",
  is_promoted: true,
});

function openCreate() {
  form.product_id = products.value[0]?.id ?? null;
  form.author_name = "";
  form.stars = 5;
  form.text = "";
  form.is_promoted = true;
  fieldErrors.value = {};
  createDialog.value = true;
}

async function saveCreate() {
  saving.value = true;
  fieldErrors.value = {};
  try {
    await adminApi.createReview({
      product_id: form.product_id,
      author_name: form.author_name,
      stars: form.stars,
      text: form.text,
      is_promoted: form.is_promoted,
    });
    flashSuccess("Отзыв создан");
    createDialog.value = false;
    await refresh();
  } catch (err) {
    const payload = err.response?.data;
    if (payload?.errors) fieldErrors.value = payload.errors;
    else flashError(payload?.error || "Не удалось создать отзыв");
  } finally {
    saving.value = false;
  }
}

async function toggleHidden(review) {
  try {
    const { data } = await adminApi.updateReview(review.id, { is_hidden: !review.is_hidden });
    Object.assign(review, data.review);
  } catch {
    flashError("Не удалось обновить отзыв");
  }
}

async function togglePromoted(review) {
  try {
    const { data } = await adminApi.updateReview(review.id, { is_promoted: !review.is_promoted });
    Object.assign(review, data.review);
  } catch {
    flashError("Не удалось обновить отзыв");
  }
}

function remove(review) {
  confirm.require({
    message: `Удалить отзыв от «${review.author_name}»? Это действие необратимо.`,
    header: "Удалить отзыв",
    icon: "pi pi-trash",
    acceptLabel: "Удалить",
    rejectLabel: "Отмена",
    acceptClass: "p-button-danger",
    accept: async () => {
      try {
        await adminApi.deleteReview(review.id);
        flashSuccess("Отзыв удалён");
        await refresh();
      } catch {
        flashError("Не удалось удалить");
      }
    },
  });
}
</script>

<template>
  <div class="admin-reviews">
    <header class="section-head">
      <h2>Отзывы</h2>
      <p>{{ countLabel }}</p>
      <Button label="Добавить отзыв" icon="pi pi-plus" @click="openCreate" />
    </header>

    <Message v-if="flashMessage" :severity="flashMessage.severity" :closable="false">
      {{ flashMessage.text }}
    </Message>

    <DataTable :value="reviews" stripedRows paginator :rows="20" class="admin-table">
      <Column field="id" header="#" style="width: 60px">
        <template #body="{ data }">{{ data.id }}</template>
      </Column>
      <Column header="Товар">
        <template #body="{ data }">{{ data.product?.title }}</template>
      </Column>
      <Column header="Автор" style="width: 200px">
        <template #body="{ data }">
          {{ data.author_name }}
          <Tag v-if="!data.user_id" severity="warn" value="От магазина" style="margin-left: 6px" />
        </template>
      </Column>
      <Column header="Оценка" style="width: 140px">
        <template #body="{ data }">
          <StarRating :model-value="data.stars" readonly size="sm" />
        </template>
      </Column>
      <Column header="Текст">
        <template #body="{ data }">
          <p class="admin-reviews__text">{{ data.text }}</p>
        </template>
      </Column>
      <Column header="Статус" style="width: 160px">
        <template #body="{ data }">
          <Tag
            v-if="data.is_hidden"
            severity="danger"
            value="Скрыт"
            icon="pi pi-eye-slash"
          />
          <Tag v-else severity="success" value="Виден" icon="pi pi-eye" />
          <Tag
            v-if="data.is_promoted"
            severity="info"
            value="На главной"
            style="margin-top: 4px"
          />
        </template>
      </Column>
      <Column header="Дата" style="width: 110px">
        <template #body="{ data }">{{ formatDate(data.created_at) }}</template>
      </Column>
      <Column header="Действия" style="width: 240px">
        <template #body="{ data }">
          <div class="admin-reviews__actions">
            <Button
              :icon="data.is_hidden ? 'pi pi-eye' : 'pi pi-eye-slash'"
              :aria-label="data.is_hidden ? 'Показать' : 'Скрыть'"
              size="small"
              text
              @click="toggleHidden(data)"
            />
            <Button
              :icon="data.is_promoted ? 'pi pi-star-fill' : 'pi pi-star'"
              :aria-label="data.is_promoted ? 'Убрать с главной' : 'На главную'"
              size="small"
              text
              @click="togglePromoted(data)"
            />
            <Button
              icon="pi pi-trash"
              severity="danger"
              size="small"
              text
              aria-label="Удалить"
              @click="remove(data)"
            />
          </div>
        </template>
      </Column>
    </DataTable>

    <Dialog
      v-model:visible="createDialog"
      modal
      header="Новый отзыв"
      :style="{ width: '500px' }"
    >
      <form class="admin-reviews__form" @submit.prevent="saveCreate">
        <div class="admin-reviews__field">
          <label for="ar-product">Товар</label>
          <Select
            input-id="ar-product"
            v-model="form.product_id"
            :options="products"
            option-label="title"
            option-value="id"
            filter
            placeholder="Выберите товар"
          />
          <small v-if="fieldErrors.product_id">{{ fieldErrors.product_id[0] }}</small>
        </div>
        <div class="admin-reviews__field">
          <label for="ar-author">Имя автора</label>
          <InputText id="ar-author" v-model="form.author_name" placeholder="Анна К." />
          <small v-if="fieldErrors.author_name">{{ fieldErrors.author_name[0] }}</small>
        </div>
        <div class="admin-reviews__field">
          <label>Оценка</label>
          <StarRating v-model="form.stars" size="lg" />
        </div>
        <div class="admin-reviews__field">
          <label for="ar-text">Текст</label>
          <Textarea
            id="ar-text"
            v-model="form.text"
            rows="4"
            autoResize
            maxlength="2000"
            placeholder="Букет приехал свежим, упаковка..."
          />
          <small v-if="fieldErrors.text">{{ fieldErrors.text[0] }}</small>
        </div>
        <label class="admin-reviews__check">
          <Checkbox v-model="form.is_promoted" :binary="true" input-id="ar-promo" />
          <span>Показывать на&nbsp;главной странице</span>
        </label>
        <div class="admin-reviews__dialog-actions">
          <Button label="Отмена" severity="secondary" text @click="createDialog = false" />
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
  align-items: center;
  margin-bottom: 20px;
  gap: 16px;

  h2 {
    margin: 0;
  }
  p {
    color: var(--color-text-muted);
    margin: 0;
    margin-right: auto;
    margin-left: 8px;
  }
}

.admin-reviews {
  &__text {
    margin: 0;
    font-size: 0.9rem;
    line-height: 1.4;
    color: var(--color-text);
    max-width: 320px;
    display: -webkit-box;
    -webkit-line-clamp: 3;
    -webkit-box-orient: vertical;
    overflow: hidden;
  }

  &__actions {
    display: flex;
    gap: 4px;
  }

  &__form {
    display: flex;
    flex-direction: column;
    gap: 14px;
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
    :deep(.p-select),
    :deep(.p-textarea) {
      width: 100%;
    }
  }

  &__check {
    display: flex;
    align-items: center;
    gap: 10px;
    cursor: pointer;
    font-size: 0.92rem;
  }

  &__dialog-actions {
    display: flex;
    justify-content: flex-end;
    gap: 8px;
    margin-top: 8px;
  }
}
</style>
