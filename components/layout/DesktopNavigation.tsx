"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { navigationItems } from "@/lib/navigation";

export function DesktopNavigation() {
  const pathname = usePathname();

  return (
    <nav aria-label="التنقل الرئيسي" className="desktop-nav">
      {navigationItems.map(({ href, icon: Icon, label }) => {
        const active = href === "/" ? pathname === "/" : pathname.startsWith(href);

        return (
          <Link
            aria-current={active ? "page" : undefined}
            className="desktop-nav__link"
            href={href}
            key={href}
          >
            <Icon aria-hidden="true" size={17} strokeWidth={1.9} />
            <span>{label}</span>
          </Link>
        );
      })}
    </nav>
  );
}
