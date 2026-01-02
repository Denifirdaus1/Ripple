import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/todo.dart';

/// Custom CalendarDataSource that adapts Todo entities for SfCalendar
class TodoCalendarDataSource extends CalendarDataSource {
  TodoCalendarDataSource(List<Todo> todos) {
    // Only include scheduled todos with valid start times
    appointments = todos
        .where((t) => t.isScheduled && t.startTime != null)
        .toList();
  }

  @override
  DateTime getStartTime(int index) {
    final todo = appointments![index] as Todo;
    return todo.startTime!;
  }

  @override
  DateTime getEndTime(int index) {
    final todo = appointments![index] as Todo;
    // Default to 1 hour if no end time specified
    return todo.endTime ?? todo.startTime!.add(const Duration(hours: 1));
  }

  @override
  String getSubject(int index) {
    final todo = appointments![index] as Todo;
    return todo.title;
  }

  @override
  Color getColor(int index) {
    final todo = appointments![index] as Todo;
    switch (todo.priority) {
      case TodoPriority.high:
        return AppColors.coralPink;
      case TodoPriority.medium:
        return AppColors.warmTangerine;
      case TodoPriority.low:
        return AppColors.rippleBlue;
    }
  }

  @override
  bool isAllDay(int index) => false;

  @override
  String? getNotes(int index) {
    final todo = appointments![index] as Todo;
    return todo.description;
  }

  /// Get the original Todo entity at index
  Todo getTodo(int index) => appointments![index] as Todo;
}
