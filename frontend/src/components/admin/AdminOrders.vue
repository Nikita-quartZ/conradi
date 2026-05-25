<script setup>
import { computed, ref, watch } from "vue";
import { useConfirm } from "primevue/useconfirm";
import { adminApi } from "@/api";
import { useAsyncData } from "@/composables/useAsyncData";
import { formatPrice, pluralizeRu } from "@/utils/format";
import Select from "primevue/select";
import DataTable from "primevue/datatable";
import Column from "primevue/column";

const confirm = useConfirm();

const sort = ref("created");
const order = ref("desc");

const SORT_OPTIONS = [
  { value: "created", label: "По дате" },
  { value: "status", label: "По статусу" },
  { value: "delivery", label: "По дате доставки" },
  { value: "total", label: "По сумме" },
];

const params = computed(() => ({ sort: sort.value, order: order.value }));

const { data: ordersData, refresh } = useAsyncData(
  () => adminApi.listOrders(params.value).then((r) => r.data.items),
  { initialValue: [], watch: [params] },
);

const { data: statusesData } = useAsyncData(
  () => adminApi.statuses().then((r) => r.data.items),
  { initialValue: [] },
);

const orders = computed(() => ordersData.value ?? []);
const statuses = computed(() => statusesData.value ?? []);

const STATUS_LABEL = computed(() => {
  const map = {};
  for (const s of statuses.value) map[s.value] = s.label;
  return map;
});

const countLabel = computed(
  () => `${orders.value.length} ${pluralizeRu(orders.value.length, ["заказ", "заказа", "заказов"])}`,
);

function toggleOrder() {
  order.value = order.value === "asc" ? "desc" : "asc";
}

function requestStatusChange(orderRow, newStatus) {
  if (!newStatus || newStatus === orderRow.status) return;
  const oldLabel = STATUS_LABEL.value[orderRow.status] ?? orderRow.status;
  const newLabel = STATUS_LABEL.value[newStatus] ?? newStatus;

  confirm.require({
    message: `Изменить статус заказа #${orderRow.id} с «${oldLabel}» на «${newLabel}»?`,
    header: "Подтверждение",
    icon: "pi pi-exclamation-triangle",
    acceptLabel: "Да, изменить",
    rejectLabel: "Отмена",
    accept: async () => {
      const { data } = await adminApi.changeStatus(orderRow.id, newStatus);
      orderRow.status = data.order.status;
      orderRow.status_label = data.order.status_label;
    },
    reject: () => {
      const refresh = orderRow.status;
      orderRow.status = "";
      orderRow.status = refresh;
    },
  });
}
</script>

<template>
  <div class="admin-orders">
    <header class="section-head">
      <h2>Все заказы</h2>
      <p>{{ countLabel }}</p>
    </header>

    <div class="admin-orders__toolbar">
      <Select
        v-model="sort"
        :options="SORT_OPTIONS"
        option-label="label"
        option-value="value"
        placeholder="Сортировка"
      />
      <button class="sort-dir" type="button" @click="toggleOrder">
        <i :class="order === 'asc' ? 'pi pi-sort-amount-up' : 'pi pi-sort-amount-down'" />
        {{ order === "asc" ? "По возрастанию" : "По убыванию" }}
      </button>
    </div>

    <DataTable :value="orders" stripedRows paginator :rows="20" class="admin-table">
      <Column field="id" header="#" style="width: 70px">
        <template #body="{ data }">#{{ data.id }}</template>
      </Column>
      <Column header="Клиент">
        <template #body="{ data }">
          <div>{{ data.user.full_name }}</div>
          <small style="color: var(--color-text-muted)">{{ data.user.phone }}</small>
        </template>
      </Column>
      <Column header="Состав">
        <template #body="{ data }">
          <div v-for="it in data.items" :key="it.id" style="font-size: 0.9rem">
            {{ it.title_snapshot }} ×{{ it.quantity }}
          </div>
          <div v-if="data.customer_comment" class="admin-orders__comment">
            <i class="pi pi-comment" />
            {{ data.customer_comment }}
          </div>
        </template>
      </Column>
      <Column field="total" header="Сумма" style="width: 120px">
        <template #body="{ data }">{{ formatPrice(data.total) }}</template>
      </Column>
      <Column header="Доставка" style="width: 180px">
        <template #body="{ data }">
          {{ data.delivery_date }}<br />
          <small>{{ data.delivery_time }} · {{ data.pay_method === 'card' ? 'Картой' : 'Курьеру' }}</small>
        </template>
      </Column>
      <Column header="Статус" style="width: 220px">
        <template #body="{ data }">
          <Select
            :model-value="data.status"
            :options="statuses"
            option-label="label"
            option-value="value"
            class="status-select"
            @change="requestStatusChange(data, $event.value)"
          />
        </template>
      </Column>
    </DataTable>
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

.admin-orders {
  &__toolbar {
    display: flex;
    align-items: center;
    gap: 12px;
    margin-bottom: 16px;
  }

  &__comment {
    margin-top: 8px;
    padding: 8px 12px;
    background: var(--color-secondary);
    border-radius: var(--radius);
    font-size: 0.85rem;
    color: var(--color-text-muted);
    line-height: 1.4;
    display: flex;
    gap: 8px;
    align-items: flex-start;

    i {
      color: var(--color-primary);
      margin-top: 2px;
    }
  }
}

.sort-dir {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 9px 16px;
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius);
  cursor: pointer;
  font-family: inherit;
  font-size: 0.95rem;
  color: var(--color-text);
  transition: border-color 0.15s ease;

  i {
    color: var(--color-primary);
  }

  &:hover {
    border-color: var(--color-primary);
  }
}

.status-select {
  width: 200px;
}
</style>
