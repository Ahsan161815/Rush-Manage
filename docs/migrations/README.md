Migration: add `project_id` to `finance_invoices`

Purpose
- Persist `project_id` on invoices to reliably associate invoices with projects
  (avoids fuzzy client-name matching).

Files
- `2025-12-31-add-project-id-to-invoices.sql` — SQL to add `project_id`, create index,
  conservative backfill and ambiguous-row selector.

Run plan (recommended)
1. Take a production DB snapshot (required).
2. Run migration SQL in staging (copy of production) and verify schema/index created.
   - Use Supabase SQL editor or psql.
3. Deploy app change that writes `project_id` for new invoices. (Client-side support added.)
4. Run the conservative backfill from the SQL file in staging. Verify counts and samples.
   - The backfill only updates invoices whose lower(client_name) maps to exactly one project.
5. Query ambiguous rows using the provided SELECT and resolve manually (export CSV for review).
6. After QA, repeat migration on production during a maintenance window.
7. Optionally, once all rows are backfilled and verified, add a foreign-key constraint and
   make `project_id` NOT NULL:

   ALTER TABLE public.finance_invoices
     ALTER COLUMN project_id SET NOT NULL;
   ALTER TABLE public.finance_invoices
     ADD CONSTRAINT finance_invoices_project_fk
     FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE SET NULL;

Notes
- `projects.id` is `text` in the schema, so `project_id` uses `text` to match types.
- Keep `project_id` nullable while backfilling and resolving ambiguous rows to avoid data loss.
- Test the entire flow in staging before production. Roll back using DB snapshot if needed.

If you want, I can:
- Produce a CSV export SQL for ambiguous rows formatted for download.
- Draft a small admin UI CSV + import mapping helper to assign `project_id` for ambiguous invoices.
- Prepare a PR with documentation and the migration files added (already added here).
