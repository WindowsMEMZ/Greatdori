//===---*- Greatdori! -*---------------------------------------------------===//
//
// Character.swift
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
    /// Request and fetch data about character in Bandori.
    public enum Character {
        /// Get all characters in Bandori.
        ///
        /// The results have guaranteed sorting by ID.
        ///
        /// - Returns: Requested characters, nil if failed to fetch data.
        public static func all() async -> [PreviewCharacter]? {
            // Response example:
            // {
            //     "1": {
            //         "characterType": "unique",
            //         "characterName": [
            //             "戸山 香澄",
            //             "Kasumi Toyama",
            //             "戶山 香澄",
            //             "户山 香澄",
            //             "토야마 카스미"
            //         ],
            //         "nickname": [
            //             null,
            //             ...
            //         ],
            //         "bandId": 1,
            //         "colorCode": "#FF5522"
            //     },
            //     ...
            // }
            let request = await requestJSON("https://bestdori.com/api/characters/all.2.json")
            if case let .success(respJSON) = request {
                let task = Task.detached(priority: .userInitiated) {
                    var characters = [PreviewCharacter]()
                    for (key, value) in respJSON {
                        characters.append(
                            .init(
                                id: Int(key) ?? 0,
                                characterType: .init(rawValue: value["characterType"].stringValue) ?? .common,
                                characterName: .init(
                                    jp: value["characterName"][0].string,
                                    en: value["characterName"][1].string,
                                    tw: value["characterName"][2].string,
                                    cn: value["characterName"][3].string,
                                    kr: value["characterName"][4].string
                                ),
                                nickname: .init(
                                    jp: value["nickname"][0].string,
                                    en: value["nickname"][1].string,
                                    tw: value["nickname"][2].string,
                                    cn: value["nickname"][3].string,
                                    kr: value["nickname"][4].string
                                ),
                                bandID: value["bandId"].int,
                                color: .init(hex: value["colorCode"].stringValue)
                            )
                        )
                    }
                    return characters.sorted { $0.id < $1.id }
                }
                return await task.value
            }
            return nil
        }
        
        /// Get all characters with birthday information in Bandori.
        ///
        /// The results have guaranteed sorting by ID.
        ///
        /// - Returns: Requested information, nil if failed to fetch data.
        public static func allBirthday() async -> [BirthdayCharacter]? {
            // Response example:
            // {
            //     "1": {
            //         "characterName": [
            //             "戸山 香澄",
            //             "Kasumi Toyama",
            //             "戶山 香澄",
            //             "户山 香澄",
            //             "토야마 카스미"
            //         ],
            //         "nickname": [
            //             null,
            //             ...
            //         ],
            //         "profile": {
            //             "birthday": "963500400000"
            //         }
            //     },
            //     ...
            // }
            let request = await requestJSON("https://bestdori.com/api/characters/main.birthday.json")
            if case let .success(respJSON) = request {
                let task = Task.detached(priority: .userInitiated) {
                    var result = [BirthdayCharacter]()
                    for (key, value) in respJSON {
                        result.append(.init(
                            id: Int(key) ?? 0,
                            characterName: .init(
                                jp: value["characterName"][0].string,
                                en: value["characterName"][1].string,
                                tw: value["characterName"][2].string,
                                cn: value["characterName"][3].string,
                                kr: value["characterName"][4].string
                            ),
                            nickname: .init(
                                jp: value["nickname"][0].string,
                                en: value["nickname"][1].string,
                                tw: value["nickname"][2].string,
                                cn: value["nickname"][3].string,
                                kr: value["nickname"][4].string
                            ),
                            birthday: .init(timeIntervalSince1970: Double(Int64(value["profile"]["birthday"].stringValue.dropLast(3)) ?? 0))
                        ))
                    }
                    return result.sorted { $0.id < $1.id }
                }
                return await task.value
            }
            return nil
        }
        
        /// Get detail of a character in Bandori.
        /// - Parameter id: ID of target character.
        /// - Returns: Detail data of requested character, nil if failed to fetch.
        public static func detail(of id: Int) async -> Character? {
            // Response example:
            // {
            //     "characterType": "unique",
            //     "characterName": [
            //         "長崎 そよ",
            //         "Soyo Nagasaki",
            //         "長崎 爽世",
            //         "长崎 爽世",
            //         null
            //     ],
            //     "firstName": [
            //         "そよ",
            //         ...
            //     ],
            //     "lastName": [
            //         "長崎",
            //         ...
            //     ],
            //     "nickname": [
            //         null,
            //         ...
            //     ],
            //     "bandId": 45,
            //     "colorCode": "#FFDD88",
            //     "sdAssetBundleName": "00039",
            //     "defaultCostumeId": 1789,
            //     "seasonCostumeListMap": ..., // This attribute is not provided in Swift API
            //     "ruby": [
            //         "ながさき そよ",
            //         ...
            //     ],
            //     "profile": {
            //         "characterVoice": [
            //             "小日向美香",
            //             ...
            //         ],
            //         "favoriteFood": [
            //             "紅茶、ミネストローネ",
            //             ...
            //         ],
            //         "hatedFood": [
            //             "ホルモン",
            //             ...
            //         ],
            //         "hobby": [
            //             "アロマ",
            //             ...
            //         ],
            //         "selfIntroduction": [
            //             "おっとりした雰囲気のMyGO!!!!!のベーシスト。...",
            //             ...
            //         ],
            //         "school": [
            //             "月ノ森女子学園",
            //             ...
            //         ],
            //         "schoolCls": [
            //             "A組",
            //             ...
            //         ],
            //         "schoolYear": [
            //             "高校1年生",
            //             ...
            //         ],
            //         "part": "base",
            //         "birthday": "959356800000",
            //         "constellation": "gemini",
            //         "height": 162
            //     }
            // }
            let request = await requestJSON("https://bestdori.com/api/characters/\(id).json")
            if case let .success(respJSON) = request {
                let task = Task.detached(priority: .userInitiated) { () async -> Character? in
                    if let characterType = CharacterType(rawValue: respJSON["characterType"].stringValue) {
                        switch characterType {
                        case .unique:
                            return Character(
                                id: id,
                                characterType: characterType,
                                characterName: .init(
                                    jp: respJSON["characterName"][0].string,
                                    en: respJSON["characterName"][1].string,
                                    tw: respJSON["characterName"][2].string,
                                    cn: respJSON["characterName"][3].string,
                                    kr: respJSON["characterName"][4].string
                                ),
                                firstName: .init(
                                    jp: respJSON["firstName"][0].string,
                                    en: respJSON["firstName"][1].string,
                                    tw: respJSON["firstName"][2].string,
                                    cn: respJSON["firstName"][3].string,
                                    kr: respJSON["firstName"][4].string
                                ),
                                lastName: .init(
                                    jp: respJSON["lastName"][0].string,
                                    en: respJSON["lastName"][1].string,
                                    tw: respJSON["lastName"][2].string,
                                    cn: respJSON["lastName"][3].string,
                                    kr: respJSON["lastName"][4].string
                                ),
                                nickname: .init(
                                    jp: respJSON["nickname"][0].string,
                                    en: respJSON["nickname"][1].string,
                                    tw: respJSON["nickname"][2].string,
                                    cn: respJSON["nickname"][3].string,
                                    kr: respJSON["nickname"][4].string
                                ),
                                bandID: respJSON["bandId"].intValue,
                                color: .init(hex: respJSON["colorCode"].stringValue),
                                sdAssetBundleName: respJSON["sdAssetBundleName"].stringValue,
                                defaultCostumeID: respJSON["defaultCostumeId"].intValue,
                                ruby: .init(
                                    jp: respJSON["ruby"][0].string,
                                    en: respJSON["ruby"][1].string,
                                    tw: respJSON["ruby"][2].string,
                                    cn: respJSON["ruby"][3].string,
                                    kr: respJSON["ruby"][4].string
                                ),
                                profile: .init(
                                    characterVoice: .init(
                                        jp: respJSON["profile"]["characterVoice"][0].string,
                                        en: respJSON["profile"]["characterVoice"][1].string,
                                        tw: respJSON["profile"]["characterVoice"][2].string,
                                        cn: respJSON["profile"]["characterVoice"][3].string,
                                        kr: respJSON["profile"]["characterVoice"][4].string
                                    ),
                                    favoriteFood: .init(
                                        jp: respJSON["profile"]["favoriteFood"][0].string,
                                        en: respJSON["profile"]["favoriteFood"][1].string,
                                        tw: respJSON["profile"]["favoriteFood"][2].string,
                                        cn: respJSON["profile"]["favoriteFood"][3].string,
                                        kr: respJSON["profile"]["favoriteFood"][4].string
                                    ),
                                    hatedFood: .init(
                                        jp: respJSON["profile"]["hatedFood"][0].string,
                                        en: respJSON["profile"]["hatedFood"][1].string,
                                        tw: respJSON["profile"]["hatedFood"][2].string,
                                        cn: respJSON["profile"]["hatedFood"][3].string,
                                        kr: respJSON["profile"]["hatedFood"][4].string
                                    ),
                                    hobby: .init(
                                        jp: respJSON["profile"]["hobby"][0].string,
                                        en: respJSON["profile"]["hobby"][1].string,
                                        tw: respJSON["profile"]["hobby"][2].string,
                                        cn: respJSON["profile"]["hobby"][3].string,
                                        kr: respJSON["profile"]["hobby"][4].string
                                    ),
                                    selfIntroduction: .init(
                                        jp: respJSON["profile"]["selfIntroduction"][0].string,
                                        en: respJSON["profile"]["selfIntroduction"][1].string,
                                        tw: respJSON["profile"]["selfIntroduction"][2].string,
                                        cn: respJSON["profile"]["selfIntroduction"][3].string,
                                        kr: respJSON["profile"]["selfIntroduction"][4].string
                                    ),
                                    school: .init(
                                        jp: respJSON["profile"]["school"][0].string,
                                        en: respJSON["profile"]["school"][1].string,
                                        tw: respJSON["profile"]["school"][2].string,
                                        cn: respJSON["profile"]["school"][3].string,
                                        kr: respJSON["profile"]["school"][4].string
                                    ),
                                    schoolClass: .init(
                                        jp: respJSON["profile"]["schoolCls"][0].string,
                                        en: respJSON["profile"]["schoolCls"][1].string,
                                        tw: respJSON["profile"]["schoolCls"][2].string,
                                        cn: respJSON["profile"]["schoolCls"][3].string,
                                        kr: respJSON["profile"]["schoolCls"][4].string
                                    ),
                                    schoolYear: .init(
                                        jp: respJSON["profile"]["schoolYear"][0].string,
                                        en: respJSON["profile"]["schoolYear"][1].string,
                                        tw: respJSON["profile"]["schoolYear"][2].string,
                                        cn: respJSON["profile"]["schoolYear"][3].string,
                                        kr: respJSON["profile"]["schoolYear"][4].string
                                    ),
                                    part: .init(rawValue: respJSON["profile"]["part"].stringValue) ?? .keyboard,
                                    birthday: .init(timeIntervalSince1970: Double(Int64(respJSON["profile"]["birthday"].stringValue.dropLast(3)) ?? 0)),
                                    constellation: .init(rawValue: respJSON["profile"]["constellation"].stringValue) ?? .aries,
                                    height: respJSON["profile"]["height"].intValue
                                )
                            )
                        case .common, .another:
                            return Character(
                                id: id,
                                characterType: characterType,
                                characterName: .init(
                                    jp: respJSON["characterName"][0].string,
                                    en: respJSON["characterName"][1].string,
                                    tw: respJSON["characterName"][2].string,
                                    cn: respJSON["characterName"][3].string,
                                    kr: respJSON["characterName"][4].string
                                ),
                                firstName: .init(
                                    jp: respJSON["firstName"][0].string,
                                    en: respJSON["firstName"][1].string,
                                    tw: respJSON["firstName"][2].string,
                                    cn: respJSON["firstName"][3].string,
                                    kr: respJSON["firstName"][4].string
                                ),
                                lastName: .init(
                                    jp: respJSON["lastName"][0].string,
                                    en: respJSON["lastName"][1].string,
                                    tw: respJSON["lastName"][2].string,
                                    cn: respJSON["lastName"][3].string,
                                    kr: respJSON["lastName"][4].string
                                ),
                                nickname: .init(
                                    jp: respJSON["nickname"][0].string,
                                    en: respJSON["nickname"][1].string,
                                    tw: respJSON["nickname"][2].string,
                                    cn: respJSON["nickname"][3].string,
                                    kr: respJSON["nickname"][4].string
                                ),
                                sdAssetBundleName: respJSON["sdAssetBundleName"].stringValue,
                                ruby: .init(
                                    jp: respJSON["ruby"][0].string,
                                    en: respJSON["ruby"][1].string,
                                    tw: respJSON["ruby"][2].string,
                                    cn: respJSON["ruby"][3].string,
                                    kr: respJSON["ruby"][4].string
                                )
                            )
                        }
                    }
                    return nil
                }
                return await task.value
            }
            return nil
        }
    }
}

