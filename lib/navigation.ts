import {
  FolderSearch,
  Home,
  Search,
  Settings,
  UserRound,
  type LucideIcon,
} from "lucide-react";

export type NavigationItem = {
  href: string;
  label: string;
  icon: LucideIcon;
};

export const navigationItems: NavigationItem[] = [
  { href: "/", label: "الرئيسية", icon: Home },
  { href: "/cases", label: "القضايا", icon: FolderSearch },
  { href: "/search", label: "البحث", icon: Search },
  { href: "/profile/me", label: "الشخصية", icon: UserRound },
  { href: "/settings", label: "الإعدادات", icon: Settings },
];
