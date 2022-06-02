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
//      gotoChatDetail()
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
        let credentials: MXCredentials = MXCredentials(homeServer: "https://chat-matrix.tnex.com.vn", userId: "@7181fb55-bba8-483f-adde-c5c1f4452852:chat-matrix.tnex.com.vn", accessToken: "MDAyNWxvY2F0aW9uIGNoYXQtbWF0cml4LnRuZXguY29tLnZuCjAwMTNpZGVudGlmaWVyIGtleQowMDEwY2lkIGdlbiA9IDEKMDA1MGNpZCB1c2VyX2lkID0gQDcxODFmYjU1LWJiYTgtNDgzZi1hZGRlLWM1YzFmNDQ1Mjg1MjpjaGF0LW1hdHJpeC50bmV4LmNvbS52bgowMDE2Y2lkIHR5cGUgPSBhY2Nlc3MKMDAyMWNpZCBub25jZSA9IHE7U2ZMRGcxd3M9Mm00dCYKMDAyZnNpZ25hdHVyZSArvUahqvnk2QhJl9Vs3gds4Vze18mbinHERTIWLzs7RAo")
        credentials.identityServer = "https://vector.im"
        MatrixManager.shared.sync(credentials: credentials) {
            let vc = ConversationViewController(rooms: MatrixManager.shared.getRooms()!)
            let navi = UINavigationController(rootViewController: vc)
            navi.modalPresentationStyle = .fullScreen
            UIViewController.visibleViewController()?.present(navi, animated: true)
        }
    }

//    private func gotoViewController() {
//        MatrixManager.shared.loginToken { succeed in
//            let vc = ConversationViewController(rooms: MatrixManager.shared.getRooms()!)
//            let navi = UINavigationController(rootViewController: vc)
//            navi.modalPresentationStyle = .fullScreen
//            UIViewController.visibleViewController()?.present(navi, animated: true)
//        }
//    }

}
