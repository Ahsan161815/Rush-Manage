-- Migration: persist CRM contact linkage for finance documents
-- Adds optional contact_id + client_email columns to quotes/invoices.

ALTER TABLE public.finance_quotes
  ADD COLUMN IF NOT EXISTS contact_id text,
  ADD COLUMN IF NOT EXISTS client_email text;

ALTER TABLE public.finance_invoices
  ADD COLUMN IF NOT EXISTS contact_id text,
  ADD COLUMN IF NOT EXISTS client_email text;

CREATE INDEX IF NOT EXISTS finance_quotes_contact_id_idx
  ON public.finance_quotes (contact_id);

CREATE INDEX IF NOT EXISTS finance_invoices_contact_id_idx
  ON public.finance_invoices (contact_id);
