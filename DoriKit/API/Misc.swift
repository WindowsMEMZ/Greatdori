//===---*- Greatdori! -*---------------------------------------------------===//
//
// Misc.swift
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
    /// Other uncatogorized requests in Bandori.
    public enum Misc {
        public static func itemTexts() async -> [String: ItemText]? {
            // Response example:
            // {
            //     "item_1": {
            //         "name": [
            //             "ハッピーのかけら(小)",
            //             "Happy Shard (S)",
            //             "ＨＡＰＰＹ的碎片(小)",
            //             "Happy属性碎片(小)",
            //             "해피 조각 (소)"
            //         ],
            //         "resourceId": 1
            //     },
            //     ...
            // }
            let request = await requestJSON("https://bestdori.com/api/misc/itemtexts.2.json")
            if case let .success(respJSON) = request {
                let task = Task.detached(priority: .userInitiated) {
                    var result = [String: ItemText]()
                    for (key, value) in respJSON {
                        result.updateValue(
                            .init(
                                name: .init(
                                    jp: value["name"][0].string,
                                    en: value["name"][1].string,
                                    tw: value["name"][2].string,
                                    cn: value["name"][3].string,
                                    kr: value["name"][4].string
                                ),
                                type: .init(rawValue: value["type"].stringValue) ?? .normal,
                                resourceID: value["resourceId"].intValue
                            ),
                            forKey: key
                        )
                    }
                    return result
                }
                return await task.value
            }
            return nil
        }
        
        public static func mainStories() async -> [Story]? {
            let request = await requestJSON("https://bestdori.com/api/misc/mainstories.5.json")
            if case let .success(respJSON) = request {
                let task = Task.detached(priority: .userInitiated) {
                    var result = [(id: Int, story: Story)]()
                    for (key, value) in respJSON {
                        result.append((
                            Int(key) ?? 0,
                            .init(
                                scenarioID: value["scenarioId"].stringValue,
                                caption: .init(
                                    jp: value["caption"][0].string,
                                    en: value["caption"][1].string,
                                    tw: value["caption"][2].string,
                                    cn: value["caption"][3].string,
                                    kr: value["caption"][4].string
                                ),
                                title: .init(
                                    jp: value["title"][0].string,
                                    en: value["title"][1].string,
                                    tw: value["title"][2].string,
                                    cn: value["title"][3].string,
                                    kr: value["title"][4].string
                                ),
                                synopsis: .init(
                                    jp: value["synopsis"][0].string,
                                    en: value["synopsis"][1].string,
                                    tw: value["synopsis"][2].string,
                                    cn: value["synopsis"][3].string,
                                    kr: value["synopsis"][4].string
                                )
                            )
                        ))
                    }
                    return result.sorted { $0.id < $1.id }.map { $0.story }
                }
                return await task.value
            }
            return nil
        }
        
        public static func bandStories() async -> [BandStory]? {
            let request = await requestJSON("https://bestdori.com/api/misc/bandstories.5.json")
            if case let .success(respJSON) = request {
                let task = Task.detached(priority: .userInitiated) {
                    var result = [BandStory]()
                    for (key, value) in respJSON {
                        result.append(.init(
                            id: Int(key) ?? 0,
                            bandID: value["bandId"].intValue,
                            chapterNumber: value["chapterNumber"].intValue,
                            mainTitle: .init(
                                jp: value["mainTitle"][0].string,
                                en: value["mainTitle"][1].string,
                                tw: value["mainTitle"][2].string,
                                cn: value["mainTitle"][3].string,
                                kr: value["mainTitle"][4].string
                            ),
                            subTitle: .init(
                                jp: value["subTitle"][0].string,
                                en: value["subTitle"][1].string,
                                tw: value["subTitle"][2].string,
                                cn: value["subTitle"][3].string,
                                kr: value["subTitle"][4].string
                            ),
                            publishedAt: .init(
                                jp: value["publishedAt"][0].string != nil ? Date(timeIntervalSince1970: Double(Int(value["publishedAt"][0].stringValue.dropLast(3))!)) : nil,
                                en: value["publishedAt"][1].string != nil ? Date(timeIntervalSince1970: Double(Int(value["publishedAt"][1].stringValue.dropLast(3))!)) : nil,
                                tw: value["publishedAt"][2].string != nil ? Date(timeIntervalSince1970: Double(Int(value["publishedAt"][2].stringValue.dropLast(3))!)) : nil,
                                cn: value["publishedAt"][3].string != nil ? Date(timeIntervalSince1970: Double(Int(value["publishedAt"][3].stringValue.dropLast(3))!)) : nil,
                                kr: value["publishedAt"][4].string != nil ? Date(timeIntervalSince1970: Double(Int(value["publishedAt"][4].stringValue.dropLast(3))!)) : nil
                            ),
                            stories: value["stories"].map {
                                (id: Int($0.0) ?? 0,
                                 value: DoriAPI.Story(
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
                                    ),
                                    voiceAssetBundleName: $0.1["voiceAssetBundleName"].stringValue
                                 ))
                            }.sorted { $0.id < $1.id }.map { $0.value }
                        ))
                    }
                    return result.sorted { $0.id < $1.id }
                }
                return await task.value
            }
            return nil
        }
        
        public static func afterLiveTalks() async -> [AfterLiveTalk]? {
            let request = await requestJSON("https://bestdori.com/api/misc/afterlivetalks.5.json")
            if case let .success(respJSON) = request {
                let task = Task.detached(priority: .userInitiated) {
                    var result = [AfterLiveTalk]()
                    for (key, value) in respJSON {
                        result.append(.init(
                            id: Int(key) ?? 0,
                            scenarioID: value["scenarioId"].stringValue,
                            description: .init(
                                jp: value["description"][0].string,
                                en: value["description"][1].string,
                                tw: value["description"][2].string,
                                cn: value["description"][3].string,
                                kr: value["description"][4].string
                            )
                        ))
                    }
                    return result.sorted { $0.id < $1.id }
                }
                return await task.value
            }
            return nil
        }
        
        public static func areas() async -> [Area]? {
            let request = await requestJSON("https://bestdori.com/api/misc/areas.1.json")
            if case let .success(respJSON) = request {
                let task = Task.detached(priority: .userInitiated) {
                    var result = [Area]()
                    for (key, value) in respJSON {
                        result.append(.init(
                            id: Int(key) ?? 0,
                            areaName: .init(
                                jp: value["areaName"][0].string,
                                en: value["areaName"][1].string,
                                tw: value["areaName"][2].string,
                                cn: value["areaName"][3].string,
                                kr: value["areaName"][4].string
                            )
                        ))
                    }
                    return result.sorted { $0.id < $1.id }
                }
                return await task.value
            }
            return nil
        }
        
        public static func actionSets() async -> [ActionSet]? {
            let request = await requestJSON("https://bestdori.com/api/misc/actionsets.5.json")
            if case let .success(respJSON) = request {
                let task = Task.detached(priority: .userInitiated) {
                    var result = [ActionSet]()
                    for (key, value) in respJSON {
                        result.append(.init(
                            id: Int(key) ?? 0,
                            areaID: value["areaId"].intValue,
                            characterIDs: value["characterIds"].map { $0.1.intValue },
                            actionSetType: .init(rawValue: value["actionSetType"].stringValue) ?? .normal
                        ))
                    }
                    return result.sorted { $0.id < $1.id }
                }
                return await task.value
            }
            return nil
        }
        
        public static func eventStoryAsset(eventID: Int, scenarioID: String, locale: DoriAPI.Locale) async -> StoryAsset? {
            let request = await requestJSON("https://bestdori.com/assets/\(locale.rawValue)/scenario/eventstory/event\(eventID)_rip/Scenario\(scenarioID).asset")
            if case let .success(respJSON) = request {
                return await _parseStoryAsset(respJSON)
            }
            return nil
        }
        public static func mainStoryAsset(scenarioID: String, locale: DoriAPI.Locale) async -> StoryAsset? {
            let request = await requestJSON("https://bestdori.com/assets/\(locale.rawValue)/scenario/main_rip/Scenario\(scenarioID).asset")
            if case let .success(respJSON) = request {
                return await _parseStoryAsset(respJSON)
            }
            return nil
        }
        public static func bandStoryAsset(bandID: Int, scenarioID: String, locale: DoriAPI.Locale) async -> StoryAsset? {
            var bandID = String(bandID)
            while bandID.count < 3 {
                bandID = "0" + bandID
            }
            let request = await requestJSON("https://bestdori.com/assets/\(locale.rawValue)/scenario/band/\(bandID)_rip/Scenario\(scenarioID).asset")
            if case let .success(respJSON) = request {
                return await _parseStoryAsset(respJSON)
            }
            return nil
        }
        public static func cardStoryAsset(resourceSetName: String, scenarioID: String, locale: DoriAPI.Locale) async -> StoryAsset? {
            let request = await requestJSON("https://bestdori.com/assets/\(locale.rawValue)/characters/resourceset/\(resourceSetName)_rip/Scenario\(scenarioID).asset")
            if case let .success(respJSON) = request {
                return await _parseStoryAsset(respJSON)
            }
            return nil
        }
        public static func actionSetStoryAsset(actionSetID: Int, locale: DoriAPI.Locale) async -> StoryAsset? {
            let _request = await requestJSON("https://bestdori.com/assets/\(locale.rawValue)/actionset/group\(Int(floor(Double(actionSetID / 128))))_rip/ActionSet\(actionSetID).asset")
            if case let .success(respJSON) = _request {
                let id = respJSON["Base"]["details"][0]["reactionTypeBelongId"].stringValue
                let request = await requestJSON("https://bestdori.com/assets/\(locale.rawValue)/scenario/actionset/group\(Int(floor(Double(actionSetID / 256))))_rip/Scenario\(id).asset")
                if case let .success(respJSON) = request {
                    return await _parseStoryAsset(respJSON)
                }
            }
            return nil
        }
        public static func afterLiveStoryAsset(talkID: Int, scenarioID: String, locale: DoriAPI.Locale) async -> StoryAsset? {
            let request = await requestJSON("https://bestdori.com/assets/\(locale.rawValue)/scenario/afterlivetalk/group\(Int(floor(Double(talkID / 256))))_rip/Scenario\(scenarioID).asset")
            if case let .success(respJSON) = request {
                return await _parseStoryAsset(respJSON)
            }
            return nil
        }
        internal static func _parseStoryAsset(_ json: JSON) async -> StoryAsset {
            let task = Task.detached(priority: .userInitiated) {
                let base = json["Base"]
                return StoryAsset(
                    scenarioSceneID: base["scenarioSceneId"].stringValue,
                    storyType: base["storyType"].intValue,
                    appearCharacters: base["appearCharacters"].map {
                        .init(
                            characterID: $0.1["characterId"].intValue,
                            costumeType: $0.1["costumeType"].stringValue
                        )
                    },
                    firstBGM: base["firstBgm"].stringValue,
                    firstBackground: base["firstBackground"].stringValue,
                    firstBackgroundBundleName: base["firstBackgroundBundleName"].stringValue,
                    snippets: base["snippets"].map {
                        .init(
                            actionType: .init(rawValue: $0.1["actionType"].intValue) ?? .none,
                            progressType: $0.1["progressType"].intValue,
                            referenceIndex: $0.1["referenceIndex"].intValue,
                            delay: $0.1["delay"].doubleValue,
                            isWaitForSkipMode: $0.1["isWaitForSkipMode"].intValue != 0
                        )
                    },
                    talkData: base["talkData"].map {
                        .init(
                            talkCharacters: $0.1["talkCharacters"].map {
                                .init(characterID: $0.1["characterId"].intValue)
                            },
                            windowDisplayName: $0.1["windowDisplayName"].stringValue,
                            body: $0.1["body"].stringValue,
                            tention: $0.1["tention"].intValue,
                            lipSyncMode: $0.1["lipSyncMode"].intValue,
                            motionChangeFactor: $0.1["motionChangeFactor"].intValue,
                            motions: $0.1["motions"].map {
                                .init(
                                    characterID: $0.1["characterId"].intValue,
                                    motionName: $0.1["motionName"].stringValue,
                                    expressionName: $0.1["expressionName"].stringValue,
                                    timingSyncValue: $0.1["timingSyncValue"].stringValue
                                )
                            },
                            voices: $0.1["voices"].map {
                                .init(
                                    characterID: $0.1["characterId"].intValue,
                                    voiceID: $0.1["voiceId"].stringValue,
                                    volume: $0.1["volume"].doubleValue
                                )
                            },
                            speed: $0.1["speed"].intValue,
                            fontSize: $0.1["fontSize"].intValue,
                            whenFinishCloseWindow: $0.1["whenFinishCloseWindow"].intValue != 0,
                            requirePlayEffect: $0.1["requirePlayEffect"].intValue != 0,
                            effectReferenceIdx: $0.1["effectReferenceIdx"].intValue,
                            requirePlaySound: $0.1["requirePlaySound"].intValue != 0,
                            soundReferenceIdx: $0.1["soundReferenceIdx"].intValue,
                            whenStartHideWindow: $0.1["whenStartHideWindow"].intValue != 0
                        )
                    },
                    layoutData: base["layoutData"].map {
                        .init(
                            type: $0.1["type"].intValue,
                            sideFrom: $0.1["sideFrom"].intValue,
                            sideFromOffsetX: $0.1["sideFromOffsetX"].intValue,
                            sideTo: $0.1["sideTo"].intValue,
                            sideToOffsetX: $0.1["sideToOffsetX"].intValue,
                            depthType: $0.1["depthType"].intValue,
                            characterID: $0.1["characterId"].intValue,
                            costumeType: $0.1["costumeType"].stringValue,
                            motionName: $0.1["motionName"].stringValue,
                            expressionName: $0.1["expressionName"].stringValue,
                            moveSpeedType: $0.1["moveSpeedType"].intValue
                        )
                    },
                    specialEffectData: base["specialEffectData"].map {
                        .init(
                            effectType: .init(rawValue: $0.1["effectType"].intValue) ?? .none,
                            stringVal: $0.1["stringVal"].stringValue,
                            stringValSub: $0.1["stringValSub"].stringValue,
                            duration: $0.1["duration"].doubleValue,
                            animationTriggerName: $0.1["animationTriggerName"].stringValue
                        )
                    },
                    soundData: base["soundData"].map {
                        .init(
                            playMode: $0.1["playMode"].intValue,
                            bgm: $0.1["bgm"].stringValue,
                            se: $0.1["se"].stringValue,
                            volume: $0.1["volume"].doubleValue,
                            seBundleName: $0.1["seBundleName"].stringValue,
                            duration: $0.1["duration"].doubleValue
                        )
                    },
                    includeSoundDataBundleNames: base["includeSoundDataBundleNames"].map { $0.1.stringValue }
                )
            }
            return await task.value
        }
        
        public static func playerProfile(of id: Int, in locale: Locale) async -> PlayerProfile? {
            let request = await requestJSON("https://bestdori.com/api/player/\(locale.rawValue)/\(id)?mode=2")
            if case let .success(respJSON) = request {
                let task = Task.detached(priority: .userInitiated) { () -> PlayerProfile? in
                    guard respJSON["result"].boolValue else { return nil }
                    let profile = respJSON["data"]["profile"]
                    
                    var flagsValue: UInt16 = 0
                    if profile["publishTotalDeckPowerFlg"].boolValue {
                        flagsValue |= PlayerProfile.Flags.publishTotalDeckPower.rawValue
                    }
                    if profile["publishBandRankFlg"].boolValue {
                        flagsValue |= PlayerProfile.Flags.publishBandRank.rawValue
                    }
                    if profile["publishMusicClearedFlg"].boolValue {
                        flagsValue |= PlayerProfile.Flags.publishMusicCleared.rawValue
                    }
                    if profile["publishMusicFullComboFlg"].boolValue {
                        flagsValue |= PlayerProfile.Flags.publishMusicFullCombo.rawValue
                    }
                    if profile["publishHighScoreRatingFlg"].boolValue {
                        flagsValue |= PlayerProfile.Flags.publishHighScoreRating.rawValue
                    }
                    if profile["publishUserIdFlg"].boolValue {
                        flagsValue |= PlayerProfile.Flags.publishUserID.rawValue
                    }
                    if profile["searchableFlg"].boolValue {
                        flagsValue |= PlayerProfile.Flags.searchable.rawValue
                    }
                    if profile["publishUpdatedAtFlg"].boolValue {
                        flagsValue |= PlayerProfile.Flags.publishUpdatedAt.rawValue
                    }
                    if profile["friendApplicableFlg"].boolValue {
                        flagsValue |= PlayerProfile.Flags.friendApplicable.rawValue
                    }
                    if profile["publishMusicAllPerfectFlg"].boolValue {
                        flagsValue |= PlayerProfile.Flags.publishMusicAllPerfect.rawValue
                    }
                    if profile["publishDeckRankFlg"].boolValue {
                        flagsValue |= PlayerProfile.Flags.publishDeckRank.rawValue
                    }
                    if profile["publishStageChallengeAchievementConditionsFlg"].boolValue {
                        flagsValue |= PlayerProfile.Flags.publishStageChallengeAchievementConditions.rawValue
                    }
                    if profile["publishStageChallengeFriendRankingFlg"].boolValue {
                        flagsValue |= PlayerProfile.Flags.publishStageChallengeFriendRanking.rawValue
                    }
                    if profile["publishCharacterRankFlg"].boolValue {
                        flagsValue |= PlayerProfile.Flags.publishCharacterRank.rawValue
                    }
                    
                    func highScoreMusic(for key: String) -> [PlayerProfile.HighScoreRating.HighScoreMusic] {
                        profile["userHighScoreRating"][key]["entries"].map {
                            .init(
                                musicID: $0.1["musicId"].intValue,
                                difficulty: .init(rawStringValue: $0.1["difficulty"].stringValue) ?? .easy,
                                rating: $0.1["rating"].intValue
                            )
                        }
                    }
                    
                    let userMusicClearInfo = profile["userMusicClearInfoMap"]["entries"].map {
                        (key: DoriAPI.Song.DifficultyType(rawStringValue: $0.0) ?? .easy,
                         value: PlayerProfile.MusicClearInfo(
                            clearedMusicCount: $0.1["clearedMusicCount"].intValue,
                            fullComboMusicCount: $0.1["fullComboMusicCount"].intValue,
                            allPerfectMusicCount: $0.1["allPerfectMusicCount"].intValue
                         ))
                    }.reduce(into: [DoriAPI.Song.DifficultyType: PlayerProfile.MusicClearInfo]()) { $0.updateValue($1.value, forKey: $1.key) }
                    let stageChallengeAchievementConditions = profile["stageChallengeAchievementConditionsMap"]["entries"].map {
                        (key: Int($0.0) ?? 0, value: $0.1.intValue)
                    }.reduce(into: [Int: Int]()) { $0.updateValue($1.value, forKey: $1.key) }
                    
                    return .init(
                        userName: profile["userName"].stringValue,
                        rank: profile["rank"].intValue,
                        degree: profile["degree"].intValue,
                        introduction: profile["introduction"].stringValue,
                        flags: .init(rawValue: flagsValue),
                        mainDeckUserSituations: profile["mainDeckUserSituations"]["entries"].map {
                            .init(
                                userID: Int($0.1["userId"].stringValue) ?? 0,
                                situationID: $0.1["situationId"].intValue,
                                level: $0.1["level"].intValue,
                                exp: $0.1["exp"].intValue,
                                createdAt: .init(timeIntervalSince1970: Double(Int($0.1["createdAt"][0].stringValue.dropLast(3))!)),
                                addExp: $0.1["addExp"].intValue,
                                trained: $0.1["trainingStatus"].stringValue == "done",
                                duplicateCount: $0.1["duplicateCount"].intValue,
                                illust: $0.1["illust"].stringValue,
                                skillExp: $0.1["skillExp"].intValue,
                                skillLevel: $0.1["skillLevel"].intValue,
                                userAppendParameter: .init(
                                    stat: .init(
                                        performance: $0.1["userAppendParameter"]["performance"].intValue,
                                        technique: $0.1["userAppendParameter"]["technique"].intValue,
                                        visual: $0.1["userAppendParameter"]["visual"].intValue
                                    ),
                                    characterPotentialStat: .init(
                                        performance: $0.1["userAppendParameter"]["characterPotentialPerformance"].intValue,
                                        technique: $0.1["userAppendParameter"]["characterPotentialTechnique"].intValue,
                                        visual: $0.1["userAppendParameter"]["characterPotentialVisual"].intValue
                                    ),
                                    characterBonusStat: .init(
                                        performance: $0.1["userAppendParameter"]["characterBonusPerformance"].intValue,
                                        technique: $0.1["userAppendParameter"]["characterBonusTechnique"].intValue,
                                        visual: $0.1["userAppendParameter"]["characterBonusVisual"].intValue
                                    )
                                ),
                                limitBreakRank: $0.1["limitBreakRank"].intValue
                            )
                        },
                        userHighScoreRating: .init(
                            poppinParty: highScoreMusic(for: "userPoppinPartyHighScoreMusicList"),
                            afterglow: highScoreMusic(for: "userAfterglowHighScoreMusicList"),
                            pastelPalettes: highScoreMusic(for: "userPastelPalettesHighScoreMusicList"),
                            helloHappyWorld: highScoreMusic(for: "userHelloHappyWorldHighScoreMusicList"),
                            roselia: highScoreMusic(for: "userRoseliaHighScoreMusicList"),
                            morfonica: highScoreMusic(for: "userMorfonicaHighScoreMusicList"),
                            raiseASuilen: highScoreMusic(for: "userRaiseASuilenHighScoreMusicList"),
                            myGO: highScoreMusic(for: "userMyGOScoreMusicList"),
                            others: highScoreMusic(for: "userOtherHighScoreMusicList")
                        ),
                        mainUserDeck: .init(
                            deckID: profile["mainUserDeck"]["deckId"].intValue,
                            deckName: profile["mainUserDeck"]["deckName"].stringValue,
                            leader: profile["mainUserDeck"]["leader"].intValue,
                            member1: profile["mainUserDeck"]["member1"].intValue,
                            member2: profile["mainUserDeck"]["member2"].intValue,
                            member3: profile["mainUserDeck"]["member3"].intValue,
                            member4: profile["mainUserDeck"]["member4"].intValue
                        ),
                        userProfileSituation: .init(
                            userID: Int(profile["userProfileSituation"]["userId"].stringValue) ?? 0,
                            situationID: profile["userProfileSituation"]["situationId"].intValue,
                            illust: profile["userProfileSituation"]["illust"].stringValue,
                            viewProfileSituationStatus: profile["userProfileSituation"]["viewProfileSituationStatus"].stringValue
                        ),
                        userProfileDegree: [
                            profile["userProfileDegreeMap"]["entries"]["first"]["degreeId"].int,
                            profile["userProfileDegreeMap"]["entries"]["second"]["degreeId"].int
                        ],
                        stageChallengeAchievementConditions: stageChallengeAchievementConditions,
                        userMusicClearInfo: userMusicClearInfo
                    )
                }
                return await task.value
            }
            return nil
        }
    }
}

