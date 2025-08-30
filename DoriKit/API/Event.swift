//===---*- Greatdori! -*---------------------------------------------------===//
//
// Event.swift
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
    /// Request and fetch data about events in Bandori.
    public enum Event {
        /// Get all events in Bandori.
        ///
        /// The results have guaranteed sorting by ID.
        ///
        /// - Returns: Requested events, nil if failed to fetch data.
        public static func all() async -> [PreviewEvent]? {
            // Response example:
            // {
            //     "1": {
            //         "eventType": "story",
            //         "eventName": [
            //             "SAKURA＊BLOOMING PARTY!",
            //             "SAKURA＊BLOOMING PARTY!",
            //             "SAKURA＊BLOOMING PARTY!",
            //             "SAKURA＊BLOOMING PARTY!",
            //             "CHERRY＊BLOOMING PARTY!"
            //         ],
            //         "assetBundleName": "sakura",
            //         "bannerAssetBundleName": "banner-016",
            //         "startAt": [
            //             "1490335200000",
            //             ...
            //         ],
            //         "endAt": [
            //             "1490875200000",
            //             ...
            //         ],
            //         "attributes": [
            //             {
            //                 "attribute": "pure",
            //                 "percent": 20
            //             }
            //         ],
            //         "characters": [
            //             {
            //                 "characterId": 5,
            //                 "percent": 70
            //             },
            //             ...
            //         ],
            //         "members": [],
            //         "limitBreaks": [],
            //         "rewardCards": [
            //             105,
            //             101
            //         ]
            //     },
            //     ...
            // }
            let request = await requestJSON("https://bestdori.com/api/events/all.5.json")
            if case let .success(respJSON) = request {
                let task = Task.detached(priority: .userInitiated) {
                    var result = [PreviewEvent]()
                    for (key, value) in respJSON {
                        result.append(.init(
                            id: Int(key) ?? 0,
                            eventType: .init(rawValue: value["eventType"].stringValue) ?? .story,
                            eventName: .init(
                                jp: value["eventName"][0].string,
                                en: value["eventName"][1].string,
                                tw: value["eventName"][2].string,
                                cn: value["eventName"][3].string,
                                kr: value["eventName"][4].string
                            ),
                            assetBundleName: value["assetBundleName"].stringValue,
                            bannerAssetBundleName: value["bannerAssetBundleName"].stringValue,
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
                            ),
                            attributes: value["attributes"].map {
                                EventAttribute(
                                    eventID: $0.1["eventId"].int,
                                    attribute: .init(rawValue: $0.1["attribute"].stringValue) ?? .pure,
                                    percent: $0.1["percent"].intValue
                                )
                            },
                            characters: value["characters"].map {
                                EventCharacter(
                                    eventID: $0.1["eventId"].int,
                                    characterID: $0.1["characterId"].intValue,
                                    percent: $0.1["percent"].intValue,
                                    seq: $0.1["seq"].int
                                )
                            },
                            eventAttributeAndCharacterBonus: value["eventAttributeAndCharacterBonus"]["eventId"].int != nil ? .init(
                                eventID: value["eventAttributeAndCharacterBonus"]["eventId"].intValue,
                                pointPercent: value["eventAttributeAndCharacterBonus"]["pointPercent"].intValue,
                                parameterPercent: value["eventAttributeAndCharacterBonus"]["parameterPercent"].intValue
                            ) : nil,
                            eventCharacterParameterBonus: value["eventCharacterParameterBonus"]["performance"].int != nil ? .init(
                                performance: value["eventCharacterParameterBonus"]["performance"].intValue,
                                technique: value["eventCharacterParameterBonus"]["technique"].intValue,
                                visual: value["eventCharacterParameterBonus"]["visual"].intValue
                            ) : nil,
                            members: value["members"].map {
                                EventMember(
                                    eventID: $0.1["eventId"].int,
                                    situationID: $0.1["situationId"].intValue,
                                    percent: $0.1["percent"].intValue,
                                    seq: $0.1["seq"].int
                                )
                            },
                            limitBreaks: value["limitBreaks"].map {
                                EventLimitBreak(
                                    rarity: $0.1["rarity"].intValue,
                                    rank: $0.1["rank"].intValue,
                                    percent: $0.1["percent"].doubleValue
                                )
                            },
                            rewardCards: value["rewardCards"].map { $0.1.intValue }
                        ))
                    }
                    return result.sorted { $0.id < $1.id }
                }
                return await task.value
            }
            return nil
        }
        
        /// Get detail of an event in Bandori.
        /// - Parameter id: ID of target event.
        /// - Returns: Detail data of requested event, nil if failed to fetch.
        public static func detail(of id: Int) async -> Event? {
            // Response example:
            // {
            //     "eventType": "mission_live",
            //     "eventName": [
            //         "雨上がり、瞳に映る空は",
            //         "After the Rain, What Sky Reflected in Her Eyes",
            //         null,
            //         null,
            //         null
            //     ],
            //     "assetBundleName": "ammeagari_sora",
            //     "bannerAssetBundleName": "banner_event297",
            //     "startAt": [
            //         "1749535200000",
            //         ...
            //     ],
            //     "endAt": [
            //         "1750247999000",
            //         ...
            //     ],
            //     "enableFlag": [ // This attribute is not provided in Swift API. How does it works?
            //         null,
            //         ...
            //     ],
            //     "publicStartAt": [
            //         "1749535200000",
            //         ...
            //     ],
            //     "publicEndAt": [
            //         "1750399199000",
            //         ...
            //     ],
            //     "distributionStartAt": [
            //         "1750298400000",
            //         ...
            //     ],
            //     "distributionEndAt": [
            //         "1751554800000",
            //         ...
            //     ],
            //     "bgmAssetBundleName": "sound/scenario/bgm/63_longing",
            //     "bgmFileName": "63_longing",
            //     "aggregateEndAt": [
            //         "1750249799000",
            //         ...
            //     ],
            //     "exchangeEndAt": [
            //         "1751025599000",
            //         ...
            //     ],
            //     "pointRewards": [
            //         [
            //             {
            //                 "point": "1000",
            //                 "rewardType": "star",
            //                 "rewardQuantity": 50
            //             },
            //             ...
            //         ],
            //         ...
            //     ],
            //     "rankingRewards": [
            //         [
            //             {
            //                 "fromRank": 1,
            //                 "toRank": 1,
            //                 "rewardType": "degree",
            //                 "rewardId": 8025,
            //                 "rewardQuantity": 1
            //             },
            //             ...
            //         ],
            //         ...
            //     ],
            //     "attributes": [
            //         {
            //             "attribute": "powerful",
            //             "percent": 10
            //         }
            //     ],
            //     "characters": [
            //         {
            //             "characterId": 36,
            //             "percent": 20
            //         },
            //         ...
            //     ],
            //     "eventAttributeAndCharacterBonus": {
            //         "pointPercent": 20,
            //         "parameterPercent": 0
            //     },
            //     "members": [
            //         {
            //             "eventId": 297,
            //             "situationId": 2231,
            //             "percent": 20,
            //             "seq": 1
            //         },
            //         ...
            //     ],
            //     "limitBreaks": [
            //         {
            //             "rarity": 1,
            //             "rank": 0,
            //             "percent": 0
            //         },
            //         ...
            //     ],
            //     "stories": [
            //         {
            //             "scenarioId": "event297-01",
            //             "coverImage": "297_0",
            //             "backgroundImage": "0",
            //             "releasePt": "0",
            //             "rewards": [
            //                 {
            //                     "rewardType": "item",
            //                     "rewardId": 13,
            //                     "rewardQuantity": 1
            //                 },
            //                 ...
            //             ],
            //             "caption": [
            //                 "オープニング",
            //                 ...
            //             ],
            //             "title": [
            //                 "幕が開いて",
            //                 ...
            //             ],
            //             "synopsis": [
            //                 "Ave Mujicaのライブを観に行った\n愛音とそよ。そこにいたのは――",
            //                 ...
            //             ],
            //             "releaseConditions": [
            //                 "オープニングシナリオ",
            //                 ...
            //             ]
            //         },
            //         ...
            //     ],
            //     "rewardCards": [
            //         2235,
            //         2234
            //     ]
            // }
            let request = await requestJSON("https://bestdori.com/api/events/\(id).json")
            if case let .success(respJSON) = request {
                let task = Task.detached(priority: .userInitiated) {
                    // We break up expressions because of:
                    // The compiler is unable to type-check this expression in reasonable time;
                    // try breaking up the expression into distinct sub-expressions 😇
                    let pointRewards = DoriAPI.LocalizedData(
                        jp: respJSON["pointRewards"][0].map {
                            Event.PointReward(
                                point: Int($0.1["point"].stringValue) ?? 0,
                                reward: .init(
                                    itemID: $0.1["rewardId"].int,
                                    type: .init(rawValue: $0.1["rewardType"].stringValue) ?? .item,
                                    quantity: $0.1["rewardQuantity"].intValue
                                )
                            )
                        },
                        en: respJSON["pointRewards"][1].map {
                            Event.PointReward(
                                point: Int($0.1["point"].stringValue) ?? 0,
                                reward: .init(
                                    itemID: $0.1["rewardId"].int,
                                    type: .init(rawValue: $0.1["rewardType"].stringValue) ?? .item,
                                    quantity: $0.1["rewardQuantity"].intValue
                                )
                            )
                        },
                        tw: respJSON["pointRewards"][2].map {
                            Event.PointReward(
                                point: Int($0.1["point"].stringValue) ?? 0,
                                reward: .init(
                                    itemID: $0.1["rewardId"].int,
                                    type: .init(rawValue: $0.1["rewardType"].stringValue) ?? .item,
                                    quantity: $0.1["rewardQuantity"].intValue
                                )
                            )
                        },
                        cn: respJSON["pointRewards"][3].map {
                            Event.PointReward(
                                point: Int($0.1["point"].stringValue) ?? 0,
                                reward: .init(
                                    itemID: $0.1["rewardId"].int,
                                    type: .init(rawValue: $0.1["rewardType"].stringValue) ?? .item,
                                    quantity: $0.1["rewardQuantity"].intValue
                                )
                            )
                        },
                        kr: respJSON["pointRewards"][4].map {
                            Event.PointReward(
                                point: Int($0.1["point"].stringValue) ?? 0,
                                reward: .init(
                                    itemID: $0.1["rewardId"].int,
                                    type: .init(rawValue: $0.1["rewardType"].stringValue) ?? .item,
                                    quantity: $0.1["rewardQuantity"].intValue
                                )
                            )
                        }
                    )
                    let rankingRewards = DoriAPI.LocalizedData(
                        jp: respJSON["rankingRewards"][0].map {
                            Event.RankingReward(
                                rankRange: $0.1["fromRank"].intValue...$0.1["toRank"].intValue,
                                reward: .init(
                                    itemID: $0.1["rewardId"].int,
                                    type: .init(rawValue: $0.1["rewardType"].stringValue) ?? .item,
                                    quantity: $0.1["rewardQuantity"].intValue
                                )
                            )
                        },
                        en: respJSON["rankingRewards"][1].map {
                            Event.RankingReward(
                                rankRange: $0.1["fromRank"].intValue...$0.1["toRank"].intValue,
                                reward: .init(
                                    itemID: $0.1["rewardId"].int,
                                    type: .init(rawValue: $0.1["rewardType"].stringValue) ?? .item,
                                    quantity: $0.1["rewardQuantity"].intValue
                                )
                            )
                        },
                        tw: respJSON["rankingRewards"][2].map {
                            Event.RankingReward(
                                rankRange: $0.1["fromRank"].intValue...$0.1["toRank"].intValue,
                                reward: .init(
                                    itemID: $0.1["rewardId"].int,
                                    type: .init(rawValue: $0.1["rewardType"].stringValue) ?? .item,
                                    quantity: $0.1["rewardQuantity"].intValue
                                )
                            )
                        },
                        cn: respJSON["rankingRewards"][3].map {
                            Event.RankingReward(
                                rankRange: $0.1["fromRank"].intValue...$0.1["toRank"].intValue,
                                reward: .init(
                                    itemID: $0.1["rewardId"].int,
                                    type: .init(rawValue: $0.1["rewardType"].stringValue) ?? .item,
                                    quantity: $0.1["rewardQuantity"].intValue
                                )
                            )
                        },
                        kr: respJSON["rankingRewards"][4].map {
                            Event.RankingReward(
                                rankRange: $0.1["fromRank"].intValue...$0.1["toRank"].intValue,
                                reward: .init(
                                    itemID: $0.1["rewardId"].int,
                                    type: .init(rawValue: $0.1["rewardType"].stringValue) ?? .item,
                                    quantity: $0.1["rewardQuantity"].intValue
                                )
                            )
                        },
                    )
                    return Event(
                        id: id,
                        eventType: .init(rawValue: respJSON["eventType"].stringValue) ?? .story,
                        eventName: .init(
                            jp: respJSON["eventName"][0].string,
                            en: respJSON["eventName"][1].string,
                            tw: respJSON["eventName"][2].string,
                            cn: respJSON["eventName"][3].string,
                            kr: respJSON["eventName"][4].string
                        ),
                        assetBundleName: respJSON["assetBundleName"].stringValue,
                        bannerAssetBundleName: respJSON["bannerAssetBundleName"].stringValue,
                        startAt: .init(
                            jp: respJSON["startAt"][0].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["startAt"][0].stringValue.dropLast(3))!)) : nil,
                            en: respJSON["startAt"][1].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["startAt"][1].stringValue.dropLast(3))!)) : nil,
                            tw: respJSON["startAt"][2].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["startAt"][2].stringValue.dropLast(3))!)) : nil,
                            cn: respJSON["startAt"][3].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["startAt"][3].stringValue.dropLast(3))!)) : nil,
                            kr: respJSON["startAt"][4].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["startAt"][4].stringValue.dropLast(3))!)) : nil
                        ),
                        endAt: .init(
                            jp: respJSON["endAt"][0].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["endAt"][0].stringValue.dropLast(3))!)) : nil,
                            en: respJSON["endAt"][1].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["endAt"][1].stringValue.dropLast(3))!)) : nil,
                            tw: respJSON["endAt"][2].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["endAt"][2].stringValue.dropLast(3))!)) : nil,
                            cn: respJSON["endAt"][3].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["endAt"][3].stringValue.dropLast(3))!)) : nil,
                            kr: respJSON["endAt"][4].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["endAt"][4].stringValue.dropLast(3))!)) : nil
                        ),
                        publicStartAt: .init(
                            jp: respJSON["publicStartAt"][0].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["publicStartAt"][0].stringValue.dropLast(3))!)) : nil,
                            en: respJSON["publicStartAt"][1].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["publicStartAt"][1].stringValue.dropLast(3))!)) : nil,
                            tw: respJSON["publicStartAt"][2].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["publicStartAt"][2].stringValue.dropLast(3))!)) : nil,
                            cn: respJSON["publicStartAt"][3].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["publicStartAt"][3].stringValue.dropLast(3))!)) : nil,
                            kr: respJSON["publicStartAt"][4].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["publicStartAt"][4].stringValue.dropLast(3))!)) : nil
                        ),
                        publicEndAt: .init(
                            jp: respJSON["publicEndAt"][0].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["publicEndAt"][0].stringValue.dropLast(3))!)) : nil,
                            en: respJSON["publicEndAt"][1].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["publicEndAt"][1].stringValue.dropLast(3))!)) : nil,
                            tw: respJSON["publicEndAt"][2].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["publicEndAt"][2].stringValue.dropLast(3))!)) : nil,
                            cn: respJSON["publicEndAt"][3].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["publicEndAt"][3].stringValue.dropLast(3))!)) : nil,
                            kr: respJSON["publicEndAt"][4].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["publicEndAt"][4].stringValue.dropLast(3))!)) : nil
                        ),
                        distributionStartAt: .init(
                            jp: respJSON["distributionStartAt"][0].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["distributionStartAt"][0].stringValue.dropLast(3))!)) : nil,
                            en: respJSON["distributionStartAt"][1].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["distributionStartAt"][1].stringValue.dropLast(3))!)) : nil,
                            tw: respJSON["distributionStartAt"][2].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["distributionStartAt"][2].stringValue.dropLast(3))!)) : nil,
                            cn: respJSON["distributionStartAt"][3].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["distributionStartAt"][3].stringValue.dropLast(3))!)) : nil,
                            kr: respJSON["distributionStartAt"][4].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["distributionStartAt"][4].stringValue.dropLast(3))!)) : nil
                        ),
                        distributionEndAt: .init(
                            jp: respJSON["distributionEndAt"][0].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["distributionEndAt"][0].stringValue.dropLast(3))!)) : nil,
                            en: respJSON["distributionEndAt"][1].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["distributionEndAt"][1].stringValue.dropLast(3))!)) : nil,
                            tw: respJSON["distributionEndAt"][2].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["distributionEndAt"][2].stringValue.dropLast(3))!)) : nil,
                            cn: respJSON["distributionEndAt"][3].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["distributionEndAt"][3].stringValue.dropLast(3))!)) : nil,
                            kr: respJSON["distributionEndAt"][4].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["distributionEndAt"][4].stringValue.dropLast(3))!)) : nil
                        ),
                        bgmAssetBundleName: respJSON["bgmAssetBundleName"].stringValue,
                        bgmFileName: respJSON["bgmFileName"].stringValue,
                        aggregateEndAt: .init(
                            jp: respJSON["aggregateEndAt"][0].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["aggregateEndAt"][0].stringValue.dropLast(3))!)) : nil,
                            en: respJSON["aggregateEndAt"][1].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["aggregateEndAt"][1].stringValue.dropLast(3))!)) : nil,
                            tw: respJSON["aggregateEndAt"][2].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["aggregateEndAt"][2].stringValue.dropLast(3))!)) : nil,
                            cn: respJSON["aggregateEndAt"][3].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["aggregateEndAt"][3].stringValue.dropLast(3))!)) : nil,
                            kr: respJSON["aggregateEndAt"][4].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["aggregateEndAt"][4].stringValue.dropLast(3))!)) : nil
                        ),
                        exchangeEndAt: .init(
                            jp: respJSON["exchangeEndAt"][0].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["exchangeEndAt"][0].stringValue.dropLast(3))!)) : nil,
                            en: respJSON["exchangeEndAt"][1].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["exchangeEndAt"][1].stringValue.dropLast(3))!)) : nil,
                            tw: respJSON["exchangeEndAt"][2].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["exchangeEndAt"][2].stringValue.dropLast(3))!)) : nil,
                            cn: respJSON["exchangeEndAt"][3].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["exchangeEndAt"][3].stringValue.dropLast(3))!)) : nil,
                            kr: respJSON["exchangeEndAt"][4].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["exchangeEndAt"][4].stringValue.dropLast(3))!)) : nil
                        ),
                        pointRewards: pointRewards,
                        rankingRewards: rankingRewards,
                        attributes: respJSON["attributes"].map {
                            EventAttribute(
                                eventID: $0.1["eventId"].int,
                                attribute: .init(rawValue: $0.1["attribute"].stringValue) ?? .pure,
                                percent: $0.1["percent"].intValue
                            )
                        },
                        characters: respJSON["characters"].map {
                            EventCharacter(
                                eventID: $0.1["eventId"].int,
                                characterID: $0.1["characterId"].intValue,
                                percent: $0.1["percent"].intValue,
                                seq: $0.1["seq"].int
                            )
                        },
                        eventAttributeAndCharacterBonus: respJSON["eventAttributeAndCharacterBonus"]["eventId"].int != nil ? .init(
                            eventID: respJSON["eventAttributeAndCharacterBonus"]["eventId"].intValue,
                            pointPercent: respJSON["eventAttributeAndCharacterBonus"]["pointPercent"].intValue,
                            parameterPercent: respJSON["eventAttributeAndCharacterBonus"]["parameterPercent"].intValue
                        ) : nil,
                        eventCharacterParameterBonus: respJSON["eventCharacterParameterBonus"]["performance"].int != nil ? .init(
                            performance: respJSON["eventCharacterParameterBonus"]["performance"].intValue,
                            technique: respJSON["eventCharacterParameterBonus"]["technique"].intValue,
                            visual: respJSON["eventCharacterParameterBonus"]["visual"].intValue
                        ) : nil,
                        members: respJSON["members"].map {
                            EventMember(
                                eventID: $0.1["eventId"].int,
                                situationID: $0.1["situationId"].intValue,
                                percent: $0.1["percent"].intValue,
                                seq: $0.1["seq"].int
                            )
                        },
                        limitBreaks: respJSON["limitBreaks"].map {
                            EventLimitBreak(
                                rarity: $0.1["rarity"].intValue,
                                rank: $0.1["rank"].intValue,
                                percent: $0.1["percent"].doubleValue
                            )
                        },
                        stories: respJSON["stories"].map {
                            Event.Story(
                                scenarioID: $0.1["scenarioId"].stringValue,
                                coverImage: $0.1["coverImage"].stringValue,
                                backgroundImage: $0.1["backgroundImage"].stringValue,
                                releasePt: Int($0.1["releasePt"].stringValue) ?? 0,
                                rewards: $0.1["rewards"].map {
                                    .init(
                                        itemID: $0.1["rewardId"].int,
                                        type: .init(rawValue: $0.1["rewardType"].stringValue) ?? .item,
                                        quantity: $0.1["rewardQuantity"].intValue
                                    )
                                },
                                caption: .init(
                                    jp: $0.1["caption"][0].string,
                                    en: $0.1["caption"][1].string,
                                    tw: $0.1["caption"][2].string,
                                    cn: $0.1["caption"][3].string,
                                    kr: $0.1["caption"][4].string
                                ),
                                title: .init(
                                    jp: $0.1["title"][0].string,
                                    en: $0.1["title"][1].string,
                                    tw: $0.1["title"][2].string,
                                    cn: $0.1["title"][3].string,
                                    kr: $0.1["title"][4].string
                                ),
                                synopsis: .init(
                                    jp: $0.1["synopsis"][0].string,
                                    en: $0.1["synopsis"][1].string,
                                    tw: $0.1["synopsis"][2].string,
                                    cn: $0.1["synopsis"][3].string,
                                    kr: $0.1["synopsis"][4].string
                                ),
                                releaseConditions: .init(
                                    jp: $0.1["releaseConditions"][0].string,
                                    en: $0.1["releaseConditions"][1].string,
                                    tw: $0.1["releaseConditions"][2].string,
                                    cn: $0.1["releaseConditions"][3].string,
                                    kr: $0.1["releaseConditions"][4].string
                                )
                            )
                        },
                        rewardCards: respJSON["rewardCards"].map { $0.1.intValue }
                    )
                }
                return await task.value
            }
            return nil
        }
        
        /// Get top 10 data of an event in Bandori.
        /// - Parameters:
        ///   - id: ID of the event.
        ///   - locale: Locale for event data.
        ///   - interval: Interval of each data, the default value is 0.
        /// - Returns: Top 10 data of requested event, nil if failed to fetch.
        public static func topData(of id: Int, in locale: Locale, interval: TimeInterval = 0) async -> TopData? {
            // Response example:
            // {
            //     "points": [
            //         {
            //             "time": 1753600364600,
            //             "uid": 1000000001,
            //             "value": 175490
            //         },
            //         ...
            //     ],
            //     "users": [
            //         {
            //             "uid": 1000000001,
            //             "name": "工作人员一号",
            //             "introduction": "觉悟～fighting",
            //             "rank": 130,
            //             "sid": 2095,
            //             "strained": 1,
            //             "degrees": [
            //                 20061,
            //                 20077
            //             ]
            //         },
            //         ...
            //     ]
            // }
            let serverID = switch locale {
            case .jp: 0
            case .en: 1
            case .tw: 2
            case .cn: 3
            case .kr: 4
            }
            let request = await requestJSON("https://bestdori.com/api/eventtop/data?server=\(serverID)&event=\(id)&mid=0&interval=\(interval)")
            if case let .success(respJSON) = request {
                let task = Task.detached(priority: .userInitiated) {
                    return TopData(
                        points: respJSON["points"].map {
                            .init(
                                time: Date(timeIntervalSince1970: $0.1["time"].doubleValue / 1000),
                                uid: $0.1["uid"].intValue,
                                value: $0.1["value"].intValue
                            )
                        },
                        users: respJSON["users"].map {
                            .init(
                                uid: $0.1["uid"].intValue,
                                name: $0.1["name"].stringValue,
                                introduction: $0.1["introduction"].stringValue,
                                rank: $0.1["rank"].intValue,
                                sid: $0.1["sid"].intValue,
                                strained: $0.1["strained"].intValue != 0,
                                degrees: $0.1["degrees"].map { $0.1.intValue }
                            )
                        }
                    )
                }
                return await task.value
            }
            return nil
        }
        
        /// Get rates information of event tracker.
        /// - Returns: Rates information of event tracker.
        public static func trackerRates() async -> [TrackerRate]? {
            // Response example:
            // [{
            //     "type": "story",
            //     "server": 0,
            //     "tier": 100,
            //     "rate": 0.1864557607881584
            // },...]
            let request = await requestJSON("https://bestdori.com/api/tracker/rates.json")
            if case let .success(respJSON) = request {
                let task = Task.detached(priority: .userInitiated) {
                    return respJSON.map {
                        let locale = switch $0.1["server"].intValue {
                        case 0: Locale.jp
                        case 1: Locale.en
                        case 2: Locale.tw
                        case 3: Locale.cn
                        case 4: Locale.kr
                        default: Locale.jp
                        }
                        return TrackerRate(
                            type: .init(rawValue: $0.1["type"].stringValue) ?? .story,
                            server: locale,
                            tier: $0.1["tier"].intValue,
                            rate: $0.1["rate"].doubleValue
                        )
                    }
                }
                return await task.value
            }
            return nil
        }
        
        /// Get cutoff data of event tracker.
        /// - Parameters:
        ///   - id: ID of event.
        ///   - locale: Locale for event data.
        ///   - tier: Tier. Possible values are 20, 30, 40, 50, 100, 200, 300, 400, 500, 1000, 2000, 3000, 4000, 5000, 10000, 20000 and 30000.
        /// - Returns: Cutoff data of requested event, nil if failed to fetch.
        public static func trackerData(of id: Int, in locale: Locale, tier: Int) async -> TrackerData? {
            // Response example:
            // {
            //     "result": true, // We emit this field in Swift API and return nil if it's false.
            //     "cutoffs": [
            //         {
            //             "time": 1753600511000,
            //             "ep": 51280
            //         },
            //         ...
            //     }
            // }
            let serverID = switch locale {
            case .jp: 0
            case .en: 1
            case .tw: 2
            case .cn: 3
            case .kr: 4
            }
            let request = await requestJSON("https://bestdori.com/api/tracker/data?server=\(serverID)&event=\(id)&tier=\(tier)")
            if case let .success(respJSON) = request {
                let task = Task.detached(priority: .userInitiated) { () async -> TrackerData? in
                    guard respJSON["result"].boolValue else { return nil }
                    return TrackerData(
                        cutoffs: respJSON["cutoffs"].map {
                            .init(
                                time: Date(timeIntervalSince1970: $0.1["time"].doubleValue / 1000),
                                ep: $0.1["ep"].intValue
                            )
                        }
                    )
                }
                return await task.value
            }
            return nil
        }
        
        /// Get all events with stories in Bandori.
        /// - Returns: Requested events with stories, nil if failed to fetch.
        public static func allStories() async -> [EventStory]? {
            let request = await requestJSON("https://bestdori.com/api/events/all.stories.json")
            if case let .success(respJSON) = request {
                let task = Task.detached(priority: .userInitiated) {
                    var result = [EventStory]()
                    for (key, value) in respJSON {
                        result.append(.init(
                            id: Int(key) ?? 0,
                            eventName: .init(
                                jp: value["eventName"][0].string,
                                en: value["eventName"][1].string,
                                tw: value["eventName"][2].string,
                                cn: value["eventName"][3].string,
                                kr: value["eventName"][4].string
                            ),
                            stories: value["stories"].map {
                                .init(
                                    scenarioID: $0.1["scenarioId"].stringValue,
                                    caption: .init(
                                        jp: $0.1["caption"][0].string,
                                        en: $0.1["caption"][1].string,
                                        tw: $0.1["caption"][2].string,
                                        cn: $0.1["caption"][3].string,
                                        kr: $0.1["caption"][4].string
                                    ),
                                    title: .init(
                                        jp: $0.1["title"][0].string,
                                        en: $0.1["title"][1].string,
                                        tw: $0.1["title"][2].string,
                                        cn: $0.1["title"][3].string,
                                        kr: $0.1["title"][4].string
                                    ),
                                    synopsis: .init(
                                        jp: $0.1["synopsis"][0].string,
                                        en: $0.1["synopsis"][1].string,
                                        tw: $0.1["synopsis"][2].string,
                                        cn: $0.1["synopsis"][3].string,
                                        kr: $0.1["synopsis"][4].string
                                    )
                                )
                            }
                        ))
                    }
                    return result.sorted { $0.id < $1.id }
                }
                return await task.value
            }
            return nil
        }
    }
}

