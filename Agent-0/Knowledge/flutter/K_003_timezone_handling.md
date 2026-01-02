# Timezone Management - Flutter + Supabase

## Problem Statement
Handling timezones correctly in a Flutter app with Supabase backend to ensure:
1. System knows user's timezone automatically
2. All users see times in their local timezone
3. Database stores consistent, unambiguous timestamps

## Solution Architecture

### 1. Detect User's Timezone (Flutter Side)

**Package**: `flutter_timezone` (or `flutter_native_timezone`)

```dart
// pubspec.yaml
dependencies:
  flutter_timezone: ^5.0.1
  timezone: ^0.10.1

// Usage
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

Future<void> initializeTimezone() async {
  tz.initializeTimeZones();
  
  // Get device's IANA timezone name (e.g., "Asia/Jakarta", "America/New_York")
  final TimezoneInfo tzInfo = await FlutterTimezone.getLocalTimezone();
  final String tzName = tzInfo.name; // "Asia/Jakarta"
  
  // Set as local location for TZDateTime operations
  tz.setLocalLocation(tz.getLocation(tzName));
}
```

**Why IANA names?**
- Unambiguous (unlike "CST" which could be Central Standard or China Standard)
- Automatically handles DST (Daylight Saving Time) changes
- Supported by PostgreSQL's timezone functions

---

### 2. Store User's Timezone Preference (Database)

**Add column to user profile/settings table:**

```sql
ALTER TABLE public.profiles 
ADD COLUMN timezone TEXT DEFAULT 'UTC';
```

**Store on first login/registration:**

```dart
Future<void> saveUserTimezone(String userId, String timezone) async {
  await supabase.from('profiles').upsert({
    'id': userId,
    'timezone': timezone,
  });
}
```

---

### 3. Store Timestamps in UTC (Database)

**Golden Rule**: Always use `TIMESTAMPTZ` (timestamp with time zone)

```sql
-- Correct (stores in UTC, converts on retrieval)
start_time TIMESTAMP WITH TIME ZONE,
end_time TIMESTAMP WITH TIME ZONE,

-- Incorrect (ambiguous, no timezone info)
start_time TIMESTAMP,
```

**When inserting from Flutter:**
```dart
// Always convert to UTC before sending
'start_time': dateTime.toUtc().toIso8601String(),

// For date-only fields (like scheduled_date), use local date string
'scheduled_date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
```

---

### 4. Convert for Display (Client-Side)

**Option A: Convert in Flutter using TZDateTime**

```dart
import 'package:timezone/timezone.dart' as tz;

// Get user's location
final location = tz.getLocation('Asia/Jakarta');

// Convert UTC DateTime to user's timezone
final utcTime = DateTime.parse(json['start_time']);
final localTime = tz.TZDateTime.from(utcTime, location);
```

**Option B: Convert in PostgreSQL (useful for complex queries)**

```sql
SELECT 
  title,
  start_time AT TIME ZONE profiles.timezone AS local_start_time
FROM todos
JOIN profiles ON todos.user_id = profiles.id;
```

---

## Implementation Strategy for Ripple

### Phase 1: Add Dependencies
```yaml
dependencies:
  flutter_timezone: ^5.0.1
  timezone: ^0.10.1
```

### Phase 2: Initialize Timezone on App Start
```dart
// In main.dart or service locator
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize timezone database
  tz.initializeTimeZones();
  
  // Detect and set local timezone
  final tzInfo = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(tzInfo.name));
  
  runApp(const RippleApp());
}
```

### Phase 3: Store User Preference (Optional)
If supporting user-selectable timezone (not just device timezone):
1. Add `timezone` column to `profiles` table
2. Save detected timezone on first login
3. Allow user to override in settings

### Phase 4: Update TodoModel
```dart
// fromJson: Parse with timezone awareness
startTime: json['start_time'] != null 
    ? TZDateTime.parse(tz.local, json['start_time']) 
    : null,

// toJson: Always send UTC
'start_time': startTime?.toUtc().toIso8601String(),
```

---

## Key Packages

| Package | Purpose |
|---------|---------|
| `flutter_timezone` | Detect device's IANA timezone |
| `timezone` | TZDateTime for timezone-aware operations |
| `intl` | Date formatting (already in project) |

## References
- [flutter_timezone on pub.dev](https://pub.dev/packages/flutter_timezone)
- [timezone on pub.dev](https://pub.dev/packages/timezone)
- [PostgreSQL Timezone Docs](https://www.postgresql.org/docs/current/datatype-datetime.html)
- [IANA Time Zone Database](https://www.iana.org/time-zones)
