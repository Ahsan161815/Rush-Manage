# Outstanding Work Log

_Last updated: December 30, 2025_

## Auth & Onboarding
- [ ] **Upgrade invite-email Edge Function SMTP**
  - Function: Supabase Edge Function `invite-email`
  - The Edge Function currently calls Supabase's default SMTP endpoint, which is slow and quota-limited. Once you provision a custom SMTP (SendGrid, Mailgun, etc.), update the function to authenticate against it so invite emails deliver reliably.

<!-- ## Collaboration & Chat
- [x] **Wire attachment buttons to real uploads**
  - ✅ Completed December 30, 2025. Both workspace and project chats now pick/upload files via Supabase storage, show pending chips, and save attachment URLs in `Message.attachments`.
- [x] **Use real user/member IDs in project chat**
  - ✅ Sending/receipts: [lib/screens/project_chat_screen.dart](lib/screens/project_chat_screen.dart#L40-L120) and [lib/screens/project_chat_screen.dart](lib/screens/project_chat_screen.dart#L260-L320)
  - ✅ Project chat writes every outbound message with `authorId: 'me'` and marks read receipts against the same sentinel key, so multi-user conversations cannot attribute messages or track per-user reads. Pipe Supabase `auth.currentUser.id` (and the corresponding member id) through `_handleSend()` and `markReceipt()` so stored messages reflect real collaborators.
- [x] **Populate the contacts tab or hide it**
  - ✅ Threads list: [lib/screens/chats_screen.dart](lib/screens/chats_screen.dart#L80-L250)
  - The chats list offers filters for “Projects” and “Contacts,” but `_buildThreads()` only returns project threads, so the contacts filter always renders an empty state. Either hydrate contact conversations or remove that filter until DM threads exist.
- [x] **Implement shared-files upload/download flows**
  - ✅ Screen: [lib/screens/shared_files_screen.dart](lib/screens/shared_files_screen.dart#L26-L170) plus [lib/common/utils/shared_file_builder.dart](lib/common/utils/shared_file_builder.dart#L13-L160)
  - The “Upload files” CTA and per-file action icons have empty callbacks, and the aggregator fabricates file size/timestamps from task/message metadata. Hook the button into the same upload pipeline as chat/tasks, persist metadata in Supabase, and make download/more menus actually retrieve files.
- [x] **Contact/collaborator “Message” buttons ignore the person you picked**
  - ✅ Screens: [lib/screens/contact_detail_screen.dart](lib/screens/contact_detail_screen.dart#L25-L150), [lib/screens/collaborator_profile_screen.dart](lib/screens/collaborator_profile_screen.dart#L20-L160), [lib/screens/collaborators_screen.dart](lib/screens/collaborators_screen.dart#L120-L220)
  - Every “Send Message”/“Conversation” CTA just routes to the generic workspace chat without identifying the selected contact, so there’s no way to open a targeted thread. Either create actual per-contact chats (and pass IDs). -->
- [ ] **Share-link invite UI is static and can’t copy anything**
  - Screen: [lib/screens/invite_collaborator_screen.dart](lib/screens/invite_collaborator_screen.dart#L40-L220)
  - Toggling “Share invite link” reveals a hard-coded URL and a `Copy link` button with an empty `onPressed`. There’s no generated token, clipboard copy, or backend update, so the option is cosmetic. Implement real link issuance + copy/share handling tied to Supabase invites.
<!-- - [ ] **Invitation “Accept” CTA doesn’t do anything**
  - ✅ Screen: [lib/screens/invitation_notifications_screen.dart](lib/screens/invitation_notifications_screen.dart#L180-L320)
  - Pending invitation cards render a gradient “Accept” pill with no tap handler, so you can’t approve collaborators from this screen. Wire the CTA to `ProjectController.acceptInvitation()` (and add a decline/copy-link action that actually fires) instead of a decorative container. -->

## Project Management
<!-- - [x] **Persist the selected project category**
  - Screens: [lib/screens/create_project_screen.dart](lib/screens/create_project_screen.dart#L520-L548) and [lib/models/project.dart](lib/models/project.dart#L167-L240)
  - The creation form collects `_selectedCategory`, but the submit payload never includes it and the `Project` model has no field to store it. As a result, category selections are silently discarded and can’t drive filtering or analytics. -->
- [ ] **Replace the fake external invite toggle/link with a real share flow**
  - Screen: [lib/screens/create_project_screen.dart](lib/screens/create_project_screen.dart#L704-L824)
  - Flipping “Invite external stakeholders” only toggles `_inviteExternal` and reveals a hard-coded `https://rush.manage/invite/...` string with no copy/share action or Supabase token issuance. Hook this toggle into the real invite-link service (generate, persist, copy/share) or hide it until backend support lands.
<!-- - [x] **Actually send collaborator invites from the “Add member” flow**
  - Screen: [lib/screens/create_project_screen.dart](lib/screens/create_project_screen.dart#L328-L430)
  - Tapping “Add member” just builds local `Member` objects via `_inviteesAsMembers()` and stuffs them into the new project with IDs equal to the typed email address. The app never calls an invite API, emails users, or validates membership, so collaborators never learn about the project. Integrate this list with the existing invitation service before closing the wizard. -->
<!-- - [x] **Wire the Project Detail “Add files” CTA to uploads**
  - Screen: [lib/screens/project_detail_screen.dart](lib/screens/project_detail_screen.dart#L512-L533)
  - The primary button in the files card has `onPressed: () {}` so there’s no way to upload or attach documents from the project hub. Connect it to the same uploader used on the shared-files screen and refresh the file list when uploads finish. -->
<!-- - [ ] **Give task attachments a real picker/uploader**
  - Screen: [lib/screens/project_detail_screen.dart](lib/screens/project_detail_screen.dart#L968-L1005)
  - When adding a task, “attachments” is a plain text field that expects users to type a filename, and `_addAttachment()` just stores the string. Replace this with a file picker plus upload pipeline that persists files and links them to the task record. -->
 <!-- - [x] **Tie finance metrics to project IDs instead of client-name guesses**
  - File: [lib/screens/project_detail_screen.dart](lib/screens/project_detail_screen.dart#L2630-L2690)
  - `_ProjectFinanceSnapshot` now prefers `invoice.projectId == project.id` and falls back to the legacy `clientName` match when no project-linked invoices exist. Models, controller, data service, router, and invoice composer were updated so new invoices persist `project_id`. -->

## Finance
<!-- - [x] **Invoice metadata pickers never persist to Supabase**
  - Screen: [lib/screens/finance_invoice_screen.dart#L18-L110](lib/screens/finance_invoice_screen.dart#L18-L110)
  - The issue/due date buttons and payment-method chips only mutate local `_issueDate`, `_dueDate`, and `_method` state and feed `_InvoiceFieldsCard`; there is no call into `FinanceController` to save the values, so edits disappear as soon as you leave the screen. -->
- [ ] **“Send reminder” on the invoice detail screen is a no-op**
  - Screen: [lib/screens/finance_invoice_screen.dart#L96-L110](lib/screens/finance_invoice_screen.dart#L96-L110)
  - The CTA renders prominently but its `onPressed` is literally `() {}`, so you can’t email or notify clients about overdue invoices from the detail view.
<!-- - [x] **Reporting export button is placeholder-only**
  - Screen: [lib/screens/finance_reporting_screen.dart#L150-L170](lib/screens/finance_reporting_screen.dart#L150-L170)
  - The “Export data” `GradientButton` uses `onPressed: () {}` so nothing happens when you tap it—no CSV, PDF, or even a snackbar confirming the feature doesn’t exist. -->
<!-- - [x] **Dashboards fabricate revenue trend data when you have no payments**
  - Source: [lib/controllers/finance_controller.dart#L200-L290](lib/controllers/finance_controller.dart#L200-L290)
  - `revenueTrendFor()` calls `_syntheticTrendValue()` to inject sinusoidal numbers whenever a bucket sums to zero, which means the main finance charts can display misleading values unrelated to Supabase data. -->
<!-- - [x] **Quote “require signature” switch is hard-coded on**
  - Screen: [lib/screens/finance_create_quote_screen.dart#L108-L118](lib/screens/finance_create_quote_screen.dart#L108-L118)
  - The toggle uses `Switch(value: true, onChanged: (_) {})`, so users can’t actually disable signatures or update any backing model—it's pure decoration. -->
<!-- - [x] **Quote preview card has no document or download actions**
  - Screen: [lib/screens/finance_quote_preview_screen.dart#L150-L210](lib/screens/finance_quote_preview_screen.dart#L150-L210)
  - Implemented: `_QuoteDocumentCard` now generates an HTML preview for the quote, uploads it to Supabase Storage (`documents` bucket) and returns a public URL. The UI shows a loading state, then offers `Open`, `Copy link`, and `Download` actions. See `lib/controllers/finance_controller.dart` (`generateQuoteDocument`) and `lib/screens/finance_quote_preview_screen.dart` (`_QuoteDocumentCard`). -->

## Misc & Settings
<!-- - [x] **Role changes in the permissions screen never persist**
  - Screen: [lib/screens/roles_permissions_screen.dart#L18-L210](lib/screens/roles_permissions_screen.dart#L18-L210)
  - `_roleOverrides` only mutates local state via `_updateRole()` and there is no call into `ProjectController`/`CrmDataService` to save the selection, nor is there a save button. Leaving the screen discards every change, so collaborators always keep their previous Supabase role. -->
<!-- - [x] **CRM “Send quote”/“Create invoice” buttons ignore the selected contact**
  - Screens: [lib/screens/crm_screen.dart#L820-L900](lib/screens/crm_screen.dart#L820-L900) and [lib/screens/contact_detail_screen.dart#L55-L215](lib/screens/contact_detail_screen.dart#L55-L215)
  - The quick actions simply route to `financeCreateQuote`/`finance` without passing any client metadata, so the finance forms can’t pre-populate the customer. Users have to re-type names/emails every time even though they started from a CRM profile. -->
 <!-- - [x] **CRM “Create invoice” CTA opens the invoice composer and seeds client data**
  - Screens: [lib/screens/crm_screen.dart#L885-L894](lib/screens/crm_screen.dart#L885-L894) and [lib/screens/contact_detail_screen.dart#L208-L214](lib/screens/contact_detail_screen.dart#L208-L214)
  - Implemented: both `_openInvoiceCreation()` handlers now navigate to the named route `financeCreateInvoiceForm` and pass `clientName`, optional `clientEmail`, `contactId`, and `projectId` (when available). The composer (`FinanceCreateInvoiceScreen`) seeds the client name/email and `FinanceController.createInvoice()` persists invoices to Supabase via `FinanceDataService`.
  - Backend: DB schema and migrations for `finance_invoices` exist in `docs/supabase_schema.sql` and `db/migrations/*`. A convenience Edge Function to insert invoices is provided at `functions/create-invoice` (see `functions/create-invoice/README.md`).
  - Deployment notes: run the SQL in `docs/supabase_schema.sql` against your Supabase project, deploy the Edge Function with the Supabase CLI, and set `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` environment variables for the function. The app uses the Supabase client to insert/read `finance_invoices` and will work once the DB and function are deployed. -->
 <!-- - [x] **"System default" language option always falls back to English**
   - File: [lib/controllers/locale_controller.dart#L32-L43](lib/controllers/locale_controller.dart#L32-L43)
   - Fixed: `localeResolutionCallback` now defers to Flutter's `locale` (or `WidgetsBinding.instance.window.locale`) and matches supported locales before falling back. -->
