import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/recurrence_rule.dart';

/// A widget for selecting recurrence days (weekday picker)
class RecurrencePicker extends StatefulWidget {
  /// Initial recurrence rule (if editing)
  final RecurrenceRule? initialRule;

  /// Callback when recurrence rule changes
  final ValueChanged<RecurrenceRule?> onChanged;

  /// Whether recurrence is enabled
  final bool enabled;

  const RecurrencePicker({
    super.key,
    this.initialRule,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  State<RecurrencePicker> createState() => _RecurrencePickerState();
}

class _RecurrencePickerState extends State<RecurrencePicker> {
  late bool _isRecurring;
  late Set<int> _selectedDays;

  @override
  void initState() {
    super.initState();
    _isRecurring = widget.initialRule != null;
    _selectedDays = Set.from(widget.initialRule?.days ?? []);
  }

  void _toggleRecurrence(bool value) {
    setState(() {
      _isRecurring = value;
      if (!value) {
        _selectedDays.clear();
        widget.onChanged(null);
      } else if (_selectedDays.isNotEmpty) {
        _emitRule();
      }
    });
  }

  void _toggleDay(int day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
      _emitRule();
    });
  }

  void _emitRule() {
    if (_selectedDays.isEmpty) {
      widget.onChanged(null);
    } else {
      widget.onChanged(RecurrenceRule.weekly(days: _selectedDays.toList()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.repeat_rounded,
                  size: 20,
                  color: _isRecurring
                      ? AppColors.rippleBlue
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Ulangi',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: _isRecurring
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            Switch(
              value: _isRecurring,
              onChanged: widget.enabled ? _toggleRecurrence : null,
              activeColor: AppColors.rippleBlue,
            ),
          ],
        ),

        // Day selector (only visible when recurring is on)
        if (_isRecurring) ...[
          const SizedBox(height: 12),
          Text(
            'Pilih hari:',
            style: AppTypography.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),

          // Weekday chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(7, (index) {
              final isSelected = _selectedDays.contains(index);
              return _DayChip(
                day: index,
                isSelected: isSelected,
                onTap: widget.enabled ? () => _toggleDay(index) : null,
              );
            }),
          ),

          // Quick presets
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _PresetChip(
                label: 'Hari Kerja',
                onTap: widget.enabled
                    ? () {
                        setState(() {
                          _selectedDays = {1, 2, 3, 4, 5}; // Mon-Fri
                          _emitRule();
                        });
                      }
                    : null,
              ),
              _PresetChip(
                label: 'Akhir Pekan',
                onTap: widget.enabled
                    ? () {
                        setState(() {
                          _selectedDays = {0, 6}; // Sun, Sat
                          _emitRule();
                        });
                      }
                    : null,
              ),
              _PresetChip(
                label: 'Setiap Hari',
                onTap: widget.enabled
                    ? () {
                        setState(() {
                          _selectedDays = {0, 1, 2, 3, 4, 5, 6};
                          _emitRule();
                        });
                      }
                    : null,
              ),
            ],
          ),

          // Current selection summary
          if (_selectedDays.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.rippleBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.event_repeat_rounded,
                    size: 16,
                    color: AppColors.rippleBlue,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      RecurrenceRule.weekly(
                        days: _selectedDays.toList(),
                      ).displayText,
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: AppColors.rippleBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }
}

/// Individual day chip
class _DayChip extends StatelessWidget {
  final int day;
  final bool isSelected;
  final VoidCallback? onTap;

  const _DayChip({required this.day, required this.isSelected, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.rippleBlue : AppColors.softGray,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.rippleBlue : AppColors.softGray,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            RecurrenceRule.weekdayNames[day],
            style: AppTypography.textTheme.bodySmall?.copyWith(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

/// Preset selection chip
class _PresetChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _PresetChip({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.paperWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.softGray),
        ),
        child: Text(
          label,
          style: AppTypography.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
