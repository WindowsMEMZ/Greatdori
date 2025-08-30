//===---*- Greatdori! -*---------------------------------------------------===//
//
// FrontendEvent.swift
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
    /// Request and fetch data about events in Bandori.
    public enum Event {
        /// Returns latest events for each locales.
        ///
        /// - Returns: Latest events for each locales, nil if failed to fetch.
        public static func localizedLatestEvent() async -> DoriAPI.LocalizedData<PreviewEvent>? {
            guard let allEvents = await DoriAPI.Event.all() else { return nil }
            var result = DoriAPI.LocalizedData<PreviewEvent>(jp: nil, en: nil, tw: nil, cn: nil, kr: nil)
            // Find from latest to earliest.
            let reversedEvents = allEvents.filter { $0.id <= 5000 }.reversed()
            for locale in DoriAPI.Locale.allCases {
                let availableEvents = reversedEvents.filter { $0.startAt.availableInLocale(locale) }
                if let ongoingEvent = availableEvents.first(where: {
                    $0.startAt.forLocale(locale)! <= .now
                    && $0.endAt.forLocale(locale)!.timeIntervalSinceNow > 0
                }) {
                    // Use ongoing locale firstly
                    result._set(ongoingEvent, forLocale: locale)
                } else {
                    // Otherwise find the event where `startAt` is closest to now
                    result._set(
                        availableEvents.min(by: {
                            abs($0.startAt.forLocale(locale)!.timeIntervalSinceNow)
                            < abs($1.startAt.forLocale(locale)!.timeIntervalSinceNow)
                        }),
                        forLocale: locale
                    )
                }
                if let event = result.forLocale(locale), let endDate = event.endAt.forLocale(locale), endDate < .now {
                    // latest event has ended, but next event is null
                    if let nextEvent = allEvents.first(where: { $0.id == event.id + 1 }) {
                        result._set(nextEvent, forLocale: locale)
                    }
                }
            }
            return result
        }
        
        /// List all events with a filter.
        ///
        /// - Parameter filter: A ``DoriFrontend/Filter`` for filtering result.
        /// - Returns: All events, nil if failed to fetch.
        ///
        /// This function respects these keys in `filter`:
        ///
        /// - ``DoriFrontend/Filter/Key/attribute``
        /// - ``DoriFrontend/Filter/Key/character``
        /// - ``DoriFrontend/Filter/Key/characterRequiresMatchAll``
        /// - ``DoriFrontend/Filter/Key/server``
        /// - ``DoriFrontend/Filter/Key/timelineStatus``
        /// - ``DoriFrontend/Filter/Key/eventType``
        /// - ``DoriFrontend/Filter/Key/sort``
        ///     - ``DoriFrontend/Filter/Sort/Keyword/releaseDate(in:)``
        ///     - ``DoriFrontend/Filter/Sort/Keyword/id``
        ///
        /// Other keys are ignored.
        public static func list(filter: Filter = .init()) async -> [PreviewEvent]? {
            guard let events = await DoriAPI.Event.all() else { return nil }
            
            let filteredEvents = events.filter { event in
                filter.attribute.contains { attribute in
                    event.attributes.contains { $0.attribute == attribute }
                }
            }.filter { event in
                if filter.characterRequiresMatchAll {
                    filter.character.allSatisfy { character in
                        event.characters.contains { $0.characterID == character.rawValue }
                    }
                } else {
                    filter.character.contains { character in
                        event.characters.contains { $0.characterID == character.rawValue }
                    }
                }
            }.filter { event in
                filter.server.contains { locale in
                    event.startAt.availableInLocale(locale)
                }
            }.filter { event in
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
        
        /// Get a detailed event with related information.
        ///
        /// - Parameter id: The ID of event.
        /// - Returns: The event of requested ID,
        ///     with related bands, characters, cards, gacha, songs and degrees.
        public static func extendedInformation(of id: Int) async -> ExtendedEvent? {
            let groupResult = await withTasksResult {
                await DoriAPI.Event.detail(of: id)
            } _: {
                await DoriAPI.Band.all()
            } _: {
                await DoriAPI.Character.all()
            } _: {
                await DoriAPI.Card.all()
            } _: {
                await DoriAPI.Gacha.all()
            } _: {
                await DoriAPI.Song.all()
            } _: {
                await DoriAPI.Degree.all()
            }
            guard let event = groupResult.0 else { return nil }
            guard let bands = groupResult.1 else { return nil }
            guard let characters = groupResult.2 else { return nil }
            guard let cards = groupResult.3 else { return nil }
            guard let gacha = groupResult.4 else { return nil }
            guard let songs = groupResult.5 else { return nil }
            guard let degrees = groupResult.6 else { return nil }
            
            let resultCharacters = characters.filter { character in event.characters.contains { $0.characterID == character.id } }
            
            return .init(
                id: id,
                event: event,
                bands: bands.filter { band in resultCharacters.contains { $0.bandID == band.id } },
                characters: resultCharacters,
                cards: cards.filter { card in event.rewardCards.contains(card.id) || event.members.contains { $0.situationID == card.id } },
                gacha: gacha.filter { event.startAt.forPreferredLocale() == $0.publishedAt.forPreferredLocale() },
                songs: songs.filter { event.startAt.forPreferredLocale() == $0.publishedAt.forPreferredLocale() },
                degrees: degrees.filter { $0.baseImageName.forPreferredLocale() == "degree_event\(event.id)_point" }
            )
        }
        
        /// Returns event tracker data.
        ///
        /// - Parameters:
        ///   - event: The event for tracking.
        ///   - locale: Tracking locale of event.
        ///   - tier: Tracking tier.
        ///   - smooth: Whether smooth the results.
        /// - Returns: The event tracker data for requested event, nil if failed to fetch or arguments are invalid.
        ///
        /// - Note:
        ///     Valid tiers are *20, 30, 40, 50, 100, 200, 300, 400, 500, 1000, 2000, 3000, 4000, 5000, 10000, 20000 and 30000*.
        ///     For data of tier 10, see ``DoriAPI/Event/topData(of:in:interval:)``.
        @inlinable
        public static func trackerData(
            for event: PreviewEvent,
            in locale: DoriAPI.Locale,
            tier: Int,
            smooth: Bool = true
        ) async -> TrackerData? {
            guard let startAt = event.startAt.forLocale(locale) else { return nil }
            guard let endAt = event.endAt.forLocale(locale) else { return nil }
            return await _trackerData(
                of: event.id,
                eventType: event.eventType,
                eventStartDate: startAt,
                eventEndDate: endAt,
                in: locale,
                tier: tier,
                smooth: smooth
            )
        }
        /// Returns event tracker data.
        ///
        /// - Parameters:
        ///   - event: The event for tracking.
        ///   - locale: Tracking locale of event.
        ///   - tier: Tracking tier.
        ///   - smooth: Whether smooth the results.
        /// - Returns: The event tracker data for requested event, nil if failed to fetch or arguments are invalid.
        ///
        /// - Note:
        ///     Valid tiers are *20, 30, 40, 50, 100, 200, 300, 400, 500, 1000, 2000, 3000, 4000, 5000, 10000, 20000 and 30000*.
        ///     For data of tier 10, see ``DoriAPI/Event/topData(of:in:interval:)``.
        @inlinable
        public static func trackerData(
            for event: Event,
            in locale: DoriAPI.Locale,
            tier: Int,
            smooth: Bool = true
        ) async -> TrackerData? {
            guard let startAt = event.startAt.forLocale(locale) else { return nil }
            guard let endAt = event.endAt.forLocale(locale) else { return nil }
            return await _trackerData(
                of: event.id,
                eventType: event.eventType,
                eventStartDate: startAt,
                eventEndDate: endAt,
                in: locale,
                tier: tier,
                smooth: smooth
            )
        }
        public static func _trackerData(
            of id: Int,
            eventType: DoriAPI.Event.EventType,
            eventStartDate: Date,
            eventEndDate: Date,
            in locale: DoriAPI.Locale,
            tier: Int,
            smooth: Bool
        ) async -> TrackerData? {
            struct TrackerDataPoint {
                let time: TimeInterval // epoch milliseconds
                let ep: Double
            }
            struct ChartPoint {
                var x: Date
                var y: Double
                var epph: Double? = nil
                var xn: Double? = nil
            }
            func withPrediction(
                _ trackerData: [TrackerDataPoint],
                start: TimeInterval,
                end: TimeInterval,
                rate: Double,
                smooth: Bool
            ) -> (actual: [ChartPoint], predicted: [ChartPoint])? {
                func regression(_ e: [(Double, Double)]) -> (a: Double, b: Double, r2: Double) {
                    var t = 0, a = 0.0, n = 0.0, i = e.count
                    while t < i {
                        a += e[t].0
                        n += e[t].1
                        t += 1
                    }
                    a /= Double(i)
                    n /= Double(i)
                    var r = 0.0, s = 0.0, o = 0.0, l = 0.0
                    t = 0
                    while t < i {
                        o += (e[t].0 - a) * (e[t].1 - n)
                        l += (e[t].0 - a) * (e[t].0 - a)
                        r += (e[t].0 - a) * (e[t].0 - a)
                        s += (e[t].1 - n) * (e[t].1 - n)
                        t += 1
                    }
                    r = sqrt(r / Double(i))
                    s = sqrt(s / Double(i))
                    let d = o / l, u = n - d * a, c = d * r / s
                    return (u, d, c * c)
                }
                
                var actual: [ChartPoint] = []
                var predicted: [ChartPoint] = []
                actual.append(ChartPoint(x: Date(timeIntervalSince1970: TimeInterval(start / 1000)), y: 0))
                predicted.append(ChartPoint(x: Date(timeIntervalSince1970: TimeInterval(start / 1000)), y: Double.infinity))
                var regressionData: [(Double, Double)] = []
                for point in trackerData {
                    let time = point.time
                    let normTime = Double(time - start) / Double(end - start)
                    let last = actual.last!
                    let epph = last.x.timeIntervalSince1970 == TimeInterval(time / 1000) ? nil :
                    Double(point.ep - last.y) / ((Double(time - last.x.timeIntervalSince1970 * 1000)) / 3600000)
                    actual.append(ChartPoint(
                        x: Date(timeIntervalSince1970: TimeInterval(time / 1000)),
                        y: point.ep,
                        epph: epph
                    ))
                    if time - start >= 432_00000 {
                        regressionData.append((normTime, point.ep))
                    }
                    var predictedPoint = ChartPoint(
                        x: Date(timeIntervalSince1970: TimeInterval(time / 1000)),
                        y: Double.infinity,
                        xn: normTime
                    )
                    if time - start >= 864_00000,
                       end - time >= 864_00000,
                       regressionData.count >= 5 {
                        let reg = regression(regressionData)
                        predictedPoint.y = reg.a + reg.b + reg.b * rate
                    }
                    if end - time < 864_00000,
                       let lastPredicted = predicted.last {
                        predictedPoint.y = lastPredicted.y
                    }
                    predicted.append(predictedPoint)
                }
                if smooth {
                    var smoothed: [ChartPoint] = []
                    for (i, pt) in predicted.enumerated() {
                        if pt.y == Double.infinity {
                            smoothed.append(pt)
                        } else {
                            var a = 0.0, b = 0.0
                            for j in 0...i {
                                let p = predicted[j]
                                if p.y != Double.infinity, let xn = p.xn {
                                    let weight = xn * xn
                                    a += p.y * weight
                                    b += weight
                                }
                            }
                            smoothed.append(ChartPoint(x: pt.x, y: a / b))
                        }
                    }
                    predicted = smoothed
                }
                if let lastPred = predicted.last,
                   lastPred.x.timeIntervalSince1970 < TimeInterval(end / 1000),
                   lastPred.y != Double.infinity {
                    predicted.append(ChartPoint(x: Date(timeIntervalSince1970: TimeInterval(end / 1000)), y: lastPred.y))
                }
                return (actual, predicted)
            }
            
            let groupResult = await withTasksResult {
                await DoriAPI.Event.trackerRates()
            } _: {
                await DoriAPI.Event.trackerData(of: id, in: locale, tier: tier)
            }
            guard let rates = groupResult.0 else { return nil }
            guard let trackerData = groupResult.1 else { return nil }
            
            guard let rate = rates.first(where: { $0.type == eventType && $0.server == locale && $0.tier == tier }) else { return nil }
            guard let raw = withPrediction(
                trackerData.cutoffs.map { TrackerDataPoint(time: $0.time.timeIntervalSince1970 * 1000, ep: Double($0.ep)) },
                start: eventStartDate.timeIntervalSince1970 * 1000,
                end: eventEndDate.timeIntervalSince1970 * 1000,
                rate: rate.rate,
                smooth: smooth
            ) else { return nil }
            let cutoffs = raw.actual.map { TrackerData.DataPoint(time: $0.x, ep: Int($0.y), epph: $0.xn != nil ? Int($0.xn!) : nil) }
            let predictions = raw.predicted.map { TrackerData.DataPoint(time: $0.x, ep: $0.y.isFinite ? Int($0.y) : nil, epph: $0.xn != nil ? Int($0.xn!) : nil) }
            return .init(cutoffs: cutoffs, predictions: predictions)
        }
    }
}

extension DoriFrontend.Event {
    public typealias PreviewEvent = DoriAPI.Event.PreviewEvent
    public typealias Event = DoriAPI.Event.Event
    
    public struct ExtendedEvent: Sendable, Identifiable, Hashable, DoriCache.Cacheable {
        public var id: Int
        public var event: Event
        public var bands: [DoriAPI.Band.Band]
        public var characters: [DoriAPI.Character.PreviewCharacter]
        public var cards: [DoriAPI.Card.PreviewCard]
        public var gacha: [DoriAPI.Gacha.PreviewGacha]
        public var songs: [DoriAPI.Song.PreviewSong]
        public var degrees: [DoriAPI.Degree.Degree]
    }
    
    public struct TrackerData: Sendable, Hashable, DoriCache.Cacheable {
        public var cutoffs: [DataPoint]
        public var predictions: [DataPoint]
        
        public struct DataPoint: Sendable, Hashable, DoriCache.Cacheable {
            public var time: Date
            public var ep: Int?
            public var epph: Int?
        }
    }
}