extension DoriAPI.Event {
    /// Represent simplified data of an event.
    public struct PreviewEvent: Sendable, Identifiable, Hashable, DoriCache.Cacheable, DoriFrontend.Filterable {
        /// A unique ID of event.
        public var id: Int
        /// Type of event.
        public var eventType: EventType
        /// Localized name of event.
        public var eventName: DoriAPI.LocalizedData<String>
        /// Name of resource bundle, used for combination of resource URLs.
        public var assetBundleName: String
        /// Name of banner resource bundle, used for combination of resource URLs.
        public var bannerAssetBundleName: String
        /// Localized start date of event.
        public var startAt: DoriAPI.LocalizedData<Date> // String(JSON) -> Date(Swift)
        /// Localized end date of event.
        public var endAt: DoriAPI.LocalizedData<Date> // String(JSON) -> Date(Swift)
        /// Attributes related to this event, with bonus percentage.
        public var attributes: [EventAttribute]
        /// Characters related to this event, with bonus percentage.
        public var characters: [EventCharacter]
        public var eventAttributeAndCharacterBonus: EventAttributeAndCharacterBonus?
        public var eventCharacterParameterBonus: DoriAPI.Card.Stat?
        /// Members related to this event, with bonus percentage.
        ///
        /// A *member* related to event is a card with bonus during the event.
        public var members: [EventMember]
        public var limitBreaks: [EventLimitBreak]
        /// IDs of cards that can be gotten by participating this event.
        public var rewardCards: [Int]
    }
    
