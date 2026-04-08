import FlutterMacOS
import AppKit

public class IconSwitcherPlugin: NSObject, FlutterPlugin {

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "basic_icon_switcher", binaryMessenger: registrar.messenger)
        let instance = IconSwitcherPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "changeIcon":
            handleChangeIcon(call, result: result)
        case "resetIcon":
            handleResetIcon(result: result)
        case "getCurrentIcon":
            result(nil)
        case "isSupported":
            result(true)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func handleChangeIcon(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Arguments are not a dictionary.", details: nil))
            return
        }

        guard let iconData = args["iconData"] as? FlutterStandardTypedData else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "iconData (Uint8List) is required on macOS.", details: nil))
            return
        }

        guard let image = NSImage(data: iconData.data) else {
            result(FlutterError(code: "INVALID_IMAGE", message: "Could not create an image from the provided data.", details: nil))
            return
        }

        NSApplication.shared.applicationIconImage = image
        result(true)
    }

    private func handleResetIcon(result: @escaping FlutterResult) {
        NSApplication.shared.applicationIconImage = nil
        result(true)
    }
}