// We declare extension of `DoriAPI` instead of `DoriAPI.Misc`
// to make them can be found easier.
extension DoriAPI {
    public struct Item: Sendable, Identifiable, Hashable, DoriCache.Cacheable {
        public var itemID: Int?
        public var type: ItemType
        public var quantity: Int
        
        internal init(itemID: Int?, type: ItemType, quantity: Int) {
            self.itemID = itemID
            self.type = type
            self.quantity = quantity
        }
        
        @inlinable
        public var id: String {
            if let itemID {
                type.rawValue + String(itemID)
            } else {
                type.rawValue
            }
        }
        
        public enum ItemType: String, Sendable, Hashable, DoriCache.Cacheable {
            case item
            case star
            case coin
            case gachaTicket = "gacha_ticket"
            case practiceTicket = "practice_ticket"
            case miracleTicket = "miracle_ticket"
            case liveBoostRecoveryItem = "live_boost_recovery_item"
            case stamp
            case voiceStamp = "voice_stamp"
            case situation
            case costume3DMakingItem = "costume_3d_making_item"
            case degree
        }
    }
    
    public struct Story: Sendable, Identifiable, Hashable, DoriCache.Cacheable {
        public var scenarioID: String
        public var caption: LocalizedData<String>
        public var title: LocalizedData<String>
        public var synopsis: LocalizedData<String>
        public var voiceAssetBundleName: String?
        