    /// Represent detailed data of an event.
    public struct Event: Sendable, Identifiable, Hashable, DoriCache.Cacheable {
        /// A unique ID of event.
        public var id: Int
        /// Type of event.
        public var eventType: EventType
        /// Localized name of event.
        public var eventName: DoriAPI.LocalizedData<String>
        /// Name of resource bundle, used for combination of resource URLs.
        public var assetBundleName: String
        /// Name of banner resource bundle, used for combination of resource URLs.
        public var bannerAssetBundleName: String
        /// Localized start date of event.
        public var startAt: DoriAPI.LocalizedData<Date> // String(JSON) -> Date(Swift)
        /// Localized end date of event.
        public var endAt: DoriAPI.LocalizedData<Date> // String(JSON) -> Date(Swift)
        public var publicStartAt: DoriAPI.LocalizedData<Date> // String(JSON) -> Date(Swift)
        public var publicEndAt: DoriAPI.LocalizedData<Date> // String(JSON) -> Date(Swift)
        public var distributionStartAt: DoriAPI.LocalizedData<Date> // String(JSON) -> Date(Swift)
        public var distributionEndAt: DoriAPI.LocalizedData<Date> // String(JSON) -> Date(Swift)
        /// Name of BGM resource bundle, used for combination of resource URLs.
        public var bgmAssetBundleName: String
        /// Name of BGM file, used for combination of resource URLs.
        public var bgmFileName: String
        public var aggregateEndAt: DoriAPI.LocalizedData<Date> // String(JSON) -> Date(Swift)
        public var exchangeEndAt: DoriAPI.LocalizedData<Date> // String(JSON) -> Date(Swift)
        public var pointRewards: DoriAPI.LocalizedData<[PointReward]>
        public var rankingRewards: DoriAPI.LocalizedData<[RankingReward]>
        /// Attributes related to this event, with bonus percentage.
        public var attributes: [EventAttribute]
        /// Characters related to this event, with bonus percentage.
        public var characters: [EventCharacter]
        public var eventAttributeAndCharacterBonus: EventAttributeAndCharacterBonus?
        public var eventCharacterParameterBonus: DoriAPI.Card.Stat?
        /// Members related to this event, with bonus percentage.
        ///
        /// A *member* related to event is a card with bonus during the event.
        public var members: [EventMember]
        public var limitBreaks: [EventLimitBreak]
        public var stories: [Story]
        /// IDs of cards that can be gotten by participating this event.
        public var rewardCards: [Int]
        
