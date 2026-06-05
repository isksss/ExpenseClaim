export const useFiscalPeriod = () => {
  const now = useNow();
  const formatter = new Intl.DateTimeFormat("ja-JP", {
    year: "numeric",
    month: "2-digit",
  });

  const currentPeriod = computed(() => formatter.format(now.value));

  return {
    currentPeriod,
  };
};
