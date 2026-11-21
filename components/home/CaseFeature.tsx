import { ArrowLeft, Clock3, LockKeyhole } from "lucide-react";
import Link from "next/link";
import { featuredDemoCase } from "@/lib/demo-data";
import { GlassBadge } from "@/components/ui/GlassBadge";

export function CaseFeature() {
  return (
    <article aria-labelledby="featured-case-title" className="feature-case">
      <div className="feature-case__content">
        <div className="feature-case__tags">
          <GlassBadge variant="gold">{featuredDemoCase.category}</GlassBadge>
          <GlassBadge variant="blood">
            <LockKeyhole aria-hidden="true" size={12} />
            ملف تجريبي
          </GlassBadge>
        </div>
        <h2 id="featured-case-title">{featuredDemoCase.title}</h2>
        <p>{featuredDemoCase.summary}</p>
        <ul className="feature-case__details">
          <li>
            <Clock3 aria-hidden="true" size={15} />
            نحو {featuredDemoCase.estimatedMinutes} دقائق
          </li>
          <li>
            <span aria-hidden="true" className="difficulty-dot" />
            مستوى {featuredDemoCase.difficulty}
          </li>
        </ul>
        <Link className="button button--primary" href="/cases">
          استكشف القضايا
          <ArrowLeft aria-hidden="true" size={17} />
        </Link>
      </div>
      <div aria-hidden="true" className="feature-case__art">
        <div className="file-shadow" />
        <div className="evidence-file">
          <div className="evidence-file__top">
            <span>ملف رقم ٠١</span>
            <span>٢٠٢٦</span>
          </div>
          <div className="evidence-file__title">
            <strong>الغرفة ١٧</strong>
            <div className="evidence-file__lines">
              <span />
              <span />
              <span />
            </div>
          </div>
          <span className="file-stamp">سري</span>
        </div>
      </div>
    </article>
  );
}
