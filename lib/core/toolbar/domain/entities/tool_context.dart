import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

/// Context object passed to toolbar tools during execution.
/// Contains all necessary information for tools to operate.
class ToolContext {
  /// Flutter's BuildContext for showing dialogs, snackbars, etc.
  final BuildContext buildContext;
  
  /// QuillController for text formatting operations (optional)
  final QuillController? quillController;
  
  /// Callback to hide the keyboard
  final VoidCallback? onHideKeyboard;
  
  /// Callback for image picker
  final VoidCallback? onImageTap;
  
  /// Callback for mention feature
  final VoidCallback? onMentionTap;
  
  /// Extensible map for custom data from features
  final Map<String, dynamic> extra;

  const ToolContext({
    required this.buildContext,
    this.quillController,
    this.onHideKeyboard,
    this.onImageTap,
    this.onMentionTap,
    this.extra = const {},
  });

  /// Create a copy with modified properties
  ToolContext copyWith({
    BuildContext? buildContext,
    QuillController? quillController,
    VoidCallback? onHideKeyboard,
    VoidCallback? onImageTap,
    VoidCallback? onMentionTap,
    Map<String, dynamic>? extra,
  }) {
    return ToolContext(
      buildContext: buildContext ?? this.buildContext,
      quillController: quillController ?? this.quillController,
      onHideKeyboard: onHideKeyboard ?? this.onHideKeyboard,
      onImageTap: onImageTap ?? this.onImageTap,
      onMentionTap: onMentionTap ?? this.onMentionTap,
      extra: extra ?? this.extra,
    );
  }
}
