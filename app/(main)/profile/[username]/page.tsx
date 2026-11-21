import { UserRound } from "lucide-react";
import { PlaceholderScreen } from "@/components/shared/PlaceholderScreen";

type ProfilePageProps = {
  params: Promise<{ username: string }>;
};

export async function generateMetadata({ params }: ProfilePageProps) {
  const { username } = await params;
  return { title: username === "me" ? "الشخصية" : "ملف محقق" };
}

export default async function ProfilePage({ params }: ProfilePageProps) {
  const { username } = await params;
  const ownProfile = username === "me";

  return (
    <PlaceholderScreen
      description={ownProfile ? "ستظهر هنا إحصاءاتك وشاراتك بعد ربط الحساب." : "ملفات المحققين ستُضاف في مرحلة المجتمع."}
      Icon={UserRound}
      title={ownProfile ? "الشخصية" : "ملف محقق"}
    />
  );
}
