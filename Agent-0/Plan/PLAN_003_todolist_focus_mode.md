# PLAN_003: Implement TodoList & Focus Mode

**ID:** PLAN_003 | **Status:** 🏗️ In Progress | **Prioritas:** 🔴 High
**Terkait:** [TOPIC_001](../Topic/TOPIC_001_ripple_mvp/_main.md)
**Constraint:** Clean Architecture, Flutter Bloc, Supabase

---

# Goal Description
Implement the core productivity features of Ripple: **TodoList** and **Focus Mode (Pomodoro)**. This plan covers the full stack implementation from Domain entities to Data repositories (Supabase) and Presentation (Bloc/UI).

The implementation will strictly follow **Clean Architecture** and use **Supabase** as the single source of truth, leveraging the existing tables (`todos`, `focus_sessions`) verified in the research phase.

## User Review Required
> [!IMPORTANT]
> **State Management Strategy**:
> - **Todos**: Uses `Bloc` (complex event handling: stream subscription, filtering, undo).
> - **Focus Timer**: Uses `Cubit` (simpler state: tick, pause, resume).
>
> **Supabase Integration**:
> - Direct integration via `supabase_flutter` package in Data Layer.
> - No local database (Offline support is purely memory-based for MVP, or `hive` if strictly needed later. Current plan assumes online-first).

---

## Proposed Changes

### 1. Domain Layer (Core Business Logic)
Define the contracts and core entities.

#### [NEW] [lib/features/todo/domain/entities](file:///c:/Project/ripple/lib/features/todo/domain/entities/)
- `todo.dart`: Entity class with properties matching schema (`id`, `title`, `priority`, `isCompleted`, `dueDate`, `milestoneId`).
- `focus_session.dart`: Entity for tracking pomodoro sessions.

#### [NEW] [lib/features/todo/domain/repositories](file:///c:/Project/ripple/lib/features/todo/domain/repositories/)
- `todo_repository.dart`: Interface defining `getTodos()`, `saveTodo()`, `deleteTodo()`.
- `focus_repository.dart`: Interface for `saveSession()`.

#### [NEW] [lib/features/todo/domain/usecases](file:///c:/Project/ripple/lib/features/todo/domain/usecases/)
- `get_todos_stream.dart`: Watch functionality.
- `manage_todo.dart`: Add/Edit/Toggle.
- `start_focus_session.dart`: Logic to start a session.

### 2. Data Layer (Supabase Implementation)
Implement the interfaces using Supabase SDK.

#### [NEW] [lib/features/todo/data/models](file:///c:/Project/ripple/lib/features/todo/data/models/)
- `todo_model.dart`: `fromJson`/`toJson` mapping to Supabase `todos` table.
- `focus_session_model.dart`: Mapping for `focus_sessions` table.

#### [NEW] [lib/features/todo/data/datasources](file:///c:/Project/ripple/lib/features/todo/data/datasources/)
- `todo_remote_data_source.dart`: Calls `SupabaseClient.from('todos')`.

#### [NEW] [lib/features/todo/data/repositories](file:///c:/Project/ripple/lib/features/todo/data/repositories/)
- `todo_repository_impl.dart`: Implementation of `TodoRepository`.

### 3. Presentation Layer (UI & State)
Blocs and UI Screens.

#### [NEW] [lib/features/todo/presentation/bloc](file:///c:/Project/ripple/lib/features/todo/presentation/bloc/)
- `todos_overview_bloc.dart`: Handles loading list, filtering (All/Active/Completed), and real-time updates.
- `todo_edit_cubit.dart`: Manages form state for adding/editing.
- `focus_timer_cubit.dart`: Manages the timer countdown (Work/Break logic).

#### [NEW] [lib/features/todo/presentation/pages](file:///c:/Project/ripple/lib/features/todo/presentation/pages/)
- `todos_page.dart`: Main list view using `SliverList` or `ListView`.
- `todo_edit_sheet.dart`: BottomSheet for quick add.
- `focus_timer_page.dart`: Full screen timer UI with circular progress.

#### [NEW] [lib/features/todo/presentation/widgets](file:///c:/Project/ripple/lib/features/todo/presentation/widgets/)
- `todo_list_tile.dart`: Custom tile with checkbox and priority indicator.
- `timer_display.dart`: Reusable timer widget.

### 4. Dependency Injection
#### [MODIFY] [lib/injection_container.dart](file:///c:/Project/ripple/lib/injection_container.dart)
- Register `TodoRepository`, `TodoRemoteDataSource`, and Blocs using `get_it`.

---

## Verification Plan

### Automated Tests
Run unit tests for Domain and Bloc logic.
```bash
flutter test test/features/todo/domain
flutter test test/features/todo/presentation/bloc
```

### Manual Verification
1.  **Add Todo**: Open app, tap FAB, create Todo "Test Task" (Priority: High). Verify it appears in list.
2.  **Supabase Check**: Open Supabase Dashboard -> Table Editor -> `todos`. Verify row exists.
3.  **Realtime**: Open app in 2 simulators. Add todo in A, verify it appears in B instantly.
4.  **Focus Mode**: Swipe on Todo -> Start Focus. Verify Timer starts.
5.  **Complete Session**: Let timer finish. Verify `focus_sessions` table recording.
