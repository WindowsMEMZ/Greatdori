//===---*- Greatdori! -*---------------------------------------------------===//
//
// LoginCampaign.swift
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
internal import SwiftyJSON

extension DoriAPI {
    /// Request and fetch data about login campaigns in Bandori.
    public enum LoginCampaign {
        /// Get all login campaigns in Bandori.
        ///
        /// The results have guaranteed sorting by ID.
        ///
        /// - Returns: Requested login campaigns, nil if failed to fetch data.
        public static func all() async -> [PreviewCampaign]? {
            // Response example:
            // {
            //     "1": {
            //         "loginBonusType": "normal",
            //         "assetBundleName": [
            //             null,
            //             ...
            //         ],
            //         "caption": [
            //             "通常ログインボーナス",
            //             ...
            //         ],
            //         "publishedAt": [
            //             "0",
            //             ...
            //         ],
            //         "closedAt": [
            //             "4133948399000",
            //             ...
            //         ]
            //     },
            //     ...
            // }
            let request = await requestJSON("https://bestdori.com/api/loginCampaigns/all.5.json")
            if case let .success(respJSON) = request {
                let task = Task.detached(priority: .userInitiated) {
                    var result = [PreviewCampaign]()
                    for (key, value) in respJSON {
                        result.append(.init(
                            id: Int(key) ?? 0,
                            loginBonusType: .init(rawValue: value["loginBonusType"].stringValue) ?? .normal,
                            assetBundleName: .init(
                                jp: value["assetBundleName"][0].string,
                                en: value["assetBundleName"][1].string,
                                tw: value["assetBundleName"][2].string,
                                cn: value["assetBundleName"][3].string,
                                kr: value["assetBundleName"][4].string
                            ),
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
                    return result.sorted { $0.id < $1.id }
                }
                return await task.value
            }
            return nil
        }
        
        /// Get detail of a login campaign in Bandori.
        /// - Parameter id: ID of target login campaign.
        /// - Returns: Detail data of requested login campaign, nil if failed to fetch.
        public static func detail(of id: Int) async -> Campaign? {
            // Response example:
            // {
            //     "loginBonusType": "normal",
            //     "assetBundleName": [
            //         null,
            //         ...
            //     ],
            //     "assetMap": {},
            //     "caption": [
            //         "通常ログインボーナス",
            //         ...
            //     ],
            //     "publishedAt": [
            //         "0",
            //         ...
            //     ],
            //     "closedAt": [
            //         "4133948399000",
            //         ...
            //     ],
            //     "details": [
            //         [
            //             {
            //                 "loginBonusId": 1,
            //                 "days": 1,
            //                 "resourceType": "coin",
            //                 "quantity": 10000,
            //                 "seq": 1,
            //                 "grantType": "present"
            //             },
            //             ...
            //         ],
            //         ...
            //     ]
            // }
            let request = await requestJSON("https://bestdori.com/api/loginCampaigns/\(id).json")
            if case let .success(respJSON) = request {
                let task = Task.detached(priority: .userInitiated) {
                    func bonus(for localeIndex: Int) -> [Campaign.Bonus]? {
                        guard respJSON["details"][localeIndex][0]["loginBonusId"].int != nil else { return nil }
                        var result = [Campaign.Bonus]()
                        for (_, value) in respJSON["details"][localeIndex] {
                            result.append(
                                .init(
                                    loginBonusID: value["loginBonusId"].intValue,
                                    days: value["days"].intValue,
                                    item: .init(
                                        itemID: value["resourceId"].int,
                                        type: .init(rawValue: value["resourceType"].stringValue) ?? .item,
                                        quantity: value["quantity"].intValue
                                    ),
                                    voiceID: value["voiceId"].string,
                                    seq: value["seq"].intValue,
                                    grantType: .init(rawValue: value["grantType"].stringValue) ?? .present
                                )
                            )
                        }
                        return result
                    }
                    
                    return Campaign(
                        id: id,
                        loginBonusType: .init(rawValue: respJSON["loginBonusType"].stringValue) ?? .normal,
                        assetBundleName: .init(
                            jp: respJSON["assetBundleName"][0].string,
                            en: respJSON["assetBundleName"][1].string,
                            tw: respJSON["assetBundleName"][2].string,
                            cn: respJSON["assetBundleName"][3].string,
                            kr: respJSON["assetBundleName"][4].string
                        ),
                        caption: .init(
                            jp: respJSON["caption"][0].string,
                            en: respJSON["caption"][1].string,
                            tw: respJSON["caption"][2].string,
                            cn: respJSON["caption"][3].string,
                            kr: respJSON["caption"][4].string
                        ),
                        publishedAt: .init(
                            jp: respJSON["publishedAt"][0].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["publishedAt"][0].stringValue.dropLast(3))!)) : nil,
                            en: respJSON["publishedAt"][1].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["publishedAt"][1].stringValue.dropLast(3))!)) : nil,
                            tw: respJSON["publishedAt"][2].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["publishedAt"][2].stringValue.dropLast(3))!)) : nil,
                            cn: respJSON["publishedAt"][3].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["publishedAt"][3].stringValue.dropLast(3))!)) : nil,
                            kr: respJSON["publishedAt"][4].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["publishedAt"][4].stringValue.dropLast(3))!)) : nil
                        ),
                        closedAt: .init(
                            jp: respJSON["closedAt"][0].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["closedAt"][0].stringValue.dropLast(3))!)) : nil,
                            en: respJSON["closedAt"][1].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["closedAt"][1].stringValue.dropLast(3))!)) : nil,
                            tw: respJSON["closedAt"][2].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["closedAt"][2].stringValue.dropLast(3))!)) : nil,
                            cn: respJSON["closedAt"][3].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["closedAt"][3].stringValue.dropLast(3))!)) : nil,
                            kr: respJSON["closedAt"][4].string != nil ? Date(timeIntervalSince1970: Double(Int(respJSON["closedAt"][4].stringValue.dropLast(3))!)) : nil
                        ),
                        details: .init(
                            jp: bonus(for: 0),
                            en: bonus(for: 1),
                            tw: bonus(for: 2),
                            cn: bonus(for: 3),
                            kr: bonus(for: 4)
                        )
                    )
                }
                return await task.value
            }
            return nil
        }
    }
}

