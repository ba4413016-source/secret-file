"use client";

import Image from "next/image";
import { useEffect, useRef, useState, type ChangeEvent, type CSSProperties } from "react";
import {
  BadgeCheck,
  Check,
  Crown,
  ImagePlus,
  RotateCcw,
  ShieldCheck,
  Sparkles,
  Upload,
  X,
} from "lucide-react";

type BannerMode = "static" | "motion";
type FrameStyle = "coin" | "double" | "seal" | "orbit" | "leaf";
type ThemeChoice = {
  id: string;
  label: string;
  surface: string;
  accent: string;
  cover: string;
};
type SelectedBanner = { file: File; url: string };
type CropSettings = { x: number; y: number; zoom: number };

const MAX_BANNER_BYTES = 12 * 1024 * 1024;
const STATIC_TYPES = ["image/jpeg", "image/png", "image/webp", "image/avif"];
const MOTION_TYPES = ["image/gif", "image/apng", "image/webp"];

const themes: ThemeChoice[] = [
  { id: "archive", label: "دفتر الأرشيف", surface: "#282321", accent: "#e4b27b", cover: "#37302c" },
  { id: "forest", label: "أخضر عميق", surface: "#1e2924", accent: "#9ac2a8", cover: "#2d3a33" },
  { id: "ink", label: "حبر ليلي", surface: "#202833", accent: "#9cc4dd", cover: "#2b3845" },
  { id: "rose", label: "ورد معتّق", surface: "#2b2226", accent: "#dfa2a7", cover: "#3b2d33" },
  { id: "amber", label: "عنبر داكن", surface: "#2d271e", accent: "#e6c477", cover: "#403725" },
];

const frames: { id: FrameStyle; label: string }[] = [
  { id: "coin", label: "ختم نحاسي" },
  { id: "double", label: "خطّان فضيّان" },
  { id: "seal", label: "ختم الأرشيف" },
  { id: "orbit", label: "مدار هادئ" },
  { id: "leaf", label: "ورقة زمردية" },
];

const initialCrops: Record<BannerMode, CropSettings> = {
  static: { x: 50, y: 50, zoom: 100 },
  motion: { x: 50, y: 50, zoom: 100 },
};

function PreviewBadge({ kind, size = "sm" }: { kind: "vip" | "admin"; size?: "sm" | "md" }) {
  return (
    <BadgeCheck
      aria-label={kind === "vip" ? "معاينة شارة VIP الزرقاء" : "معاينة شارة الإدارة الذهبية"}
      className={`vip-preview-badge vip-preview-badge--${kind}`}
      role="img"
      size={size === "md" ? 20 : 16}
    />
  );
}

