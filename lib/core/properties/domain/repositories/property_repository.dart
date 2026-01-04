import '../entities/user_property_option.dart';
import '../entities/entity_property.dart';

/// Repository interface for property-related operations
abstract class PropertyRepository {
  /// Get all options for a specific property (e.g., all tags, all priorities)
  Future<List<UserPropertyOption>> getOptions(String propertyId);
  
  /// Create a new option
  Future<UserPropertyOption> createOption({
    required String propertyId,
    required String optionId,
    required String label,
    String? color,
    String? icon,
    int orderIndex = 0,
  });
  
  /// Update an existing option
  Future<UserPropertyOption> updateOption(UserPropertyOption option);
  
  /// Delete an option
  Future<void> deleteOption(String id);
  
  /// Get enabled properties for an entity
  Future<List<EntityProperty>> getEntityProperties({
    required String entityType,
    required String entityId,
  });
  
  /// Enable a property on an entity
  Future<EntityProperty> enableProperty({
    required String entityType,
    required String entityId,
    required String propertyId,
  });
  
  /// Disable a property on an entity
  Future<void> disableProperty({
    required String entityType,
    required String entityId,
    required String propertyId,
  });
}
