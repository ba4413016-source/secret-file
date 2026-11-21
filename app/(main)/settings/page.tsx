import { Settings } from "lucide-react";
import { PlaceholderScreen } from "@/components/shared/PlaceholderScreen";

export const metadata = { title: "الإعدادات" };

export default function SettingsPage() {
  return (
    <PlaceholderScreen
      description="خيارات الحساب واللغة والمظهر والخصوصية لم تُربط بعد."
      Icon={Settings}
      supportEmail="ba4413016@gmail.com"
      title="الإعدادات"
    />
  );
}
