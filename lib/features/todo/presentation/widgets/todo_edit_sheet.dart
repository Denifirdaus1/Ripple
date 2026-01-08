import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ripple_button.dart';
import '../../../../core/widgets/ripple_input.dart';
import '../../domain/entities/todo.dart';
import '../../domain/entities/recurrence_rule.dart';
import '../../data/models/recurrence_rule_model.dart';
import 'recurrence_picker.dart';

class TodoEditSheet extends StatefulWidget {
  final Todo? initialTodo;
  final DateTime? scheduledTime; // Pre-filled from calendar tap
  final ValueChanged<Todo> onSave;

  /// Callback for subtasks to create (only for new todos)
  final void Function(List<String> subtaskTitles)? onSubtasksCreated;

  const TodoEditSheet({
    super.key,
    this.initialTodo,
    this.scheduledTime,
    required this.onSave,
    this.onSubtasksCreated,
  });

  @override
  State<TodoEditSheet> createState() => _TodoEditSheetState();
}

class _TodoEditSheetState extends State<TodoEditSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late TodoPriority _priority;
  late bool _focusEnabled;
  late int _focusDurationMinutes;

  // Schedule Fields
  late bool _isScheduled;
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late int _reminderMinutes; // New: reminder time before start

  // Recurrence
  RecurrenceRule? _recurrenceRule;

  // Subtasks (for new todo creation)
  final List<String> _subtasks = [];
  bool _isAddingSubtask = false;
  final TextEditingController _subtaskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final todo = widget.initialTodo;

    _titleController = TextEditingController(text: todo?.title ?? '');
    _descController = TextEditingController(text: todo?.description ?? '');
    _priority = todo?.priority ?? TodoPriority.medium;
    _focusEnabled = todo?.focusEnabled ?? false;
    _focusDurationMinutes = todo?.focusDurationMinutes ?? 25;

    // Initialize Schedule
    _isScheduled = todo?.isScheduled ?? (widget.scheduledTime != null);
    _selectedDate =
        todo?.scheduledDate ?? widget.scheduledTime ?? DateTime.now();

    if (todo?.startTime != null) {
      _startTime = TimeOfDay.fromDateTime(todo!.startTime!);
    } else if (widget.scheduledTime != null) {
      _startTime = TimeOfDay.fromDateTime(widget.scheduledTime!);
    } else {
      _startTime = const TimeOfDay(hour: 9, minute: 0);
    }

    if (todo?.endTime != null) {
      _endTime = TimeOfDay.fromDateTime(todo!.endTime!);
    } else {
      _endTime = TimeOfDay(
        hour: _startTime.hour + 1,
        minute: _startTime.minute,
      );
    }

    // Initialize reminder minutes
    _reminderMinutes = todo?.reminderMinutes ?? 5;

    // Initialize recurrence rule
    _recurrenceRule = todo?.parsedRecurrenceRule;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) => _applyTheme(context, child!),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: (context, child) => _applyTheme(context, child!),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
          // Auto-adjust end time to be 1 hour after start
          _endTime = TimeOfDay(
            hour: (picked.hour + 1) % 24,
            minute: picked.minute,
          );
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Widget _applyTheme(BuildContext context, Widget child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.light(
          primary: AppColors.rippleBlue,
          onPrimary: Colors.white,
          onSurface: AppColors.textPrimary,
        ),
      ),
      child: child,
    );
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty) return;

    final baseDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    DateTime? startDateTime;
    DateTime? endDateTime;

    if (_isScheduled) {
      startDateTime = baseDate.add(
        Duration(hours: _startTime.hour, minutes: _startTime.minute),
      );
      endDateTime = baseDate.add(
        Duration(hours: _endTime.hour, minutes: _endTime.minute),
      );

      // Validate: endTime must be > startTime (DB constraint)
      if (!endDateTime.isAfter(startDateTime)) {
        // Auto-fix: add 1 hour to end time
        endDateTime = startDateTime.add(const Duration(hours: 1));
      }
    }

    // For existing todo, we need to explicitly set nulls when un-scheduling
    Todo todo;
    if (widget.initialTodo != null) {
      todo = Todo(
        id: widget.initialTodo!.id,
        userId: widget.initialTodo!.userId,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        priority: _priority,
        isCompleted: widget.initialTodo!.isCompleted,
        completedAt: widget.initialTodo!.completedAt,
        focusEnabled: _focusEnabled,
        focusDurationMinutes: _focusEnabled ? _focusDurationMinutes : null,
        isScheduled: _isScheduled,
        scheduledDate: _isScheduled ? baseDate : null,
        startTime: startDateTime,
        endTime: endDateTime,
        reminderMinutes: _isScheduled ? _reminderMinutes : 5,
        milestoneId: widget.initialTodo!.milestoneId,
        recurrenceRule: _recurrenceRule != null
            ? RecurrenceRuleModel.fromEntity(_recurrenceRule!).toJson()
            : null,
        parentTodoId: widget.initialTodo!.parentTodoId,
        notificationSent: widget.initialTodo!.notificationSent,
        createdAt: widget.initialTodo!.createdAt,
        updatedAt: DateTime.now(),
      );
    } else {
      todo = Todo(
        id: '',
        userId: '',
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        priority: _priority,
        focusEnabled: _focusEnabled,
        focusDurationMinutes: _focusEnabled ? _focusDurationMinutes : null,
        isScheduled: _isScheduled,
        scheduledDate: _isScheduled ? baseDate : null,
        startTime: startDateTime,
        endTime: endDateTime,
        reminderMinutes: _isScheduled ? _reminderMinutes : 5,
        recurrenceRule: _recurrenceRule != null
            ? RecurrenceRuleModel.fromEntity(_recurrenceRule!).toJson()
            : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    widget.onSave(todo);

    // Pass subtasks to parent (only for new todos)
    if (widget.initialTodo == null && _subtasks.isNotEmpty) {
      widget.onSubtasksCreated?.call(_subtasks);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.initialTodo == null ? 'New Task' : 'Edit Task',
                  style: AppTypography.textTheme.headlineSmall,
                ),
                IconButton(
                  icon: const Icon(PhosphorIconsRegular.x),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            RippleInput(
              hintText: 'What needs to be done?',
              controller: _titleController,
              autofocus: widget.initialTodo == null,
            ),
            const SizedBox(height: 12),

            // Subtasks Section (branching UI)
            _buildSubtasksSection(),
            const SizedBox(height: 20),

            // Priority Section
            Text('Priority', style: AppTypography.textTheme.labelLarge),
            const SizedBox(height: 8),
            Row(
              children: TodoPriority.values.map((p) {
                final isSelected = _priority == p;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(p.name.toUpperCase()),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _priority = p);
                    },
                    selectedColor: _getPriorityColor(p),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
            const Divider(height: 32),

            // Schedule Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      PhosphorIconsRegular.calendar,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(width: 8),
                    Text('Schedule', style: AppTypography.textTheme.titleSmall),
                  ],
                ),
                Switch.adaptive(
                  value: _isScheduled,
                  activeColor: AppColors.rippleBlue,
                  onChanged: (val) async {
                    if (val) {
                      // Step 1: Check if system notifications are enabled
                      final FlutterLocalNotificationsPlugin
                      flutterLocalNotificationsPlugin =
                          FlutterLocalNotificationsPlugin();
                      final androidPlugin = flutterLocalNotificationsPlugin
                          .resolvePlatformSpecificImplementation<
                            AndroidFlutterLocalNotificationsPlugin
                          >();

                      final areNotificationsEnabled =
                          await androidPlugin?.areNotificationsEnabled() ??
                          false;

                      if (!areNotificationsEnabled) {
                        // Show dialog to redirect to system settings
                        if (mounted) {
                          final shouldOpenSettings = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Enable Notifications'),
                              content: const Text(
                                'To receive reminders for scheduled tasks, please enable notifications in your device settings.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.rippleBlue,
                                  ),
                                  child: const Text('Open Settings'),
                                ),
                              ],
                            ),
                          );

                          if (shouldOpenSettings == true) {
                            // Open notification settings
                            await androidPlugin
                                ?.requestNotificationsPermission();
                          }
                        }
                        return; // Don't enable schedule until notifications are enabled
                      }

                      // Step 2: Check and request FCM permission using new API
                      final service = GetIt.I<NotificationService>();
                      final isGranted = await service.isPermissionGranted();

                      if (!isGranted) {
                        final granted = await service.requestPermission();
                        if (!granted) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Notification permission is required for reminders.',
                                ),
                                backgroundColor: AppColors.coralPink,
                              ),
                            );
                          }
                          return; // Don't enable if permission denied
                        }
                      }

                      // Step 3: Sync FCM token
                      final userId =
                          Supabase.instance.client.auth.currentUser?.id;
                      if (userId != null) {
                        await service.initialize(userId);
                      }
                    }
                    setState(() => _isScheduled = val);
                  },
                ),
              ],
            ),
            if (_isScheduled) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _InfoTile(
                      label: 'Date',
                      value: DateFormat('MMM dd, yyyy').format(_selectedDate),
                      icon: PhosphorIconsRegular.calendarBlank,
                      onTap: _pickDate,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _InfoTile(
                      label: 'Start',
                      value: _startTime.format(context),
                      icon: PhosphorIconsRegular.clock,
                      onTap: () => _pickTime(true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoTile(
                      label: 'End',
                      value: _endTime.format(context),
                      icon: PhosphorIconsRegular.clockAfternoon,
                      onTap: () => _pickTime(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Reminder Time Dropdown
              Row(
                children: [
                  const Icon(
                    PhosphorIconsRegular.bellRinging,
                    size: 20,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(width: 8),
                  Text('Remind me', style: AppTypography.textTheme.titleSmall),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.softGray,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.outlineGray),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _reminderMinutes,
                        isDense: true,
                        items: const [
                          DropdownMenuItem(
                            value: 5,
                            child: Text('5 min before'),
                          ),
                          DropdownMenuItem(
                            value: 10,
                            child: Text('10 min before'),
                          ),
                          DropdownMenuItem(
                            value: 15,
                            child: Text('15 min before'),
                          ),
                          DropdownMenuItem(
                            value: 30,
                            child: Text('30 min before'),
                          ),
                          DropdownMenuItem(
                            value: 60,
                            child: Text('1 hour before'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _reminderMinutes = value);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Recurrence Section (only when scheduled)
            if (_isScheduled) ...[
              const SizedBox(height: 12),
              RecurrencePicker(
                initialRule: _recurrenceRule,
                onChanged: (rule) {
                  setState(() => _recurrenceRule = rule);
                },
              ),
            ],

            const Divider(height: 32),

            // Focus Mode Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      PhosphorIconsRegular.timer,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Focus Mode',
                      style: AppTypography.textTheme.titleSmall,
                    ),
                  ],
                ),
                Switch.adaptive(
                  value: _focusEnabled,
                  activeColor: AppColors.rippleBlue,
                  onChanged: (val) => setState(() => _focusEnabled = val),
                ),
              ],
            ),
            if (_focusEnabled) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text(
                    'Duration: ',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  Text(
                    '${_focusDurationMinutes}m',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Slider(
                      value: _focusDurationMinutes.toDouble(),
                      min: 5,
                      max: 120,
                      divisions: 23,
                      activeColor: AppColors.rippleBlue,
                      onChanged: (val) =>
                          setState(() => _focusDurationMinutes = val.toInt()),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),
            RippleButton(
              text: widget.initialTodo == null ? 'Create Task' : 'Save Changes',
              onPressed: _submit,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// Build branching subtasks section with tree-like UI
  Widget _buildSubtasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Icon(
              PhosphorIconsRegular.gitBranch,
              size: 18,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              'Subtasks',
              style: AppTypography.textTheme.labelLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _addSubtask,
              icon: Icon(PhosphorIconsRegular.plus, size: 16),
              label: const Text('Add'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.rippleBlue,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ],
        ),

        // Subtask list with branching lines
        if (_subtasks.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...List.generate(_subtasks.length, (index) {
            final isLast = index == _subtasks.length - 1;
            return _buildSubtaskItem(index, isLast);
          }),
        ],

        // Empty state
        if (_subtasks.isEmpty && !_isAddingSubtask)
          Padding(
            padding: const EdgeInsets.only(left: 26, top: 8),
            child: Text(
              'No subtasks yet',
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

        // Inline add input
        if (_isAddingSubtask)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Branch line for new item
                SizedBox(
                  width: 26,
                  child: Column(
                    children: [
                      Container(
                        width: 2,
                        height: 16,
                        color: AppColors.outlineGray,
                      ),
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 2,
                            color: AppColors.outlineGray,
                          ),
                          Icon(
                            PhosphorIconsRegular.plusCircle,
                            size: 12,
                            color: AppColors.sageGreen,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _subtaskController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Subtask name...',
                      hintStyle: TextStyle(color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.softGray,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.outlineGray),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.outlineGray),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppColors.rippleBlue,
                          width: 2,
                        ),
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              PhosphorIconsRegular.check,
                              size: 20,
                              color: AppColors.sageGreen,
                            ),
                            onPressed: _submitSubtask,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(
                              PhosphorIconsRegular.x,
                              size: 20,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () {
                              _subtaskController.clear();
                              setState(() => _isAddingSubtask = false);
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                    style: AppTypography.textTheme.bodyMedium,
                    onSubmitted: (_) => _submitSubtask(),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSubtaskItem(int index, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Branch line indicator
        SizedBox(
          width: 26,
          child: Column(
            children: [
              Container(width: 2, height: 16, color: AppColors.outlineGray),
              Row(
                children: [
                  Container(width: 12, height: 2, color: AppColors.outlineGray),
                  Icon(
                    PhosphorIconsRegular.circle,
                    size: 12,
                    color: AppColors.rippleBlue,
                  ),
                ],
              ),
              if (!isLast)
                Container(width: 2, height: 16, color: AppColors.outlineGray),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Subtask content
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.softGray,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.outlineGray),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _subtasks[index],
                    style: AppTypography.textTheme.bodyMedium,
                  ),
                ),
                GestureDetector(
                  onTap: () => _removeSubtask(index),
                  child: Icon(
                    PhosphorIconsRegular.x,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _addSubtask() {
    setState(() => _isAddingSubtask = true);
  }

  void _submitSubtask() {
    if (_subtaskController.text.trim().isNotEmpty) {
      setState(() {
        _subtasks.add(_subtaskController.text.trim());
        _subtaskController.clear();
        _isAddingSubtask = false;
      });
    }
  }

  void _removeSubtask(int index) {
    setState(() => _subtasks.removeAt(index));
  }

  Color _getPriorityColor(TodoPriority p) {
    switch (p) {
      case TodoPriority.high:
        return AppColors.coralPink;
      case TodoPriority.medium:
        return AppColors.warmTangerine;
      case TodoPriority.low:
        return AppColors.rippleBlue;
    }
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _InfoTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.softGray.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
