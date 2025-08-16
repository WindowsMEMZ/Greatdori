//===---*- Greatdori! -*---------------------------------------------------===//
//
// Searching.swift
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

#if canImport(SwiftUI)
import SwiftUI
#endif

extension DoriFrontend {
    public protocol Searchable: Identifiable {
        var _searchStrings: [String] { get }
        var _searchLocalizedStrings: [DoriAPI.LocalizedData<String>] { get }
        var _searchIntegers: [Int] { get }
        var _searchLocales: [DoriAPI.Locale] { get }
        var _searchBands: [DoriAPI.Band.Band] { get }
        var _searchAttributes: [DoriAPI.Attribute] { get }
    }
}

extension DoriFrontend.Searchable {
    public var _searchStrings: [String] { [] }
    public var _searchLocalizedStrings: [DoriAPI.LocalizedData<String>] { [] }
    public var _searchIntegers: [Int] { [] }
    public var _searchLocales: [DoriAPI.Locale] { [] }
    public var _searchBands: [DoriAPI.Band.Band] { [] }
    public var _searchAttributes: [DoriAPI.Attribute] { [] }
}

extension Array where Element: DoriFrontend.Searchable {
    public func search(for keyword: String) -> Self {
        let tokens = keyword.split(separator: " ").map { $0.lowercased() }
        guard !tokens.isEmpty else { return self }
        
        var result = self
        var removes = IndexSet()
        for (index, item) in result.enumerated() {
            tokenLoop: for token in tokens {
                // We always do early exit for performance
                for string in item._searchStrings {
                    if string.lowercased().contains(token) {
                        continue tokenLoop
                    }
                }
                for localizedString in item._searchLocalizedStrings {
                    for locale in DoriAPI.Locale.allCases {
                        if localizedString.forLocale(locale)?.lowercased().contains(token) == true {
                            continue tokenLoop
                        }
                    }
                }
                for integer in item._searchIntegers {
                    // like 4 for rarity of 4
                    if let intToken = Int(token), integer == intToken {
                        continue tokenLoop
                    }
                    // like 4* for rarity of 4
                    if let intToken = Int(token.dropLast()), integer == intToken {
                        continue tokenLoop
                    }
                    // like 4+, 4*+
                    if token.hasSuffix("+") {
                        var token = token
                        while !token.isEmpty {
                            token.removeLast()
                            if let intToken = Int(token), integer >= intToken {
                                continue tokenLoop
                            }
                        }
                    }
                    // like 4-, 4*-
                    if token.hasSuffix("-") {
                        var token = token
                        while !token.isEmpty {
                            token.removeLast()
                            if let intToken = Int(token), integer <= intToken {
                                continue tokenLoop
                            }
                        }
                    }
                    // like >4, >4*, <4, ...
                    if token.hasPrefix(">") || token.hasPrefix("<") {
                        var token = token
                        while let l = token.last, Int(String(l)) != nil {
                            token.removeLast()
                        }
                        if token.hasPrefix(">") {
                            while !token.isEmpty {
                                token.removeFirst()
                                if let intToken = Int(token), integer >= intToken {
                                    continue tokenLoop
                                }
                            }
                        } else {
                            while !token.isEmpty {
                                token.removeFirst()
                                if let intToken = Int(token), integer <= intToken {
                                    continue tokenLoop
                                }
                            }
                        }
                    }
                }
                let server: DoriAPI.Locale? = switch token {
                case "japan", "japanese", "jp": .jp
                case "worldwide", "english", "ww", "en": .en
                case "taiwan", "tw": .tw
                case "china", "chinese", "cn": .cn
                case "korea", "korean", "kr": .kr
                default: nil
                }
                if let server {
                    if item._searchLocales.contains(server) {
                        continue tokenLoop
                    }
                }
                let band: String? = switch token {
                case "popipa", "poppin", "poppin'party", "party", "ppp":
                    "Poppin'Party"
                case "afterglow", "ag", "after", "glow":
                    "Afterglow"
                case "hhw", "hello", "happy", "world", "ハロー、ハッピーワールド",
                    "ハロー", "ハッピーワールド", "ハロー、ハッピーワールド！",
                    "hello，happyworld", "hello，happyworld！",
                    "hello,happyworld!":
                    "ハロー、ハッピーワールド！"
                case "pastel＊palettes", "pastel", "palettes", "pp",
                    "＊", "*", "pastel*palettes":
                    "Pastel＊Palettes"
                case "roselia", "rose", "r":
                    "Roselia"
                case "raiseasuilen", "ras", "raise", "suilen":
                    "RAISE A SUILEN"
                case "morfonica", "mor", "foni":
                    "Morfonica"
                case "mygo!!!!!", "mygo", "my", "go", "!!!!!":
                    "MyGO!!!!!"
                default: nil
                }
                if let band {
                    if item._searchBands.contains(where: { $0.bandName.forLocale(.jp) == band }) {
                        continue tokenLoop
                    }
                }
                let attribute: DoriAPI.Attribute? = switch token {
                case "powerful", "power", "red", "パワフル", "红", "紅": .powerful
                case "pure", "green", "ピュア", "绿", "綠": .pure
                case "cool", "blue", "クール", "蓝", "藍": .cool
                case "happy", "orange", "ハッピー", "橙": .happy
                default: nil
                }
                if let attribute {
                    if item._searchAttributes.contains(attribute) {
                        continue tokenLoop
                    }
                }
                if token.hasPrefix("#"), let intToken = Int(String(token.dropFirst())) {
                    if (item.id as? Int) == intToken {
                        continue tokenLoop
                    }
                }
                removes.insert(index)
            }
        }
        result.remove(atOffsets: removes)
        
        return result
    }
}

