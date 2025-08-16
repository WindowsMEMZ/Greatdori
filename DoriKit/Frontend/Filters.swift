//===---*- Greatdori! -*---------------------------------------------------===//
//
// Filters.swift
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

#if canImport(os)
import os
#endif
#if canImport(CryptoKit)
import CryptoKit
#endif

extension DoriFrontend {
    public struct Filter: Sendable, Hashable, Codable {
        public var band: Set<Band> = .init(Band.allCases) { didSet { store() } }
        public var attribute: Set<Attribute> = .init(Attribute.allCases)  { didSet { store() } }
        public var rarity: Set<Rarity> = [1, 2, 3, 4, 5]  { didSet { store() } }
        public var character: Set<Character> = .init(Character.allCases)  { didSet { store() } }
        public var server: Set<Server> = .init(Server.allCases)  { didSet { store() } }
        public var released: Set<Bool> = [false, true]  { didSet { store() } }
        public var cardType: Set<CardType> = .init(CardType.allCases)  { didSet { store() } }
        public var eventType: Set<EventType> = .init(EventType.allCases)  { didSet { store() } }
        public var gachaType: Set<GachaType> = .init(GachaType.allCases)  { didSet { store() } }
        public var songType: Set<SongType> = .init(SongType.allCases)  { didSet { store() } }
        public var skill: Skill? = nil  { didSet { store() } }
        public var timelineStatus: Set<TimelineStatus> = .init(TimelineStatus.allCases)  { didSet { store() } }
        public var sort: Sort = .init(direction: .descending, keyword: .releaseDate(in: .jp))  { didSet { store() } }
        
        public init(
            band: Set<Band> = .init(Band.allCases),
            attribute: Set<Attribute> = .init(Attribute.allCases),
            rarity: Set<Rarity> = [1, 2, 3, 4, 5],
            character: Set<Character> = .init(Character.allCases),
            server: Set<Server> = .init(Server.allCases),
            released: Set<Bool> = [false, true],
            cardType: Set<CardType> = .init(CardType.allCases),
            eventType: Set<EventType> = .init(EventType.allCases),
            gachaType: Set<GachaType> = .init(GachaType.allCases),
            songType: Set<SongType> = .init(SongType.allCases),
            skill: Skill? = nil,
            timelineStatus: Set<TimelineStatus> = .init(TimelineStatus.allCases),
            sort: Sort = .init(direction: .descending, keyword: .releaseDate(in: .jp))
        ) {
            self.band = band
            self.attribute = attribute
            self.rarity = rarity
            self.character = character
            self.server = server
            self.released = released
            self.cardType = cardType
            self.eventType = eventType
            self.gachaType = gachaType
            self.songType = songType
            self.skill = skill
            self.timelineStatus = timelineStatus
            self.sort = sort
        }
        
        private var recoveryID: String?
        
        public static func recoverable(id: String) -> Self {
            let storageURL = URL(filePath: NSHomeDirectory() + "/Documents/DoriKit_Filter_Status.plist")
            let decoder = PropertyListDecoder()
            var result: Self = if let _data = try? Data(contentsOf: storageURL),
                                  let storage = try? decoder.decode([String: Filter].self, from: _data) {
                storage[id] ?? .init()
            } else {
                .init()
            }
            result.recoveryID = id
            return result
        }
        
        public var isFiltered: Bool {
            band.count != Band.allCases.count
            || attribute.count != Attribute.allCases.count
            || rarity.count != 5
            || character.count != Character.allCases.count
            || server.count != Server.allCases.count
            || released.count != 2
            || cardType.count != CardType.allCases.count
            || eventType.count != EventType.allCases.count
            || gachaType.count != GachaType.allCases.count
            || songType.count != SongType.allCases.count
            || skill != nil
            || timelineStatus.count != TimelineStatus.allCases.count
        }
        
