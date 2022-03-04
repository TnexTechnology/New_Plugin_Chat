//
//  TnexRoomSummary.swift
//  Tnex messenger
//
//  Created by MacOS on 27/02/2022.
//

import Foundation

import Foundation
import MatrixSDK

@dynamicMemberLookup
public class TnexRoomSummary {
    internal var summary: MXRoomSummary

    public var lastMessageDate: Date {
        let timestamp = Double(summary.lastMessage.originServerTs)
        return Date(timeIntervalSince1970: timestamp / 1000)
    }

    public init(_ summary: MXRoomSummary) {
        self.summary = summary
    }

    public subscript<T>(dynamicMember keyPath: KeyPath<MXRoomSummary, T>) -> T {
        summary[keyPath: keyPath]
    }
}