extension DoriAPI.Character {
    /// Represent simplified data of a character.
    public struct PreviewCharacter: Sendable, Identifiable, Hashable, DoriCache.Cacheable {
        /// A unique ID of character.
        public var id: Int
        /// Type of character.
        public var characterType: CharacterType
        /// Localized name of character.
        public var characterName: DoriAPI.LocalizedData<String>
        /// Localized nickname of character.
        ///
        /// Only few characters are associateed with a nickname,
        /// mainly in *RAISE A SUILEN*, such as Chiyu has a nickname *CHU²*.
        public var nickname: DoriAPI.LocalizedData<String>
        /// ID of related band to this character.
        public var bandID: Int?
        /// Member color of character.
        public var color: Color? // String(JSON) -> Color(Swift)
        
        internal init(
            id: Int,
            characterType: CharacterType,
            characterName: DoriAPI.LocalizedData<String>,
            nickname: DoriAPI.LocalizedData<String>,
            bandID: Int?,
            color: Color?
        ) {
            self.id = id
            self.characterType = characterType
            self.characterName = characterName
            self.nickname = nickname
            self.bandID = bandID
            self.color = color
        }
    }
    
    /// Represent birthday information of a character.
    public struct BirthdayCharacter: Sendable, Identifiable, Hashable, DoriCache.Cacheable {
        /// A unique ID of character.
        public var id: Int
        /// Localized name of character.
        public var characterName: DoriAPI.LocalizedData<String>
        /// Localized nickname of character.
        ///
        /// Only few characters are associateed with a nickname,
        /// mainly in *RAISE A SUILEN*, such as Chiyu has a nickname *CHU²*.
        public var nickname: DoriAPI.LocalizedData<String>
        /// Birthday of character.
        public var birthday: Date // String(JSON) -> Date(Swift)
    }
    
