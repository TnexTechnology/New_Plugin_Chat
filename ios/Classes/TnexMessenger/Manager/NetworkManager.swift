//
//  NetworkManager.swift
//  tnexchat
//
//  Created by Din Vu Dinh on 22/03/2022.
//

import Foundation
import Alamofire
import UIKit
import Flutter

public class NetworkManager: NSObject {
    
    public static let shared = NetworkManager()
    public var eventSink: FlutterEventSink?
    public var flutterVC: FlutterViewController!
    
    
    
    func uploadImageChat(imageData: Data, completion: @escaping(_ url: String?) -> Void) {
        self.getToken { url in
            let requestUrl = "https://api-gw-user.tnex.com.vn/api/v1/customer-gw/services/uploadFiles"
            var headers: [String: String] = [:]
            headers["device-id"] =  "8c30f508-3b8d-4696-b7ef-135615e4e4b8"
            headers["location"] = "21.032876784,105.839820047"
            headers["language"] = "vi"
            headers["unomi-session-id"] = "8c30f508-3b8d-4696-b7ef-135615e4e4b8"
            headers["Content-Type"] = "multipart/form-data"
            headers["Authorization"] = url
            AF.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(imageData, withName: "files", fileName: "image.png", mimeType: "image/png")
            }, to: requestUrl, usingThreshold: UInt64.init(), method: .post, headers: HTTPHeaders(headers))
                .responseData { response in
                    switch response.result {
                    case .success(let value):
                        do{
                            if let result = try JSONSerialization.jsonObject(with: value, options: []) as? [String], let urlString = result.first {
                                completion(urlString)
                                return
                            }
                        }catch{ print("erroMsg") }
                        completion(nil)
                    case .failure(let error):
                        print("Error in upload: \(error.localizedDescription)")
                        completion(nil)
                    }
                }
        }
        eventSink?("dđ")
        
        
    }
    
    var tokenChannel: FlutterMethodChannel?
    
    func getToken(completion: @escaping(_ url: String?) -> Void) {
        tokenChannel = FlutterMethodChannel(name: "samples.flutter.io/eventToken",
                                              binaryMessenger: flutterVC.binaryMessenger)
        tokenChannel?.setMethodCallHandler({
            (call: FlutterMethodCall, result: FlutterResult) -> Void in
            let dic = call.arguments as? String
            completion(dic)
        })
        
    }
    
    func createImageContent(image: UIImage, completion: @escaping (_ content: [String: Any]?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            completion(nil)
            return
        }
        NetworkManager.shared.uploadImageChat(imageData: imageData) { url in
            guard let url = url else {
                completion(nil)
                return
            }
            var messageContent: [String: Any] = [MessageConstants.messageBodyKey: url, MessageConstants.messageTypeKey: MessageType.image.key, "clientId": UUID().uuidString]
            messageContent["format"] = "org.matrix.custom.html"
            messageContent["filename"] = url
            messageContent["url"] = url
            let size = image.size
            let info: [String: Any] = ["mimetype": "image/png", "size": imageData.count, "w": size.width, "h": size.height]
            messageContent["info"] = info
            completion(messageContent)
        }
        
    }
}