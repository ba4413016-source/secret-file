import type { ReactNode } from "react";
import { AppHeader } from "@/components/layout/AppHeader";
import { BottomNavigation } from "@/components/layout/BottomNavigation";

export default function MainLayout({ children }: Readonly<{ children: ReactNode }>) {
  return (
    <div className="app-frame">
      <a className="skip-link" href="#main-content">
        تخطَّ إلى المحتوى
      </a>
      <AppHeader />
      <main className="main-scroll" id="main-content" tabIndex={-1}>
        {children}
      </main>
      <BottomNavigation />
    </div>
  );
}
