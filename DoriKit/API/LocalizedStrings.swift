//===---*- Greatdori! -*---------------------------------------------------===//
//
// LocalizedStrings.swift
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

extension DoriAPI.Constellation {
    @inline(never)
    public var localizedString: String {
        switch self {
        case .aries: String(localized: "CONSTELLATION_ARIES", bundle: #bundle)
        case .taurus: String(localized: "CONSTELLATION_TAURUS", bundle: #bundle)
        case .gemini: String(localized: "CONSTELLATION_GEMINI", bundle: #bundle)
        case .cancer: String(localized: "CONSTELLATION_CANCER", bundle: #bundle)
        case .leo: String(localized: "CONSTELLATION_LEO", bundle: #bundle)
        case .virgo: String(localized: "CONSTELLATION_VIRGO", bundle: #bundle)
        case .libra: String(localized: "CONSTELLATION_LIBRA", bundle: #bundle)
        case .scorpio: String(localized: "CONSTELLATION_SCORPIO", bundle: #bundle)
        case .sagittarius: String(localized: "CONSTELLATION_SAGITTARIUS", bundle: #bundle)
        case .capricorn: String(localized: "CONSTELLATION_CAPRICORN", bundle: #bundle)
        case .aquarius: String(localized: "CONSTELLATION_AQUARIUS", bundle: #bundle)
        case .pisces: String(localized: "CONSTELLATION_PISCES", bundle: #bundle)
        }
    }
}

extension DoriAPI.Card.CardType {
    @inline(never)
    public var localizedString: String {
        NSLocalizedString("card" + self.rawValue, bundle: #bundle, comment: "")
    }
}

extension DoriAPI.Character.Character.Profile.Part {
    @inline(never)
    public var localizedString: String {
        switch self {
        case .vocal: String(localized: "CHARACTER_PROFILE_PART_VOCAL", bundle: #bundle)
        case .keyboard: String(localized: "CHARACTER_PROFILE_PART_KEYBOARD", bundle: #bundle)
        case .guitar: String(localized: "CHARACTER_PROFILE_PART_GUITAR", bundle: #bundle)
        case .guitarVocal: String(localized: "CHARACTER_PROFILE_PART_GUITAR_VOCAL", bundle: #bundle)
        case .bass: String(localized: "CHARACTER_PROFILE_PART_BASS", bundle: #bundle)
        case .bassVocal: String(localized: "CHARACTER_PROFILE_PART_BASS_VOCAL", bundle: #bundle)
        case .drum: String(localized: "CHARACTER_PROFILE_PART_DRUM", bundle: #bundle)
        case .violin: String(localized: "CHARACTER_PROFILE_PART_VIOLIN", bundle: #bundle)
        case .dj: String(localized: "CHARACTER_PROFILE_PART_DJ", bundle: #bundle)
        }
    }
}

extension DoriAPI.Event.EventType {
    @inline(never)
    public var localizedString: String {
        NSLocalizedString("event" + self.rawValue, bundle: #bundle, comment: "")
    }
}

extension DoriAPI.Gacha.GachaType {
    @inline(never)
    public var localizedString: String {
        NSLocalizedString("gacha" + self.rawValue, bundle: #bundle, comment: "")
    }
}
extension DoriAPI.Gacha.Gacha.PaymentMethod.Method {
    @inline(never)
    public var localizedString: String {
        switch self {
        case .free: String(localized: "GACHA_PAYMENT_METHOD_METHOD_FREE", bundle: #bundle)
        case .freeStar: String(localized: "GACHA_PAYMENT_METHOD_METHOD_FREE_STAR", bundle: #bundle)
        case .paidStar: String(localized: "GACHA_PAYMENT_METHOD_METHOD_PAID_STAR", bundle: #bundle)
        case .normalTicket: String(localized: "GACHA_PAYMENT_METHOD_METHOD_NORMAL_TICKET", bundle: #bundle)
        case .overThe3StarTicket: String(localized: "GACHA_PAYMENT_METHOD_METHOD_OVER_THE_3_STAR_TICKET", bundle: #bundle)
        case .overThe4StarTicket: String(localized: "GACHA_PAYMENT_METHOD_METHOD_OVER_THE_4_STAR_TICKET", bundle: #bundle)
        case .fixed5StarTicket: String(localized: "GACHA_PAYMENT_METHOD_METHOD_FIXED_5_STAR_TICKET", bundle: #bundle)
        }
    }
}
extension DoriAPI.Gacha.Gacha.PaymentMethod.Behavior {
    @inline(never)
    public var localizedString: String {
        switch self {
        case .normal: String()
        case .overThe3StarOnce: String(localized: "GACHA_PAYMENT_METHOD_BEHAVIOR_OVER_THE_3_STAR_ONCE", bundle: #bundle)
        case .overThe4StarOnce: String(localized: "GACHA_PAYMENT_METHOD_BEHAVIOR_OVER_THE_4_STAR_ONCE", bundle: #bundle)
        case .onceADay: String(localized: "GACHA_PAYMENT_METHOD_BEHAVIOR_ONCE_A_DAY", bundle: #bundle)
        case .onceADayOverThe3StarOnce: String(localized: "GACHA_PAYMENT_METHOD_BEHAVIOR_ONCE_A_DAY_OVER_THE_3_STAR_ONCE", bundle: #bundle)
        case .fixed5StarOnce: String(localized: "GACHA_PAYMENT_METHOD_BEHAVIOR_FIXED_5_STAR_ONCE", bundle: #bundle)
        }
    }
}

extension DoriAPI.LoginCampaign.CampaignType {
    @inline(never)
    public var localizedString: String {
        NSLocalizedString("login" + self.rawValue, bundle: #bundle, comment: "")
    }
}

#if HAS_BINARY_RESOURCE_BUNDLES
extension DoriAPI.Post.Post.StoryMetadata.AgeRating {
    @inline(never)
    public var localizedString: String {
        switch self {
        case .general: String(localized: "COMMUNITY_STORY_AGE_RATING_GENERAL", bundle: #bundle)
        case .teenAndUp: String(localized: "COMMUNITY_STORY_AGE_RATING_TEEN_AND_UP", bundle: #bundle)
        case .mature: String(localized: "COMMUNITY_STORY_AGE_RATING_MATURE", bundle: #bundle)
        case .explicit: String(localized: "COMMUNITY_STORY_AGE_RATING_EXPLICIT", bundle: #bundle)
        }
    }
}
#endif

extension DoriAPI.Song.SongTag {
    @inline(never)
    public var localizedString: String {
        NSLocalizedString("tag" + self.rawValue, bundle: #bundle, comment: "")
    }
}
