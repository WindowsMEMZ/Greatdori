//===---*- Greatdori! -*---------------------------------------------------===//
//
// RichContent.swift
//
// This source file is part of the Greatdori! open source project
//
// Copyright (c) 2025 the Greatdori! project authors
// Licensed under Apache License v2.0
//
// See https://greatdori.memz.top/LICENSE.txt for license information
// See https://greatdori.memz.top/CONTRIBUTORS.txt for the list of Greatdori! project authors
//
//===----------------------------------------------------------------------===//

#if canImport(SwiftUI)

import Foundation
internal import SwiftyJSON

public typealias RichContentGroup = [RichContent]

public enum RichContent: Sendable, Equatable, Hashable, DoriCache.Cacheable {
    case br
    case text(String)
    case image([URL])
    case link(URL)
    case emoji(Emoji)
    
    internal init?(parsing json: JSON) {
        if let type = json["type"].string {
            // We use `br` as a tag for unavailable conditions.
            // However, this is not a good way in both semantic and performance.
            // Let's follow progress of experimental feature `ThenStatements` at
            // https://github.com/swiftlang/swift/blob/573607ff369dbc9d0299aa549b2ec33d87d45e6a/include/swift/Basic/Features.def#L409
            // Once it's available for production compiler, we can use it for better code.
            self = switch type {
            case "br": .br
            case "text": .text(json["data"].stringValue)
            case "image": .image(json["objects"].compactMap { .init(string: $0.1.stringValue) })
            case "link": if let url = URL(string: json["data"].stringValue) { .link(url) } else { .br }
            case "emoji": .emoji(.init(_resourceName: json["data"].stringValue))
            default: .br
            }
            if type != "br" && self == .br {
                return nil
            }
        } else {
            return nil
        }
    }
}

extension RichContentGroup {
    internal init(parsing json: JSON) {
        self = []
        for (_, value) in json {
            if let content = RichContent(parsing: value) {
                self.append(content)
            }
        }
    }
}

#endif
