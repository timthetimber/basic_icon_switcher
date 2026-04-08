import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'src/basic_icon_switcher_platform_interface.dart';
import 'src/basic_icon_switcher_web.dart' as web_impl;

class IconSwitcherWeb {
  static void registerWith(Registrar registrar) {
    IconSwitcherPlatform.instance = web_impl.createWebPlatform();
  }
}
