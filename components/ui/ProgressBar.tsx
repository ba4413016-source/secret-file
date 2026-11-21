import type { CSSProperties } from "react";

type ProgressBarProps = {
  value: number;
  label: string;
};

export function ProgressBar({ value, label }: ProgressBarProps) {
  const safeValue = Math.min(100, Math.max(0, value));
  const style = { "--progress-value": `${safeValue}%` } as CSSProperties;

  return (
    <div
      aria-label={label}
      aria-valuemax={100}
      aria-valuemin={0}
      aria-valuenow={safeValue}
      className="progress-track"
      role="progressbar"
      style={style}
    >
      <div className="progress-track__fill" />
    </div>
  );
}
