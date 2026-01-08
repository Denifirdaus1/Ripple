import '../../domain/entities/recurrence_rule.dart';

/// Model for serializing/deserializing RecurrenceRule to/from JSON
///
/// **IMPORTANT: Weekday Format Conversion**
/// - Flutter/JS uses: 0=Sunday, 1=Monday, ..., 6=Saturday
/// - Database (ISO) uses: 1=Monday, 2=Tuesday, ..., 7=Sunday
///
/// This model handles the conversion automatically in toJson/fromJson.
class RecurrenceRuleModel extends RecurrenceRule {
  const RecurrenceRuleModel({
    required super.type,
    super.days,
    super.interval,
    super.until,
    super.count,
  });

  /// Convert JS weekday (0=Sun, 1=Mon, ..., 6=Sat) to ISO (1=Mon, ..., 7=Sun)
  static int _jsToIsoWeekday(int jsDay) {
    // JS: 0=Sun, 1=Mon, 2=Tue, 3=Wed, 4=Thu, 5=Fri, 6=Sat
    // ISO: 1=Mon, 2=Tue, 3=Wed, 4=Thu, 5=Fri, 6=Sat, 7=Sun
    if (jsDay == 0) return 7; // Sunday: 0 -> 7
    return jsDay; // Monday-Saturday: 1-6 -> 1-6
  }

  /// Convert ISO weekday (1=Mon, ..., 7=Sun) to JS (0=Sun, 1=Mon, ..., 6=Sat)
  static int _isoToJsWeekday(int isoDay) {
    if (isoDay == 7) return 0; // Sunday: 7 -> 0
    return isoDay; // Monday-Saturday: 1-6 -> 1-6
  }

  /// Create from RecurrenceRule entity
  factory RecurrenceRuleModel.fromEntity(RecurrenceRule rule) {
    return RecurrenceRuleModel(
      type: rule.type,
      days: rule.days,
      interval: rule.interval,
      until: rule.until,
      count: rule.count,
    );
  }

  /// Parse from JSON (database format with ISO weekdays)
  factory RecurrenceRuleModel.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String? ?? 'weekly';
    final type = RecurrenceType.values.firstWhere(
      (t) => t.name == typeStr,
      orElse: () => RecurrenceType.weekly,
    );

    // Convert from ISO weekday (DB) to JS weekday (Flutter)
    final daysList = json['days'] as List<dynamic>?;
    final days = daysList?.map((d) => _isoToJsWeekday(d as int)).toList() ?? [];

    final interval = json['interval'] as int? ?? 1;

    final untilStr = json['until'] as String?;
    final until = untilStr != null ? DateTime.tryParse(untilStr) : null;

    final count = json['count'] as int?;

    return RecurrenceRuleModel(
      type: type,
      days: days,
      interval: interval,
      until: until,
      count: count,
    );
  }

  /// Convert to JSON for database storage (with ISO weekdays)
  Map<String, dynamic> toJson() {
    // Convert from JS weekday (Flutter) to ISO weekday (DB)
    final isoDays = days.map(_jsToIsoWeekday).toList()..sort();

    return {
      'type': type.name,
      'days': isoDays,
      'interval': interval,
      if (until != null) 'until': until!.toIso8601String().split('T').first,
      if (count != null) 'count': count,
    };
  }

  /// Create RecurrenceRuleModel from RecurrenceRule
  static RecurrenceRuleModel? fromRecurrenceRule(RecurrenceRule? rule) {
    if (rule == null) return null;
    if (rule is RecurrenceRuleModel) return rule;
    return RecurrenceRuleModel.fromEntity(rule);
  }
}
