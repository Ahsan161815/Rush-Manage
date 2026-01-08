-- Migration: add nullable project_id to finance_invoices and index
-- Run in Supabase SQL editor on a staging copy first. Take a DB snapshot.

BEGIN;

-- 1) Add nullable project_id column (text to match public.projects.id)
ALTER TABLE public.finance_invoices
  ADD COLUMN IF NOT EXISTS project_id text;

-- 2) Index for faster lookups
CREATE INDEX IF NOT EXISTS finance_invoices_project_idx
  ON public.finance_invoices (project_id);

COMMIT;

-- Conservative backfill: auto-fill only when client_name maps to exactly one project
-- Run this after app changes that write project_id for new invoices

-- BACKFILL SCRIPT
WITH project_keys AS (
  SELECT lower(coalesce(client, '')) AS client_key, id AS project_id
  FROM public.projects
),
unique_keys AS (
  SELECT client_key, min(project_id) AS project_id
  FROM project_keys
  GROUP BY client_key
  HAVING count(*) = 1
)
UPDATE public.finance_invoices fi
SET project_id = uk.project_id
FROM unique_keys uk
WHERE fi.project_id IS NULL
  AND lower(coalesce(fi.client_name, '')) = uk.client_key;

-- Ambiguous rows selector (manual review)
-- Lists invoices whose client_name maps to multiple projects
WITH project_keys AS (
  SELECT lower(coalesce(client, '')) AS client_key, id AS project_id
  FROM public.projects
),
ambiguous_clients AS (
  SELECT client_key
  FROM project_keys
  GROUP BY client_key
  HAVING count(*) > 1
)
SELECT fi.*
FROM public.finance_invoices fi
JOIN ambiguous_clients ac ON lower(coalesce(fi.client_name, '')) = ac.client_key
WHERE fi.project_id IS NULL;
