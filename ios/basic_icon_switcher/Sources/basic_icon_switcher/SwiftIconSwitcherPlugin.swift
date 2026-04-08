import Flutter
import UIKit

public class SwiftIconSwitcherPlugin: NSObject, FlutterPlugin {

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "basic_icon_switcher", binaryMessenger: registrar.messenger())
        let instance = SwiftIconSwitcherPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "changeIcon":
            handleChangeIcon(call, result: result)
        case "resetIcon":
            handleResetIcon(result: result)
        case "getCurrentIcon":
            handleGetCurrentIcon(result: result)
        case "isSupported":
            result(UIApplication.shared.supportsAlternateIcons)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func handleChangeIcon(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Arguments are not a dictionary.", details: nil))
            return
        }

        guard let iconName = args["iconName"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "iconName is required.", details: nil))
            return
        }

        guard UIApplication.shared.supportsAlternateIcons else {
            result(FlutterError(code: "UNSUPPORTED", message: "Alternate icons are not supported on this device.", details: nil))
            return
        }

        UIApplication.shared.setAlternateIconName(iconName) { error in
            if let error = error {
                result(FlutterError(code: "CHANGE_ICON_FAILED", message: error.localizedDescription, details: nil))
            } else {
                result(true)
            }
        }
    }

    private func handleResetIcon(result: @escaping FlutterResult) {
        guard UIApplication.shared.supportsAlternateIcons else {
            result(FlutterError(code: "UNSUPPORTED", message: "Alternate icons are not supported on this device.", details: nil))
            return
        }

        UIApplication.shared.setAlternateIconName(nil) { error in
            if let error = error {
                result(FlutterError(code: "RESET_ICON_FAILED", message: error.localizedDescription, details: nil))
            } else {
                result(true)
            }
        }
    }

    private func handleGetCurrentIcon(result: @escaping FlutterResult) {
        result(UIApplication.shared.alternateIconName)
    }
}
