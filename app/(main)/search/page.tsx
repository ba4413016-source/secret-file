import { Search } from "lucide-react";
import { PlaceholderScreen } from "@/components/shared/PlaceholderScreen";

export const metadata = { title: "البحث" };

export default function SearchPage() {
  return (
    <PlaceholderScreen
      description="ستُضاف نتائج البحث والفلاتر في مرحلة التوسّع."
      Icon={Search}
      title="البحث"
    />
  );
}
