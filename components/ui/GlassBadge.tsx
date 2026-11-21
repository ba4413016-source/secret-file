import type { HTMLAttributes, ReactNode } from "react";

type GlassBadgeProps = HTMLAttributes<HTMLSpanElement> & {
  variant?: "neutral" | "gold" | "blood" | "cyan";
  children: ReactNode;
};

export function GlassBadge({
  variant = "neutral",
  className = "",
  children,
  ...props
}: GlassBadgeProps) {
  return (
    <span className={`glass-badge glass-badge--${variant} ${className}`.trim()} {...props}>
      {children}
    </span>
  );
}
