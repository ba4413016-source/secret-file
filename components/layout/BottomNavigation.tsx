"use client";

import { motion } from "framer-motion";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { navigationItems } from "@/lib/navigation";

export function BottomNavigation() {
  const pathname = usePathname();

  return (
    <div className="bottom-nav-wrap">
      <nav aria-label="التنقل الرئيسي" className="bottom-nav">
        {navigationItems.map(({ href, icon: Icon, label }) => {
          const active = href === "/" ? pathname === "/" : pathname.startsWith(href);

          return (
            <Link
              aria-current={active ? "page" : undefined}
              className="bottom-nav__link"
              href={href}
              key={href}
            >
              {active && (
                <motion.span
                  aria-hidden="true"
                  className="bottom-nav__indicator"
                  layoutId="active-navigation-indicator"
                  transition={{ duration: 0.2, ease: "easeOut" }}
                />
              )}
              <Icon aria-hidden="true" size={21} strokeWidth={active ? 2.1 : 1.8} />
              <span className="bottom-nav__label">{label}</span>
            </Link>
          );
        })}
      </nav>
    </div>
  );
}
