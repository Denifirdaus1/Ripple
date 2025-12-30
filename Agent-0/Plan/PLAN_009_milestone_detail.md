# PLAN_009: Milestone Detail Feature

**Status:** 📝 Draft  
**Priority:** 🔴 High  
**Parent:** [PLAN_005 - Milestones & Goals](PLAN_005_milestone_goals.md)

---

## Goal Description

Implement the **Milestone Detail View** to allow users to fully manage milestones within a Goal. This completes the Milestones & Goals feature by enabling:
- Viewing milestones inside a goal (timeline visualization).
- Adding, editing, deleting milestones.
- Marking milestones as complete.
- Attaching Todos to milestones for micro-progress tracking.
- Uploading banner images for visual motivation.

---

## User Review Required

> [!IMPORTANT]
> **Schema Verified**: The `milestones` and `todos` tables are already in Supabase. No migration needed.

> [!NOTE]
> **UI Choice**: Using custom-built timeline (not external package) for full control over Ripple's design system.

---

## Existing Schema (Verified via Supabase MCP)

### `goals` Table
| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | uuid | NO | gen_random_uuid() |
| user_id | uuid | NO | - |
| title | text | NO | - |
| description | text | YES | - |
| target_year | integer | YES | - |
| created_at | timestamptz | NO | now() |
| updated_at | timestamptz | NO | now() |

### `milestones` Table
| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| id | uuid | NO | gen_random_uuid() |
| goal_id | uuid | NO | FK → goals.id |
| title | text | NO | - |
| target_date | date | YES | - |
| notes | jsonb | YES | - |
| banner_url | text | YES | - |
| is_completed | boolean | NO | false |
| completed_at | timestamptz | YES | - |
| order_index | integer | NO | 0 |
| created_at | timestamptz | NO | now() |
| updated_at | timestamptz | NO | now() |

### `todos` Table (FK Relationship)
| Column | Type | Notes |
|--------|------|-------|
| milestone_id | uuid | FK → milestones.id (nullable) |

---

## Proposed Changes

### 1. Domain Layer

#### [NEW] `lib/features/milestone/domain/usecases/milestone_detail_usecases.dart`
- `GetMilestonesForGoal(String goalId)` → `Stream<List<Milestone>>`.
- `DeleteMilestone(String milestoneId)`.
- `GetTodosForMilestone(String milestoneId)` → `Stream<List<Todo>>`.

#### [MODIFY] `lib/features/milestone/domain/repositories/milestone_repository.dart`
- Add: `deleteMilestone(String id)`.
- Add: `getTodosForMilestone(String milestoneId)`.
- Add: `attachTodoToMilestone(String todoId, String milestoneId)`.
- Add: `detachTodoFromMilestone(String todoId)`.

---

### 2. Data Layer

#### [MODIFY] `lib/features/milestone/data/repositories/milestone_repository_impl.dart`
- Implement `deleteMilestone`.
- Implement `getTodosForMilestone` (query `todos` where `milestone_id = ?`).
- Implement `attachTodoToMilestone` (update `todos.milestone_id`).
- Implement `detachTodoFromMilestone` (set `todos.milestone_id = null`).

---

### 3. Presentation Layer

#### [NEW] `lib/features/milestone/presentation/bloc/milestone_detail_bloc.dart`
- **Events**:
    - `MilestoneDetailSubscriptionRequested(goalId)`
    - `MilestoneDetailMilestoneCreated(milestone)`
    - `MilestoneDetailMilestoneUpdated(milestone)`
    - `MilestoneDetailMilestoneDeleted(milestoneId)`
    - `MilestoneDetailTodoAttached(todoId, milestoneId)`
- **State**:
    - `goal: Goal`
    - `milestones: List<Milestone>`
    - `status: loading | success | failure`

#### [NEW] `lib/features/milestone/presentation/pages/goal_detail_page.dart`
- Route: `/goals/:goalId`
- Displays:
    - Goal Title & Description (header).
    - Overall progress bar.
    - Milestone Timeline (vertical).
    - FAB to add new milestone.

#### [NEW] `lib/features/milestone/presentation/widgets/milestone_timeline.dart`
- Custom timeline widget using `Column` + `IntrinsicHeight` + `Row`.
- Each milestone rendered as a card with connecting line.
- Indicator: Checkmark if completed, dot if pending.

#### [NEW] `lib/features/milestone/presentation/widgets/milestone_card_detail.dart`
- Displays:
    - Title, Target Date.
    - Banner Image (if exists).
    - Attached Todos (progress: X/Y).
    - Mark Complete / Undo button.

#### [NEW] `lib/features/milestone/presentation/widgets/add_milestone_sheet.dart`
- BottomSheet for creating/editing a milestone.
- Fields: Title, Target Date, Notes (optional).
- Image Picker for Banner (future: upload to Supabase Storage).

---

### 4. Navigation

#### [MODIFY] `lib/core/router/app_router.dart`
- Add route: `/goals/:goalId` → `GoalDetailPage`.

#### [MODIFY] `lib/features/milestone/presentation/widgets/goal_card.dart`
- `onTap` → `context.push('/goals/${goal.id}')`.

---

### 5. Dependency Injection

#### [MODIFY] `lib/core/injection/injection_container.dart`
- Register `MilestoneDetailBloc`.
- Register new Use Cases.

---

## Technical Notes (From Research)

### Bloc Pattern (Context7)
- Use `emit.forEach<List<Milestone>>(...)` to subscribe to milestone stream.
- Handle events for CRUD operations, updating state immutably.
- Reference: `TodosOverviewBloc` pattern from `flutter_bloc` docs.

### Timeline UI (Exa Research)
- **Option A**: `timeline_tile` package (simple, horizontal/vertical).
- **Option B**: Custom build using `Column` + `IntrinsicHeight` + `Row` (more control).
- **Decision**: **Option B (Custom)** to match Ripple design system exactly.

---

## Verification Plan

### Manual Verification
1.  **Navigate**: Tap a Goal Card → should open `GoalDetailPage`.
2.  **Add Milestone**: Tap FAB → fill form → save. Verify milestone appears in timeline.
3.  **Complete Milestone**: Tap checkbox. Verify indicator changes & `completed_at` updates.
4.  **Attach Todo**: (Future) Link a todo. Verify progress updates.
5.  **Delete Milestone**: Swipe or delete button. Verify removal.

### Automated Tests
- Unit tests for `MilestoneDetailBloc`.
- Widget tests for `MilestoneTimeline`.
