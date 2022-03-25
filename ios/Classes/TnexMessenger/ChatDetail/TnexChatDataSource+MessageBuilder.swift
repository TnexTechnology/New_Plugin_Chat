//
//  TnexChatDataSource+MessageBuilder.swift
//  tnexchat
//
//  Created by MacOS on 06/03/2022.
//

import Foundation
import MatrixSDK

extension TnexChatDataSource {
    
    func builderMessage(from event: MXEvent) -> ChatItemProtocol {
        switch MXEventType(identifier: event.type) {
        case .roomMessage:
            if event.isMediaAttachment() {
                return buildPhotoMessage(event: event)
            }
            return buildTextMessage(event: event)
        case .roomMember, .roomCreate:
            return ActionMessageModel(event: event)
        case .roomGuestAccess:
            print("Setting can join")
            return buildTextMessage(event: event)
        case .roomHistoryVisibility:
            print("Da chia se")
            return buildTextMessage(event: event)
            
//        case .roomTopic:
//        case .roomName:
        case .roomPowerLevels:
            print("casc thong so cua room")
            return buildTextMessage(event: event)
        default:
            return buildTextMessage(event: event)
        }
        
    }
    
    private func buildTextMessage(event: MXEvent) -> TnexMessageModelProtocol {
        let messageModel = TnexMessageModel(event: event)
        messageModel.type = TextMessageModel<TnexMessageModel>.chatItemType
        let textMessageModel = DemoTextMessageModel(messageModel: messageModel, text: getText(event: event))
        if let client = event.clientId {
            eventDic[client] = event.eventId
        }
        return textMessageModel
    }
    
    private func getText(event: MXEvent) -> String {
        if !event.isEdit() {
            if let newContent = event.content["text"] as? String {
                return newContent.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            return (event.content["body"] as? String).map {
                $0.trimmingCharacters(in: .whitespacesAndNewlines)
            } ?? "event type: \(event.type) content: \(event.content)"
        } else {
            let newContent = event.content["m.new_content"]! as? NSDictionary
            return (newContent?["body"] as? String).map {
                    $0.trimmingCharacters(in: .whitespacesAndNewlines)
                } ?? event.type
        }
    }
    
    func buildPhotoMessage(event: MXEvent) -> TnexMessageModelProtocol {
        var imageSize: CGSize = CGSize(width: 200, height: 200)
        if let info: [String: Any] = event.content(valueFor: "info") {
            if let width = info["w"] as? Double,
                let height = info["h"] as? Double {
                imageSize = CGSize(width: width, height: height)
            }
        }
        let messageModel = TnexMessageModel(event: event)
        messageModel.type = PhotoMessageModel<TnexMessageModel>.chatItemType
        let mediaURLs = event.getMediaURLs().compactMap(MXURL.init)
        let urls: [URL] = mediaURLs.compactMap { mediaURL in
            return URL(string: mediaURL.mxContentURI.absoluteString)
//            return mediaURL.contentURL(on: URL(string: APIManager.shared.homeServer)!)
        }
        let photoItem = TnexMediaItem(imageSize: imageSize, image: nil, urlString: urls.first?.absoluteString)
        let photoMessageModel = TnextPhotoMessageModel(messageModel: messageModel, mediaItem: photoItem)
        if let client = event.clientId {
            eventDic[client] = event.eventId
        }
        return photoMessageModel
    }
    
    private func buildActionMessage(event: MXEvent) -> TnexMessageModelProtocol {
        let messageModel = TnexMessageModel(event: event)
        messageModel.type = TextMessageModel<TnexMessageModel>.chatItemType
        let textMessageModel = DemoTextMessageModel(messageModel: messageModel, text: getText(event: event))
        return textMessageModel
    }
    
}
