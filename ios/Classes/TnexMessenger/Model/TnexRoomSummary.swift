//
//  TnexRoomSummary.swift
//  Tnex messenger
//
//  Created by MacOS on 27/02/2022.
//

import Foundation
import MatrixSDK

@dynamicMemberLookup
public class TnexRoomSummary {
    internal var summary: MXRoomSummary

    public var lastMessageDate: Date {
        guard let lastMessage = summary.lastMessage else { return Date()}
        let timestamp = Double(lastMessage.originServerTs)
        return Date(timeIntervalSince1970: timestamp / 1000)
    }
    
    public var originServerTs: UInt64 {
        return summary.lastMessage.originServerTs
    }

    public init(_ summary: MXRoomSummary) {
        self.summary = summary
    }

    public subscript<T>(dynamicMember keyPath: KeyPath<MXRoomSummary, T>) -> T {
        summary[keyPath: keyPath]
    }
}
