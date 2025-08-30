//===---*- Greatdori! -*---------------------------------------------------===//
//
// Costume.swift
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

import SwiftUI
import Foundation
internal import SwiftyJSON

extension DoriAPI {
    /// Request and fetch data about costume in Bandori.
    public enum Costume {
        /// Get all costumes in Bandori.
        ///
        /// The results have guaranteed sorting by ID.
        ///
        /// - Returns: Requested costumes, nil if failed to fetch data.
        public static func all() async -> [PreviewCostume]? {
            // Response example:
            // {
            //     "26": {
            //         "characterId": 1,
            //         "assetBundleName": "001_live_default",
            //         "description": [
            //             "ステージ",
            //             "Stage",
            //             "舞台裝",
            //             "舞台",
            //             "스테이지"
            //         ],
            //         "publishedAt": [
            //             "1233284400000",
            //             ...
            //         ]
            //     },
            //     ...
            // }
            let request = await requestJSON("https://bestdori.com/api/costumes/all.5.json")
            if case let .success(respJSON) = request {
                let task = Task.detached(priority: .userInitiated) {
                    var result = [PreviewCostume]()
                    for (key, value) in respJSON {
                        result.append(.init(
                            id: Int(key) ?? 0,
                            characterID: value["characterId"].intValue,
                            assetBundleName: value["assetBundleName"].stringValue,
                            description: .init(
                                jp: value["description"][0].string,
                                en: value["description"][1].string,
                                tw: value["description"][2].string,
                                cn: value["description"][3].string,
                                kr: value["description"][4].string
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
                    return result.sorted { $0.id < $1.id }
                }
                return await task.value
            }
            return nil
        }
        
        /// Get detail of a costume in Bandori.
        /// - Parameter id: ID of target costume.
        /// - Returns: Detail data of reqeusted costume, nil if failed to fetch.
        public static func detail(of id: Int) async -> Costume? {
            // Response example:
            // {
            //     "characterId": 39,
            //     "assetBundleName": "039_dream_festival_3_ur",
            //     "sdResourceName": "sd039009",
            //     "description": [
            //         "この繋がりの名前は",
            //         "This Type of Relationship is Called...",
            //         "這份牽絆的名字是",
            //         "这种关系的名字是",
            //         null
            //     ],
            //     "howToGet": [
            //         null,
            //         ...
            //     ],
            //     "publishedAt": [
            //         "1735624800000",
            //         ...
            //     ],
            //     "cards": [
            //         2125
            //     ]
            // }
            let request = await requestJSON("https://bestdori.com/api/costumes/\(id).json")
            if case let .success(respJSON) = request {
                let task = Task.detached(priority: .userInitiated) {
                    return Costume(
                        id: id,
                        characterID: respJSON["characterId"].intValue,
                        assetBundleName: respJSON["assetBundleName"].stringValue,
                        sdResourceName: respJSON["sdResourceName"].stringValue,
                        description: .init(
                            jp: respJSON["description"][0].string,
                            en: respJSON["description"][1].string,
                            tw: respJSON["description"][2].string,
                            cn: respJSON["description"][3].string,
                            kr: respJSON["description"][4].string
                        ),
                        howToGet: .init(
                            jp: respJSON["howToGet"][0].string,
                            en: respJSON["howToGet"][1].string,
                            tw: respJSON["howToGet"][2].string,
                            cn: respJSON["howToGet"][3].string,
                            kr: respJSON["howToGet"][4].string
                        ),
                        publishedAt: .init(
                            jp: respJSON["publishedAt"][0].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["publishedAt"][0].stringValue.dropLast(3))!)) : nil,
                            en: respJSON["publishedAt"][1].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["publishedAt"][1].stringValue.dropLast(3))!)) : nil,
                            tw: respJSON["publishedAt"][2].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["publishedAt"][2].stringValue.dropLast(3))!)) : nil,
                            cn: respJSON["publishedAt"][3].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["publishedAt"][3].stringValue.dropLast(3))!)) : nil,
                            kr: respJSON["publishedAt"][4].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["publishedAt"][4].stringValue.dropLast(3))!)) : nil
                        ),
                        cards: respJSON["cards"].map { $0.1.intValue }
                    )
                }
                return await task.value
            }
            return nil
        }
    }
}
    
extension DoriAPI.Costume {
    /// Represent simplified data of a costume.
    public struct PreviewCostume: Sendable, Identifiable, Hashable, DoriCache.Cacheable {
        /// A unique ID of costume.
        public var id: Int
        /// ID of related character to this costume.
        public var characterID: Int
        /// Name of asset bundle, used for combination of resource URLs.
        public var assetBundleName: String
        /// Localized description of costume.
        public var description: DoriAPI.LocalizedData<String>
        /// Localized published date of costume.
        public var publishedAt: DoriAPI.LocalizedData<Date> // String(JSON) -> Date(Swift)
    }
    
    /// Represent detailed data of a costume.
    public struct Costume: Sendable, Identifiable, Hashable, DoriCache.Cacheable {
        /// A unique ID of costume.
        public var id: Int
        /// ID of related character to this costume.
        public var characterID: Int
        /// Name of asset bundle, used for combination of resource URLs.
        public var assetBundleName: String
        /// Name of super deformed resource bundle, used for combination of resource URLs.
        public var sdResourceName: String
        /// Localized description of costume.
        public var description: DoriAPI.LocalizedData<String>
        /// Localized "how to get" text of costume.
        public var howToGet: DoriAPI.LocalizedData<String>
        /// Localized published date of costume.
        public var publishedAt: DoriAPI.LocalizedData<Date> // String(JSON) -> Date(Swift)
        /// IDs of related cards to this costume.
        public var cards: [Int]
    }
}

extension DoriAPI.Costume.PreviewCostume {
    public init(_ full: DoriAPI.Costume.Costume) {
        self.init(
            id: full.id,
            characterID: full.characterID,
            assetBundleName: full.assetBundleName,
            description: full.description,
            publishedAt: full.publishedAt
        )
    }
}
extension DoriAPI.Costume.Costume {
    @inlinable
    public init?(id: Int) async {
        if let costume = await DoriAPI.Costume.detail(of: id) {
            self = costume
        } else {
            return nil
        }
    }
    
    @inlinable
    public init?(preview: DoriAPI.Costume.PreviewCostume) async {
        await self.init(id: preview.id)
    }
}