        internal init(
            id: Int,
            eventType: EventType,
            eventName: DoriAPI.LocalizedData<String>,
            assetBundleName: String,
            bannerAssetBundleName: String,
            startAt: DoriAPI.LocalizedData<Date>,
            endAt: DoriAPI.LocalizedData<Date>,
            publicStartAt: DoriAPI.LocalizedData<Date>,
            publicEndAt: DoriAPI.LocalizedData<Date>,
            distributionStartAt: DoriAPI.LocalizedData<Date>,
            distributionEndAt: DoriAPI.LocalizedData<Date>,
            bgmAssetBundleName: String,
            bgmFileName: String,
            aggregateEndAt: DoriAPI.LocalizedData<Date>,
            exchangeEndAt: DoriAPI.LocalizedData<Date>,
            pointRewards: DoriAPI.LocalizedData<[PointReward]>,
            rankingRewards: DoriAPI.LocalizedData<[RankingReward]>,
            attributes: [EventAttribute],
            characters: [EventCharacter],
            eventAttributeAndCharacterBonus: EventAttributeAndCharacterBonus?,
            eventCharacterParameterBonus: DoriAPI.Card.Stat?,
            members: [EventMember],
            limitBreaks: [EventLimitBreak],
            stories: [Story],
            rewardCards: [Int]
        ) {
            self.id = id
            self.eventType = eventType
            self.eventName = eventName
            self.assetBundleName = assetBundleName
            self.bannerAssetBundleName = bannerAssetBundleName
            self.startAt = startAt
            self.endAt = endAt
            self.publicStartAt = publicStartAt
            self.publicEndAt = publicEndAt
            self.distributionStartAt = distributionStartAt
            self.distributionEndAt = distributionEndAt
            self.bgmAssetBundleName = bgmAssetBundleName
            self.bgmFileName = bgmFileName
            self.aggregateEndAt = aggregateEndAt
            self.exchangeEndAt = exchangeEndAt
            self.pointRewards = pointRewards
            self.rankingRewards = rankingRewards
            self.attributes = attributes
            self.characters = characters
            self.eventAttributeAndCharacterBonus = eventAttributeAndCharacterBonus
            self.eventCharacterParameterBonus = eventCharacterParameterBonus
            self.members = members
            self.limitBreaks = limitBreaks
            self.stories = stories
            self.rewardCards = rewardCards
        }
        