        public var id: String { scenarioID }
    }
}

// These declerations are less used so we define it in
// extension of `DoriAPI.Misc`
extension DoriAPI.Misc {
    public struct ItemText: Sendable, Hashable, DoriCache.Cacheable {
        public var name: DoriAPI.LocalizedData<String>
        public var type: ItemType?
        public var resourceID: Int
        
        internal init(name: DoriAPI.LocalizedData<String>, type: ItemType?, resourceID: Int) {
            self.name = name
            self.type = type
            self.resourceID = resourceID
        }
        
        public enum ItemType: String, Sendable, Hashable, DoriCache.Cacheable {
            case normal
            case practice
            case special
            case skillPractice = "skill_practice"
            case normalTicket = "normal_ticket"
            case gamonTicket1 = "gamon_ticket_1"
            case gamonTicket2 = "gamon_ticket_2"
            case gamonTicket3 = "gamon_ticket_3"
            case overThe3StarTicket = "over_the_3_star_ticket"
            case spend1Fixed4StarTicket = "spend_1_fixed_4_star_ticket"
            case spend2Fixed4StarTicket = "spend_2_fixed_4_star_ticket"
            case spend3Fixed4StarTicket = "spend_3_fixed_4_star_ticket"
            case fixed4StarTicket = "fixed_4_star_ticket"
            case fesFixed4StarTicket = "fes_fixed_4_star_ticket"
            case overThe4StarTicket = "over_the_4_star_ticket"
            case fixed5StarTicket = "fixed_5_star_ticket"
        }
    }
    