    /// Represent detailed data of a character.
    public struct Character: Sendable, Identifiable, Hashable, DoriCache.Cacheable {
        /// A unique ID of character.
        public var id: Int
        /// Type of character.
        public var characterType: CharacterType
        /// Localized name of character.
        public var characterName: DoriAPI.LocalizedData<String>
        /// Localized first name of character.
        public var firstName: DoriAPI.LocalizedData<String>
        /// Localized last name of character.
        public var lastName: DoriAPI.LocalizedData<String>
        /// Localized nickname of character.
        ///
        /// Only few characters are associateed with a nickname,
        /// mainly in *RAISE A SUILEN*, such as Chiyu has a nickname *CHU²*.
        public var nickname: DoriAPI.LocalizedData<String>
        /// ID of related band to this character.
        public var bandID: Int?
        /// Member color of character.
        public var color: Color? // String(JSON) -> Color(Swift)
        /// Name of super deformed resource bundle, used for combination of resource URLs.
        public var sdAssetBundleName: String
        /// ID of default costume of character.
        public var defaultCostumeID: Int?
        /// Localized ruby of character's name.
        public var ruby: DoriAPI.LocalizedData<String>
        /// Profile of character
        public var profile: Profile?
        
        internal init(
            id: Int,
            characterType: CharacterType,
            characterName: DoriAPI.LocalizedData<String>,
            firstName: DoriAPI.LocalizedData<String>,
            lastName: DoriAPI.LocalizedData<String>,
            nickname: DoriAPI.LocalizedData<String>,
            bandID: Int?,
            color: Color?,
            sdAssetBundleName: String,
            defaultCostumeID: Int?,
            ruby: DoriAPI.LocalizedData<String>,
            profile: Profile?
        ) {
            self.id = id
            self.characterType = characterType
            self.characterName = characterName
            self.firstName = firstName
            self.lastName = lastName
            self.nickname = nickname
            self.bandID = bandID
            self.color = color
            self.sdAssetBundleName = sdAssetBundleName
            self.defaultCostumeID = defaultCostumeID
            self.ruby = ruby
            self.profile = profile
        }
        internal init(
            id: Int,
            characterType: CharacterType,
            characterName: DoriAPI.LocalizedData<String>,
            firstName: DoriAPI.LocalizedData<String>,
            lastName: DoriAPI.LocalizedData<String>,
            nickname: DoriAPI.LocalizedData<String>,
            sdAssetBundleName: String,
            ruby: DoriAPI.LocalizedData<String>
        ) {
            self.id = id
            self.characterType = characterType
            self.characterName = characterName
            self.firstName = firstName
            self.lastName = lastName
            self.nickname = nickname
            self.sdAssetBundleName = sdAssetBundleName
            self.ruby = ruby
        }
        
