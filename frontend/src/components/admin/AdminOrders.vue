<script setup>
import { ref, onMounted } from "vue";
import { adminApi } from "@/api";
import Select from "primevue/select";
import DataTable from "primevue/datatable";
import Column from "primevue/column";
import Tag from "primevue/tag";

const orders = ref([]);
const statuses = ref([]);
const loading = ref(true);

const STATUS_SEVERITY = {
  created: "warn",
  assembling: "info",
  issued: "info",
  delivered: "success",
  canceled: "danger",
};

async function load() {
  loading.value = true;
  try {
    const [o, s] = await Promise.all([
      adminApi.listOrders(),
      adminApi.statuses(),
    ]);
    orders.value = o.data.items;
    statuses.value = s.data.items;
  } finally {
    loading.value = false;
  }
}

async function changeStatus(order, newStatus) {
  if (!newStatus || newStatus === order.status) return;
  const { data } = await adminApi.changeStatus(order.id, newStatus);
  order.status = data.order.status;
  order.status_label = data.order.status_label;
}

const fmt = (n) => new Intl.NumberFormat("ru-RU").format(n) + " ₽";

onMounted(load);
</script>

<template>
  <div class="admin-orders">
    <header class="section-head">
      <h2>Все заказы</h2>
      <p>{{ orders.length }} {{ orders.length === 1 ? "заказ" : "заказов" }}</p>
    </header>

    <DataTable
      :value="orders"
      :loading="loading"
      stripedRows
      paginator
      :rows="20"
      class="admin-table"
    >
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
        </template>
      </Column>
      <Column field="total" header="Сумма" style="width: 120px">
        <template #body="{ data }">{{ fmt(data.total) }}</template>
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
            :modelValue="data.status"
            :options="statuses"
            optionLabel="label"
            optionValue="value"
            @change="changeStatus(data, $event.value)"
            class="status-select"
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

.status-select {
  width: 200px;
}
</style>
