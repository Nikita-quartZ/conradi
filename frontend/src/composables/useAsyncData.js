import { ref, shallowRef, onMounted, watch } from "vue";

export function useAsyncData(loader, options = {}) {
  const {
    immediate = true,
    initialValue = null,
    onError,
    watch: watchSources,
  } = options;

  const data = shallowRef(initialValue);
  const error = shallowRef(null);
  const pending = ref(false);

  let currentRequestId = 0;

  async function execute(...args) {
    const requestId = ++currentRequestId;
    pending.value = true;
    error.value = null;
    try {
      const result = await loader(...args);
      if (requestId === currentRequestId) {
        data.value = result;
      }
      return result;
    } catch (err) {
      if (requestId === currentRequestId) {
        error.value = err;
        if (onError) onError(err);
      }
      throw err;
    } finally {
      if (requestId === currentRequestId) {
        pending.value = false;
      }
    }
  }

  if (immediate) {
    onMounted(() => execute());
  }

  if (watchSources) {
    watch(watchSources, () => execute(), { flush: "post" });
  }

  return { data, error, pending, execute, refresh: execute };
}
