## Plan: Projects Module UI

TL;DR: Design and add a complete Projects feature set that reuses the app's theme and widgets, extends data models/controllers, and adds new screens and widgets. Deliverables: My Projects dashboard, Project Detail, Create Project flow, Collaboration/Invite UX, Calendar/Timeline, and Global Metrics. Changes are scoped to `lib/common/models/`, `lib/controllers/`, `lib/app/widgets/`, `lib/screens/`, and the router files.

### Steps
1. Add domain models: create `lib/common/models/project.dart`, `task.dart`, `member.dart`, `project_file.dart`, `finance.dart` with basic fields (`name,id,client,start,end,status,progress,assignees,attachments`).
2. Add controller: create `lib/controllers/project_controller.dart` with `ProjectController` (CRUD projects, tasks, comments, files, finance) and `ChangeNotifier` APIs to update UI.
3. Build reusable widgets: add `lib/app/widgets/project_card.dart`, `lib/app/widgets/member_avatar.dart`, `lib/app/widgets/progress_chip.dart`, `lib/app/widgets/project_progress_indicator.dart`, `lib/app/widgets/task_item.dart`, `lib/app/widgets/discussion_feed.dart`, `lib/app/widgets/finance_summary.dart` using `AppColors` and `appTextTheme`.
4. Update/Add screens:
   - Update `lib/screens/dashboard_screen.dart` → implement “My Projects” dashboard UI with header, `+ New Project`, filter icon, and project cards (tap opens detail).
   - Implement `lib/screens/project_detail_screen.dart` → header summary, status dropdown (`In preparation/Ongoing/Completed`), progress indicator, task list (+add task), discussion feed, finance summary, files list, options (Archive/Duplicate/Delete).
   - Enhance `lib/screens/create_project_screen.dart` → quick fields (client selector/quick-add, dates, category, invited members with roles) and onCreate navigate to project detail.
   - Add `lib/screens/collaboration_invite_screen.dart` (or embed in create flow) for external invite links and onboarding note.
   - Add `lib/screens/project_calendar_screen.dart` and `lib/screens/project_timeline_screen.dart` (Gantt-lite) reusing `lib/screens/calendar_screen.dart` patterns.
   - Add `lib/screens/project_metrics_screen.dart` or extend `lib/screens/finance_screen.dart` for global performance metrics.
5. Wire navigation and providers:
   - Consolidate router: update `lib/app/router.dart` (and remove or align `lib/app/app_router.dart`) to include routes: `/projects` (Dashboard), `/projects/create`, `/projects/:id`, `/projects/calendar`, `/projects/metrics`.
   - Register `ProjectController` provider in `lib/main.dart` (similar to `DashboardController`) and ensure `MainScreen` nav bar links to Projects if needed.
6. Data & UX integration:
   - Implement light local persistence (in-memory + optional JSON) in `ProjectController` for prototyping.
   - Add placeholders/hooks for backend endpoints (invite, file upload, finance sync) and surface graceful offline behavior.

### Further Considerations
1. Router choice: consolidate to `lib/app/router.dart` (Option A) or update `main.dart` to import `lib/app/router.dart` instead of `app_router.dart` (Option B). Recommend Option A (consolidation). -- import router consolidation preferred.
2. Backend vs Mock: Do you want real API integration now or staged mock data? Option A: Mock local for fast UI; Option B: Wire API endpoints (requires spec).  ----- MOCK preferred for initial UI.
3. External invites: implement secure token-based link stub now; backend required for real invite acceptance and account-join flow. -- will be implemented later. ----- now focus on UI.


### File targets (examples)
- Models: `lib/common/models/project.dart`, `task.dart`, `member.dart`, `project_file.dart`, `finance.dart`
- Controller: `lib/controllers/project_controller.dart`
- Widgets: `lib/app/widgets/project_card.dart`, `member_avatar.dart`, `discussion_feed.dart`, `finance_summary.dart`
- Screens: `lib/screens/project_detail_screen.dart`, `project_calendar_screen.dart`, `project_timeline_screen.dart`, `project_metrics_screen.dart`, plus updating `dashboard_screen.dart` and `create_project_screen.dart`
- Router: `lib/app/router.dart` (update) and remove/align `lib/app/app_router.dart`
- Registration in `lib/main.dart`: add `ChangeNotifierProvider(create: (_) => ProjectController())`

### Estimates (rough)
- My Projects Dashboard (UI + filters + cards): Medium (1–2 days)
- Project Detail (all sections: tasks, files, discussion, finance): Large (2–4 days)
- Create Project (fast flow + invitations stub): Small→Medium (0.5–1.5 days)
- Collaboration & Invitations (link & onboarding stub): Medium (1–2 days; backend needed for full)
- Calendar / Timeline (calendar + simple Gantt + drag/drop): Large (2–4 days)
- Global Performance screen (metrics visualization): Small→Medium (1 day)

Pause for review: this is a draft plan. Which options do you prefer for the router (consolidate vs adapt main import), backend vs mock data, and whether I should produce the detailed UI wireframes and exact widget props next?
