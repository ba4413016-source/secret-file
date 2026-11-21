import { BookOpenCheck, Fingerprint, Lightbulb, ShieldAlert } from "lucide-react";
import { CaseFeature } from "@/components/home/CaseFeature";
import { SectionHeading } from "@/components/home/SectionHeading";
import { ProgressBar } from "@/components/ui/ProgressBar";
import { featuredDemoCase } from "@/lib/demo-data";

export function HomeScreen() {
  return (
    <div className="page-container home-page">
      <section aria-labelledby="welcome-title" className="welcome-row">
        <div className="welcome-copy">
          <h1 id="welcome-title">مرحبًا بعودتك، يا محقّق.</h1>
          <p>خذ وقتك. أحيانًا تكون التفاصيل الصغيرة هي بداية الحكاية.</p>
        </div>
        <div aria-hidden="true" className="welcome-mark">
          <Fingerprint size={24} strokeWidth={1.7} />
        </div>
      </section>

      <CaseFeature />

      <section aria-labelledby="brief-section-title">
        <SectionHeading
          description="خيط قصير من ملف العرض التجريبي"
          id="brief-section-title"
          title="من دفتر المحقق"
        />
        <div className="home-lower-grid">
          <article className="brief-card">
            <div className="brief-card__top">
              <div aria-hidden="true" className="brief-card__icon">
                <Lightbulb size={20} />
              </div>
              <div>
                <strong>ملاحظة من موقع الحادثة</strong>
                <span>تفصيل خيالي ضمن المعاينة</span>
              </div>
            </div>
            <p>{featuredDemoCase.clue}</p>
            <div className="brief-card__clue">
              <BookOpenCheck aria-hidden="true" size={16} />
              <span>اسأل نفسك: هل كان الصوت مقصودًا، أم مجرد مصادفة؟</span>
            </div>
          </article>

          <article aria-labelledby="progress-title" className="progress-card">
            <div className="progress-card__header">
              <div>
                <h3 id="progress-title">مسار الملف التجريبي</h3>
                <p>جمع الأدلة قبل تكوين النظرية</p>
              </div>
              <span className="progress-value">٢ من ٥</span>
            </div>
            <ProgressBar label="تقدّم ملف العرض التجريبي" value={featuredDemoCase.sampleProgress} />
            <p className="progress-note">هذا التقدّم تجريبي ولا يُحفظ في هذه المرحلة.</p>
          </article>
        </div>
      </section>

      <p className="home-note">
        <ShieldAlert aria-hidden="true" size={16} />
        <span>{featuredDemoCase.note}</span>
      </p>
    </div>
  );
}