        public struct PointReward: Sendable, Hashable, DoriCache.Cacheable {
            public var point: Int
            public var reward: DoriAPI.Item
        }
        public struct RankingReward: Sendable, Hashable, DoriCache.Cacheable {
            public var rankRange: ClosedRange<Int> // keys{fromRank, toRank}(JSON) -> ClosedRange(Swift)
            public var reward: DoriAPI.Item
        }
        
        public struct Story: Sendable, Hashable, DoriCache.Cacheable {
            public var scenarioID: String
            public var coverImage: String
            public var backgroundImage: String
            public var releasePt: Int
            public var rewards: [DoriAPI.Item]
            public var caption: DoriAPI.LocalizedData<String>
            public var title: DoriAPI.LocalizedData<String>
            public var synopsis: DoriAPI.LocalizedData<String>
            public var releaseConditions: DoriAPI.LocalizedData<String>
        }
    }
    
    /// Represent top 10 data of an event.
    public struct TopData: Sendable, Hashable, DoriCache.Cacheable {
        public var points: [Point]
        public var users: [User]
        
        public struct Point: Sendable, Hashable, DoriCache.Cacheable {
            public var time: Date
            public var uid: Int
            public var value: Int
        }
        public struct User: Sendable, Hashable, DoriCache.Cacheable {
            public var uid: Int
            public var name: String
            public var introduction: String
            public var rank: Int
            public var sid: Int
            public var strained: Bool // Int(JSON) -> Bool(Swift)
            public var degrees: [Int]
        }
    }
    
