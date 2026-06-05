<script setup lang="ts">
defineProps<{
  label: string;
  value: string;
  tone?: "primary" | "warning" | "neutral";
}>();
</script>

<template>
  <UCard>
    <div class="flex items-start justify-between gap-3">
      <div>
        <p class="text-sm text-slate-500">
          {{ label }}
        </p>
        <p class="mt-2 text-2xl font-semibold text-slate-950">
          {{ value }}
        </p>
      </div>
      <UBadge :color="tone ?? 'neutral'" variant="subtle"> 今月 </UBadge>
    </div>
  </UCard>
</template>
