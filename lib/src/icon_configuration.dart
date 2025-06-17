/// Icon configuration classes for type-safe icon handling

/// Base class for icon configuration
abstract class IconConfiguration {
  final String identifier;
  final String displayName;
  final String? activityAlias;
  
  const IconConfiguration({
    required this.identifier,
    required this.displayName,
    this.activityAlias,
  });
  
  @override
  String toString() => displayName;
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IconConfiguration &&
          runtimeType == other.runtimeType &&
          identifier == other.identifier;

  @override
  int get hashCode => identifier.hashCode;
}

/// Predefined icon configurations for common use cases
class AppIcon extends IconConfiguration {
  /// Default app icon (usually the main icon)
  static const AppIcon defaultIcon = AppIcon._('default', 'Default');
  
  const AppIcon._(String id, String name, [String? alias]) : super(
    identifier: id,
    displayName: name,
    activityAlias: alias,
  );
  
  /// Create a custom icon configuration
  const AppIcon.custom({
    required String identifier,
    required String displayName,
    String? activityAlias,
  }) : super(
    identifier: identifier,
    displayName: displayName,
    activityAlias: activityAlias,
  );
}