export function VipCustomizationScreen() {
  const [themeId, setThemeId] = useState(themes[0].id);
  const [frameStyle, setFrameStyle] = useState<FrameStyle>("coin");
  const [mode, setMode] = useState<BannerMode>("static");
  const [banners, setBanners] = useState<Record<BannerMode, SelectedBanner | null>>({
    static: null,
    motion: null,
  });
  const [crops, setCrops] = useState(initialCrops);
  const [error, setError] = useState("");
  const [notice, setNotice] = useState("");
  const objectUrls = useRef<Record<BannerMode, string | null>>({ static: null, motion: null });
  const coverRef = useRef<HTMLDivElement>(null);
  const [coverRatio, setCoverRatio] = useState<number | null>(null);
  const activeTheme = themes.find((theme) => theme.id === themeId) ?? themes[0];
  const activeBanner = banners[mode];
  const activeCrop = crops[mode];

  useEffect(
    () => () => {
      Object.values(objectUrls.current).forEach((url) => {
        if (url) URL.revokeObjectURL(url);
      });
    },
    [],
  );

  useEffect(() => {
    const cover = coverRef.current;
    if (!cover) return;

    const updateCoverRatio = () => {
      const { width, height } = cover.getBoundingClientRect();
      if (width > 0 && height > 0) setCoverRatio(width / height);
    };

    updateCoverRatio();
    const observer = new ResizeObserver(updateCoverRatio);
    observer.observe(cover);
    return () => observer.disconnect();
  }, []);

  function selectBanner(event: ChangeEvent<HTMLInputElement>) {
    const file = event.currentTarget.files?.[0];
    event.currentTarget.value = "";
    setError("");
    setNotice("");

    if (!file) return;
    if (!file.type.startsWith("image/")) {
      setError("اختاري ملف صورة صالحًا.");
      return;
    }
    if (file.size > MAX_BANNER_BYTES) {
      setError("حجم الملف أكبر من 12 ميغابايت. اختاري صورة أصغر.");
      return;
    }
    if (mode === "static" && !STATIC_TYPES.includes(file.type)) {
      setError("للبنر الثابت اختاري JPG أو PNG أو WebP أو AVIF.");
      return;
    }
    if (mode === "motion" && !MOTION_TYPES.includes(file.type)) {
      setError("للبنر المتحرك اختاري GIF أو APNG أو WebP يدعم الحركة.");
      return;
    }

    const previousUrl = objectUrls.current[mode];
    if (previousUrl) URL.revokeObjectURL(previousUrl);
    const url = URL.createObjectURL(file);
    objectUrls.current[mode] = url;
    setBanners((current) => ({ ...current, [mode]: { file, url } }));
    setNotice(mode === "motion" ? "تمت إضافة المعاينة. ستظهر الحركة إذا كان الملف متحركًا." : "تمت إضافة البنر إلى المعاينة.");
  }

  function clearBanner() {
    const previousUrl = objectUrls.current[mode];
    if (previousUrl) URL.revokeObjectURL(previousUrl);
    objectUrls.current[mode] = null;
    setBanners((current) => ({ ...current, [mode]: null }));
    setError("");
    setNotice("أُزيل البنر من المعاينة.");
  }

  function updateCrop(key: keyof CropSettings, value: number) {
    setCrops((current) => ({
      ...current,
      [mode]: { ...current[mode], [key]: value },
    }));
  }

  const themeStyle = {
    "--vip-surface": activeTheme.surface,
    "--vip-accent": activeTheme.accent,
    "--vip-cover": activeTheme.cover,
  } as CSSProperties;

  const bannerImageStyle = {
    objectPosition: `${activeCrop.x}% ${activeCrop.y}%`,
    transform: `scale(${activeCrop.zoom / 100})`,
  } as CSSProperties;

  return (
    <div className="page-container vip-page">
      <header className="vip-intro">
        <div>
          <h1 id="vip-title">خلّ ملفك يشبهك</h1>
          <p>اختر سمة وإطارًا وبنرًا، وشاهد التغييرات مباشرة على معاينة ملفك.</p>
        </div>
        <span className="vip-local-note">معاينة محلية فقط</span>
      </header>

      <div className="vip-top-grid">
        <section aria-labelledby="vip-preview-heading" className="vip-preview-shell">
          <div className="vip-section-heading">
            <div>
              <h2 id="vip-preview-heading">معاينة الملف</h2>
              <p>تتغير مع اختياراتك في هذه الصفحة.</p>
            </div>
            <span className="vip-live-indicator"><span aria-hidden="true" /> مباشر</span>
          </div>

          <article className="vip-profile-card" style={themeStyle}>
            <div
              aria-label={activeBanner ? `معاينة البنر ${mode === "static" ? "الثابت" : "المتحرك"}` : "مساحة معاينة البنر"}
              className={`vip-profile-cover${activeBanner ? " vip-profile-cover--image" : ""}`}
              role="img"
              ref={coverRef}
            >
              {activeBanner ? (
                <Image alt="" fill sizes="(max-width: 680px) 100vw, 720px" src={activeBanner.url} style={bannerImageStyle} unoptimized />
              ) : (
                <div className={`vip-cover-placeholder vip-cover-placeholder--${mode}`}>
                  <span aria-hidden="true" className="vip-cover-placeholder__seal"><Sparkles size={19} /></span>
                  <span>{mode === "static" ? "بنرك الثابت" : "بنرك المتحرك"}</span>
                  <small>اختر صورة لتخصيص الغلاف</small>
                </div>
              )}
              <span className="vip-profile-cover__tag">ملف تجريبي</span>
            </div>

            <div className="vip-profile-identity">
              <div className={`vip-avatar-frame vip-avatar-frame--${frameStyle}`}>
                <div aria-label="صورة رمزية تجريبية" className="vip-avatar" role="img">ب</div>
              </div>
              <div className="vip-profile-name">
                <div className="vip-profile-name__line">
                  <h3>بدر</h3>
                  <PreviewBadge kind="vip" size="md" />
                  <span className="vip-member-label"><Crown aria-hidden="true" size={13} /> معاينة VIP</span>
                </div>
                <p>@bader · محقّق مستقل</p>
              </div>
            </div>

            <div className="vip-profile-details">
              <p>أبحث عن الحكاية الكاملة خلف كل تفصيل صغير.</p>
              <div className="vip-profile-stats"><span>٤ ملفات</span><span>١٢ دليلًا</span><span>منذ ٢٠٢٤</span></div>
            </div>
          </article>

          <div aria-label="دليل ألوان شارة التوثيق" className="vip-badge-policy">
            <span><PreviewBadge kind="vip" /> أزرق: لمشتركي VIP (معاينة)</span>
            <span><PreviewBadge kind="admin" /> ذهبي: role=admin فقط، لا staff</span>
          </div>
        </section>

        <aside aria-labelledby="vip-offer-title" className="vip-offer">
          <div className="vip-offer__icon"><Crown aria-hidden="true" size={21} /></div>
          <h2 id="vip-offer-title">تصوّر باقة VIP</h2>
          <p className="vip-offer__description">مساحة أوسع لتخصيص شكل ملفك.</p>
          <div className="vip-offer__price-row">
            <strong dir="ltr">14.99</strong>
            <span>ر.س <small>/ شهر</small></span>
          </div>
          <span className="vip-proposed-label">سعر مقترح</span>
          <ul className="vip-offer__features">
            <li><Check aria-hidden="true" size={16} /> سمات وإطارات متنوعة</li>
            <li><Check aria-hidden="true" size={16} /> بنر ثابت أو متحرك من صورك</li>
            <li><Check aria-hidden="true" size={16} /> تصور شارة زرقاء لمشترك VIP</li>
          </ul>
          <p className="vip-offer__footnote">هذا تصوّر غير مفعّل. لا يوجد دفع أو اشتراك من هذه الصفحة.</p>
        </aside>
      </div>

      <section aria-labelledby="vip-customize-heading" className="vip-editor">
        <div className="vip-editor__heading">
          <div>
            <h2 id="vip-customize-heading">خيارات التخصيص</h2>
            <p>غيّر أي خيار لترى أثره في المعاينة أعلاه.</p>
          </div>
          <span><Sparkles aria-hidden="true" size={16} /> اختيارات تجريبية</span>
        </div>

        <section aria-labelledby="vip-theme-heading" className="vip-editor-section">
          <div className="vip-editor-section__title">
            <div><h3 id="vip-theme-heading">السمات</h3><p>لوحة ألوان ملفك</p></div>
            <span>{activeTheme.label}</span>
          </div>
          <div className="vip-theme-grid">
            {themes.map((theme) => (
              <button
                aria-pressed={themeId === theme.id}
                className={`vip-theme-choice${themeId === theme.id ? " is-selected" : ""}`}
                key={theme.id}
                onClick={() => setThemeId(theme.id)}
                type="button"
              >
                <span aria-hidden="true" className="vip-theme-choice__swatches">
                  <i style={{ backgroundColor: theme.surface }} />
                  <i style={{ backgroundColor: theme.accent }} />
                  <i style={{ backgroundColor: theme.cover }} />
                </span>
                <span>{theme.label}</span>
                {themeId === theme.id && <Check aria-hidden="true" className="vip-choice-check" size={16} />}
              </button>
            ))}
          </div>
        </section>

        <section aria-labelledby="vip-frames-heading" className="vip-editor-section">
          <div className="vip-editor-section__title">
            <div><h3 id="vip-frames-heading">إطارات الصورة</h3><p>اختر تفصيلًا يميّز صورتك</p></div>
            <span>{frames.find((frame) => frame.id === frameStyle)?.label}</span>
          </div>
          <div className="vip-frame-grid">
            {frames.map((frame) => (
              <button
                aria-pressed={frameStyle === frame.id}
                className={`vip-frame-choice${frameStyle === frame.id ? " is-selected" : ""}`}
                key={frame.id}
                onClick={() => setFrameStyle(frame.id)}
                type="button"
              >
                <span className={`vip-avatar-frame vip-avatar-frame--${frame.id}`} aria-hidden="true">
                  <span className="vip-avatar">ب</span>
                </span>
                <span>{frame.label}</span>
                {frameStyle === frame.id && <Check aria-hidden="true" className="vip-choice-check" size={16} />}
              </button>
            ))}
          </div>
        </section>

        <section aria-labelledby="vip-banner-heading" className="vip-editor-section vip-banner-editor">
          <div className="vip-editor-section__title">
            <div><h3 id="vip-banner-heading">بنر الملف</h3><p>اختر صورة من مكتبة الصور أو الملفات على جهازك.</p></div>
          </div>

          <div aria-label="نوع البنر" className="vip-banner-tabs">
            <button aria-pressed={mode === "static"} className={mode === "static" ? "is-active" : ""} onClick={() => { setMode("static"); setError(""); setNotice(""); }} type="button">
              <ImagePlus aria-hidden="true" size={17} /> ثابت
            </button>
            <button aria-pressed={mode === "motion"} className={mode === "motion" ? "is-active" : ""} onClick={() => { setMode("motion"); setError(""); setNotice(""); }} type="button">
              <Sparkles aria-hidden="true" size={17} /> متحرك
            </button>
          </div>

          <div className="vip-upload-row">
            <label className="vip-upload-button" htmlFor="vip-banner-file">
              <Upload aria-hidden="true" size={18} />
              <span>{activeBanner ? "اختيار صورة أخرى" : "اختيار صورة من الجهاز"}</span>
              <input
                accept={mode === "static" ? "image/jpeg,image/png,image/webp,image/avif" : "image/gif,image/apng,image/webp"}
                className="vip-file-input"
                id="vip-banner-file"
                onChange={selectBanner}
                type="file"
              />
            </label>
            {activeBanner && (
              <button className="vip-clear-button" onClick={clearBanner} type="button">
                <X aria-hidden="true" size={16} /> إزالة
              </button>
            )}
          </div>
          <p className="vip-file-help">
            {mode === "static" ? "JPG أو PNG أو WebP أو AVIF · حتى 12 ميغابايت" : "GIF أو APNG أو WebP متحرك · حتى 12 ميغابايت"}
          </p>

          {activeBanner && (
            <div className="vip-crop-editor">
              <div className="vip-crop-editor__heading">
                <div><h4>قصّ البنر</h4><p>حرّك نقطة التركيز وقرّب الصورة؛ المعاينة أعلاه تتحدث فورًا.</p></div>
                <button aria-label="إعادة ضبط القص" className="vip-reset-crop" onClick={() => setCrops((current) => ({ ...current, [mode]: { ...initialCrops[mode] } }))} type="button">
                  <RotateCcw aria-hidden="true" size={16} /> إعادة ضبط
                </button>
              </div>
              <div
                aria-label="معاينة القص"
                className="vip-crop-preview"
                role="img"
                style={coverRatio ? { aspectRatio: coverRatio.toFixed(6), height: "auto" } : undefined}
              >
                <Image alt="" fill sizes="(max-width: 680px) 100vw, 1000px" src={activeBanner.url} style={bannerImageStyle} unoptimized />
                <span aria-hidden="true" className="vip-crop-preview__safe-area" />
              </div>
              <div className="vip-crop-controls">
                <label>
                  <span>الموضع الأفقي <b>{activeCrop.x}%</b></span>
                  <input aria-label="الموضع الأفقي للقص" max="100" min="0" onChange={(event) => updateCrop("x", Number(event.currentTarget.value))} type="range" value={activeCrop.x} />
                </label>
                <label>
                  <span>الموضع العمودي <b>{activeCrop.y}%</b></span>
                  <input aria-label="الموضع العمودي للقص" max="100" min="0" onChange={(event) => updateCrop("y", Number(event.currentTarget.value))} type="range" value={activeCrop.y} />
                </label>
                <label>
                  <span>التقريب <b>{activeCrop.zoom}%</b></span>
                  <input aria-label="تقريب صورة البنر" max="180" min="100" onChange={(event) => updateCrop("zoom", Number(event.currentTarget.value))} step="5" type="range" value={activeCrop.zoom} />
                </label>
              </div>
              <p className="vip-selected-file" title={activeBanner.file.name}>{activeBanner.file.name}</p>
            </div>
          )}

          {error && <p className="vip-feedback vip-feedback--error" role="alert">{error}</p>}
          {notice && !error && <p className="vip-feedback" role="status">{notice}</p>}
        </section>
      </section>

      <p className="vip-local-disclaimer"><ShieldCheck aria-hidden="true" size={17} /> شارة VIP هنا للعرض فقط إلى أن يكتمل التحقق الخلفي، ولا تثبت استحقاقًا فعليًا. الشارة الذهبية مخصصة لـ role=admin فقط وليست لـ staff. اختيار الصور والقصّ محليان؛ لا تُرفع الصور ولا تُحفَظ على الخادم.</p>
    </div>
  );
}
