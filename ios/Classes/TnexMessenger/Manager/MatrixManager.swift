//
//  AccountStore.swift
//  Tnex messenger
//
//  Created by MacOS on 27/02/2022.
//

import Foundation
import MatrixSDK
import KeychainAccess
import RxSwift
import RxRelay

public typealias SectionEvent = (event: MXEvent, direction: MXTimelineDirection, customObject: Any?)

public enum LoginState {
    case loggedOut
    case authenticating
    case failure(Error)
    case loggedIn(userId: String)
}

final public class MatrixManager: NSObject {
        
    public static let shared = MatrixManager()
    var mxRestClient: MXRestClient!
    public var mxSession: MXSession?
    var fileStore: MXFileStore?
    var memberDic: [String: MXRoomMember] = [:]
    var dicRoomAvatar: [String: String] = [:]
    public let rxEvent = BehaviorRelay<SectionEvent?>(value: nil)
        
    public var userId: String?
    
    var rooms: [TnexRoom] {
        guard let session = self.mxSession else { return [] }
        let rooms = session.rooms
            .compactMap { roomCache[$0.roomId] ?? makeRoom(from: $0) }
            .sorted { $0.summary.lastMessageDate > $1.summary.lastMessageDate }
//        updateUserDefaults(with: rooms)
        return rooms
    }
    
    private func updateUserDefaults(with rooms: [TnexRoom]) {
        let roomItems = rooms.map { $0.toRoomItem() }
        do {
            let data = try JSONEncoder().encode(roomItems)
            UserDefaults.group.set(data, forKey: "roomList")
        } catch {
            print("An error occured: \(error)")
        }
    }
    
    private var roomCache = [String: TnexRoom]()
    private func makeRoom(from mxRoom: MXRoom) -> TnexRoom? {
        let room = TnexRoom(mxRoom)
        if !room.lastMessage.isEmpty {
            roomCache[mxRoom.roomId] = room
            return room
        }
        return nil
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
            case .failure:
                break
            case .success:
                self.mxSession?.start { response in
                    switch response {
                    case .failure:
                        break
                    case .success:
                        self.startListeningForRoomEvents()
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
            if let user = room?.mxSession.user(withUserId: senderId) {
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
    }
    
    var listenReference: Any?
    func startListeningForRoomEvents() {
        // roomState is nil for presence events, just for future reference
        listenReference = self.mxSession?.listenToEvents { event, direction, roomState in
            let affectedRooms = self.rooms.filter { $0.summary.roomId == event.roomId }
            for room in affectedRooms {
                room.add(event: event, direction: direction, roomState: roomState as? MXRoomState)
            }
            self.rxEvent.accept((event, direction, roomState))
        }
    }
    
    func getRooms() -> [TnexRoom]? {
        let rooms = self.mxSession?.rooms
            .compactMap { roomCache[$0.roomId] ?? makeRoom(from: $0) }
            .sorted { $0.summary.lastMessageDate > $1.summary.lastMessageDate }
        return rooms
    }
    
    public func getDicRooms(completion: @escaping([NSDictionary]) -> Void) {
        guard let rooms = getRooms() else { return }
        let dispatchGroup = DispatchGroup()
        let tnexRooms = rooms.map({ room -> NSDictionary in
            let roomId = room.roomId
            let item: NSMutableDictionary = ["displayname": room.summary.displayname ?? "Unknown",
                                             "avatar": room.roomAvatarURL?.absoluteString ?? "",
                                             "lastMessage": room.lastMessage,
                                             "id": roomId,
                                             "unreadCount": room.summary.notificationCount,
                                             "timeCreated": room.getLastEvent()?.originServerTs ?? UInt64(Date().timeIntervalSince1970)
            ]
            
            if let avatarUrl: String = room.getRoom().directUserId, !avatarUrl.isEmpty {
                //Avatar direct chat la avatar partner
                item["avatarUrl"] = avatarUrl
            } else if let groupAvatarUrl = self.dicRoomAvatar[roomId]{
                item["avatarUrl"] = groupAvatarUrl
            } else {
                dispatchGroup.enter()
                room.getState { roomState in
                    if let partnerId = roomState?.members?.members.first(where: {$0.userId != MatrixManager.shared.userId})?.userId {
                        let groupAvatarUrl = partnerId.getAvatarUrl()
                        self.dicRoomAvatar[roomId] = groupAvatarUrl
                        item["avatarUrl"] = groupAvatarUrl
                    }
                    dispatchGroup.leave()
                }
            }
            return item
        })
        dispatchGroup.notify(queue: .main, execute: {
            completion(tnexRooms)
        })
    }
    
    public func getRoom(roomId: String) -> TnexRoom? {
        return roomCache[roomId]
    }
    
    public func createRoom(with userId: String, completion: @escaping(MXRoom?) -> Void) {
        let parameters = MXRoomCreationParameters()
        parameters.inviteArray = [userId]
        parameters.isDirect = true
        parameters.visibility = MXRoomDirectoryVisibility.private.identifier
        parameters.preset = MXRoomPreset.trustedPrivateChat.identifier
        if let room = self.mxSession?.directJoinedRoom(withUserId: userId) {
            completion(room)
            return
        }
            
        self.mxSession?.createRoom(parameters: parameters) { response in
            switch response {
            case .success(let room):
                completion(room)
            case.failure(let error):
                print("Error on creating room: \(error)")
                completion(nil)
            }
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