extension DoriAPI.Card.PreviewCard: DoriFrontend.Searchable {
    public var _searchLocalizedStrings: [DoriAPI.LocalizedData<String>] {
        [self.prefix]
    }
    public var _searchIntegers: [Int] {
        [self.rarity]
    }
    public var _searchLocales: [DoriAPI.Locale] {
        var result = [DoriAPI.Locale]()
        for locale in DoriAPI.Locale.allCases {
            if self.releasedAt.availableInLocale(locale) {
                result.append(locale)
            }
        }
        return result
    }
    public var _searchAttributes: [DoriAPI.Attribute] {
        [self.attribute]
    }
}
extension DoriAPI.Comic.Comic: DoriFrontend.Searchable {
    public var _searchLocalizedStrings: [DoriAPI.LocalizedData<String>] {
        [self.title, self.subTitle]
    }
    public var _searchLocales: [DoriAPI.Locale] {
        var result = [DoriAPI.Locale]()
        for locale in DoriAPI.Locale.allCases {
            if self.publicStartAt.availableInLocale(locale) {
                result.append(locale)
            }
        }
        return result
    }
}
extension DoriAPI.Costume.PreviewCostume: DoriFrontend.Searchable {
    public var _searchLocalizedStrings: [DoriAPI.LocalizedData<String>] {
        [self.description]
    }
    public var _searchLocales: [DoriAPI.Locale] {
        var result = [DoriAPI.Locale]()
        for locale in DoriAPI.Locale.allCases {
            if self.publishedAt.availableInLocale(locale) {
                result.append(locale)
            }
        }
        return result
    }
}
extension DoriAPI.Event.PreviewEvent: DoriFrontend.Searchable {
    public var _searchStrings: [String] {
        [self.eventType.localizedString]
    }
    public var _searchLocalizedStrings: [DoriAPI.LocalizedData<String>] {
        [self.eventName]
    }
    public var _searchLocales: [DoriAPI.Locale] {
        var result = [DoriAPI.Locale]()
        for locale in DoriAPI.Locale.allCases {
            if self.startAt.availableInLocale(locale) {
                result.append(locale)
            }
        }
        return result
    }
    public var _searchAttributes: [DoriAPI.Attribute] {
        self.attributes.map { $0.attribute }
    }
}
extension DoriAPI.Gacha.PreviewGacha: DoriFrontend.Searchable {
    public var _searchStrings: [String] {
        [self.type.localizedString]
    }
    public var _searchLocalizedStrings: [DoriAPI.LocalizedData<String>] {
        [self.gachaName]
    }
    public var _searchLocales: [DoriAPI.Locale] {
        var result = [DoriAPI.Locale]()
        for locale in DoriAPI.Locale.allCases {
            if self.publishedAt.availableInLocale(locale) {
                result.append(locale)
            }
        }
        return result
    }
}
extension DoriAPI.Song.PreviewSong: DoriFrontend.Searchable {
    public var _searchStrings: [String] {
        [self.tag.localizedString]
    }
    public var _searchLocalizedStrings: [DoriAPI.LocalizedData<String>] {
        [self.musicTitle]
    }
    public var _searchLocales: [DoriAPI.Locale] {
        var result = [DoriAPI.Locale]()
        for locale in DoriAPI.Locale.allCases {
            if self.publishedAt.availableInLocale(locale) {
                result.append(locale)
            }
        }
        return result
    }
}
