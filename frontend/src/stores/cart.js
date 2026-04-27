import { defineStore } from "pinia";
import { ref } from "vue";
import { cartApi } from "@/api";
import { useAuthStore } from "./auth";

export const useCartStore = defineStore("cart", () => {
  const items = ref([]);
  const total = ref(0);
  const count = ref(0);

  function _apply(data) {
    items.value = data.items;
    total.value = data.total;
    count.value = data.count;
  }

  async function fetch() {
    const auth = useAuthStore();
    if (!auth.isAuthenticated) {
      items.value = [];
      total.value = 0;
      count.value = 0;
      return;
    }
    const { data } = await cartApi.get();
    _apply(data);
  }

  async function add(productId, quantity = 1) {
    const { data } = await cartApi.add(productId, quantity);
    _apply(data);
  }

  async function update(itemId, quantity) {
    const { data } = await cartApi.update(itemId, quantity);
    _apply(data);
  }

  async function remove(itemId) {
    const { data } = await cartApi.remove(itemId);
    _apply(data);
  }

  async function clear() {
    const { data } = await cartApi.clear();
    _apply(data);
  }

  return { items, total, count, fetch, add, update, remove, clear };
});