    public struct BandStory: Sendable, Identifiable, Hashable, DoriCache.Cacheable {
        public var id: Int
        public var bandID: Int
        public var chapterNumber: Int
        public var mainTitle: DoriAPI.LocalizedData<String>
        public var subTitle: DoriAPI.LocalizedData<String>
        public var publishedAt: DoriAPI.LocalizedData<Date>
        public var stories: [DoriAPI.Story]
    }
    public struct AfterLiveTalk: Sendable, Identifiable, Hashable, DoriCache.Cacheable {
        public var id: Int
        public var scenarioID: String
        public var description: DoriAPI.LocalizedData<String>
    }
    
    public struct Area: Sendable, Identifiable, Hashable, DoriCache.Cacheable {
        public var id: Int
        public var areaName: DoriAPI.LocalizedData<String>
    }
    public struct ActionSet: Sendable, Identifiable, Hashable, DoriCache.Cacheable {
        public var id: Int
        public var areaID: Int
        public var characterIDs: [Int]
        public var actionSetType: ActionSetType
        
        public enum ActionSetType: String, Sendable, Hashable, DoriCache.Cacheable {
            case normal
            case birthday
            case areaItem = "area_item"
            case periodLimitedArea = "period_limited_area"
        }
    }
    
    public struct StoryAsset: Sendable, Hashable, DoriCache.Cacheable {
        public var scenarioSceneID: String
        public var storyType: Int
        public var appearCharacters: [AppearCharacter]
        public var firstBGM: String
        public var firstBackground: String
        public var firstBackgroundBundleName: String
        public var snippets: [Snippet]
        public var talkData: [TalkData]
        public var layoutData: [LayoutData]
        public var specialEffectData: [SpecialEffectData]
        public var soundData: [SoundData]
        public var includeSoundDataBundleNames: [String]
        
