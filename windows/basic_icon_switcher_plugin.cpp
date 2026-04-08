#include "basic_icon_switcher_plugin.h"

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <windows.h>
#include <gdiplus.h>

#include <memory>
#include <vector>

#pragma comment(lib, "gdiplus.lib")

namespace basic_icon_switcher {

namespace {

HICON CreateIconFromPngData(const std::vector<uint8_t>& data) {
  Gdiplus::GdiplusStartupInput gdiplusStartupInput;
  ULONG_PTR gdiplusToken;
  Gdiplus::GdiplusStartup(&gdiplusToken, &gdiplusStartupInput, nullptr);

  IStream* stream = nullptr;
  HGLOBAL hMem = GlobalAlloc(GMEM_MOVEABLE, data.size());
  if (!hMem) return nullptr;

  void* pMem = GlobalLock(hMem);
  if (!pMem) {
    GlobalFree(hMem);
    return nullptr;
  }
  memcpy(pMem, data.data(), data.size());
  GlobalUnlock(hMem);

  if (CreateStreamOnHGlobal(hMem, TRUE, &stream) != S_OK) {
    GlobalFree(hMem);
    return nullptr;
  }

  Gdiplus::Bitmap* bitmap = Gdiplus::Bitmap::FromStream(stream);
  HICON hIcon = nullptr;
  if (bitmap && bitmap->GetLastStatus() == Gdiplus::Ok) {
    bitmap->GetHICON(&hIcon);
  }

  delete bitmap;
  stream->Release();
  Gdiplus::GdiplusShutdown(gdiplusToken);

  return hIcon;
}

}  // namespace

void IconSwitcherPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "basic_icon_switcher",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<IconSwitcherPlugin>(registrar);

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

IconSwitcherPlugin::IconSwitcherPlugin(
    flutter::PluginRegistrarWindows *registrar)
    : registrar_(registrar) {}

IconSwitcherPlugin::~IconSwitcherPlugin() {}

void IconSwitcherPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {

  if (method_call.method_name() == "changeIcon") {
    const auto* args = std::get_if<flutter::EncodableMap>(method_call.arguments());
    if (!args) {
      result->Error("INVALID_ARGUMENTS", "Arguments must be a map.");
      return;
    }

    auto it = args->find(flutter::EncodableValue("iconData"));
    if (it == args->end()) {
      result->Error("INVALID_ARGUMENTS", "iconData is required on Windows.");
      return;
    }

    const auto* icon_data = std::get_if<std::vector<uint8_t>>(&(it->second));
    if (!icon_data) {
      result->Error("INVALID_ARGUMENTS", "iconData must be a Uint8List.");
      return;
    }

    HICON hIcon = CreateIconFromPngData(*icon_data);
    if (!hIcon) {
      result->Error("INVALID_IMAGE", "Could not create icon from the provided data.");
      return;
    }

    HWND hwnd = registrar_->GetView()->GetNativeWindow();
    if (hwnd) {
      SendMessage(hwnd, WM_SETICON, ICON_BIG, reinterpret_cast<LPARAM>(hIcon));
      SendMessage(hwnd, WM_SETICON, ICON_SMALL, reinterpret_cast<LPARAM>(hIcon));
      result->Success(flutter::EncodableValue(true));
    } else {
      DestroyIcon(hIcon);
      result->Error("NO_WINDOW", "Could not find the application window.");
    }
  } else if (method_call.method_name() == "resetIcon") {
    HWND hwnd = registrar_->GetView()->GetNativeWindow();
    if (hwnd) {
      // Reset to the class default icon
      HICON hDefaultIcon = reinterpret_cast<HICON>(
          GetClassLongPtr(hwnd, GCLP_HICON));
      SendMessage(hwnd, WM_SETICON, ICON_BIG, reinterpret_cast<LPARAM>(hDefaultIcon));
      SendMessage(hwnd, WM_SETICON, ICON_SMALL, reinterpret_cast<LPARAM>(hDefaultIcon));
      result->Success(flutter::EncodableValue(true));
    } else {
      result->Error("NO_WINDOW", "Could not find the application window.");
    }
  } else if (method_call.method_name() == "getCurrentIcon") {
    result->Success(flutter::EncodableValue());  // null
  } else if (method_call.method_name() == "isSupported") {
    result->Success(flutter::EncodableValue(true));
  } else {
    result->NotImplemented();
  }
}

}  // namespace basic_icon_switcher