        public var identity: String {
            // We skips `skill` in identity encoding because it's too dynamic.
            let desc = """
            \(band.sorted { $0.rawValue < $1.rawValue })\
            \(attribute.sorted { $0.rawValue < $1.rawValue })\
            \(rarity.sorted { $0 < $1 })\
            \(character.sorted { $0.rawValue < $1.rawValue })\
            \(server.sorted { $0.rawValue < $1.rawValue })\
            \(released.sorted { $1 })\
            \(cardType.sorted { $0.rawValue < $1.rawValue })\
            \(eventType.sorted { $0.rawValue < $1.rawValue })\
            \(gachaType.sorted { $0.rawValue < $1.rawValue })\
            \(songType.sorted { $0.rawValue < $1.rawValue })\
            \(timelineStatus.sorted { $0.rawValue < $1.rawValue })
            """
            #if canImport(CryptoKit)
            return String(SHA256.hash(data: desc.data(using: .utf8)!).map { $0.description }.joined().prefix(8))
            #else
            return unsafe String(format: "%016lx", desc.utf8.reduce(14695981039346656037) { ($0 ^ UInt64($1)) &* 1099511628211 })
            #endif
        }
        
        public mutating func clearAll() {
            band = .init(Band.allCases)
            attribute = .init(Attribute.allCases)
            rarity = [1, 2, 3, 4, 5]
            character = .init(Character.allCases)
            server = .init(Server.allCases)
            released = [false, true]
            cardType = .init(CardType.allCases)
            eventType = .init(EventType.allCases)
            gachaType = .init(GachaType.allCases)
            songType = .init(SongType.allCases)
            skill = nil
            timelineStatus = .init(TimelineStatus.allCases)
        }
        
        private static let _storageLock = NSLock()
        private func store() {
            guard let recoveryID else { return }
            DispatchQueue(label: "com.memz233.DoriKit.Filter-Store", qos: .utility).async {
                Self._storageLock.lock()
                let storageURL = URL(filePath: NSHomeDirectory() + "/Documents/DoriKit_Filter_Status.plist")
                let decoder = PropertyListDecoder()
                let encoder = PropertyListEncoder()
                if let _data = try? Data(contentsOf: storageURL),
                   var storage = try? decoder.decode([String: Filter].self, from: _data) {
                    storage.updateValue(self, forKey: recoveryID)
                    try? encoder.encode(storage).write(to: storageURL)
                } else {
                    let storage = [recoveryID: self]
                    try? encoder.encode(storage).write(to: storageURL)
                }
                Self._storageLock.unlock()
            }
        }
    }
}

extension DoriFrontend.Filter {
    public typealias Attribute = DoriAPI.Attribute
    public typealias Rarity = Int
    public typealias Server = DoriAPI.Locale
    public typealias CardType = DoriAPI.Card.CardType
    public typealias EventType = DoriAPI.Event.EventType
    public typealias GachaType = DoriAPI.Gacha.GachaType
    public typealias SongType = DoriAPI.Song.SongTag
    public typealias Skill = DoriAPI.Skill.Skill
    
    public enum Band: Int, Sendable, CaseIterable, Hashable, Codable {
        case poppinParty = 1
        case afterglow
        case helloHappyWorld
        case pastelPalettes
        case roselia
        case raiseASuilen = 18
        case morfonica = 21
        case mygo = 45
        case others = -1
        