        public struct AppearCharacter: Sendable, Hashable, DoriCache.Cacheable {
            public var characterID: Int
            public var costumeType: String
        }
        public struct Snippet: Sendable, Hashable, DoriCache.Cacheable {
            public var actionType: ActionType
            public var progressType: Int
            public var referenceIndex: Int
            public var delay: Double
            public var isWaitForSkipMode: Bool // Int(JSON) -> Bool(Swift)
            
            public enum ActionType: Int, Sendable, Hashable, DoriCache.Cacheable {
                case none
                case talk
                case layout
                case input
                case motion
                case selectable
                case effect
                case sound
            }
        }
        public struct TalkData: Sendable, Hashable, DoriCache.Cacheable {
            public var talkCharacters: [TalkCharacter]
            public var windowDisplayName: String
            public var body: String
            public var tention: Int
            public var lipSyncMode: Int
            public var motionChangeFactor: Int
            public var motions: [Motion]
            public var voices: [Voice]
            public var speed: Int
            public var fontSize: Int
            public var whenFinishCloseWindow: Bool // Int(JSON) -> Bool(Swift)
            public var requirePlayEffect: Bool // Int(JSON) -> Bool(Swift)
            public var effectReferenceIdx: Int
            public var requirePlaySound: Bool // Int(JSON) -> Bool(Swift)
            public var soundReferenceIdx: Int
            public var whenStartHideWindow: Bool // Int(JSON) -> Bool(Swift)
            
