# PLAN_005: Implement Milestones & Goals Feature

**ID:** PLAN_005 | **Status:** 🏗️ In Progress | **Prioritas:** 🔴 High
**Terkait:** [TOPIC_001](../Topic/TOPIC_001_ripple_mvp/_main.md)
**Constraint:** Clean Architecture, Supabase, Gamification UI

---

# Goal Description
Implement the "Big Picture" layer of Ripple: **Goals** (Life Areas/Long-term) and **Milestones** (Checkpoints). This provides the context for daily tasks.

The implementation includes:
1.  **Goal Management**: Creating broad goals (e.g., "Become a Senior Developer").
2.  **Milestone Tracking**: Breaking goals into time-bound milestones.
3.  **Progress Visualization**: Automatically calculating progress based on linked Todos.

## User Review Required
> [!IMPORTANT]
> **Progress Calculation**:
> - **Milestone Progress**: `(Count of Completed Todos for Milestone) / (Total Todos for Milestone) * 100%`
> - **Goal Progress**: Average of its Milestones' progress OR `(Completed Milestones / Total Milestones)`. *Decision: Use Average of Milestones for smoother granularity.*
>
> **UI Libraries**:
> - `percent_indicator`: For circular/linear progress bars.
> - `flutter_staggered_grid_view` (optional) or `Wrap`: For Goal dashboard.

---

## Proposed Changes

### 1. Domain Layer
#### [NEW] [lib/features/milestone/domain/entities](file:///c:/Project/ripple/lib/features/milestone/domain/entities/)
- `goal.dart`: Entity (`id`, `title`, `description`, `color`, `icon`).
- `milestone.dart`: Entity (`id`, `goalId`, `title`, `targetDate`, `isCompleted`).

#### [NEW] [lib/features/milestone/domain/repositories](file:///c:/Project/ripple/lib/features/milestone/domain/repositories/)
- `milestone_repository.dart`: Methods for Goal and Milestone CRUD.
    - `getGoalsWithProgress()`: returns Goals with calculated progress.
    - `getMilestonesForGoal(String goalId)`

#### [NEW] [lib/features/milestone/domain/usecases](file:///c:/Project/ripple/lib/features/milestone/domain/usecases/)
- `create_goal.dart`, `create_milestone.dart`.
- `calculate_goal_progress.dart`: Domain logic to aggregate status.

### 2. Data Layer
#### [NEW] [lib/features/milestone/data/models](file:///c:/Project/ripple/lib/features/milestone/data/models/)
- `goal_model.dart`: Supabase mapping.
- `milestone_model.dart`: Supabase mapping.

#### [NEW] [lib/features/milestone/data/repositories](file:///c:/Project/ripple/lib/features/milestone/data/repositories/)
- `milestone_repository_impl.dart`:
    - Fetch Goals via standard query.
    - Fetch Progress: Can be done via a custom SQL View `view_goal_progress` (Recommended for performance) OR fetching counts. *Plan assumes client-side calculation for MVP to avoid complex SQL migrations for now, unless performance is slow.*

### 3. Presentation Layer
#### [NEW] [lib/features/milestone/presentation/bloc](file:///c:/Project/ripple/lib/features/milestone/presentation/bloc/)
- `goal_list_bloc.dart`: Manages the Dashboard state.
- `milestone_detail_bloc.dart`: Manages the Milestone view (showing related Todos).

#### [NEW] [lib/features/milestone/presentation/pages](file:///c:/Project/ripple/lib/features/milestone/presentation/pages/)
- `goals_dashboard_page.dart`: Grid of Goal Cards.
- `milestone_timeline_page.dart`: Vertical timeline of milestones for a specific goal.

#### [NEW] [lib/features/milestone/presentation/widgets](file:///c:/Project/ripple/lib/features/milestone/presentation/widgets/)
- `goal_card.dart`: Visual card with progress bar.
- `milestone_step_card.dart`: Timeline step widget.

### 4. Dependency Injection
#### [MODIFY] [lib/injection_container.dart](file:///c:/Project/ripple/lib/injection_container.dart)
- Register Milestone feature dependencies.

---

## Verification Plan

### Automated Tests
```bash
flutter test test/features/milestone/domain/usecases/calculate_progress_test.dart
```
- Test Calculation: Mock a Goal with 2 Milestones (1 completed, 1 active). Verify Goal progress is 50%.

### Manual Verification
1.  **Create Goal**: "Learn Flutter".
2.  **Create Milestone**: "Finish Course" (linked to Goal).
3.  **Link Todo**: Go to Todo List, create "Watch Section 1", link to "Finish Course".
4.  **Check Progress**: Dashboard show 0%.
5.  **Complete Todo**: Mark "Watch Section 1" as done.
6.  **Verify Progress**: Dashboard Goal "Learn Flutter" should show progress (e.g. 100% if only 1 task).
