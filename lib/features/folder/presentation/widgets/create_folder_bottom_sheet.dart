import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/folder_bloc.dart';

/// Bottom sheet for creating a new folder
class CreateFolderBottomSheet extends StatefulWidget {
  const CreateFolderBottomSheet({super.key});

  /// Show the bottom sheet and return true if folder was created
  static Future<bool> show(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.paperWhite,
      isScrollControlled: true,
      useRootNavigator: true, // Show above FAB
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<FolderBloc>(),
        child: const CreateFolderBottomSheet(),
      ),
    );
    return result ?? false;
  }

  @override
  State<CreateFolderBottomSheet> createState() =>
      _CreateFolderBottomSheetState();
}

class _CreateFolderBottomSheetState extends State<CreateFolderBottomSheet> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto focus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _createFolder() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    context.read<FolderBloc>().add(FolderCreated(name: name));
    Navigator.of(context).pop(true);
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
            children: [
              Icon(
                Icons.create_new_folder_rounded,
                color: AppColors.rippleBlue,
              ),
              const SizedBox(width: 12),
              const Text(
                'Buat Folder Baru',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Input field
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: 'Nama folder...',
              filled: true,
              fillColor: AppColors.softGray,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _createFolder(),
          ),
          const SizedBox(height: 20),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _createFolder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.rippleBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Buat Folder'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
