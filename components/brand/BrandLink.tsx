import Image from "next/image";
import Link from "next/link";

export function BrandLink() {
  return (
    <Link aria-label="ملف غامض، الرئيسية" className="brand-link" href="/">
      <Image alt="" height={40} priority src="/icons/brand-mark.svg" width={40} />
      <span className="brand-wordmark">
        <strong>ملف غامض</strong>
        <span>منصة التحقيق</span>
      </span>
    </Link>
  );
}
