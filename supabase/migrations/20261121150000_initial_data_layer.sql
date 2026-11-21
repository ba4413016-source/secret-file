-- Secret File: initial data layer (PostgreSQL 15+ / Supabase)
-- Client access is granted per table/column and then constrained by RLS.
-- Passwords, email addresses, and provider tokens are deliberately not stored here.

begin;

create type public.account_role as enum ('user', 'lawyer', 'verified', 'admin', 'staff');
create type public.investigator_rank as enum ('trainee', 'detective', 'senior_detective', 'expert_detective', 'legend');
create type public.profile_visibility as enum ('public', 'investigators', 'followers', 'private');
create type public.message_privacy as enum ('everyone', 'investigators', 'followers', 'nobody');
create type public.app_locale as enum ('ar', 'en', 'system');
create type public.theme_preference as enum ('dark', 'amoled', 'system');
create type public.case_category as enum (
  'mansion', 'street', 'missing_person', 'financial', 'art', 'cyber',
  'cold_case', 'psychological', 'theatrical', 'locked_room', 'supernatural', 'historical'
);
create type public.case_difficulty as enum ('beginner', 'easy', 'medium', 'hard', 'very_hard', 'monster');
create type public.case_status as enum ('draft', 'pending_review', 'published', 'archived');
create type public.progress_status as enum ('in_progress', 'completed', 'abandoned');
create type public.evidence_kind as enum ('document', 'photo', 'audio', 'object', 'statement', 'other');
create type public.theory_status as enum ('pending', 'approved', 'rejected');
create type public.request_status as enum ('pending', 'accepted', 'declined', 'cancelled');
create type public.conversation_status as enum ('active', 'closed');
create type public.report_reason as enum ('harassment', 'spam', 'impersonation', 'unsafe_content', 'other');
create type public.report_status as enum ('pending', 'reviewed', 'actioned', 'dismissed');
create type public.season_status as enum ('planned', 'active', 'completed');

-- Public-facing profile data only. Authentication identifiers live in auth.users;
-- email/password/provider data is never copied into this table.
create table public.users (
  id uuid primary key references auth.users (id) on delete cascade,
  username text not null unique check (username ~ '^[a-z0-9_]{3,32}$'),
  display_name text not null default 'محقق جديد' check (char_length(btrim(display_name)) between 1 and 60),
  bio text not null default '' check (char_length(bio) <= 160),
  avatar_path text,
  banner_path text,
  role public.account_role not null default 'user',
  is_verified boolean not null default false,
  rank public.investigator_rank not null default 'trainee',
  xp bigint not null default 0 check (xp >= 0),
  lawyer_specialty text check (lawyer_specialty is null or char_length(lawyer_specialty) <= 80),
  lawyer_years_experience integer check (lawyer_years_experience is null or lawyer_years_experience between 0 and 80),
  lawyer_license_verified boolean not null default false,
  profile_visibility public.profile_visibility not null default 'public',
  message_privacy public.message_privacy not null default 'followers',
  show_activity boolean not null default true,
  show_statistics boolean not null default true,
  show_socials boolean not null default true,
  locale public.app_locale not null default 'ar',
  theme public.theme_preference not null default 'dark',
  last_username_change_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint users_lawyer_fields_match_role check (
    role = 'lawyer' or (lawyer_specialty is null and lawyer_years_experience is null and not lawyer_license_verified)
  )
);

