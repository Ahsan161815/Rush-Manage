-- Migration: add category column to projects
-- The Flutter model `Project` includes an optional `category` field and
-- create/update operations send it when set.

ALTER TABLE public.projects
  ADD COLUMN IF NOT EXISTS category text;
