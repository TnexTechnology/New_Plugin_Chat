//
//  AccountStore.swift
//  Tnex messenger
//
//  Created by MacOS on 27/02/2022.
//

import Foundation
import MatrixSDK
import KeychainAccess

public enum LoginState {
    case loggedOut
    case authenticating
    case failure(Error)
    case loggedIn(userId: String)
}

final public class APIManager: NSObject {
        
    public static let shared = APIManager()
    var mxRestClient: MXRestClient!
    var mxSession: MXSession?
    var fileStore: MXFileStore?
    
    var handleEvent: MXOnSessionEvent?
    var memberDic: [String: MXRoomMember] = [:]
    
    var userId: String?
    
    var rooms: [TnexRoom] {
        guard let session = self.mxSession else { return [] }
        let rooms = session.rooms
            .map { roomCache[$0.roomId] ?? makeRoom(from: $0) }
            .sorted { $0.summary.lastMessageDate > $1.summary.lastMessageDate }

//        updateUserDefaults(with: rooms)
        return rooms
    }
    
    private func updateUserDefaults(with rooms: [TnexRoom]) {
        let roomItems = rooms.map { RoomItem(room: $0.room) }
        do {
            let data = try JSONEncoder().encode(roomItems)
            UserDefaults.group.set(data, forKey: "roomList")
        } catch {
            print("An error occured: \(error)")
        }
    }
    
    private var roomCache = [String: TnexRoom]()
    private func makeRoom(from mxRoom: MXRoom) -> TnexRoom {
        let room = TnexRoom(mxRoom)
        roomCache[mxRoom.roomId] = room
        return room
    }
    
    override init() {
        super.init()
        let homeServerUrl = URL(string: "https://chat-matrix.tnex.com.vn")!
       mxRestClient = MXRestClient(homeServer: homeServerUrl, unrecognizedCertificateHandler: nil)
    }
    
    
    func loginToken(completion: @escaping(_ succeed: Bool) -> Void) {
        let params = ["type" : "m.login.jwt",
                      "token": "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiI5NGVkM2IwNi1lN2E1LTQ2ODMtOWM0Ni0wZjc2YzEyZDlhYTAifQ.43m-TAjkt8AqHv1JGeAIJMrU-k2kdn-qh1p6FLCcd-Y",
                      "initial_device_display_name" : "Mobile"]
//    https://chat-matrix.tnex.com.vn/_matrix/client/r0/login
//        AF.request("https://chat-matrix.tnex.com.vn/_matrix/client/r0/login", method: .post, parameters: params, encoding: URLEncoding.httpBody)
//            .responseJSON { response in
//                print(response)
//                switch response.result {
//                case .success(let json):
//                    let jsonData = json as! Any
//                    print(jsonData)
//                case .failure(let error):
//                    print(error)
//                }
//        }
        
        
        mxRestClient.login(parameters: params) { [self] response in
            guard let responseDic = response.value else { return }
            print(responseDic)
//            let loginResponse: MXLoginResponse = MXLoginResponse(fromJSON: response)
            let homeServer: String = responseDic["home_server"] as? String ?? ""
            let userId: String? = responseDic["user_id"] as? String
            let accessToken: String? = responseDic["access_token"] as? String
            let credentials: MXCredentials = MXCredentials(homeServer: "https://chat-matrix.tnex.com.vn", userId: userId, accessToken: accessToken)
            credentials.identityServer = "https://vector.im"
            self.userId = userId
            self.sync(credentials: credentials) {
                completion(true)
            }
        }
    }
    
    var homeServer: String = ""
    public func sync(credentials: MXCredentials, completion: @escaping () -> Void) {
        self.mxRestClient = MXRestClient(credentials: credentials, unrecognizedCertificateHandler: nil)
        self.mxSession = MXSession(matrixRestClient: self.mxRestClient!)
        self.homeServer = credentials.homeServer ?? ""
        self.fileStore = MXFileStore()
        self.userId = credentials.userId

        self.mxSession!.setStore(fileStore!) { response in
            switch response {
            case .failure(let error):
                break
            case .success:
                self.mxSession?.start { response in
                    switch response {
                    case .failure(let error):
                        break
                    case .success:
                        APIManager.shared.startListeningForRoomEvents()
                        completion()
                    @unknown default:
                        fatalError("Unexpected Matrix response: \(response)")
                    }
                }
            @unknown default:
                fatalError("Unexpected Matrix response: \(response)")
            }
        }
    }
    
    func getSenderInfo(senderId: String, at room: MXRoom?, completion: @escaping (_ displayName: String?) -> Void) {
        
        if let user = self.memberDic[senderId] {
            completion(user.displayname)
        } else {
            room?.liveTimeline {[weak self] eventTimeline in
                guard let self = self else { return }
                if let members = eventTimeline?.state?.members.members {
                    for member in members {
                        if let userId = member.userId, !userId.isEmpty {
                            self.memberDic[userId] = member
                            if senderId == userId {
                                completion(member.displayname)
                            }
                        }
                    }
                }
            }
        }
    }
    
    var listenReference: Any?
    func startListeningForRoomEvents() {
        // roomState is nil for presence events, just for future reference
        listenReference = self.mxSession?.listenToEvents { event, direction, roomState in
            let affectedRooms = self.rooms.filter { $0.summary.roomId == event.roomId }
            for room in affectedRooms {
                room.add(event: event, direction: direction, roomState: roomState as? MXRoomState)
            }
            self.handleEvent?(event, direction, roomState)
        }
    }
    
    public func getRooms() -> [TnexRoom]? {
        let rooms = self.mxSession?.rooms
            .map { roomCache[$0.roomId] ?? makeRoom(from: $0) }
            .sorted { $0.summary.lastMessageDate > $1.summary.lastMessageDate }
        return rooms
    }
    
    public func getPublicList() {
        mxRestClient.publicRooms(onServer: nil, limit: nil) { response in
            switch response {
            case .success(let rooms):

                // rooms is an array of MXPublicRoom objects containing information like room id
                print("The public rooms are: \(rooms)")

            case .failure: break
            }
        }
    }
    
    
    func getUserId(userId: String) {
        mxRestClient?.displayName(forUser: userId, completion: { response in
            print(response.value)
        })
    }
    var listenReferenceRoom: Any?
    func paginate(room: TnexRoom, event: MXEvent, completion: @escaping(() -> Void)) {
        let timeline = room.room.timeline(onEvent: event.eventId)
        listenReferenceRoom = timeline?.listenToEvents { event, direction, roomState in
            if direction == .backwards {
                room.add(event: event, direction: direction, roomState: roomState)
            }
        }
        timeline?.resetPaginationAroundInitialEvent(withLimit: 40) { _ in
            completion()
        }
    }
    
    deinit {
        self.mxSession?.removeListener(self.listenReference)
    }
    
}


@objcMembers
final class RiotSettings: NSObject {
    static let shared = RiotSettings()
}
