import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../domain/entities/entities.dart';
import '../../toolbar_registry.dart';
import '../../tools/default_tools.dart';
import 'toolbar_icon.dart';

/// Extensible toolbar widget that displays registered tools.
/// Can be customized by filtering tools or categories.
class ExtensibleToolbar extends StatefulWidget {
  /// Context for tool execution
  final ToolContext toolContext;
  
  /// List of tool IDs to show (null = show all)
  final List<String>? enabledToolIds;
  
  /// List of tool IDs to hide
  final List<String>? disabledToolIds;
  
  /// Filter to show only specific categories
  final List<ToolCategory>? filterCategories;
  
  /// Height of the toolbar
  final double height;

  const ExtensibleToolbar({
    super.key,
    required this.toolContext,
    this.enabledToolIds,
    this.disabledToolIds,
    this.filterCategories,
    this.height = 52,
  });

  @override
  State<ExtensibleToolbar> createState() => _ExtensibleToolbarState();
}

class _ExtensibleToolbarState extends State<ExtensibleToolbar> {
  @override
  void initState() {
    super.initState();
    // Ensure registry is initialized
    final registry = ToolbarRegistry();
    if (!registry.isInitialized) {
      registry.initialize(DefaultTools.all);
    }
  }

  @override
  Widget build(BuildContext context) {
    final registry = ToolbarRegistry();
    var tools = registry.all;
    
    // Filter by enabled IDs
    if (widget.enabledToolIds != null) {
      tools = tools.where((t) => widget.enabledToolIds!.contains(t.id)).toList();
    }
    
    // Filter out disabled IDs
    if (widget.disabledToolIds != null) {
      tools = tools.where((t) => !widget.disabledToolIds!.contains(t.id)).toList();
    }
    
    // Filter by categories
    if (widget.filterCategories != null) {
      tools = tools.where((t) => widget.filterCategories!.contains(t.category)).toList();
    }

    return Container(
      height: widget.height,
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.outlineGray, width: 0.5),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: tools.length,
        itemBuilder: (context, index) {
          final tool = tools[index];
          return _buildToolIcon(tool);
        },
      ),
    );
  }

  Widget _buildToolIcon(ToolDefinition tool) {
    return ToolbarIcon(
      icon: tool.icon,
      isActive: tool.isActive(widget.toolContext),
      isEnabled: tool.isEnabled(widget.toolContext),
      onTap: tool.isEnabled(widget.toolContext) 
          ? () {
              tool.execute(widget.toolContext);
              setState(() {}); // Rebuild to update active states
            }
          : null,
    );
  }
}