extension DoriAPI.LoginCampaign {
    /// Represent simplified data of login campaign.
    public struct PreviewCampaign: Sendable, Identifiable, Hashable, DoriCache.Cacheable {
        /// A unique ID of login campaign.
        public var id: Int
        /// Type of login campaign.
        public var loginBonusType: CampaignType
        /// Name of resource bundle, used for combination of resource URLs.
        public var assetBundleName: DoriAPI.LocalizedData<String>
        /// Localized caption of login campaign.
        public var caption: DoriAPI.LocalizedData<String>
        /// Localized publish date of login campaign.
        public var publishedAt: DoriAPI.LocalizedData<Date>
        /// Localized close date of login campaign.
        public var closedAt: DoriAPI.LocalizedData<Date>
    }
    
    public struct Campaign: Sendable, Identifiable, Hashable, DoriCache.Cacheable {
        /// A unique ID of login campaign.
        public var id: Int
        /// Type of login campaign.
        public var loginBonusType: CampaignType
        /// Name of resource bundle, used for combination of resource URLs.
        public var assetBundleName: DoriAPI.LocalizedData<String>
        /// Localized caption of login campaign.
        public var caption: DoriAPI.LocalizedData<String>
        /// Localized publish date of login campaign.
        public var publishedAt: DoriAPI.LocalizedData<Date>
        /// Localized close date of login campaign.
        public var closedAt: DoriAPI.LocalizedData<Date>
        /// Localized bonus details.
        public var details: DoriAPI.LocalizedData<[Bonus]>
        
        /// Represent a bonus detail of login campaign.
        public struct Bonus: Sendable, Hashable, DoriCache.Cacheable {
            /// Corresponding login campaign ID.
            public var loginBonusID: Int
            /// Relative days from start of login campaign to the bonus available.
            public var days: Int
            /// Item for this bonus.
            public var item: DoriAPI.Item
            public var voiceID: String?
            public var seq: Int
            public var grantType: GrantType
            
            internal init(
                loginBonusID: Int,
                days: Int,
                item: DoriAPI.Item,
                voiceID: String?,
                seq: Int,
                grantType: GrantType
            ) {
                self.loginBonusID = loginBonusID
                self.days = days
                self.item = item
                self.voiceID = voiceID
                self.seq = seq
                self.grantType = grantType
            }
            
            public enum GrantType: String, Sendable, Hashable, DoriCache.Cacheable {
                case present
            }
        }
    }
    
    /// Represent type of a login campaign.
    public enum CampaignType: String, Sendable, Hashable, DoriCache.Cacheable {
        case normal
        case event
        case birthday
        case rookie
        case comeback
        case spComeback = "sp_comeback"
        case noAsset = "no_asset"
    }
}

extension DoriAPI.LoginCampaign.PreviewCampaign {
    public init(_ full: DoriAPI.LoginCampaign.Campaign) {
        self.init(
            id: full.id,
            loginBonusType: full.loginBonusType,
            assetBundleName: full.assetBundleName,
            caption: full.caption,
            publishedAt: full.publishedAt,
            closedAt: full.closedAt
        )
    }
}
extension DoriAPI.LoginCampaign.Campaign {
    @inlinable
    public init?(id: Int) async {
        if let campaign = await DoriAPI.LoginCampaign.detail(of: id) {
            self = campaign
        } else {
            return nil
        }
    }
    
    @inlinable
    public init?(preview: DoriAPI.LoginCampaign.PreviewCampaign) async {
        await self.init(id: preview.id)
    }
}
