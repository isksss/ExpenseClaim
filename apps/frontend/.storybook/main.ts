import type { StorybookConfig } from "@storybook-vue/nuxt";

const config: StorybookConfig = {
  stories: ["../components/**/*.stories.@(ts|tsx|js|jsx|mjs)"],
  framework: {
    name: "@storybook-vue/nuxt",
    options: {},
  },
  docs: {},
};

export default config;
