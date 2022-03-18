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
      gotoChatDetail()
    result("iOS " + UIDevice.current.systemVersion)
  }
     
    private func gotoChatDetail() {
            let currentVC = UIViewController.visibleViewController()
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let gotoAction = UIAlertAction(title: "Goto", style: .default, handler: {[weak self] _ in
                self?.gotoViewController()
            })
            let alertVC = UIAlertController.init(title: "title", message: "Oke", preferredStyle: .alert)
            alertVC.addAction(cancelAction)
            alertVC.addAction(gotoAction)
            currentVC?.present(alertVC, animated: true, completion: nil)
        }
    
    private func gotoViewController() {
        let vc = ChatDetailViewController(roomId: "")
        let navi = UINavigationController(rootViewController: vc)
        navi.modalPresentationStyle = .fullScreen
        UIViewController.visibleViewController()?.present(navi, animated: true, completion: nil)

    }


}
