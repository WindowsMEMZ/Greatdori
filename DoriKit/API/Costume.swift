//
//  Costume.swift
//  Greatdori
//
//  Created by Mark Chan on 7/22/25.
//

import SwiftUI
import Foundation
internal import SwiftyJSON

extension DoriAPI {
    public class Costume {
        private init() {}
        
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
            return nil
        }
        
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
                return .init(
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
            return nil
        }
    }
}
    
extension DoriAPI.Costume {
    public struct PreviewCostume: Identifiable {
        public var id: Int
        public var characterID: Int
        public var assetBundleName: String
        public var description: DoriAPI.LocalizedData<String>
        public var publishedAt: DoriAPI.LocalizedData<Date> // String(JSON) -> Date(Swift)
    }
    
    public struct Costume: Identifiable {
        public var id: Int
        public var characterID: Int
        public var assetBundleName: String
        public var sdResourceName: String
        public var description: DoriAPI.LocalizedData<String>
        public var howToGet: DoriAPI.LocalizedData<String>
        public var publishedAt: DoriAPI.LocalizedData<Date> // String(JSON) -> Date(Swift)
        public var cards: [Int]
    }
}

extension DoriAPI.Costume.Costume {
    @inlinable
    public init?(id: Int) async {
        if let costume = await DoriAPI.Costume.detail(of: id) {
            self = costume
        }
        return nil
    }
    
    @inlinable
    public init?(preview: DoriAPI.Costume.PreviewCostume) async {
        await self.init(id: preview.id)
    }
}
