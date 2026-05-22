import { defineStore } from "pinia";
import { ref } from "vue";
import { cartApi } from "@/api";
import { useAuthStore } from "./auth";

export const useCartStore = defineStore("cart", () => {
  const items = ref([]);
  const total = ref(0);
  const count = ref(0);

  function apply({ items: nextItems = [], total: nextTotal = 0, count: nextCount = 0 } = {}) {
    items.value = nextItems;
    total.value = nextTotal;
    count.value = nextCount;
  }

  function reset() {
    apply();
  }

  async function load() {
    if (!useAuthStore().isAuthenticated) {
      reset();
      return;
    }
    const { data } = await cartApi.get();
    apply(data);
  }

  async function add(productId, quantity = 1) {
    const { data } = await cartApi.add(productId, quantity);
    apply(data);
  }

  async function update(itemId, quantity) {
    const { data } = await cartApi.update(itemId, quantity);
    apply(data);
  }

  async function remove(itemId) {
    const { data } = await cartApi.remove(itemId);
    apply(data);
  }

  async function clear() {
    const { data } = await cartApi.clear();
    apply(data);
  }

  return { items, total, count, load, add, update, remove, clear, reset };
});
