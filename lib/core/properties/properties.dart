/// Reusable Property System for Ripple
/// 
/// This library provides an extensible property system that can be used
/// across various entity types (Notes, Todos, Milestones, etc.).
/// 
/// ## Core Concepts
/// 
/// - **PropertyType**: Defines the type of data (text, date, select, etc.)
/// - **PropertyDefinition**: Schema for a property (name, type, options)
/// - **PropertyValue**: Actual value for a property instance
/// - **PropertyRegistry**: Manages all available property definitions
/// 
/// ## Usage Example
/// 
/// ```dart
/// // Initialize registry
/// PropertyRegistry().initialize();
/// 
/// // Get a property definition
/// final dateDef = PropertyRegistry().get('date');
/// 
/// // Create property values for an entity
/// final values = PropertyValueMap()
///   .set('date', DateTime.now())
///   .set('priority', 'high')
///   .set('tags', ['work', 'urgent']);
/// ```
library;

export 'domain/entities/entities.dart';
export 'domain/repositories/property_repository.dart';
export 'data/repositories/property_repository_impl.dart';
export 'data/models/user_property_option_model.dart';
export 'data/models/entity_property_model.dart';
export 'property_registry.dart';
export 'presentation/widgets/widgets.dart';
export 'presentation/bloc/property_options_cubit.dart';
