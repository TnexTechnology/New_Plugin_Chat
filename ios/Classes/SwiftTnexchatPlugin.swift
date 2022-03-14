import Flutter
import UIKit
import MatrixSDK
import SDWebImage

public class SwiftTnexchatPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "tnexchat", binaryMessenger: registrar.messenger())
    let instance = SwiftTnexchatPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
     
}
