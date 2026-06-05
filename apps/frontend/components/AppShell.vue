<script setup lang="ts">
const dashboard = useDashboardStore();
const { currentPeriod } = useFiscalPeriod();

const statusColor = {
  承認待ち: "warning",
  差戻し: "error",
  経理確認中: "info",
  支払予定: "success",
} as const;

const formatter = new Intl.NumberFormat("ja-JP", {
  style: "currency",
  currency: "JPY",
});

const navigationItems = [
  { label: "ダッシュボード", icon: "i-lucide-layout-dashboard", active: true },
  { label: "申請一覧", icon: "i-lucide-files" },
  { label: "承認キュー", icon: "i-lucide-check-check" },
  { label: "経理確認", icon: "i-lucide-receipt-text" },
  { label: "設定", icon: "i-lucide-settings" },
];
</script>

<template>
  <div class="min-h-screen bg-slate-50 text-slate-950">
    <div class="grid min-h-screen grid-cols-1 lg:grid-cols-[16rem_1fr]">
      <aside class="border-b border-slate-200 bg-white px-4 py-4 lg:border-b-0 lg:border-r">
        <div class="flex items-center gap-3">
          <div
            class="grid size-10 place-items-center rounded-md bg-emerald-600 text-sm font-bold text-white"
          >
            EC
          </div>
          <div>
            <p class="font-semibold">ExpenseClaim</p>
            <p class="text-xs text-slate-500">経費申請管理</p>
          </div>
        </div>

        <nav class="mt-6 grid gap-1">
          <UButton
            v-for="item in navigationItems"
            :key="item.label"
            :color="item.active ? 'primary' : 'neutral'"
            :icon="item.icon"
            :variant="item.active ? 'soft' : 'ghost'"
            block
            class="justify-start"
          >
            {{ item.label }}
          </UButton>
        </nav>
      </aside>

      <main class="min-w-0">
        <header
          class="flex flex-col gap-4 border-b border-slate-200 bg-white px-5 py-4 md:flex-row md:items-center md:justify-between"
        >
          <div>
            <p class="text-sm text-slate-500">{{ currentPeriod }} 対象</p>
            <h1 class="text-xl font-semibold tracking-normal">申請ダッシュボード</h1>
          </div>
          <div class="flex flex-wrap items-center gap-2">
            <UButton icon="i-lucide-filter" color="neutral" variant="outline"> 絞り込み </UButton>
            <UButton icon="i-lucide-plus"> 新規申請 </UButton>
          </div>
        </header>

        <div class="space-y-6 p-5">
          <section class="grid gap-4 md:grid-cols-3">
            <SummaryCard label="承認待ち" :value="`${dashboard.pendingCount}件`" tone="warning" />
            <SummaryCard
              label="経理確認中"
              :value="`${dashboard.accountingCount}件`"
              tone="primary"
            />
            <SummaryCard
              label="申請合計"
              :value="formatter.format(dashboard.totalAmount)"
              tone="neutral"
            />
          </section>

          <section class="grid gap-4 xl:grid-cols-[1fr_20rem]">
            <UCard>
              <template #header>
                <div class="flex items-center justify-between gap-3">
                  <div>
                    <h2 class="text-base font-semibold">最近の申請</h2>
                    <p class="text-sm text-slate-500">申請状況</p>
                  </div>
                  <UBadge variant="subtle">{{ dashboard.requests.length }}件</UBadge>
                </div>
              </template>

              <div class="grid gap-3 md:hidden">
                <div
                  v-for="request in dashboard.requests"
                  :key="request.id"
                  class="rounded-md border border-slate-200 p-3"
                >
                  <div class="flex items-start justify-between gap-3">
                    <div class="min-w-0">
                      <p class="text-xs text-slate-500">{{ request.id }}</p>
                      <p class="mt-1 font-medium">{{ request.title }}</p>
                      <p class="text-xs text-slate-500">{{ request.submittedAt }}</p>
                    </div>
                    <UBadge :color="statusColor[request.status]" variant="subtle">
                      {{ request.status }}
                    </UBadge>
                  </div>
                  <div class="mt-3 grid grid-cols-2 gap-3 text-sm">
                    <div>
                      <p class="text-xs text-slate-500">申請者</p>
                      <p class="font-medium">{{ request.applicant }}</p>
                      <p class="text-xs text-slate-500">{{ request.department }}</p>
                    </div>
                    <div>
                      <p class="text-xs text-slate-500">金額</p>
                      <p class="font-medium tabular-nums">{{ formatter.format(request.amount) }}</p>
                    </div>
                  </div>
                </div>
              </div>

              <div class="hidden overflow-x-auto md:block">
                <table class="w-full min-w-[36rem] text-left text-sm">
                  <thead class="border-b border-slate-200 text-xs text-slate-500">
                    <tr>
                      <th class="py-2 pr-4 font-medium">申請ID</th>
                      <th class="py-2 pr-4 font-medium">内容</th>
                      <th class="py-2 pr-4 font-medium">申請者</th>
                      <th class="py-2 pr-4 font-medium">金額</th>
                      <th class="py-2 pr-4 font-medium">状態</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr
                      v-for="request in dashboard.requests"
                      :key="request.id"
                      class="border-b border-slate-100 last:border-0"
                    >
                      <td class="py-3 pr-4 font-medium">{{ request.id }}</td>
                      <td class="py-3 pr-4">
                        <div>{{ request.title }}</div>
                        <div class="text-xs text-slate-500">{{ request.submittedAt }}</div>
                      </td>
                      <td class="py-3 pr-4">
                        <div>{{ request.applicant }}</div>
                        <div class="text-xs text-slate-500">{{ request.department }}</div>
                      </td>
                      <td class="py-3 pr-4 tabular-nums">{{ formatter.format(request.amount) }}</td>
                      <td class="py-3 pr-4">
                        <UBadge :color="statusColor[request.status]" variant="subtle">
                          {{ request.status }}
                        </UBadge>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </UCard>

            <UCard>
              <template #header>
                <h2 class="text-base font-semibold">処理状況</h2>
              </template>

              <div class="space-y-5">
                <div>
                  <div class="mb-2 flex justify-between text-sm">
                    <span>承認 SLA</span>
                    <span class="font-medium">68%</span>
                  </div>
                  <UProgress :model-value="68" color="primary" />
                </div>
                <div>
                  <div class="mb-2 flex justify-between text-sm">
                    <span>経理確認</span>
                    <span class="font-medium">42%</span>
                  </div>
                  <UProgress :model-value="42" color="warning" />
                </div>
                <USeparator />
                <div class="space-y-3 text-sm text-slate-600">
                  <p>領収書確認待ち 3 件</p>
                  <p>承認期限が近い申請 2 件</p>
                </div>
              </div>
            </UCard>
          </section>
        </div>
      </main>
    </div>
  </div>
</template>
