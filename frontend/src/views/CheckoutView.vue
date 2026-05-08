<script setup>
import { ref, computed, onMounted, reactive } from "vue";
import { useRouter } from "vue-router";
import { useCartStore } from "@/stores/cart";
import { ordersApi } from "@/api";
import InputText from "primevue/inputtext";
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
  card_number: "",
  card_holder: "",
  card_expiry: "",
  card_cvv: "",
});

const submitting = ref(false);
const error = ref(null);
const fieldErrors = ref({});

const today = new Date();
const maxDate = new Date(today.getTime() + 90 * 24 * 3600 * 1000);

const timeSlots = computed(() => {
  const slots = [];
  for (let h = 9; h <= 20; h++) {
    for (let m of [0, 15, 30, 45]) {
      slots.push(`${String(h).padStart(2, "0")}:${String(m).padStart(2, "0")}`);
    }
  }
  slots.push("21:00");
  return slots;
});

function fmt(n) {
  return new Intl.NumberFormat("ru-RU").format(n) + " ₽";
}

function fmtDate(d) {
  if (!d) return null;
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, "0");
  const day = String(d.getDate()).padStart(2, "0");
  return `${y}-${m}-${day}`;
}

function formatCardNumber(value) {
  return value
    .replace(/\D/g, "")
    .slice(0, 16)
    .replace(/(\d{4})/g, "$1 ")
    .trim();
}

function formatExpiry(value) {
  const digits = value.replace(/\D/g, "").slice(0, 4);
  if (digits.length >= 3) return digits.slice(0, 2) + "/" + digits.slice(2);
  return digits;
}

async function submit() {
  error.value = null;
  fieldErrors.value = {};
  submitting.value = true;
  try {
    const payload = {
      address: form.address,
      pay_method: form.pay_method,
      delivery_date: fmtDate(form.delivery_date),
      delivery_time: form.delivery_time,
    };
    if (form.pay_method === "card") {
      payload.card_number = form.card_number;
      payload.card_holder = form.card_holder;
      payload.card_expiry = form.card_expiry;
      payload.card_cvv = form.card_cvv;
    }

    const { data } = await ordersApi.checkout(payload);
    await cart.fetch();
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
  await cart.fetch();
  if (!cart.items.length) {
    router.replace("/cart");
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
                inputId="ch-date"
                v-model="form.delivery_date"
                :minDate="today"
                :maxDate="maxDate"
                dateFormat="dd.mm.yy"
                showIcon
                fluid
              />
              <small v-if="fieldErrors.delivery_date">{{ fieldErrors.delivery_date[0] }}</small>
            </div>
            <div class="field">
              <label for="ch-time">Время (с 09:00 до 21:00, шаг 15 мин)</label>
              <select id="ch-time" v-model="form.delivery_time" class="time-select">
                <option v-for="t in timeSlots" :key="t" :value="t">{{ t }}</option>
              </select>
            </div>
          </div>
        </section>

        <section class="form-section">
          <h2>Оплата</h2>
          <div class="pay-method">
            <label class="pay-option">
              <RadioButton v-model="form.pay_method" inputId="pay-cash" value="cash" />
              <span>Наличными или картой курьеру</span>
            </label>
            <label class="pay-option">
              <RadioButton v-model="form.pay_method" inputId="pay-card" value="card" />
              <span>Банковской картой онлайн</span>
            </label>
          </div>

          <div v-if="form.pay_method === 'card'" class="card-form">
            <div class="field">
              <label for="ch-card-number">Номер карты</label>
              <InputText
                id="ch-card-number"
                v-model="form.card_number"
                @input="form.card_number = formatCardNumber(form.card_number)"
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
                  v-model="form.card_expiry"
                  @input="form.card_expiry = formatExpiry(form.card_expiry)"
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
          :loading="submitting"
          @click="submit"
          class="checkout__submit"
        />
      </div>

      <aside class="checkout__summary">
        <h3>Ваш заказ</h3>
        <div v-for="item in cart.items" :key="item.id" class="summary-item">
          <div class="summary-item__title">
            {{ item.product.title }} <span>×{{ item.quantity }}</span>
          </div>
          <div class="summary-item__price">
            {{ fmt(item.product.price * item.quantity) }}
          </div>
        </div>
        <div class="summary-total">
          <span>Итого</span>
          <span>{{ fmt(cart.total) }}</span>
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
}
</style>
