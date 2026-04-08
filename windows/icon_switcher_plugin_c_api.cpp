#include "include/icon_switcher/icon_switcher_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "icon_switcher_plugin.h"

void IconSwitcherPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  icon_switcher::IconSwitcherPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
