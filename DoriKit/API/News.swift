//===---*- Greatdori! -*---------------------------------------------------===//
//
// News.swift
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

import Foundation
internal import os
internal import SwiftyJSON

extension DoriAPI {
    /// Request and fetch data about news in Bandori.
    public enum News {
        /// Get all news about Bestdori.
        ///
        /// The results have guaranteed sorting by ID.
        ///
        /// - Returns: Requested news, nil if failed to fetch data.
        public static func all() async -> [PreviewItem]? {
            // Response example:
            // {
            //     "1": {
            //         "title": "New Bestdori! is under Development",
            //         "authors": [
            //             "Bestdori! Team"
            //         ],
            //         "timestamp": "1550188800000",
            //         "tags": [
            //             "Bestdori!",
            //             "Announcement"
            //         ]
            //     },
            //     ...
            // }
            let request = await requestJSON("https://bestdori.com/api/news/all.5.json")
            if case let .success(respJSON) = request {
                let task = Task.detached(priority: .userInitiated) {
                    var result = [PreviewItem]()
                    for (key, value) in respJSON {
                        result.append(.init(
                            id: Int(key) ?? 0,
                            title: value["title"].stringValue,
                            authors: value["authors"].arrayValue.map { $0.stringValue },
                            timestamp: Date(timeIntervalSince1970: Double(Int64(value["timestamp"].stringValue.dropLast(3)) ?? 0)),
                            tags: value["tags"].arrayValue.map { $0.stringValue }
                        ))
                    }
                    return result.sorted { $0.id < $1.id }
                }
                return await task.value
            }
            return nil
        }
        
