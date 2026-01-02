# Implementation Plan - Fix Schema Mismatches

**ID:** PLAN_012 | **Status:** ✅ Implemented | **Task:** Auditing Feature vs Schema Sync

---

# Goal Description
Fix schema synchronization issues identified in [FIND_004](../Find/FIND_004_schema_audit.md) to ensure robust database operations for Notifications and Milestones, preventing runtime exceptions on non-mobile platforms.

## User Review Required
> [!NOTE]
> Desktop platforms (Windows/macOS) will report as 'web' to the database for the `platform` column in `user_devices` table, as the database constraint only allows `('android', 'ios', 'web')`.

## Proposed Changes

### Notification Feature
#### [MODIFY] [notification_repository_impl.dart](file:///c:/Project/ripple/lib/features/notification/data/repositories/notification_repository_impl.dart)
- Import `package:flutter/foundation.dart` for `kIsWeb`.
- Implement robust platform detection:
  - If `kIsWeb` -> 'web'
  - If `!kIsWeb` && `Platform.isAndroid` -> 'android'
  - If `!kIsWeb` && `Platform.isIOS` -> 'ios'
  - Default -> 'web' (Fallback for Desktop to satisfy DB constraint)

### Milestone Feature
#### [MODIFY] [milestone_model.dart](file:///c:/Project/ripple/lib/features/milestone/data/models/milestone_model.dart)
- Update `toJson` to format `target_date` as `YYYY-MM-DD` (strip time component).

## Verification Plan

### Automated Tests
- Run `flutter analyze` to ensure no `dart:io` issues on web path (though analyzer might not catch conditional imports without compilation, clean code is key).
- Run `flutter test` to ensure existing model tests pass.

### Manual Verification
- **Constraint Check**: Verify `NotificationRepositoryImpl` logic visually ensures output is always one of `['android', 'ios', 'web']`.
