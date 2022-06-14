import UIKit
import Flutter
import MatrixSDK
import tnexchat
import RxSwift

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
    var disposeBag: DisposeBag? = DisposeBag()
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
//
    GeneratedPluginRegistrant.register(with: self)
      guard let controller = window?.rootViewController as? FlutterViewController else {
            fatalError("rootViewController is not type FlutterViewController")
          }
      configNaviFlutter(flutterViewController: controller)
      _ = ListChatFlutterHandler(appDelegate: self)

          let chargingChannel = FlutterEventChannel(name: "event_room",
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

//        let chargingChannel = FlutterEventChannel(name: "tnex_chat/refreshToken",
//                                                  binaryMessenger: flutterViewController.binaryMessenger)
//        chargingChannel.setStreamHandler(ChatStreamHandler())
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
        case MethodCode.rooms.methodId:
            print(MethodCode.rooms.methodId)
//                result(appDelegate.getListRoom())
            self.getListRooms()
        case MethodCode.members.methodId:
            guard let roomId = call.arguments as? String,
                  let room = MatrixManager.shared.getRoom(roomId: roomId) else { break }
            room.getState { state in
                if let userId = state?.members.members.first(where: {$0.userId != MatrixManager.shared.userId})?.userId {
                    self.channel.invokeMethod("listMember", arguments: ["roomId": room.roomId, "avatarUrl": userId.getAvatarUrl()])
                }
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }

      public func onListen(withArguments arguments: Any?,
                           eventSink: @escaping FlutterEventSink) -> FlutterError? {
          print("onListen")
        self.eventSink = eventSink
          MatrixManager.shared.rxEvent.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] (_sessionEvent) in
              if let self = self, let sessionEvent = _sessionEvent {
                  self.eventSink?(["event": sessionEvent.event.eventId])
              }
          }).disposed(by: disposeBag!)
//          MatrixManager.shared.handleEvent = {[weak self] event, direction, roomState in
//              self?.eventSink?(["event": event.eventId])
//
//          }
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
      }

      public func onCancel(withArguments arguments: Any?) -> FlutterError? {
          print("onCancel")
//        NotificationCenter.default.removeObserver(self)
        eventSink = nil
        return nil
      }
    
    
    func getListRooms() {
        MatrixManager.shared.getDicRooms {[weak self] rooms in
            self?.channel.invokeMethod("rooms", arguments: rooms)
        }
    }
}
