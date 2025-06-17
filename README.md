# Mobile Icon Switcher

[![pub package](https://img.shields.io/pub/v/mobile_icon_switcher.svg)](https://pub.dev/packages/mobile_icon_switcher)
[![GitHub](https://img.shields.io/github/license/timthetimber/mobile_icon_switcher)](https://github.com/timthetimber/mobile_icon_switcher/blob/main/LICENSE)
[![GitHub Repo stars](https://img.shields.io/github/stars/timthetimber/mobile_icon_switcher?style=social)](https://github.com/timthetimber/mobile_icon_switcher/stargazers)

Mobile Icon Switcher is a plugin that makes changing your app's icon within the app easy. See a short demo below:

## Demo

<img src="https://github.com/timthetimber/mobile_icon_switcher/raw/main/.github/images/demo.gif"  width="400"/>

## How to use

### iOS

<details>
  <summary>Click to expand</summary>

#### Prerequisites

- **Important:** This package doesn't handle the initial App Icon. You must provide/set this yourself.
- iOS 10.3 and above.
- Images in @1x, @2x, and @3x sizes like standard iOS images. A tool for this can be found [here](https://www.appicon.co/#image-sets) (It can also be used for Android).

#### Preparation

1. Open `Runner.xcworkspace` from your project in XCode.
2. Create a folder named `App Icons` in the Runner folder.
3. In this folder, place your app icons as follows:
   - Name@1x.png
   - Name@2x.png
   - Name@3x.png

Then, modify the `info.plist` as shown:

```plist
...
<plist version="1.0">
<dict>
<key>CFBundleIcons</key>
    <dict>
        <key>CFBundleAlternateIcons</key>
        <dict>
            <key>NAME</key>
            <dict>
                <key>UIPrerenderedIcon</key>
                <string>NO</string>
                <key>CFBundleIconFiles</key>
                <array>
                    <string>NAME</string>
                </array>
            </dict>
            <key>NAME2</key>
            <dict>
                <key>UIPrerenderedIcon</key>
                <string>NO</string>
                <key>CFBundleIconFiles</key>
                <array>
                    <string>NAME2</string>
                </array>
            </dict>
        </dict>
    </dict>
...
```

Replace NAME and NAME2 with the names of your app icon files.

After that, you're ready to go!

</details>

### Android

<details>
  <summary>Click to expand</summary>

### Prerequisites

- IMPORTANT: Android is not providing a solution for changing the App Icon by default as IOS does, so this way may not be the cleanest and best, but it works.
- You need to know your `applicationId` by default it is: `com.example.example`
- Images in mipmap format just like the default android icon. Find a tool for this: [here](https://www.appicon.co/#image-sets) (Can also be used for the IOS ones)

### Preperation

- Put your images in the destination folders: `your_project/android/app/src/main/res/mipmap-anydpi-v26`, `your_project/android/app/src/main/res/mipmap-hdpi`, `your_project/android/app/src/main/res/mipmap-mdpi`, `your_project/android/app/src/main/res/mipmap-xhdpi`, `your_project/android/app/src/main/res/mipmap-xxhdpi` and `your_project/android/app/src/main/res/mipmap-xxxhdpi`

Go to `your_project/android/app/src/main/AndroidManifest.xml` and here you
need to add for each icon an entry like this:

```xml
...
        </activity>
        <!--START HERE: -->
        <activity-alias
            android:name=".NameOfYourActivity"
            android:targetActivity=".MainActivity"
            android:icon="@mipmap/NameOfTheMipMapImage"
            android:enabled="false">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity-alias>
        ...
```

The `NameOfTheMipMapImage` must just be the name of the image you put in the mipmap folders (Please feel free to checkout my example).

The `NameOfYourActivity` is really important! Because now we need to create a Activity Class in our Android Project, for this I just edited the `MainActivity.kt` file located under: `your_project/android/app/src/main/kotlin/com/example/example/MainActivity.kt` In this file you need to create new activity classes with the name you specified in `NameOfYourActivity`.

#### Example:

My `AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application
        android:label="example"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <!-- Specifies an Android theme to apply to this Activity as soon as
                 the Android process has started. This theme is visible to the user
                 while the Flutter UI initializes. After that, this theme continues
                 to determine the Window background behind the Flutter UI. -->
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"
              />
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        <!--IMPORTANT START HERE: -->
        <activity-alias
            android:name=".First"
            android:targetActivity=".MainActivity"
            android:icon="@mipmap/first"
            android:enabled="false">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity-alias>
        <!-- Don't delete the meta-data below.
             This is used by the Flutter tool to generate GeneratedPluginRegistrant.java -->
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

As you can see I need to create a class called `First` just like this:

```kotlin
package com.example.example

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
}

//NEW:
class First: FlutterActivity() {
}
```

## Flutter/Dart part

Sadly we also have one different thing to setup here for Android:

```Dart
MobileIconSwitcher.setDefaultComponent("com.example.example.MainActivity");
```

This we need to call when our App starts, please also feel free to look into my example App how I did this. Important here, the applicationId and the MainActivity name must be correct, please double check this in case of errors.

</details>

## Using the mobile_icon_switcher in a Flutter App

### Switching the Apps Icon

To now switch the icon after you are done with the IOS and/or Android Setup above you can just call this method:

```dart
await MobileIconSwitcher.changeIcon('first', 'com.example.example.First');
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

## Modern API Usage (Recommended)

The package now provides a modern, type-safe API with better error handling:

### Basic Usage

```dart
import 'package:mobile_icon_switcher/mobile_icon_switcher.dart';

// Check if icon switching is supported
if (MobileIconSwitcher.isSupported) {
  try {
    // Set icon by name
    await MobileIconSwitcher.setIcon(iconName: 'premium');
    
    // Or use IconConfiguration for type safety
    const premiumIcon = AppIcon.custom(
      identifier: 'premium',
      displayName: 'Premium Theme',
      activityAlias: 'PremiumActivity', // Android only
    );
    await MobileIconSwitcher.setIcon(iconConfig: premiumIcon);
    
    // Get current icon
    final currentIcon = await MobileIconSwitcher.getCurrentIcon();
    print('Current icon: $currentIcon');
    
    // Get all available icons
    final availableIcons = await MobileIconSwitcher.getAvailableIcons();
    print('Available icons: $availableIcons');
    
    // Reset to default icon
    await MobileIconSwitcher.resetToDefaultIcon();
    
  } on IconNotSupportedException catch (e) {
    print('Icon not supported: ${e.message}');
  } on PlatformNotSupportedException catch (e) {
    print('Platform not supported: ${e.message}');
  } on IconSwitchFailedException catch (e) {
    print('Icon switch failed: ${e.message}');
  }
}
```

### Error Handling

The modern API provides specific exception types:

- `IconNotSupportedException`: When the requested icon is not available
- `PlatformNotSupportedException`: When the platform doesn't support icon switching
- `IconSwitchFailedException`: When the icon switching operation fails

### Debug Mode

Enable debug logging for troubleshooting:

```dart
// Enable debug logging
MobileIconSwitcher.enableDebugMode();

// Your icon switching code here

// Disable debug logging
MobileIconSwitcher.disableDebugMode();
```

### Legacy API (Deprecated)

The old API methods are still available but deprecated:

```dart
// Deprecated - use setIcon instead
bool success = await MobileIconSwitcher.changeIcon('iconName', 'activityAlias');

// Deprecated - use resetToDefaultIcon instead  
bool success = await MobileIconSwitcher.resetIcon();
```
