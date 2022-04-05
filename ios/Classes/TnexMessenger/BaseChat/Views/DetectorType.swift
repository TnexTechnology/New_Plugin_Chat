//
//  DetectorType.swift
//  tnexchat
//
//  Created by Din Vu Dinh on 28/03/2022.
//

import Foundation

public struct MentionInfo{
    public let range: NSRange
    public let target: String
    public init(range: NSRange, target: String) {
        self.range = range
        self.target = target
    }
}

public enum DetectorType: Hashable {
    public static func == (lhs: DetectorType, rhs: DetectorType) -> Bool {
        return lhs.toInt() == rhs.toInt()
    }
    

    case address
    case date
    case phoneNumber
    case url
    case transitInformation
    case custom(NSRegularExpression)
    case keySearch([NSRange])
    case mentionRange([MentionInfo])
    

    // swiftlint:disable force_try
    public static var hashtag = DetectorType.custom(try! NSRegularExpression(pattern: "#[a-zA-Z0-9]{4,}", options: []))
//    public static var mention = DetectorType.custom(try! NSRegularExpression(pattern: "@[a-zA-Z0-9]{4,}", options: []))
    // swiftlint:enable force_try

    internal var textCheckingType: NSTextCheckingResult.CheckingType {
        switch self {
        case .address: return .address
        case .date: return .date
        case .phoneNumber: return .phoneNumber
        case .url: return .link
        case .transitInformation: return .transitInformation
        case .custom: return .regularExpression
        case .mentionRange: return .regularExpression
        case .keySearch: return .regularExpression
        }
    }

    /// Simply check if the detector type is a .custom
    public var isCustom: Bool {
        switch self {
        case .custom: return true
        default: return false
        }
    }

    public var isMention: Bool {
        switch self {
        case .mentionRange: return true
        default: return false
        }
    }
    
    public var isKeySearch: Bool {
        switch self {
        case .keySearch: return true
        default: return false
        }
    }
    ///The hashValue of the `DetectorType` so we can conform to `Hashable` and be sorted.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(toInt())
    }

    /// Return an 'Int' value for each `DetectorType` type so `DetectorType` can conform to `Hashable`
    private func toInt() -> Int {
        switch self {
        case .address: return 0
        case .date: return 1
        case .phoneNumber: return 2
        case .url: return 3
        case .transitInformation: return 4
        case .custom(let regex): return regex.hashValue
        case .keySearch(let listRanges): return 5
        case .mentionRange(let mentionInfo): return mentionInfo.map({$0.target}).joined().hashValue
        }
    }

}