            public struct TalkCharacter: Sendable, Hashable, DoriCache.Cacheable {
                public var characterID: Int
            }
            public struct Motion: Sendable, Hashable, DoriCache.Cacheable {
                public var characterID: Int
                public var motionName: String
                public var expressionName: String
                public var timingSyncValue: String
            }
            public struct Voice: Sendable, Hashable, DoriCache.Cacheable {
                public var characterID: Int
                public var voiceID: String
                public var volume: Double
            }
        }
        public struct LayoutData: Sendable, Hashable, DoriCache.Cacheable {
            public var type: Int
            public var sideFrom: Int
            public var sideFromOffsetX: Int
            public var sideTo: Int
            public var sideToOffsetX: Int
            public var depthType: Int
            public var characterID: Int
            public var costumeType: String
            public var motionName: String
            public var expressionName: String
            public var moveSpeedType: Int
        }
        public struct SpecialEffectData: Sendable, Hashable, DoriCache.Cacheable {
            public var effectType: EffectType
            public var stringVal: String
            public var stringValSub: String
            public var duration: Double
            public var animationTriggerName: String
            
            public enum EffectType: Int, Sendable, Hashable, DoriCache.Cacheable {
                case none
                case blackIn
                case blackOut
                case whiteIn
                case whiteOut
                case shakeScreen
                case shakeWindow
                case changeBackground
                case telop
                case flashbackIn
                case flashbackOut
                case changeCardStill
                case ambientColorNormal
                case ambientColorEvening
                case ambientColorNight
                case playScenarioEffect
                case stopScenarioEffect
                case changeBackgroundStill
            }
        }
        public struct SoundData: Sendable, Hashable, DoriCache.Cacheable {
            public var playMode: Int
            public var bgm: String
            public var se: String
            public var volume: Double
            public var seBundleName: String
            public var duration: Double
        }
    }
    
