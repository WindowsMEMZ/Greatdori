//===---*- Greatdori! -*---------------------------------------------------===//
//
// Gacha.swift
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
    /// Request and fetch data about gacha in Bandori.
    public enum Gacha {
        /// Get all gacha in Bandori.
        ///
        /// The results have guaranteed sorting by ID.
        ///
        /// - Returns: Requested gacha, nil if failed to fetch data.
        public static func all() async -> [PreviewGacha]? {
            // Response example:
            // {
            //     "1": {
            //         "resourceName": "gacha1",
            //         "bannerAssetBundleName": "banner-001",
            //         "gachaName": [
            //             "リリース記念ガチャ",
            //             "Release Celebration Gacha",
            //             "遊戲上線紀念轉蛋",
            //             "开服纪念招募",
            //             "오픈 기념 뽑기"
            //         ],
            //         "publishedAt": [
            //             "1462071600000",
            //             ...
            //         ],
            //         "closedAt": [
            //             "1490335199000",
            //             ...
            //         ],
            //         "type": "permanent",
            //         "newCards": [
            //             2,
            //             ...
            //         ]
            //     },
            //     ...
            // }
            let request = await requestJSON("https://bestdori.com/api/gacha/all.5.json")
            if case let .success(respJSON) = request {
                let task = Task.detached(priority: .userInitiated) {
                    var result = [PreviewGacha]()
                    for (key, value) in respJSON {
                        result.append(.init(
                            id: Int(key) ?? 0,
                            resourceName: value["resourceName"].stringValue,
                            bannerAssetBundleName: value["bannerAssetBundleName"].stringValue,
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
                            ),
                            type: .init(rawValue: value["type"].stringValue) ?? .permanent,
                            newCards: value["newCards"].map { $0.1.intValue }
                        ))
                    }
                    return result.sorted { $0.id < $1.id }
                }
                return await task.value
            }
            return nil
        }
        
        /// Get detail of gacha in Bandori.
        /// - Parameter id: ID of target gacha.
        /// - Returns: Detail data of requested gacha, nil if failed to fetch.
        public static func detail(of id: Int) async -> Gacha? {
            // Response example:
            // {
            //     "details": [
            //         {
            //             "2": {
            //                 "rarityIndex": 2,
            //                 "weight": 1,
            //                 "pickup": false
            //             },
            //             ...
            //         },
            //         ...
            //     ],
            //     "rates": [
            //         {
            //             "1": {
            //                 "rate": 0,
            //                 "weightTotal": 0
            //             },
            //             ...,
            //             "5": {
            //                 "rate": 6,
            //                 "weightTotal": 59952
            //             }
            //         },
            //         ...
            //     ],
            //     "paymentMethods": [
            //         {
            //             "gachaId": 1469,
            //             "paymentMethod": "free_star",
            //             "quantity": 250,
            //             "paymentMethodId": 3929,
            //             "count": 10,
            //             "behavior": "over_the_3_star_once",
            //             "pickup": false,
            //             "costItemQuantity": 2500,
            //             "appealImageFileName": "over_3_star_once",
            //             "discountType": 0
            //         },
            //         ...
            //     ],
            //     "resourceName": "gacha1469",
            //     "bannerAssetBundleName": "banner_gacha1469",
            //     "gachaName": [
            //         "ドリームフェスティバルガチャ",
            //         ...
            //     ],
            //     "publishedAt": [
            //         "1735624800000",
            //         ...
            //     ],
            //     "closedAt": [
            //         "1735970399000",
            //         ...
            //     ],
            //     "description": [
            //         "★★★★以上メンバーの提供割合2倍！※出現メンバー及び提供割合はガチャ詳細をご確認ください。",
            //         ...
            //     ],
            //     "annotation": [
            //         "・下記提供割合でメンバーが出現します。...",
            //         ...
            //     ],
            //     "gachaPeriod": [
            //         "01/04 14:59 まで",
            //         ...
            //     ],
            //     "gachaType": "normal",
            //     "type": "dreamfes",
            //     "newCards": [
            //         2123,
            //         ...
            //     ],
            //     "information": {
            //         "description": [
            //             "「ドリームフェスティバルガチャ」では★5メンバーのレアリティ別の提供割合が3%の2倍の6%、...",
            //             ...
            //         ],
            //         "term": [
            //             "2024/12/31 15:00～2025/01/04 14:59",
            //             ...
            //         ],
            //         "newMemberInfo": [
            //             "【ドリフェス限定メンバー】...",
            //             ...
            //         ],
            //         "notice": [
            //             "・「5回限定の10回ガチャ」は有償スターでのみご利用いただけます。...",
            //             ...
            //         ]
            //     }
            // }
            let request = await requestJSON("https://bestdori.com/api/gacha/\(id).json")
            if case let .success(respJSON) = request {
                let task = Task.detached(priority: .userInitiated) {
                    func details(atLocalizedIndex index: Int) -> [Int: Gacha.CardDetail]? {
                        guard respJSON["details"][index].null == nil else {
                            return nil
                        }
                        return respJSON["details"][index].map {
                            (key: Int($0.0) ?? 0,
                             value: Gacha.CardDetail(
                                rarityIndex: $0.1["rarityIndex"].intValue,
                                weight: $0.1["weight"].intValue,
                                pickup: $0.1["pickup"].boolValue
                             ))
                        }.reduce(into: [Int: Gacha.CardDetail]()) {
                            $0.updateValue($1.value, forKey: $1.key)
                        }
                    }
                    func rates(atLocalizedIndex index: Int) -> [Int: Gacha.Rate]? {
                        guard respJSON["rates"][index].null == nil else {
                            return nil
                        }
                        return respJSON["rates"][index].map {
                            (key: Int($0.0) ?? 0,
                             value: Gacha.Rate(
                                rate: $0.1["rate"].doubleValue,
                                weightTotal: $0.1["weightTotal"].intValue
                             ))
                        }.reduce(into: [Int: Gacha.Rate]()) {
                            $0.updateValue($1.value, forKey: $1.key)
                        }
                    }
                    return Gacha(
                        id: id,
                        details: .init(
                            jp: details(atLocalizedIndex: 0),
                            en: details(atLocalizedIndex: 1),
                            tw: details(atLocalizedIndex: 2),
                            cn: details(atLocalizedIndex: 3),
                            kr: details(atLocalizedIndex: 4)
                        ),
                        rates: .init(
                            jp: rates(atLocalizedIndex: 0),
                            en: rates(atLocalizedIndex: 1),
                            tw: rates(atLocalizedIndex: 2),
                            cn: rates(atLocalizedIndex: 3),
                            kr: rates(atLocalizedIndex: 4)
                        ),
                        paymentMethods: respJSON["paymentMethods"].map {
                            Gacha.PaymentMethod(
                                gachaID: $0.1["gachaId"].intValue,
                                paymentMethod: .init(rawValue: $0.1["paymentMethod"].stringValue) ?? .freeStar,
                                quantity: $0.1["quantity"].intValue,
                                paymentMethodID: $0.1["paymentMethodId"].intValue,
                                count: $0.1["count"].intValue,
                                behavior: .init(rawValue: $0.1["behavior"].stringValue) ?? .normal,
                                pickup: $0.1["pickup"].boolValue,
                                maxSpinLimit: $0.1["maxSpinLimit"].int,
                                costItemQuantity: $0.1["costItemQuantity"].intValue,
                                appealImageFileName: $0.1["appealImageFileName"].string,
                                discountType: $0.1["discountType"].intValue,
                                ticketID: $0.1["ticketId"].int,
                                gachaBonusPoint: $0.1["gachaBonusPoint"].int
                            )
                        },
                        resourceName: respJSON["resourceName"].stringValue,
                        bannerAssetBundleName: respJSON["bannerAssetBundleName"].stringValue,
                        gachaName: .init(
                            jp: respJSON["gachaName"][0].string,
                            en: respJSON["gachaName"][1].string,
                            tw: respJSON["gachaName"][2].string,
                            cn: respJSON["gachaName"][3].string,
                            kr: respJSON["gachaName"][4].string
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
                        description: .init(
                            jp: respJSON["description"][0].string,
                            en: respJSON["description"][1].string,
                            tw: respJSON["description"][2].string,
                            cn: respJSON["description"][3].string,
                            kr: respJSON["description"][4].string
                        ),
                        annotation: .init(
                            jp: respJSON["annotation"][0].string,
                            en: respJSON["annotation"][1].string,
                            tw: respJSON["annotation"][2].string,
                            cn: respJSON["annotation"][3].string,
                            kr: respJSON["annotation"][4].string
                        ),
                        gachaPeriod: .init(
                            jp: respJSON["gachaPeriod"][0].string,
                            en: respJSON["gachaPeriod"][1].string,
                            tw: respJSON["gachaPeriod"][2].string,
                            cn: respJSON["gachaPeriod"][3].string,
                            kr: respJSON["gachaPeriod"][4].string
                        ),
                        type: .init(rawValue: respJSON["type"].stringValue) ?? .permanent,
                        newCards: respJSON["newCards"].map { $0.1.intValue },
                        information: .init(
                            description: .init(
                                jp: respJSON["information"]["description"][0].string,
                                en: respJSON["information"]["description"][1].string,
                                tw: respJSON["information"]["description"][2].string,
                                cn: respJSON["information"]["description"][3].string,
                                kr: respJSON["information"]["description"][4].string
                            ),
                            term: .init(
                                jp: respJSON["information"]["term"][0].string,
                                en: respJSON["information"]["term"][1].string,
                                tw: respJSON["information"]["term"][2].string,
                                cn: respJSON["information"]["term"][3].string,
                                kr: respJSON["information"]["term"][4].string
                            ),
                            newMemberInfo: .init(
                                jp: respJSON["information"]["newMemberInfo"][0].string,
                                en: respJSON["information"]["newMemberInfo"][1].string,
                                tw: respJSON["information"]["newMemberInfo"][2].string,
                                cn: respJSON["information"]["newMemberInfo"][3].string,
                                kr: respJSON["information"]["newMemberInfo"][4].string
                            ),
                            notice: .init(
                                jp: respJSON["information"]["notice"][0].string,
                                en: respJSON["information"]["notice"][1].string,
                                tw: respJSON["information"]["notice"][2].string,
                                cn: respJSON["information"]["notice"][3].string,
                                kr: respJSON["information"]["notice"][4].string
                            )
                        )
                    )
                }
                return await task.value
            }
            return nil
        }
    }
}

