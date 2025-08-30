//===---*- Greatdori! -*---------------------------------------------------===//
//
// FrontendLoginCampaign.swift
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
    /// Request and fetch data about login campaigns in Bandori.
    public enum LoginCampaign {
        /// List all login campaigns with a filter.
        ///
        /// - Parameter filter: A ``DoriFrontend/Filter`` for filtering result.
        /// - Returns: All login campaigns, nil if failed to fetch.
        ///
        /// This function respects these keys in `filter`:
        ///
        /// - ``DoriFrontend/Filter/Key/server``
        /// - ``DoriFrontend/Filter/Key/timelineStatus``
        /// - ``DoriFrontend/Filter/Key/loginCampaignType``
        /// - ``DoriFrontend/Filter/Key/sort``
        ///     - ``DoriFrontend/Filter/Sort/Keyword/releaseDate(in:)``
        ///     - ``DoriFrontend/Filter/Sort/Keyword/id``
        ///
        /// Other keys are ignored.
        public static func list(filter: Filter = .init()) async -> [PreviewCampaign]? {
            guard let campaigns = await DoriAPI.LoginCampaign.all() else { return nil }
            
            var filteredCampaigns = campaigns
            if filter.isFiltered {
                filteredCampaigns = campaigns.filter { campaign in
                    filter.loginCampaignType.contains { campaign.loginBonusType.rawValue == $0.rawValue }
                }.filter { campaign in
                    filter.server.contains { locale in
                        campaign.publishedAt.availableInLocale(locale)
                    }
                }.filter { campaign in
                    for timelineStatus in filter.timelineStatus {
                        let result = switch timelineStatus {
                        case .ended:
                            (campaign.closedAt.forPreferredLocale() ?? .init(timeIntervalSince1970: 4107477600)) < .now
                        case .ongoing:
                            (campaign.publishedAt.forPreferredLocale() ?? .init(timeIntervalSince1970: 4107477600)) < .now
                            && (campaign.closedAt.forPreferredLocale() ?? .init(timeIntervalSince1970: 0)) > .now
                        case .upcoming:
                            (campaign.publishedAt.forPreferredLocale() ?? .init(timeIntervalSince1970: 0)) > .now
                        }
                        if result {
                            return true
                        }
                    }
                    return false
                }
            }
            
            switch filter.sort.keyword {
            case .releaseDate(let locale):
                return filteredCampaigns.sorted { lhs, rhs in
                    filter.sort.compare(
                        lhs.publishedAt.forLocale(locale) ?? lhs.publishedAt.forPreferredLocale() ?? .init(timeIntervalSince1970: 0),
                        rhs.publishedAt.forLocale(locale) ?? rhs.publishedAt.forPreferredLocale() ?? .init(timeIntervalSince1970: 0)
                    )
                }
            default:
                return filteredCampaigns.sorted { lhs, rhs in
                    filter.sort.compare(lhs.id, rhs.id)
                }
            }
        }
    }
}

extension DoriFrontend.LoginCampaign {
    public typealias PreviewCampaign = DoriAPI.LoginCampaign.PreviewCampaign
}
