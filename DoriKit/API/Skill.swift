//===---*- Greatdori! -*---------------------------------------------------===//
//
// Skill.swift
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
    /// Request and fetch data about skills in Bandori.
    public enum Skill {
        /// Get all skills in Bandori.
        ///
        /// The results have guaranteed sorting by ID.
        ///
        /// - Returns: Requested skills, nil if failed to fetch data.
        public static func all() async -> [Skill]? {
            // Response example:
            // {
            //     "1": {
            //         "simpleDescription": [
            //             "スコア10%ＵＰ",
            //             "Score Boost 10%",
            //             "ＳＣＯＲＥ１０%ＵＰ",
            //             "得分提升10%",
            //             "스코어 10% UP"
            //         ],
            //         "description": [
            //             "{0}秒間  スコアが10%UPする",
            //             ...
            //         ],
            //         "duration": [
            //             5,
            //             5.5,
            //             6,
            //             6.5,
            //             7
            //         ],
            //         "activationEffect": {
            //             "activateEffectTypes": {
            //                 "score": {
            //                     "activateEffectValue": [
            //                         10,
            //                         10,
            //                         10,
            //                         10,
            //                         10
            //                     ],
            //                     "activateEffectValueType": "rate",
            //                     "activateCondition": "good"
            //                 }
            //             }
            //         }
            //     },
            //     ...
            // }
            let request = await requestJSON("https://bestdori.com/api/skills/all.10.json")
            if case let .success(respJSON) = request {
                let task = Task.detached(priority: .userInitiated) {
                    var result = [Skill]()
                    for (key, value) in respJSON {
                        var effects = Skill.ActivationEffect.Effects()
                        for (k, v) in value["activationEffect"]["activateEffectTypes"] {
                            if let type = Skill.ActivationEffect.ActivateEffectType(rawValue: k) {
                                effects.updateValue(
                                    .init(
                                        activateEffectValue: v["activateEffectValue"].map { $0.1.intValue },
                                        activateEffectValueType: .init(rawValue: v["activateEffectValueType"].stringValue) ?? .rate,
                                        activateCondition: .init(rawValue: v["activateCondition"].stringValue) ?? .good,
                                        activateConditionLife: v["activateConditionLife"].int
                                    ),
                                    forKey: type
                                )
                            }
                        }
                        var onceEffect: Skill.OnceEffect?
                        if value["onceEffect"].exists() {
                            onceEffect = .init(
                                onceEffectType: .init(rawValue: value["onceEffect"]["onceEffectType"].stringValue) ?? .life,
                                onceEffectValueType: .init(rawValue: value["onceEffect"]["onceEffectValueType"].stringValue) ?? .realValue,
                                onceEffectConditionLifeType: .init(rawValue: value["onceEffect"]["onceEffectConditionLifeType"].stringValue) ?? .underLife,
                                onceEffectConditionLife: value["onceEffect"]["onceEffectConditionLife"].intValue,
                                onceEffectValue: value["onceEffect"]["onceEffectValue"].map { $0.1.intValue }
                            )
                        }
                        result.append(.init(
                            id: Int(key) ?? 0,
                            simpleDescription: .init(
                                jp: value["simpleDescription"][0].string,
                                en: value["simpleDescription"][1].string,
                                tw: value["simpleDescription"][2].string,
                                cn: value["simpleDescription"][3].string,
                                kr: value["simpleDescription"][4].string
                            ),
                            description: .init(
                                jp: value["description"][0].string,
                                en: value["description"][1].string,
                                tw: value["description"][2].string,
                                cn: value["description"][3].string,
                                kr: value["description"][4].string
                            ),
                            duration: value["duration"].map { $0.1.doubleValue },
                            activationEffect: .init(
                                unificationActivateEffectValue: value["activationEffect"]["unificationActivateEffectValue"].int,
                                unificationActivateConditionType: .init(rawValue: value["activationEffect"]["unificationActivateConditionType"].stringValue),
                                unificationActivateConditionBandID: value["activationEffect"]["unificationActivateConditionBandId"].int,
                                activateEffectTypes: effects
                            ),
                            onceEffect: onceEffect
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

extension DoriAPI.Skill {
    /// Represent a skill of card.
    public struct Skill: Sendable, Identifiable, Equatable, Hashable, DoriCache.Cacheable {
        /// A unique ID of skill.
        public var id: Int
        /// Localized simple description of skill.
        ///
        /// Simple description is a shorten and general description of a skill,
        /// without duration in text.
        ///
        /// ```
        /// PERFECTのみ\nスコア150%UP
        /// ```
        ///
        /// - Note:
        ///     `simpleDescription` may contain a **line break** like the example above.
        ///     You can replace all line breaks with spaces to make it compact:
        ///     ```swift
        ///     skill.simpleDescription.map { string in
        ///         string.replacing("\n", with: " ")
        ///     }
        ///     ```
        ///
        /// - SeeAlso:
        ///     - ``description``
        ///     - ``DoriAPI/LocalizedData/map(_:)``
        public var simpleDescription: DoriAPI.LocalizedData<String>
        /// Localized description of skill.
        ///
        /// Description is a full descriptive text for skill.
        /// It may contain `{0}` and `{1}` for string interpolation,
        /// where `{0}` is duration of the skill when `{1}` is not exist,
        /// or it stands for the other argument of skill. `{1}` stands for duration if presents.
        ///
        /// ```
        /// ライフが{0}回復し、{1}秒間  スコアが10%UPする
        /// ```
        ///
        /// - SeeAlso:
        ///     - ``simpleDescription``
        ///
        ///     Instead of replacing `{0}` and `{1}` according to the rules above by yourself,
        ///     use ``replacedDescription(with:)`` to let DoriKit do this,
        ///     which is more stable. ``maximumDescription`` calculates arguments
        ///     automatically for maximum level of the skill and returns you description for maximum level.
        public var description: DoriAPI.LocalizedData<String>
        /// Durations of skill.
        ///
        /// Duration values in this array have sorted by level and guarantee there're 5 elements,
        /// where the first value is the duration when level of skill is 1.
        public var duration: [Double]
        /// Activation effect of skill.
        public var activationEffect: ActivationEffect
        /// Once effect of skill, if available.
        public var onceEffect: OnceEffect?
        
        public struct ActivationEffect: Sendable, Equatable, Hashable, DoriCache.Cacheable {
            public var unificationActivateEffectValue: Int?
            public var unificationActivateConditionType: ActivateConditionType?
            public var unificationActivateConditionBandID: Int?
            public var activateEffectTypes: Effects
            
            internal init(
                unificationActivateEffectValue: Int?,
                unificationActivateConditionType: ActivateConditionType?,
                unificationActivateConditionBandID: Int?,
                activateEffectTypes: Effects
            ) {
                self.unificationActivateEffectValue = unificationActivateEffectValue
                self.unificationActivateConditionType = unificationActivateConditionType
                self.unificationActivateConditionBandID = unificationActivateConditionBandID
                self.activateEffectTypes = activateEffectTypes
            }
            
            public enum ActivateConditionType: String, Sendable, Hashable, DoriCache.Cacheable {
                case pure = "PURE"
                case cool = "COOL"
                case happy = "HAPPY"
                case powerful = "POWERFUL"
            }
            
            public typealias Effects = [ActivateEffectType: ActivateEffect]
            public enum ActivateEffectType: String, Sendable, Hashable, DoriCache.Cacheable {
                case score
                case judge
                case scoreOverLife = "score_over_life"
                case scoreUnderLife = "score_under_life"
                case scoreContinuedNoteJudge = "score_continued_note_judge"
                case scoreOnlyPerfect = "score_only_perfect"
                case scoreRateUpWithPerfect = "score_rate_up_with_perfect"
                case scoreUnderGreatHalf = "score_under_great_half"
                case damage
                case neverDie = "never_die"
            }
            public struct ActivateEffect: Sendable, Equatable, Hashable, DoriCache.Cacheable {
                public var activateEffectValue: [Int]
                public var activateEffectValueType: ValueType
                public var activateCondition: ActivateCondition
                public var activateConditionLife: Int?
                
                internal init(
                    activateEffectValue: [Int],
                    activateEffectValueType: ValueType,
                    activateCondition: ActivateCondition,
                    activateConditionLife: Int?
                ) {
                    self.activateEffectValue = activateEffectValue
                    self.activateEffectValueType = activateEffectValueType
                    self.activateCondition = activateCondition
                    self.activateConditionLife = activateConditionLife
                }
                
                public enum ValueType: String, Sendable, Hashable, DoriCache.Cacheable {
                    case rate
                    case realValue = "real_value"
                }
                public enum ActivateCondition: String, Sendable, Hashable, DoriCache.Cacheable {
                    case none
                    case good
                    case perfect
                }
            }
        }
        public struct OnceEffect: Sendable, Equatable, Hashable, DoriCache.Cacheable {
            public var onceEffectType: OnceEffectType
            public var onceEffectValueType: ValueType
            public var onceEffectConditionLifeType: ConditionLifeType
            public var onceEffectConditionLife: Int
            public var onceEffectValue: [Int]
            
            public enum OnceEffectType: String, Sendable, Hashable, DoriCache.Cacheable {
                case life
            }
            public enum ValueType: String, Sendable, Hashable, DoriCache.Cacheable {
                case realValue = "real_value"
            }
            public enum ConditionLifeType: String, Sendable, Hashable, DoriCache.Cacheable {
                case underLife = "under_life"
            }
        }
    }
}

extension DoriAPI.Skill.Skill {
    public func replacedDescription(with replacement: (String, String?)) -> DoriAPI.LocalizedData<String> {
        let description = self.description
        return description.map { desc in
            guard var desc, desc.contains("{0}") else { return desc }
            if desc.contains("{1}") {
                if let r = replacement.1 {
                    desc.replace("{0}", with: r)
                }
                desc.replace("{1}", with: replacement.0)
            } else {
                desc.replace("{0}", with: replacement.0)
            }
            return desc
        }
    }
    
    public var maximumDescription: DoriAPI.LocalizedData<String> {
        self.replacedDescription(
            with: (
                String(self.duration.last ?? 0),
                self.onceEffect?.onceEffectValue.last?.description
            )
        )
    }
}
