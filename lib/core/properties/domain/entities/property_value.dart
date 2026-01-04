import 'package:equatable/equatable.dart';
import 'property_definition.dart';

/// Holds the actual value for a property.
/// This is the "data" - the value assigned to a specific property for an entity.
class PropertyValue extends Equatable {
  /// Reference to the property definition
  final String propertyId;
  
  /// The actual value (type depends on PropertyDefinition.type)
  /// - text/multilineText/url/email/phone: String
  /// - number: num (int or double)
  /// - date/datetime: DateTime
  /// - select: String (option id)
  /// - multiSelect: List<String> (option ids)
  /// - checkbox: bool
  /// - relation: String (entity id)
  final dynamic value;

  const PropertyValue({
    required this.propertyId,
    required this.value,
  });

  /// Whether this property has a value set
  bool get hasValue {
    if (value == null) return false;
    if (value is String) return value.isNotEmpty;
    if (value is List) return value.isNotEmpty;
    return true;
  }

  /// Creates a copy with updated value
  PropertyValue copyWith({
    String? propertyId,
    dynamic value,
  }) {
    return PropertyValue(
      propertyId: propertyId ?? this.propertyId,
      value: value ?? this.value,
    );
  }

  @override
  List<Object?> get props => [propertyId, value];
}

/// A collection of property values for an entity.
/// Provides convenient access methods.
class PropertyValueMap extends Equatable {
  final Map<String, PropertyValue> _values;

  const PropertyValueMap([Map<String, PropertyValue>? values])
      : _values = values ?? const {};

  /// Gets a property value by property ID
  PropertyValue? get(String propertyId) => _values[propertyId];

  /// Gets the raw value for a property
  dynamic getValue(String propertyId) => _values[propertyId]?.value;

  /// Gets a typed value for a property
  T? getTypedValue<T>(String propertyId) {
    final value = _values[propertyId]?.value;
    if (value is T) return value;
    return null;
  }

  /// Sets a property value
  PropertyValueMap set(String propertyId, dynamic value) {
    final newValues = Map<String, PropertyValue>.from(_values);
    newValues[propertyId] = PropertyValue(propertyId: propertyId, value: value);
    return PropertyValueMap(newValues);
  }

  /// Removes a property value
  PropertyValueMap remove(String propertyId) {
    final newValues = Map<String, PropertyValue>.from(_values);
    newValues.remove(propertyId);
    return PropertyValueMap(newValues);
  }

  /// Whether a property has a value
  bool hasProperty(String propertyId) {
    return _values.containsKey(propertyId) && _values[propertyId]!.hasValue;
  }

  /// All property IDs with values
  Iterable<String> get propertyIds => _values.keys;

  /// All property values
  Iterable<PropertyValue> get values => _values.values;

  /// Number of properties
  int get length => _values.length;

  /// Whether empty
  bool get isEmpty => _values.isEmpty;

  /// Convert to Map for serialization
  Map<String, dynamic> toMap() {
    return _values.map((key, value) => MapEntry(key, value.value));
  }

  /// Create from Map
  factory PropertyValueMap.fromMap(Map<String, dynamic> map) {
    final values = map.map((key, value) => MapEntry(
          key,
          PropertyValue(propertyId: key, value: value),
        ));
    return PropertyValueMap(values);
  }

  @override
  List<Object?> get props => [_values];
}
