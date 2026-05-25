<script setup>
import { computed, reactive, ref, watch, onMounted } from "vue";
import { useRouter } from "vue-router";
import { useCartStore } from "@/stores/cart";
import { ordersApi } from "@/api";
import {
  formatPrice,
  toIsoDate,
  formatCardNumber,
  formatCardExpiry,
} from "@/utils/format";
import InputText from "primevue/inputtext";
import Textarea from "primevue/textarea";
import DatePicker from "primevue/datepicker";
import Button from "primevue/button";
import Message from "primevue/message";
import RadioButton from "primevue/radiobutton";

const cart = useCartStore();
const router = useRouter();

const form = reactive({
  address: "",
  pay_method: "cash",
  delivery_date: null,
  delivery_time: "12:00",
  customer_comment: "",
  card_number: "",
  card_holder: "",
  card_expiry: "",
  card_cvv: "",
});

const submitting = ref(false);
const error = ref(null);
const fieldErrors = ref({});

const today = new Date();
today.setHours(0, 0, 0, 0);
const maxDate = new Date(today.getTime() + 90 * 24 * 3600 * 1000);

const ALL_SLOTS = (() => {
  const slots = [];
  for (let h = 9; h <= 20; h++) {
    for (const m of [0, 15, 30, 45]) {
      slots.push(`${String(h).padStart(2, "0")}:${String(m).padStart(2, "0")}`);
    }
  }
  slots.push("21:00");
  return slots;
})();

function slotsForDate(date) {
  if (!date) return ALL_SLOTS;
  const sameDay =
    date.getFullYear() === new Date().getFullYear() &&
    date.getMonth() === new Date().getMonth() &&
    date.getDate() === new Date().getDate();
  if (!sameDay) return ALL_SLOTS;
  const cutoff = new Date(Date.now() + 60 * 60 * 1000);
  return ALL_SLOTS.filter((slot) => {
    const [h, m] = slot.split(":").map(Number);
    const slotDate = new Date();
    slotDate.setHours(h, m, 0, 0);
    return slotDate >= cutoff;
  });
}

function nextValidDate() {
  const tomorrow = new Date();
  tomorrow.setDate(tomorrow.getDate() + 1);
  tomorrow.setHours(0, 0, 0, 0);
  return tomorrow;
}

const cardNumber = computed({
  get: () => form.card_number,
  set: (v) => (form.card_number = formatCardNumber(v)),
});

const cardExpiry = computed({
  get: () => form.card_expiry,
  set: (v) => (form.card_expiry = formatCardExpiry(v)),
});

const timeSlots = computed(() => slotsForDate(form.delivery_date));

watch(
  () => form.delivery_date,
  (date) => {
    if (!date) return;
    const slots = slotsForDate(date);
    if (slots.length === 0) {
      form.delivery_date = nextValidDate();
      return;
    }
    if (!slots.includes(form.delivery_time)) {
      form.delivery_time = slots[0];
    }
  },
  { immediate: false },
);

async function submit() {
  error.value = null;
  fieldErrors.value = {};
  submitting.value = true;
  try {
    const payload = {
      address: form.address,
      pay_method: form.pay_method,
      delivery_date: toIsoDate(form.delivery_date),
      delivery_time: form.delivery_time,
      customer_comment: form.customer_comment || null,
    };
    if (form.pay_method === "card") {
      payload.card_number = form.card_number;
      payload.card_holder = form.card_holder;
      payload.card_expiry = form.card_expiry;
      payload.card_cvv = form.card_cvv;
    }

    const { data } = await ordersApi.checkout(payload);
    await cart.load();
    router.push(`/order-success/${data.order.id}`);
  } catch (err) {
    const payload = err.response?.data;
    if (payload?.errors) fieldErrors.value = payload.errors;
    else error.value = payload?.error || "Не удалось оформить заказ";
  } finally {
    submitting.value = false;
  }
}

