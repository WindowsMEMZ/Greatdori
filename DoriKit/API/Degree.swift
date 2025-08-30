//===---*- Greatdori! -*---------------------------------------------------===//
//
// Degree.swift
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
    /// Request and fetch data about degree in Bandori.
    public enum Degree {
        /// Get all degrees in Bandori.
        ///
        /// The results have guaranteed sorting by ID.
        ///
        /// - Returns: Requested degrees, nil if failed to fetch data.
        public static func all() async -> [Degree]? {
            // Response example:
            // {
            //     "1": {
            //         "degreeType": [
            //             "event_point",
            //             "event_point",
            //             "event_point",
            //             "event_point",
            //             "event_point"
            //         ],
            //         "iconImageName": [
            //             "none",
            //             ...
            //         ],
            //         "baseImageName": [
            //             "degree001",
            //             ...
            //         ],
            //         "rank": [
            //             "none",
            //             ...
            //         ],
            //         "degreeName": [
            //             "SAKURA＊BLOOMING PARTY! TOP100",
            //             ...
            //         ]
            //     },
            //     ...
            // }
            let request = await requestJSON("https://bestdori.com/api/degrees/all.3.json")
            if case let .success(respJSON) = request {
                let task = Task.detached(priority: .userInitiated) {
                    var result = [Degree]()
                    for (key, value) in respJSON {
                        result.append(.init(
                            id: Int(key) ?? 0,
                            degreeType: .init(
                                jp: .init(rawValue: value["degreeType"][0].stringValue),
                                en: .init(rawValue: value["degreeType"][1].stringValue),
                                tw: .init(rawValue: value["degreeType"][2].stringValue),
                                cn: .init(rawValue: value["degreeType"][3].stringValue),
                                kr: .init(rawValue: value["degreeType"][4].stringValue)
                            ),
                            iconImageName: .init(
                                jp: value["iconImageName"][0].string,
                                en: value["iconImageName"][1].string,
                                tw: value["iconImageName"][2].string,
                                cn: value["iconImageName"][3].string,
                                kr: value["iconImageName"][4].string
                            ),
                            baseImageName: .init(
                                jp: value["baseImageName"][0].string,
                                en: value["baseImageName"][1].string,
                                tw: value["baseImageName"][2].string,
                                cn: value["baseImageName"][3].string,
                                kr: value["baseImageName"][4].string
                            ),
                            rank: .init(
                                jp: value["rank"][0].string,
                                en: value["rank"][1].string,
                                tw: value["rank"][2].string,
                                cn: value["rank"][3].string,
                                kr: value["rank"][4].string
                            ),
                            degreeName: .init(
                                jp: value["degreeName"][0].string,
                                en: value["degreeName"][1].string,
                                tw: value["degreeName"][2].string,
                                cn: value["degreeName"][3].string,
                                kr: value["degreeName"][4].string
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

extension DoriAPI.Degree {
    /// Represent information of a degree.
    public struct Degree: Sendable, Identifiable, Hashable, DoriCache.Cacheable {
        /// A unique ID of degree.
        public var id: Int
        /// Localized type of degree.
        public var degreeType: DoriAPI.LocalizedData<DegreeType>
        /// Localized icon image name, used for combination of resource URLs.
        public var iconImageName: DoriAPI.LocalizedData<String>
        /// Localized base image name, used for combination of resource URLs.
        public var baseImageName: DoriAPI.LocalizedData<String>
        /// Localized rank of degree.
        public var rank: DoriAPI.LocalizedData<String>
        /// Localized name of degree.
        public var degreeName: DoriAPI.LocalizedData<String>
        
        /// Represent type of degrees
        public enum DegreeType: String, Sendable, DoriCache.Cacheable {
            case normal
            case scoreRanking = "score_ranking"
            case eventPoint = "event_point"
            case tryClear = "try_clear"
        }
    }
}
