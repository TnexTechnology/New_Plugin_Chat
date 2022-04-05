//
//  ChatDetailViewController+Label.swift
//  tnexchat
//
//  Created by Din Vu Dinh on 05/04/2022.
//

import Foundation

extension ChatDetailViewController: MKMessageLabelDelegate {
    
    public func didSelectDate(_ date: Date) {
        print(date.convertDateToDayString())
    }

    public func didSelectPhoneNumber(_ phoneNumber: String) {
        print("Phone Number Selected: \(phoneNumber)")
        self.cellDidClickPhoneNumber(phone: phoneNumber)
    }

    public func didSelectURL(_ url: URL) {
        print("URL Selected: \(url)")
        let strUrl: String = url.absoluteString
        self.handleOpenAppUrl(url: strUrl)
    }
    
    func cellDidClickPhoneNumber(phone: String) {
        let alertSheet: UIAlertController = UIAlertController(title: nil, message: phone, preferredStyle: .actionSheet)
        let copyAction = UIAlertAction(title: "Sao chép", style: .default) { (_) in
            UIPasteboard.general.string = phone
        }
        let callAction = UIAlertAction(title: "Gọi \(phone)", style: .default) {[weak self] (_) in
            let phoneFiltedText = String(phone.unicodeScalars.filter(CharacterSet.whitespaces.inverted.contains))
            var phoneNumber: String = phoneFiltedText
            if phoneNumber.hasPrefix("84") { phoneNumber = "+" + phoneNumber }
            self?.handleOpenAppUrl(url: "tel://\(phoneNumber)")
        }
        let cancelAction = UIAlertAction(title: "Huỷ", style: .cancel, handler: nil)
        alertSheet.addAction(copyAction)
        alertSheet.addAction(callAction)
        alertSheet.addAction(cancelAction)
        self.present(alertSheet, animated: true, completion: nil)
    }
    
    private func handleOpenAppUrl(url: String) {
        guard let url = URL(string: url),
            UIApplication.shared.canOpenURL(url) else { return }
        if #available(iOS 10, *) {
            UIApplication.shared.open(url)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}
