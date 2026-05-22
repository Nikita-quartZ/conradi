import { ref } from "vue";

export function useFlash(timeout = 3000) {
  const message = ref(null);
  let timer = null;

  function show(severity, text) {
    if (timer) clearTimeout(timer);
    message.value = { severity, text };
    timer = setTimeout(() => {
      message.value = null;
      timer = null;
    }, timeout);
  }

  return {
    message,
    success: (text) => show("success", text),
    error: (text) => show("error", text),
    info: (text) => show("info", text),
    clear: () => {
      if (timer) clearTimeout(timer);
      message.value = null;
    },
  };
}
