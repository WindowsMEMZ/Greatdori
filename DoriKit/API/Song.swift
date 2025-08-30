//===---*- Greatdori! -*---------------------------------------------------===//
//
// Song.swift
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
    /// Request and fetch data about songs in Bandori.
    public enum Song {
        /// Get all songs in Bandori.
        ///
        /// The results have guaranteed sorting by ID.
        ///
        /// - Returns: Requested songs, nil if failed to fetch data.
        public static func all() async -> [PreviewSong]? {
            // Response example:
            // {
            //     "1": {
            //         "tag": "normal",
            //         "bandId": 1,
            //         "jacketImage": [
            //             "yes_bang_dream"
            //         ],
            //         "musicTitle": [
            //             "Yes! BanG_Dream!",
            //             "Yes! BanG_Dream!",
            //             "Yes! BanG_Dream!",
            //             "Yes! BanG_Dream!",
            //             "Yes! BanG_Dream!"
            //         ],
            //         "publishedAt": [
            //             "1462071600000",
            //             ...
            //         ],
            //         "closedAt": [
            //             "4102369200000",
            //             ...
            //         ],
            //         "difficulty": {
            //             "0": {
            //                 "playLevel": 5
            //             },
            //             ...
            //         }
            //     },
            //     ...
            // }
            let request = await requestJSON("https://bestdori.com/api/songs/all.7.json")
            if case let .success(respJSON) = request {
                let task = Task.detached(priority: .userInitiated) {
                    var result = [PreviewSong]()
                    for (key, value) in respJSON {
                        let notes = value["notes"].map {
                            (key: DoriAPI.Song.DifficultyType(rawValue: Int($0.0)!) ?? .easy,
                             value: $0.1.intValue)
                        }.reduce(into: [DifficultyType: Int]()) { $0.updateValue($1.value, forKey: $1.key) }
                        
                        let bpm = value["bpm"].map {
                            (key: DoriAPI.Song.DifficultyType(rawValue: Int($0.0)!) ?? .easy,
                             value: $0.1.map {
                                BPM(bpm: $0.1["bpm"].intValue, start: $0.1["start"].doubleValue, end: $0.1["end"].doubleValue)
                            })
                        }.reduce(into: [DifficultyType: [BPM]]()) { $0.updateValue($1.value, forKey: $1.key) }
                        
                        result.append(.init(
                            id: Int(key) ?? 0,
                            tag: .init(rawValue: value["tag"].stringValue) ?? .normal,
                            bandID: value["bandId"].intValue,
                            jacketImage: value["jacketImage"].map { $0.1.stringValue },
                            musicTitle: .init(
                                jp: value["musicTitle"][0].string,
                                en: value["musicTitle"][1].string,
                                tw: value["musicTitle"][2].string,
                                cn: value["musicTitle"][3].string,
                                kr: value["musicTitle"][4].string
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
                            difficulty: value["difficulty"].map {
                                (key: DifficultyType(rawValue: Int($0.0) ?? 0) ?? .easy,
                                 value: PreviewSong.Difficulty(
                                    playLevel: $0.1["playLevel"].intValue,
                                    publishedAt: $0.1["publishedAt"].null == nil ? .init(
                                        jp: $0.1["publishedAt"][0].string != nil ? Date(timeIntervalSince1970: Double(Int($0.1["publishedAt"][0].stringValue.dropLast(3))!)) : nil,
                                        en: $0.1["publishedAt"][1].string != nil ? Date(timeIntervalSince1970: Double(Int($0.1["publishedAt"][1].stringValue.dropLast(3))!)) : nil,
                                        tw: $0.1["publishedAt"][2].string != nil ? Date(timeIntervalSince1970: Double(Int($0.1["publishedAt"][2].stringValue.dropLast(3))!)) : nil,
                                        cn: $0.1["publishedAt"][3].string != nil ? Date(timeIntervalSince1970: Double(Int($0.1["publishedAt"][3].stringValue.dropLast(3))!)) : nil,
                                        kr: $0.1["publishedAt"][4].string != nil ? Date(timeIntervalSince1970: Double(Int($0.1["publishedAt"][4].stringValue.dropLast(3))!)) : nil
                                    ) : nil
                                 ))
                            }.reduce(into: [DifficultyType: PreviewSong.Difficulty]()) {
                                $0.updateValue($1.value, forKey: $1.key)
                            },
                            length: value["length"].doubleValue,
                            notes: notes,
                            bpm: bpm,
                            musicVideos: value["musicVideos"].exists() ? value["musicVideos"].map {
                                (key: $0.0,
                                 value: MusicVideoMetadata(
                                    startAt: .init(
                                        jp: $0.1["startAt"][0].string != nil ? Date(timeIntervalSince1970: Double(Int($0.1["startAt"][0].stringValue.dropLast(3))!)) : nil,
                                        en: $0.1["startAt"][1].string != nil ? Date(timeIntervalSince1970: Double(Int($0.1["startAt"][1].stringValue.dropLast(3))!)) : nil,
                                        tw: $0.1["startAt"][2].string != nil ? Date(timeIntervalSince1970: Double(Int($0.1["startAt"][2].stringValue.dropLast(3))!)) : nil,
                                        cn: $0.1["startAt"][3].string != nil ? Date(timeIntervalSince1970: Double(Int($0.1["startAt"][3].stringValue.dropLast(3))!)) : nil,
                                        kr: $0.1["startAt"][4].string != nil ? Date(
                                            timeIntervalSince1970: Double(
                                                Int(
                                                    $0.1["startAt"][4].stringValue.dropLast(3)
                                                )!
                                            )
                                        ) : nil
                                    )
                                 ))
                            }.reduce(into: [String: MusicVideoMetadata]()) {
                                $0.updateValue($1.value, forKey: $1.key)
                            } : nil
                        ))
                    }
                    return result.sorted { $0.id < $1.id }
                }
                return await task.value
            }
            return nil
        }
        
        /// Get all song meta in Bandori
        /// - Returns: All song meta, nil if failed to fetch data.
        public static func meta() async -> SongMeta? {
            // Response example:
            // {
            //     "1": {
            //         "0": {
            //             "3": [
            //                 2.69,
            //                 0.3367,
            //                 3.3662,
            //                 0.4819
            //             ],
            //             ...
            //         },
            //         "1": {
            //             ...
            //         },
            //         "2": {
            //             ...
            //         },
            //         "3": {
            //             ...
            //         },
            //         "4": {
            //             ...
            //         }
            //     },
            //     ...
            // }
            let request = await requestJSON("https://bestdori.com/api/songs/meta/all.5.json")
            if case let .success(respJSON) = request {
                let task = Task.detached(priority: .userInitiated) {
                    return respJSON.map {
                        (key: Int($0.0) ?? 0,
                         value: $0.1.map {
                            let value = $0.1.map {
                                (key: Double($0.0) ?? 0,
                                 value: $0.1.map { $0.1.doubleValue })
                            }.reduce(into: [Double: [Double]]()) { $0.updateValue($1.value, forKey: $1.key) }
                            return (key: DifficultyType(rawValue: Int($0.0) ?? 0) ?? .easy,
                                    value: value)
                        }.reduce(into: [DifficultyType: [Double: [Double]]]()) { $0.updateValue($1.value, forKey: $1.key) })
                    }.reduce(into: SongMeta()) { $0.updateValue($1.value, forKey: $1.key) }
                }
                return await task.value
            }
            return nil
        }
        
        /// Get detail of a song in Bandori.
        /// - Parameter id: ID of target song.
        /// - Returns: Detail data of requested song, nil if failed to fetch.
        public static func detail(of id: Int) async -> Song? {
            // Response example:
            // {
            //     "bgmId": "bgm580",
            //     "bgmFile": "580_refrain",
            //     "tag": "normal",
            //     "bandId": 45,
            //     "achievements": [
            //         {
            //             "musicId": 580,
            //             "achievementType": "combo_easy",
            //             "rewardType": "coin",
            //             "quantity": 5000
            //         },
            //         ...
            //     ],
            //     "jacketImage": [
            //         "580_refrain"
            //     ],
            //     "seq": 809,
            //     "musicTitle": [
            //         "輪符雨",
            //         "Refrain",
            //         "輪符雨",
            //         "輪符雨",
            //         null
            //     ],
            //     "ruby": [
            //         "りふれいん",
            //         ...
            //     ],
            //     "phonetic": [
            //         "リフレイン",
            //         ...
            //     ],
            //     "lyricist": [
            //         "藤原優樹(SUPA LOVE)",
            //         ...
            //     ],
            //     "composer": [
            //         "木下龍平(SUPA LOVE)",
            //         ...
            //     ],
            //     "arranger": [
            //         "木下龍平(SUPA LOVE)",
            //         ...
            //     ],
            //     "howToGet": [
            //         "楽曲プレゼントを受け取る",
            //         ...
            //     ],
            //     "publishedAt": [
            //         "1708408800000",
            //         ...
            //     ],
            //     "closedAt": [
            //         "4121982000000",
            //         ...
            //     ],
            //     "description": [
            //         "「雨粒に混ざる色」楽曲",
            //         ...
            //     ],
            //     "difficulty": {
            //         "0": {
            //             "playLevel": 7,
            //             "multiLiveScoreMap": {
            //                 "2001": {
            //                     "musicId": 580,
            //                     "musicDifficulty": "easy",
            //                     "multiLiveDifficultyId": 2001,
            //                     "scoreS": 3240000,
            //                     "scoreA": 2160000,
            //                     "scoreB": 1080000,
            //                     "scoreC": 180000,
            //                     "multiLiveDifficultyType": "daredemo",
            //                     "scoreSS": 4320000,
            //                     "scoreSSS": 0
            //                 },
            //                 ...
            //             },
            //             "notesQuantity": 1000,
            //             "scoreC": 36000,
            //             "scoreB": 216000,
            //             "scoreA": 432000,
            //             "scoreS": 648000,
            //             "scoreSS": 864000
            //         },
            //         ...
            //     },
            //     "length": 90.456,
            //     "notes": {
            //         "0": 107,
            //         "1": 201,
            //         "2": 369,
            //         "3": 588
            //     },
            //     "bpm": {
            //         "0": [
            //             {
            //                 "bpm": 154,
            //                 "start": 0,
            //                 "end": 90.456
            //             }
            //         ],
            //         ...
            //     }
            // }
            let request = await requestJSON("https://bestdori.com/api/songs/\(id).json")
            if case let .success(respJSON) = request {
                let task = Task.detached(priority: .userInitiated) {
                    // We break up expressions because of:
                    // The compiler is unable to type-check this expression in reasonable time;
                    // try breaking up the expression into distinct sub-expressions 😇
                    let notes = respJSON["notes"].map {
                        (key: DoriAPI.Song.DifficultyType(rawValue: Int($0.0)!) ?? .easy,
                         value: $0.1.intValue)
                    }.reduce(into: [DifficultyType: Int]()) { $0.updateValue($1.value, forKey: $1.key) }
                    
                    let bpm = respJSON["bpm"].map {
                        (key: DoriAPI.Song.DifficultyType(rawValue: Int($0.0)!) ?? .easy,
                         value: $0.1.map {
                            BPM(bpm: $0.1["bpm"].intValue, start: $0.1["start"].doubleValue, end: $0.1["end"].doubleValue)
                        })
                    }.reduce(into: [DifficultyType: [BPM]]()) { $0.updateValue($1.value, forKey: $1.key) }
                    
                    return Song(
                        id: id,
                        bgmID: respJSON["bgmId"].stringValue,
                        bgmFile: respJSON["bgmFile"].stringValue,
                        tag: .init(rawValue: respJSON["tag"].stringValue) ?? .normal,
                        bandID: respJSON["bandId"].intValue,
                        achievements: respJSON["achievements"].map {
                            .init(
                                musicID: $0.1["musicId"].intValue,
                                achievementType: .init(rawValue: $0.1["achievementType"].stringValue) ?? .comboEasy,
                                reward: .init(
                                    itemID: $0.1["rewardId"].int,
                                    type: .init(rawValue: $0.1["rewardType"].stringValue) ?? .item,
                                    quantity: $0.1["quantity"].intValue
                                )
                            )
                        },
                        jacketImage: respJSON["jacketImage"].map { $0.1.stringValue },
                        seq: respJSON["seq"].intValue,
                        musicTitle: .init(
                            jp: respJSON["musicTitle"][0].string,
                            en: respJSON["musicTitle"][1].string,
                            tw: respJSON["musicTitle"][2].string,
                            cn: respJSON["musicTitle"][3].string,
                            kr: respJSON["musicTitle"][4].string
                        ),
                        ruby: .init(
                            jp: respJSON["ruby"][0].string,
                            en: respJSON["ruby"][1].string,
                            tw: respJSON["ruby"][2].string,
                            cn: respJSON["ruby"][3].string,
                            kr: respJSON["ruby"][4].string
                        ),
                        phonetic: .init(
                            jp: respJSON["phonetic"][0].string,
                            en: respJSON["phonetic"][1].string,
                            tw: respJSON["phonetic"][2].string,
                            cn: respJSON["phonetic"][3].string,
                            kr: respJSON["phonetic"][4].string
                        ),
                        lyricist: .init(
                            jp: respJSON["lyricist"][0].string,
                            en: respJSON["lyricist"][1].string,
                            tw: respJSON["lyricist"][2].string,
                            cn: respJSON["lyricist"][3].string,
                            kr: respJSON["lyricist"][4].string
                        ),
                        composer: .init(
                            jp: respJSON["composer"][0].string,
                            en: respJSON["composer"][1].string,
                            tw: respJSON["composer"][2].string,
                            cn: respJSON["composer"][3].string,
                            kr: respJSON["composer"][4].string
                        ),
                        arranger: .init(
                            jp: respJSON["arranger"][0].string,
                            en: respJSON["arranger"][1].string,
                            tw: respJSON["arranger"][2].string,
                            cn: respJSON["arranger"][3].string,
                            kr: respJSON["arranger"][4].string
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
                        difficulty: respJSON["difficulty"].map {
                            var publishedAt: DoriAPI.LocalizedData<Date>?
                            if $0.1["publishedAt"].exists() {
                                publishedAt = .init(
                                    jp: $0.1["publishedAt"][0].string != nil ? Date(timeIntervalSince1970: Double(Int($0.1["publishedAt"][0].stringValue.dropLast(3))!)) : nil,
                                    en: $0.1["publishedAt"][1].string != nil ? Date(timeIntervalSince1970: Double(Int($0.1["publishedAt"][1].stringValue.dropLast(3))!)) : nil,
                                    tw: $0.1["publishedAt"][2].string != nil ? Date(timeIntervalSince1970: Double(Int($0.1["publishedAt"][2].stringValue.dropLast(3))!)) : nil,
                                    cn: $0.1["publishedAt"][3].string != nil ? Date(timeIntervalSince1970: Double(Int($0.1["publishedAt"][3].stringValue.dropLast(3))!)) : nil,
                                    kr: $0.1["publishedAt"][4].string != nil ? Date(timeIntervalSince1970: Double(Int($0.1["publishedAt"][4].stringValue.dropLast(3))!)) : nil
                                )
                            }
                            return (
                                key: DoriAPI.Song.DifficultyType(rawValue: Int($0.0)!) ?? .easy,
                                value: DoriAPI.Song.Song.Difficulty(
                                    playLevel: $0.1["playLevel"].intValue,
                                    publishedAt: publishedAt,
                                    notesQuantity: $0.1["notesQuantity"].intValue,
                                    scoreC: $0.1["scoreC"].intValue,
                                    scoreB: $0.1["scoreB"].intValue,
                                    scoreA: $0.1["scoreA"].intValue,
                                    scoreS: $0.1["scoreS"].intValue,
                                    scoreSS: $0.1["scoreSS"].intValue,
                                    multiLiveScoreMap: $0.1["multiLiveScoreMap"].map {
                                        (
                                            key: Int($0.0)!,
                                            value: DoriAPI.Song.Song.Difficulty.MultiLiveScore(
                                                musicID: $0.1["musicId"].intValue,
                                                musicDifficulty: $0.1["musicDifficulty"].stringValue,
                                                multiLiveDifficultyID: $0.1["multiLiveDifficultyID"].intValue,
                                                scoreS: $0.1["scoreS"].intValue,
                                                scoreA: $0.1["scoreA"].intValue,
                                                scoreB: $0.1["scoreB"].intValue,
                                                scoreC: $0.1["scoreC"].intValue,
                                                scoreSS: $0.1["scoreSS"].intValue,
                                                scoreSSS: $0.1["scoreSSS"].intValue,
                                                multiLiveDifficultyType: .init(rawValue: $0.1["multiLiveDifficultyType"].stringValue) ?? .daredemo
                                            )
                                        )
                                    }.reduce(into: [Int: Song.Difficulty.MultiLiveScore]()) { $0.updateValue($1.value, forKey: $1.key) }
                                )
                            )
                        }.reduce(into: [DifficultyType: Song.Difficulty]()) { $0.updateValue($1.value, forKey: $1.key) },
                        length: respJSON["length"].doubleValue,
                        notes: notes,
                        bpm: bpm,
                        musicVideos: respJSON["musicVideos"].exists() ? respJSON["musicVideos"].map {
                            (key: $0.0,
                             value: MusicVideoMetadata(
                                startAt: .init(
                                    jp: $0.1["startAt"][0].string != nil ? Date(timeIntervalSince1970: Double(Int($0.1["startAt"][0].stringValue.dropLast(3))!)) : nil,
                                    en: $0.1["startAt"][1].string != nil ? Date(timeIntervalSince1970: Double(Int($0.1["startAt"][1].stringValue.dropLast(3))!)) : nil,
                                    tw: $0.1["startAt"][2].string != nil ? Date(timeIntervalSince1970: Double(Int($0.1["startAt"][2].stringValue.dropLast(3))!)) : nil,
                                    cn: $0.1["startAt"][3].string != nil ? Date(timeIntervalSince1970: Double(Int($0.1["startAt"][3].stringValue.dropLast(3))!)) : nil,
                                    kr: $0.1["startAt"][4].string != nil ? Date(timeIntervalSince1970: Double(Int($0.1["startAt"][4].stringValue.dropLast(3))!)) : nil
                                )
                             ))
                        }.reduce(into: [String: MusicVideoMetadata]()) {
                            $0.updateValue($1.value, forKey: $1.key)
                        } : nil
                    )
                }
                return await task.value
            }
            return nil
        }
    }
}

extension DoriAPI.Song {
    /// Represent simplified data of a song.
    public struct PreviewSong: Sendable, Identifiable, Hashable, DoriCache.Cacheable {
        /// A unique ID of song.
        public var id: Int
        /// Tag of song.
        public var tag: SongTag
        /// ID of band for this song.
        public var bandID: Int
        /// Name of jacket image bundle, used for combination of resource URLs.
        public var jacketImage: [String]
        /// Localized title of music.
        public var musicTitle: DoriAPI.LocalizedData<String>
        /// Localized publish date of song.
        public var publishedAt: DoriAPI.LocalizedData<Date> // String(JSON) -> Date(Swift)
        /// Localized close date of song.
        public var closedAt: DoriAPI.LocalizedData<Date> // String(JSON) -> Date(Swift)
        /// Difficulties of song.
        public var difficulty: [DifficultyType: Difficulty] // {Index: {Difficulty}...}(JSON) -> ~(Swift)
        /// Length of song, in seconds.
        public var length: Double
        /// Note count for different difficulties.
        public var notes: [DifficultyType: Int]
        /// BPMs for different difficulties.
        public var bpm: [DifficultyType: [BPM]]
        /// Music videos data, if available.
        public var musicVideos: [String: MusicVideoMetadata]? // ["music_video_{Int}": ~]
        
        internal init(
            id: Int,
            tag: SongTag,
            bandID: Int,
            jacketImage: [String],
            musicTitle: DoriAPI.LocalizedData<String>,
            publishedAt: DoriAPI.LocalizedData<Date>,
            closedAt: DoriAPI.LocalizedData<Date>,
            difficulty: [DifficultyType : Difficulty],
            length: Double,
            notes: [DifficultyType : Int],
            bpm: [DifficultyType : [BPM]],
            musicVideos: [String : MusicVideoMetadata]?
        ) {
            self.id = id
            self.tag = tag
            self.bandID = bandID
            self.jacketImage = jacketImage
            self.musicTitle = musicTitle
            self.publishedAt = publishedAt
            self.closedAt = closedAt
            self.difficulty = difficulty
            self.length = length
            self.notes = notes
            self.bpm = bpm
            self.musicVideos = musicVideos
        }
        
        public struct Difficulty: Sendable, Hashable, DoriCache.Cacheable {
            public var playLevel: Int
            public var publishedAt: DoriAPI.LocalizedData<Date>? // String(JSON) -> Date(Swift)
            
            internal init(playLevel: Int, publishedAt: DoriAPI.LocalizedData<Date>?) {
                self.playLevel = playLevel
                self.publishedAt = publishedAt
            }
            
            public init(_ full: Song.Difficulty) {
                self.playLevel = full.playLevel
                self.publishedAt = full.publishedAt
            }
        }
    }
    
    /// Represent detailed data of a song.
    public struct Song: Sendable, Identifiable, Hashable, DoriCache.Cacheable {
        public var id: Int
        public var bgmID: String
        public var bgmFile: String
        public var tag: SongTag
        public var bandID: Int
        public var achievements: [Achievement]
        public var jacketImage: [String]
        public var seq: Int
        public var musicTitle: DoriAPI.LocalizedData<String>
        public var ruby: DoriAPI.LocalizedData<String>
        public var phonetic: DoriAPI.LocalizedData<String>
        public var lyricist: DoriAPI.LocalizedData<String>
        public var composer: DoriAPI.LocalizedData<String>
        public var arranger: DoriAPI.LocalizedData<String>
        public var howToGet: DoriAPI.LocalizedData<String>
        public var publishedAt: DoriAPI.LocalizedData<Date> // String(JSON) -> Date(Swift)
        public var closedAt: DoriAPI.LocalizedData<Date> // String(JSON) -> Date(Swift)
        public var description: DoriAPI.LocalizedData<String>
        public var difficulty: [DifficultyType: Difficulty] // {Index: {Difficulty}...}(JSON) -> ~(Swift)
        public var length: Double
        public var notes: [DifficultyType: Int]
        public var bpm: [DifficultyType: [BPM]]
        public var musicVideos: [String: MusicVideoMetadata]? // ["music_video_{Int}": ~]
        
        internal init(
            id: Int,
            bgmID: String,
            bgmFile: String,
            tag: SongTag,
            bandID: Int,
            achievements: [Achievement],
            jacketImage: [String],
            seq: Int,
            musicTitle: DoriAPI.LocalizedData<String>,
            ruby: DoriAPI.LocalizedData<String>,
            phonetic: DoriAPI.LocalizedData<String>,
            lyricist: DoriAPI.LocalizedData<String>,
            composer: DoriAPI.LocalizedData<String>,
            arranger: DoriAPI.LocalizedData<String>,
            howToGet: DoriAPI.LocalizedData<String>,
            publishedAt: DoriAPI.LocalizedData<Date>,
            closedAt: DoriAPI.LocalizedData<Date>,
            description: DoriAPI.LocalizedData<String>,
            difficulty: [DifficultyType : Difficulty],
            length: Double,
            notes: [DifficultyType : Int],
            bpm: [DifficultyType : [BPM]],
            musicVideos: [String : MusicVideoMetadata]?
        ) {
            self.id = id
            self.bgmID = bgmID
            self.bgmFile = bgmFile
            self.tag = tag
            self.bandID = bandID
            self.achievements = achievements
            self.jacketImage = jacketImage
            self.seq = seq
            self.musicTitle = musicTitle
            self.ruby = ruby
            self.phonetic = phonetic
            self.lyricist = lyricist
            self.composer = composer
            self.arranger = arranger
            self.howToGet = howToGet
            self.publishedAt = publishedAt
            self.closedAt = closedAt
            self.description = description
            self.difficulty = difficulty
            self.length = length
            self.notes = notes
            self.bpm = bpm
            self.musicVideos = musicVideos
        }
        
        public struct Achievement: Sendable, Hashable, DoriCache.Cacheable {
            public var musicID: Int
            public var achievementType: AchievementType
            public var reward: DoriAPI.Item
            
            public enum AchievementType: String, Sendable, Hashable, DoriCache.Cacheable {
                case comboEasy = "combo_easy"
                case comboNormal = "combo_normal"
                case comboHard = "combo_hard"
                case comboExpert = "combo_expert"
                case comboSpecial = "combo_special"
                
                case fullComboEasy = "fullCombo_easy"
                case fullComboNormal = "fullCombo_normal"
                case fullComboHard = "fullCombo_hard"
                case fullComboExpert = "fullCombo_expert"
                case fullComboSpecial = "fullCombo_special"
                
                case scoreRankA = "score_rank_a"
                case scoreRankB = "score_rank_b"
                case scoreRankC = "score_rank_c"
                case scoreRankS = "score_rank_s"
                case scoreRankSS = "score_rank_ss"
            }
        }
        
        public struct Difficulty: Sendable, Hashable, DoriCache.Cacheable {
            public var playLevel: Int
            public var publishedAt: DoriAPI.LocalizedData<Date>? // String(JSON) -> Date(Swift)
            public var notesQuantity: Int
            public var scoreC: Int
            public var scoreB: Int
            public var scoreA: Int
            public var scoreS: Int
            public var scoreSS: Int
            public var multiLiveScoreMap: [Int: MultiLiveScore]
            
            internal init(
                playLevel: Int,
                publishedAt: DoriAPI.LocalizedData<Date>?,
                notesQuantity: Int,
                scoreC: Int,
                scoreB: Int,
                scoreA: Int,
                scoreS: Int,
                scoreSS: Int,
                multiLiveScoreMap: [Int : MultiLiveScore]
            ) {
                self.playLevel = playLevel
                self.publishedAt = publishedAt
                self.notesQuantity = notesQuantity
                self.scoreC = scoreC
                self.scoreB = scoreB
                self.scoreA = scoreA
                self.scoreS = scoreS
                self.scoreSS = scoreSS
                self.multiLiveScoreMap = multiLiveScoreMap
            }
            
            public struct MultiLiveScore: Sendable, Hashable, DoriCache.Cacheable {
                public var musicID: Int
                public var musicDifficulty: String
                public var multiLiveDifficultyID: Int
                public var scoreS: Int
                public var scoreA: Int
                public var scoreB: Int
                public var scoreC: Int
                public var scoreSS: Int
                public var scoreSSS: Int
                public var multiLiveDifficultyType: DifficultyType
                
                public enum DifficultyType: String, Sendable, DoriCache.Cacheable {
                    case daredemo
                    case standard
                    case grand
                    case legend
                }
            }
        }
    }
    
    /// ```
    /// [Int: [DifficultyType: [Double: [Double]]]]
    ///  ^~~ Song ID
    /// ```
    ///
    /// ```
    /// [Int: [DifficultyType: [Double: [Double]]]]
    ///                         ^~~~~~ Skill duration
    /// ```
    ///
    /// ```
    /// [Int: [DifficultyType: [Double: [Double]]]]
    ///                   SongMeta Data ^~~~~~~~
    /// ```
    public typealias SongMeta = [Int: [DifficultyType: [Double: [Double]]]]
    
    public enum SongTag: String, CaseIterable, Sendable, Hashable, DoriCache.Cacheable {
        case normal
        case anime
        case tieUp = "tie_up"
    }
    
    @frozen
    public enum DifficultyType: Int, Hashable, DoriCache.Cacheable {
        case easy = 0
        case normal
        case hard
        case expert
        case special
    }
    
    @frozen
    public struct BPM: Sendable, Hashable, DoriCache.Cacheable {
        public var bpm: Int
        public var start: Double
        public var end: Double
    }
    
    public struct MusicVideoMetadata: Sendable, Hashable, DoriCache.Cacheable {
        public var startAt: DoriAPI.LocalizedData<Date> // String(JSON) -> Date(Swift)
    }
}

extension DoriAPI.Song.DifficultyType {
    internal init?(rawStringValue name: String) {
        switch name {
        case "easy": self = .easy
        case "normal": self = .normal
        case "hard": self = .hard
        case "expert": self = .expert
        case "special": self = .special
        default: return nil
        }
    }
}

extension DoriAPI.Song.PreviewSong {
    public init(_ full: DoriAPI.Song.Song) {
        self.init(
            id: full.id,
            tag: full.tag,
            bandID: full.bandID,
            jacketImage: full.jacketImage,
            musicTitle: full.musicTitle,
            publishedAt: full.publishedAt,
            closedAt: full.closedAt,
            difficulty: full.difficulty.mapValues {
                .init(
                    playLevel: $0.playLevel,
                    publishedAt: $0.publishedAt
                )
            },
            length: full.length,
            notes: full.notes,
            bpm: full.bpm,
            musicVideos: full.musicVideos
        )
    }
}
extension DoriAPI.Song.Song {
    @inlinable
    public init?(id: Int) async {
        if let song = await DoriAPI.Song.detail(of: id) {
            self = song
        } else {
            return nil
        }
    }
    
    @inlinable
    public init?(preview: DoriAPI.Song.PreviewSong) async {
        await self.init(id: preview.id)
    }
}
