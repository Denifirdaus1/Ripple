import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ripple_page_header.dart';
import '../../../../core/widgets/auto_scroll_text.dart';
import '../../domain/entities/todo.dart';
import '../../data/datasources/todo_calendar_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/services/notification_service.dart';
import '../../../../../core/injection/injection_container.dart';
import '../bloc/todos_overview_bloc.dart';
import '../bloc/focus_timer_cubit.dart';
import '../widgets/todo_edit_sheet.dart';
import '../widgets/todo_item.dart';

/// View modes are now managed by TodosOverviewBloc

class TodosPage extends StatefulWidget {
  const TodosPage({super.key});

  @override
  State<TodosPage> createState() => _TodosPageState();
}

class _TodosPageState extends State<TodosPage> {
  @override
  void initState() {
    super.initState();
    // Initialize Notification Service and Sync Token
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      sl<NotificationService>().initialize(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodosOverviewBloc, TodosOverviewState>(
      builder: (context, state) {
        final viewMode = state.viewMode;

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // ========== FIXED HEADER SECTION ==========
                // This section stays fixed at top while content scrolls

                // Top spacing for better visual breathing room
                const SizedBox(height: 8),

                // Page Header with title and actions
                RipplePageHeader(
                  title: viewMode == TodosViewMode.list ? 'Tasks' : 'Schedule',
                  subtitle: viewMode == TodosViewMode.list
                      ? 'Stay focused and organized.'
                      : 'Your day at a glance.',
                ),

                // View Mode Toggle Switch
                _buildViewModeToggle(context, viewMode),

                // Filter bar (only show in list mode)
                if (viewMode == TodosViewMode.list) _TodosFilterBar(),

                // ========== SCROLLABLE CONTENT SECTION ==========
                // This section scrolls independently from the header
                Expanded(
                  child: viewMode == TodosViewMode.list
                      ? _buildTodoListView(context)
                      : _buildCalendarView(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Toggle switch for List / Schedule mode
  Widget _buildViewModeToggle(BuildContext context, TodosViewMode currentMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.softGray.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Expanded(
              child: _ToggleButton(
                label: 'List',
                icon: PhosphorIconsRegular.listChecks,
                isSelected: currentMode == TodosViewMode.list,
                onTap: () => context.read<TodosOverviewBloc>().add(
                  const TodosOverviewViewModeChanged(TodosViewMode.list),
                ),
              ),
            ),
            Expanded(
              child: _ToggleButton(
                label: 'Schedule',
                icon: PhosphorIconsRegular.calendarBlank,
                isSelected: currentMode == TodosViewMode.schedule,
                onTap: () => context.read<TodosOverviewBloc>().add(
                  const TodosOverviewViewModeChanged(TodosViewMode.schedule),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the todo list as sliver
  Widget _buildTodoListSliver(BuildContext context) {
    return BlocBuilder<TodosOverviewBloc, TodosOverviewState>(
      builder: (context, state) {
        if (state.status == TodosOverviewStatus.loading) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final todos = state.filteredTodos.toList();

        if (todos.isEmpty) {
          if (state.status == TodosOverviewStatus.initial) {
            return const SliverFillRemaining(
              child: Center(child: Text('Loading tasks...')),
            );
          }
          return const SliverFillRemaining(
            child: Center(
              child: Text(
                'No tasks found.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final todo = todos[index];
              return TodoItem(
                todo: todo,
                onCheckboxChanged: (val) {
                  context.read<TodosOverviewBloc>().add(
                    TodosOverviewTodoSaved(
                      todo.copyWith(
                        isCompleted: val ?? false,
                        completedAt: (val ?? false) ? DateTime.now() : null,
                      ),
                    ),
                  );
                },
                onTap: () {
                  _openEditSheet(context, todo: todo);
                },
                onStartFocus: () {
                  // Start Focus Mode for this todo
                  context.read<FocusTimerCubit>().startFocusForTodo(todo);
                  context.go('/focus');
                },
              );
            }, childCount: todos.length),
          ),
        );
      },
    );
  }

  /// Build the todo list as a regular scrollable widget (for fixed header layout)
  Widget _buildTodoListView(BuildContext context) {
    return BlocBuilder<TodosOverviewBloc, TodosOverviewState>(
      builder: (context, state) {
        if (state.status == TodosOverviewStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        final todos = state.filteredTodos.toList();

        if (todos.isEmpty) {
          if (state.status == TodosOverviewStatus.initial) {
            return const Center(child: Text('Loading tasks...'));
          }
          return const Center(
            child: Text(
              'No tasks found.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: todos.length,
          itemBuilder: (context, index) {
            final todo = todos[index];
            return TodoItem(
              todo: todo,
              onCheckboxChanged: (val) {
                context.read<TodosOverviewBloc>().add(
                  TodosOverviewTodoSaved(
                    todo.copyWith(
                      isCompleted: val ?? false,
                      completedAt: (val ?? false) ? DateTime.now() : null,
                    ),
                  ),
                );
              },
              onTap: () {
                _openEditSheet(context, todo: todo);
              },
              onStartFocus: () {
                context.read<FocusTimerCubit>().startFocusForTodo(todo);
                context.go('/focus');
              },
            );
          },
        );
      },
    );
  }

  /// Build the Syncfusion Calendar as a regular widget (for fixed header layout)
  Widget _buildCalendarView(BuildContext context) {
    return BlocBuilder<TodosOverviewBloc, TodosOverviewState>(
      builder: (context, state) {
        if (state.status == TodosOverviewStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Get scheduled todos (can be empty)
        final allTodos = state.todos.toList();
        final scheduledTodos = allTodos
            .where((t) => t.isScheduled && t.startTime != null)
            .toList();

        // Always show calendar, even if empty
        return _buildSfCalendar(context, scheduledTodos);
      },
    );
  }

  /// Shared SfCalendar widget builder
  Widget _buildSfCalendar(BuildContext context, List<Todo> scheduledTodos) {
    return SfCalendar(
      view: CalendarView.day,
      dataSource: TodoCalendarDataSource(scheduledTodos),
      showCurrentTimeIndicator: true,
      initialDisplayDate: DateTime.now(),
      todayHighlightColor: AppColors.rippleBlue,
      cellBorderColor: AppColors.softGray.withValues(alpha: 0.5),
      backgroundColor: AppColors.paperWhite,
      headerStyle: CalendarHeaderStyle(
        textStyle: AppTypography.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: AppColors.paperWhite,
        textAlign: TextAlign.center,
      ),
      viewHeaderStyle: ViewHeaderStyle(
        dayTextStyle: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        dateTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      timeSlotViewSettings: TimeSlotViewSettings(
        startHour: 6,
        endHour: 23,
        timeInterval: const Duration(minutes: 60),
        timeIntervalHeight: 60,
        timeTextStyle: TextStyle(color: AppColors.textSecondary, fontSize: 11),
        timelineAppointmentHeight: 50,
      ),
      appointmentTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      appointmentBuilder: _buildAppointmentWidget,
      onTap: (details) {
        if (details.appointments?.isEmpty ?? true) {
          // Tapped on empty cell - create new scheduled todo
          if (details.date != null) {
            _openEditSheet(context, scheduledTime: details.date);
          }
        }
      },
    );
  }

  /// Build individual appointment widget for the calendar
  Widget _buildAppointmentWidget(
    BuildContext context,
    CalendarAppointmentDetails details,
  ) {
    final todo = details.appointments.first as Todo;
    final color = _getPriorityColor(todo.priority);

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final width = constraints.maxWidth;
        final canStackTime = height > 70;

        // Format time strings
        String timeRange = '';
        String startStr = '';
        String endStr = '';
        if (todo.startTime != null && todo.endTime != null) {
          final startHour = todo.startTime!.hour;
          final startMin = todo.startTime!.minute;
          final endHour = todo.endTime!.hour;
          final endMin = todo.endTime!.minute;
          final startPeriod = startHour >= 12 ? 'PM' : 'AM';
          final endPeriod = endHour >= 12 ? 'PM' : 'AM';
          final startH = startHour > 12
              ? startHour - 12
              : (startHour == 0 ? 12 : startHour);
          final endH = endHour > 12
              ? endHour - 12
              : (endHour == 0 ? 12 : endHour);

          startStr =
              '${startH.toString().padLeft(2, '0')}:${startMin.toString().padLeft(2, '0')} $startPeriod';
          endStr =
              '${endH.toString().padLeft(2, '0')}:${endMin.toString().padLeft(2, '0')} $endPeriod';
          timeRange = '$startStr - $endStr';
        }

        // Check for time text overflow
        bool timeOverflows = false;
        if (timeRange.isNotEmpty) {
          final textPainter = TextPainter(
            text: TextSpan(
              text: timeRange,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            ),
            maxLines: 1,
            textDirection: TextDirection.ltr,
          )..layout(maxWidth: width - 24);
          timeOverflows =
              textPainter.didExceedMaxLines || textPainter.width > (width - 24);
        }

        final bool useVerticalTime = canStackTime && timeOverflows;

        return GestureDetector(
          onTap: () => _openEditSheet(context, todo: todo),
          onLongPress: () {
            context.read<TodosOverviewBloc>().add(
              TodosOverviewTodoSaved(
                todo.copyWith(
                  isCompleted: !todo.isCompleted,
                  completedAt: !todo.isCompleted ? DateTime.now() : null,
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
            padding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
            decoration: BoxDecoration(
              color: todo.isCompleted ? color.withValues(alpha: 0.5) : color,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Row 1: Checkbox - Title - Focus
                Row(
                  children: [
                    _buildCheckbox(context, todo, color, 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: AutoScrollText(
                        todo.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          decoration: todo.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        delay: const Duration(seconds: 6),
                      ),
                    ),
                    if (todo.focusEnabled && !todo.isCompleted)
                      GestureDetector(
                        onTap: () {
                          context.read<FocusTimerCubit>().startFocusForTodo(
                            todo,
                          );
                          context.go('/focus');
                        },
                        child: const Icon(
                          PhosphorIconsFill.playCircle,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
                // Row 2: Time display
                if (timeRange.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  if (useVerticalTime)
                    Row(
                      children: [
                        Icon(
                          PhosphorIconsRegular.clock,
                          size: 12,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 4),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              startStr,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                            Text(
                              endStr,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Icon(
                          PhosphorIconsRegular.clock,
                          size: 12,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: AutoScrollText(
                            timeRange,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            delay: const Duration(seconds: 6),
                          ),
                        ),
                      ],
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build the Syncfusion Calendar as sliver (always shows calendar grid)
  Widget _buildCalendarSliver(BuildContext context) {
    return SliverFillRemaining(
      child: BlocBuilder<TodosOverviewBloc, TodosOverviewState>(
        builder: (context, state) {
          if (state.status == TodosOverviewStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Get scheduled todos (can be empty)
          final allTodos = state.todos.toList();
          final scheduledTodos = allTodos
              .where((t) => t.isScheduled && t.startTime != null)
              .toList();

          // Always show calendar, even if empty
          return SfCalendar(
            view: CalendarView.day,
            dataSource: TodoCalendarDataSource(scheduledTodos),
            showCurrentTimeIndicator: true,
            initialDisplayDate: DateTime.now(),
            todayHighlightColor: AppColors.rippleBlue,
            cellBorderColor: AppColors.softGray.withValues(alpha: 0.5),
            backgroundColor: AppColors.paperWhite,
            headerStyle: CalendarHeaderStyle(
              textStyle: AppTypography.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              backgroundColor: AppColors.paperWhite,
              textAlign: TextAlign.center,
            ),
            viewHeaderStyle: ViewHeaderStyle(
              dayTextStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
              dateTextStyle: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            timeSlotViewSettings: TimeSlotViewSettings(
              startHour: 6,
              endHour: 23,
              timeInterval: const Duration(minutes: 60),
              timeIntervalHeight: 60,
              timeTextStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
              timelineAppointmentHeight: 50,
            ),
            appointmentTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            appointmentBuilder: (context, calendarAppointmentDetails) {
              final todo =
                  calendarAppointmentDetails.appointments.first as Todo;
              final color = _getPriorityColor(todo.priority);

              return LayoutBuilder(
                builder: (context, constraints) {
                  final height = constraints.maxHeight;
                  final width = constraints.maxWidth;
                  final showDescription = height > 90;
                  // Allow vertical stacking of time if block is tall enough
                  final canStackTime = height > 70;

                  // Format time strings
                  String timeRange = '';
                  String startStr = '';
                  String endStr = '';
                  if (todo.startTime != null && todo.endTime != null) {
                    final startHour = todo.startTime!.hour;
                    final startMin = todo.startTime!.minute;
                    final endHour = todo.endTime!.hour;
                    final endMin = todo.endTime!.minute;
                    final startPeriod = startHour >= 12 ? 'PM' : 'AM';
                    final endPeriod = endHour >= 12 ? 'PM' : 'AM';
                    final startH = startHour > 12
                        ? startHour - 12
                        : (startHour == 0 ? 12 : startHour);
                    final endH = endHour > 12
                        ? endHour - 12
                        : (endHour == 0 ? 12 : endHour);

                    startStr =
                        '${startH.toString().padLeft(2, '0')}:${startMin.toString().padLeft(2, '0')} $startPeriod';
                    endStr =
                        '${endH.toString().padLeft(2, '0')}:${endMin.toString().padLeft(2, '0')} $endPeriod';
                    timeRange = '$startStr - $endStr';
                  }

                  // Check for time text overflow using TextPainter
                  bool timeOverflows = false;
                  if (timeRange.isNotEmpty) {
                    final textPainter = TextPainter(
                      text: TextSpan(
                        text: timeRange,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      maxLines: 1,
                      textDirection: TextDirection.ltr,
                    )..layout(maxWidth: width - 24); // Account for padding/icon
                    timeOverflows =
                        textPainter.didExceedMaxLines ||
                        textPainter.width > (width - 24);
                  }

                  // Timer style (Vertical stack if overflow + tall, else single line auto-scroll)
                  final bool useVerticalTime = canStackTime && timeOverflows;

                  return GestureDetector(
                    onTap: () => _openEditSheet(context, todo: todo),
                    onLongPress: () {
                      context.read<TodosOverviewBloc>().add(
                        TodosOverviewTodoSaved(
                          todo.copyWith(
                            isCompleted: !todo.isCompleted,
                            completedAt: !todo.isCompleted
                                ? DateTime.now()
                                : null,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: 1,
                      ),
                      padding: const EdgeInsets.fromLTRB(
                        6,
                        4,
                        6,
                        4,
                      ), // Compact padding
                      decoration: BoxDecoration(
                        color: todo.isCompleted
                            ? color.withValues(alpha: 0.5)
                            : color,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ROW 1: Checkbox - Title (AutoScroll) - FocusButton
                          Row(
                            children: [
                              _buildCheckbox(context, todo, color, 16),
                              const SizedBox(width: 4),
                              Expanded(
                                child: AutoScrollText(
                                  todo.title,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        13, // Slightly reduced for better fit
                                    fontWeight: FontWeight.w600,
                                    decoration: todo.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                  delay: const Duration(seconds: 6),
                                ),
                              ),
                              if (todo.focusEnabled) ...[
                                const SizedBox(width: 2),
                                if (!todo.isCompleted)
                                  GestureDetector(
                                    onTap: () {
                                      context
                                          .read<FocusTimerCubit>()
                                          .startFocusForTodo(todo);
                                      context.go('/focus');
                                    },
                                    child: const Icon(
                                      PhosphorIconsFill.playCircle,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  )
                                else
                                  Icon(
                                    PhosphorIconsFill.target,
                                    size: 14,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                              ],
                            ],
                          ),

                          // ROW 2: Time Display
                          if (timeRange.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            if (useVerticalTime)
                              // Vertical Stack:
                              // Start
                              // End
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 1),
                                    child: Icon(
                                      PhosphorIconsRegular.clock,
                                      size: 12,
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        startStr,
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.9,
                                          ),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        endStr,
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.9,
                                          ),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            else
                              // Single Line (AutoScroll if overflow)
                              Row(
                                children: [
                                  Icon(
                                    PhosphorIconsRegular.clock,
                                    size: 12,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: AutoScrollText(
                                      timeRange,
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      delay: const Duration(seconds: 6),
                                    ),
                                  ),
                                ],
                              ),
                          ],

                          // ROW 3: Description (if space permits)
                          if (showDescription &&
                              todo.description != null &&
                              todo.description!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Flexible(
                              child: Text(
                                todo.description!,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 11,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            onTap: (CalendarTapDetails details) {
              if (details.appointments == null ||
                  details.appointments!.isEmpty) {
                if (details.targetElement == CalendarElement.calendarCell) {
                  final tappedDate = details.date;
                  if (tappedDate != null) {
                    _openEditSheet(context, scheduledTime: tappedDate);
                  }
                }
              }
              // Appointment taps are now handled by appointmentBuilder
            },
          );
        },
      ),
    );
  }

  void _openEditSheet(
    BuildContext context, {
    Todo? todo,
    DateTime? scheduledTime,
  }) {
    // Store pending subtasks to create after parent is saved
    List<String>? pendingSubtasks;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return TodoEditSheet(
          initialTodo: todo,
          scheduledTime: scheduledTime,
          onSave: (newTodo) async {
            debugPrint('📝 [TodosPage] onSave called for: ${newTodo.title}');
            final userId = Supabase.instance.client.auth.currentUser?.id;
            final bloc = context.read<TodosOverviewBloc>();

            Todo todoToSave = newTodo;
            if (userId != null && newTodo.userId.isEmpty) {
              todoToSave = newTodo.copyWith(userId: userId);
            }

            // Save parent todo
            debugPrint(
              '📝 [TodosPage] Saving parent todo: ${todoToSave.title}',
            );
            bloc.add(TodosOverviewTodoSaved(todoToSave));

            // If we have pending subtasks, create them after a short delay
            // to allow parent todo to be saved first
            if (pendingSubtasks != null &&
                pendingSubtasks!.isNotEmpty &&
                userId != null) {
              debugPrint(
                '📝 [TodosPage] Found ${pendingSubtasks!.length} pending subtasks',
              );

              // Wait for parent to be saved (simple delay approach)
              debugPrint('📝 [TodosPage] Waiting 500ms for parent save...');
              await Future.delayed(const Duration(milliseconds: 500));

              // Get the saved todo (it should have an ID now)
              // For new todos, we need to find it by title
              final state = bloc.state;
              debugPrint(
                '📝 [TodosPage] Searching for parent in ${state.todos.length} todos',
              );
              final savedParent = state.todos.firstWhere(
                (t) => t.title == todoToSave.title && t.id.isNotEmpty,
                orElse: () => todoToSave,
              );

              debugPrint(
                '📝 [TodosPage] Found parent: id=${savedParent.id}, title=${savedParent.title}',
              );

              if (savedParent.id.isNotEmpty) {
                // Create subtasks with parent reference
                debugPrint(
                  '📝 [TodosPage] Creating ${pendingSubtasks!.length} subtasks with parentId=${savedParent.id}',
                );
                for (final subtaskTitle in pendingSubtasks!) {
                  final subtask = Todo(
                    id: '',
                    userId: userId,
                    title: subtaskTitle,
                    priority: savedParent.priority,
                    parentTodoId: savedParent.id,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  debugPrint('📝 [TodosPage] Saving subtask: $subtaskTitle');
                  bloc.add(TodosOverviewTodoSaved(subtask));
                }
                debugPrint('✅ [TodosPage] All subtasks dispatched to bloc');
              } else {
                debugPrint(
                  '❌ [TodosPage] Parent ID is empty, cannot create subtasks',
                );
              }
            } else {
              debugPrint('📝 [TodosPage] No subtasks to create');
            }
          },
          onSubtasksCreated: (subtaskTitles) {
            debugPrint(
              '📝 [TodosPage] onSubtasksCreated: ${subtaskTitles.length} subtasks - $subtaskTitles',
            );
            pendingSubtasks = subtaskTitles;
          },
        );
      },
    );
  }

  Color _getPriorityColor(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.high:
        return AppColors.coralPink;
      case TodoPriority.medium:
        return AppColors.warmTangerine;
      case TodoPriority.low:
        return AppColors.rippleBlue;
    }
  }

  Widget _buildCheckbox(
    BuildContext context,
    Todo todo,
    Color color,
    double size,
  ) {
    return GestureDetector(
      onTap: () {
        context.read<TodosOverviewBloc>().add(
          TodosOverviewTodoSaved(
            todo.copyWith(
              isCompleted: !todo.isCompleted,
              completedAt: !todo.isCompleted ? DateTime.now() : null,
            ),
          ),
        );
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: todo.isCompleted ? Colors.white : Colors.transparent,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: todo.isCompleted
            ? Icon(PhosphorIconsBold.check, size: size * 0.6, color: color)
            : null,
      ),
    );
  }
}

/// Toggle button for view mode switcher
class _ToggleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.rippleBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodosFilterBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentFilter = context.select(
      (TodosOverviewBloc bloc) => bloc.state.filter,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            isSelected: currentFilter == TodosViewFilter.all,
            onTap: () => context.read<TodosOverviewBloc>().add(
              const TodosOverviewFilterChanged(TodosViewFilter.all),
            ),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Active',
            isSelected: currentFilter == TodosViewFilter.active,
            onTap: () => context.read<TodosOverviewBloc>().add(
              const TodosOverviewFilterChanged(TodosViewFilter.active),
            ),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Done',
            isSelected: currentFilter == TodosViewFilter.completed,
            onTap: () => context.read<TodosOverviewBloc>().add(
              const TodosOverviewFilterChanged(TodosViewFilter.completed),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.inkBlack : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.inkBlack : AppColors.softGray,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
