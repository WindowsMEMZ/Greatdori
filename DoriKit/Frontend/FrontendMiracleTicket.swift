//===---*- Greatdori! -*---------------------------------------------------===//
//
// FrontendMiracleTicket.swift
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
    /// Request and fetch data about miracle tickets in Bandori.
    public enum MiracleTicket {
        /// List all miracle tickets with related information.
        ///
        /// - Returns: All miracle tickets with related cards.
        public static func extendedList() async -> [ExtendedMiracleTicket]? {
            let groupResult = await withTasksResult {
                await DoriAPI.MiracleTicket.all()
            } _: {
                await DoriAPI.Card.all()
            }
            guard let tickets = groupResult.0 else { return nil }
            guard let cards = groupResult.1 else { return nil }
            
            return tickets.map {
                .init(
                    ticket: $0,
                    cards: $0.ids.map { ids in
                        if let ids {
                            cards.filter { ids.contains($0.id) }
                        } else {
                            nil
                        }
                    }
                )
            }
        }
    }
}

extension DoriFrontend.MiracleTicket {
    public struct ExtendedMiracleTicket: Sendable, Identifiable, Hashable, DoriCache.Cacheable {
        public var ticket: DoriAPI.MiracleTicket.MiracleTicket
        public var cards: DoriAPI.LocalizedData<[DoriAPI.Card.PreviewCard]>
        
        public var id: Int {
            ticket.id
        }
    }
}
