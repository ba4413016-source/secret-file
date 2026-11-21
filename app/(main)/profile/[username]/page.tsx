import { UserRound } from "lucide-react";
import { PlaceholderScreen } from "@/components/shared/PlaceholderScreen";

type ProfilePageProps = {
  params: { username: string };
};

export function generateMetadata({ params }: ProfilePageProps) {
  return { title: params.username === "me" ? "الشخصية" : "ملف محقق" };
}

export default function ProfilePage({ params }: ProfilePageProps) {
  const ownProfile = params.username === "me";

  return (
    <PlaceholderScreen
      description={ownProfile ? "ستظهر هنا إحصاءاتك وشاراتك بعد ربط الحساب." : "ملفات المحققين ستُضاف في مرحلة المجتمع."}
      Icon={UserRound}
      title={ownProfile ? "الشخصية" : "ملف محقق"}
    />
  );
}
