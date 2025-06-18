library mobile_icon_switcher;

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// Export public classes
export 'src/exceptions.dart';
export 'src/icon_configuration.dart';

import 'src/exceptions.dart';
import 'src/icon_configuration.dart';

class MobileIconSwitcher {
  static const MethodChannel _channel = MethodChannel('app_icon_switcher');
  
  // Singleton instance for caching
  static final MobileIconSwitcher _instance = MobileIconSwitcher._internal();
  
  // Cache for current icon status
  String? _cachedCurrentIcon;
  DateTime? _cacheTimestamp;
  static const _cacheTimeout = Duration(seconds: 30);
  
  // Debug logging
  static bool _debugMode = false;
  
  // Platform override for testing
  static bool? _platformOverride;
  
  MobileIconSwitcher._internal();

  /// Enable debug logging for troubleshooting
  static void enableDebugMode() {
    _debugMode = true;
  }
  
  /// Disable debug logging
  static void disableDebugMode() {
    _debugMode = false;
  }
  
  static void _log(String message) {
    if (_debugMode) {
      print('[MobileIconSwitcher] $message');
    }
  }

  /// Override platform detection for testing
  @visibleForTesting
  static void setPlatformOverride(bool isSupported) {
    _platformOverride = isSupported;
  }

  /// Clear platform override for testing
  @visibleForTesting
  static void clearPlatformOverride() {
    _platformOverride = null;
  }

  /// Check if platform supports icon switching
  static bool get _isPlatformSupported {
    if (_platformOverride != null) {
      return _platformOverride!;
    }
    return Platform.isAndroid || Platform.isIOS;
  }

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  /// This function changes the app icon and returns a boolean indicating whether the operation was
  /// successful or not.
  ///
  /// Args:
  ///   iconName (String): A string representing the name of the new app icon that you want to change to.
  ///   iconActivityAlias (String): `iconActivityAlias` is a string parameter that represents the activity
  /// alias name of the launcher icon that you want to change. An activity alias is an alternate entry
  /// point into an activity that allows you to provide different labels, icons, and intents for the same
  /// underlying activity. In this case, the `
  ///
  /// Returns:
  ///   A `Future<bool>` is being returned.
  @Deprecated('Use setIcon instead for better error handling and type safety')
  static Future<bool> changeIcon(
      String iconName, String iconActivityAlias) async {
    try {
      await setIcon(iconName: iconName, activityAlias: iconActivityAlias);
      return true;
    } catch (e) {
      _log('changeIcon failed: $e');
      return false;
    }
  }

  /// Sets the app icon using modern API with proper error handling
  ///
  /// Args:
  ///   iconName: The name of the icon to set
  ///   activityAlias: (Android only) The activity alias for the icon
  ///   iconConfig: Alternative to iconName - use IconConfiguration object
  ///
  /// Throws:
  ///   [PlatformNotSupportedException] if platform doesn't support icon switching
  ///   [IconNotSupportedException] if the specified icon is not available
  ///   [IconSwitchFailedException] if the operation fails
  static Future<void> setIcon({
    String? iconName,
    String? activityAlias,
    IconConfiguration? iconConfig,
  }) async {
    // Validate platform support
    if (!_isPlatformSupported) {
      throw const PlatformNotSupportedException(
        'Icon switching is only supported on iOS and Android'
      );
    }

    // Determine icon name and alias
    final String targetIconName;
    final String? targetAlias;
    
    if (iconConfig != null) {
      targetIconName = iconConfig.identifier;
      targetAlias = iconConfig.activityAlias;
    } else if (iconName != null) {
      targetIconName = iconName;
      targetAlias = activityAlias;
    } else {
      throw const IconSwitchFailedException(
        'Either iconName or iconConfig must be provided'
      );
    }

    _log('Setting icon to: $targetIconName${targetAlias != null ? ' (alias: $targetAlias)' : ''}');
    
    try {
      final bool success = await _channel.invokeMethod('changeIcon', {
        'iconName': targetIconName,
        'iconActivityAlias': targetAlias ?? targetIconName,
      });
      
      if (!success) {
        throw IconSwitchFailedException('Failed to change icon to $targetIconName');
      }
      
      // Update cache
      _instance._cachedCurrentIcon = targetIconName;
      _instance._cacheTimestamp = DateTime.now();
      
      _log('Icon successfully changed to: $targetIconName');
    } on PlatformException catch (e) {
      _log('Platform error changing icon: ${e.message}');
      switch (e.code) {
        case 'ICON_NOT_FOUND':
          throw IconNotSupportedException('Icon "$targetIconName" not found');
        case 'UNSUPPORTED_PLATFORM':
          throw const PlatformNotSupportedException(
            'Icon switching not supported on this platform'
          );
        default:
          throw IconSwitchFailedException(
            'Failed to change icon: ${e.message ?? e.code}'
          );
      }
    } catch (e) {
      _log('Unexpected error changing icon: $e');
      throw IconSwitchFailedException('Unexpected error: $e');
    }
  }

