import Foundation
import UIKit
import Flutter
import MatrixSDK
import tnexchat

final class ChatCoordinator: BaseCoordinator{
    weak var navigationController: UINavigationController?
    weak var delegate: NewsToAppCoordinatorDelegate?
    
    override func start(call: FlutterMethodCall) {
        super.start(call: call)
        if let roomId = call.arguments as? String {
            let vc = TnexChatViewController(roomId: roomId)
            vc.coordinatorDelegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func createRoom(call: FlutterMethodCall) {
        super.start(call: call)
        if let userId = call.arguments as? String {
            MatrixManager.shared.createRoom(with: userId) {[weak self] room in
                guard let self = self, let roomId = room?.roomId else { return }
                let vc = TnexChatViewController(roomId: roomId)
                vc.coordinatorDelegate = self
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        }
    }
    
    init(navigationController: UINavigationController?) {
        super.init()
        self.navigationController = navigationController
    }
}

protocol ChatCoordinatorDelegate {
    func navigateToFlutter()
}

extension ChatCoordinator: ChatCoordinatorDelegate{
    func navigateToFlutter(){
        self.delegate?.navigateToFlutterViewController()
    }
}