        /// Get recent news in different categories.
        ///
        /// The results in each categories have guaranteed sorting by ID.
        ///
        /// - Returns: Requested news, nil if failed to fetch data.
        public static func recent() async -> RecentItems? {
            // Response example:
            // {
            //     "songs": {
            //         "622": {
            //             "musicTitle": [
            //                 "Start as Usual", // jp
            //                 "Start as Usual", // en
            //                 "Start as Usual", // tw
            //                 "Start as Usual", // cn
            //                 null              // kr
            //             ],
            //             "publishedAt": [
            //                 "1724220000000",
            //                 ...
            //             ]
            //         },
            //         ...
            //     },
            //     "events": {
            //         "268": {
            //             "eventName": [
            //                 "夕影、鮮やかに溶け出して",
            //                 ...
            //             ],
            //             "startAt": [
            //                 "1724220000000",
            //                 ...
            //             ],
            //             "endAt": [
            //                 "1724932799000",
            //                 ...
            //             ]
            //         },
            //         ...
            //     },
            //     "gacha": {
            //         "1361": {
            //             "gachaName": [
            //                 "キラキラサマー！★5メンバー1人確定ガチャ",
            //                 ...
            //             ],
            //             "publishedAt": [
            //                 "1720591200000",
            //                 ...
            //             ],
            //             "closedAt": [
            //                 "1722405599000",
            //                 ...
            //             ]
            //         },
            //         ...
            //     },
            //     "loginBonuses": {
            //         "828": {
            //             "caption": [
            //                 "キラキラサマー！ログインキャンペーン",
            //                 ...
            //             ],
            //             "publishedAt": [
            //                 "1720591200000",
            //                 ...
            //             ],
            //             "closedAt": [
            //                 "1722884399000",
            //                 ...
            //             ]
            //         },
            //         ...
            //     }
            // }
            let request = await requestJSON("https://bestdori.com/api/news/dynamic/recent.json")
            if case let .success(respJSON) = request {
                let task = Task.detached(priority: .userInitiated) {
                    var songs = [RecentItems.Song]()
                    for (key, value) in respJSON["songs"] {
                        songs.append(.init(
                            id: Int(key) ?? 0,
                            musicTitle: .init(
                                jp: value["musicTitle"][0].string,
                                en: value["musicTitle"][1].string,
                                tw: value["musicTitle"][2].string,
                                cn: value["musicTitle"][3].string,
                                kr: value["musicTitle"][4].string
                            ),
                            publishedAt: .init(
                                jp: value["publishedAt"][0].string != nil ? Date(timeIntervalSince1970: Double(Int(value["publishedAt"][0].stringValue.dropLast(3))!)) : nil,
                                en: value["publishedAt"][1].string != nil ? Date(timeIntervalSince1970: Double(Int(value["publishedAt"][1].stringValue.dropLast(3))!)) : nil,
                                tw: value["publishedAt"][2].string != nil ? Date(timeIntervalSince1970: Double(Int(value["publishedAt"][2].stringValue.dropLast(3))!)) : nil,
                                cn: value["publishedAt"][3].string != nil ? Date(timeIntervalSince1970: Double(Int(value["publishedAt"][3].stringValue.dropLast(3))!)) : nil,
                                kr: value["publishedAt"][4].string != nil ? Date(timeIntervalSince1970: Double(Int(value["publishedAt"][4].stringValue.dropLast(3))!)) : nil
                            )
                        ))
                    }
                    var events = [RecentItems.Event]()
                    for (key, value) in respJSON["events"] {
                        events.append(.init(
                            id: Int(key) ?? 0,
                            eventName: .init(
                                jp: value["eventName"][0].string,
                                en: value["eventName"][1].string,
                                tw: value["eventName"][2].string,
                                cn: value["eventName"][3].string,
                                kr: value["eventName"][4].string
                            ),
                            startAt: .init(
                                jp: value["startAt"][0].string != nil ? Date(timeIntervalSince1970: Double(Int(value["startAt"][0].stringValue.dropLast(3))!)) : nil,
                                en: value["startAt"][1].string != nil ? Date(timeIntervalSince1970: Double(Int(value["startAt"][1].stringValue.dropLast(3))!)) : nil,
                                tw: value["startAt"][2].string != nil ? Date(timeIntervalSince1970: Double(Int(value["startAt"][2].stringValue.dropLast(3))!)) : nil,
                                cn: value["startAt"][3].string != nil ? Date(timeIntervalSince1970: Double(Int(value["startAt"][3].stringValue.dropLast(3))!)) : nil,
                                kr: value["startAt"][4].string != nil ? Date(timeIntervalSince1970: Double(Int(value["startAt"][4].stringValue.dropLast(3))!)) : nil
                            ),
                            endAt: .init(
                                jp: value["endAt"][0].string != nil ? Date(timeIntervalSince1970: Double(Int(value["endAt"][0].stringValue.dropLast(3))!)) : nil,
                                en: value["endAt"][1].string != nil ? Date(timeIntervalSince1970: Double(Int(value["endAt"][1].stringValue.dropLast(3))!)) : nil,
                                tw: value["endAt"][2].string != nil ? Date(timeIntervalSince1970: Double(Int(value["endAt"][2].stringValue.dropLast(3))!)) : nil,
                                cn: value["endAt"][3].string != nil ? Date(timeIntervalSince1970: Double(Int(value["endAt"][3].stringValue.dropLast(3))!)) : nil,
                                kr: value["endAt"][4].string != nil ? Date(timeIntervalSince1970: Double(Int(value["endAt"][4].stringValue.dropLast(3))!)) : nil
                            )
                        ))
                    }
                    var gacha = [RecentItems.Gacha]()
                    for (key, value) in respJSON["gacha"] {
                        gacha.append(.init(
                            id: Int(key) ?? 0,
                            gachaName: .init(
                                jp: value["gachaName"][0].string,
                                en: value["gachaName"][1].string,
                                tw: value["gachaName"][2].string,
                                cn: value["gachaName"][3].string,
                                kr: value["gachaName"][4].string
                            ),
                            publishedAt: .init(
                                jp: value["publishedAt"][0].string != nil ? Date(timeIntervalSince1970: Double(Int(value["publishedAt"][0].stringValue.dropLast(3))!)) : nil,
                                en: value["publishedAt"][1].string != nil ? Date(timeIntervalSince1970: Double(Int(value["publishedAt"][1].stringValue.dropLast(3))!)) : nil,
                                tw: value["publishedAt"][2].string != nil ? Date(timeIntervalSince1970: Double(Int(value["publishedAt"][2].stringValue.dropLast(3))!)) : nil,
                                cn: value["publishedAt"][3].string != nil ? Date(timeIntervalSince1970: Double(Int(value["publishedAt"][3].stringValue.dropLast(3))!)) : nil,
                                kr: value["publishedAt"][4].string != nil ? Date(timeIntervalSince1970: Double(Int(value["publishedAt"][4].stringValue.dropLast(3))!)) : nil
                            ),
                            closedAt: .init(
                                jp: value["closedAt"][0].string != nil ? Date(timeIntervalSince1970: Double(Int(value["closedAt"][0].stringValue.dropLast(3))!)) : nil,
                                en: value["closedAt"][1].string != nil ? Date(timeIntervalSince1970: Double(Int(value["closedAt"][1].stringValue.dropLast(3))!)) : nil,
                                tw: value["closedAt"][2].string != nil ? Date(timeIntervalSince1970: Double(Int(value["closedAt"][2].stringValue.dropLast(3))!)) : nil,
                                cn: value["closedAt"][3].string != nil ? Date(timeIntervalSince1970: Double(Int(value["closedAt"][3].stringValue.dropLast(3))!)) : nil,
                                kr: value["closedAt"][4].string != nil ? Date(timeIntervalSince1970: Double(Int(value["closedAt"][4].stringValue.dropLast(3))!)) : nil
                            )
                        ))
                    }
                    var loginBonuses = [RecentItems.LoginBonus]()
                    for (key, value) in respJSON["loginBonuses"] {
                        loginBonuses.append(.init(
                            id: Int(key) ?? 0,
                            caption: .init(
                                jp: value["caption"][0].string,
                                en: value["caption"][1].string,
                                tw: value["caption"][2].string,
                                cn: value["caption"][3].string,
                                kr: value["caption"][4].string
                            ),
                            publishedAt: .init(
                                jp: value["publishedAt"][0].string != nil ? Date(timeIntervalSince1970: Double(Int(value["publishedAt"][0].stringValue.dropLast(3))!)) : nil,
                                en: value["publishedAt"][1].string != nil ? Date(timeIntervalSince1970: Double(Int(value["publishedAt"][1].stringValue.dropLast(3))!)) : nil,
                                tw: value["publishedAt"][2].string != nil ? Date(timeIntervalSince1970: Double(Int(value["publishedAt"][2].stringValue.dropLast(3))!)) : nil,
                                cn: value["publishedAt"][3].string != nil ? Date(timeIntervalSince1970: Double(Int(value["publishedAt"][3].stringValue.dropLast(3))!)) : nil,
                                kr: value["publishedAt"][4].string != nil ? Date(timeIntervalSince1970: Double(Int(value["publishedAt"][4].stringValue.dropLast(3))!)) : nil
                            ),
                            closedAt: .init(
                                jp: value["closedAt"][0].string != nil ? Date(timeIntervalSince1970: Double(Int(value["closedAt"][0].stringValue.dropLast(3))!)) : nil,
                                en: value["closedAt"][1].string != nil ? Date(timeIntervalSince1970: Double(Int(value["closedAt"][1].stringValue.dropLast(3))!)) : nil,
                                tw: value["closedAt"][2].string != nil ? Date(timeIntervalSince1970: Double(Int(value["closedAt"][2].stringValue.dropLast(3))!)) : nil,
                                cn: value["closedAt"][3].string != nil ? Date(timeIntervalSince1970: Double(Int(value["closedAt"][3].stringValue.dropLast(3))!)) : nil,
                                kr: value["closedAt"][4].string != nil ? Date(timeIntervalSince1970: Double(Int(value["closedAt"][4].stringValue.dropLast(3))!)) : nil
                            )
                        ))
                    }
                    return RecentItems(
                        songs: songs.sorted { $0.id < $1.id },
                        events: events.sorted { $0.id < $1.id },
                        gacha: gacha.sorted { $0.id < $1.id },
                        loginBonuses: loginBonuses.sorted { $0.id < $1.id }
                    )
                }
                return await task.value
            }
            return nil
        }
        
