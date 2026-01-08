# create-invoice Edge Function

Purpose: simple Supabase Edge Function to insert a row into `finance_invoices` and accept `project_id` (nullable).

Environment variables:
  - `SUPABASE_URL` — your Supabase project URL
  - `SUPABASE_SERVICE_ROLE_KEY` — service role key for write operations

Important: the `finance_invoices` table requires an `owner_id` (uuid) column. When calling this function include `owner_id` in the JSON body (or `ownerId`) so the inserted row is attributed to the correct workspace owner.

Optional: include `contact_id` (or `contactId`) and/or `client_email` (or `clientEmail`) so invoices created from CRM can stay linked to the selected contact.

Example payload in the request body:

```json
{
  "client": "ACME",
  "amount": 123.45,
  "due_date": "2026-01-15",
  "project_id": "proj_abc123",
  "owner_id": "<user-uuid>",
  "contact_id": "contact_123",
  "client_email": "billing@acme.com"
}
```

Deploy (Supabase CLI):

```bash
supabase functions deploy create-invoice --project-ref <PROJECT_REF>
supabase functions deploy create-invoice --project-ref <PROJECT_REF>
```

Example request:

```bash
curl -X POST "https://<YOUR_FN_URL>/" \
  -H "Content-Type: application/json" \
  -d '{"client":"ACME","amount":123.45,"due_date":"2026-01-15","project_id":"proj_abc123"}'
```

Notes:
  - Keep `project_id` nullable while you backfill and QA.
  - Ensure the function runs under a role with permission to insert into `finance_invoices` (service role recommended for admin-style ops).