        /// Represent profile of a character.
        public struct Profile: Sendable, Hashable, DoriCache.Cacheable {
            /// Localized name of character's voice actor.
            public var characterVoice: DoriAPI.LocalizedData<String>
            /// Localized favorite food of character.
            public var favoriteFood: DoriAPI.LocalizedData<String>
            /// Localized hated food of character.
            public var hatedFood: DoriAPI.LocalizedData<String>
            /// Localized hobby of character.
            public var hobby: DoriAPI.LocalizedData<String>
            /// Localized self-introduction of character.
            public var selfIntroduction: DoriAPI.LocalizedData<String>
            /// Localized school name of character.
            public var school: DoriAPI.LocalizedData<String>
            /// Localized class in school which the character in.
            public var schoolClass: DoriAPI.LocalizedData<String> // named "schoolCls" in JSON, we use "schoolClass" to make it clear
            /// Localized school year which the character in.
            public var schoolYear: DoriAPI.LocalizedData<String>
            /// The part of character works in band.
            public var part: Part
            /// Birthday of character.
            public var birthday: Date // String(JSON) -> Date(Swift)
            /// Constellation of character.
            public var constellation: DoriAPI.Constellation
            /// Height of character, in *centimeter*.
            public var height: Int
            
            /// Represent a part in bands.
            public enum Part: String, Sendable, Hashable, DoriCache.Cacheable {
                case vocal
                case keyboard
                case guitar
                case guitarVocal = "guitar_vocal"
                case bass = "base" // There's a typo in Bestdori's API response, we correct it in Swift API.
                case bassVocal = "base_vocal" // Also typo
                case drum
                case violin
                case dj
            }
        }
    }
    
