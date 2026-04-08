#ifndef FLUTTER_PLUGIN_BASIC_ICON_SWITCHER_PLUGIN_H_
#define FLUTTER_PLUGIN_BASIC_ICON_SWITCHER_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace basic_icon_switcher {

class IconSwitcherPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  IconSwitcherPlugin(flutter::PluginRegistrarWindows *registrar);
  virtual ~IconSwitcherPlugin();

  IconSwitcherPlugin(const IconSwitcherPlugin&) = delete;
  IconSwitcherPlugin& operator=(const IconSwitcherPlugin&) = delete;

 private:
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  flutter::PluginRegistrarWindows *registrar_;
};

}  // namespace basic_icon_switcher

#endif  // FLUTTER_PLUGIN_BASIC_ICON_SWITCHER_PLUGIN_H_