  /// Gets the currently active icon name
  ///
  /// Returns the identifier of the currently active icon, or null if unable to determine
  static Future<String?> getCurrentIcon() async {
    final instance = _instance;
    
    // Check cache first
    if (instance._cachedCurrentIcon != null && 
        instance._cacheTimestamp != null &&
        DateTime.now().difference(instance._cacheTimestamp!) < _cacheTimeout) {
      _log('Returning cached current icon: ${instance._cachedCurrentIcon}');
      return instance._cachedCurrentIcon;
    }
    
    try {
      final String? currentIcon = await _channel.invokeMethod('getCurrentIcon');
      
      // Update cache
      instance._cachedCurrentIcon = currentIcon;
      instance._cacheTimestamp = DateTime.now();
      
      _log('Current icon: $currentIcon');
      return currentIcon;
    } on PlatformException catch (e) {
      _log('Error getting current icon: ${e.message}');
      if (e.code == 'UNSUPPORTED_PLATFORM') {
        throw const PlatformNotSupportedException(
          'Getting current icon not supported on this platform'
        );
      }
      return null;
    } catch (e) {
      _log('Unexpected error getting current icon: $e');
      return null;
    }
  }

  /// Gets all available icons for the current platform
  ///
  /// Returns a list of available icon identifiers
  static Future<List<String>> getAvailableIcons() async {
    if (!_isPlatformSupported) {
      throw const PlatformNotSupportedException(
        'Icon switching is only supported on iOS and Android'
      );
    }
    return await _getAvailableIconsFromPlatform();
  }

  static Future<List<String>> _getAvailableIconsFromPlatform() async {
    try {
      final List<dynamic>? icons = await _channel.invokeMethod('getAvailableIcons');
      return icons?.cast<String>() ?? [];
    } on PlatformException catch (e) {
      _log('Error getting available icons: ${e.message}');
      return [];
    } catch (e) {
      _log('Unexpected error getting available icons: $e');
      return [];
    }
  }

  /// This function sets the default component for Android and returns a boolean indicating success.
  ///
  /// Args:
  ///   defaultComponent (String): The `defaultComponent` parameter is a string that represents the
  /// package name and class name of the default activity to launch when the app is opened. This method
  /// is used to set the default component for an Android app.
  /// `com.example.example.MainActivity
  ///
  /// Returns:
  ///   The function `setDefaultComponent` returns a `Future<bool>`. If the platform is Android, it
  /// invokes a method named `defaultComponent` with a `Map` parameter containing a `String` key
  /// `component` and the value of `defaultComponent`. The method returns a `bool` value indicating
  /// whether the operation was successful or not. If the platform is not Android, the function returns
  /// `true
  @Deprecated('Use setIcon with proper error handling instead')
  static Future<bool> setDefaultComponent(String defaultComponent) async {
    if (!Platform.isAndroid) {
      _log('setDefaultComponent called on non-Android platform');
      return true;
    }
    
    try {
      final bool success =
          await _channel.invokeMethod('defaultComponent', {
        'component': defaultComponent,
      });
      _log('setDefaultComponent result: $success');
      return success;
    } catch (e) {
      _log('setDefaultComponent failed: $e');
      return false;
    }
  }

  /// The function `resetIcon` is a static method in Dart that invokes a platform-specific method called
  /// 'resetIcon'. This call will reset the App's Icon to the default value.
  ///
  /// For IOS:
  ///   There is an actual reset, so I do a real reset
  ///
  /// For Android:
  ///   I only set the defaultComponent to put the app in the state it
  ///   was before.
  ///
  /// Returns:
  ///   The method is returning a Future<bool> value, which states if the reset
  ///   was successful or not.
  @Deprecated('Use resetToDefaultIcon for better error handling')
  static Future<bool> resetIcon() async {
    try {
      await resetToDefaultIcon();
      return true;
    } catch (e) {
      _log('resetIcon failed: $e');
      return false;
    }
  }

  /// Resets the app icon to the default icon
  ///
  /// Throws:
  ///   [PlatformNotSupportedException] if platform doesn't support icon switching
  ///   [IconSwitchFailedException] if the reset operation fails
  static Future<void> resetToDefaultIcon() async {
    if (!_isPlatformSupported) {
      throw const PlatformNotSupportedException(
        'Icon switching is only supported on iOS and Android'
      );
    }

    _log('Resetting icon to default');
    
    try {
      final bool success = await _channel.invokeMethod('resetIcon');
      
      if (!success) {
        throw const IconSwitchFailedException('Failed to reset icon to default');
      }
      
      // Clear cache since we've reset
      _instance._cachedCurrentIcon = null;
      _instance._cacheTimestamp = null;
      
      _log('Icon successfully reset to default');
    } on PlatformException catch (e) {
      _log('Platform error resetting icon: ${e.message}');
      throw IconSwitchFailedException(
        'Failed to reset icon: ${e.message ?? e.code}'
      );
    } catch (e) {
      _log('Unexpected error resetting icon: $e');
      throw IconSwitchFailedException('Unexpected error during reset: $e');
    }
  }

  /// Clears the internal cache for icon state
  ///
  /// Use this if you suspect the cached icon state is out of sync
  static void clearCache() {
    _log('Clearing icon cache');
    _instance._cachedCurrentIcon = null;
    _instance._cacheTimestamp = null;
  }

  /// Checks if icon switching is supported on the current platform
  static bool get isSupported {
    return _isPlatformSupported;
  }
}
