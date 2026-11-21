import { FolderSearch } from "lucide-react";
import { PlaceholderScreen } from "@/components/shared/PlaceholderScreen";

export const metadata = { title: "القضايا" };

export default function CasesPage() {
  return (
    <PlaceholderScreen
      description="سيظهر هنا أرشيف القضايا عندما يبدأ تنفيذ مرحلة المحتوى."
      Icon={FolderSearch}
      title="القضايا"
    />
  );
}