extension DoriAPI.Gacha {
    /// Represent simplified data of gacha.
    public struct PreviewGacha: Sendable, Identifiable, Hashable, DoriCache.Cacheable {
        /// A unique ID of gacha.
        public var id: Int
        /// Name of resource bundle, used for combination of resource URLs.
        public var resourceName: String
        /// Name of banner resource bundle, used for combination of resource URLs.
        public var bannerAssetBundleName: String
        /// Localized name of gacha.
        public var gachaName: DoriAPI.LocalizedData<String>
        /// Localized published date of gacha.
        public var publishedAt: DoriAPI.LocalizedData<Date> // String(JSON) -> Date(Swift)
        /// Localized closed date of gacha.
        public var closedAt: DoriAPI.LocalizedData<Date> // String(JSON) -> Date(Swift)
        /// Type of gacha.
        public var type: GachaType
        /// IDs of new cards in this gacha.
        ///
        /// *New cards* mean cards that never appears in gacha before this one.
        public var newCards: [Int]
    }
    
    /// Represent detailed data of gacha.
    public struct Gacha: Sendable, Identifiable, Hashable, DoriCache.Cacheable {
        /// A unique ID of gacha.
        public var id: Int
        /// Localized details of gacha.
        ///
        /// Detailed data dictionary `[Int: CardDetail]` represents `[CardID: CardDetail]`.
        ///
        /// - SeeAlso:
        ///     - ``CardDetail``
        public var details: DoriAPI.LocalizedData<[Int: CardDetail]>
        /// Localized rates for each rarities of gacha.
        ///
        /// Detailed data dictionary `[Int: Rate]` represents `[CardRarity: Rate]`.
        ///
        /// - SeeAlso:
        ///     - ``Rate``
        public var rates: DoriAPI.LocalizedData<[Int: Rate]>
        /// Payment methods of gacha.
        public var paymentMethods: [PaymentMethod]
        /// Name of resource bundle, used for combination of resource URLs.
        public var resourceName: String
        /// Name of banner resource bundle, used for combination of resource URLs.
        public var bannerAssetBundleName: String
        /// Localized name of gacha.
        public var gachaName: DoriAPI.LocalizedData<String>
        /// Localized published date of gacha.
        public var publishedAt: DoriAPI.LocalizedData<Date> // String(JSON) -> Date(Swift)
        /// Localized closed date of gacha.
        public var closedAt: DoriAPI.LocalizedData<Date> // String(JSON) -> Date(Swift)
        /// Localized description of gacha.
        public var description: DoriAPI.LocalizedData<String>
        /// Localized annotation text of gacha.
        public var annotation: DoriAPI.LocalizedData<String>
        /// Localized period text of gacha.
        public var gachaPeriod: DoriAPI.LocalizedData<String>
        /// Type of gacha.
        public var type: GachaType
        /// IDs of new cards in this gacha.
        ///
        /// *New cards* mean cards that never appears in gacha before this one.
        public var newCards: [Int]
        /// Information of gacha.
        public var information: Information
        
