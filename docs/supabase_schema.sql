-- Rush Manage Supabase schema bootstrap
-- Run this script inside the Supabase SQL editor

create schema if not exists public;

create or replace function public.handle_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- Finance quotes -----------------------------------------------------------
create table if not exists public.finance_quotes (
  id text primary key,
  owner_id uuid not null references auth.users(id) on delete cascade,
  contact_id text,
  client_name text not null,
  client_email text,
  description text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  status text not null default 'draft'
    check (status in ('draft','pending_signature','signed','declined')),
  total numeric(12,2) not null default 0,
  vat numeric(12,2) not null default 0
  ,require_signature boolean not null default true
);
create trigger finance_quotes_set_updated_at
  before update on public.finance_quotes
  for each row execute procedure public.handle_updated_at();

-- Finance invoices ---------------------------------------------------------
create table if not exists public.finance_invoices (
  id text primary key,
  owner_id uuid not null references auth.users(id) on delete cascade,
  quote_id text,
  project_id text,
  contact_id text,
  client_name text not null,
  client_email text,
  issued_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  status text not null default 'draft'
    check (status in ('draft','unpaid','paid')),
  amount numeric(12,2) not null default 0,
  due_date timestamptz,
  payment_method text
);
create trigger finance_invoices_set_updated_at
  before update on public.finance_invoices
  for each row execute procedure public.handle_updated_at();

create index if not exists finance_invoices_project_idx
  on public.finance_invoices (project_id);

-- Finance expenses ---------------------------------------------------------
create table if not exists public.finance_expenses (
  id text primary key,
  owner_id uuid not null references auth.users(id) on delete cascade,
  project_id text,
  description text not null,
  amount numeric(12,2) not null,
  date date not null default now(),
  recurrence text not null default 'one_time'
    check (recurrence in ('one_time','weekly','monthly')),
  created_at timestamptz not null default now()
);

