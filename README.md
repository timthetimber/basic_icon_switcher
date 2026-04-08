# Icon Switcher

[![pub package](https://img.shields.io/pub/v/icon_switcher.svg)](https://pub.dev/packages/icon_switcher)
[![GitHub](https://img.shields.io/github/license/timthetimber/icon_switcher)](https://github.com/timthetimber/icon_switcher/blob/main/LICENSE)

A Flutter plugin to dynamically change your app icon at runtime. Supports **iOS**, **Android**, **Web**, **macOS**, **Windows**, and **Linux**.

> **Migrating from `mobile_icon_switcher`?** See the [Migration Guide](#migration-from-mobile_icon_switcher) at the bottom.

## Platform Support

| Platform    | What changes          | Persistence                   | Setup required                     |
| ----------- | --------------------- | ----------------------------- | ---------------------------------- |
| **iOS**     | Launcher icon         | Permanent                     | Info.plist + icon files            |
| **Android** | Launcher icon         | Permanent                     | AndroidManifest + activity-aliases |
| **Web**     | Browser tab favicon   | Session only (tab lifetime)   | Favicon files in `web/`            |
| **macOS**   | Dock icon             | Temporary (resets on restart) | Bundle icon assets                 |
| **Windows** | Window + taskbar icon | Temporary (resets on restart) | Bundle icon assets                 |
| **Linux**   | Window icon           | Temporary (resets on restart) | Bundle icon assets                 |

## Installation

```yaml
dependencies:
  icon_switcher: ^1.0.0
```

## Quick Start

```dart
import 'package:icon_switcher/icon_switcher.dart';

// Switch to an alternate icon
await IconSwitcher.changeIcon(
  iconName: 'dark',
  androidActivityAlias: 'com.example.myapp.Dark', // Android only
  webFaviconUrl: 'icons/dark.png',                // Web only
  desktopIconAsset: 'assets/icons/dark.png',       // macOS/Windows/Linux
);

// Reset to default
await IconSwitcher.resetIcon();

// Check current icon (iOS/Android)
final current = await IconSwitcher.getCurrentIcon(); // null = default

// Check if supported
final supported = await IconSwitcher.isSupported;
```

## Platform Setup

### iOS

<details>
<summary>Click to expand</summary>

#### Prerequisites

- iOS 12.0+
- Icon images in @1x, @2x, and @3x sizes. Generate them at [appicon.co](https://www.appicon.co/#image-sets).

#### Steps

1. Open `Runner.xcworkspace` in Xcode.
2. Create a folder named `App Icons` in the Runner group.
3. Add your icon files:
   - `IconName.png` (1x)
   - `IconName@2x.png` (2x)
   - `IconName@3x.png` (3x)
4. Edit `Info.plist` to declare alternate icons:

```xml
<key>CFBundleIcons</key>
<dict>
    <key>CFBundleAlternateIcons</key>
    <dict>
        <key>dark</key>
        <dict>
            <key>UIPrerenderedIcon</key>
            <false/>
            <key>CFBundleIconFiles</key>
            <array>
                <string>dark</string>
            </array>
        </dict>
        <key>light</key>
        <dict>
            <key>UIPrerenderedIcon</key>
            <false/>
            <key>CFBundleIconFiles</key>
            <array>
                <string>light</string>
            </array>
        </dict>
    </dict>
</dict>
```

5. Use in Dart:

```dart
await IconSwitcher.changeIcon(iconName: 'dark');
```

</details>

### Android

<details>
<summary>Click to expand</summary>

#### Prerequisites

- Android minSdk 21+
- Icon images in mipmap format. Generate them at [appicon.co](https://www.appicon.co/#image-sets).
- Your `applicationId` (e.g., `com.example.myapp`)

#### Steps

1. Place icon images in the mipmap folders under `android/app/src/main/res/` (`mipmap-hdpi`, `mipmap-mdpi`, `mipmap-xhdpi`, `mipmap-xxhdpi`, `mipmap-xxxhdpi`).

2. Add activity-aliases to `AndroidManifest.xml` (after the `</activity>` tag):

```xml
<activity-alias
    android:name=".Dark"
    android:targetActivity=".MainActivity"
    android:icon="@mipmap/dark"
    android:enabled="false">
    <intent-filter>
        <action android:name="android.intent.action.MAIN" />
        <category android:name="android.intent.category.LAUNCHER" />
    </intent-filter>
</activity-alias>
```

3. Create a Kotlin/Java class for each alias in your `MainActivity.kt`:

```kotlin
package com.example.myapp

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity()
class Dark: FlutterActivity()
```

4. Use in Dart:

```dart
await IconSwitcher.changeIcon(
  iconName: 'dark',
  androidActivityAlias: 'com.example.myapp.Dark',
);
```

> **Note**: Unlike the previous version (`mobile_icon_switcher`), you no longer need to call `setDefaultComponent()`. The plugin auto-detects the default launcher activity.

</details>

### Web

<details>
<summary>Click to expand</summary>

#### Steps

1. Place your alternate favicon files in the `web/` directory (or a subfolder like `web/icons/`):
   - `web/icons/dark.png`
   - `web/icons/light.png`

2. Make sure your `web/index.html` has a favicon link:

```html
<link rel="icon" type="image/png" href="favicon.png" />
```

3. Use in Dart:

```dart
await IconSwitcher.changeIcon(
  iconName: 'dark',
  webFaviconUrl: 'icons/dark.png',
);
```

> **Note**: Favicon changes are session-only — they reset when the tab is closed.

</details>

### macOS

<details>
<summary>Click to expand</summary>

#### Steps

1. Add your icon PNG files as Flutter assets in `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/icons/
```

2. Place icon files in `assets/icons/` (e.g., `dark.png`, `light.png`).

3. Use in Dart:

```dart
await IconSwitcher.changeIcon(
  iconName: 'dark',
  desktopIconAsset: 'assets/icons/dark.png',
);
```

> **Note**: The dock icon change is temporary — it resets when the app restarts. To persist your choice, store the selected icon name (e.g., in `SharedPreferences`) and call `changeIcon()` again on app startup.

</details>

### Windows

<details>
<summary>Click to expand</summary>

#### Steps

Same as macOS — add PNG assets and pass `desktopIconAsset`:

```dart
await IconSwitcher.changeIcon(
  iconName: 'dark',
  desktopIconAsset: 'assets/icons/dark.png',
);
```

> **Note**: Changes the window titlebar and taskbar icon. Resets on restart.

</details>

### Linux

<details>
<summary>Click to expand</summary>

#### Steps

Same as macOS/Windows — add PNG assets and pass `desktopIconAsset`:

```dart
await IconSwitcher.changeIcon(
  iconName: 'dark',
  desktopIconAsset: 'assets/icons/dark.png',
);
```

> **Note**: Changes the window decoration icon. Resets on restart.

</details>

## API Reference

### `IconSwitcher.changeIcon()`

```dart
static Future<bool> changeIcon({
  required String iconName,
  String? androidActivityAlias,
  String? webFaviconUrl,
  String? desktopIconAsset,
})
```

| Parameter              | Required on           | Description                               |
| ---------------------- | --------------------- | ----------------------------------------- |
| `iconName`             | iOS, Android          | Icon name matching platform config        |
| `androidActivityAlias` | Android               | Fully qualified activity-alias class name |
| `webFaviconUrl`        | Web                   | URL/path to favicon file                  |
| `desktopIconAsset`     | macOS, Windows, Linux | Flutter asset path to PNG                 |

### `IconSwitcher.resetIcon()`

Resets to the default icon on all platforms.

### `IconSwitcher.getCurrentIcon()`

Returns the current icon name, or `null` if the default is active. Currently supported on iOS and Android only.

### `IconSwitcher.isSupported`

Returns `true` if icon switching is supported on the current platform.

## Platform Limitations

| Platform    | Limitation                                                                        |
| ----------- | --------------------------------------------------------------------------------- |
| **iOS**     | Shows a system alert when the icon changes (iOS limitation, cannot be suppressed) |
| **Android** | May briefly kill the app on some devices when switching icons                     |
| **Web**     | Favicon change is session-only; resets on page reload or tab close                |
| **macOS**   | Dock icon resets when the app restarts                                            |
| **Windows** | Window icon resets when the app restarts                                          |
| **Linux**   | Window icon resets when the app restarts; behavior varies by window manager       |

## Migration from `mobile_icon_switcher`

### Breaking Changes

1. **Package name**: `mobile_icon_switcher` → `icon_switcher`
2. **Class name**: `MobileIconSwitcher` → `IconSwitcher`
3. **`setDefaultComponent()` removed**: No longer needed — the Android plugin auto-detects the default component.
4. **`changeIcon()` signature changed**: Now uses named parameters.
5. **`platformVersion` removed**: Use Flutter's built-in platform detection instead.

### Before (mobile_icon_switcher)

```dart
import 'package:mobile_icon_switcher/mobile_icon_switcher.dart';

// Required on Android
MobileIconSwitcher.setDefaultComponent("com.example.app.MainActivity");

// Change icon
await MobileIconSwitcher.changeIcon('dark', 'com.example.app.Dark');

// Reset
await MobileIconSwitcher.resetIcon();
```

### After (icon_switcher)

```dart
import 'package:icon_switcher/icon_switcher.dart';

// Change icon (no setDefaultComponent needed!)
await IconSwitcher.changeIcon(
  iconName: 'dark',
  androidActivityAlias: 'com.example.app.Dark',
);

// Reset
await IconSwitcher.resetIcon();
```

The first argument here is the IconName, this part is necessary for IOS mostly, the second argument is the Activity with the ApplicationId of Android.

---

### Reseting the Apps Icon to default

To revert the app icon to its default after you have completed the iOS and/or Android Setup mentioned above, you can simply call this method:

```dart
await MobileIconSwitcher.resetIcon();
```

This method doesn’t require any arguments. Calling this will reset the app icon to the default one set in your project, whether you’re on iOS or Android. Remember to handle any possible errors that might occur while resetting, ensuring a smooth user experience.

Note: For IOS there is a real option to reset the App's icon for Android, there isn't therefore I will just set the Default Component as the "new" App Icon.

## Note

Please be aware that the Android solution is as stated before not the best solution but however it works, for me it takes a bit until Android updates the App on the Homescreen so pressing on an Icon and getting the message Unknown App or something like this can happen! It takes a few moments and than the App is again back with the new Icon and can be started without any issues.
