import type { Metadata, Viewport } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: {
    default: "ملف غامض",
    template: "%s | ملف غامض",
  },
  description: "منصة تحقيق تفاعلية عربية. هذه النسخة واجهة محلية تجريبية.",
  applicationName: "ملف غامض",
  icons: {
    icon: "/icons/brand-mark.svg",
  },
};

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  maximumScale: 1,
  userScalable: false,
  viewportFit: "cover",
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="ar" dir="rtl">
      <body>{children}</body>
    </html>
  );
}
