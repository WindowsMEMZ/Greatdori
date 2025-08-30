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

#if HAS_BINARY_RESOURCE_BUNDLES

import Foundation
internal import SwiftyJSON

/// Represent a group of related rich contents.
///
/// > Beta API:
/// >
/// > This API is currently in development and is unstable.
/// > It is subject to change, and software implemented with this API should be tested with its stable version.
public typealias RichContentGroup = [RichContent]

/// Represent partial rich content.
///
/// > Beta API:
/// >
/// > This API is currently in development and is unstable.
/// > It is subject to change, and software implemented with this API should be tested with its stable version.
public enum RichContent: Sendable, Equatable, Hashable, DoriCache.Cacheable {
    case br
    case text(String)
    case heading(String)
    case bullet(String)
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
    @usableFromInline
    internal init(_ newsContent: [DoriAPI.News.Item.Content]) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        func parseSection(_ section: [DoriAPI.News.Item.Content.ContentDataSection], ul: Bool = false) -> Self {
            var result = Self()
            for data in section {
                switch data {
                case .localizedText(let text):
                    if !ul {
                        result.append(.text(NSLocalizedString(text, bundle: #bundle, comment: "")))
                    } else {
                        result.append(.bullet(NSLocalizedString(text, bundle: #bundle, comment: "")))
                    }
                case .textLiteral(let text):
                    if !ul {
                        result.append(.text(text))
                    } else {
                        result.append(.bullet(text))
                    }
                case .ul(let sections):
                    result.append(contentsOf: sections.flatMap { parseSection($0, ul: true) })
                case .link(_, let data, _):
                    if let url = URL(string: data) {
                        result.append(.link(url))
                    } else {
                        result.append(.text(data))
                    }
                case .br:
                    result.append(.br)
                case .date(let date):
                    result.append(.text(dateFormatter.string(from: date)))
                }
            }
            return result
        }
        self = []
        for content in newsContent {
            switch content {
            case .content(let section):
                self.append(contentsOf: parseSection(section))
            case .heading(let string):
                self.append(.heading(string))
            }
        }
    }
}

#endif // HAS_BINARY_RESOURCE_BUNDLES
