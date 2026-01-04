part of 'property_options_cubit.dart';

class PropertyOptionsState extends Equatable {
  final bool isLoading;
  final String? error;
  final Map<String, List<UserPropertyOption>> options;
  final List<String> enabledProperties;

  const PropertyOptionsState({
    this.isLoading = false,
    this.error,
    this.options = const {},
    this.enabledProperties = const [],
  });

  PropertyOptionsState copyWith({
    bool? isLoading,
    String? error,
    Map<String, List<UserPropertyOption>>? options,
    List<String>? enabledProperties,
  }) {
    return PropertyOptionsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      options: options ?? this.options,
      enabledProperties: enabledProperties ?? this.enabledProperties,
    );
  }

  /// Get options for a specific property
  List<UserPropertyOption> getPropertyOptions(String propertyId) {
    return options[propertyId] ?? [];
  }

  /// Check if a property is enabled
  bool isPropertyEnabled(String propertyId) {
    return enabledProperties.contains(propertyId);
  }

  @override
  List<Object?> get props => [isLoading, error, options, enabledProperties];
}
