import { defineStore } from "pinia";
import { ref, computed } from "vue";
import { authApi } from "@/api";
import { useLocalStorage } from "@/composables/useLocalStorage";

export const useAuthStore = defineStore("auth", () => {
  const token = useLocalStorage("token", null);
  const user = ref(null);
  const loading = ref(false);

  const isAuthenticated = computed(() => Boolean(token.value));
  const isAdmin = computed(() => user.value?.role === "admin");

  async function withLoading(task) {
    loading.value = true;
    try {
      return await task();
    } finally {
      loading.value = false;
    }
  }

  async function login(credentials) {
    return withLoading(async () => {
      const { data } = await authApi.login(credentials);
      token.value = data.token;
      user.value = data.user;
      return data.user;
    });
  }

  async function register(payload) {
    return withLoading(async () => {
      const { data } = await authApi.register(payload);
      token.value = data.token;
      user.value = data.user;
      return data.user;
    });
  }

  async function fetchMe() {
    if (!token.value) return null;
    try {
      const { data } = await authApi.me();
      user.value = data.user;
      return data.user;
    } catch {
      token.value = null;
      user.value = null;
      return null;
    }
  }

  function logout() {
    token.value = null;
    user.value = null;
  }

  async function updateProfile(payload) {
    const { data } = await authApi.updateMe(payload);
    user.value = data.user;
    return data.user;
  }

  return {
    token,
    user,
    loading,
    isAuthenticated,
    isAdmin,
    login,
    register,
    fetchMe,
    logout,
    updateProfile,
  };
});