    public struct TrackerRate: Sendable, Hashable, DoriCache.Cacheable {
        public var type: EventType
        public var server: DoriAPI.Locale
        public var tier: Int
        public var rate: Double
    }
    /// Represent cutoff data of an event.
    public struct TrackerData: Sendable, Hashable, DoriCache.Cacheable {
        public var cutoffs: [Cutoff]
        
        public struct Cutoff: Sendable, Hashable, DoriCache.Cacheable {
            public var time: Date
            public var ep: Int
        }
    }
    
    /// Represent type of an event.
    public enum EventType: String, Sendable, CaseIterable, Hashable, DoriCache.Cacheable {
        case story
        case challenge
        case versus
        case liveTry = "live_try"
        case missionLive = "mission_live"
        case festival
        case medley
    }
    
    /// Represent an attribute with bonus related to an event.
    public struct EventAttribute: Sendable, Hashable, DoriCache.Cacheable {
        /// Related event ID.
        public var eventID: Int?
        /// Attribute.
        public var attribute: DoriAPI.Attribute
        /// Percentage of bonus.
        public var percent: Int
        
        internal init(eventID: Int?, attribute: DoriAPI.Attribute, percent: Int) {
            self.eventID = eventID
            self.attribute = attribute
            self.percent = percent
        }
    }
    /// Represent a character with bonus related to an event.
    public struct EventCharacter: Sendable, Hashable, DoriCache.Cacheable {
        /// Related event ID.
        public var eventID: Int?
        /// Character ID.
        public var characterID: Int
        /// Percentage of bonus.
        public var percent: Int
        public var seq: Int?
        
