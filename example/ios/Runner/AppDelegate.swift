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
    private var mainCoordinator: AppCoordinator?
    var flutterVC: FlutterViewController!
    var channel: FlutterMethodChannel!
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
//
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
      configNaviFlutter(flutterViewController: controller)
      _ = ListChatFlutterHandler(appDelegate: self, flutterController: controller)

          let chargingChannel = FlutterEventChannel(name: ChannelName.charging,
                                                    binaryMessenger: controller.binaryMessenger)
          chargingChannel.setStreamHandler(self)
//      registerFlutterView()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    
    
    private func registerFlutterView() {
        weak var registrar = self.registrar(forPlugin: "plugin-name")

                let factory = FLNativeViewFactory(messenger: registrar!.messenger())
                self.registrar(forPlugin: "<plugin-name>")!.register(
                    factory,
                    withId: "<platform-view-type>")
    }
    
    private func configNaviFlutter(flutterViewController: FlutterViewController) {
        self.flutterVC = flutterViewController
        NetworkManager.shared.updateFont(flutterViewController: flutterViewController)
        self.createMethodChannel()
        let navigationController = UINavigationController(rootViewController: flutterViewController)
        navigationController.isNavigationBarHidden = true
        window?.rootViewController = navigationController
        mainCoordinator = AppCoordinator(navigationController: navigationController)
        window?.makeKeyAndVisible()

        let chargingChannel = FlutterEventChannel(name: "tnex_chat/refreshToken",
                                                  binaryMessenger: flutterViewController.binaryMessenger)
        chargingChannel.setStreamHandler(self)
    }
    
    private func createMethodChannel() {
        let channel = FlutterMethodChannel(name: "tnex_chat",
                                              binaryMessenger: flutterVC.binaryMessenger)
       
        channel.setMethodCallHandler {[weak self] (call: FlutterMethodCall, result: FlutterResult) in
            self?.handleMethodChannel(call: call, result: result)
        }
        self.channel = channel
        
    }
    
    private func handleMethodChannel(call: FlutterMethodCall, result: FlutterResult) {
        print(call.method)
        switch call.method {
        case "gotoChatDetail":
            self.mainCoordinator?.start(call: call)
        case "loginMatrix":
            self.mainCoordinator?.loginMatrix(call: call)
        case "roomInfo":
            if let userId = call.arguments as? String {
                print(userId)
                if let room = MatrixManager.shared.mxSession?.directJoinedRoom(withUserId: userId) {
                    result(room.roomId)
                } else {
                    result("none")
                }
                
            } else {
                result("none")
            }
        case "createRoom":
            self.mainCoordinator?.createRoom(call: call)
        default:
            result(FlutterMethodNotImplemented)
        }
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
            room.getState {[weak self] roomState in
                if let partnerId = roomState?.members?.members.first(where: {$0.userId != MatrixManager.shared.userId})?.userId {
                    self?.channel.invokeMethod("listMember", arguments: ["roomId": room.roomId, "avatarUrl": partnerId.getAvatarUrl()])
                }
            }
            let avatarUrl: String? = room.getRoom().directUserId
            return ["displayname": room.summary.displayname ?? "Unknown",
                    "avatar": room.roomAvatarURL?.absoluteString ?? "",
                    "lastMessage": room.lastMessage,
                    "id": room.roomId,
                    "timeCreated": room.getLastEvent()!.originServerTs,
                    "avatarUrl": avatarUrl?.getAvatarUrl() ?? ""]
        })
    }
}
