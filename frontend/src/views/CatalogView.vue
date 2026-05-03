<script setup>
import { ref, onMounted, watch, computed } from "vue";
import { useRoute, useRouter } from "vue-router";
import { catalogApi } from "@/api";
import ProductCard from "@/components/ProductCard.vue";
import Select from "primevue/select";
import InputText from "primevue/inputtext";
import InputNumber from "primevue/inputnumber";
import Button from "primevue/button";
import Paginator from "primevue/paginator";

const route = useRoute();
const router = useRouter();

const categories = ref([]);
const types = ref([]);
const products = ref([]);
const total = ref(0);
const loading = ref(false);

const filters = ref({
  category_id: route.query.category ? Number(route.query.category) : null,
  product_type_id: route.query.type ? Number(route.query.type) : null,
  q: route.query.q || "",
  min_price: null,
  max_price: null,
  in_stock: false,
  sort: "newest",
});

const page = ref(Number(route.query.page) || 1);
const perPage = ref(12);

const sortOptions = [
  { value: "newest", label: "Сначала новые" },
  { value: "price_asc", label: "Сначала дешевле" },
  { value: "price_desc", label: "Сначала дороже" },
];

async function loadMeta() {
  const [c, t] = await Promise.all([
    catalogApi.categories(),
    catalogApi.productTypes(),
  ]);
  categories.value = c.data.items;
  types.value = t.data.items;
}

async function loadProducts() {
  loading.value = true;
  try {
    const params = { page: page.value, per_page: perPage.value, sort: filters.value.sort };
    if (filters.value.category_id) params.category_id = filters.value.category_id;
    if (filters.value.product_type_id) params.product_type_id = filters.value.product_type_id;
    if (filters.value.q) params.q = filters.value.q;
    if (filters.value.min_price != null) params.min_price = filters.value.min_price;
    if (filters.value.max_price != null) params.max_price = filters.value.max_price;
    if (filters.value.in_stock) params.in_stock = "true";

    const { data } = await catalogApi.products(params);
    products.value = data.items;
    total.value = data.total;
  } finally {
    loading.value = false;
  }
}

function applyFilters() {
  page.value = 1;
  loadProducts();
}

function resetFilters() {
  filters.value = {
    category_id: null,
    product_type_id: null,
    q: "",
    min_price: null,
    max_price: null,
    in_stock: false,
    sort: "newest",
  };
  page.value = 1;
  loadProducts();
}

function onPage(event) {
  page.value = event.page + 1;
  loadProducts();
  window.scrollTo({ top: 0, behavior: "smooth" });
}

const activeCategoryTitle = computed(() => {
  const c = categories.value.find((x) => x.id === filters.value.category_id);
  return c?.title || "";
});

onMounted(async () => {
  await loadMeta();
  await loadProducts();
});

watch(
  () => route.query.category,
  (v) => {
    filters.value.category_id = v ? Number(v) : null;
    page.value = 1;
    loadProducts();
  },
);
</script>