        /// Represent detail of a card in gacha.
        public struct CardDetail: Sendable, Hashable, DoriCache.Cacheable {
            /// Rarity of card.
            public var rarityIndex: Int
            /// Weight of card.
            public var weight: Int
            /// Whether the card is picked up in gacha.
            public var pickup: Bool
        }
        
        /// Represent rate of a rarity in gacha.
        public struct Rate: Sendable, Hashable, DoriCache.Cacheable {
            /// Rate.
            public var rate: Double
            /// Total of weight for cards in this rate.
            public var weightTotal: Int
        }
        
        /// Represent a payment method of gacha.
        public struct PaymentMethod: Sendable, Hashable, DoriCache.Cacheable {
            /// ID of gacha about this payment method.
            public var gachaID: Int
            /// Payment method type.
            public var paymentMethod: Method
            /// Required quantity of item (unit price).
            public var quantity: Int
            /// A unique id of payment method.
            public var paymentMethodID: Int
            /// Count of costing item required by this payment method.
            public var count: Int
            /// Behavior about payment method.
            public var behavior: Behavior
            /// Whether gacha by this payment method picked up.
            public var pickup: Bool
            /// Max spin limit of gacha by this payment method, nil if not limited.
            public var maxSpinLimit: Int?
            /// Total quantity of costing item.
            public var costItemQuantity: Int
            /// Appeal image file name.
            public var appealImageFileName: String?
            /// Discount type of payment method.
            public var discountType: Int
            /// Ticket ID when payment method is ticket.
            public var ticketID: Int?
            /// Bonus point for gacha by this payment method.
            public var gachaBonusPoint: Int?
            
