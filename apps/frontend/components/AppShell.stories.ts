import type { Meta, StoryObj } from "@storybook-vue/nuxt";

import AppShell from "./AppShell.vue";

const meta = {
  title: "App/AppShell",
  component: AppShell,
  parameters: {
    layout: "fullscreen",
  },
} satisfies Meta<typeof AppShell>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {};