    /// Represent type of character.
    ///
    /// ``unique`` means this character is in a *main band*,
    /// all other characters are ``common``.
    /// *Misaki* is an exception which is associated ``another``.
    ///
    /// - SeeAlso: Learn more about *main band* in ``DoriAPI/Band/main()``.
    public enum CharacterType: String, Sendable, Hashable, DoriCache.Cacheable {
        case unique
        case common
        case another
    }
}

extension DoriAPI.Character.PreviewCharacter {
    public init(_ full: DoriAPI.Character.Character) {
        self.init(
            id: full.id,
            characterType: full.characterType,
            characterName: full.characterName,
            nickname: full.nickname,
            bandID: full.bandID,
            color: full.color
        )
    }
}
extension DoriAPI.Character.BirthdayCharacter {
    public init?(_ full: DoriAPI.Character.Character) {
        if let birthday = full.profile?.birthday {
            self.init(
                id: full.id,
                characterName: full.characterName,
                nickname: full.nickname,
                birthday: birthday
            )
        } else {
            return nil
        }
    }
}
extension DoriAPI.Character.Character {
    @inlinable
    public init?(id: Int) async {
        if let character = await DoriAPI.Character.detail(of: id) {
            self = character
        } else {
            return nil
        }
    }
    
    @inlinable
    public init?(preview: DoriAPI.Character.PreviewCharacter) async {
        await self.init(id: preview.id)
    }
    @inlinable
    public init?(preview: DoriAPI.Character.BirthdayCharacter) async {
        await self.init(id: preview.id)
    }
}
