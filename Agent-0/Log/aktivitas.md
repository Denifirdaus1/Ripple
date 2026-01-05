# Log Aktivitas

---

## 2025-12-28

| Waktu | Aktivitas | ID | Keterangan |
| :--- | :--- | :--- | :--- |
| 19:10 | Install | - | Agent-0 berhasil diinstall |
| 20:13 | Buat Topic | TOPIC_001 | Ripple MVP: Productivity App Vision (Expanded) |
| 20:38 | Update Topic | TOPIC_001 | Confirm all decisions, add Database Schema sub-topic |
| 21:05 | Deep Research | K_001 | Supabase Database Best Practices (RLS, Security, Cron) |
| 21:17 | Fix Schema | TOPIC_001 | Switch from locale-dependent TO_CHAR to ISODOW for recurring todos |
| 21:21 | Deep Research | R_001 | Push Notification System - FCM, Local Notifications, Architecture |
| 21:34 | Update Schema | TOPIC_001 | Add FCM Push Notifications: user_devices table, notification_sent field, cron jobs |

## 2025-12-29

| Waktu | Aktivitas | ID | Keterangan |
| :--- | :--- | :--- | :--- |
| 14:45 | Firebase Setup | TOPIC_001 | Create Firebase project `ripple-66854`, register Android app |
| 14:51 | Gradle Config | TOPIC_001 | Add Google Services plugin to `build.gradle.kts` (root & app level) |
| 14:54 | Add File | TOPIC_001 | Add `google-services.json` to `android/app/` |
| 14:55 | Add Packages | TOPIC_001 | Add `firebase_core`, `firebase_messaging` to pubspec.yaml |
| 14:56 | Init Firebase | TOPIC_001 | Update `main.dart` with Firebase init & background handler |
| 14:57 | Update Topic | TOPIC_001 | Update `07_push_notifications.md` with implementation progress |
| 15:04 | Deep Research | TOPIC_001 | FCM Permission, Token Storage, Edge Functions, pg_cron via Exa MCP |
| 15:10 | Update Topic | TOPIC_001 | Add comprehensive Step 1-5 guide for FCM implementation |
| 15:12 | Create Service | TOPIC_001 | Create `notification_service.dart` with permission, token, handlers |

## 2025-12-30

| Waktu | Aktivitas | ID | Keterangan |
| :--- | :--- | :--- | :--- |
| 08:43 | Restructure Topics | TOPIC_001 | Reorganize: Backend → 06, Client → 07 (Option C) |
| 08:45 | Update 06 | TOPIC_001 | Add Edge Functions section & update Vault with FCM secrets |
| 08:46 | Rewrite 07 | TOPIC_001 | Focus on client-side only, reference 06 for backend |
| 09:15 | Execute Plan | PLAN_001 | Implement Database Schema (8 Tables, Cron, Edge Fn) |
| 09:25 | Fix Schema | PLAN_001 | Verify Unique Constraint & Fix Generated Column Logic |
| 09:35 | Deep Research | PLAN_002 | RLS performance (auth.uid wrapper), search_path security |
| 09:38 | Buat Plan | PLAN_002 | Schema Security & Performance Fixes (11 Warnings) |
| 09:48 | Execute Plan | PLAN_002 | Fix 3 Functions, 8 RLS Policies, 2 FK Indexes |
| 09:50 | Verify | PLAN_002 | 0 Security WARN, 0 Performance WARN (Linter Clean) |
| 10:08 | Fix Vault | - | Corrected vault.create_secret argument order |
| 10:10 | Create Knowledge | K_002 | Database Production Ready Status recorded |

## 2025-12-31

| Waktu | Aktivitas | ID | Keterangan |
| :--- | :--- | :--- | :--- |
| 09:06 | Buat Finding | FIND_002 | Data Tidak Ter-load Setelah Re-login & Unexpected Signout |
| 09:10 | Buat Plan | PLAN_011 | Fix Auth Session & Data Loading Issues |
| 09:14 | Execute Plan | PLAN_011 | Phase 1: Auth-Aware Data Loading (BlocListener, ClearRequested events) |
| 09:18 | Execute Plan | PLAN_011 | Phase 2: Session Management (SessionService, token refresh) |
| 09:20 | Verify | PLAN_011 | ✅ flutter analyze clean, 10 tests passed |
| 09:34 | Buat Finding | FIND_003 | Todo Priority Constraint Violation - Schema Mismatch |
| 09:38 | Fix Direct | FIND_003 | Removed TodoPriority.none, aligned with DB schema (high/medium/low) |
| 09:40 | Verify | FIND_003 | ✅ flutter analyze clean, all tests passed |
| 10:45 | Audit | Lib/Features | Audited repositories against schema (FIND_004) |
| 10:50 | Implement | PLAN_013 | Implemented comprehensive logging using `AppLogger` across Auth, Todo, Notes, Milestone, and Notification features. Added logging to BLoC events and Repository CRUD operations. |
| 10:50 | Plan | PLAN_012 | Plan fixes for Notification platform & Milestone Date |
| 10:55 | Execute | PLAN_012 | Fixed notification platform detection & milestone date format |
| 10:58 | Verify | PLAN_012 | ✅ flutter analyze clean, tests passed |
| 11:00 | Implement | PLAN_014 | Standardized Reactive UI Patterns (Optimistic-Wait) across Todo, Notes, and Milestone features. Updated `NoteBloc` to support event-driven saving. Verified with `flutter analyze`. |
| 13:51 | Buat Plan | PLAN_014 | Enhance TodoList & Focus Mode - Gap Analysis vs TOPIC_001 |
| 15:57 | Buat Topic | TOPIC_003 | Flutter Calendar Timeline Library Research - Deep research with MCP Exa & Context7 |
| 16:58 | Buat Plan | PLAN_015 | Todo Calendar View (Syncfusion) - Implement Calendar Mode di TodosPage |
| 17:10 | Execute | PLAN_015 | Implemented SfCalendar toggle in TodosPage with TodoCalendarDataSource |
| 18:05 | Buat Plan | PLAN_016 | Implement Schedule Management - Add Date/Time Picker to TodoEditSheet |
| 07:45 | Fix DB | - | Fix `user_devices` unique constraint for FCM token upsert (FAILURE_002) |
| 08:10 | Buat Plan | PLAN_017 | FCM Notification System Optimization & Security Hardening |
| 08:25 | Buat Plan | PLAN_018 | Todo Notification Integration |
| 09:20 | Buat Finding | FIND_007 | Notification Timing & Delivery Failure |
| 18:45 | Fix | FIND_007 | System notification check + settings redirect in TodoEditSheet |
| 19:38 | Buat Plan | PLAN_019 | Notification Click Navigation & Custom Reminder |
| 19:45 | Implement | PLAN_019 | Click navigation + reminder dropdown complete |

