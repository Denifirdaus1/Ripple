import 'domain/entities/entities.dart';

/// Singleton registry for toolbar tool definitions.
/// Provides centralized management of all available toolbar tools.
class ToolbarRegistry {
  static final ToolbarRegistry _instance = ToolbarRegistry._internal();
  factory ToolbarRegistry() => _instance;
  ToolbarRegistry._internal();

  final List<ToolDefinition> _orderedTools = [];
  final Map<String, ToolDefinition> _toolsMap = {};
  bool _initialized = false;

  /// Initialize registry with default tools
  void initialize(List<ToolDefinition> defaultTools) {
    if (_initialized) return;
    for (final tool in defaultTools) {
      _toolsMap[tool.id] = tool;
      _orderedTools.add(tool);
    }
    _initialized = true;
  }

  /// Re-initialize registry (clears all tools first)
  void reinitialize(List<ToolDefinition> defaultTools) {
    _toolsMap.clear();
    _orderedTools.clear();
    _initialized = false;
    initialize(defaultTools);
  }

  /// Register a custom tool
  void register(ToolDefinition tool) {
    if (!_toolsMap.containsKey(tool.id)) {
      _orderedTools.add(tool);
    }
    _toolsMap[tool.id] = tool;
  }

  /// Unregister a tool (only non-system tools)
  bool unregister(String toolId) {
    final tool = _toolsMap[toolId];
    if (tool != null && !tool.isSystem) {
      _toolsMap.remove(toolId);
      _orderedTools.removeWhere((t) => t.id == toolId);
      return true;
    }
    return false;
  }

  /// Get a tool by ID
  ToolDefinition? get(String toolId) => _toolsMap[toolId];

  /// Get all registered tools in insertion order
  List<ToolDefinition> get all => List.unmodifiable(_orderedTools);

  /// Get tools by category
  List<ToolDefinition> byCategory(ToolCategory category) =>
      all.where((t) => t.category == category).toList();

  /// Get all system tools
  List<ToolDefinition> get systemTools =>
      all.where((t) => t.isSystem).toList();

  /// Get all custom (non-system) tools
  List<ToolDefinition> get customTools =>
      all.where((t) => !t.isSystem).toList();

  /// Check if registry has been initialized
  bool get isInitialized => _initialized;
}
