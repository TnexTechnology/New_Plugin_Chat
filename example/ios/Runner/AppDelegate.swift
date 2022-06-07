import UIKit
import Flutter
import MatrixSDK
import tnexchat

enum ChannelName {
    static let battery = "samples.flutter.io/battery"
    static let charging = "samples.flutter.io/charging"
    static let chatList = "tnex_chat_list"
}

enum BatteryState {
  static let charging = "charging"
  static let discharging = "discharging"
}

enum MyFlutterErrorCode {
  static let unavailable = "UNAVAILABLE"
}



@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, FlutterStreamHandler {
    
    private var eventSink: FlutterEventSink?
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
      guard let controller = window?.rootViewController as? FlutterViewController else {
            fatalError("rootViewController is not type FlutterViewController")
          }
          let batteryChannel = FlutterMethodChannel(name: ChannelName.battery,
                                                    binaryMessenger: controller.binaryMessenger)
          batteryChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
            guard call.method == "getBatteryLevel" else {
              result(FlutterMethodNotImplemented)
              return
            }
            self?.receiveBatteryLevel(result: result)
          })
      _ = ListChatFlutterHandler(appDelegate: self, flutterController: controller)

          let chargingChannel = FlutterEventChannel(name: ChannelName.charging,
                                                    binaryMessenger: controller.binaryMessenger)
          chargingChannel.setStreamHandler(self)
      registerFlutterView()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    private func registerFlutterView() {
        weak var registrar = self.registrar(forPlugin: "plugin-name")

                let factory = FLNativeViewFactory(messenger: registrar!.messenger())
                self.registrar(forPlugin: "<plugin-name>")!.register(
                    factory,
                    withId: "<platform-view-type>")
    }
    
    private func receiveBatteryLevel(result: FlutterResult) {
//        let device = UIDevice.current
//        device.isBatteryMonitoringEnabled = true
//        guard device.batteryState != .unknown  else {
//          result(FlutterError(code: MyFlutterErrorCode.unavailable,
//                              message: "Battery info unavailable",
//                              details: nil))
//          return
//        }
//        result(Int(device.batteryLevel * 100))
        print("############")
      }

      public func onListen(withArguments arguments: Any?,
                           eventSink: @escaping FlutterEventSink) -> FlutterError? {
          print("onListen")
        self.eventSink = eventSink
//        UIDevice.current.isBatteryMonitoringEnabled = true
//        sendBatteryStateEvent()
//        NotificationCenter.default.addObserver(
//          self,
//          selector: #selector(AppDelegate.onBatteryStateDidChange),
//          name: UIDevice.batteryStateDidChangeNotification,
//          object: nil)
//
//          Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        return nil
      }
    
    @objc func update() {
        sendBatteryStateEvent()
    }

      @objc private func onBatteryStateDidChange(notification: NSNotification) {
        sendBatteryStateEvent()
      }

      private func sendBatteryStateEvent() {
        guard let eventSink = eventSink else {
          return
        }
          eventSink(BatteryState.charging)
//        switch UIDevice.current.batteryState {
//        case .full:
//          eventSink(BatteryState.charging)
//        case .charging:
//          eventSink(BatteryState.charging)
//        case .unplugged:
//          eventSink(BatteryState.discharging)
//        default:
//          eventSink(FlutterError(code: MyFlutterErrorCode.unavailable,
//                                 message: "Charging status unavailable",
//                                 details: nil))
//        }
      }

      public func onCancel(withArguments arguments: Any?) -> FlutterError? {
          print("onCancel")
//        NotificationCenter.default.removeObserver(self)
        eventSink = nil
        return nil
      }
    
    func getListRoom() -> [[String: Any]] {
        guard let rooms = MatrixManager.shared.getRooms() else { return []}
        return rooms.map({ room in
            let avatarUrl: String = room.getAvatarURLString() ?? "22222"
            return ["displayname": room.summary.displayname ?? "Unknown",
                    "avatar": room.roomAvatarURL?.absoluteString ?? "",
                    "lastMessage": room.lastMessage,
                    "id": room.roomId,
                    "timeCreated": room.getLastEvent()!.originServerTs,
                    "avatarUrl": avatarUrl]
        })
    }
}
