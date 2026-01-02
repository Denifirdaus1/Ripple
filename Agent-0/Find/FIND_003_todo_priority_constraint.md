# Todo Priority Constraint Violation - Schema Mismatch

**ID:** FIND_003 | **Status:** ✅ Resolved | **Prioritas:** 🔴 High
**Dibuat:** 2025-12-31 | **Update:** 2025-12-31
**Solution:** Direct code fix - removed TodoPriority.none, aligned with DB schema

---

## 📝 Deskripsi Masalah

### Error Log
```
PostgrestException(message: new row for relation "todos" violates check constraint "todos_priority_check", code: 23514, details: Bad Request, hint: null)
```

### Root Cause
**Schema Mismatch antara Database dan Application Code:**

| Component | Priority Values |
|:----------|:----------------|
| **Database** (`06_database_schema.md` line 89) | `CHECK (priority IN ('high', 'medium', 'low'))` |
| **Dart Code** (`todo.dart` line 3) | `enum TodoPriority { high, medium, low, none }` |
| **Default Value in Dart** | `TodoPriority.none` |

**Problem:** When user creates a todo without explicitly setting priority, Dart code uses `TodoPriority.none` as default, which gets serialized to string `'none'`. Database rejects this because the CHECK constraint only allows `['high', 'medium', 'low']`.

---

## 🕵️ Analisis & Hipotesis

### Affected Code Files
- [x] [todo.dart](file:///c:/Project/ripple/lib/features/todo/domain/entities/todo.dart) - Line 3, 33: Defines enum dengan 'none' dan uses as default
- [x] [todo_model.dart](file:///c:/Project/ripple/lib/features/todo/data/models/todo_model.dart) - Line 106-113: Converts enum to string including 'none'
- [x] [06_database_schema.md](file:///c:/Project/ripple/Agent-0/Topic/TOPIC_001_ripple_mvp/06_database_schema.md) - Line 88-89: DB constraint definition

### When Does This Error Occur?
- ✅ Creating new todo without explicitly setting priority
- ✅ Any todo that uses default `priority = TodoPriority.none`
- ❌ Won't happen if user explicitly selects high/medium/low in UI

---

## 💡 Ide Solusi

### Option A: Remove 'none' dari Dart, Align dengan DB *(Recommended)*
**Change Dart code to match DB constraint:**
```dart
// todo.dart - REMOVE 'none'
enum TodoPriority { high, medium, low }

// Update default to match DB default
const Todo({
  //...
  this.priority = TodoPriority.medium,  // Match DB default
})
```

**Pros:**
- Aligns with DB schema (single source of truth)
- DB already has `DEFAULT 'medium'`
- No migration needed
- Simpler - forces user to pick priority

**Cons:**
- Breaking change if any existing code relies on TodoPriority.none

---

### Option B: Update DB Constraint to Allow 'none'
**Change DB schema:**
```sql
ALTER TABLE public.todos 
DROP CONSTRAINT todos_priority_check;

ALTER TABLE public.todos 
ADD CONSTRAINT todos_priority_check 
CHECK (priority IN ('high', 'medium', 'low', 'none'));

ALTER TABLE public.todos 
ALTER COLUMN priority SET DEFAULT 'none';
```

**Pros:**
- No Dart code changes
- Preserves TodoPriority.none semantics

**Cons:**
- Requires DB migration
- 'none' might not make semantic sense (every todo should have priority)
- Less explicit - "none" vs just using "low" priority

---

## 🔗 Terkait
Topic: [TOPIC_001](../Topic/TOPIC_001_ripple_mvp/_main.md) - Ripple MVP
Schema: [06_database_schema.md](../Topic/TOPIC_001_ripple_mvp/06_database_schema.md)
