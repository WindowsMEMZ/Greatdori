//===---*- Greatdori! -*---------------------------------------------------===//
//
// FrontendCharacter.swift
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
    /// Request and fetch data about character in Bandori.
    public enum Character {
        /// Returns characters that birthdays are around provided date.
        ///
        /// - Parameters:
        ///   - date: A date for comparing with characters' birthdays.
        ///   - timeZone: A time zone corresponding to the `date`.
        /// - Returns: Characters that birthdays are around provided date, nil if failed to fetch.
        ///
        /// This function returns 1 character which the birthday is exactly
        /// match the `date` provided (year, hour, minute and second are ignored)
        /// if available; otherwise, it returns 2 characters, where the birthday
        /// of the first one is after provided `date`, and the second one's
        /// is before provided `date`.
        public static func recentBirthdayCharacters(aroundDate date: Date = .now, timeZone: TimeZone = .init(identifier: "Asia/Tokyo")!) async -> [BirthdayCharacter]? {
            func normalize(_ inputDate: Date, timezone: TimeZone = .init(identifier: "Asia/Tokyo")!) -> Date {
                var calendar = Calendar(identifier: .gregorian)
                calendar.timeZone = timezone
                var components = calendar.dateComponents([.month, .day], from: inputDate)
                components.year = 2000
                components.hour = 0
                components.minute = 0
                components.second = 0
                return calendar.date(from: components)!/*.componentsRewritten(year: 2000, hour: 0, minute: 0, second: 0)*/
            }
            
            guard let allBirthday = await DoriAPI.Character.allBirthday() else { return nil }
            
            var todaysCalender = Calendar(identifier: .gregorian)
            todaysCalender.timeZone = timeZone
            let todaysMonth: Int = todaysCalender.component(.month, from: date)
            let todaysDay: Int = todaysCalender.component(.day, from: date)
            todaysCalender.timeZone = .init(identifier: "Asia/Tokyo")!
            let today = todaysCalender.date(from: DateComponents(timeZone: .init(identifier: "Asia/Tokyo")!, year: 2000, month: todaysMonth, day: todaysDay, hour: 0, minute: 0, second: 0))!
            
            // Make all birthdays in the same year, hour, minute and second
            let normalizedBirthdays = allBirthday.map { character in
                var mutableCharacter = character
                mutableCharacter.birthday = normalize(character.birthday)
                // mutableCharacters
                return mutableCharacter
            }
            
            // We check if there's any birthdays today so we can do early exit
            // and emit time-costing sorting.
            let birthdaysToday = normalizedBirthdays.filter { character in
                character.birthday == today
            }
            if !birthdaysToday.isEmpty {
                return allBirthday
                    .filter { character in birthdaysToday.contains(where: { $0.id == character.id }) }
                    .sorted { $0.birthday > $1.birthday }
            }
            
            let sortedBirthdays = normalizedBirthdays.sorted { $0.birthday < $1.birthday }
            let after = sortedBirthdays.first { $0.birthday >= today } ?? sortedBirthdays.first!
            let before = sortedBirthdays.reversed().first { $0.birthday <= today } ?? sortedBirthdays.last!
            // Because more than 1 people may have the same birthday,
            // we have to filter them out again.
            var result = sortedBirthdays.filter { $0.birthday == after.birthday || $0.birthday == before.birthday }
            // And filter from source again because they've been normalized...
            result = allBirthday
                .filter { character in result.contains { $0.id == character.id } }
                .sorted { $0.birthday > $1.birthday }
            let sortedAll = allBirthday.sorted { $0.birthday < $1.birthday }
            if result.contains(where: { $0.id == sortedAll.first!.id })
                && result.contains(where: { $0.id == sortedAll.last!.id }) {
                // Make sure the character whose birthday isn't passed appears first.
                result.swapAt(0, 1)
            }
            return result
        }
        
        /// List all characters that are categorized with their bands.
        ///
        /// - Returns: All characters that are categorized with their bands, nil if failed to fetch.
        ///
        /// Characters without a corresponding band can be accessed by `nil` as key of the result dictionary.
        public static func categorizedCharacters() async -> CategorizedCharacters? {
            let groupResult = await withTasksResult {
                await DoriAPI.Band.main()
            } _: {
                await DoriAPI.Character.all()
            }
            guard let bands = groupResult.0 else { return nil }
            guard let characters = groupResult.1 else { return nil }
            
            var result = [DoriAPI.Band.Band?: [PreviewCharacter]]()
            
            // Add characters for each bands
            for band in bands {
                var characters = characters.filter { $0.bandID == band.id }
                if _slowPath(band.id == 3) {
                    // Hello, Happy World!
                    characters.removeAll { $0.id == 601 } // Misaki...
                }
                result.updateValue(characters, forKey: band)
            }
            
            // Add characters that aren't in any band
            result.updateValue(characters.filter { $0.bandID == nil }, forKey: nil)
            
            return result
        }
        
        /// Get a detailed character with related information.
        ///
        /// - Parameter id: The ID of character.
        /// - Returns: The character of requested ID,
        ///     with related band, cards, costumes, events and gacha.
        public static func extendedInformation(of id: Int) async -> ExtendedCharacter? {
            let groupResult = await withTasksResult {
                await DoriAPI.Character.detail(of: id)
            } _: {
                await DoriAPI.Band.all()
            } _: {
                await DoriAPI.Card.all()
            } _: {
                await DoriAPI.Costume.all()
            } _: {
                await DoriAPI.Event.all()
            } _: {
                await DoriAPI.Gacha.all()
            }
            guard let character = groupResult.0 else { return nil }
            guard let bands = groupResult.1 else { return nil }
            guard let cards = groupResult.2 else { return nil }
            guard let costumes = groupResult.3 else { return nil }
            guard let events = groupResult.4 else { return nil }
            guard let gacha = groupResult.5 else { return nil }
            
            let band = if let id = character.bandID {
                bands.first { $0.id == id }
            } else {
                nil as DoriAPI.Band.Band?
            }
            
            let newCards = cards.filter { $0.characterID == character.id }
            
            return .init(
                id: id,
                character: character,
                band: band,
                cards: newCards,
                costumes: costumes.filter { $0.characterID == character.id },
                events: events.filter { $0.characters.contains { $0.characterID == character.id } },
                gacha: gacha.filter { $0.newCards.contains { cardID in newCards.contains { $0.id == cardID } } }
            )
        }
    }
}