        @inline(never)
        internal var name: String {
            switch self {
            case .poppinParty: String(localized: "BAND_NAME_POPIPA", bundle: #bundle)
            case .afterglow: String(localized: "BAND_NAME_AFTERGLOW", bundle: #bundle)
            case .helloHappyWorld: String(localized: "BAND_NAME_HHW", bundle: #bundle)
            case .pastelPalettes: String(localized: "BAND_NAME_PP", bundle: #bundle)
            case .roselia: String(localized: "BAND_NAME_ROSELIA", bundle: #bundle)
            case .raiseASuilen: String(localized: "BAND_NAME_RAS", bundle: #bundle)
            case .morfonica: String(localized: "BAND_NAME_MORFONICA", bundle: #bundle)
            case .mygo: String(localized: "BAND_NAME_MYGO", bundle: #bundle)
            case .others: String(localized: "BAND_NAME_OTHERS", bundle: #bundle)
            }
        }
    }
    public enum Character: Int, Sendable, CaseIterable, Hashable, Codable {
        // Poppin'Party
        case kasumi = 1
        case tae
        case rimi
        case saya
        case arisa
        
        // Afterglow
        case ran
        case moca
        case himari
        case tomoe
        case tsugumi
        
        // Hello, Happy World!
        case kokoro
        case kaoru
        case hagumi
        case kanon
        case misaki
        
        // Pastel＊Palettes
        case aya
        case hina
        case chisato
        case maya
        case eve
        
        // Roselia
        case yukina
        case sayo
        case lisa
        case ako
        case rinko
        
        // Morfonica
        case mashiro
        case toko
        case nanami
        case tsukushi
        case rui
        
        // RAISE A SUILEN
        case rei
        case rokka
        case masuki
        case reona
        case chiyu
        
        // MyGO!!!!!
        case tomori
        case anon
        case rana
        case soyo
        case taki
        
        @inline(never)
        public var name: String {
            NSLocalizedString("CHARACTER_NAME_ID_" + String(self.rawValue), bundle: #bundle, comment: "")
        }
    }
    @frozen
    public enum TimelineStatus: Int, CaseIterable, Hashable, Codable {
        case ended
        case ongoing
        case upcoming
        
        @inline(never)
        internal var localizedString: String {
            switch self {
            case .ended: String(localized: "TIMELINE_STATUS_ENDED", bundle: #bundle)
            case .ongoing: String(localized: "TIMELINE_STATUS_ONGOING", bundle: #bundle)
            case .upcoming: String(localized: "TIMELINE_STATUS_UPCOMING", bundle: #bundle)
            }
        }
    }
    
    public struct Sort: Sendable, Equatable, Hashable, Codable {
        public var direction: Direction
        public var keyword: Keyword
        
        public init(direction: Direction, keyword: Keyword) {
            self.direction = direction
            self.keyword = keyword
        }
        
        @frozen
        public enum Direction: Equatable, Hashable, Codable {
            case ascending
            case descending
        }
        public enum Keyword: CaseIterable, Sendable, Equatable, Hashable, Codable {
            case releaseDate(in: DoriAPI.Locale)
            case rarity
            case maximumStat
            case id
            
            public static let allCases: [Self] = [
                .releaseDate(in: .jp),
                .releaseDate(in: .en),
                .releaseDate(in: .tw),
                .releaseDate(in: .cn),
                .releaseDate(in: .kr),
                .rarity,
                .maximumStat,
                .id
            ]
            
            @inline(never)
            internal var localizedString: String {
                switch self {
                case .releaseDate(let locale):
                    String(localized: "FILTER_SORT_KEYWORD_RELEASE_DATE_IN_\(locale.rawValue.uppercased())", bundle: #bundle)
                case .rarity: String(localized: "FILTER_SORT_KEYWORD_RARITY", bundle: #bundle)
                case .maximumStat: String(localized: "FILTER_SORT_KEYWORD_MAXIMUM_STAT", bundle: #bundle)
                case .id: String(localized: "FILTER_SORT_KEYWORD_ID", bundle: #bundle)
                }
            }
        }
        
        internal func compare<T: Comparable>(_ lhs: T, _ rhs: T) -> Bool {
            switch direction {
            case .ascending: lhs < rhs
            case .descending: lhs > rhs
            }
        }
    }
    
    public enum Key: Int, CaseIterable, Hashable {
        case band
        case attribute
        case rarity
        case character
        case server
        case released
        case cardType
        case eventType
        case gachaType
        case songType
        case skill
        case timelineStatus
        case sort
    }
}

extension DoriFrontend.Filter.Key: Identifiable {
    public var id: Int { self.rawValue }
}
extension Set<DoriFrontend.Filter.Key> {
    @inlinable
    public func sorted() -> [DoriFrontend.Filter.Key] {
        self.sorted { $0.rawValue < $1.rawValue }
    }
}
extension Array<DoriFrontend.Filter.Key> {
    @inlinable
    public func sorted() -> [DoriFrontend.Filter.Key] {
        self.sorted { $0.rawValue < $1.rawValue }
    }
}
extension DoriFrontend.Filter.Key {
    @inline(never)
    public var localizedString: String {
        switch self {
        case .band: String(localized: "FILTER_KEY_BAND", bundle: #bundle)
        case .attribute: String(localized: "FILTER_KEY_ATTRIBUTE", bundle: #bundle)
        case .rarity: String(localized: "FILTER_KEY_RARITY", bundle: #bundle)
        case .character: String(localized: "FILTER_KEY_CHARACTER", bundle: #bundle)
        case .server: String(localized: "FILTER_KEY_SERVER", bundle: #bundle)
        case .released: String(localized: "FILTER_KEY_RELEASED", bundle: #bundle)
        case .cardType: String(localized: "FILTER_KEY_CARD_TYPE", bundle: #bundle)
        case .eventType: String(localized: "FILTER_KEY_EVENT_TYPE", bundle: #bundle)
        case .gachaType: String(localized: "FILTER_KEY_GACHA_TYPE", bundle: #bundle)
        case .songType: String(localized: "FILTER_KEY_SONG_TYPE", bundle: #bundle)
        case .skill: String(localized: "FILTER_KEY_SKILL", bundle: #bundle)
        case .timelineStatus: String(localized: "FILTER_KEY_TIMELINE_STATUS", bundle: #bundle)
        case .sort: String(localized: "FILTER_KEY_SORT", bundle: #bundle)
        }
    }
}

extension DoriFrontend.Filter.Key: Comparable {
    @inlinable
    public static func < (lhs: DoriFrontend.Filter.Key, rhs: DoriFrontend.Filter.Key) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
extension DoriFrontend.Filter: MutableCollection {
    public typealias Element = AnyHashable
    
    @inlinable
    public var startIndex: Key { .band }
    @inlinable
    public var endIndex: Key { .sort }
    @inlinable
    public func index(after i: Key) -> Key {
        .init(rawValue: i.rawValue + 1)!
    }
    
    public subscript(position: Key) -> AnyHashable {
        get {
            switch position {
            case .band: self.band
            case .attribute: self.attribute
            case .rarity: self.rarity
            case .character: self.character
            case .server: self.server
            case .released: self.released
            case .cardType: self.cardType
            case .eventType: self.eventType
            case .gachaType: self.gachaType
            case .songType: self.songType
            case .skill: self.skill
            case .timelineStatus: self.timelineStatus
            case .sort: self.sort
            }
        }
        set {
            self.updateValue(newValue, forKey: position)
        }
    }
    
    public mutating func updateValue(_ value: AnyHashable, forKey key: Key) {
        let expectedValueType = type(of: self[key])
        let valueType = type(of: value)
        if valueType != expectedValueType {
            logger.critical("Failed to update value of filter, expected \(expectedValueType), but got \(valueType)")
            return
        }
        switch key {
        case .band:
            self.band = value as! Set<Band>
        case .attribute:
            self.attribute = value as! Set<Attribute>
        case .rarity:
            self.rarity = value as! Set<Rarity>
        case .character:
            self.character = value as! Set<Character>
        case .server:
            self.server = value as! Set<Server>
        case .released:
            self.released = value as! Set<Bool>
        case .cardType:
            self.cardType = value as! Set<CardType>
        case .eventType:
            self.eventType = value as! Set<EventType>
        case .gachaType:
            self.gachaType = value as! Set<GachaType>
        case .songType:
            self.songType = value as! Set<SongType>
        case .skill:
            self.skill = value as! Skill?
        case .timelineStatus:
            self.timelineStatus = value as! Set<TimelineStatus>
        case .sort:
            if let sort = value as? Sort {
                self.sort = sort
            } else {
                self.sort.keyword = value as! Sort.Keyword
            }
        }
    }
}

extension DoriFrontend.Filter {
    @_typeEraser(_AnySelectable)
    public protocol _Selectable: Hashable {
        var selectorText: String { get }
        var selectorImageURL: URL? { get }
    }
    public struct _AnySelectable: _Selectable, Equatable, Hashable {
        private let _selectorText: String
        private let _selectorImageURL: URL?
        
        public let value: AnyHashable
        
        public init<T: _Selectable>(erasing value: T) {
            self._selectorText = value.selectorText
            self._selectorImageURL = value.selectorImageURL
            self.value = value
        }
        public init<T: _Selectable>(_ value: T) {
            self.init(erasing: value)
        }
        
        public var selectorText: String { _selectorText }
        public var selectorImageURL: URL? { _selectorImageURL }
    }
}
extension DoriFrontend.Filter._Selectable {
    public var selectorImageURL: URL? { nil }
    
    public func isEqual(to selectable: any DoriFrontend.Filter._Selectable) -> Bool {
        self.selectorText == selectable.selectorText
    }
}
extension DoriFrontend.Filter.Band: DoriFrontend.Filter._Selectable {
    public var selectorText: String {
        self.name
    }
    public var selectorImageURL: URL? {
        .init(string: "https://bestdori.com/res/icon/band_\(self.rawValue).svg")!
    }
}
extension DoriFrontend.Filter.Attribute: DoriFrontend.Filter._Selectable {
    public var selectorText: String {
        self.rawValue.uppercased()
    }
    public var selectorImageURL: URL? {
        .init(string: "https://bestdori.com/res/icon/\(self.rawValue).svg")!
    }
}
extension DoriFrontend.Filter.Rarity: DoriFrontend.Filter._Selectable {
    public var selectorText: String {
        String(self)
    }
    public var selectorImageURL: URL? {
        .init(string: "https://bestdori.com/res/icon/star_\(self).png")!
    }
}
extension DoriFrontend.Filter.Character: DoriFrontend.Filter._Selectable {
    public var selectorText: String {
        self.name
    }
    public var selectorImageURL: URL? {
        .init(string: "https://bestdori.com/res/icon/chara_icon_\(self.rawValue).png")!
    }
}
extension DoriFrontend.Filter.Server: DoriFrontend.Filter._Selectable {
    public var selectorText: String {
        self.rawValue.uppercased()
    }
    public var selectorImageURL: URL? {
        self.iconImageURL
    }
}
extension Bool: DoriFrontend.Filter._Selectable {
    @inline(never)
    public var selectorText: String {
        self ? String(localized: "FILTER_RELEASED_YES", bundle: #bundle) : String(localized: "FILTER_RELEASED_NO", bundle: #bundle)
    }
}
extension DoriFrontend.Filter.CardType: DoriFrontend.Filter._Selectable {
    public var selectorText: String {
        self.localizedString
    }
}
extension DoriFrontend.Filter.EventType: DoriFrontend.Filter._Selectable {
    public var selectorText: String {
        self.localizedString
    }
}
extension DoriFrontend.Filter.GachaType: DoriFrontend.Filter._Selectable {
    public var selectorText: String {
        self.localizedString
    }
}
extension DoriFrontend.Filter.SongType: DoriFrontend.Filter._Selectable {
    public var selectorText: String {
        self.localizedString
    }
}
extension DoriFrontend.Filter.Skill: DoriFrontend.Filter._Selectable {
    public var selectorText: String {
        self.maximumDescription.forPreferredLocale() ?? ""
    }
}
extension Optional<DoriFrontend.Filter.Skill>: DoriFrontend.Filter._Selectable {
    @inline(never)
    public var selectorText: String {
        if let skill = self {
            skill.maximumDescription.forPreferredLocale() ?? ""
        } else {
            String(localized: "FILTER_SKILL_ANY", bundle: #bundle)
        }
    }
}
extension DoriFrontend.Filter.TimelineStatus: DoriFrontend.Filter._Selectable {
    public var selectorText: String {
        self.localizedString
    }
}
extension DoriFrontend.Filter.Sort.Keyword: DoriFrontend.Filter._Selectable {
    public var selectorText: String {
        self.localizedString
    }
}
extension DoriFrontend.Filter.Sort: DoriFrontend.Filter._Selectable {
    public var selectorText: String {
        self.keyword.localizedString
    }
}
extension DoriFrontend.Filter.Key {
    public var selector: (type: SelectionType, items: [SelectorItem<DoriFrontend.Filter._AnySelectable>]) {
        switch self {
        case .band:
            (.multiple, DoriFrontend.Filter.Band.allCases.map {
                SelectorItem(DoriFrontend.Filter._AnySelectable($0))
            })
        case .attribute:
            (.multiple, DoriFrontend.Filter.Attribute.allCases.map {
                SelectorItem(DoriFrontend.Filter._AnySelectable($0))
            })
        case .rarity:
            (.multiple, (1...5).map {
                SelectorItem(DoriFrontend.Filter._AnySelectable($0))
            })
        case .character:
            (.multiple, DoriFrontend.Filter.Character.allCases.map {
                SelectorItem(DoriFrontend.Filter._AnySelectable($0))
            })
        case .server:
            (.multiple, DoriFrontend.Filter.Server.allCases.map {
                SelectorItem(DoriFrontend.Filter._AnySelectable($0))
            })
        case .released:
            (.multiple, [true, false].map {
                SelectorItem(DoriFrontend.Filter._AnySelectable($0))
            })
        case .cardType:
            (.multiple, DoriFrontend.Filter.CardType.allCases.map {
                SelectorItem(DoriFrontend.Filter._AnySelectable($0))
            })
        case .eventType:
            (.multiple, DoriFrontend.Filter.EventType.allCases.map {
                SelectorItem(DoriFrontend.Filter._AnySelectable($0))
            })
        case .gachaType:
            (.multiple, DoriFrontend.Filter.GachaType.allCases.map {
                SelectorItem(DoriFrontend.Filter._AnySelectable($0))
            })
        case .songType:
            (.multiple, DoriFrontend.Filter.SongType.allCases.map {
                SelectorItem(DoriFrontend.Filter._AnySelectable($0))
            })
        case .skill:
            (.single, InMemoryCache.allSkills.map {
                SelectorItem(DoriFrontend.Filter._AnySelectable($0))
            })
        case .timelineStatus:
            (.multiple, DoriFrontend.Filter.TimelineStatus.allCases.map {
                SelectorItem(DoriFrontend.Filter._AnySelectable($0))
            })
        case .sort:
            (.single, DoriFrontend.Filter.Sort.Keyword.allCases.map {
                SelectorItem(DoriFrontend.Filter._AnySelectable($0))
            })
        }
    }
    
    public struct SelectorItem<T: DoriFrontend.Filter._Selectable> {
        public let item: T
        
        internal init(_ item: T) {
            self.item = item
        }
        
        public var text: String {
            item.selectorText
        }
        public var imageURL: URL? {
            item.selectorImageURL
        }
    }
    
    @frozen
    public enum SelectionType {
        case single
        case multiple
    }
}
extension DoriFrontend.Filter.Key.SelectorItem: Equatable where T: Equatable {}
extension DoriFrontend.Filter.Key.SelectorItem: Hashable where T: Hashable {}
