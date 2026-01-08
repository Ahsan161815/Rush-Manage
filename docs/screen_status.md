# Screen Delivery Tracker

Status legend: ✅ fully data-wired • ⚙️ workflow/form (no backing data needed) • 🟡 follow-up planned

| Screen | Status | Notes |
| --- | --- | --- |
| analytics_screen.dart | ✅ | Metrics come from `ProjectController` (completed projects) and `FinanceController` (paid/unpaid invoices). |
| calendar_screen.dart | ✅ | Calendar buckets draw from live project tasks via `ProjectScheduleAdapter`. |
| chats_screen.dart | ✅ | Thread list and previews are built from controller-backed projects + messages. |
| collaboration_chat_screen.dart | ✅ | Uses `ProjectController` message store + receipts; reactions update Supabase service. |
| collaborators_screen.dart | ✅ | Lists collaborators, availability, and invitations from `ProjectController` contacts/invitations. |
| collaborator_profile_screen.dart | ✅ | Profile view now computes task/project stats directly from controller data. |
| contact_detail_screen.dart | ✅ | Renders live contact info supplied through `ContactDetailArgs`. |
| create_project_screen.dart | ⚙️ | Form posts new projects through `ProjectController.addProject`. |
| create_quote_screen.dart | ⚙️ | Quote builder feeds `FinanceController` to persist quotes/invoices. |
| crm_screen.dart | ✅ | CRM dashboard lists contacts/invitations sourced from controller data. |
| edit_profile_screen.dart | ⚙️ | Updates go through `UserController` profile APIs. |
| finance_create_invoice_screen.dart | ⚙️ | Invoice creation form connected to finance services. |
| finance_create_quote_screen.dart | ⚙️ | Quote creation/edit workflow tied to finance models. |
| finance_expenses_screen.dart | ✅ | Expense list and filters use `FinanceController.expenses`. |
| finance_invoices_screen.dart | ✅ | Invoice table pulls from controller + supports filter/search. |
| finance_invoice_screen.dart | ✅ | Single-invoice view consumes route-provided invoice data. |
| finance_quote_preview_screen.dart | ✅ | Preview renders passed-in quote + localization helpers. |
| finance_record_payment_screen.dart | ⚙️ | Payment form updates invoice via controller mutation. |
| finance_reporting_screen.dart | ✅ | Cards, charts, and clients derive from `FinanceController` snapshots. |
| finance_screen.dart | ✅ | Overview tiles display balances, invoices, and shortcuts from finance data. |
| finance_signature_tracking_screen.dart | ✅ | Signature tracker uses real quote statuses + timestamps. |
| forgot_password_screen.dart | ⚙️ | Pure auth workflow calling Supabase password reset. |
| home_screen.dart | ✅ | Hero metrics and activities tie into Project/Finance/User controllers. |
| invitation_notifications_screen.dart | ✅ | Fetches invitations + updates statuses via controller. |
| invitation_onboarding_screen.dart | ⚙️ | Form collects onboarding inputs and persists through controller. |
| invite_collaborator_screen.dart | ⚙️ | Invitation form posts via `ProjectController.addInvitation`. |
| login_screen.dart | ⚙️ | Auth-only screen (Supabase sign-in) with no fake UI data. |
| main_screen.dart | ✅ | Hosts tab navigation; each tab consumes live providers. |
| management_screen.dart | ✅ | Project grid/list uses controller projects + filters. |
| profile_screen.dart | ✅ | Loads profile info from `UserController`; edits propagate to backend. |
| project_chat_screen.dart | ✅ | Project-level threads use controller message list + composer hooks. |
| project_detail_screen.dart | ✅ | Finance/files/insights sections wired into controllers + shared file aggregator. |
| project_schedule_screen.dart | ✅ | Uses `ProjectScheduleAdapter` for per-project calendar view. |
| project_timeline_screen.dart | ✅ | Syncfusion timeline renders task data with drag/update hooks. |
| registration_screen.dart | ⚙️ | Supabase sign-up workflow; no mock data displayed. |
| reset_new_password_screen.dart | ⚙️ | Password reset form calling auth endpoints. |
| roles_permissions_screen.dart | ✅ | Member list, roles, and assignment counts originate from controller data. |
| setup_profile_screen.dart | ⚙️ | First-run profile wizard writing to `UserController`. |
| shared_files_screen.dart | ✅ | File list now supplied by `SharedFileAggregator` built from projects/messages. |
| verify_email_screen.dart | ⚙️ | E-mail verification UI tied to Supabase status checks. |
| welcome_screen.dart | ⚙️ | Static onboarding copy only (no data dependencies). |
