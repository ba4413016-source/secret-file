import type { LucideIcon } from "lucide-react";
import Link from "next/link";
import { ArrowRight } from "lucide-react";
import { GlassBadge } from "@/components/ui/GlassBadge";

type PlaceholderScreenProps = {
  title: string;
  description: string;
  Icon: LucideIcon;
  supportEmail?: string;
};

export function PlaceholderScreen({
  title,
  description,
  Icon,
  supportEmail,
}: PlaceholderScreenProps) {
  return (
    <div className="page-container">
      <section aria-labelledby="placeholder-title" className="placeholder-page">
        <div aria-hidden="true" className="placeholder-page__icon">
          <Icon size={30} strokeWidth={1.7} />
        </div>
        <GlassBadge variant="gold">مسار تنقل تجريبي</GlassBadge>
        <h1 id="placeholder-title">{title}</h1>
        <p>{description}</p>
        <div className="placeholder-page__notice">
          هذه الصفحة هي هيكل تنقل فقط. المحتوى الفعلي سيُضاف في مرحلة لاحقة.
        </div>
        {supportEmail && (
          <div className="support-panel">
            <span>للدعم والمساعدة</span>
            <a href={`mailto:${supportEmail}`}>{supportEmail}</a>
          </div>
        )}
        <Link className="button button--subtle" href="/">
          <ArrowRight aria-hidden="true" size={17} />
          العودة للرئيسية
        </Link>
      </section>
    </div>
  );
}
