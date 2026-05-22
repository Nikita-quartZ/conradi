<script setup>
import { computed, reactive, ref } from "vue";
import { useRoute } from "vue-router";
import { catalogApi } from "@/api";
import { useAsyncData } from "@/composables/useAsyncData";
import {
  useRouteQuery,
  useRouteQueryBatch,
  asNumber,
  asBoolean,
} from "@/composables/useRouteQuery";
import { pluralizeRu } from "@/utils/format";
import ProductCard from "@/components/ProductCard.vue";
import Select from "primevue/select";
import InputText from "primevue/inputtext";
import InputNumber from "primevue/inputnumber";
import Button from "primevue/button";
import Paginator from "primevue/paginator";

const route = useRoute();

const PER_PAGE = 12;

const categoryId = useRouteQuery("category", null, asNumber);
const typeId = useRouteQuery("type", null, asNumber);
const sort = useRouteQuery("sort", "newest");
const page = useRouteQuery("page", 1, asNumber);

const formFilters = reactive({
  q: route.query.q ?? "",
  min_price: asNumber(route.query.min_price),
  max_price: asNumber(route.query.max_price),
  in_stock: asBoolean(route.query.in_stock),
});

const appliedQ = useRouteQuery("q", "");
const appliedMin = useRouteQuery("min_price", null, asNumber);
const appliedMax = useRouteQuery("max_price", null, asNumber);
const appliedInStock = useRouteQuery("in_stock", false, asBoolean);

const setQueryBatch = useRouteQueryBatch();

const filtersOpen = ref(false);

const sortOptions = [
  { value: "newest", label: "Сначала новые" },
  { value: "price_asc", label: "Сначала дешевле" },
  { value: "price_desc", label: "Сначала дороже" },
];

const requestParams = computed(() => {
  const params = { page: page.value, per_page: PER_PAGE, sort: sort.value };
  if (categoryId.value) params.category_id = categoryId.value;
  if (typeId.value) params.product_type_id = typeId.value;
  if (appliedQ.value) params.q = appliedQ.value;
  if (appliedMin.value != null) params.min_price = appliedMin.value;
  if (appliedMax.value != null) params.max_price = appliedMax.value;
  if (appliedInStock.value) params.in_stock = "true";
  return params;
});

const { data: meta } = useAsyncData(async () => {
  const [c, t] = await Promise.all([catalogApi.categories(), catalogApi.productTypes()]);
  return { categories: c.data.items, types: t.data.items };
});

const { data: catalogData, pending } = useAsyncData(
  () => catalogApi.products(requestParams.value).then((r) => r.data),
  { watch: [requestParams], initialValue: { items: [], total: 0 } },
);

const categories = computed(() => meta.value?.categories ?? []);
const types = computed(() => meta.value?.types ?? []);
const products = computed(() => catalogData.value?.items ?? []);
const total = computed(() => catalogData.value?.total ?? 0);

const activeCategoryTitle = computed(
  () => categories.value.find((c) => c.id === categoryId.value)?.title ?? "",
);

const totalLabel = computed(
  () => `${total.value} ${pluralizeRu(total.value, ["товар", "товара", "товаров"])}`,
);

function pickCategory(id) {
  setQueryBatch([
    ["category", id, null],
    ["page", 1, 1],
  ]);
  filtersOpen.value = false;
}

function pickType(id) {
  setQueryBatch([
    ["type", id, null],
    ["page", 1, 1],
  ]);
  filtersOpen.value = false;
}

function changeSort(value) {
  setQueryBatch([
    ["sort", value, "newest"],
    ["page", 1, 1],
  ]);
}

function applyForm() {
  setQueryBatch([
    ["q", formFilters.q, ""],
    ["min_price", formFilters.min_price, null],
    ["max_price", formFilters.max_price, null],
    ["in_stock", formFilters.in_stock ? "true" : null, null],
    ["page", 1, 1],
  ]);
  filtersOpen.value = false;
}

function resetFilters() {
  formFilters.q = "";
  formFilters.min_price = null;
  formFilters.max_price = null;
  formFilters.in_stock = false;
  setQueryBatch([
    ["category", null, null],
    ["type", null, null],
    ["sort", "newest", "newest"],
    ["page", 1, 1],
    ["q", "", ""],
    ["min_price", null, null],
    ["max_price", null, null],
    ["in_stock", null, null],
  ]);
}

function onPage(event) {
  page.value = event.page + 1;
  window.scrollTo({ top: 0, behavior: "smooth" });
}
</script>

