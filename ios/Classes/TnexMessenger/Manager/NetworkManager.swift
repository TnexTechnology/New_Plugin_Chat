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
    
    public func updateFont(flutterViewController: FlutterViewController) {
//        let font: UIFont = UIFont(name: "Quicksand-Regular", size: 18.0)!
        
        let bundle = Bundle.main
        let listFontNames: [String] = ["Quicksand-Regular", "Quicksand-Medium", "RobotoMono-SemiBold"]
        listFontNames.forEach { name in
            let fontKey = flutterViewController.lookupKey(forAsset: "fonts/\(name).ttf")
            let path = bundle.path(forResource: fontKey, ofType: nil)
            if let fontData = NSData(contentsOfFile: path ?? ""), let dataProvider = CGDataProvider(data: fontData) {
                let fontRef = CGFont(dataProvider)
                var errorRef: Unmanaged<CFError>? = nil
                if let fr = fontRef {
                 CTFontManagerRegisterGraphicsFont(fr, &errorRef)
                }
            }
        }
    }
    
    func uploadImageChat(imageData: Data, completion: @escaping(_ url: String?) -> Void) {
        self.getToken {[weak self] bearToken in
            self?.tokenChannel = nil
            let requestUrl = "https://api-gw-user.tnex.com.vn/api/v1/customer-gw/services/uploadFiles"
            var headers: [String: String] = [:]
            headers["device-id"] =  "8c30f508-3b8d-4696-b7ef-135615e4e4b8"
            headers["location"] = "21.032876784,105.839820047"
            headers["language"] = "vi"
            headers["unomi-session-id"] = "8c30f508-3b8d-4696-b7ef-135615e4e4b8"
            headers["Content-Type"] = "multipart/form-data"
            headers["Authorization"] = bearToken
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
        eventSink?("token")
        
        
    }
    
    var tokenChannel: FlutterMethodChannel?
    
    func getToken(completion: @escaping(_ url: String?) -> Void) {
        tokenChannel = FlutterMethodChannel(name: "tnex_token",
                                              binaryMessenger: flutterVC.binaryMessenger)
        tokenChannel?.setMethodCallHandler({
            (call: FlutterMethodCall, result: FlutterResult) -> Void in
            let dic = call.arguments as? String
            completion(dic)
        })
        
    }
    
    public func showProfile(userId: String) {
        let channel = FlutterMethodChannel(name: "tnex_chat",
                                              binaryMessenger: flutterVC.binaryMessenger)
        channel.invokeMethod("showProfile", arguments: userId)
        
    }
    
    public func gotoTransfer(mobile: String) {
        let channel = FlutterMethodChannel(name: "tnex_chat",
                                              binaryMessenger: flutterVC.binaryMessenger)
        channel.invokeMethod("transfer", arguments: mobile)
        
    }
    
    func getProfile(by userId: String, completion: @escaping(MSBUserInfoModel?) -> Void) {
        //consumer-api/service-user/user/friendprofile/
        self.getToken {[weak self] bearToken in
            guard let self = self else { return }
            self.tokenChannel = nil
            guard let msbUserId = self.convertChatFriendIdToMsbUserId(userId: userId) else {
                completion(nil)
                return
            }
            let requestUrl = "https://api-gw-user.tnex.com.vn/consumer-api/service-user/user/friendprofile/\(msbUserId)"
            var headers: HTTPHeaders = [:]
            headers["Authorization"] = bearToken
            headers["messageId"] = UUID().uuidString
            AF.request(requestUrl, method:.get,parameters: nil,encoding: JSONEncoding.default, headers: headers).responseData { response in
                switch response.result {
                case .success(let value):
                    do{
                        if let result = try JSONSerialization.jsonObject(with: value, options: []) as? [String: Any] {
                            let avatarUrl = result["avatarImage"] as? String
                            let displayName = result["firstname"] as? String
                            let coverUrl = result["backgroundImage"] as? String
                            let mobile = result["mobile"] as? String
                            let userInfo = MSBUserInfoModel(avatarUrl: avatarUrl, coverUrl: coverUrl, displayName: displayName ?? "", userId: userId, msbUserId: msbUserId, mobile: mobile ?? "")
                            completion(userInfo)
                        }
                        
                    }catch{ print("erroMsg") }
                case .failure(let error):
                    print("Error in upload: \(error.localizedDescription)")
                    completion(nil)
                }
            }
            
        }
        eventSink?("token")
    }
    
    private func convertChatFriendIdToMsbUserId(userId: String) -> String? {
        let msbUserId = userId.replacingOccurrences(of: "@", with: "")
        return msbUserId.components(separatedBy: ":").first
    }
}