    public struct PlayerProfile: Sendable, Hashable, DoriCache.Cacheable {
        public var userName: String
        public var rank: Int
        public var degree: Int
        public var introduction: String
        public var flags: Flags // Bool<.+Flg>(JSON) -> Flags(:OptionSet)(Swift)
        public var mainDeckUserSituations: [Situation]
        public var userHighScoreRating: HighScoreRating
        public var mainUserDeck: UserDeck
        public var userProfileSituation: ProfileSituation
        public var userProfileDegree: [Int?] // [FirstID, SecondID]
        public var stageChallengeAchievementConditions: [Int: Int]
        public var userMusicClearInfo: [DoriAPI.Song.DifficultyType: MusicClearInfo]
        
        public struct Flags: Sendable, OptionSet, Hashable, DoriCache.Cacheable {
            public var rawValue: UInt16
            
            public init(rawValue: UInt16) {
                self.rawValue = rawValue
            }
            
            public static let publishTotalDeckPower                      = Flags(rawValue: 1 << 0)
            public static let publishBandRank                            = Flags(rawValue: 1 << 1)
            public static let publishMusicCleared                        = Flags(rawValue: 1 << 2)
            public static let publishMusicFullCombo                      = Flags(rawValue: 1 << 3)
            public static let publishHighScoreRating                     = Flags(rawValue: 1 << 4)
            public static let publishUserID                              = Flags(rawValue: 1 << 5)
            public static let searchable                                 = Flags(rawValue: 1 << 6)
            public static let publishUpdatedAt                           = Flags(rawValue: 1 << 7)
            public static let friendApplicable                           = Flags(rawValue: 1 << 8)
            public static let publishMusicAllPerfect                     = Flags(rawValue: 1 << 9)
            public static let publishDeckRank                            = Flags(rawValue: 1 << 10)
            public static let publishStageChallengeAchievementConditions = Flags(rawValue: 1 << 11)
            public static let publishStageChallengeFriendRanking         = Flags(rawValue: 1 << 12)
            public static let publishCharacterRank                       = Flags(rawValue: 1 << 13)
        }
        
