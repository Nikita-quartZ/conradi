import { ref, watch } from "vue";

function serialize(value) {
  if (typeof value === "string") return value;
  return JSON.stringify(value);
}

function deserialize(raw, defaultValue) {
  if (raw == null) return defaultValue;
  if (typeof defaultValue === "string" || defaultValue == null) {
    try {
      const parsed = JSON.parse(raw);
      return typeof parsed === "string" ? parsed : raw;
    } catch {
      return raw;
    }
  }
  try {
    return JSON.parse(raw);
  } catch {
    return defaultValue;
  }
}

export function useLocalStorage(key, defaultValue = null) {
  const read = () => deserialize(localStorage.getItem(key), defaultValue);
  const state = ref(read());

  watch(
    state,
    (value) => {
      if (value == null) localStorage.removeItem(key);
      else localStorage.setItem(key, serialize(value));
    },
    { deep: true },
  );

  window.addEventListener("storage", (event) => {
    if (event.key === key) state.value = read();
  });

  return state;
}
