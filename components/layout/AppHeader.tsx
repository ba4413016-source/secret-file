import Link from "next/link";
import { Search } from "lucide-react";
import { BrandLink } from "@/components/brand/BrandLink";
import { DesktopNavigation } from "@/components/layout/DesktopNavigation";

export function AppHeader() {
  return (
    <header className="app-header">
      <div className="app-header__inner">
        <BrandLink />
        <DesktopNavigation />
        <div className="header-actions">
          <span className="header-local-badge">نسخة تجريبية</span>
          <Link
            aria-label="اذهب إلى البحث"
            className="header-search-link"
            href="/search"
          >
            <Search aria-hidden="true" size={19} />
          </Link>
        </div>
      </div>
    </header>
  );
}