### 2026-01-02
| Waktu | Aksi | Ref ID | Deskripsi |
| :--- | :--- | :--- | :--- |
| 08:12 | Research | PLAN_020 | Deep research: FCM deep linking, go_router, flutter_local_notifications |
| 08:15 | Buat Plan | PLAN_020 | Notification Deep Linking to Todo Detail |
| 08:20 | Implement | PLAN_020 | TodoDetailPage, route, navigation service, SQL function |
| 21:20 | Audit | Auth | Self-audit auth system: 11 error handling gaps identified |
| 21:23 | Implement | PLAN_021 | Created AuthErrorHandler, updated LoginCubit with user-friendly messages |

### 2026-01-03
| Waktu | Aksi | Ref ID | Deskripsi |
| :--- | :--- | :--- | :--- |
| 20:36 | Buat Plan | PLAN_021 | Fix Notes List Auto-Update (Root cause: listenWhen condition) |
| 20:36 | Implement | PLAN_021 | Fixed BlocListener condition in note_editor_page.dart |
| 20:55 | Buat Plan | PLAN_022 | Notes Enhancement & Mention System Fix |
| 20:56 | Implement | PLAN_022 | Phase 1-3: Fixed mention dialog, sync, and click navigation |
| 21:07 | Buat Plan | PLAN_023 | Note Editor UI Redesign (Notion-Style) |
| 21:12 | Implement | PLAN_023 | Schema migration + Note entity/model + UI redesign |
| 21:45 | Buat Plan | PLAN_024 | Note Editor UI Refinements & Advanced Tags |
| 22:10 | Implement | PLAN_024 | Schema user_tags + Tag entity/model + UI widgets + Cubit updates |
| 10:45 | Buat Plan | PLAN_025 | Note Card UI Fix & Data Sync Verification |
| 10:55 | Implement | PLAN_025 | Fixed NoteCard icons + priority chip UI |
| 11:13 | Buat Plan | PLAN_026 | Notes Save/Sync System Fix & FAB Bug |
| 11:16 | Implement | PLAN_026 | NoteBloc notification + FAB hidden on editor |
| 11:24 | Buat Plan | PLAN_027 | System Back Gesture Fix & Auto-Date Note |
| 11:26 | Implement | PLAN_027 | PopScope canPop:false + auto-date new note |
| 12:08 | Buat Plan | PLAN_028 | Notes Image Upload Feature |
| 12:15 | Implement | PLAN_028 | ImageUploadService + UI Integration |
| 17:23 | Buat Plan | PLAN_029 | Reusable Property Library System |
| 17:26 | Implement | PLAN_029 | Phase 1: Core Entities (PropertyType, Definition, Value) |
| 17:34 | Implement | PLAN_029 | Phase 2-4: UI Widgets + Notes Integration |
| 17:45 | Buat Plan | PLAN_030 | Property Sandbox System |
| 17:49 | Implement | PLAN_030 | Phase 1-4: DB Schema + Domain + Data + Presentation |
| 17:56 | Implement | PLAN_030 | Phase 5: Notes Integration (dynamic properties) |
| 18:52 | Research | PLAN_031 | Entity Properties Persistence strategies |
| 18:52 | Buat Plan | PLAN_031 | Entity Properties Persistence |
| 18:56 | Implement | PLAN_031 | All phases: DB + Entity + Model + Cubit |
| 11:04 | Buat Plan | PLAN_032 | Toolbar Sandbox Extension System |
| 11:08 | Implement | PLAN_032 | All phases: Domain + Registry + Tools + UI + Migration |
| 12:11 | Buat Plan | PLAN_033 | Notes Status & Description Properties |
| 12:34 | Implement | PLAN_033 | All phases: DB + Entity + Model + Registry + Cubit + UI + NoteCard |
| 13:55 | Buat Plan | PLAN_034 | Notes Menu Actions (Delete & Favorite) |
| 16:56 | Implement | PLAN_034 | All phases: DB + Entity + Model + Cubit + UI + NoteCard |
| 18:48 | Buat Plan | PLAN_035 | Fix Notes List Update After Delete |
| 18:50 | Implement | PLAN_035 | Added isDeleted guards to PopScope + BlocListener |
| 18:52 | Fix | Notes | Sort favorites to top in notes_page.dart |
| 19:03 | Buat Topic | TOPIC_004 | Universal Folder System |
| 19:03 | Buat Plan | PLAN_036 | Universal Folder System Implementation |

