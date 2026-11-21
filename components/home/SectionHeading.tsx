type SectionHeadingProps = {
  title: string;
  description?: string;
  id?: string;
};

export function SectionHeading({ title, description, id }: SectionHeadingProps) {
  return (
    <div className="section-heading">
      <div>
        <h2 id={id}>{title}</h2>
        {description && <p>{description}</p>}
      </div>
    </div>
  );
}
