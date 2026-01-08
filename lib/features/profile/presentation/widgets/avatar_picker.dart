import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Widget for picking and displaying user avatar with compression
class AvatarPicker extends StatefulWidget {
  final String? currentAvatarUrl;
  final String fallbackInitial;
  final Function(Uint8List imageBytes, String fileName) onImageSelected;
  final VoidCallback? onDeleteRequested;
  final bool isLoading;

  const AvatarPicker({
    super.key,
    this.currentAvatarUrl,
    required this.fallbackInitial,
    required this.onImageSelected,
    this.onDeleteRequested,
    this.isLoading = false,
  });

  @override
  State<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<AvatarPicker> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    debugPrint('📸 [AvatarPicker] Opening image picker');

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (image == null) {
        debugPrint('📸 [AvatarPicker] No image selected');
        return;
      }

      debugPrint('📸 [AvatarPicker] Image selected: ${image.path}');

      // Compress image to 90% quality
      final compressedBytes = await _compressImage(image.path);

      if (compressedBytes != null) {
        debugPrint(
          '📸 [AvatarPicker] Compressed size: ${compressedBytes.length} bytes',
        );
        widget.onImageSelected(compressedBytes, image.name);
      }
    } catch (e) {
      debugPrint('❌ [AvatarPicker] Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
      }
    }
  }

  Future<Uint8List?> _compressImage(String path) async {
    debugPrint('📸 [AvatarPicker] Compressing image at 90% quality');

    final File file = File(path);
    final originalSize = await file.length();
    debugPrint('📸 [AvatarPicker] Original size: $originalSize bytes');

    final result = await FlutterImageCompress.compressWithFile(
      path,
      minWidth: 256,
      minHeight: 256,
      quality: 90, // 90% compression as requested
      format: CompressFormat.jpeg,
    );

    if (result != null) {
      debugPrint(
        '📸 [AvatarPicker] Compressed: ${originalSize} -> ${result.length} bytes',
      );
      debugPrint(
        '📸 [AvatarPicker] Reduction: ${((1 - result.length / originalSize) * 100).toStringAsFixed(1)}%',
      );
    }

    return result;
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(PhosphorIconsRegular.image),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            if (widget.currentAvatarUrl != null &&
                widget.onDeleteRequested != null)
              ListTile(
                leading: Icon(
                  PhosphorIconsRegular.trash,
                  color: AppColors.coralPink,
                ),
                title: Text(
                  'Remove Photo',
                  style: TextStyle(color: AppColors.coralPink),
                ),
                onTap: () {
                  Navigator.pop(context);
                  widget.onDeleteRequested?.call();
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isLoading ? null : _showOptions,
      child: Stack(
        children: [
          // Avatar image or initial
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.rippleBlue.withOpacity(0.1),
              border: Border.all(
                color: AppColors.rippleBlue.withOpacity(0.3),
                width: 3,
              ),
            ),
            child: ClipOval(
              child: widget.currentAvatarUrl != null
                  ? Image.network(
                      widget.currentAvatarUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                            strokeWidth: 2,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return _buildInitialAvatar();
                      },
                    )
                  : _buildInitialAvatar(),
            ),
          ),

          // Loading overlay
          if (widget.isLoading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.5),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ),
              ),
            ),

          // Edit button
          if (!widget.isLoading)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.rippleBlue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  PhosphorIconsRegular.camera,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInitialAvatar() {
    return Center(
      child: Text(
        widget.fallbackInitial,
        style: AppTypography.textTheme.headlineLarge?.copyWith(
          color: AppColors.rippleBlue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
