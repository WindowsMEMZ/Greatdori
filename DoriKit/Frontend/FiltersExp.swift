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
    protocol Filterable {
        func matches<ValueType>(value: ValueType) -> Bool
    }
}

extension DoriAPI.Event.PreviewEvent: Filterable {
    func matches<ValueType>(value: ValueType) -> Bool {
        if ValueType.self is RarityType.Type {
            // 处理 RarityType 的逻辑
        }
        // 其他类型逻辑...
        return false
    }
}

public extension DoriFrontend {
    public class EventsFilter {
        public var allEvents: [DoriFrontend.Event.PreviewEvent]?
        public var result: [DoriFrontend.Event.PreviewEvent]?
        public var filter: DoriFrontend.Filter = .init()
        
        public init() async {
            self.allEvents = await DoriAPI.Event.all()
            self.result = allEvents
        }
        
        public func getCards(withFilter: DoriFrontend.Filter = .init()) -> [DoriFrontend.Event.PreviewEvent]? {
            guard let events = allEvents else { return nil }
            guard withFilter.isFiltered else { return events }
            
            let filteredEvents = events.filter { event in
                filter.attribute.contains { attribute in
                    event.attributes.contains { $0.attribute == attribute }
                }
            } .filter { event in
                if filter.characterRequiresMatchAll {
                    filter.character.allSatisfy { character in
                        event.characters.contains { $0.characterID == character.rawValue }
                    }
                } else {
                    filter.character.contains { character in
                        event.characters.contains { $0.characterID == character.rawValue }
                    }
                }
            } .filter { event in
                filter.server.contains { locale in
                    event.startAt.availableInLocale(locale)
                }
            } .filter { event in
                for timelineStatus in filter.timelineStatus {
                    switch timelineStatus {
                    case .ended:
                        for singleLocale in DoriAPI.Locale.allCases {
                            if (event.endAt.forLocale(singleLocale) ?? .init(timeIntervalSince1970: 4107477600)) < .now {
                                return true
                            }
                        }
                    case .ongoing:
                        for singleLocale in DoriAPI.Locale.allCases {
                            if (event.startAt.forLocale(singleLocale) ?? .init(timeIntervalSince1970: 4107477600)) < .now
                                && (event.endAt.forLocale(singleLocale) ?? .init(timeIntervalSince1970: 0)) > .now {
                                return true
                            }
                        }
                    case .upcoming:
                        for singleLocale in DoriAPI.Locale.allCases {
                            if (event.startAt.forLocale(singleLocale) ?? .init(timeIntervalSince1970: 0)) > .now {
                                return true
                            }
                        }
                    }
                }
                return false
            }.filter { event in
                filter.eventType.contains(event.eventType)
            }
            let sortedEvents = switch filter.sort.keyword {
            case .releaseDate(let locale):
                filteredEvents.sorted { lhs, rhs in
                    filter.sort.compare(
                        lhs.startAt.forLocale(locale) ?? lhs.startAt.forPreferredLocale() ?? .init(timeIntervalSince1970: 0),
                        rhs.startAt.forLocale(locale) ?? rhs.startAt.forPreferredLocale() ?? .init(timeIntervalSince1970: 0)
                    )
                }
            default:
                filteredEvents.sorted { lhs, rhs in
                    filter.sort.compare(lhs.id, rhs.id)
                }
            }
            return sortedEvents
        }
    }
}

//#Playground {
//    Task {
//        let cardsFilter = await DoriFrontend.EventsFilter()
//        cardsFilter.getCards(withFilter: DoriFrontend.Filter.init(attribute: [DoriAPI.Attribute.happy]))
//    }
//}
