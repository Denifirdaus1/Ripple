import 'package:equatable/equatable.dart';

/// Type of recurrence pattern
enum RecurrenceType {
  /// Repeat every X days
  daily,

  /// Repeat on specific weekdays every X weeks
  weekly,

  /// Repeat on specific day of month every X months
  monthly,

  /// Custom pattern (future use)
  custom,
}

/// Represents a recurrence rule for repeating todos.
/// Based on simplified iCal RRULE concepts.
class RecurrenceRule extends Equatable {
  /// The type of recurrence (daily, weekly, monthly)
  final RecurrenceType type;

  /// Days of the week when the todo should repeat.
  /// 0 = Sunday, 1 = Monday, ..., 6 = Saturday
  /// Only used for weekly recurrence type.
  final List<int> days;

  /// Interval between recurrences.
  /// For weekly: every N weeks. For daily: every N days.
  final int interval;

  /// Optional end date for the recurrence.
  /// If null, recurrence continues indefinitely.
  final DateTime? until;

  /// Optional count of occurrences.
  /// If null, recurrence continues indefinitely (or until 'until' date).
  final int? count;

  const RecurrenceRule({
    required this.type,
    this.days = const [],
    this.interval = 1,
    this.until,
    this.count,
  });

  /// Create a weekly recurrence on specific days
  factory RecurrenceRule.weekly({
    required List<int> days,
    int interval = 1,
    DateTime? until,
    int? count,
  }) {
    return RecurrenceRule(
      type: RecurrenceType.weekly,
      days: List.unmodifiable(days..sort()),
      interval: interval,
      until: until,
      count: count,
    );
  }

  /// Create a daily recurrence
  factory RecurrenceRule.daily({
    int interval = 1,
    DateTime? until,
    int? count,
  }) {
    return RecurrenceRule(
      type: RecurrenceType.daily,
      interval: interval,
      until: until,
      count: count,
    );
  }

  /// Check if this recurrence should occur on the given date.
  /// Does not consider the 'until' date or 'count' limits.
  bool shouldOccurOnWeekday(DateTime date) {
    if (type == RecurrenceType.weekly) {
      // date.weekday: 1=Monday, ..., 7=Sunday
      // Our format: 0=Sunday, 1=Monday, ..., 6=Saturday
      final weekday = date.weekday == 7 ? 0 : date.weekday;
      return days.contains(weekday);
    }
    // For daily, it always occurs (based on interval, handled elsewhere)
    return true;
  }

  /// Get the next occurrence date after 'from' date.
  /// Returns null if there are no more occurrences (e.g., past 'until' date).
  DateTime? getNextOccurrence(DateTime from) {
    DateTime candidate = DateTime(from.year, from.month, from.day);

    // Check 'until' limit first
    if (until != null && candidate.isAfter(until!)) {
      return null;
    }

    switch (type) {
      case RecurrenceType.daily:
        candidate = candidate.add(Duration(days: interval));
        break;

      case RecurrenceType.weekly:
        if (days.isEmpty) return null;

        // Find the next matching weekday
        for (int i = 1; i <= 7 * interval + 7; i++) {
          candidate = candidate.add(const Duration(days: 1));
          if (shouldOccurOnWeekday(candidate)) {
            break;
          }
        }
        break;

      case RecurrenceType.monthly:
        // For monthly, add X months to the candidate
        candidate = DateTime(
          candidate.year,
          candidate.month + interval,
          candidate.day,
        );
        break;

      case RecurrenceType.custom:
        // Custom not implemented yet
        return null;
    }

    // Check 'until' limit after calculation
    final untilDate = until;
    if (untilDate != null && candidate.isAfter(untilDate)) {
      return null;
    }

    return candidate;
  }

  /// Generate all occurrences between startDate and endDate.
  /// Used for calendar view expansion.
  List<DateTime> generateOccurrences({
    required DateTime startDate,
    required DateTime endDate,
    int maxOccurrences = 100,
  }) {
    final occurrences = <DateTime>[];
    DateTime current = DateTime(startDate.year, startDate.month, startDate.day);

    // First, check if startDate itself is an occurrence
    if (shouldOccurOnWeekday(current)) {
      occurrences.add(current);
    }

    int generated = 0;
    while (generated < maxOccurrences) {
      final next = getNextOccurrence(current);
      if (next == null) break;
      if (next.isAfter(endDate)) break;

      occurrences.add(next);
      current = next;
      generated++;
    }

    return occurrences;
  }

  /// Weekday names for display (Indonesian)
  static const List<String> weekdayNames = [
    'Min',
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
  ];

  /// Get display text for the selected days
  String get daysDisplayText {
    if (days.isEmpty) return '';
    if (days.length == 7) return 'Setiap hari';
    if (_isWeekdays) return 'Hari kerja';
    if (_isWeekends) return 'Akhir pekan';

    return days.map((d) => weekdayNames[d]).join(', ');
  }

  bool get _isWeekdays =>
      days.length == 5 &&
      days.contains(1) &&
      days.contains(2) &&
      days.contains(3) &&
      days.contains(4) &&
      days.contains(5);

  bool get _isWeekends =>
      days.length == 2 && days.contains(0) && days.contains(6);

  /// Human-readable summary of the recurrence
  String get displayText {
    switch (type) {
      case RecurrenceType.daily:
        if (interval == 1) return 'Setiap hari';
        return 'Setiap $interval hari';

      case RecurrenceType.weekly:
        if (interval == 1) {
          return 'Setiap $daysDisplayText';
        }
        return 'Setiap $interval minggu: $daysDisplayText';

      case RecurrenceType.monthly:
        if (interval == 1) return 'Setiap bulan';
        return 'Setiap $interval bulan';

      case RecurrenceType.custom:
        return 'Kustom';
    }
  }

  @override
  List<Object?> get props => [type, days, interval, until, count];
}
