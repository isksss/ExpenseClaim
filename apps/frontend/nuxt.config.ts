export default defineNuxtConfig({
  compatibilityDate: "2026-06-06",
  devtools: { enabled: false },
  modules: ["@nuxt/ui", "@pinia/nuxt", "@vueuse/nuxt"],
  css: ["~/assets/css/main.css"],
  typescript: {
    strict: true,
    typeCheck: true,
  },
  app: {
    head: {
      title: "ExpenseClaim",
      meta: [
        {
          name: "description",
          content: "社内経費申請管理ツール",
        },
      ],
    },
  },
});
