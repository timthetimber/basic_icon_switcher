import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_icon_switcher/mobile_icon_switcher.dart';

void main() {
  const testChannel = MethodChannel('app_icon_switcher');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    MobileIconSwitcher.clearCache(); // Clear cache before each test
    MobileIconSwitcher.setPlatformOverride(true); // Mock platform support for tests

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(testChannel, (call) async {
      switch (call.method) {
        case 'getPlatformVersion':
          return '1.0.0';
        case 'changeIcon':
          final args = call.arguments as Map;
          final iconName = args['iconName'] as String;
          if (iconName == 'non_existent') {
            throw PlatformException(
              code: 'ICON_NOT_FOUND',
              message: 'Icon not found',
            );
          }
          return true;
        case 'getCurrentIcon':
          return 'default';
        case 'getAvailableIcons':
          return ['default', 'alternative', 'premium'];
        case 'resetIcon':
          return true;
        case 'defaultComponent':
          return true;
        default:
          return null;
      }
    });
  });

  tearDown(() {
    testChannel.setMethodCallHandler(null);
    MobileIconSwitcher.disableDebugMode();
    MobileIconSwitcher.clearPlatformOverride(); // Clean up platform override
  });

  group('Basic functionality tests', () {
    test('getPlatformVersion', () async {
      expect(await MobileIconSwitcher.platformVersion, '1.0.0');
    });

    test('changeIcon (deprecated)', () async {
      expect(await MobileIconSwitcher.changeIcon('icon1', 'alias1'), true);
    });

    test('setDefaultComponent (deprecated)', () async {
      expect(
        await MobileIconSwitcher.setDefaultComponent(
          'com.example.example.MainActivity'
        ),
        true,
      );
    });

    test('resetIcon (deprecated)', () async {
      expect(await MobileIconSwitcher.resetIcon(), true);
    });
  });

  group('Modern API tests', () {
    test('setIcon with iconName', () async {
      await expectLater(
        MobileIconSwitcher.setIcon(iconName: 'alternative'),
        completes,
      );
    });

    test('setIcon with IconConfiguration', () async {
      const icon = AppIcon.custom(
        identifier: 'premium',
        displayName: 'Premium Icon',
      );
      
      await expectLater(
        MobileIconSwitcher.setIcon(iconConfig: icon),
        completes,
      );
    });

    test('getCurrentIcon', () async {
      final currentIcon = await MobileIconSwitcher.getCurrentIcon();
      expect(currentIcon, 'default');
    });

    test('getCurrentIcon uses cache', () async {
      // First call
      final icon1 = await MobileIconSwitcher.getCurrentIcon();
      // Second call should use cache
      final icon2 = await MobileIconSwitcher.getCurrentIcon();
      expect(icon1, icon2);
    });

    test('getAvailableIcons', () async {
      final icons = await MobileIconSwitcher.getAvailableIcons();
      expect(icons, ['default', 'alternative', 'premium']);
    });

    test('resetToDefaultIcon', () async {
      await expectLater(
        MobileIconSwitcher.resetToDefaultIcon(),
        completes,
      );
    });

    test('clearCache', () {
      // Should not throw
      MobileIconSwitcher.clearCache();
    });

    test('isSupported getter', () {
      // Should be true due to platform override
      expect(MobileIconSwitcher.isSupported, true);
      
      // Test without override
      MobileIconSwitcher.clearPlatformOverride();
      // This will depend on the test environment (should be false on desktop)
      expect(MobileIconSwitcher.isSupported, isA<bool>());
      
      // Restore override for other tests
      MobileIconSwitcher.setPlatformOverride(true);
    });
  });

  group('Error handling tests', () {
    test('should handle invalid icon names gracefully', () async {
      await expectLater(
        MobileIconSwitcher.setIcon(iconName: 'non_existent'),
        throwsA(isA<IconNotSupportedException>()),
      );
    });

    test('should throw when neither iconName nor iconConfig provided', () async {
      await expectLater(
        MobileIconSwitcher.setIcon(),
        throwsA(isA<IconSwitchFailedException>()),
      );
    });

    test('should handle unsupported platform', () async {
      // Temporarily disable platform support
      MobileIconSwitcher.setPlatformOverride(false);
      
      await expectLater(
        MobileIconSwitcher.setIcon(iconName: 'test'),
        throwsA(isA<PlatformNotSupportedException>()),
      );
      
      await expectLater(
        MobileIconSwitcher.getAvailableIcons(),
        throwsA(isA<PlatformNotSupportedException>()),
      );
      
      await expectLater(
        MobileIconSwitcher.resetToDefaultIcon(),
        throwsA(isA<PlatformNotSupportedException>()),
      );
      
      // Restore platform support for other tests
      MobileIconSwitcher.setPlatformOverride(true);
    });

    test('deprecated changeIcon handles errors gracefully', () async {
      final result = await MobileIconSwitcher.changeIcon('non_existent', 'alias');
      expect(result, false);
    });
  });

  group('Debug mode tests', () {
    test('enable and disable debug mode', () {
      MobileIconSwitcher.enableDebugMode();
      MobileIconSwitcher.disableDebugMode();
      // Should not throw
    });
  });

  group('IconConfiguration tests', () {
    test('AppIcon equality', () {
      const icon1 = AppIcon.custom(identifier: 'test', displayName: 'Test');
      const icon2 = AppIcon.custom(identifier: 'test', displayName: 'Different Name');
      const icon3 = AppIcon.custom(identifier: 'different', displayName: 'Test');
      
      expect(icon1, equals(icon2)); // Same identifier
      expect(icon1, isNot(equals(icon3))); // Different identifier
    });

    test('AppIcon toString', () {
      const icon = AppIcon.custom(identifier: 'test', displayName: 'Test Icon');
      expect(icon.toString(), 'Test Icon');
    });

    test('AppIcon hashCode', () {
      const icon1 = AppIcon.custom(identifier: 'test', displayName: 'Test');
      const icon2 = AppIcon.custom(identifier: 'test', displayName: 'Test');
      
      expect(icon1.hashCode, equals(icon2.hashCode));
    });
  });

  group('Exception tests', () {
    test('IconSwitcherException toString', () {
      const exception = IconSwitcherException('Test message', code: 'TEST_CODE');
      expect(exception.toString(), contains('Test message'));
      expect(exception.toString(), contains('TEST_CODE'));
    });

    test('IconNotSupportedException', () {
      const exception = IconNotSupportedException('Icon not found');
      expect(exception.code, 'ICON_NOT_SUPPORTED');
      expect(exception.message, 'Icon not found');
    });

    test('PlatformNotSupportedException', () {
      const exception = PlatformNotSupportedException('Platform not supported');
      expect(exception.code, 'PLATFORM_NOT_SUPPORTED');
      expect(exception.message, 'Platform not supported');
    });

    test('IconSwitchFailedException', () {
      const exception = IconSwitchFailedException('Switch failed');
      expect(exception.code, 'ICON_SWITCH_FAILED');
      expect(exception.message, 'Switch failed');
    });
  });
}