        internal init(eventID: Int?, characterID: Int, percent: Int, seq: Int?) {
            self.eventID = eventID
            self.characterID = characterID
            self.percent = percent
            self.seq = seq
        }
    }
    /// Represent a member with bonus related to an event.
    ///
    /// A *member* related to event is a card with bonus during the event.
    public struct EventMember: Sendable, Hashable, DoriCache.Cacheable {
        /// Related event ID.
        public var eventID: Int?
        /// Card ID.
        public var situationID: Int
        /// Percentage of bonus.
        public var percent: Int
        public var seq: Int?
        
        internal init(eventID: Int?, situationID: Int, percent: Int, seq: Int?) {
            self.eventID = eventID
            self.situationID = situationID
            self.percent = percent
            self.seq = seq
        }
    }
    public struct EventLimitBreak: Sendable, Hashable, DoriCache.Cacheable {
        public var rarity: Int
        public var rank: Int
        public var percent: Double
    }
    public struct EventAttributeAndCharacterBonus: Sendable, Hashable, DoriCache.Cacheable {
        public var eventID: Int
        public var pointPercent: Int
        public var parameterPercent: Int
    }
    
    public struct EventStory: Sendable, Identifiable, Hashable, DoriCache.Cacheable {
        public var id: Int
        public var eventName: DoriAPI.LocalizedData<String>
        public var stories: [DoriAPI.Story]
    }
}

extension DoriAPI.Event.PreviewEvent {
    public init(_ full: DoriAPI.Event.Event) {
        self.init(
            id: full.id,
            eventType: full.eventType,
            eventName: full.eventName,
            assetBundleName: full.assetBundleName,
            bannerAssetBundleName: full.bannerAssetBundleName,
            startAt: full.startAt,
            endAt: full.endAt,
            attributes: full.attributes,
            characters: full.characters,
            members: full.members,
            limitBreaks: full.limitBreaks,
            rewardCards: full.rewardCards
        )
    }
}
extension DoriAPI.Event.Event {
    @inlinable
    public init?(id: Int) async {
        if let event = await DoriAPI.Event.detail(of: id) {
            self = event
        } else {
            return nil
        }
    }
    
    @inlinable
    public init?(preview: DoriAPI.Event.PreviewEvent) async {
        await self.init(id: preview.id)
    }
}
