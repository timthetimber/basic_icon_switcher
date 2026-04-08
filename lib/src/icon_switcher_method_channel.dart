import 'package:flutter/services.dart';

import 'icon_switcher_platform_interface.dart';

class MethodChannelIconSwitcher extends IconSwitcherPlatform {
  final MethodChannel _channel = const MethodChannel('icon_switcher');

  @override
  Future<bool> changeIcon({
    required String iconName,
    String? androidActivityAlias,
  }) async {
    final bool success =
        await _channel.invokeMethod('changeIcon', <String, dynamic>{
      'iconName': iconName,
      if (androidActivityAlias != null)
        'iconActivityAlias': androidActivityAlias,
    });
    return success;
  }

  @override
  Future<bool> resetIcon() async {
    final bool success = await _channel.invokeMethod('resetIcon');
    return success;
  }

  @override
  Future<String?> getCurrentIcon() async {
    final String? iconName = await _channel.invokeMethod('getCurrentIcon');
    return iconName;
  }

  @override
  Future<bool> isSupported() async {
    final bool supported = await _channel.invokeMethod('isSupported');
    return supported;
  }

  @override
  Future<bool> changeDesktopIcon(List<int> iconData) async {
    final bool success = await _channel.invokeMethod(
      'changeIcon',
      <String, dynamic>{
        'iconData': Uint8List.fromList(iconData),
      },
    );
    return success;
  }
}
