//===---*- Greatdori! -*---------------------------------------------------===//
//
// FiltersExp.swift
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
import Playgrounds


extension DoriFrontend {
    //MARK: protocol Filterable
    protocol Filterable {
        func matches<ValueType>(_ value: ValueType) -> Bool?
    }
    
    //MARK: actor PreviewCardCache
    actor FilterCache {
        static let shared = FilterCache()
        
        public var cachedCards: [DoriAPI.Card.PreviewCard]?
        func readCardCache() -> [DoriAPI.Card.PreviewCard]? {
            cachedCards
        }
        func writeCardCache(_ cards: [DoriAPI.Card.PreviewCard]?) {
            cachedCards = cards
        }
        
//        public var cachedCards: [DoriAPI.Card.PreviewCard]?
//        func readCardCache() -> [DoriAPI.Card.PreviewCard]? {
//            cachedCards
//        }
//        func writeCardCache(_ cards: [DoriAPI.Card.PreviewCard]?) {
//            cachedCards = cards
//        }
    }
}




extension DoriAPI.Event.PreviewEvent {
    func matches<ValueType>(_ value: ValueType) -> Bool? {
        if let attribute = value as? DoriFrontend.Filter.Attribute { // Attribute
            return self.attributes.contains { $0.attribute == attribute }
        } else if let character = value as? DoriFrontend.Filter.Character { // Character
            return self.characters.contains { $0.characterID == character.rawValue }
        } else if let server = value as? DoriFrontend.Filter.Server { // Server
            return self.startAt.availableInLocale(server)
        } else if let timelineStatus = value as? DoriFrontend.Filter.TimelineStatus { // Timeline Status
            switch timelineStatus {
            case .ended:
                for singleLocale in DoriAPI.Locale.allCases {
                    if (self.endAt.forLocale(singleLocale) ?? .init(timeIntervalSince1970: 4107477600)) < .now {
                        return true
                    }
                }
            case .ongoing:
                for singleLocale in DoriAPI.Locale.allCases {
                    if (self.startAt.forLocale(singleLocale) ?? .init(timeIntervalSince1970: 4107477600)) < .now
                        && (self.endAt.forLocale(singleLocale) ?? .init(timeIntervalSince1970: 0)) > .now {
                        return true
                    }
                }
            case .upcoming:
                for singleLocale in DoriAPI.Locale.allCases {
                    if (self.startAt.forLocale(singleLocale) ?? .init(timeIntervalSince1970: 0)) > .now {
                        return true
                    }
                }
            }
            return false
        } else if let eventType = value as? DoriFrontend.Filter.EventType { // Event Type
            return self.eventType == eventType
        } else {
            return nil
        }
    }
}

extension DoriAPI.Event.PreviewGacha {
    func matches<ValueType>(_ value: ValueType) -> Bool? {
        if let attribute = value as? DoriFrontend.Filter.Attribute { // Attribute
            return self.attributes.contains { $0.attribute == attribute }
        } else if let character = value as? DoriFrontend.Filter.Character { // Character
            return self.characters.contains { $0.characterID == character.rawValue }
        } else if let server = value as? DoriFrontend.Filter.Server { // Server
            return self.startAt.availableInLocale(server)
        } else if let timelineStatus = value as? DoriFrontend.Filter.TimelineStatus { // Timeline Status
            switch timelineStatus {
            case .ended:
                for singleLocale in DoriAPI.Locale.allCases {
                    if (self.endAt.forLocale(singleLocale) ?? .init(timeIntervalSince1970: 4107477600)) < .now {
                        return true
                    }
                }
            case .ongoing:
                for singleLocale in DoriAPI.Locale.allCases {
                    if (self.startAt.forLocale(singleLocale) ?? .init(timeIntervalSince1970: 4107477600)) < .now
                        && (self.endAt.forLocale(singleLocale) ?? .init(timeIntervalSince1970: 0)) > .now {
                        return true
                    }
                }
            case .upcoming:
                for singleLocale in DoriAPI.Locale.allCases {
                    if (self.startAt.forLocale(singleLocale) ?? .init(timeIntervalSince1970: 0)) > .now {
                        return true
                    }
                }
            }
            return false
        } else if let eventType = value as? DoriFrontend.Filter.EventType { // Event Type
            return self.eventType == eventType
        } else {
            return nil
        }
    }
}

extension Array where Element: DoriFrontend.Filterable {
    func filterByDori(with filter: DoriFrontend.Filter) -> [Element] {
        var result: [Element] = self
        guard filter.isFiltered else { return result }
        
        result = result.filter { element in // Attribute
            return filter.attribute.contains { attribute in
                element.matches(attribute) ?? true
            }
        } .filter { element in // Character
            if filter.characterRequiresMatchAll {
                filter.character.allSatisfy { character in
                    element.matches(character) ?? true
                }
            } else {
                filter.character.contains { character in
                    element.matches(character) ?? true
                }
            }
        } .filter { element in // Timeline Status
            filter.timelineStatus.contains { timelineStatus in
                element.matches(timelineStatus) ?? true
            }
        } .filter { element in // Server
            filter.server.contains { server in
                element.matches(server) ?? true
            }
        } .filter { element in // Event Types
            filter.eventType.contains { eventType in
                element.matches(eventType) ?? true
            }
        }
        return result
    }
}


#Playground {
    Task {
        let events = await DoriFrontend.Event.list()!
        var filter = DoriFrontend.Filter()
        filter.attribute = [.cool, .happy]
//        filter.character = [.init(rawValue: 1)!]
        filter.character = [.sayo, .moca]
        filter.characterRequiresMatchAll = false
        filter.server = [.jp, .tw]
//        filter.timelineStatus = [.ongoing]
        filter.eventType = [.challenge, .liveTry]
        events.filterByDori(with: filter)
    }
}
