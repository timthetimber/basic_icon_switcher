#include "include/basic_icon_switcher/basic_icon_switcher_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "basic_icon_switcher_plugin.h"

void IconSwitcherPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  basic_icon_switcher::IconSwitcherPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
