import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:basic_icon_switcher/basic_icon_switcher.dart';
import 'package:basic_icon_switcher/src/basic_icon_switcher_method_channel.dart';
import 'package:basic_icon_switcher/src/basic_icon_switcher_platform_interface.dart';

void main() {
  const testChannel = MethodChannel('basic_icon_switcher');

  TestWidgetsFlutterBinding.ensureInitialized();

  late List<MethodCall> log;

  setUp(() {
    log = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(testChannel, (call) async {
      log.add(call);
      switch (call.method) {
        case 'changeIcon':
          return true;
        case 'resetIcon':
          return true;
        case 'getCurrentIcon':
          return 'first';
        case 'isSupported':
          return true;
        default:
          return null;
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(testChannel, null);
    // Reset to default platform instance
    IconSwitcherPlatform.instance = MethodChannelIconSwitcher();
  });

  group('MethodChannelIconSwitcher', () {
    test('changeIcon sends correct arguments', () async {
      final channel = MethodChannelIconSwitcher();
      final result = await channel.changeIcon(
        iconName: 'first',
        androidActivityAlias: 'com.example.First',
      );
      expect(result, true);
      expect(log.length, 1);
      expect(log[0].method, 'changeIcon');
      expect(log[0].arguments, {
        'iconName': 'first',
        'iconActivityAlias': 'com.example.First',
      });
    });

    test('changeIcon without alias omits key', () async {
      final channel = MethodChannelIconSwitcher();
      await channel.changeIcon(iconName: 'first');
      expect(log[0].arguments, {'iconName': 'first'});
    });

    test('resetIcon calls method channel', () async {
      final channel = MethodChannelIconSwitcher();
      final result = await channel.resetIcon();
      expect(result, true);
      expect(log[0].method, 'resetIcon');
    });

    test('getCurrentIcon returns icon name', () async {
      final channel = MethodChannelIconSwitcher();
      final result = await channel.getCurrentIcon();
      expect(result, 'first');
      expect(log[0].method, 'getCurrentIcon');
    });

    test('isSupported returns true', () async {
      final channel = MethodChannelIconSwitcher();
      final result = await channel.isSupported();
      expect(result, true);
      expect(log[0].method, 'isSupported');
    });

    test('changeDesktopIcon sends iconData', () async {
      final channel = MethodChannelIconSwitcher();
      final iconBytes = [0x89, 0x50, 0x4E, 0x47]; // PNG header
      final result = await channel.changeDesktopIcon(iconBytes);
      expect(result, true);
      expect(log[0].method, 'changeIcon');
      final args = log[0].arguments as Map;
      expect(args['iconData'], isA<Uint8List>());
    });
  });

  group('IconSwitcherPlatform', () {
    test('default instance is MethodChannelIconSwitcher', () {
      expect(IconSwitcherPlatform.instance, isA<MethodChannelIconSwitcher>());
    });

    test('can be set to extending class', () {
      final mock = _MockIconSwitcherPlatform();
      IconSwitcherPlatform.instance = mock;
      expect(IconSwitcherPlatform.instance, mock);
    });
  });
}

class _MockIconSwitcherPlatform extends IconSwitcherPlatform {
  // Using the proper constructor gives the right token
}
