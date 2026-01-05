import 'package:flutter/material.dart';
import 'domain/entities/entities.dart';

/// Registry of all available property definitions.
/// Provides default system properties and allows for custom property registration.
class PropertyRegistry {
  static final PropertyRegistry _instance = PropertyRegistry._internal();
  factory PropertyRegistry() => _instance;
  PropertyRegistry._internal() {
    // Auto-initialize with default properties
    _initializeDefaults();
  }

  final Map<String, PropertyDefinition> _definitions = {};
  bool _initialized = false;

  void _initializeDefaults() {
    if (_initialized) return;
    // Register all default properties
    for (final def in DefaultProperties.all) {
      _definitions[def.id] = def;
    }
    _initialized = true;
  }

  /// Initialize with default system properties (for re-initialization)
  void initialize() {
    _definitions.clear();
    _initialized = false;
    _initializeDefaults();
  }

  /// Register a custom property definition
  void register(PropertyDefinition definition) {
    _definitions[definition.id] = definition;
  }

  /// Unregister a property (only non-system properties)
  bool unregister(String propertyId) {
    final def = _definitions[propertyId];
    if (def != null && !def.isSystem) {
      _definitions.remove(propertyId);
      return true;
    }
    return false;
  }

  /// Get a property definition by ID
  PropertyDefinition? get(String propertyId) => _definitions[propertyId];

  /// Get all registered property definitions
  List<PropertyDefinition> get all => _definitions.values.toList()
    ..sort((a, b) => a.order.compareTo(b.order));

  /// Get all system property definitions
  List<PropertyDefinition> get systemProperties =>
      all.where((d) => d.isSystem).toList();

  /// Get all custom property definitions
  List<PropertyDefinition> get customProperties =>
      all.where((d) => !d.isSystem).toList();
}

/// Default system property definitions
class DefaultProperties {
  DefaultProperties._();

  /// Date property (for Notes, Milestones, etc.)
  static const date = PropertyDefinition(
    id: 'date',
    name: 'Tanggal',
    type: PropertyType.date,
    icon: Icons.calendar_today_outlined,
    isSystem: true,
    order: 1,
    placeholder: 'Pilih tanggal',
  );

  /// Priority property with predefined options
  static final priority = PropertyDefinition(
    id: 'priority',
    name: 'Prioritas',
    type: PropertyType.select,
    icon: Icons.flag_outlined,
    isSystem: true,
    order: 2,
    options: [
      const PropertyOption(
        id: 'high',
        label: 'Tinggi',
        color: Colors.red,
        order: 1,
      ),
      const PropertyOption(
        id: 'medium',
        label: 'Sedang',
        color: Colors.orange,
        order: 2,
      ),
      const PropertyOption(
        id: 'low',
        label: 'Rendah',
        color: Colors.blue,
        order: 3,
      ),
    ],
  );

  /// Tags property (multi-select)
  static const tags = PropertyDefinition(
    id: 'tags',
    name: 'Tag',
    type: PropertyType.multiSelect,
    icon: Icons.label_outline,
    isSystem: true,
    order: 3,
    options: [], // Options loaded dynamically from user's tag list
  );

  /// Status property (select with 3 options)
  static final status = PropertyDefinition(
    id: 'status',
    name: 'Status',
    type: PropertyType.select,
    icon: Icons.check_circle_outline,
    isSystem: true,
    order: 4,
    options: [
      const PropertyOption(
        id: 'not_started',
        label: 'Belum Dimulai',
        color: Color(0xFF6B7280), // Gray
        order: 1,
      ),
      const PropertyOption(
        id: 'in_progress',
        label: 'Sedang Berjalan',
        color: Color(0xFF3B82F6), // Blue
        order: 2,
      ),
      const PropertyOption(
        id: 'done',
        label: 'Selesai',
        color: Color(0xFF10B981), // Green
        order: 3,
      ),
    ],
  );

  /// Description property (multiline text)
  static const description = PropertyDefinition(
    id: 'description',
    name: 'Deskripsi',
    type: PropertyType.multilineText,
    icon: Icons.notes_outlined,
    isSystem: true,
    order: 5,
    placeholder: 'Tambahkan deskripsi...',
  );

  /// All default properties
  static List<PropertyDefinition> get all => [
        date,
        priority,
        tags,
        status,
        description,
      ];
}
