import 'package:flutter/material.dart';
import 'tool_category.dart';
import 'tool_context.dart';

/// Abstract base class for all toolbar tool definitions.
/// Extend this class to create custom tools.
abstract class ToolDefinition {
  /// Unique identifier for this tool
  String get id;
  
  /// Display name for the tool
  String get name;
  
  /// Icon to display in toolbar
  IconData get icon;
  
  /// Category for grouping tools
  ToolCategory get category;
  
  /// Sort order within category (lower = first)
  int get order;
  
  /// Whether this is a system tool (cannot be unregistered)
  bool get isSystem;
  
  /// Check if the tool is currently active (e.g., bold is applied)
  bool isActive(ToolContext context);
  
  /// Check if the tool is enabled (can be tapped)
  bool isEnabled(ToolContext context);
  
  /// Execute the tool action
  void execute(ToolContext context);
}
