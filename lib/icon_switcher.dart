import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'src/icon_switcher_platform_interface.dart';
import 'src/icon_switcher_web_stub.dart'
    if (dart.library.js_interop) 'src/icon_switcher_web.dart' as web_impl;

export 'src/icon_switcher_platform_interface.dart';

class IconSwitcher {
  /// Changes the app icon on the current platform.
  ///
  /// - **iOS**: [iconName] must match a key in `CFBundleAlternateIcons` in your `Info.plist`.
  /// - **Android**: [iconName] is passed as the icon name. [androidActivityAlias] must be
  ///   the fully qualified activity-alias class name (e.g., `com.example.app.IconGreen`).
  /// - **Web**: [webFaviconUrl] is the URL/path to the new favicon (e.g., `icons/dark.png`).
  /// - **macOS/Windows/Linux**: [desktopIconAsset] is a Flutter asset path to a PNG image
  ///   (e.g., `assets/icons/dark.png`). The asset bytes are loaded and sent to native code.
  ///
  /// Returns `true` on success.
  static Future<bool> changeIcon({
    required String iconName,
    String? androidActivityAlias,
    String? webFaviconUrl,
    String? desktopIconAsset,
  }) async {
    if (kIsWeb) {
      if (webFaviconUrl == null) {
        throw ArgumentError('webFaviconUrl is required on the web platform.');
      }
      return web_impl.changeFaviconImpl(webFaviconUrl);
    }

    final platform = defaultTargetPlatform;

    if (platform == TargetPlatform.macOS ||
        platform == TargetPlatform.windows ||
        platform == TargetPlatform.linux) {
      if (desktopIconAsset == null) {
        throw ArgumentError(
          'desktopIconAsset is required on desktop platforms.',
        );
      }
      final byteData = await rootBundle.load(desktopIconAsset);
      final bytes = byteData.buffer.asUint8List();
      return IconSwitcherPlatform.instance.changeDesktopIcon(bytes.toList());
    }

    // iOS and Android
    return IconSwitcherPlatform.instance.changeIcon(
      iconName: iconName,
      androidActivityAlias: androidActivityAlias,
    );
  }

  /// Resets the app icon to its default on the current platform.
  ///
  /// - **iOS**: Reverts to the primary icon defined in `CFBundlePrimaryIcon`.
  /// - **Android**: Re-enables the default `MainActivity` and disables all aliases.
  /// - **Web**: Restores `favicon.ico` as the default favicon.
  /// - **macOS**: Restores the original dock icon (sets `applicationIconImage` to `nil`).
  /// - **Windows/Linux**: Restores the window icon to the default.
  ///
  /// Returns `true` on success.
  static Future<bool> resetIcon() async {
    if (kIsWeb) {
      return web_impl.resetFaviconImpl();
    }
    return IconSwitcherPlatform.instance.resetIcon();
  }

  /// Returns the name of the currently active icon, or `null` if the default is active.
  ///
  /// Currently supported on **iOS** and **Android** only. Returns `null` on other platforms.
  static Future<String?> getCurrentIcon() async {
    if (kIsWeb) return null;
    return IconSwitcherPlatform.instance.getCurrentIcon();
  }

  /// Returns `true` if icon switching is supported on the current platform.
  ///
  /// - **iOS**: Based on `UIApplication.supportsAlternateIcons`.
  /// - **Android**: Always `true`.
  /// - **Web**: Always `true`.
  /// - **macOS/Windows/Linux**: Always `true`.
  static Future<bool> get isSupported async {
    if (kIsWeb) return true;
    return IconSwitcherPlatform.instance.isSupported();
  }
}
