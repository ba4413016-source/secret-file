import { BadgeCheck } from "lucide-react";

type VerifiedBadgeProps = {
  size?: "xs" | "sm" | "md" | "lg";
};

const sizeMap = {
  xs: 12,
  sm: 16,
  md: 20,
  lg: 28,
} as const;

export function VerifiedBadge({ size = "sm" }: VerifiedBadgeProps) {
  return (
    <BadgeCheck
      aria-label="حساب موثق"
      className="verified-badge"
      role="img"
      size={sizeMap[size]}
    />
  );
}
