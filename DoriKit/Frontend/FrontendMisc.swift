//===---*- Greatdori! -*---------------------------------------------------===//
//
// FrontendMisc.swift
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

extension DoriFrontend {
    /// Other uncatogorized requests in Bandori.
    public enum Misc {
        /// Returns a list of items with related information from given items.
        ///
        /// - Parameter items: A collection of items.
        /// - Returns: Items with related information from given items, nil if failed to fetch.
        public static func extendedItems<T>(
            from items: T
        ) async -> [ExtendedItem]? where T: RandomAccessCollection, T.Element == Item {
            guard let texts = await DoriAPI.Misc.itemTexts() else { return nil }
            
            var result = [ExtendedItem]()
            for item in items {
                var text: DoriAPI.Misc.ItemText?
                switch item.type {
                case .item, .practiceTicket, .liveBoostRecoveryItem, .gachaTicket, .miracleTicket:
                    // These types of items are included in itemTexts result,
                    // we get it directly.
                    if let id = item.itemID {
                        text = texts["\(item.type.rawValue)_\(id)"]
                    }
                case .star:
                    text = .init(
                        name: .init(
                            jp: "スター (無償)",
                            en: "Star (Free)",
                            tw: "Star (免費)",
                            cn: "星石 (免费)",
                            kr: "스타 (무료)"
                        ),
                        type: nil,
                        resourceID: -1
                    )
                case .coin:
                    text = .init(
                        name: .init(
                            jp: "コイン",
                            en: "Coin",
                            tw: "金幣",
                            cn: "金币",
                            kr: "골드"
                        ),
                        type: nil,
                        resourceID: -1
                    )
                case .stamp:
                    text = .init(
                        name: .init(
                            jp: "レアスタンプ",
                            en: "Rare Stamp",
                            tw: "稀有貼圖",
                            cn: "稀有表情",
                            kr: "레어 스탬프"
                        ),
                        type: nil,
                        resourceID: -1
                    )
                case .degree:
                    text = .init(
                        name: .init(
                            jp: "Title",
                            en: "称号",
                            tw: "稱號",
                            cn: "称号",
                            kr: "제목"
                        ),
                        type: nil,
                        resourceID: -1
                    )
                default: break
                }
                result.append(.init(item: item, text: text))
            }
            return result
        }
    }
}

extension DoriFrontend {
    public typealias Item = DoriAPI.Item
    
    public struct ExtendedItem: Identifiable, Hashable, DoriCache.Cacheable {
        public var item: Item
        public var text: DoriAPI.Misc.ItemText?
        
        public var id: String {
            item.id
        }
        
        internal init(item: Item, text: DoriAPI.Misc.ItemText?) {
            self.item = item
            self.text = text
        }
    }
}

extension DoriAPI.Misc.StoryAsset {
    /// Textual transcript of story.
    public var transcript: [Transcript] {
        var result = [Transcript]()
        for snippet in self.snippets {
            switch snippet.actionType {
            case .talk:
                let ref = self.talkData[snippet.referenceIndex]
                result.append(.talk(.init(
                    _characterID: ref.talkCharacters.count > 0 ? ref.talkCharacters[0].characterID : 0,
                    characterName: ref.windowDisplayName,
                    text: ref.body,
                    voiceID: ref.voices.count > 0 ? ref.voices[0].voiceID : nil
                )))
            case .effect:
                let ref = self.specialEffectData[snippet.referenceIndex]
                if ref.effectType == .telop {
                    result.append(.notation(ref.stringVal))
                }
            default: break
            }
        }
        return result
    }
    
    public enum Transcript: Sendable, Hashable {
        case talk(Talk)
        case notation(String)
        
        public struct Talk: Sendable, Hashable {
            public var _characterID: Int
            public var characterName: String
            public var text: String
            public var voiceID: String?
            
            internal init(_characterID: Int, characterName: String, text: String, voiceID: String?) {
                self._characterID = _characterID
                self.characterName = characterName
                self.text = text
                self.voiceID = voiceID
            }
            
            @inlinable
            public var characterIconImageURL: URL? {
                if _characterID > 0 {
                    .init(string: "https://bestdori.com/res/icon/chara_icon_\(_characterID).png")!
                } else {
                    nil
                }
            }
        }
    }
}
