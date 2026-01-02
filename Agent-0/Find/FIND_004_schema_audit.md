# Schema Audit: Feature vs Database Mismatches

**ID:** FIND_004 | **Status:** ✅ Resolved | **Prioritas:** 🔴 High
**Dibuat:** 2025-12-31 | **Update:** 2025-12-31
**Solution:**
1. Updated `NotificationRepositoryImpl` to map Desktop platforms to `'web'` fallback.
2. Updated `MilestoneModel.toJson` to strip time from `target_date`.

---

## 📝 Deskripsi Masalah

Following a comprehensive audit of `lib/features` regarding Supabase Schema synchronization, the following discrepancies were found between the Dart implementation and the Database Schema (`06_database_schema.md`).

### 1. Notification Platform Constraint Violation
*   **File:** `lib/features/notification/data/repositories/notification_repository_impl.dart`
*   **Code:**
    ```dart
    final platform = Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'unknown');
    // ...
    'platform': platform,
    ```
*   **Schema:** `CHECK (platform IN ('android', 'ios', 'web'))`
*   **Issue:** On Windows/MacOS (current user env), `platform` resolves to `'unknown'`. The database **rejects** this value due to the CHECK constraint.
*   **Secondary Issue:** Usage of `dart:io` `Platform` crashes on Web builds.

### 2. Milestone Target Date Format
*   **File:** `lib/features/milestone/data/models/milestone_model.dart`
*   **Code:** `'target_date': targetDate?.toIso8601String(),`
*   **Schema:** `target_date DATE`
*   **Issue:** `toIso8601String()` returns `YYYY-MM-DDTHH:MM:SS.ssss`. While Postgres is robust, standard practice for `DATE` columns is sending `YYYY-MM-DD` to avoid timezone offset confusion or truncation errors.

---

## 💡 Ide Solusi

### Fix 1: Notification Platform Logic
Update `NotificationRepositoryImpl` to:
1.  Use `kIsWeb` from `flutter/foundation` to support Web.
2.  Map Desktop platforms to 'web' (as fallback) or skip saving token if strictly mobile-only. Given this is a productivity app, 'web' is a reasonable fallback for desktop metadata if 'desktop' isn't in DB.
3.  **Better:** Check schema. Only `android`, `ios`, `web` allowed.
    *   Strategy: If `kIsWeb` -> 'web'. Else if Android -> 'android'. Else if iOS -> 'ios'. Else -> 'web' (treat desktop as web client for metadata) OR don't save.

### Fix 2: Milestone Date Formatting
Update `MilestoneModel.toJson`:
```dart
'target_date': targetDate?.toIso8601String().split('T').first,
```

---

## 🔗 Terkait
*   [FIND_003](FIND_003_todo_priority_constraint.md) (Previously fixed priority issue)
*   [PLAN_012](../Plan/PLAN_012_fix_schema_mismatches.md)