<template>
  <section class="catalog">
    <div class="container">
      <header class="catalog__head">
        <h1>{{ activeCategoryTitle || "Каталог" }}</h1>
        <p>Всего {{ total }} {{ total === 1 ? "товар" : "товаров" }}</p>
      </header>

      <div class="catalog__layout">
        <aside class="catalog__sidebar">
          <div class="filter-block">
            <h3>Категория</h3>
            <ul class="filter-list">
              <li>
                <button
                  :class="{ active: filters.category_id == null }"
                  @click="filters.category_id = null; applyFilters()"
                >
                  Все
                </button>
              </li>
              <li v-for="c in categories" :key="c.id">
                <button
                  :class="{ active: filters.category_id === c.id }"
                  @click="filters.category_id = c.id; applyFilters()"
                >
                  {{ c.title }}
                </button>
              </li>
            </ul>
          </div>

          <div class="filter-block">
            <h3>Тип</h3>
            <ul class="filter-list">
              <li>
                <button
                  :class="{ active: filters.product_type_id == null }"
                  @click="filters.product_type_id = null; applyFilters()"
                >
                  Все
                </button>
              </li>
              <li v-for="t in types" :key="t.id">
                <button
                  :class="{ active: filters.product_type_id === t.id }"
                  @click="filters.product_type_id = t.id; applyFilters()"
                >
                  {{ t.title }}
                </button>
              </li>
            </ul>
          </div>

          <div class="filter-block">
            <h3>Цена, ₽</h3>
            <div class="filter-price">
              <InputNumber v-model="filters.min_price" placeholder="От" :min="0" />
              <InputNumber v-model="filters.max_price" placeholder="До" :min="0" />
            </div>
            <Button label="Применить" size="small" outlined @click="applyFilters" />
          </div>

          <Button label="Сбросить" text @click="resetFilters" />
        </aside>

        <div class="catalog__main">
          <div class="catalog__toolbar">
            <InputText
              v-model="filters.q"
              placeholder="Поиск по названию..."
              @keyup.enter="applyFilters"
            />
            <Select
              v-model="filters.sort"
              :options="sortOptions"
              optionLabel="label"
              optionValue="value"
              @change="applyFilters"
            />
          </div>

          <div v-if="loading" class="catalog__loading">Загружаем...</div>
          <div v-else-if="!products.length" class="catalog__empty">
            <p>По заданным фильтрам ничего не нашлось</p>
            <Button label="Сбросить фильтры" outlined @click="resetFilters" />
          </div>
          <div v-else class="catalog__grid">
            <ProductCard
              v-for="p in products"
              :key="p.id"
              :product="p"
            />
          </div>

          <Paginator
            v-if="total > perPage"
            :rows="perPage"
            :totalRecords="total"
            :first="(page - 1) * perPage"
            @page="onPage"
            class="catalog__paginator"
          />
        </div>
      </div>
    </div>
  </section>
</template>

<style lang="scss" scoped>
@use "@/assets/styles/variables" as *;

.catalog {
  padding: 48px 0 80px;

  &__head {
    text-align: center;
    margin-bottom: 48px;

    h1 {
      margin: 0 0 8px;
    }
    p {
      color: var(--color-text-muted);
      margin: 0;
    }
  }

  &__layout {
    display: grid;
    grid-template-columns: 260px 1fr;
    gap: 48px;
  }

  &__sidebar {
    display: flex;
    flex-direction: column;
    gap: 24px;
  }

  &__main {
    min-width: 0;
  }

  &__toolbar {
    display: flex;
    gap: 12px;
    margin-bottom: 32px;

    :deep(.p-inputtext) {
      flex: 1;
    }
    :deep(.p-select) {
      min-width: 200px;
    }
  }

  &__grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
    gap: 24px;
  }

  &__loading,
  &__empty {
    padding: 60px 0;
    text-align: center;
    color: var(--color-text-muted);
  }

  &__paginator {
    margin-top: 48px;
    background: transparent;
    border: 0;
    justify-content: center;
  }
}

.filter-block {
  background: var(--color-surface);
  border-radius: var(--radius-lg);
  padding: 20px 24px;

  h3 {
    font-family: var(--font-body);
    text-transform: uppercase;
    letter-spacing: 0.08em;
    font-size: 0.8rem;
    margin: 0 0 16px;
    color: var(--color-text-muted);
  }
}

.filter-list {
  list-style: none;
  margin: 0;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 4px;

  button {
    width: 100%;
    text-align: left;
    background: transparent;
    border: 0;
    padding: 8px 12px;
    border-radius: var(--radius);
    color: var(--color-text);
    cursor: pointer;
    font-size: 0.95rem;
    transition: all 0.15s ease;

    &:hover {
      background: var(--color-secondary);
    }

    &.active {
      background: var(--color-primary);
      color: #fff;
    }
  }
}

.filter-price {
  display: flex;
  gap: 8px;
  margin-bottom: 12px;

  :deep(.p-inputnumber) {
    width: 100%;
  }
  :deep(.p-inputnumber input) {
    width: 100%;
  }
}

@media (max-width: 900px) {
  .catalog__layout {
    grid-template-columns: 1fr;
  }
}
</style>
