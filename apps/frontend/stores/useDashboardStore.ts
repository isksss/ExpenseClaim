export type ExpenseStatus = "承認待ち" | "差戻し" | "経理確認中" | "支払予定";

export interface ExpenseRequestSummary {
  id: string;
  applicant: string;
  department: string;
  title: string;
  amount: number;
  submittedAt: string;
  status: ExpenseStatus;
}

export const useDashboardStore = defineStore("dashboard", () => {
  const requests = ref<ExpenseRequestSummary[]>([
    {
      id: "EXP-2026-0018",
      applicant: "田中 葵",
      department: "営業部",
      title: "大阪出張交通費",
      amount: 42800,
      submittedAt: "2026-06-04",
      status: "承認待ち",
    },
    {
      id: "EXP-2026-0017",
      applicant: "佐藤 陽介",
      department: "開発部",
      title: "検証端末購入",
      amount: 96800,
      submittedAt: "2026-06-03",
      status: "経理確認中",
    },
    {
      id: "EXP-2026-0016",
      applicant: "鈴木 美咲",
      department: "管理部",
      title: "月次備品精算",
      amount: 12450,
      submittedAt: "2026-06-02",
      status: "差戻し",
    },
    {
      id: "EXP-2026-0015",
      applicant: "高橋 健",
      department: "営業部",
      title: "顧客訪問タクシー代",
      amount: 7300,
      submittedAt: "2026-06-01",
      status: "支払予定",
    },
  ]);

  const pendingCount = computed(
    () => requests.value.filter((request) => request.status === "承認待ち").length,
  );
  const accountingCount = computed(
    () => requests.value.filter((request) => request.status === "経理確認中").length,
  );
  const totalAmount = computed(() =>
    requests.value.reduce((sum, request) => sum + request.amount, 0),
  );

  return {
    accountingCount,
    pendingCount,
    requests,
    totalAmount,
  };
});
