import Foundation
import UIKit
import Flutter
import MatrixSDK
import tnexchat

class AppCoordinator: BaseCoordinator{
    weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        super.init()
        self.navigationController = navigationController
    }
    
    override func start(call: FlutterMethodCall) {
        super.start(call: call)
        navigateToNewsViewController(call: call)
    }
    
    override func createRoom(call: FlutterMethodCall) {
        super.start(call: call)
        navigateToCreateRoom(call: call)
    }
    
    func loginMatrix(call: FlutterMethodCall) {
        if let dic = call.arguments as? [String: Any] {
            if let userId = dic["userId"] as? String, let accessToken = dic["accessToken"] as? String, let homeUrl = dic["homeUrl"] as? String {
                print(userId)
                print(accessToken)
                print(homeUrl)
                let credentials: MXCredentials = MXCredentials(homeServer: homeUrl, userId: userId, accessToken: accessToken)
                credentials.identityServer = "https://vector.im"
                MatrixManager.shared.sync(credentials: credentials) {
                    print("sync Martrix succeed")
                }
                if let domain = dic["domain"] as? String {
                    NetworkManager.shared.domain = domain
                }
            }
        }
    }
    
}

protocol NewsToAppCoordinatorDelegate: class {
    func navigateToFlutterViewController()
}

protocol FlutterToAppCoordinatorDelegate: class {
    func navigateToNewsViewController(call: FlutterMethodCall)
}

extension AppCoordinator: NewsToAppCoordinatorDelegate{
    func navigateToFlutterViewController(){
        let coordinator = FlutterCoordinator(navigationController: self.navigationController)
        coordinator.delegate = self
        self.add(coordinator)
//        coordinator.start()
    }
}

extension AppCoordinator: FlutterToAppCoordinatorDelegate{
    func navigateToNewsViewController(call: FlutterMethodCall){
        let coordinator = ChatCoordinator(navigationController: self.navigationController)
        coordinator.delegate = self
        self.add(coordinator)
        coordinator.start(call: call)
    }
    
    func navigateToCreateRoom(call: FlutterMethodCall){
        let coordinator = ChatCoordinator(navigationController: self.navigationController)
        coordinator.delegate = self
        self.add(coordinator)
        coordinator.createRoom(call: call)
    }
}
