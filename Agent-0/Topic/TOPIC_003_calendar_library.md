# Flutter Calendar Timeline Library Research

**ID:** TOPIC_003 | **Status:** 💬 Aktif | **Prioritas:** 🟡 Normal
**Dibuat:** 2025-12-31 | **Update:** 2025-12-31
**Tipe:** 📄 Simple

---

## Deskripsi
Riset library Flutter untuk menambahkan Calendar Mode pada Todo feature. User menginginkan tampilan seperti Google Calendar dengan:
1. **Day View Timeline** - Slot waktu per jam (00:00 - 24:00)  
2. **Week Strip Calendar** - Horizontal date selector dengan hari-hari dalam seminggu

---

## 📷 Reference UI

![Timeline View](file:///C:/Users/Deni/.gemini/antigravity/brain/d60f50be-abb1-4e1a-b4ea-566cebf642e1/uploaded_image_0_1767171461696.jpg)

![Week Strip View](file:///C:/Users/Deni/.gemini/antigravity/brain/d60f50be-abb1-4e1a-b4ea-566cebf642e1/uploaded_image_1_1767171461696.jpg)

---

## 🔬 Research Findings

### Top Candidates Comparison

| Package | Stars | Day View | Week Strip | Timeline | License | Best For |
|---------|-------|----------|------------|----------|---------|----------|
| **syncfusion_flutter_calendar** | ⭐ High | ✅ | ✅ | ✅ | Community* | Full-featured calendar |
| **calendar_day_view** | ⭐ Medium | ✅ | ❌ | ✅ | MIT | Focused day view |
| **table_calendar** | ⭐ High | ❌ | ✅ | ❌ | MIT | Month/week picker |
| **flutter_customizable_calendar** | ⭐ Medium | ✅ | ✅ | ✅ | MIT | Customizable |
| **infinite_calendar_view** | ⭐ New | ✅ | ✅ | ✅ | MIT | Infinite scroll |

> *Syncfusion: Free for small teams (<5 devs + <$1M revenue)

---

### 🥇 **RECOMMENDED: syncfusion_flutter_calendar**

**Alasan:**
1. ✅ **Timeline View** - Native support untuk day, week, timeline views
2. ✅ **Day View** - Hourly slots dengan event overlay
3. ✅ **Week View** - 7-day horizontal view
4. ✅ **Resource Grouping** - Bisa group by category
5. ✅ **Drag & Drop** - Native resize/move appointments
6. ✅ **Recurring Events** - Built-in RRULE support
7. ✅ **Current Time Indicator** - Line showing current time
8. ✅ **Working Hours** - Customizable working hours display
9. ✅ **Cross-platform** - Android, iOS, Web, Desktop
10. ❌ **Caveat:** Perlu license untuk commercial (tapi free tier available)

```dart
// Basic Usage
SfCalendar(
  view: CalendarView.day, // day, week, workWeek, month, timelineDay, timelineWeek
  dataSource: MeetingDataSource(_getDataSource()),
  timeSlotViewSettings: TimeSlotViewSettings(
    startHour: 0,
    endHour: 24,
    timeInterval: Duration(minutes: 60),
  ),
)
```

---

### 🥈 **Alternative: calendar_day_view**

**Alasan:**
- ✅ Lightweight, focused on day view only
- ✅ MIT License (no restrictions)
- ✅ Multiple view types: Overflow, Category, InRow
- ❌ Tidak ada built-in week strip
- ❌ Perlu combine dengan `table_calendar` untuk date picker

```dart
CalendarDayView.overflow(
  events: events,
  heightPerMin: 1,
  showCurrentTimeLine: true,
  startOfDay: TimeOfDay(hour: 0, minute: 0),
  endOfDay: TimeOfDay(hour: 22, minute: 0),
  itemBuilder: (context, constraints, event) => EventCard(event: event),
)
```

---

### 🥉 **Combo Option: table_calendar + calendar_day_view**

Gunakan **table_calendar** untuk week strip picker, dan **calendar_day_view** untuk timeline view.

```dart
// Week Strip (table_calendar)
TableCalendar(
  focusedDay: selectedDay,
  calendarFormat: CalendarFormat.week, // Week strip mode
  onDaySelected: (selected, focused) => setState(() => selectedDay = selected),
)

// Timeline (calendar_day_view)
CalendarDayView.overflow(
  currentDate: selectedDay,
  events: getEventsForDay(selectedDay),
  // ...
)
```

---

## ✅ Keputusan

**Primary Choice:** `syncfusion_flutter_calendar`
- Reason: Most feature-complete, native support for all required views

**Fallback Option:** `table_calendar` + `calendar_day_view`
- Reason: If license is a concern, use combo MIT packages

---

## 🔗 Terkait

**Find:** - 
**Plan:** PLAN_014 (Phase 2: Scheduled Todo & Timeline)
**Reference URLs:**
- https://pub.dev/packages/syncfusion_flutter_calendar
- https://pub.dev/packages/calendar_day_view
- https://pub.dev/packages/table_calendar
- https://pub.dev/packages/flutter_customizable_calendar
