# Project Guidelines

## Overview

Flutter plugin (`icon_switcher`) enabling runtime app icon switching on iOS, Android, Web, macOS, Windows, and Linux. Published on [pub.dev](https://pub.dev/packages/icon_switcher). Successor to `mobile_icon_switcher`.

## Architecture

Uses method channel (name: `icon_switcher`) for native platforms, and `package:web` for web.

| Layer           | File                                                                         | Language |
| --------------- | ---------------------------------------------------------------------------- | -------- |
| Dart API        | `lib/icon_switcher.dart`                                                     | Dart     |
| Platform iface  | `lib/src/icon_switcher_platform_interface.dart`                              | Dart     |
| Method channel  | `lib/src/icon_switcher_method_channel.dart`                                  | Dart     |
| Web impl        | `lib/src/icon_switcher_web.dart`                                             | Dart     |
| Web entry point | `lib/icon_switcher_web.dart`                                                 | Dart     |
| Android         | `android/src/main/java/de/timthetimber/iconswitcher/IconSwitcherPlugin.java` | Java     |
| iOS             | `ios/Classes/SwiftIconSwitcherPlugin.swift`                                  | Swift    |
| macOS           | `macos/Classes/IconSwitcherPlugin.swift`                                     | Swift    |
| Windows         | `windows/icon_switcher_plugin.cpp`                                           | C++      |
| Linux           | `linux/icon_switcher_plugin.cc`                                              | C++      |
| Example         | `example/lib/main.dart`                                                      | Dart     |

**Key class**: `IconSwitcher` — all-static API with methods `changeIcon()`, `resetIcon()`, `getCurrentIcon()`, and `isSupported`.

**Platform differences**:

- **iOS**: Uses `UIApplication.setAlternateIconName` — permanent launcher icon change.
- **Android**: Uses activity-alias enable/disable via `PackageManager` — auto-detects default component.
- **Web**: Manipulates `<link rel="icon">` in the DOM via `package:web` — session-only.
- **macOS**: Sets `NSApplication.shared.applicationIconImage` — temporary, resets on restart.
- **Windows**: Uses `SendMessage(WM_SETICON)` with GDI+ icon creation — temporary.
- **Linux**: Uses `gtk_window_set_icon()` with GdkPixbuf — temporary.

## Build and Test

```bash
# Analyze
flutter analyze

# Run unit tests
flutter test

# Run example app
cd example && flutter run
```

## Conventions

- **Dart SDK**: `>=3.4.0 <4.0.0`, Flutter `>=3.22.0`
- **Linting**: `flutter_lints` (see `analysis_options.yaml`)
- **Method channel name**: `icon_switcher`
- **Method channel calls**: Arguments passed as `Map<String, dynamic>`, return `bool` for success/failure
- **Platform detection**: Always use `kIsWeb` first, then `defaultTargetPlatform`. Never use `Platform.isX` without `kIsWeb` guard.
- **Desktop icons**: Sent as `Uint8List` icon data over method channel (loaded from Flutter assets via `rootBundle.load`)
- **Tests**: Mock `MethodChannel('icon_switcher')` via `TestDefaultBinaryMessengerBinding` — see `test/icon_switcher_test.dart`
- **Android native**: Java (not Kotlin)
- **iOS/macOS native**: Swift
- **Windows native**: C++ with GDI+
- **Linux native**: C with GTK
- **Web**: `package:web` (not `dart:html`)

## Pitfalls

- On Android, activity-alias approach may briefly kill the app on some devices
- iOS shows a system alert when the icon changes — this cannot be suppressed
- Web favicon changes are session-only and reset on page reload
- macOS/Windows/Linux icon changes are temporary — must be re-applied on app startup
- `dart:io` imports crash on web — always guard with `kIsWeb`
