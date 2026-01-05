import 'package:flutter/material.dart';
import '../../domain/entities/entities.dart';

/// Camera/Image picker tool
class ImageTool extends ToolDefinition {
  @override String get id => 'image';
  @override String get name => 'Image';
  @override IconData get icon => Icons.camera_alt_outlined;
  @override ToolCategory get category => ToolCategory.media;
  @override int get order => 300;
  @override bool get isSystem => true;

  @override
  bool isActive(ToolContext context) => false;

  @override
  bool isEnabled(ToolContext context) => context.onImageTap != null;

  @override
  void execute(ToolContext context) {
    context.onImageTap?.call();
  }
}

/// Voice recording tool (placeholder)
class VoiceTool extends ToolDefinition {
  @override String get id => 'voice';
  @override String get name => 'Voice';
  @override IconData get icon => Icons.mic_none_outlined;
  @override ToolCategory get category => ToolCategory.media;
  @override int get order => 301;
  @override bool get isSystem => true;

  @override
  bool isActive(ToolContext context) => false;

  @override
  bool isEnabled(ToolContext context) => false; // Not implemented yet

  @override
  void execute(ToolContext context) {
    // TODO: Implement voice recording
  }
}
