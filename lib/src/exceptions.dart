/// Custom exception types for better error handling in mobile_icon_switcher

/// Base exception class for all icon switcher related errors
class IconSwitcherException implements Exception {
  final String message;
  final String? code;
  
  const IconSwitcherException(this.message, {this.code});
  
  @override
  String toString() => 'IconSwitcherException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Exception thrown when an icon is not supported or not found
class IconNotSupportedException extends IconSwitcherException {
  const IconNotSupportedException(String message) : super(message, code: 'ICON_NOT_SUPPORTED');
}

/// Exception thrown when the platform doesn't support icon switching
class PlatformNotSupportedException extends IconSwitcherException {
  const PlatformNotSupportedException(String message) : super(message, code: 'PLATFORM_NOT_SUPPORTED');
}

/// Exception thrown when icon switching operation fails
class IconSwitchFailedException extends IconSwitcherException {
  const IconSwitchFailedException(String message) : super(message, code: 'ICON_SWITCH_FAILED');
}
