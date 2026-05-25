<script setup>
import { computed, reactive, ref } from "vue";
import { reviewsApi } from "@/api";
import { useAuthStore } from "@/stores/auth";
import { useAsyncData } from "@/composables/useAsyncData";
import { useFlash } from "@/composables/useFlash";
import { formatDate } from "@/utils/format";
import StarRating from "./StarRating.vue";
import Button from "primevue/button";
import Textarea from "primevue/textarea";
import Message from "primevue/message";

const { productId } = defineProps({
  productId: { type: [Number, String], required: true },
});

const auth = useAuthStore();
const { message: flashMessage, success: flashSuccess, error: flashError } = useFlash();

const { data: reviewsData, refresh } = useAsyncData(
  () => reviewsApi.list(productId).then((r) => r.data.items),
  { initialValue: [] },
);

const { data: canLeave } = useAsyncData(
  async () => {
    if (!auth.isAuthenticated) return false;
    const { data } = await reviewsApi.canLeave(productId);
    return data.allowed;
  },
  { initialValue: false },
);

const reviews = computed(() => reviewsData.value ?? []);
const showForm = ref(false);
const submitting = ref(false);

const form = reactive({
  stars: 5,
  text: "",
});

const alreadyReviewed = computed(() =>
  reviews.value.some((r) => r.user_id && r.user_id === auth.user?.id),
);

async function submit() {
  if (!form.text.trim()) {
    flashError("Напишите текст отзыва");
    return;
  }
  submitting.value = true;
  try {
    await reviewsApi.create(productId, { stars: form.stars, text: form.text.trim() });
    flashSuccess("Спасибо за отзыв!");
    form.text = "";
    form.stars = 5;
    showForm.value = false;
    await refresh();
  } catch (err) {
    flashError(err.response?.data?.error || "Не удалось отправить отзыв");
  } finally {
    submitting.value = false;
  }
}
</script>

<template>
  <section class="reviews">
    <header class="reviews__head">
      <h3>Отзывы</h3>
      <span v-if="reviews.length" class="reviews__count">{{ reviews.length }}</span>
    </header>

    <Message v-if="flashMessage" :severity="flashMessage.severity" :closable="false">
      {{ flashMessage.text }}
    </Message>

    <div v-if="canLeave && !showForm" class="reviews__cta">
      <Button label="Написать отзыв" icon="pi pi-pencil" outlined @click="showForm = true" />
    </div>

    <form v-if="showForm" class="reviews__form" @submit.prevent="submit">
      <div class="reviews__form-stars">
        <span>Оценка:</span>
        <StarRating v-model="form.stars" size="lg" />
      </div>
      <Textarea
        v-model="form.text"
        rows="4"
        autoResize
        placeholder="Поделитесь впечатлением..."
        maxlength="2000"
      />
      <div class="reviews__form-actions">
        <Button label="Отмена" severity="secondary" text @click="showForm = false" />
        <Button type="submit" label="Опубликовать" :loading="submitting" />
      </div>
    </form>

    <p v-if="!auth.isAuthenticated" class="reviews__hint">
      Войдите в&nbsp;аккаунт, чтобы оставить отзыв.
    </p>
    <p v-else-if="!canLeave && !alreadyReviewed" class="reviews__hint">
      Оставить отзыв можно только после получения заказа с&nbsp;этим букетом.
    </p>

    <div v-if="!reviews.length" class="reviews__empty">
      Пока нет отзывов. Будьте первым!
    </div>

    <ul v-else class="reviews__list">
      <li v-for="r in reviews" :key="r.id" class="review">
        <header class="review__head">
          <strong>{{ r.author_name }}</strong>
          <StarRating :model-value="r.stars" readonly size="sm" />
          <time>{{ formatDate(r.created_at) }}</time>
        </header>
        <p>{{ r.text }}</p>
      </li>
    </ul>
  </section>
</template>

<style lang="scss" scoped>
@use "@/assets/styles/variables" as *;

.reviews {
  background: var(--color-surface);
  border-radius: var(--radius-lg);
  padding: 28px 32px;
  display: flex;
  flex-direction: column;
  gap: 16px;

  &__head {
    display: flex;
    align-items: baseline;
    gap: 8px;

    h3 {
      font-family: var(--font-display);
      font-size: 1.4rem;
      margin: 0;
    }
  }

  &__count {
    color: var(--color-text-muted);
    font-size: 0.9rem;
  }

  &__cta {
    display: flex;
    justify-content: flex-start;
  }

  &__form {
    display: flex;
    flex-direction: column;
    gap: 12px;
    padding: 16px;
    background: var(--color-surface-alt);
    border-radius: var(--radius);
  }

  &__form-stars {
    display: flex;
    align-items: center;
    gap: 12px;
    color: var(--color-text-muted);
    font-size: 0.9rem;
  }

  &__form-actions {
    display: flex;
    justify-content: flex-end;
    gap: 8px;
  }

  &__hint,
  &__empty {
    color: var(--color-text-muted);
    margin: 0;
    font-size: 0.95rem;
  }

  &__list {
    list-style: none;
    margin: 0;
    padding: 0;
    display: flex;
    flex-direction: column;
    gap: 16px;
  }
}

.review {
  padding: 16px 0;
  border-top: 1px solid var(--color-border);

  &:first-child {
    border-top: 0;
    padding-top: 0;
  }

  &__head {
    display: flex;
    align-items: center;
    gap: 12px;
    margin-bottom: 8px;

    strong {
      font-size: 0.95rem;
    }

    time {
      margin-left: auto;
      color: var(--color-text-muted);
      font-size: 0.85rem;
    }
  }

  p {
    margin: 0;
    line-height: 1.6;
    white-space: pre-line;
  }
}

@media (max-width: 600px) {
  .reviews {
    padding: 20px;
  }

  .review__head {
    flex-wrap: wrap;

    time {
      margin-left: 0;
      width: 100%;
    }
  }
}
</style>
