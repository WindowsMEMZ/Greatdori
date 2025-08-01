//
//  FrontendCard.swift
//  Greatdori
//
//  Created by Mark Chan on 7/23/25.
//

import Foundation

extension DoriFrontend {
    public class Card {
        private init() {}
        
        public static func list(filter: Filter = .init()) async -> [CardWithBand]? {
            let groupResult = await withTasksResult {
                await DoriAPI.Card.all()
            } _: {
                await DoriAPI.Character.all()
            } _: {
                await DoriAPI.Band.main()
            }
            guard let cards = groupResult.0 else { return nil }
            guard let characters = groupResult.1 else { return nil }
            guard let bands = groupResult.2 else { return nil }
            
            let filteredCards = cards.filter { card in
                filter.band.contains { band in
                    band.rawValue == characters.first(where: { $0.id == card.characterID })?.bandID
                }
            }.filter { card in
                filter.attribute.contains(card.attribute)
            }.filter { card in
                filter.rarity.contains(card.rarity)
            }.filter { card in
                filter.character.contains { character in
                    character.rawValue == card.characterID
                }
            }.filter { card in
                filter.server.contains { locale in
                    card.prefix.availableInLocale(locale)
                }
            }.filter { card in
                for bool in filter.released {
                    for locale in filter.server {
                        if bool {
                            if (card.releasedAt.forLocale(locale) ?? .init(timeIntervalSince1970: 4107477600)) < .now {
                                return true
                            }
                        } else {
                            if (card.releasedAt.forLocale(locale) ?? .init(timeIntervalSince1970: 0)) > .now {
                                return true
                            }
                        }
                    }
                }
                return false
            }.filter { card in
                filter.cardType.contains(card.type)
            }.filter { card in
                if let skill = filter.skill {
                    skill.id == card.skillID
                } else {
                    true
                }
            }
            let sortedCards = switch filter.sort.keyword {
            case .releaseDate(let locale):
                filteredCards.sorted { lhs, rhs in
                    filter.sort.compare(
                        lhs.releasedAt.forLocale(locale) ?? lhs.releasedAt.forPreferredLocale() ?? .init(timeIntervalSince1970: 0),
                        rhs.releasedAt.forLocale(locale) ?? rhs.releasedAt.forPreferredLocale() ?? .init(timeIntervalSince1970: 0)
                    )
                }
            case .rarity:
                filteredCards.sorted { lhs, rhs in
                    filter.sort.compare(lhs.rarity, rhs.rarity)
                }
            case .maximumStat:
                filteredCards.sorted { lhs, rhs in
                    return filter.sort.compare(lhs.stat.forMaximumLevel()?.total ?? 0, rhs.stat.forMaximumLevel()?.total ?? 0)
                }
            case .id:
                filteredCards.sorted { lhs, rhs in
                    filter.sort.compare(lhs.id, rhs.id)
                }
            }
            return sortedCards.compactMap { card in
                if let band = bands.first(where: { $0.id == characters.first { $0.id == card.characterID }?.bandID }) {
                    .init(card: card, band: band)
                } else {
                    nil
                }
            }
        }
        
        public static func extendedInformation(of id: Int) async -> ExtendedCard? {
            let groupResult = await withTasksResult {
                await DoriAPI.Card.detail(of: id)
            } _: {
                await DoriAPI.Character.all()
            } _: {
                await DoriAPI.Band.main()
            } _: {
                await DoriAPI.Skill.all()
            } _: {
                await DoriAPI.Costume.all()
            } _: {
                await DoriAPI.Event.all()
            } _: {
                await DoriAPI.Gacha.all()
            }
            guard let card = groupResult.0 else { return nil }
            guard let characters = groupResult.1 else { return nil }
            guard let bands = groupResult.2 else { return nil }
            guard let skills = groupResult.3 else { return nil }
            guard let costumes = groupResult.4 else { return nil }
            guard let events = groupResult.5 else { return nil }
            guard let gacha = groupResult.6 else { return nil }
            
            let character = characters.first { $0.id == card.characterID }!
            var resultGacha = [DoriAPI.Gacha.PreviewGacha]()
            if let source = card.source.forPreferredLocale() {
                for src in source {
                    guard case .gacha(let info) = src else { continue }
                    resultGacha = gacha.filter { info.keys.contains($0.id) }
                }
            }
            
            return .init(
                id: id,
                card: card,
                character: character,
                band: bands.first { character.bandID == $0.id }!,
                skill: skills.first { $0.id == card.skillID }!,
                costume: costumes.first { $0.id == card.costumeID }!,
                events: events.filter { event in resultGacha.contains { $0.publishedAt.forPreferredLocale() == event.startAt.forPreferredLocale() } },
                gacha: resultGacha
            )
        }
    }
}

extension DoriFrontend.Card {
    public typealias PreviewCard = DoriAPI.Card.PreviewCard
    public typealias Card = DoriAPI.Card.Card
    
    public struct CardWithBand: Hashable, DoriCache.Cacheable {
        public var card: PreviewCard
        public var band: DoriAPI.Band.Band
    }
    public struct ExtendedCard: Identifiable, DoriCache.Cacheable {
        public var id: Int
        public var card: Card
        public var character: DoriAPI.Character.PreviewCharacter
        public var band: DoriAPI.Band.Band
        public var skill: DoriAPI.Skill.Skill
        public var costume: DoriAPI.Costume.PreviewCostume
        public var events: [DoriAPI.Event.PreviewEvent]
        public var gacha: [DoriAPI.Gacha.PreviewGacha]
    }
}
extension DoriFrontend.Card.CardWithBand: DoriFrontend.Searchable {
    public var id: Int { self.card.id }
    public var _searchLocalizedStrings: [DoriAPI.LocalizedData<String>] {
        self.card._searchLocalizedStrings
    }
    public var _searchIntegers: [Int] {
        self.card._searchIntegers
    }
    public var _searchLocales: [DoriAPI.Locale] {
        self.card._searchLocales
    }
    public var _searchBands: [DoriAPI.Band.Band] {
        [self.band]
    }
    public var _searchAttributes: [DoriAPI.Attribute] {
        self.card._searchAttributes
    }
}
