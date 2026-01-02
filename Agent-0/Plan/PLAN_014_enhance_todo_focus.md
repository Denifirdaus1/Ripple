# PLAN_014: Enhance TodoList & Focus Mode

**ID:** PLAN_014 | **Status:** 📋 Backlog | **Prioritas:** 🔴 High
**Dibuat:** 2025-12-31 | **Update:** 2025-12-31
**Terkait:** [TOPIC_001](../Topic/TOPIC_001_ripple_mvp/01_todolist_focusmode.md), [PLAN_003](PLAN_003_todolist_focus_mode.md)

---

## 🎯 Gap Analysis - Current vs Required

### Current Implementation ❌
| Feature | Status |
|---------|--------|
| Basic Todo List (Priority-based) | ✅ Done |
| Filter (All/Active/Done) | ✅ Done |
| Basic Focus Timer (Pomodoro) | ✅ Done |
| Start/Pause/Stop Timer | ✅ Done |

### Missing Features per TOPIC_001 ❌
| Feature | Status | Priority |
|---------|--------|----------|
| **Scheduled Todo (Timeline UI)** | ❌ Missing | 🔴 High |
| - Timeline slot waktu harian | ❌ | |
| - Start/End time per todo | ❌ | |
| - Notifikasi tepat waktu | ❌ | |
| **Focus Mode Toggle per Todo** | ❌ Missing | 🔴 High |
| **Link Focus dari Notifikasi** | ❌ Missing | 🔴 High |
| **Session Tracking** | ❌ Missing | 🟡 Medium |
| - `sessionsCompleted` field | ❌ | |
| - Sync ke `focus_sessions` table | ❌ | |
| **Recurring Todo** | ❌ Missing | 🟡 Medium |
| - Dropdown repeat (Custom Days) | ❌ | |
| - Multi-select hari | ❌ | |
| - Per-day time override | ❌ | |
| **Focus Mode Global State** | ❌ Missing | 🟡 Medium |
| - Timer tetap jalan saat pindah tab | ❌ | |

---

## 🛠️ Strategi Implementasi

### Phase 1: Focus Mode Integration (Priority)
1. [ ] Add `focusModeEnabled` dan `focusDuration` ke Todo entity & model
2. [ ] Update TodoEditSheet dengan toggle Focus Mode
3. [ ] Migrate FocusTimerCubit ke Global (MultiBlocProvider di app.dart)
4. [ ] Implementasi "Start Focus" dari TodoItem (swipe atau long press)
5. [ ] Sync session ke `focus_sessions` table setelah complete

### Phase 2: Scheduled Todo & Timeline
6. [ ] Add `isScheduled`, `startTime`, `endTime` ke Todo entity & model
7. [ ] Create Timeline UI widget (Daily view dengan slot waktu)
8. [ ] Update TodoEditSheet untuk mode Scheduled (date/time picker)
9. [ ] Integrasi dengan Notification untuk trigger tepat waktu
10. [ ] Deep link dari notif → Focus Mode untuk todo tersebut

### Phase 3: Recurring Todo
11. [ ] Add `recurring` JSONB field ke Todo model
12. [ ] Create RecurringSelector widget (dropdown + multi-select hari)
13. [ ] Implement time override per hari (optional)
14. [ ] Backend logic untuk generate recurring instances

---

## 📐 Data Model Updates

### Todo Entity (Schema Aligned)
```dart
class Todo {
  // Core (Matches 'todos' table)
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String priority; // 'high', 'medium', 'low' (Changed from int)
  final bool isCompleted;
  final DateTime? completedAt;
  final String? milestoneId;
  
  // Scheduled Todo
  final bool isScheduled; // 'is_scheduled'
  final DateTime? scheduledDate; // 'scheduled_date' (For query performance/bucketing)
  final DateTime? startTime; // 'start_time'
  final DateTime? endTime; // 'end_time'
  
  // Focus Mode
  final bool focusEnabled; // 'focus_enabled' (mapped from focusModeEnabled)
  final int focusDurationMinutes; // 'focus_duration_minutes' (default 25)
  // Note: sessionsCompleted is calculated from joined 'focus_sessions' count, not stored in 'todos'
  
  // Recurring
  final Map<String, dynamic>? recurrenceRule; // 'recurrence_rule' (JSONB)
  // Format: {"days": [1,5,6], "time_overrides": {"6": {"start": "11:00", "end": "12:00"}}}
  
  // Notification
  final bool notificationSent; // 'notification_sent'
}
```

### Focus Session Entity (Schema Aligned)
```dart
class FocusSession {
  final String id;
  final String userId;
  final String todoId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String sessionType; // 'work', 'break'
  final bool wasCompleted;
  final bool wasInterrupted;
  final int durationMinutes;
}
```

---

## ✅ Kriteria Sukses

### Phase 1
- [ ] User bisa enable Focus Mode per todo
- [ ] Timer global (tetap jalan saat pindah tab)
- [ ] Session tersimpan ke `focus_sessions` table

### Phase 2
- [ ] User bisa set waktu start/end untuk todo
- [ ] Timeline UI menampilkan todo sesuai slot waktu
- [ ] Notifikasi muncul tepat waktu

### Phase 3
- [ ] User bisa set recurring (daily, specific days)
- [ ] Todo otomatis muncul sesuai jadwal

---

## 🔗 Related
- **Topic:** [TOPIC_001 - TodoList & Focus Mode](../Topic/TOPIC_001_ripple_mvp/01_todolist_focusmode.md)
- **Original Plan:** [PLAN_003](PLAN_003_todolist_focus_mode.md)
- **Find:** -
