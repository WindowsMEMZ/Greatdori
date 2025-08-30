//===---*- Greatdori! -*---------------------------------------------------===//
//
// FrontendComic.swift
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
    /// Request and fetch data about comics in Bandori.
    public enum Comic {
        /// List all comics with a filter.
        ///
        /// - Parameter filter: A ``DoriFrontend/Filter`` for filtering result.
        /// - Returns: All comics, nil if failed to fetch.
        ///
        /// This function respects these keys in `filter`:
        ///
        /// - ``DoriFrontend/Filter/Key/character``
        /// - ``DoriFrontend/Filter/Key/server``
        /// - ``DoriFrontend/Filter/Key/comicType``
        /// - ``DoriFrontend/Filter/Key/sort``
        ///     - ``DoriFrontend/Filter/Sort/Keyword/id``
        ///
        /// Other keys are ignored.
        public static func list(filter: Filter = .init()) async -> [Comic]? {
            guard let comics = await DoriAPI.Comic.all() else { return nil }
            
            var filteredComics = comics
            if filter.isFiltered {
                filteredComics = comics.filter { comic in
                    filter.comicType.contains(comic.type ?? .singleFrame)
                }.filter { comic in
                    filter.character.contains { comic.characterIDs.contains($0.rawValue) }
                }.filter { comic in
                    filter.server.contains { locale in
                        comic.publicStartAt.availableInLocale(locale)
                    }
                }
            }
            
            // Comics can only be sorted by ID.
            return filteredComics.sorted { lhs, rhs in
                filter.sort.compare(lhs.id, rhs.id)
            }
        }
    }
}

extension DoriFrontend.Comic {
    public typealias Comic = DoriAPI.Comic.Comic
}

extension DoriAPI.Comic.Comic {
    @frozen
    public enum ComicType: String, CaseIterable, Hashable, Codable {
        case singleFrame
        case fourFrame
        
        @inline(never)
        public var localizedString: String {
            NSLocalizedString(rawValue, bundle: #bundle, comment: "")
        }
    }
    
    @inlinable
    public var type: ComicType? {
        self.id > 0 && self.id <= 1000 ? .singleFrame : self.id > 1000 ? .fourFrame : nil
    }
}