-- CRM contacts -------------------------------------------------------------
create table if not exists public.crm_contacts (
  id text primary key,
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  type text not null check (type in ('client','collaborator')),
  email text,
  phone text,
  address text,
  notes text,
  primary_project_label text,
  relationship_label text,
  projects jsonb not null default '[]'::jsonb,
  crm_stats jsonb not null default '[]'::jsonb,
  linked_projects text[] not null default '{}',
  finance_highlights text[] not null default '{}',
  document_links text[] not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create trigger crm_contacts_set_updated_at
  before update on public.crm_contacts
  for each row execute procedure public.handle_updated_at();

-- Projects -----------------------------------------------------------------
create table if not exists public.projects (
  id text primary key,
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  client text,
  start_date timestamptz,
  end_date timestamptz,
  status text not null default 'in_preparation'
    check (status in ('in_preparation','ongoing','completed','archived')),
  progress integer not null default 0,
  description text,
  category text,
  members jsonb not null default '[]'::jsonb,
  tasks jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create trigger projects_set_updated_at
  before update on public.projects
  for each row execute procedure public.handle_updated_at();

-- Project messages ---------------------------------------------------------
create table if not exists public.project_messages (
  id text primary key,
  project_id text not null references public.projects(id) on delete cascade,
  owner_id uuid not null references auth.users(id) on delete cascade,
  author_id text not null,
  body text not null,
  sent_at timestamptz not null default now(),
  attachments text[] not null default '{}',
  mentions text[] not null default '{}',
  reactions jsonb not null default '{}'::jsonb,
  receipts jsonb not null default '{}'::jsonb,
  reply_to_message_id text references public.project_messages(id) on delete set null,
  reply_preview jsonb
);

create index if not exists project_messages_reply_to_message_id_idx
  on public.project_messages (reply_to_message_id);

-- Shared files -------------------------------------------------------------
create table if not exists public.shared_files (
  id text primary key,
  owner_id uuid not null references auth.users(id) on delete cascade,
  project_id text,
  project_name text,
  file_name text not null,
  file_url text not null,
  content_type text not null default 'application/octet-stream',
  size_bytes bigint not null default 0,
  origin text not null default 'chat'
    check (origin in ('chat','task','library')),
  uploader_id text not null,
  uploader_name text not null,
  uploaded_at timestamptz not null default now()
);

create index if not exists shared_files_owner_uploaded_idx
  on public.shared_files(owner_id, uploaded_at desc);

create index if not exists shared_files_project_idx
  on public.shared_files(project_id);

-- Collaborator contacts ----------------------------------------------------
create table if not exists public.collaborator_contacts (
  id text primary key,
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  profession text not null,
  availability text not null default 'available'
    check (availability in ('available','busy','offline')),
  location text,
  email text,
  phone text,
  last_project text,
  tags text[] not null default '{}'
);

-- Project invitations ------------------------------------------------------
create table if not exists public.project_invitations (
  id text primary key,
  owner_id uuid not null references auth.users(id) on delete cascade,
  project_id text not null references public.projects(id) on delete cascade,
  project_name text not null,
  invitee_email text not null,
  invitee_name text not null,
  role text not null,
  status text not null default 'pending'
    check (status in ('pending','accepted','declined')),
  sent_at timestamptz not null default now(),
  updated_at timestamptz,
  requires_onboarding boolean not null default false,
  message text,
  read_by_invitee boolean not null default false,
  receipt_status text not null default 'sent'
    check (receipt_status in ('sent','received','read'))
);
create trigger project_invitations_set_updated_at
  before update on public.project_invitations
  for each row execute procedure public.handle_updated_at();

-- Shared row level security policy helper ------------------------------
create or replace function public.owner_matches(record_owner uuid)
returns boolean language sql immutable as $$
  select record_owner = auth.uid();
$$;

-- Apply policies (repeat for each table with owner_id) -----------------
create or replace procedure public.apply_owner_policies(table_name text)
language plpgsql as $$
begin
  execute format('alter table public.%I enable row level security;', table_name);
  execute format('drop policy if exists %I_select on public.%I;', table_name, table_name);
  execute format(
    'create policy %I_select on public.%I for select using (public.owner_matches(owner_id));',
    table_name,
    table_name
  );
  execute format('drop policy if exists %I_insert on public.%I;', table_name, table_name);
  execute format(
    'create policy %I_insert on public.%I for insert with check (public.owner_matches(owner_id));',
    table_name,
    table_name
  );
  execute format('drop policy if exists %I_update on public.%I;', table_name, table_name);
  execute format(
    'create policy %I_update on public.%I for update using (public.owner_matches(owner_id)) with check (public.owner_matches(owner_id));',
    table_name,
    table_name
  );
  execute format('drop policy if exists %I_delete on public.%I;', table_name, table_name);
  execute format(
    'create policy %I_delete on public.%I for delete using (public.owner_matches(owner_id));',
    table_name,
    table_name
  );
end;
$$;

call public.apply_owner_policies('finance_quotes');
call public.apply_owner_policies('finance_invoices');
call public.apply_owner_policies('finance_expenses');
call public.apply_owner_policies('crm_contacts');
call public.apply_owner_policies('projects');
call public.apply_owner_policies('project_messages');
call public.apply_owner_policies('collaborator_contacts');
call public.apply_owner_policies('project_invitations');
call public.apply_owner_policies('shared_files');

-- Storage (Supabase) -------------------------------------------------------
-- Bucket: documents (public)
--
-- The app uploads quote previews as:
--   quotes/<auth.uid()>/<quoteId>.html
--
-- Notes:
-- - Marking a bucket as "public" controls CDN access to files.
-- - Uploads/updates/deletes still require RLS policies on storage.objects.

alter table storage.objects enable row level security;

-- Create policies only if they don't already exist.
-- (Supabase SQL editor sometimes runs scripts multiple times; CREATE POLICY
-- does not support IF NOT EXISTS.)

do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'storage'
      and tablename = 'objects'
      and policyname = 'documents_public_read'
  ) then
    execute $$
      create policy documents_public_read
        on storage.objects
        for select
        using (bucket_id = 'documents');
    $$;
  end if;
end$$;

do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'storage'
      and tablename = 'objects'
      and policyname = 'documents_user_insert'
  ) then
    execute $$
      create policy documents_user_insert
        on storage.objects
        for insert
        to authenticated
        with check (
          bucket_id = 'documents'
          and name like ('quotes/' || auth.uid()::text || '/%')
        );
    $$;
  end if;
end$$;

do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'storage'
      and tablename = 'objects'
      and policyname = 'documents_user_update'
  ) then
    execute $$
      create policy documents_user_update
        on storage.objects
        for update
        to authenticated
        using (
          bucket_id = 'documents'
          and name like ('quotes/' || auth.uid()::text || '/%')
        )
        with check (
          bucket_id = 'documents'
          and name like ('quotes/' || auth.uid()::text || '/%')
        );
    $$;
  end if;
end$$;

do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'storage'
      and tablename = 'objects'
      and policyname = 'documents_user_delete'
  ) then
    execute $$
      create policy documents_user_delete
        on storage.objects
        for delete
        to authenticated
        using (
          bucket_id = 'documents'
          and name like ('quotes/' || auth.uid()::text || '/%')
        );
    $$;
  end if;
end$$;
