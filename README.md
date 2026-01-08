# Rush Manage

Rush Manage is a Flutter + Supabase workspace that centralizes CRM, project, and finance workflows. The client app runs entirely on Flutter while Supabase anchors authentication and persistence.

## Tech Stack

- Flutter 3.x / Dart 3.x
- Provider for state management
- Supabase (Auth + Postgres)
- GoRouter for navigation

## Local Development

1. Install Flutter 3.x and run `flutter doctor` to verify toolchains.
2. Fetch dependencies: `flutter pub get`.
3. Configure Supabase keys inside `lib/config/supabase_config.dart` (see Supabase section below).
4. Launch the app with `flutter run` (or `flutter run -d chrome` for web).

## Supabase Setup

1. **Create a Supabase project** and enable email auth. Add your password reset redirect URL inside `Authentication > URL Configuration` so it matches `SupabaseConfig.passwordResetRedirectUrl`.
2. **Run the schema script** contained in [docs/supabase_schema.sql](docs/supabase_schema.sql). The script creates every table the app expects (`finance_quotes`, `finance_invoices`, `finance_expenses`, `crm_contacts`, `projects`, `project_messages`, `collaborator_contacts`, and `project_invitations`), wires foreign keys, adds helper triggers, and applies owner-based RLS policies.
3. **Store your project keys**:
	- `SupabaseConfig.url` → Project URL from the Supabase dashboard.
	- `SupabaseConfig.anonKey` → `Project Settings > API > anon public` key.
	- `SupabaseConfig.serviceRoleKey` is only required for server-side tooling. Keep it out of client builds.
4. **RLS verification**: sign in with a test account and ensure you can only read/write rows where `owner_id` matches your `auth.uid()`. The shared `apply_owner_policies` procedure from the SQL file can be re-run safely whenever you recreate tables.

### Table Overview

| Table | Purpose |
| --- | --- |
| `finance_quotes` | Stores quotes, VAT, totals, and status for each workspace owner. |
| `finance_invoices` | Persists invoice drafts, unpaid/paid state, due dates, and payment metadata. |
| `finance_expenses` | Tracks operational expenses linked to optional project IDs. |
| `crm_contacts` | CRM entities, linked project summaries, stats, and highlight arrays. |
| `projects` | Portfolio metadata plus serialized `members` and `tasks`. |
| `project_messages` | Async collaboration feed for each project (with reactions/receipts). |
| `collaborator_contacts` | Directory of collaborators surfaced across project modules. |
| `project_invitations` | Invitation lifecycle (pending/accepted/declined) with onboarding flags. |

> The exact column definitions and constraints for these tables live in [docs/supabase_schema.sql](docs/supabase_schema.sql). Run that script after creating your Supabase project so the Flutter services can insert and query data.

## Common Tasks

- Refresh CRM/Finance data: controllers auto-sync at startup and whenever `refresh()` is called.
- Create contacts/quotes/invoices: all flows persist directly to Supabase with optimistic updates.
- Contact form reliability: the bottom sheet now guards against duplicate submissions and uses structured return values to avoid the previous red screen crash.

## Troubleshooting

- **AuthException: User not authenticated** – verify the Supabase session, restart the app, or log back in.
- **RLS related 401/permission denied** – confirm that `owner_id` is being set when inserting rows (check the relevant data service) and re-run the policy helper procedure for the affected table.
- **Schema drift** – re-run [docs/supabase_schema.sql](docs/supabase_schema.sql) or use Supabase migration history to reconcile differences.