        /// Get detail of news in Bestdori.
        /// - Parameter id: ID of target news.
        /// - Returns: Detail data of requested news, nil if failed to fetch.
        public static func detail(of id: Int) async -> Item? {
            // Response example:
            // {
            //     "title": "Patch Note: TW 8.4.0.31",
            //     "authors": [
            //         "Bestdori! Patch Note Bot"
            //     ],
            //     "timestamp": "1752739871925",
            //     "tags": [
            //         "Patch Note",
            //         ...
            //     ],
            //     "content": [
            //         {
            //             "type": "content",
            //             "data": [
            //                 {
            //                     "type": "text",
            //                     "data": {
            //                         "t": "text.introPatchNote[0]"
            //                     }
            //                 },
            //                 {
            //                     "type": "text",
            //                     "data": "8.4.0.31",
            //                     "class": "literal"
            //                 },
            //                 ...
            //             ]
            //         },
            //         {
            //             "type": "heading",
            //             "data": {
            //                 "t": "header.cards"
            //             }
            //         },
            //         ...
            //     ]
            // }
            let request = await requestJSON("https://bestdori.com/api/news/\(id).json")
            if case let .success(respJSON) = request {
                let task = Task.detached(priority: .userInitiated) {
                    var content = [Item.Content]()
                    for c in respJSON["content"] {
                        let type = c.1["type"].stringValue
                        switch type {
                        case "content":
                            func resolveContentSections(_ content: JSON) -> [Item.Content.ContentDataSection] {
                                var sections = [Item.Content.ContentDataSection]()
                                for section in content {
                                    let type = section.1["type"].stringValue
                                    switch type {
                                    case "text":
                                        if let localized = section.1["data"]["t"].string {
                                            sections.append(.localizedText(localized))
                                        } else if section.1["class"].stringValue == "literal",
                                                  let literal = section.1["data"].string {
                                            sections.append(.textLiteral(literal))
                                        } else {
                                            logger.error("Failed to resolve text section. Text is neither localized key nor a string literal")
                                        }
                                    case "ul":
                                        var result = [[Item.Content.ContentDataSection]]()
                                        for data in section.1["data"] {
                                            result.append(resolveContentSections(data.1))
                                        }
                                        sections.append(.ul(result))
                                    case "link":
                                        sections.append(.link(
                                            target: section.1["target"].stringValue,
                                            data: section.1["data"].string ?? String(section.1["data"].intValue),
                                            rich: section.1["rich"].bool ?? false
                                        ))
                                    case "br":
                                        sections.append(.br)
                                    case "date":
                                        sections.append(.date(Date(timeIntervalSince1970: Double(Int64(section.1["data"].stringValue.dropLast(3)) ?? 0))))
                                    default:
                                        logger.error("Failed to determine type of 2-content. Expected 'text', 'ul', 'link', 'br', or 'date', but got '\(type)'")
                                    }
                                }
                                return sections
                            }
                            
                            content.append(.content(resolveContentSections(c.1["data"])))
                        case "heading":
                            content.append(.heading(c.1["data"]["t"].stringValue))
                        default:
                            logger.error("Failed to determine type of 1-content. Expected 'content' or 'heading', but got '\(type)'")
                        }
                    }
                    return Item(
                        id: id,
                        title: respJSON["title"].stringValue,
                        authors: respJSON["authors"].arrayValue.map { $0.stringValue },
                        timestamp: Date(timeIntervalSince1970: Double(Int64(respJSON["timestamp"].stringValue.dropLast(3)) ?? 0)),
                        tags: respJSON["tags"].arrayValue.map { $0.stringValue },
                        content: content
                    )
                }
                return await task.value
            }
            return nil
        }
    }
}

