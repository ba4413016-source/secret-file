import type { HTMLAttributes } from "react";

type GlassSurfaceProps = HTMLAttributes<HTMLDivElement> & {
  intensity?: "light" | "medium";
};

export function GlassSurface({
  intensity = "light",
  className = "",
  ...props
}: GlassSurfaceProps) {
  return <div className={`glass-surface glass-surface--${intensity} ${className}`.trim()} {...props} />;
}
