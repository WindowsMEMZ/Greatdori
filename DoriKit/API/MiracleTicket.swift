//===---*- Greatdori! -*---------------------------------------------------===//
//
// MiracleTicket.swift
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
    /// Request and fetch data about miracle tickets in Bandori.
    public enum MiracleTicket {
        public static func all() async -> [MiracleTicket]? {
            // Response example:
            // {
            //     "1": {
            //         "name": [
            //             "★3ミラクルチケット交換所",
            //             "★3 Exchange Ticket",
            //             "★3奇蹟兌換券交換所",
            //             "★3奇迹招募券交换所",
            //             "★3 미라클 티켓 교환소"
            //         ],
            //         "ids": [
            //             [
            //                 3,
            //                 ...
            //             ],
            //             ...
            //         ],
            //         "exchangeStartAt": [
            //             null,
            //             ...
            //         ],
            //         "exchangeEndAt": [
            //             null,
            //             ...
            //         ]
            //     },
            //     ...
            // }
            let request = await requestJSON("https://bestdori.com/api/miracleTicketExchanges/all.5.json")
            if case let .success(respJSON) = request {
                let task = Task.detached(priority: .userInitiated) {
                    var result = [MiracleTicket]()
                    for (key, value) in respJSON {
                        result.append(.init(
                            id: Int(key) ?? 0,
                            name: .init(
                                jp: value["name"][0].string,
                                en: value["name"][1].string,
                                tw: value["name"][2].string,
                                cn: value["name"][3].string,
                                kr: value["name"][4].string
                            ),
                            ids: .init(
                                jp: value["ids"][0][0].int != nil ? value["ids"][0].map { $0.1.intValue } : nil,
                                en: value["ids"][1][0].int != nil ? value["ids"][1].map { $0.1.intValue } : nil,
                                tw: value["ids"][2][0].int != nil ? value["ids"][2].map { $0.1.intValue } : nil,
                                cn: value["ids"][3][0].int != nil ? value["ids"][3].map { $0.1.intValue } : nil,
                                kr: value["ids"][4][0].int != nil ? value["ids"][4].map { $0.1.intValue } : nil
                            ),
                            exchangeStartAt: .init(
                                jp: value["exchangeStartAt"][0].string != nil ? Date(timeIntervalSince1970: Double(Int(value["exchangeStartAt"][0].stringValue.dropLast(3))!)) : nil,
                                en: value["exchangeStartAt"][1].string != nil ? Date(timeIntervalSince1970: Double(Int(value["exchangeStartAt"][1].stringValue.dropLast(3))!)) : nil,
                                tw: value["exchangeStartAt"][2].string != nil ? Date(timeIntervalSince1970: Double(Int(value["exchangeStartAt"][2].stringValue.dropLast(3))!)) : nil,
                                cn: value["exchangeStartAt"][3].string != nil ? Date(timeIntervalSince1970: Double(Int(value["exchangeStartAt"][3].stringValue.dropLast(3))!)) : nil,
                                kr: value["exchangeStartAt"][4].string != nil ? Date(timeIntervalSince1970: Double(Int(value["exchangeStartAt"][4].stringValue.dropLast(3))!)) : nil
                            ),
                            exchangeEndAt: .init(
                                jp: value["exchangeEndAt"][0].string != nil ? Date(timeIntervalSince1970: Double(Int(value["exchangeEndAt"][0].stringValue.dropLast(3))!)) : nil,
                                en: value["exchangeEndAt"][1].string != nil ? Date(timeIntervalSince1970: Double(Int(value["exchangeEndAt"][1].stringValue.dropLast(3))!)) : nil,
                                tw: value["exchangeEndAt"][2].string != nil ? Date(timeIntervalSince1970: Double(Int(value["exchangeEndAt"][2].stringValue.dropLast(3))!)) : nil,
                                cn: value["exchangeEndAt"][3].string != nil ? Date(timeIntervalSince1970: Double(Int(value["exchangeEndAt"][3].stringValue.dropLast(3))!)) : nil,
                                kr: value["exchangeEndAt"][4].string != nil ? Date(timeIntervalSince1970: Double(Int(value["exchangeEndAt"][4].stringValue.dropLast(3))!)) : nil
                            )
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

extension DoriAPI.MiracleTicket {
    public struct MiracleTicket: Sendable, Identifiable, Hashable, DoriCache.Cacheable {
        public var id: Int
        public var name: DoriAPI.LocalizedData<String>
        public var ids: DoriAPI.LocalizedData<[Int]>
        public var exchangeStartAt: DoriAPI.LocalizedData<Date>
        public var exchangeEndAt: DoriAPI.LocalizedData<Date>
    }
}
