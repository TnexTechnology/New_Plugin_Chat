//
//  FLNativeViewFactory.swift
//  Runner
//
//  Created by Din Vu Dinh on 01/06/2022.
//

import Flutter
import UIKit
import tnexchat
import MatrixSDK

class FLNativeViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return FLNativeView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger)
    }
}

class FLNativeView: NSObject, FlutterPlatformView {
    private var _view: UIView

        init(
            frame: CGRect,
            viewIdentifier viewId: Int64,
            arguments args: Any?,
            binaryMessenger messenger: FlutterBinaryMessenger?
        ) {
            _view = UIView()
            super.init()
            // iOS views can be created here
            createNativeView(view: _view)
        }

        func view() -> UIView {
            return _view
        }
    func createNativeView(view _view: UIView){
            _view.backgroundColor = UIColor.red
//            let nativeLabel = UILabel()
//            nativeLabel.text = "Native text from iOS"
//            nativeLabel.textColor = UIColor.white
//            nativeLabel.textAlignment = .center
//            nativeLabel.frame = CGRect(x: 0, y: 0, width: 180, height: 48.0)
//            _view.addSubview(nativeLabel)
//        let conversionController = ConversationViewController(rooms: [])
        
        let credentials: MXCredentials = MXCredentials(homeServer: "https://chat-matrix.tnex.com.vn", userId: "@7181fb55-bba8-483f-adde-c5c1f4452852:chat-matrix.tnex.com.vn", accessToken: "MDAyNWxvY2F0aW9uIGNoYXQtbWF0cml4LnRuZXguY29tLnZuCjAwMTNpZGVudGlmaWVyIGtleQowMDEwY2lkIGdlbiA9IDEKMDA1MGNpZCB1c2VyX2lkID0gQDcxODFmYjU1LWJiYTgtNDgzZi1hZGRlLWM1YzFmNDQ1Mjg1MjpjaGF0LW1hdHJpeC50bmV4LmNvbS52bgowMDE2Y2lkIHR5cGUgPSBhY2Nlc3MKMDAyMWNpZCBub25jZSA9IHE7U2ZMRGcxd3M9Mm00dCYKMDAyZnNpZ25hdHVyZSArvUahqvnk2QhJl9Vs3gds4Vze18mbinHERTIWLzs7RAo")
        credentials.identityServer = "https://vector.im"
        MatrixManager.shared.sync(credentials: credentials) {
            let conversionsView = ConversationListView1(rooms: MatrixManager.shared.getRooms()!)
            _view.addSubview(conversionsView)
            conversionsView.frame = _view.bounds
        }
        
        
        
    }
   
}