create table public.user_follows (
  follower_id uuid not null default auth.uid() references public.users (id) on delete cascade,
  followed_id uuid not null references public.users (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (follower_id, followed_id),
  constraint user_follows_not_self check (follower_id <> followed_id)
);

create table public.user_blocks (
  blocker_id uuid not null default auth.uid() references public.users (id) on delete cascade,
  blocked_id uuid not null references public.users (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (blocker_id, blocked_id),
  constraint user_blocks_not_self check (blocker_id <> blocked_id)
);

create table public.social_links (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references public.users (id) on delete cascade,
  platform text not null check (platform in ('website', 'x', 'instagram', 'youtube', 'tiktok', 'linkedin', 'github', 'other')),
  url text not null check (url ~ '^https://[^[:space:]]+$' and char_length(url) <= 2048),
  created_at timestamptz not null default now(),
  unique (user_id, platform)
);

create table public.cases (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$' and char_length(slug) <= 100),
  title text not null check (char_length(btrim(title)) between 1 and 140),
  synopsis text not null check (char_length(synopsis) <= 2000),
  category public.case_category not null,
  difficulty public.case_difficulty not null default 'beginner',
  estimated_minutes smallint not null default 15 check (estimated_minutes between 1 and 600),
  tags text[] not null default '{}',
  status public.case_status not null default 'pending_review',
  is_fictional boolean not null default true,
  created_by uuid default auth.uid() references public.users (id) on delete set null,
  published_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint cases_publication_time check (status <> 'published' or published_at is not null)
);

create table public.case_suspects (
  id uuid primary key default gen_random_uuid(),
  case_id uuid not null references public.cases (id) on delete cascade,
  slug text not null check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$' and char_length(slug) <= 80),
  name text not null check (char_length(btrim(name)) between 1 and 100),
  description text not null default '' check (char_length(description) <= 3000),
  is_person_of_interest boolean not null default true,
  sort_order smallint not null default 0,
  created_at timestamptz not null default now(),
  unique (case_id, slug),
  unique (id, case_id)
);

create table public.case_evidence (
  id uuid primary key default gen_random_uuid(),
  case_id uuid not null references public.cases (id) on delete cascade,
  slug text not null check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$' and char_length(slug) <= 80),
  title text not null check (char_length(btrim(title)) between 1 and 140),
  summary text not null default '' check (char_length(summary) <= 1000),
  body text not null default '' check (char_length(body) <= 10000),
  evidence_type public.evidence_kind not null default 'document',
  storage_path text,
  sort_order smallint not null default 0,
  created_at timestamptz not null default now(),
  unique (case_id, slug),
  unique (id, case_id)
);

-- Solutions are stored separately from public case content and revealed only
-- after a signed-in player completes the corresponding case.
create table public.case_solutions (
  id uuid primary key default gen_random_uuid(),
  case_id uuid not null unique references public.cases (id) on delete cascade,
  culprit_suspect_id uuid,
  explanation text not null check (char_length(explanation) between 1 and 12000),
  reveal_data jsonb not null default '{}'::jsonb check (jsonb_typeof(reveal_data) = 'object'),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint case_solution_suspect_same_case
    foreign key (culprit_suspect_id, case_id)
    references public.case_suspects (id, case_id) on delete set null (culprit_suspect_id)
);

create table public.case_progress (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references public.users (id) on delete cascade,
  case_id uuid not null references public.cases (id) on delete cascade,
  status public.progress_status not null default 'in_progress',
  current_stage smallint not null default 1 check (current_stage between 1 and 10),
  client_state jsonb not null default '{}'::jsonb check (jsonb_typeof(client_state) = 'object'),
  score integer not null default 0 check (score >= 0),
  hints_used smallint not null default 0 check (hints_used >= 0),
  mistakes smallint not null default 0 check (mistakes >= 0),
  started_at timestamptz not null default now(),
  completed_at timestamptz,
  updated_at timestamptz not null default now(),
  unique (user_id, case_id)
);

create table public.user_notes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references public.users (id) on delete cascade,
  case_id uuid not null references public.cases (id) on delete cascade,
  title text not null default '' check (char_length(title) <= 120),
  content text not null default '' check (char_length(content) <= 20000),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.clue_connections (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references public.users (id) on delete cascade,
  case_id uuid not null references public.cases (id) on delete cascade,
  source_evidence_id uuid not null,
  target_evidence_id uuid not null,
  relation text not null default 'related' check (char_length(btrim(relation)) between 1 and 80),
  created_at timestamptz not null default now(),
  constraint clue_connections_not_self check (source_evidence_id <> target_evidence_id),
  constraint clue_connections_source_same_case
    foreign key (source_evidence_id, case_id) references public.case_evidence (id, case_id) on delete cascade,
  constraint clue_connections_target_same_case
    foreign key (target_evidence_id, case_id) references public.case_evidence (id, case_id) on delete cascade,
  unique (user_id, case_id, source_evidence_id, target_evidence_id)
);

create table public.achievements (
  code text primary key check (code ~ '^[a-z0-9]+(_[a-z0-9]+)*$' and char_length(code) <= 80),
  title text not null check (char_length(btrim(title)) between 1 and 100),
  description text not null default '' check (char_length(description) <= 500),
  category text not null check (char_length(category) between 1 and 60),
  criteria jsonb not null default '{}'::jsonb check (jsonb_typeof(criteria) = 'object'),
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table public.user_achievements (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users (id) on delete cascade,
  achievement_code text not null references public.achievements (code) on delete cascade,
  source_case_id uuid references public.cases (id) on delete set null,
  awarded_at timestamptz not null default now(),
  unique (user_id, achievement_code)
);

create table public.theories (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references public.users (id) on delete cascade,
  case_id uuid not null references public.cases (id) on delete cascade,
  title text not null check (char_length(btrim(title)) between 1 and 120),
  body text not null check (char_length(btrim(body)) between 1 and 8000),
  status public.theory_status not null default 'pending',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.theory_votes (
  id uuid primary key default gen_random_uuid(),
  theory_id uuid not null references public.theories (id) on delete cascade,
  user_id uuid not null default auth.uid() references public.users (id) on delete cascade,
  value smallint not null check (value in (-1, 1)),
  created_at timestamptz not null default now(),
  unique (theory_id, user_id)
);

create table public.theory_comments (
  id uuid primary key default gen_random_uuid(),
  theory_id uuid not null references public.theories (id) on delete cascade,
  user_id uuid not null default auth.uid() references public.users (id) on delete cascade,
  body text not null check (char_length(btrim(body)) between 1 and 4000),
  status public.theory_status not null default 'pending',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.leaderboard_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users (id) on delete cascade,
  scope text not null check (scope in ('all_time', 'weekly', 'monthly', 'season')),
  period_start date not null,
  score bigint not null check (score >= 0),
  rank_position integer not null check (rank_position > 0),
  generated_at timestamptz not null default now(),
  unique (user_id, scope, period_start)
);

create table public.daily_challenges (
  id uuid primary key default gen_random_uuid(),
  challenge_date date not null unique,
  case_id uuid references public.cases (id) on delete set null,
  title text not null check (char_length(btrim(title)) between 1 and 120),
  description text not null default '' check (char_length(description) <= 1000),
  rules jsonb not null default '{}'::jsonb check (jsonb_typeof(rules) = 'object'),
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table public.mystery_boxes (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$' and char_length(slug) <= 80),
  title text not null check (char_length(btrim(title)) between 1 and 100),
  rarity text not null check (rarity in ('common', 'rare', 'epic', 'legendary')),
  reward_pool jsonb not null default '[]'::jsonb check (jsonb_typeof(reward_pool) = 'array'),
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table public.user_rewards (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users (id) on delete cascade,
  mystery_box_id uuid references public.mystery_boxes (id) on delete set null,
  reward_type text not null check (char_length(reward_type) between 1 and 60),
  reward_data jsonb not null default '{}'::jsonb check (jsonb_typeof(reward_data) = 'object'),
  earned_at timestamptz not null default now(),
  claimed_at timestamptz
);

create table public.seasons (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$' and char_length(slug) <= 80),
  title text not null check (char_length(btrim(title)) between 1 and 120),
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  status public.season_status not null default 'planned',
  created_at timestamptz not null default now(),
  check (ends_at > starts_at)
);

create table public.season_progress (
  id uuid primary key default gen_random_uuid(),
  season_id uuid not null references public.seasons (id) on delete cascade,
  user_id uuid not null references public.users (id) on delete cascade,
  xp bigint not null default 0 check (xp >= 0),
  tier integer not null default 0 check (tier >= 0),
  updated_at timestamptz not null default now(),
  unique (season_id, user_id)
);

create table public.conversations (
  id uuid primary key default gen_random_uuid(),
  participant_1_id uuid not null references public.users (id) on delete cascade,
  participant_2_id uuid not null references public.users (id) on delete cascade,
  status public.conversation_status not null default 'active',
  last_message_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint conversations_distinct_participants check (participant_1_id < participant_2_id),
  unique (participant_1_id, participant_2_id)
);

create table public.message_requests (
  id uuid primary key default gen_random_uuid(),
  sender_id uuid not null default auth.uid() references public.users (id) on delete cascade,
  receiver_id uuid not null references public.users (id) on delete cascade,
  first_message text not null check (char_length(btrim(first_message)) between 1 and 2000),
  status public.request_status not null default 'pending',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint message_requests_distinct_users check (sender_id <> receiver_id)
);

create table public.messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.conversations (id) on delete cascade,
  sender_id uuid not null default auth.uid() references public.users (id) on delete cascade,
  content text not null check (char_length(btrim(content)) between 1 and 4000),
  attachment_path text,
  read_at timestamptz,
  created_at timestamptz not null default now()
);

create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users (id) on delete cascade,
  notification_type text not null check (char_length(notification_type) between 1 and 60),
  title text not null check (char_length(btrim(title)) between 1 and 160),
  body text not null default '' check (char_length(body) <= 2000),
  data jsonb not null default '{}'::jsonb check (jsonb_typeof(data) = 'object'),
  read_at timestamptz,
  created_at timestamptz not null default now()
);

create table public.user_reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid not null default auth.uid() references public.users (id) on delete cascade,
  reported_user_id uuid not null references public.users (id) on delete cascade,
  reason public.report_reason not null,
  details text not null default '' check (char_length(details) <= 4000),
  status public.report_status not null default 'pending',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint user_reports_not_self check (reporter_id <> reported_user_id)
);

create table public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  actor_id uuid references public.users (id) on delete set null,
  action text not null check (char_length(action) between 1 and 100),
  entity_type text not null check (char_length(entity_type) between 1 and 100),
  entity_id uuid,
  metadata jsonb not null default '{}'::jsonb check (jsonb_typeof(metadata) = 'object'),
  created_at timestamptz not null default now()
);

-- Indexes support common ownership, moderation, feed, and rate-limit checks.
create index user_follows_followed_idx on public.user_follows (followed_id, follower_id);
create index user_blocks_blocked_idx on public.user_blocks (blocked_id, blocker_id);
create index cases_public_feed_idx on public.cases (status, published_at desc) where status = 'published';
create index case_suspects_case_order_idx on public.case_suspects (case_id, sort_order);
create index case_evidence_case_order_idx on public.case_evidence (case_id, sort_order);
create index case_progress_user_updated_idx on public.case_progress (user_id, updated_at desc);
create index user_notes_user_case_idx on public.user_notes (user_id, case_id, updated_at desc);
create index clue_connections_user_case_idx on public.clue_connections (user_id, case_id);
create index user_achievements_user_idx on public.user_achievements (user_id, awarded_at desc);
create index theories_case_status_idx on public.theories (case_id, status, created_at desc);
create index theory_comments_theory_status_idx on public.theory_comments (theory_id, status, created_at);
create index leaderboard_scope_period_rank_idx on public.leaderboard_entries (scope, period_start, rank_position);
create index daily_challenges_active_date_idx on public.daily_challenges (challenge_date desc) where is_active;
create index season_progress_user_idx on public.season_progress (user_id, season_id);
create index conversations_participant_2_idx on public.conversations (participant_2_id, last_message_at desc);
create index message_requests_receiver_status_idx on public.message_requests (receiver_id, status, created_at desc);
create unique index message_requests_one_pending_pair_idx on public.message_requests (sender_id, receiver_id) where status = 'pending';
create index messages_conversation_created_idx on public.messages (conversation_id, created_at desc);
create index messages_sender_created_idx on public.messages (sender_id, created_at desc);
create index notifications_user_created_idx on public.notifications (user_id, created_at desc);
create index user_reports_status_created_idx on public.user_reports (status, created_at desc);
create index audit_logs_entity_created_idx on public.audit_logs (entity_type, entity_id, created_at desc);

-- SECURITY DEFINER helpers have a fixed empty search_path and bypass RLS only
-- to evaluate narrow authorization predicates without policy recursion.
create or replace function public.touch_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $function$
begin
  new.updated_at := pg_catalog.now();
  return new;
end;
$function$;

create or replace function public.enforce_username_change()
returns trigger
language plpgsql
set search_path = ''
as $function$
begin
  if new.username is distinct from old.username then
    new.username := pg_catalog.lower(new.username);
    if new.username !~ '^[a-z0-9_]{3,32}$' then
      raise exception using errcode = '22023', message = 'username_format_invalid';
    end if;
    if old.last_username_change_at is not null
       and old.last_username_change_at > pg_catalog.now() - interval '6 months' then
      raise exception using errcode = '22023', message = 'username_change_cooldown';
    end if;
    new.last_username_change_at := pg_catalog.now();
  end if;
  return new;
end;
$function$;

create or replace function public.viewer_is_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
set row_security = off
as $function$
  select exists (
    select 1 from public.users u
    where u.id = (select auth.uid()) and u.role in ('admin', 'staff')
  );
$function$;

create or replace function public.can_view_profile(p_profile_id uuid)
returns boolean
language plpgsql
stable
security definer
set search_path = ''
set row_security = off
as $function$
declare
  v_viewer uuid := (select auth.uid());
  v_visibility public.profile_visibility;
begin
  if v_viewer is null or p_profile_id is null then
    return false;
  end if;
  if v_viewer = p_profile_id or public.viewer_is_admin() then
    return true;
  end if;
  if exists (
    select 1 from public.user_blocks b
    where (b.blocker_id = v_viewer and b.blocked_id = p_profile_id)
       or (b.blocker_id = p_profile_id and b.blocked_id = v_viewer)
  ) then
    return false;
  end if;
  select u.profile_visibility into v_visibility
  from public.users u where u.id = p_profile_id;
  if not found then
    return false;
  end if;
  if v_visibility = 'public' then
    return true;
  elsif v_visibility = 'investigators' then
    return exists (
      select 1 from public.users viewer
      where viewer.id = v_viewer
        and (viewer.rank <> 'trainee' or viewer.role in ('lawyer', 'verified', 'admin', 'staff'))
    );
  elsif v_visibility = 'followers' then
    return exists (
      select 1 from public.user_follows f
      where f.follower_id = v_viewer and f.followed_id = p_profile_id
    );
  end if;
  return false;
end;
$function$;

create or replace function public.can_view_social_links(p_profile_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
set row_security = off
as $function$
  select public.can_view_profile(p_profile_id)
    and exists (
      select 1 from public.users u
      where u.id = p_profile_id
        and (u.id = (select auth.uid()) or u.show_socials)
    );
$function$;

create or replace function public.get_my_profile_settings()
returns table (
  profile_visibility public.profile_visibility,
  message_privacy public.message_privacy,
  show_activity boolean,
  show_statistics boolean,
  show_socials boolean,
  locale public.app_locale,
  theme public.theme_preference
)
language sql
stable
security definer
set search_path = ''
set row_security = off
as $function$
  select u.profile_visibility, u.message_privacy, u.show_activity,
         u.show_statistics, u.show_socials, u.locale, u.theme
  from public.users u
  where u.id = (select auth.uid());
$function$;

create or replace function public.can_receive_message(p_receiver_id uuid)
returns boolean
language plpgsql
stable
security definer
set search_path = ''
set row_security = off
as $function$
declare
  v_sender_id uuid := (select auth.uid());
  v_privacy public.message_privacy;
begin
  if v_sender_id is null or p_receiver_id is null or v_sender_id = p_receiver_id then
    return false;
  end if;
  if exists (
    select 1 from public.user_blocks b
    where (b.blocker_id = v_sender_id and b.blocked_id = p_receiver_id)
       or (b.blocker_id = p_receiver_id and b.blocked_id = v_sender_id)
  ) then
    return false;
  end if;
  select u.message_privacy into v_privacy
  from public.users u where u.id = p_receiver_id;
  if not found then
    return false;
  end if;
  if v_privacy = 'everyone' then
    return true;
  elsif v_privacy = 'investigators' then
    return exists (
      select 1 from public.users sender
      where sender.id = v_sender_id
        and (sender.rank <> 'trainee' or sender.role in ('lawyer', 'verified', 'admin', 'staff'))
    );
  elsif v_privacy = 'followers' then
    return exists (
      select 1 from public.user_follows f
      where f.follower_id = v_sender_id and f.followed_id = p_receiver_id
    );
  end if;
  return false;
end;
$function$;

create or replace function public.is_conversation_participant(p_conversation_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
set row_security = off
as $function$
  select exists (
    select 1 from public.conversations c
    where c.id = p_conversation_id
      and (c.participant_1_id = (select auth.uid()) or c.participant_2_id = (select auth.uid()))
  );
$function$;

create or replace function public.can_send_message(p_conversation_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
set row_security = off
as $function$
  select exists (
    select 1
    from public.conversations c
    where c.id = p_conversation_id
      and c.status = 'active'
      and (c.participant_1_id = (select auth.uid()) or c.participant_2_id = (select auth.uid()))
      and not exists (
        select 1 from public.user_blocks b
        where (b.blocker_id = c.participant_1_id and b.blocked_id = c.participant_2_id)
           or (b.blocker_id = c.participant_2_id and b.blocked_id = c.participant_1_id)
      )
  );
$function$;

create or replace function public.enforce_message_daily_limit()
returns trigger
language plpgsql
security definer
set search_path = ''
set row_security = off
as $function$
declare
  v_utc_day date := (pg_catalog.timezone('UTC', pg_catalog.now()))::date;
  v_day_start timestamptz := ((pg_catalog.timezone('UTC', pg_catalog.now()))::date::timestamp at time zone 'UTC');
  v_count bigint;
begin
  if new.sender_id is null then
    raise exception using errcode = '23502', message = 'message_sender_required';
  end if;
  -- Serialize concurrent inserts by sender/day so parallel requests cannot pass 50.
  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(new.sender_id::text || ':' || v_utc_day::text, 0)
  );
  select count(*) into v_count
  from public.messages m
  where m.sender_id = new.sender_id
    and m.created_at >= v_day_start
    and m.created_at < v_day_start + interval '1 day';
  if v_count >= 50 then
    raise exception using errcode = 'P0001', message = 'daily_message_limit_exceeded';
  end if;
  return new;
end;
$function$;

create or replace function public.refresh_conversation_activity()
returns trigger
language plpgsql
security definer
set search_path = ''
set row_security = off
as $function$
begin
  update public.conversations
  set last_message_at = new.created_at, updated_at = pg_catalog.now()
  where id = new.conversation_id;
  return new;
end;
$function$;

create or replace function public.handle_new_auth_user()
returns trigger
language plpgsql
security definer
set search_path = ''
set row_security = off
as $function$
begin
  -- Never trust user metadata for role, verification, XP, or rank.
  insert into public.users (id, username, display_name)
  values (
    new.id,
    'd_' || pg_catalog.substr(pg_catalog.replace(new.id::text, '-', ''), 1, 30),
    'محقق جديد'
  );
  return new;
end;
$function$;

create trigger users_touch_updated_at before update on public.users
for each row execute function public.touch_updated_at();
create trigger users_enforce_username before update of username on public.users
for each row execute function public.enforce_username_change();
create trigger cases_touch_updated_at before update on public.cases
for each row execute function public.touch_updated_at();
create trigger case_progress_touch_updated_at before update on public.case_progress
for each row execute function public.touch_updated_at();
create trigger user_notes_touch_updated_at before update on public.user_notes
for each row execute function public.touch_updated_at();
create trigger case_solutions_touch_updated_at before update on public.case_solutions
for each row execute function public.touch_updated_at();
create trigger theories_touch_updated_at before update on public.theories
for each row execute function public.touch_updated_at();
create trigger theory_comments_touch_updated_at before update on public.theory_comments
for each row execute function public.touch_updated_at();
create trigger conversations_touch_updated_at before update on public.conversations
for each row execute function public.touch_updated_at();
create trigger message_requests_touch_updated_at before update on public.message_requests
for each row execute function public.touch_updated_at();
create trigger user_reports_touch_updated_at before update on public.user_reports
for each row execute function public.touch_updated_at();
create trigger messages_enforce_daily_limit before insert on public.messages
for each row execute function public.enforce_message_daily_limit();
create trigger messages_refresh_conversation after insert on public.messages
for each row execute function public.refresh_conversation_activity();
create trigger on_auth_user_created after insert on auth.users
for each row execute function public.handle_new_auth_user();

-- Remove the default PUBLIC execution grant from internal helpers. Grant only
-- the predicates needed by the corresponding RLS policies.
revoke all on function public.touch_updated_at() from public, anon, authenticated;
revoke all on function public.enforce_username_change() from public, anon, authenticated;
revoke all on function public.viewer_is_admin() from public, anon, authenticated;
revoke all on function public.can_view_profile(uuid) from public, anon, authenticated;
revoke all on function public.can_view_social_links(uuid) from public, anon, authenticated;
revoke all on function public.get_my_profile_settings() from public, anon, authenticated;
revoke all on function public.can_receive_message(uuid) from public, anon, authenticated;
revoke all on function public.is_conversation_participant(uuid) from public, anon, authenticated;
revoke all on function public.can_send_message(uuid) from public, anon, authenticated;
revoke all on function public.enforce_message_daily_limit() from public, anon, authenticated;
revoke all on function public.refresh_conversation_activity() from public, anon, authenticated;
revoke all on function public.handle_new_auth_user() from public, anon, authenticated;
grant execute on function public.can_view_profile(uuid) to anon, authenticated;
grant execute on function public.can_view_social_links(uuid) to anon, authenticated;
grant execute on function public.get_my_profile_settings() to authenticated;
grant execute on function public.viewer_is_admin() to anon, authenticated;
grant execute on function public.can_receive_message(uuid) to authenticated;
grant execute on function public.is_conversation_participant(uuid) to authenticated;
grant execute on function public.can_send_message(uuid) to authenticated;

-- Row Level Security: enable it on every application table.
alter table public.users enable row level security;
alter table public.user_follows enable row level security;
alter table public.user_blocks enable row level security;
alter table public.social_links enable row level security;
alter table public.cases enable row level security;
alter table public.case_suspects enable row level security;
alter table public.case_evidence enable row level security;
alter table public.case_solutions enable row level security;
alter table public.case_progress enable row level security;
alter table public.user_notes enable row level security;
alter table public.clue_connections enable row level security;
alter table public.achievements enable row level security;
alter table public.user_achievements enable row level security;
alter table public.theories enable row level security;
alter table public.theory_votes enable row level security;
alter table public.theory_comments enable row level security;
alter table public.leaderboard_entries enable row level security;
alter table public.daily_challenges enable row level security;
alter table public.mystery_boxes enable row level security;
alter table public.user_rewards enable row level security;
alter table public.seasons enable row level security;
alter table public.season_progress enable row level security;
alter table public.conversations enable row level security;
alter table public.message_requests enable row level security;
alter table public.messages enable row level security;
alter table public.notifications enable row level security;
alter table public.user_reports enable row level security;
alter table public.audit_logs enable row level security;

-- RLS policies for user/profile data.
create policy users_profile_read on public.users for select to anon, authenticated
using (public.can_view_profile(id));
create policy users_profile_update_self on public.users for update to authenticated
using (id = (select auth.uid()))
with check (id = (select auth.uid()));

create policy user_follows_read_participants on public.user_follows for select to authenticated
using (follower_id = (select auth.uid()) or followed_id = (select auth.uid()));
create policy user_follows_insert_self on public.user_follows for insert to authenticated
with check (
  follower_id = (select auth.uid()) and follower_id <> followed_id
  and not exists (
    select 1 from public.user_blocks b
    where (b.blocker_id = follower_id and b.blocked_id = followed_id)
       or (b.blocker_id = followed_id and b.blocked_id = follower_id)
  )
);
create policy user_follows_delete_self on public.user_follows for delete to authenticated
using (follower_id = (select auth.uid()));

create policy user_blocks_read_participants on public.user_blocks for select to authenticated
using (blocker_id = (select auth.uid()) or blocked_id = (select auth.uid()));
create policy user_blocks_insert_self on public.user_blocks for insert to authenticated
with check (blocker_id = (select auth.uid()) and blocker_id <> blocked_id);
create policy user_blocks_delete_self on public.user_blocks for delete to authenticated
using (blocker_id = (select auth.uid()));

create policy social_links_read_visible_profile on public.social_links for select to anon, authenticated
using (public.can_view_social_links(user_id));
create policy social_links_insert_self on public.social_links for insert to authenticated
with check (user_id = (select auth.uid()));
create policy social_links_update_self on public.social_links for update to authenticated
using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy social_links_delete_self on public.social_links for delete to authenticated
using (user_id = (select auth.uid()));

-- Public case content is readable only after publication. User submissions
-- start in pending_review and cannot publish themselves through client grants.
create policy cases_read_published on public.cases for select to anon, authenticated
using (status = 'published' or created_by = (select auth.uid()) or public.viewer_is_admin());
create policy cases_submit_fictional on public.cases for insert to authenticated
with check (
  created_by = (select auth.uid()) and status = 'pending_review'
  and is_fictional and published_at is null
);
create policy cases_update_own_pending on public.cases for update to authenticated
using (created_by = (select auth.uid()) and status = 'pending_review')
with check (created_by = (select auth.uid()) and status = 'pending_review' and is_fictional);
create policy cases_admin_manage on public.cases for all to authenticated
using (public.viewer_is_admin()) with check (public.viewer_is_admin());

create policy case_suspects_read_published on public.case_suspects for select to anon, authenticated
using (
  exists (select 1 from public.cases c where c.id = case_id and c.status = 'published')
  or public.viewer_is_admin()
);
create policy case_suspects_admin_manage on public.case_suspects for all to authenticated
using (public.viewer_is_admin()) with check (public.viewer_is_admin());

create policy case_evidence_read_published on public.case_evidence for select to anon, authenticated
using (
  exists (select 1 from public.cases c where c.id = case_id and c.status = 'published')
  or public.viewer_is_admin()
);
create policy case_evidence_admin_manage on public.case_evidence for all to authenticated
using (public.viewer_is_admin()) with check (public.viewer_is_admin());

create policy case_solutions_read_after_completion on public.case_solutions for select to authenticated
using (
  public.viewer_is_admin()
  or exists (
    select 1 from public.case_progress p
    where p.user_id = (select auth.uid()) and p.case_id = case_solutions.case_id and p.status = 'completed'
  )
);
create policy case_solutions_admin_manage on public.case_solutions for all to authenticated
using (public.viewer_is_admin()) with check (public.viewer_is_admin());

-- Client-owned progress is private. Score/status/timestamps are server-managed;
-- clients may only create an in-progress row and save the current UI state.
create policy case_progress_read_self on public.case_progress for select to authenticated
using (user_id = (select auth.uid()));
create policy case_progress_insert_self on public.case_progress for insert to authenticated
with check (
  user_id = (select auth.uid()) and status = 'in_progress' and score = 0
  and hints_used = 0 and mistakes = 0 and completed_at is null
  and exists (select 1 from public.cases c where c.id = case_id and c.status = 'published')
);
create policy case_progress_update_self on public.case_progress for update to authenticated
using (user_id = (select auth.uid()) and status = 'in_progress')
with check (user_id = (select auth.uid()) and status = 'in_progress');
create policy case_progress_delete_unfinished_self on public.case_progress for delete to authenticated
using (user_id = (select auth.uid()) and status = 'in_progress');

create policy user_notes_all_self on public.user_notes for all to authenticated
using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy clue_connections_all_self on public.clue_connections for all to authenticated
using (user_id = (select auth.uid()))
with check (
  user_id = (select auth.uid())
  and exists (
    select 1 from public.case_progress p
    where p.user_id = (select auth.uid()) and p.case_id = clue_connections.case_id
  )
);

create policy achievements_read_active on public.achievements for select to anon, authenticated
using (is_active or public.viewer_is_admin());
create policy achievements_admin_manage on public.achievements for all to authenticated
using (public.viewer_is_admin()) with check (public.viewer_is_admin());
create policy user_achievements_read_visible_profile on public.user_achievements for select to anon, authenticated
using (public.can_view_profile(user_id));
create policy user_achievements_admin_manage on public.user_achievements for all to authenticated
using (public.viewer_is_admin()) with check (public.viewer_is_admin());

create policy theories_read_approved_or_own on public.theories for select to anon, authenticated
using (status = 'approved' or user_id = (select auth.uid()) or public.viewer_is_admin());
create policy theories_insert_pending_self on public.theories for insert to authenticated
with check (
  user_id = (select auth.uid()) and status = 'pending'
  and exists (select 1 from public.cases c where c.id = case_id and c.status = 'published')
);
create policy theories_update_own_pending on public.theories for update to authenticated
using (user_id = (select auth.uid()) and status = 'pending')
with check (user_id = (select auth.uid()) and status = 'pending');
create policy theories_delete_own_pending on public.theories for delete to authenticated
using (user_id = (select auth.uid()) and status = 'pending');
create policy theories_admin_manage on public.theories for all to authenticated
using (public.viewer_is_admin()) with check (public.viewer_is_admin());

create policy theory_votes_read_self_or_admin on public.theory_votes for select to authenticated
using (user_id = (select auth.uid()) or public.viewer_is_admin());
create policy theory_votes_insert_on_others_approved on public.theory_votes for insert to authenticated
with check (
  user_id = (select auth.uid())
  and exists (
    select 1 from public.theories t
    where t.id = theory_id and t.status = 'approved' and t.user_id <> (select auth.uid())
  )
);
create policy theory_votes_update_self on public.theory_votes for update to authenticated
using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy theory_votes_delete_self on public.theory_votes for delete to authenticated
using (user_id = (select auth.uid()));

create policy theory_comments_read_approved_or_own on public.theory_comments for select to anon, authenticated
using (status = 'approved' or user_id = (select auth.uid()) or public.viewer_is_admin());
create policy theory_comments_insert_on_approved on public.theory_comments for insert to authenticated
with check (
  user_id = (select auth.uid()) and status = 'pending'
  and exists (
    select 1 from public.theories t
    where t.id = theory_id and t.status = 'approved' and t.user_id <> (select auth.uid())
  )
);
create policy theory_comments_update_own_pending on public.theory_comments for update to authenticated
using (user_id = (select auth.uid()) and status = 'pending')
with check (user_id = (select auth.uid()) and status = 'pending');
create policy theory_comments_delete_own_pending on public.theory_comments for delete to authenticated
using (user_id = (select auth.uid()) and status = 'pending');
create policy theory_comments_admin_manage on public.theory_comments for all to authenticated
using (public.viewer_is_admin()) with check (public.viewer_is_admin());

create policy leaderboard_read_public on public.leaderboard_entries for select to anon, authenticated
using (true);
create policy daily_challenges_read_active on public.daily_challenges for select to anon, authenticated
using (is_active or public.viewer_is_admin());
create policy daily_challenges_admin_manage on public.daily_challenges for all to authenticated
using (public.viewer_is_admin()) with check (public.viewer_is_admin());
create policy mystery_boxes_read_active on public.mystery_boxes for select to anon, authenticated
using (is_active or public.viewer_is_admin());
create policy mystery_boxes_admin_manage on public.mystery_boxes for all to authenticated
using (public.viewer_is_admin()) with check (public.viewer_is_admin());
create policy user_rewards_read_self on public.user_rewards for select to authenticated
using (user_id = (select auth.uid()));
create policy user_rewards_admin_manage on public.user_rewards for all to authenticated
using (public.viewer_is_admin()) with check (public.viewer_is_admin());
create policy seasons_read_public on public.seasons for select to anon, authenticated
using (true);
create policy seasons_admin_manage on public.seasons for all to authenticated
using (public.viewer_is_admin()) with check (public.viewer_is_admin());
create policy season_progress_read_self on public.season_progress for select to authenticated
using (user_id = (select auth.uid()) or public.viewer_is_admin());
create policy season_progress_admin_manage on public.season_progress for all to authenticated
using (public.viewer_is_admin()) with check (public.viewer_is_admin());

create policy conversations_read_participants on public.conversations for select to authenticated
using (public.is_conversation_participant(id));
create policy message_requests_read_participants on public.message_requests for select to authenticated
using (sender_id = (select auth.uid()) or receiver_id = (select auth.uid()) or public.viewer_is_admin());
create policy message_requests_insert_allowed_sender on public.message_requests for insert to authenticated
with check (sender_id = (select auth.uid()) and status = 'pending' and public.can_receive_message(receiver_id));
create policy message_requests_receiver_respond on public.message_requests for update to authenticated
using (receiver_id = (select auth.uid()) and status = 'pending')
with check (receiver_id = (select auth.uid()) and status in ('accepted', 'declined'));
create policy message_requests_sender_cancel on public.message_requests for update to authenticated
using (sender_id = (select auth.uid()) and status = 'pending')
with check (sender_id = (select auth.uid()) and status = 'cancelled');
create policy message_requests_sender_delete_pending on public.message_requests for delete to authenticated
using (sender_id = (select auth.uid()) and status = 'pending');
create policy message_requests_admin_manage on public.message_requests for all to authenticated
using (public.viewer_is_admin()) with check (public.viewer_is_admin());

create policy messages_read_participants on public.messages for select to authenticated
using (public.is_conversation_participant(conversation_id));
create policy messages_insert_participant on public.messages for insert to authenticated
with check (sender_id = (select auth.uid()) and public.can_send_message(conversation_id));
create policy messages_recipient_mark_read on public.messages for update to authenticated
using (sender_id <> (select auth.uid()) and public.is_conversation_participant(conversation_id))
with check (sender_id <> (select auth.uid()) and public.is_conversation_participant(conversation_id));

create policy notifications_read_self on public.notifications for select to authenticated
using (user_id = (select auth.uid()));
create policy notifications_mark_read_self on public.notifications for update to authenticated
using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

create policy user_reports_read_own_or_admin on public.user_reports for select to authenticated
using (reporter_id = (select auth.uid()) or public.viewer_is_admin());
create policy user_reports_insert_self on public.user_reports for insert to authenticated
with check (reporter_id = (select auth.uid()) and status = 'pending');
create policy user_reports_admin_manage on public.user_reports for all to authenticated
using (public.viewer_is_admin()) with check (public.viewer_is_admin());
create policy audit_logs_read_admin on public.audit_logs for select to authenticated
using (public.viewer_is_admin());

-- Start from no client privileges on these tables, then grant only required
-- operations. RLS policies above provide the row-level authorization layer.
revoke all privileges on table
  public.users, public.user_follows, public.user_blocks, public.social_links,
  public.cases, public.case_suspects, public.case_evidence, public.case_solutions,
  public.case_progress, public.user_notes, public.clue_connections,
  public.achievements, public.user_achievements, public.theories, public.theory_votes,
  public.theory_comments, public.leaderboard_entries, public.daily_challenges,
  public.mystery_boxes, public.user_rewards, public.seasons, public.season_progress,
  public.conversations, public.message_requests, public.messages, public.notifications,
  public.user_reports, public.audit_logs
from anon, authenticated;

-- Readable public data is limited to profiles allowed by their privacy setting,
-- published case content, approved community content, active catalogs, and boards.
grant select (id, username, display_name, bio, avatar_path, banner_path, role,
  is_verified, rank, xp, lawyer_specialty, lawyer_years_experience,
  lawyer_license_verified, created_at)
  on table public.users to anon, authenticated;
grant select on table public.social_links, public.cases,
  public.case_suspects, public.case_evidence, public.achievements,
  public.user_achievements, public.theories, public.theory_comments,
  public.leaderboard_entries, public.daily_challenges, public.mystery_boxes,
  public.seasons to anon, authenticated;
grant select on table public.case_solutions, public.case_progress, public.user_notes,
  public.clue_connections, public.user_follows, public.user_blocks,
  public.theory_votes, public.user_rewards, public.season_progress,
  public.conversations, public.message_requests, public.messages,
  public.notifications, public.user_reports, public.audit_logs to authenticated;

-- Profile edits exclude role, verification, rank, XP, lawyer verification,
-- identifiers, and server-managed timestamps.
grant update (
  username, display_name, bio, avatar_path, banner_path, profile_visibility,
  message_privacy, show_activity, show_statistics, show_socials, locale, theme
) on table public.users to authenticated;

grant select, delete on table public.user_follows to authenticated;
grant insert (followed_id) on table public.user_follows to authenticated;
grant select, delete on table public.user_blocks to authenticated;
grant insert (blocked_id) on table public.user_blocks to authenticated;

grant insert (platform, url), update (platform, url), delete on table public.social_links to authenticated;

grant insert, update, delete on table public.cases to authenticated;
grant insert (slug, title, synopsis, category, difficulty, estimated_minutes, tags, is_fictional)
  on table public.cases to authenticated;
grant update (title, synopsis, category, difficulty, estimated_minutes, tags)
  on table public.cases to authenticated;

grant insert, update, delete on table public.case_suspects, public.case_evidence,
  public.case_solutions, public.achievements, public.user_achievements,
  public.daily_challenges, public.mystery_boxes, public.user_rewards,
  public.seasons, public.season_progress, public.user_reports to authenticated;

grant select, delete on table public.case_progress to authenticated;
grant insert (case_id, current_stage, client_state) on table public.case_progress to authenticated;
grant update (current_stage, client_state) on table public.case_progress to authenticated;

grant insert (case_id, title, content), update (title, content), delete
  on table public.user_notes to authenticated;
grant insert (case_id, source_evidence_id, target_evidence_id, relation),
  update (source_evidence_id, target_evidence_id, relation), delete
  on table public.clue_connections to authenticated;

grant insert (case_id, title, body), update (title, body), delete
  on table public.theories to authenticated;
grant insert (theory_id, value), update (value), delete
  on table public.theory_votes to authenticated;
grant insert (theory_id, body), update (body), delete
  on table public.theory_comments to authenticated;

grant select, delete on table public.message_requests to authenticated;
grant insert (receiver_id, first_message), update (status), delete
  on table public.message_requests to authenticated;
grant insert (conversation_id, content) on table public.messages to authenticated;
grant update (read_at) on table public.messages to authenticated;
grant update (read_at) on table public.notifications to authenticated;
grant insert (reported_user_id, reason, details) on table public.user_reports to authenticated;

commit;
