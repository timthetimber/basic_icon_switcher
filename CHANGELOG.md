## 1.0.0

**This is a new package replacing `mobile_icon_switcher`.** Published as `icon_switcher`.

### New Features

- **Web support**: Dynamically change the browser tab favicon via `webFaviconUrl` parameter
- **macOS support**: Change the dock icon at runtime via `desktopIconAsset` parameter
- **Windows support**: Change the window and taskbar icon at runtime
- **Linux support**: Change the window decoration icon at runtime
- **`getCurrentIcon()`**: Get the name of the currently active alternate icon (iOS/Android)
- **`isSupported` getter**: Check if icon switching is available on the current platform
- **Auto-detect default component on Android**: No more `setDefaultComponent()` required

### Improvements

- **Fixed Android bug**: `disableComponents()` now only disables activity-aliases, not all activities
- **Fixed Android bug**: Added missing `return` after error response (execution no longer falls through)
- **Android**: Uses `GET_DISABLED_COMPONENTS` flag to properly enumerate all activity-aliases
- **Platform detection**: Uses `kIsWeb` + `defaultTargetPlatform` instead of `dart:io` (safe on web)
- **Modern SDK constraints**: Dart `>=3.4.0 <4.0.0`, Flutter `>=3.22.0`
- **Modern Android build**: compileSdk 34, minSdk 21, AGP 8.1.0, mavenCentral (jcenter removed)
- **iOS deployment target**: Bumped to 12.0
- **Web-compatible**: Uses `package:web` instead of deprecated `dart:html`
- **Platform interface pattern**: Proper `plugin_platform_interface` for testability

### Breaking Changes

- Package renamed from `mobile_icon_switcher` to `icon_switcher`
- Class renamed from `MobileIconSwitcher` to `IconSwitcher`
- `changeIcon()` now uses named parameters
- `setDefaultComponent()` removed (auto-detected)
- `platformVersion` removed
- Method channel renamed from `app_icon_switcher` to `icon_switcher`

---

## Previous releases (as `mobile_icon_switcher`)

## 1.1.1

- Little fix in Git Repo

## 1.1.0

- Added reset functionality

## 1.0.0

- First automated release

## 0.0.1

- First release
