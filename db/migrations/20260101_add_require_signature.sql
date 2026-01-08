-- Migration: add require_signature column to finance_quotes
-- Run in Supabase SQL editor or via psql against your database.

ALTER TABLE public.finance_quotes
  ADD COLUMN IF NOT EXISTS require_signature boolean NOT NULL DEFAULT true;

-- Optional: if you prefer default false for historical behavior, use:
-- ALTER TABLE public.finance_quotes
--   ADD COLUMN IF NOT EXISTS require_signature boolean NOT NULL DEFAULT false;
