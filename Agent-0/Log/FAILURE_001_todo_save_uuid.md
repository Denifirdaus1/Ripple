# Failure Log: Todo Save Error 22P02

**Date:** 2025-12-30
**Error Code:** 22P02
**Message:** `invalid input syntax for type uuid: ""`
**Context:** Saving a Todo item.
**Trace:**
`PostgrestBuilder._parseResponse` -> `TodoRepositoryImpl.saveTodo`

**Analysis:**
The error indicates that an empty string `""` is being passed to a PostgreSQL column of type `uuid`. The likely culprits are:
- `id` (should be omitted on create, or valid UUID on update)
- `user_id` (must be valid UUID)
- `milestone_id` (nullable UUID)
- `parent_todo_id` (nullable UUID)

**Action Items:**
1. Verify Supabase Schema.
2. Check `TodoModel.toJson` logic.
3. Verify `userId` presence in `TodosOverviewBloc`.