            internal init(
                gachaID: Int,
                paymentMethod: Method,
                quantity: Int,
                paymentMethodID: Int,
                count: Int,
                behavior: Behavior,
                pickup: Bool,
                maxSpinLimit: Int?,
                costItemQuantity: Int,
                appealImageFileName: String?,
                discountType: Int,
                ticketID: Int?,
                gachaBonusPoint: Int?
            ) {
                self.gachaID = gachaID
                self.paymentMethod = paymentMethod
                self.quantity = quantity
                self.paymentMethodID = paymentMethodID
                self.count = count
                self.behavior = behavior
                self.pickup = pickup
                self.maxSpinLimit = maxSpinLimit
                self.costItemQuantity = costItemQuantity
                self.appealImageFileName = appealImageFileName
                self.discountType = discountType
                self.ticketID = ticketID
                self.gachaBonusPoint = gachaBonusPoint
            }
            
            /// Represent a payment method.
            public enum Method: String, Sendable, Hashable, DoriCache.Cacheable {
                case free
                case freeStar = "free_star"
                case paidStar = "paid_star"
                case normalTicket = "normal_ticket"
                case overThe3StarTicket = "over_the_3_star_ticket"
                case overThe4StarTicket = "over_the_4_star_ticket"
                case fixed5StarTicket = "fixed_5_star_ticket"
            }
            /// Represent behavior of a payment method.
            public enum Behavior: String, Sendable, Hashable, DoriCache.Cacheable {
                case normal
                case overThe3StarOnce = "over_the_3_star_once"
                case overThe4StarOnce = "over_the_4_star_once"
                case onceADay = "once_a_day"
                case onceADayOverThe3StarOnce = "once_a_day_over_the_3_star_once"
                case fixed5StarOnce = "fixed_5_star_once"
            }
        }
        
        /// Represent information of gacha.
        public struct Information: Sendable, Hashable, DoriCache.Cacheable {
            /// Localized description of gacha.
            public var description: DoriAPI.LocalizedData<String>
            /// Localized term of gacha.
            public var term: DoriAPI.LocalizedData<String>
            /// Localized new member info of gacha.
            public var newMemberInfo: DoriAPI.LocalizedData<String>
            /// Localized notice of gacha.
            public var notice: DoriAPI.LocalizedData<String>
        }
    }
    
    /// Represent type of gacha.
    public enum GachaType: String, Sendable, CaseIterable, Hashable, DoriCache.Cacheable {
        case free
        case permanent
        case miracle
        case limited
        case kirafes
        case dreamfes
        case special
        case birthday
    }
}

extension DoriAPI.Gacha.PreviewGacha {
    public init(_ full: DoriAPI.Gacha.Gacha) {
        self.init(
            id: full.id,
            resourceName: full.resourceName,
            bannerAssetBundleName: full.bannerAssetBundleName,
            gachaName: full.gachaName,
            publishedAt: full.publishedAt,
            closedAt: full.closedAt,
            type: full.type,
            newCards: full.newCards
        )
    }
}
extension DoriAPI.Gacha.Gacha {
    @inlinable
    public init?(id: Int) async {
        if let gacha = await DoriAPI.Gacha.detail(of: id) {
            self = gacha
        } else {
            return nil
        }
    }
    
    @inlinable
    public init?(preview: DoriAPI.Gacha.PreviewGacha) async {
        await self.init(id: preview.id)
    }
}