extension DoriAPI.News {
    /// Represent simplified data of news.
    public struct PreviewItem: Sendable, Identifiable, Hashable, DoriCache.Cacheable {
        /// A unique ID of news.
        public var id: Int
        /// Title of news.
        public var title: String
        /// Authors of news.
        public var authors: [String]
        /// Publishing timestamp of news.
        public var timestamp: Date // String(JSON) -> Date(Swift)
        /// Tags of news.
        public var tags: [String]
    }
    
    /// Represent recent news items in different categories.
    public struct RecentItems: Sendable, Hashable, DoriCache.Cacheable {
        public var songs: [Song]
        public var events: [Event]
        public var gacha: [Gacha]
        public var loginBonuses: [LoginBonus]
        
        public struct Song: Sendable, Identifiable, Hashable, DoriCache.Cacheable {
            public var id: Int
            public var musicTitle: DoriAPI.LocalizedData<String>
            public var publishedAt: DoriAPI.LocalizedData<Date> // String(JSON) -> Date(Swift)
        }
        public struct Event: Sendable, Identifiable, Hashable, DoriCache.Cacheable {
            public var id: Int
            public var eventName: DoriAPI.LocalizedData<String>
            public var startAt: DoriAPI.LocalizedData<Date> // String(JSON) -> Date(Swift)
            public var endAt: DoriAPI.LocalizedData<Date> // String(JSON) -> Date(Swift)
        }
        public struct Gacha: Sendable, Identifiable, Hashable, DoriCache.Cacheable {
            public var id: Int
            public var gachaName: DoriAPI.LocalizedData<String>
            public var publishedAt: DoriAPI.LocalizedData<Date> // String(JSON) -> Date(Swift)
            public var closedAt: DoriAPI.LocalizedData<Date> // String(JSON) -> Date(Swift)
        }
        public struct LoginBonus: Sendable, Identifiable, Hashable, DoriCache.Cacheable {
            public var id: Int
            public var caption: DoriAPI.LocalizedData<String>
            public var publishedAt: DoriAPI.LocalizedData<Date> // String(JSON) -> Date(Swift)
            public var closedAt: DoriAPI.LocalizedData<Date> // String(JSON) -> Date(Swift)
        }
    }
    
