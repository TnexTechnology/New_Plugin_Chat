//
//  UserDefaultsExtension.swift
//  Tnex messenger
//
//  Created by Din Vu Dinh on 28/02/2022.
//

import Foundation

public extension UserDefaults {
    private static let appGroup: String = {
        guard let group = Bundle.main.infoDictionary?["AppGroup"] as? String else {
            fatalError("Missing 'AppGroup' key in Info.plist!")
        }
        return group
    }()
  #if os(macOS)
    private static let teamIdentifierPrefix = Bundle.main
      .object(forInfoDictionaryKey: "TeamIdentifierPrefix") as? String ?? ""

    private static let suiteName = teamIdentifierPrefix + appGroup
  #else // iOS
    private static let suiteName = "group." + appGroup
  #endif

    static let group = UserDefaults(suiteName: suiteName)!
}
