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
        if let roomId = call.arguments as? String, let room = MatrixManager.shared.getRoom(roomId: roomId) {
            switch room.summary.membership {
            case .invite:
                MatrixManager.shared.mxSession?.joinRoom(room.roomId, completion: {[weak self] response in
                    guard let self = self, let newRoom = response.value else { return }
                    self.gotoChatDetail(room: TnexRoom(newRoom))
                })
            case .ban:
                print("Ban da bi ban")
                self.showAlertMessage(message: "Bạn không thể truy cập vì đã bị ban")
            case .leave:
                print("Ban da roi khoi nhom")
                self.showAlertMessage(message: "Bạn không thể truy cập vì đã rời khỏi nhóm!")
            case .join:
                self.gotoChatDetail(room: room)
            default:
                break
            }
        }
    }
    
    private func gotoChatDetail(room: TnexRoom) {
        let vc = TnexChatViewController(room: room)
        vc.coordinatorDelegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showAlertMessage(message: String) {
        let alertVC = UIAlertController.init(title: nil, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.navigationController?.present(alertVC, animated: true, completion: nil)
    }
    
    override func createRoom(call: FlutterMethodCall) {
        super.start(call: call)
        if let userId = call.arguments as? String {
            MatrixManager.shared.createRoom(with: userId) {[weak self] _room in
                guard let self = self, let room = _room else { return }
                let vc = TnexChatViewController(room: TnexRoom(room))
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
