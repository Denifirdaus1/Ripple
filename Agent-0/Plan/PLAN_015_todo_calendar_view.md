# Implement Todo Calendar View (Syncfusion)

**ID:** PLAN_015 | **Status:** 📋 Backlog | **Prioritas:** 🔴 High
**Dibuat:** 2025-12-31 | **Update:** 2025-12-31

---

## 🎯 Tujuan

Menambahkan **Calendar View** (mode kalender) pada TodosPage untuk menampilkan scheduled todos dalam format Day/Week Timeline, menggunakan library `syncfusion_flutter_calendar`. User bisa toggle antara **List View** dan **Calendar View**.

---

## 📚 Research Summary

**Package:** `syncfusion_flutter_calendar: ^32.1.21` (Latest: Dec 2024)  
**License:** Free for small teams (<5 devs, <$1M revenue)  
**Note:** License key registration NOT required since v18.3.0.x  

**Key Features:**
- Day, Week, Month, Timeline views
- Drag & Drop appointments
- Recurring events (RRULE)
- Current time indicator
- Custom working hours

---

## 🏗️ Prerequisite

Schema DB sudah siap:
- `todos.start_time` (timestamptz) ✅
- `todos.end_time` (timestamptz) ✅
- `todos.is_scheduled` (boolean) ✅
- `todos.recurrence_rule` (jsonb) ✅

---

## 🛠️ Strategi Implementasi

### Phase 1: Setup & Dependency

1. [ ] **Add dependency** ke `pubspec.yaml`:
   ```yaml
   dependencies:
     syncfusion_flutter_calendar: ^32.1.21
   ```

2. [ ] **Register license key** (opsional, sudah tidak wajib):
   ```dart
   // main.dart
   import 'package:syncfusion_flutter_core/core.dart';
   
   void main() {
     SyncfusionLicense.registerLicense("LICENSE_KEY_HERE");
     runApp(const RippleApp());
   }
   ```

---

### Phase 2: Create Calendar Data Source

3. [ ] **Create `TodoCalendarDataSource`** di `lib/features/todo/data/datasources/`:
   ```dart
   class TodoCalendarDataSource extends CalendarDataSource {
     TodoCalendarDataSource(List<Todo> todos) {
       appointments = todos.where((t) => t.isScheduled && t.startTime != null).toList();
     }
   
     @override
     DateTime getStartTime(int index) => (appointments![index] as Todo).startTime!;
   
     @override
     DateTime getEndTime(int index) => 
       (appointments![index] as Todo).endTime ?? 
       (appointments![index] as Todo).startTime!.add(Duration(hours: 1));
   
     @override
     String getSubject(int index) => (appointments![index] as Todo).title;
   
     @override
     Color getColor(int index) {
       final todo = appointments![index] as Todo;
       switch (todo.priority) {
         case TodoPriority.high: return AppColors.coralPink;
         case TodoPriority.medium: return AppColors.warmTangerine;
         case TodoPriority.low: return AppColors.rippleBlue;
       }
     }
   
     @override
     bool isAllDay(int index) => false;
   }
   ```

---

### Phase 3: Update TodosPage UI

4. [ ] **Add view mode state** di `TodosPage`:
   ```dart
   enum TodoViewMode { list, calendar }
   
   TodoViewMode _viewMode = TodoViewMode.list;
   ```

5. [ ] **Add toggle button** di header/AppBar:
   ```dart
   IconButton(
     icon: Icon(_viewMode == TodoViewMode.list 
       ? PhosphorIcons.calendarBlank() 
       : PhosphorIcons.list()),
     onPressed: () => setState(() {
       _viewMode = _viewMode == TodoViewMode.list 
         ? TodoViewMode.calendar 
         : TodoViewMode.list;
     }),
   )
   ```

6. [ ] **Render SfCalendar** when calendar mode active:
   ```dart
   if (_viewMode == TodoViewMode.calendar)
     SfCalendar(
       view: CalendarView.day,
       dataSource: TodoCalendarDataSource(todos),
       timeSlotViewSettings: TimeSlotViewSettings(
         startHour: 0,
         endHour: 24,
         timeInterval: Duration(minutes: 60),
       ),
       showCurrentTimeIndicator: true,
       onTap: (details) {
         if (details.appointments?.isNotEmpty ?? false) {
           final todo = details.appointments!.first as Todo;
           _openEditSheet(context, todo: todo);
         }
       },
     )
   ```

---

### Phase 4: Theming & Polish

7. [ ] **Apply Ripple theme colors** ke calendar:
   ```dart
   SfCalendar(
     todayHighlightColor: AppColors.rippleBlue,
     cellBorderColor: AppColors.softGray,
     headerStyle: CalendarHeaderStyle(
       textStyle: AppTypography.textTheme.titleMedium,
       backgroundColor: AppColors.paperWhite,
     ),
     viewHeaderStyle: ViewHeaderStyle(
       dayTextStyle: TextStyle(color: AppColors.textSecondary),
       dateTextStyle: TextStyle(color: AppColors.textPrimary),
     ),
   )
   ```

8. [ ] **Handle empty state** - Show message jika tidak ada scheduled todos

---

## 📁 Files to Create/Modify

| Action | File |
|--------|------|
| CREATE | `lib/features/todo/data/datasources/todo_calendar_datasource.dart` |
| MODIFY | `lib/features/todo/presentation/pages/todos_page.dart` |
| MODIFY | `lib/main.dart` (optional: register license) |
| MODIFY | `pubspec.yaml` |

---

## ✅ Kriteria Sukses

- [ ] `flutter analyze` clean
- [ ] Toggle button visible di TodosPage header
- [ ] Calendar view shows scheduled todos dengan waktu yang benar
- [ ] Tap on calendar appointment opens edit sheet
- [ ] UI theme consistent dengan Ripple design system
- [ ] Regular (non-scheduled) todos tetap tampil di List view

---

## 🔗 Terkait

**Topic:** [TOPIC_003](../Topic/TOPIC_003_calendar_library.md) - Calendar Library Research  
**Find:** -  
**Depends on:** PLAN_014 (Phase 2: Scheduled Todo)