<template>
  <section class="catalog">
    <div class="container">
      <header class="catalog__head">
        <h1>{{ activeCategoryTitle || "Каталог" }}</h1>
        <p>Всего {{ totalLabel }}</p>
      </header>

      <button class="catalog__filter-btn" @click="filtersOpen = true">
        <i class="pi pi-filter" /> Фильтры
      </button>

      <div class="catalog__layout">
        <aside
          class="catalog__sidebar"
          :class="{ 'catalog__sidebar--open': filtersOpen }"
        >
          <button
            class="catalog__filter-close"
            aria-label="Закрыть"
            @click="filtersOpen = false"
          >
            <i class="pi pi-times" />
          </button>
          <div class="filter-block">
            <h3>Категория</h3>
            <ul class="filter-list">
              <li>
                <button :class="{ active: categoryId == null }" @click="pickCategory(null)">
                  Все
                </button>
              </li>
              <li v-for="c in categories" :key="c.id">
                <button :class="{ active: categoryId === c.id }" @click="pickCategory(c.id)">
                  {{ c.title }}
                </button>
              </li>
            </ul>
          </div>

          <div class="filter-block">
            <h3>Тип</h3>
            <ul class="filter-list">
              <li>
                <button :class="{ active: typeId == null }" @click="pickType(null)">
                  Все
                </button>
              </li>
              <li v-for="t in types" :key="t.id">
                <button :class="{ active: typeId === t.id }" @click="pickType(t.id)">
                  {{ t.title }}
                </button>
              </li>
            </ul>
          </div>

          <div class="filter-block">
            <h3>Цена, ₽</h3>
            <div class="filter-price">
              <InputNumber v-model="formFilters.min_price" placeholder="От" :min="0" />
              <InputNumber v-model="formFilters.max_price" placeholder="До" :min="0" />
            </div>
            <Button label="Применить" size="small" outlined @click="applyForm" />
          </div>

          <Button label="Сбросить" text @click="resetFilters" />
        </aside>

        <div
          v-if="filtersOpen"
          class="catalog__filter-overlay"
          @click="filtersOpen = false"
        ></div>

        <div class="catalog__main">
          <div class="catalog__toolbar">
            <InputText
              v-model="formFilters.q"
              placeholder="Поиск по названию..."
              @keyup.enter="applyForm"
            />
            <Select
              :model-value="sort"
              :options="sortOptions"
              option-label="label"
              option-value="value"
              @update:model-value="changeSort"
            />
          </div>

          <div v-if="pending" class="catalog__loading">Загружаем...</div>
          <div v-else-if="!products.length" class="catalog__empty">
            <p>По заданным фильтрам ничего не нашлось</p>
            <Button label="Сбросить фильтры" outlined @click="resetFilters" />
          </div>
          <div v-else class="catalog__grid">
            <ProductCard v-for="p in products" :key="p.id" :product="p" />
          </div>

          <Paginator
            v-if="total > PER_PAGE"
            :rows="PER_PAGE"
            :total-records="total"
            :first="(page - 1) * PER_PAGE"
            class="catalog__paginator"
            @page="onPage"
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

.catalog__filter-btn {
  display: none;
  align-items: center;
  gap: 8px;
  padding: 10px 18px;
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius);
  font-size: 0.95rem;
  font-family: inherit;
  cursor: pointer;
  margin-bottom: 16px;

  i {
    color: var(--color-primary);
  }
}

.catalog__filter-close {
  display: none;
  position: absolute;
  top: 12px;
  right: 12px;
  width: 36px;
  height: 36px;
  border-radius: 50%;
  border: 0;
  background: var(--color-secondary);
  cursor: pointer;
  align-items: center;
  justify-content: center;

  i {
    font-size: 1rem;
    color: var(--color-text);
  }
}

.catalog__filter-overlay {
  display: none;
}

@media (max-width: 900px) {
  .catalog__layout {
    grid-template-columns: 1fr;
  }

  .catalog__filter-btn {
    display: inline-flex;
  }

  .catalog__sidebar {
    position: fixed;
    top: 0;
    left: 0;
    bottom: 0;
    width: min(85vw, 360px);
    background: var(--color-surface-alt);
    padding: 64px 20px 20px;
    overflow-y: auto;
    transform: translateX(-100%);
    transition: transform 0.25s ease;
    z-index: 60;
    box-shadow: 4px 0 16px rgba(0, 0, 0, 0.08);

    &--open {
      transform: translateX(0);
    }
  }

  .catalog__filter-close {
    display: inline-flex;
  }

  .catalog__filter-overlay {
    display: block;
    position: fixed;
    inset: 0;
    background: rgba(42, 33, 32, 0.4);
    z-index: 59;
  }
}

@media (max-width: 600px) {
  .catalog {
    padding: 32px 0 56px;

    &__head {
      margin-bottom: 24px;

      h1 {
        font-size: 2rem;
      }
    }

    &__toolbar {
      flex-direction: column;
      gap: 8px;
      margin-bottom: 24px;

      :deep(.p-select) {
        min-width: 0;
        width: 100%;
      }
    }

    &__grid {
      grid-template-columns: 1fr;
      gap: 16px;
    }
  }
}
</style>
