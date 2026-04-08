import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'basic_icon_switcher_method_channel.dart';

abstract class IconSwitcherPlatform extends PlatformInterface {
  IconSwitcherPlatform() : super(token: _token);

  static final Object _token = Object();

  static IconSwitcherPlatform _instance = MethodChannelIconSwitcher();

  static IconSwitcherPlatform get instance => _instance;

  static set instance(IconSwitcherPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<bool> changeIcon({
    required String iconName,
    String? androidActivityAlias,
  }) {
    throw UnimplementedError('changeIcon() has not been implemented.');
  }

  Future<bool> resetIcon() {
    throw UnimplementedError('resetIcon() has not been implemented.');
  }

  Future<String?> getCurrentIcon() {
    throw UnimplementedError('getCurrentIcon() has not been implemented.');
  }

  Future<bool> isSupported() {
    throw UnimplementedError('isSupported() has not been implemented.');
  }

  Future<bool> changeDesktopIcon(List<int> iconData) {
    throw UnimplementedError('changeDesktopIcon() has not been implemented.');
  }
}