onMounted(async () => {
  await cart.load();
  if (!cart.items.length) {
    router.replace("/cart");
    return;
  }
  const todaySlots = slotsForDate(new Date());
  if (todaySlots.length === 0) {
    form.delivery_date = nextValidDate();
    form.delivery_time = ALL_SLOTS[0];
  } else {
    form.delivery_date = new Date();
    form.delivery_time = todaySlots.includes("12:00") ? "12:00" : todaySlots[0];
  }
});
</script>

<template>
  <section class="checkout">
    <div class="container checkout__layout">
      <div class="checkout__form">
        <h1>Оформление заказа</h1>

        <section class="form-section">
          <h2>Доставка</h2>
          <div class="field">
            <label for="ch-address">Адрес</label>
            <InputText
              id="ch-address"
              v-model="form.address"
              placeholder="Улица, дом, квартира"
              required
            />
            <small v-if="fieldErrors.address">{{ fieldErrors.address[0] }}</small>
          </div>

          <div class="field-row">
            <div class="field">
              <label for="ch-date">Дата</label>
              <DatePicker
                input-id="ch-date"
                v-model="form.delivery_date"
                :min-date="today"
                :max-date="maxDate"
                date-format="dd.mm.yy"
                show-icon
                fluid
              />
              <small v-if="fieldErrors.delivery_date">{{ fieldErrors.delivery_date[0] }}</small>
            </div>
            <div class="field">
              <label for="ch-time">Время (с 09:00 до 21:00, шаг 15 мин)</label>
              <select id="ch-time" v-model="form.delivery_time" class="time-select">
                <option v-for="t in timeSlots" :key="t" :value="t">{{ t }}</option>
              </select>
              <small v-if="fieldErrors.delivery_time">{{ fieldErrors.delivery_time[0] }}</small>
            </div>
          </div>

          <div class="field">
            <label for="ch-comment">Комментарий курьеру (необязательно)</label>
            <Textarea
              id="ch-comment"
              v-model="form.customer_comment"
              rows="3"
              autoResize
              maxlength="1000"
              placeholder="Код домофона, этаж, пожелания к букету..."
            />
          </div>
        </section>

        <section class="form-section">
          <h2>Оплата</h2>
          <div class="pay-method">
            <label class="pay-option">
              <RadioButton v-model="form.pay_method" input-id="pay-cash" value="cash" />
              <span>Наличными или картой курьеру</span>
            </label>
            <label class="pay-option">
              <RadioButton v-model="form.pay_method" input-id="pay-card" value="card" />
              <span>Банковской картой онлайн</span>
            </label>
          </div>

          <div v-if="form.pay_method === 'card'" class="card-form">
            <div class="field">
              <label for="ch-card-number">Номер карты</label>
              <InputText
                id="ch-card-number"
                v-model="cardNumber"
                placeholder="0000 0000 0000 0000"
                inputmode="numeric"
              />
            </div>
            <div class="field">
              <label for="ch-card-holder">Держатель</label>
              <InputText
                id="ch-card-holder"
                v-model="form.card_holder"
                placeholder="IVAN IVANOV"
              />
            </div>
            <div class="field-row">
              <div class="field">
                <label for="ch-card-expiry">Срок</label>
                <InputText
                  id="ch-card-expiry"
                  v-model="cardExpiry"
                  placeholder="MM/YY"
                  inputmode="numeric"
                />
              </div>
              <div class="field">
                <label for="ch-card-cvv">CVV</label>
                <InputText
                  id="ch-card-cvv"
                  v-model="form.card_cvv"
                  type="password"
                  maxlength="3"
                  placeholder="•••"
                  inputmode="numeric"
                />
              </div>
            </div>
            <p class="card-note">
              <i class="pi pi-info-circle" />
              Это демо-проект — данные карты никуда не отправляются и не сохраняются. Реальное списание не происходит.
            </p>
          </div>
        </section>

        <Message v-if="error" severity="error" :closable="false">{{ error }}</Message>

        <Button
          label="Подтвердить и оплатить"
          size="large"
          class="checkout__submit"
          :loading="submitting"
          @click="submit"
        />
      </div>

      <aside class="checkout__summary">
        <h3>Ваш заказ</h3>
        <div v-for="item in cart.items" :key="item.id" class="summary-item">
          <div class="summary-item__title">
            {{ item.product.title }} <span>×{{ item.quantity }}</span>
          </div>
          <div class="summary-item__price">
            {{ formatPrice(item.product.price * item.quantity) }}
          </div>
        </div>
        <div class="summary-total">
          <span>Итого</span>
          <span>{{ formatPrice(cart.total) }}</span>
        </div>
      </aside>
    </div>
  </section>
