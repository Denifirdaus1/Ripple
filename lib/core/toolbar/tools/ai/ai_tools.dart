import 'package:flutter/material.dart';
import '../../domain/entities/entities.dart';

/// AI suggestion tool (placeholder)
class AiSuggestTool extends ToolDefinition {
  @override String get id => 'ai_suggest';
  @override String get name => 'AI Suggest';
  @override IconData get icon => Icons.auto_awesome_outlined;
  @override ToolCategory get category => ToolCategory.ai;
  @override int get order => 400;
  @override bool get isSystem => true;

  @override
  bool isActive(ToolContext context) => false;

  @override
  bool isEnabled(ToolContext context) => false; // Not implemented yet

  @override
  void execute(ToolContext context) {
    // TODO: Implement AI suggestion
  }
}
