import { createApp } from "vue";
import { createPinia } from "pinia";
import PrimeVue from "primevue/config";
import Aura from "@primevue/themes/aura";

import App from "./App.vue";
import router from "./router";
import { useAuthStore } from "@/stores/auth";

import "primeicons/primeicons.css";
import "./assets/styles/main.scss";

async function bootstrap() {
  const app = createApp(App);
  app.use(createPinia());

  const auth = useAuthStore();
  if (auth.token) await auth.fetchMe();

  app.use(router);
  app.use(PrimeVue, {
    theme: {
      preset: Aura,
      options: {
        darkModeSelector: ".dark-mode",
        cssLayer: { name: "primevue", order: "primevue" },
      },
    },
  });

  app.mount("#app");
}

bootstrap();
