import { computed } from "vue";
import { useRoute, useRouter } from "vue-router";

function buildNextQuery(route, updates) {
  const next = { ...route.query };
  for (const [key, value, defaultValue] of updates) {
    if (value == null || value === "" || value === defaultValue) {
      delete next[key];
    } else {
      next[key] = String(value);
    }
  }
  return next;
}

export function useRouteQuery(key, defaultValue = null, transform = (v) => v) {
  const route = useRoute();
  const router = useRouter();

  return computed({
    get() {
      const raw = route.query[key];
      if (raw == null) return defaultValue;
      return transform(raw);
    },
    set(value) {
      router.replace({
        query: buildNextQuery(route, [[key, value, defaultValue]]),
      });
    },
  });
}

export function useRouteQueryBatch() {
  const route = useRoute();
  const router = useRouter();

  return function setMany(updates) {
    router.replace({ query: buildNextQuery(route, updates) });
  };
}

export function asNumber(value) {
  const n = Number(value);
  return Number.isFinite(n) ? n : null;
}

export function asBoolean(value) {
  return value === "true" || value === "1";
}