extension DoriFrontend.Character {
    public typealias PreviewCharacter = DoriAPI.Character.PreviewCharacter
    public typealias BirthdayCharacter = DoriAPI.Character.BirthdayCharacter
    public typealias CategorizedCharacters = [DoriAPI.Band.Band?: [PreviewCharacter]]
    public typealias Character = DoriAPI.Character.Character
    
    public struct ExtendedCharacter: Sendable, Identifiable, Hashable, DoriCache.Cacheable {
        public var id: Int
        public var character: Character
        public var band: DoriAPI.Band.Band?
        public var cards: [DoriAPI.Card.PreviewCard]
        public var costumes: [DoriAPI.Costume.PreviewCostume]
        public var events: [DoriAPI.Event.PreviewEvent]
        public var gacha: [DoriAPI.Gacha.PreviewGacha]
        
        internal init(
            id: Int,
            character: Character,
            band: DoriAPI.Band.Band?,
            cards: [DoriAPI.Card.PreviewCard],
            costumes: [DoriAPI.Costume.PreviewCostume],
            events: [DoriAPI.Event.PreviewEvent],
            gacha: [DoriAPI.Gacha.PreviewGacha]
        ) {
            self.id = id
            self.character = character
            self.band = band
            self.cards = cards
            self.costumes = costumes
            self.events = events
            self.gacha = gacha
        }
    }
}

extension DoriFrontend.Character.ExtendedCharacter {
    public func randomCard() -> DoriAPI.Card.PreviewCard? {
        self.cards.randomElement()
    }
}
