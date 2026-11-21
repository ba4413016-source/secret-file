-- Fictional, non-sensitive development fixtures only.
-- No auth.users rows, user accounts, passwords, emails, tokens, or real-case data.

insert into public.cases (
  id, slug, title, synopsis, category, difficulty, estimated_minutes, tags,
  status, is_fictional, published_at
) values
  (
    '10000000-0000-4000-8000-000000000001',
    'the-last-lantern',
    'الفانوس الأخير',
    'في مسرح خيالي أُغلق منذ سنوات، ينطفئ فانوس العرض قبل العثور على رسالة مجهولة. حلّ القضية بالاعتماد على القرائن المنشورة فقط.',
    'theatrical', 'beginner', 15, array['fictional', 'demo', 'stage'],
    'published', true, now()
  ),
  (
    '10000000-0000-4000-8000-000000000002',
    'midnight-observatory',
    'مرصد منتصف الليل',
    'تختفي خريطة فلكية من مرصد خيالي خلال انقطاع قصير للكهرباء. افحص التوقيت وآثار الحركة قبل تكوين نظريتك.',
    'historical', 'easy', 20, array['fictional', 'demo', 'observatory'],
    'published', true, now()
  )
on conflict (id) do update set
  slug = excluded.slug,
  title = excluded.title,
  synopsis = excluded.synopsis,
  category = excluded.category,
  difficulty = excluded.difficulty,
  estimated_minutes = excluded.estimated_minutes,
  tags = excluded.tags,
  status = excluded.status,
  is_fictional = excluded.is_fictional,
  published_at = excluded.published_at;

insert into public.case_suspects (id, case_id, slug, name, description, sort_order) values
  ('20000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', 'stage-manager', 'مدير الخشبة', 'كان يتابع تجهيزات المسرح قبل العرض التجريبي.', 1),
  ('20000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000001', 'prop-keeper', 'مسؤول الإكسسوارات', 'يعرف مواقع الأدوات ومواعيد نقلها.', 2),
  ('20000000-0000-4000-8000-000000000003', '10000000-0000-4000-8000-000000000002', 'night-keeper', 'حارس المرصد', 'سجّل ملاحظات عن انقطاع الكهرباء في دفتر المناوبة.', 1),
  ('20000000-0000-4000-8000-000000000004', '10000000-0000-4000-8000-000000000002', 'guest-researcher', 'باحثة زائرة', 'كانت تعمل في قاعة الخرائط وقت إغلاق المرصد.', 2)
on conflict (id) do update set
  case_id = excluded.case_id,
  slug = excluded.slug,
  name = excluded.name,
  description = excluded.description,
  sort_order = excluded.sort_order;

insert into public.case_evidence (
  id, case_id, slug, title, summary, body, evidence_type, sort_order
) values
  (
    '30000000-0000-4000-8000-000000000001',
    '10000000-0000-4000-8000-000000000001',
    'lighting-log', 'سجل الإضاءة', 'ملاحظة قصيرة من سجل تجريبي.',
    'يُظهر السجل أن مفتاح الإضاءة اليدوي فُحص قبل بدء العرض التجريبي بعشر دقائق.',
    'document', 1
  ),
  (
    '30000000-0000-4000-8000-000000000002',
    '10000000-0000-4000-8000-000000000001',
    'dust-mark', 'أثر غبار', 'أثر خيالي على صندوق الفانوس.',
    'يمتد الأثر باتجاه الرف الجانبي ولا يحمل علامة تعريف شخصية.',
    'object', 2
  ),
  (
    '30000000-0000-4000-8000-000000000003',
    '10000000-0000-4000-8000-000000000002',
    'power-note', 'تدوين انقطاع الكهرباء', 'توقيت مسجل في دفتر المناوبة.',
    'يسجل الدفتر انقطاعًا قصيرًا للكهرباء عند منتصف الليل، ثم عودة التيار بعد دقائق.',
    'document', 1
  ),
  (
    '30000000-0000-4000-8000-000000000004',
    '10000000-0000-4000-8000-000000000002',
    'map-sleeve', 'غلاف الخريطة', 'غلاف ورقي وُجد قرب طاولة القراءة.',
    'الغلاف سليم ولا يحتوي على اسم أو معلومة شخصية.',
    'object', 2
  )
on conflict (id) do update set
  case_id = excluded.case_id,
  slug = excluded.slug,
  title = excluded.title,
  summary = excluded.summary,
  body = excluded.body,
  evidence_type = excluded.evidence_type,
  sort_order = excluded.sort_order;

insert into public.case_solutions (case_id, culprit_suspect_id, explanation, reveal_data)
values
  (
    '10000000-0000-4000-8000-000000000001',
    '20000000-0000-4000-8000-000000000002',
    'في النسخة التجريبية الخيالية، يفسّر ترتيب سجل الإضاءة وأثر الغبار أن مسؤول الإكسسوارات نقل الفانوس لإخفاء خلل في التجهيز.',
    '{"demo": true, "fictional": true}'::jsonb
  ),
  (
    '10000000-0000-4000-8000-000000000002',
    '20000000-0000-4000-8000-000000000003',
    'في النسخة التجريبية الخيالية، يطابق توقيت سجل المناوبة حركة الحارس خلال فترة انقطاع الكهرباء.',
    '{"demo": true, "fictional": true}'::jsonb
  )
on conflict (case_id) do update set
  culprit_suspect_id = excluded.culprit_suspect_id,
  explanation = excluded.explanation,
  reveal_data = excluded.reveal_data;

insert into public.achievements (code, title, description, category, criteria)
values
  ('first_case_started', 'بداية التحقيق', 'ابدأ قضية تجريبية واحدة.', 'foundation', '{"cases_started": 1}'::jsonb),
  ('evidence_reader', 'قارئ الأدلة', 'افتح دليلين في قضية خيالية.', 'evidence', '{"evidence_opened": 2}'::jsonb),
  ('theory_writer', 'صاحب نظرية', 'اكتب نظرية تجريبية بعد بدء قضية.', 'community', '{"theories_created": 1}'::jsonb)
on conflict (code) do update set
  title = excluded.title,
  description = excluded.description,
  category = excluded.category,
  criteria = excluded.criteria,
  is_active = true;

insert into public.daily_challenges (challenge_date, case_id, title, description, rules)
values (
  current_date,
  '10000000-0000-4000-8000-000000000001',
  'تحدي القرينة الواحدة',
  'تحدٍ محلي خيالي: راجع قرينة واحدة قبل كتابة استنتاجك.',
  '{"demo": true, "fictional": true, "max_hints": 0}'::jsonb
)
on conflict (challenge_date) do update set
  case_id = excluded.case_id,
  title = excluded.title,
  description = excluded.description,
  rules = excluded.rules,
  is_active = true;
