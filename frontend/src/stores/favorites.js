import { defineStore } from "pinia";
import { ref, computed } from "vue";
import { favoritesApi } from "@/api";
import { useAuthStore } from "./auth";

export const useFavoritesStore = defineStore("favorites", () => {
  const ids = ref([]);

  const idSet = computed(() => new Set(ids.value));

  function isFavorite(productId) {
    return idSet.value.has(productId);
  }

  async function fetchIds() {
    const auth = useAuthStore();
    if (!auth.isAuthenticated) {
      ids.value = [];
      return;
    }
    const { data } = await favoritesApi.ids();
    ids.value = data.ids;
  }

  async function toggle(productId) {
    if (isFavorite(productId)) {
      await favoritesApi.remove(productId);
      ids.value = ids.value.filter((id) => id !== productId);
    } else {
      await favoritesApi.add(productId);
      ids.value = [...ids.value, productId];
    }
  }

  return { ids, isFavorite, fetchIds, toggle };
});