        public struct Situation: Sendable, Hashable, DoriCache.Cacheable {
            public var userID: Int
            public var situationID: Int
            public var level: Int
            public var exp: Int
            public var createdAt: Date
            public var addExp: Int
            public var trained: Bool // String<trainingStatus>(JSON) -> Bool<trained>(Swift)
                                     // true where trainingStatus == "done"
            public var duplicateCount: Int
            public var illust: String
            public var skillExp: Int
            public var skillLevel: Int
            public var userAppendParameter: AppendParameter
            public var limitBreakRank: Int
            
            public struct AppendParameter: Sendable, Hashable, DoriCache.Cacheable {
                public var stat: DoriAPI.Card.Stat // Int<performance|technique|visual>(JSON) -> Stat(Swift)
                public var characterPotentialStat: DoriAPI.Card.Stat // Int<characterPotential.+>(JSON) -> Stat(Swift)
                public var characterBonusStat: DoriAPI.Card.Stat // Int<characterPotential.+>(JSON) -> Stat(Swift)
            }
        }
        
        public struct HighScoreRating: Sendable, Hashable, DoriCache.Cacheable {
            public var poppinParty: [HighScoreMusic]
            public var afterglow: [HighScoreMusic]
            public var pastelPalettes: [HighScoreMusic]
            public var helloHappyWorld: [HighScoreMusic]
            public var roselia: [HighScoreMusic]
            public var morfonica: [HighScoreMusic]
            public var raiseASuilen: [HighScoreMusic]
            public var myGO: [HighScoreMusic]
            public var others: [HighScoreMusic]
            
            public struct HighScoreMusic: Sendable, Hashable, DoriCache.Cacheable {
                public var musicID: Int
                public var difficulty: DoriAPI.Song.DifficultyType
                public var rating: Int
            }
        }
        
        public struct UserDeck: Sendable, Hashable, DoriCache.Cacheable {
            public var deckID: Int
            public var deckName: String
            public var leader: Int
            public var member1: Int
            public var member2: Int
            public var member3: Int
            public var member4: Int
        }
        
        public struct ProfileSituation: Sendable, Hashable, DoriCache.Cacheable {
            public var userID: Int
            public var situationID: Int
            public var illust: String
            public var viewProfileSituationStatus: String
        }
        
        public struct MusicClearInfo: Sendable, Hashable, DoriCache.Cacheable {
            public var clearedMusicCount: Int
            public var fullComboMusicCount: Int
            public var allPerfectMusicCount: Int
        }
    }
}
