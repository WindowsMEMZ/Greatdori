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
        func matches<ValueType>(value: ValueType) -> Bool
    }
}

//MARK: actor PreviewCardCache
actor PreviewCardCache {
    static let shared = PreviewCardCache()
    
    // 缓存的数据
    private var cachedCards: [DoriAPI.Card.PreviewCard]?

    // Read
    func getCachedCards() -> [DoriAPI.Card.PreviewCard]? {
        cachedCards
    }

    // Write
    func update(cards: [DoriAPI.Card.PreviewCard]?) {
        cachedCards = cards
    }
}



extension DoriAPI.Event.PreviewEvent {
  func matches<ValueType>(value: ValueType) -> Bool {
    if let attribute = value as? DoriFrontend.Filter.Attribute {
      return self.attributes.contains { attribute in
        self.attributes.contains { $0.attribute == attribute.attribute }
      }
    } else if let character = value as? DoriFrontend.Filter.Character {
      return self.characters.contains { character in
        self.characters.contains { $0.characterID == character.characterID }
      }
    } else if let server = value as? DoriFrontend.Filter.Server {
      return self.startAt.availableInLocale(server)
    } else if let timelineStatus = value as? DoriFrontend.Filter.TimelineStatus {
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
    } else if let eventType = value as? DoriFrontend.Filter.EventType {
      return self.eventType == eventType
    } else {
      return false
    }
  }
}


#Playground {
  Task {
    let latestEvent = await DoriFrontend.Event.list()!.first!
    latestEvent
    latestEvent.matches(value: DoriFrontend.Filter.Character(rawValue: 31))
    latestEvent.matches(value: DoriFrontend.Filter.Character(rawValue: 2))
  }
}
