import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/milestone.dart';

class AddMilestoneSheet extends StatefulWidget {
  final String goalId;
  final Milestone? initialMilestone; // For edit mode
  final void Function(Milestone milestone) onSave;

  const AddMilestoneSheet({
    super.key,
    required this.goalId,
    this.initialMilestone,
    required this.onSave,
  });

  @override
  State<AddMilestoneSheet> createState() => _AddMilestoneSheetState();
}

class _AddMilestoneSheetState extends State<AddMilestoneSheet> {
  late final TextEditingController _titleController;
  DateTime? _targetDate;
  bool _isSubmitting = false;

  bool get isEditMode => widget.initialMilestone != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialMilestone?.title ?? '');
    _targetDate = widget.initialMilestone?.targetDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEditMode ? 'Edit Milestone' : 'Add Milestone',
                style: AppTypography.h4?.copyWith(color: AppColors.inkBlack),
              ),
              IconButton(
                icon: const Icon(PhosphorIconsRegular.x),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Title Field
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Milestone Title',
              hintText: 'e.g., Complete Phase 1',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.rippleBlue, width: 2),
              ),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 16),

          // Target Date Picker
          GestureDetector(
            onTap: _pickTargetDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.softGray),
              ),
              child: Row(
                children: [
                  Icon(PhosphorIconsRegular.calendarBlank, color: AppColors.textSecondary),
                  const SizedBox(width: 12),
                  Text(
                    _targetDate != null ? _formatDate(_targetDate!) : 'Set Target Date (Optional)',
                    style: AppTypography.body?.copyWith(
                      color: _targetDate != null ? AppColors.inkBlack : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.rippleBlue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      isEditMode ? 'Update' : 'Add Milestone',
                      style: AppTypography.bodyBold?.copyWith(color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickTargetDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _targetDate = picked;
      });
    }
  }

  void _handleSave() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final milestone = Milestone(
      id: widget.initialMilestone?.id ?? '',
      goalId: widget.goalId,
      title: title,
      targetDate: _targetDate,
      notes: widget.initialMilestone?.notes,
      bannerUrl: widget.initialMilestone?.bannerUrl,
      isCompleted: widget.initialMilestone?.isCompleted ?? false,
      completedAt: widget.initialMilestone?.completedAt,
      orderIndex: widget.initialMilestone?.orderIndex ?? 0,
      createdAt: widget.initialMilestone?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.onSave(milestone);
    Navigator.of(context).pop();
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