    /// Represent detailed data of news item.
    public struct Item: Sendable, Identifiable, Hashable, DoriCache.Cacheable {
        /// A unique ID of news.
        public var id: Int
        /// Title of news.
        public var title: String
        /// Authors of news.
        public var authors: [String]
        /// Publishing timestamp of news.
        public var timestamp: Date // String(JSON) -> Date(Swift)
        /// Tags of news.
        public var tags: [String]
        public var content: [Content]
        
        public enum Content: Sendable, Hashable, DoriCache.Cacheable {
            case content([ContentDataSection])
            case heading(String)
            
            public enum ContentDataSection: Sendable, Hashable, DoriCache.Cacheable {
                case localizedText(String)
                case textLiteral(String)
                case ul([[ContentDataSection]])
                case link(target: String, data: String, rich: Bool)
                case br
                case date(Date)
            }
        }
    }
}
#if HAS_BINARY_RESOURCE_BUNDLES
extension Array<DoriAPI.News.Item.Content> {
    @inlinable
    public var forRichRendering: RichContentGroup {
        .init(self)
    }
}
#endif

extension DoriAPI.News.PreviewItem {
    public init(_ full: DoriAPI.News.Item) {
        self.init(
            id: full.id,
            title: full.title,
            authors: full.authors,
            timestamp: full.timestamp,
            tags: full.tags
        )
    }
}
extension DoriAPI.News.Item {
    @inlinable
    public init?(id: Int) async {
        if let item = await DoriAPI.News.detail(of: id) {
            self = item
        } else {
            return nil
        }
    }
    
    @inlinable
    public init?(preview: DoriAPI.News.PreviewItem) async {
        await self.init(id: preview.id)
    }
}