</template>

<style lang="scss" scoped>
@use "@/assets/styles/variables" as *;

.checkout {
  padding: 48px 0 80px;

  &__layout {
    display: grid;
    grid-template-columns: 1fr 360px;
    gap: 40px;
    align-items: start;
  }

  &__form {
    h1 {
      margin: 0 0 32px;
    }
  }

  &__summary {
    background: var(--color-surface);
    border-radius: var(--radius-lg);
    padding: 28px;
    position: sticky;
    top: 100px;

    h3 {
      margin: 0 0 20px;
      font-size: 1.3rem;
    }
  }

  &__submit {
    margin-top: 16px;
    width: 100%;
  }
}

.form-section {
  background: var(--color-surface);
  border-radius: var(--radius-lg);
  padding: 28px;
  margin-bottom: 20px;

  h2 {
    font-size: 1.3rem;
    margin: 0 0 20px;
  }
}

.field {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-bottom: 16px;

  label {
    font-size: 0.85rem;
    font-weight: 500;
    letter-spacing: 0.04em;
    text-transform: uppercase;
    color: var(--color-text-muted);
  }

  small {
    color: var(--danger, #b85c5c);
    font-size: 0.8rem;
  }
}

.field-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

.time-select {
  padding: 10px 12px;
  border: 1px solid var(--color-border);
  border-radius: var(--radius);
  font-family: inherit;
  font-size: 1rem;
  background: var(--color-surface);
  color: var(--color-text);
}

:deep(.p-inputtext),
:deep(.p-datepicker) {
  width: 100%;
}

.pay-method {
  display: flex;
  flex-direction: column;
  gap: 12px;
  margin-bottom: 20px;
}

.pay-option {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 14px 16px;
  border: 1px solid var(--color-border);
  border-radius: var(--radius);
  cursor: pointer;
  transition: border-color 0.15s ease;

  &:hover {
    border-color: var(--color-primary);
  }
}

.card-form {
  padding-top: 8px;
  border-top: 1px solid var(--color-border);
}

.card-note {
  margin: 16px 0 0;
  padding: 12px 16px;
  background: var(--color-secondary);
  border-radius: var(--radius);
  color: var(--color-text-muted);
  font-size: 0.85rem;
  display: flex;
  align-items: flex-start;
  gap: 8px;

  i {
    color: var(--color-primary);
    margin-top: 2px;
  }
}

.summary-item {
  display: flex;
  justify-content: space-between;
  gap: 12px;
  padding: 12px 0;
  border-bottom: 1px solid var(--color-border);
  font-size: 0.93rem;

  &__title {
    color: var(--color-text);

    span {
      color: var(--color-text-muted);
    }
  }

  &__price {
    font-weight: 500;
    white-space: nowrap;
  }
}

.summary-total {
  display: flex;
  justify-content: space-between;
  padding-top: 16px;
  font-size: 1.2rem;
  font-weight: 600;
}

@media (max-width: 900px) {
  .checkout__layout {
    grid-template-columns: 1fr;
  }

  .checkout__summary {
    position: static;
  }
}

@media (max-width: 600px) {
  .checkout {
    padding: 24px 0 56px;
  }

  .checkout__form h1 {
    font-size: 1.8rem;
    margin-bottom: 20px;
  }

  .form-section,
  .checkout__summary {
    padding: 20px;
  }

  .field-row {
    grid-template-columns: 1fr;
    gap: 12px;
  }
}
</style>
