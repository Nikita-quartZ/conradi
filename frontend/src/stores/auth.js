import { defineStore } from "pinia";
import { ref, computed } from "vue";
import { authApi } from "@/api";

export const useAuthStore = defineStore("auth", () => {
  const token = ref(localStorage.getItem("token") || null);
  const user = ref(null);
  const loading = ref(false);

  const isAuthenticated = computed(() => !!token.value);
  const isAdmin = computed(() => user.value?.role === "admin");

  function setToken(value) {
    token.value = value;
    if (value) localStorage.setItem("token", value);
    else localStorage.removeItem("token");
  }

  async function login(credentials) {
    loading.value = true;
    try {
      const { data } = await authApi.login(credentials);
      setToken(data.token);
      user.value = data.user;
      return data.user;
    } finally {
      loading.value = false;
    }
  }

  async function register(payload) {
    loading.value = true;
    try {
      const { data } = await authApi.register(payload);
      setToken(data.token);
      user.value = data.user;
      return data.user;
    } finally {
      loading.value = false;
    }
  }

  async function fetchMe() {
    if (!token.value) return null;
    try {
      const { data } = await authApi.me();
      user.value = data.user;
      return data.user;
    } catch {
      setToken(null);
      user.value = null;
      return null;
    }
  }

  function logout() {
    setToken(null);
    user.value = null;
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
  };
});
