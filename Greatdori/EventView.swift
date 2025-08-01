//
//  EventView.swift
//  Greatdori
//
//  Created by ThreeManager785 on 2025/7/29.
//

import SwiftUI
import DoriKit
import SDWebImageSwiftUI



struct EventDetailView: View {
    var id: Int
    @State var information: DoriFrontend.Event.ExtendedEvent?
    @State var infoIsAvailable = true
    @State var eventCharacterPercentageDict: [Int: [DoriAPI.Event.EventCharacter]] = [:]
    var dateFormatter: DateFormatter { let df = DateFormatter(); df.dateStyle = .long; df.timeStyle = .short; return df }
    var body: some View {
        NavigationStack {
            if let information {
                ScrollView {
                    HStack {
                        Spacer()
                        VStack {
                            Rectangle()
                                .opacity(0)
                                .frame(height: 2)
                            WebImage(url: information.event.bannerImageURL)
                                .resizable()
                                .aspectRatio(3.0, contentMode: .fit)
                                .frame(maxWidth: 420, maxHeight: 140)
                            Rectangle()
                                .opacity(0)
                                .frame(height: 2)
                            
                            Group {
                                ListItemView(title: {
                                    Text("Event.title")
                                        .bold()
                                }, value: {
                                    MultilingualText(source: information.event.eventName)
                                })
                                Divider()
                                ListItemView(title: {
                                    Text("Event.type")
                                        .bold()
                                }, value: {
                                    Text(information.event.eventType.localizedString)
                                })
                                Divider()
                                ListItemView(title: {
                                    Text("Event.countdown")
                                        .bold()
                                }, value: {
                                    MultilingualTextForCountdown(source: information.event)
                                })
                                Divider()
                                ListItemView(title: {
                                    Text("Event.start-date")
                                        .bold()
                                }, value: {
                                    MultilingualText(source: information.event.startAt.map{dateFormatter.string(for: $0)}, showLocaleKey: true)
                                })
                                Divider()
                                    ListItemView(title: {
                                        Text("Event.end-date")
                                            .bold()
                                    }, value: {
                                        MultilingualText(source: information.event.endAt.map{dateFormatter.string(for: $0)}, showLocaleKey: true)
                                    })
                                Divider()
                                ListItemView(title: {
                                    Text("Event.attribute")
                                        .bold()
                                }, value: {
                                    ForEach(information.event.attributes, id: \.attribute.rawValue) { attribute in
                                        VStack(alignment: .trailing) {
                                            HStack {
                                                WebImage(url: attribute.attribute.iconImageURL)
                                                    .resizable()
                                                    .frame(width: 20, height: 20)
                                                Text(verbatim: "+\(attribute.percent)%")
                                            }
                                        }
                                    }
                                })
                                Divider()
                                ListItemView(title: {
                                    Text("Event.character")
                                }, value: {
                                    VStack(alignment: .trailing) {
                                          let keys = eventCharacterPercentageDict.keys.sorted()
                                        ForEach(keys, id: \.self) { percentage in
                                            HStack {
                                                Spacer()
                                                ForEach(eventCharacterPercentageDict[percentage]!) { char in
                                                    WebImage(url: char.iconImageURL)
                                                        .resizable()
                                                        .frame(width: 20, height: 20)
//                                                    information.event.characters
//                                                    if let percent = information.event.characters.first(where: { $0.characterID == character.id })?.percent {
//                                                        Text("+\(percent)%")
//                                                    }
                                                }
                                                Text("+\(percentage)%")
                                                //
                                            }
                                        }
                                    }
                                })
                            }
                        }
                        .frame(maxWidth: 600)
                        .padding()
                        .onAppear {
                            var eventCharacters = information.event.characters
                            for char in eventCharacters {
                                eventCharacterPercentageDict.updateValue(((eventCharacterPercentageDict[char.percent] ?? []) + [char]), forKey: char.percent)
                            }
                        }
                        Spacer()
                    }
                }
            } else {
                if infoIsAvailable {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                } else {
                    ContentUnavailableView("Event.unavailable", systemImage: "photo.badge.exclamationmark", description: Text("Event.unavailable.description"))
                }
            }
        }
        .navigationTitle(Text(information?.event.eventName.forPreferredLocale() ?? "#\(id)"))
        //        .navigationTitle(.lineLimit(nil))
        //        .toolbarTitleDisplayMode(.inline)
        .task {
            await getInformation()
        }
        .onTapGesture {
            if !infoIsAvailable {
                Task {
                    await getInformation()
                }
            }
        }
    }
    
    func getInformation() async {
        infoIsAvailable = true
        DoriCache.withCache(id: "EventDetail_\(id)") {
            await DoriFrontend.Event.extendedInformation(of: id)
        } .onUpdate {
            if let information = $0 {
                self.information = information
            } else {
                infoIsAvailable = false
            }
        }
    }
}



/*
 VStack(alignment: .leading) {
 Text("属性")
 .font(.system(size: 16, weight: .medium))
 ForEach(information.event.attributes, id: \.attribute.rawValue) { attribute in
 HStack {
 WebImage(url: attribute.attribute.iconImageURL)
 .resizable()
 .frame(width: 20, height: 20)
 Text("+\(attribute.percent)%")
 .font(.system(size: 14))
 .opacity(0.6)
 }
 }
 }
 VStack(alignment: .leading) {
 Text("角色")
 .font(.system(size: 16, weight: .medium))
 ForEach(information.characters) { character in
 HStack {
 WebImage(url: character.iconImageURL)
 .resizable()
 .frame(width: 20, height: 20)
 if let percent = information.event.characters.first(where: { $0.characterID == character.id })?.percent {
 Text("+\(percent)%")
 .font(.system(size: 14))
 .opacity(0.6)
 }
 }
 }
 }
 VStack(alignment: .leading) {
 Text("卡牌")
 .font(.system(size: 16, weight: .medium))
 ForEach(information.cards) { card in
 if let character = information.characters.first(where: { $0.id == card.characterID }),
 let band = information.bands.first(where: { $0.id == band.id }),
 // if the card is contained in `members`, it is a card that has bonus in this event.
 // if not, it should be shown in rewards section (the next one).
 let percent = information.event.members.first(where: { $0.situationID == card.id })?.percent {
 HStack {
 //                                    NavigationLink(destination: { CardDetailView(id: card.id) }) {
 //                                        CardIconView(card, band: band)
 //                                    }
 //                                    .buttonStyle(.borderless)
 Text("+\(percent)%")
 .font(.system(size: 14))
 .opacity(0.6)
 }
 }
 }
 }
 
 
 Section {
 
 VStack(alignment: .leading) {
 Text("奖励")
 .font(.system(size: 16, weight: .medium))
 HStack {
 ForEach(information.cards) { card in
 if let character = information.characters.first(where: { $0.id == card.characterID }),
 let band = information.bands.first(where: { $0.id == character.bandID }) {
 if information.event.rewardCards.contains(card.id) {
 //                                        NavigationLink(destination: { CardDetailView(id: card.id) }) {
 //                                            CardIconView(card, band: band)
 //                                        }
 //                                        .buttonStyle(.borderless)
 }
 }
 }
 }
 }
 }
 .listRowBackground(Color.clear)
 
 
 
 
 if !information.gacha.isEmpty {
 Section {
 //                        FoldableList(information.gacha.reversed()) { gacha in
 //                            GachaCardView(gacha)
 //                        }
 } header: {
 Text("招募")
 }
 }
 if !information.songs.isEmpty {
 Section {
 //                        FoldableList(information.songs.reversed()) { song in
 //                            SongCardView(song)
 //                        }
 } header: {
 Text("歌曲")
 }
 }
 */


struct MultilingualText: View {
    let source: DoriAPI.LocalizedData<String>
    //    let locale: Locale
    var showLocaleKey: Bool = false
    @State var isHovering = false
    @State var allLocaleTexts: [String] = []
    @State var primaryDisplayString = ""
    
    init(source: DoriAPI.LocalizedData<String>, showLocaleKey: Bool = false/*, isHovering: Bool = false, allLocaleTexts: [String], primaryDisplayString: String = ""*/) {
        self.source = source
        self.showLocaleKey = showLocaleKey
        //        self.isHovering = isHovering
        //        self.allLocaleTexts = allLocaleTexts
        //        self.primaryDisplayString = primaryDisplayString
        
        var __allLocaleTexts: [String] = []
        for lang in DoriAPI.Locale.allCases {
            if let pendingString = source.forLocale(lang) {
                if !__allLocaleTexts.contains(pendingString) {
                    __allLocaleTexts.append("\(pendingString)\(showLocaleKey ? " (\(localeToStringDict[lang] ?? "?"))" : "")")
                }
            }
        }
        self._allLocaleTexts = .init(initialValue: __allLocaleTexts)
    }
    var body: some View {
        Group {
#if !os(macOS)
            Menu(content: {
                ForEach(allLocaleTexts, id: \.self) { localeValue in
                    Button(action: {}, label: {
                        Text(localeValue)
                    })
                }
            }, label: {
                MultilingualTextInternalLabel(source: source, showLocaleKey: showLocaleKey)
            })
            .menuStyle(.button)
            .buttonStyle(.borderless)
            .menuIndicator(.hidden)
            .foregroundStyle(.primary)
#else
            MultilingualTextInternalLabel(source: source, showLocaleKey: showLocaleKey)
                .onHover { isHovering in
                    self.isHovering = isHovering
                }
                .popover(isPresented: $isHovering, arrowEdge: .bottom) {
                    VStack(alignment: .trailing) {
                        ForEach(allLocaleTexts, id: \.self) { text in
                            Text(text)
                        }
                    }
                    .padding()
                }
#endif
        }
    }
    struct MultilingualTextInternalLabel: View {
        let source: DoriAPI.LocalizedData<String>
        //    let locale: Locale
        let showLocaleKey: Bool
        @State var primaryDisplayString: String = ""
        var body: some View {
            VStack(alignment: .trailing) {
                if let sourceInPrimaryLocale = source.forPreferredLocale(allowsFallback: false) {
                    Text("\(sourceInPrimaryLocale)\(showLocaleKey ? " (\(localeToStringDict[DoriAPI.preferredLocale] ?? "?"))" : "")")
                        .onAppear {
                            primaryDisplayString = sourceInPrimaryLocale
                        }
                } else if let sourceInSecondaryLocale = source.forSecondaryLocale(allowsFallback: false) {
                    Text("\(sourceInSecondaryLocale)\(showLocaleKey ? " (\(localeToStringDict[DoriAPI.secondaryLocale] ?? "?"))" : "")")
                        .onAppear {
                            primaryDisplayString = sourceInSecondaryLocale
                        }
                } else if let sourceInJP = source.jp {
                    Text("\(sourceInJP)\(showLocaleKey ? " (JP)" : "")")
                        .onAppear {
                            primaryDisplayString = sourceInJP
                        }
                }
                if let secondarySourceInSecondaryLang = source.forSecondaryLocale(allowsFallback: false), secondarySourceInSecondaryLang != primaryDisplayString {
                    Text("\(secondarySourceInSecondaryLang)\(showLocaleKey ? " (\(localeToStringDict[DoriAPI.secondaryLocale] ?? "?"))" : "")")
                        .foregroundStyle(.secondary)
                } else if let secondarySourceInJP = source.jp, secondarySourceInJP != primaryDisplayString {
                    Text("\(secondarySourceInJP)\(showLocaleKey ? " (JP)" : "")")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

struct MultilingualTextForCountdown: View {
    let source: DoriAPI.Event.Event
    @State var isHovering = false
    //    @State var allLocaleTexts: [String] = []
    //    @State var primaryDisplayString = ""
    @State var allAvailableLocales: [DoriAPI.Locale] = []
    @State var primaryDisplayLocale: DoriAPI.Locale?
    
    //    init(source: DoriAPI.Event.Event/*, isHovering: Bool = false, allLocaleTexts: [String], primaryDisplayString: String = ""*/) {
    //        self.source = source
    //    }
    var body: some View {
        Group {
#if !os(macOS)
            Menu(content: {
                VStack(alignment: .trailing) {
                    ForEach(allAvailableLocales, id: \.self) { localeValue in
                        Button(action: {}, label: {
                            MultilingualTextForCountdownInternalNumbersView(event: source, locale: localeValue)
                        })
                    }
                }
            }, label: {
                MultilingualTextForCountdownInternalLabel(source: source, allAvailableLocales: allAvailableLocales)
            })
            .menuStyle(.button)
            .buttonStyle(.borderless)
            .menuIndicator(.hidden)
            .foregroundStyle(.primary)
#else
            MultilingualTextForCountdownInternalLabel(source: source, allAvailableLocales: allAvailableLocales)
                .onHover { isHovering in
                    self.isHovering = isHovering
                }
                .popover(isPresented: $isHovering, arrowEdge: .bottom) {
                    VStack(alignment: .trailing) {
                        ForEach(allAvailableLocales, id: \.self) { localeValue in
                            MultilingualTextForCountdownInternalNumbersView(event: source, locale: localeValue)
                        }
                    }
                    .padding()
                }
#endif
        }
        .onAppear {
            for lang in [DoriAPI.Locale.jp, DoriAPI.Locale.en, DoriAPI.Locale.tw, DoriAPI.Locale.cn, DoriAPI.Locale.kr] {
                if source.startAt.availableInLocale(lang) {
                    allAvailableLocales.append(lang)
                }
            }
        }
    }
    struct MultilingualTextForCountdownInternalLabel: View {
        let source: DoriAPI.Event.Event
        let allAvailableLocales: [DoriAPI.Locale]
        @State var primaryDisplayingLocale: DoriAPI.Locale? = nil
        var body: some View {
            VStack(alignment: .trailing) {
                if allAvailableLocales.contains(DoriAPI.preferredLocale) {
                    MultilingualTextForCountdownInternalNumbersView(event: source, locale: DoriAPI.preferredLocale)
                        .onAppear {
                            primaryDisplayingLocale = DoriAPI.preferredLocale
                        }
                } else if allAvailableLocales.contains(DoriAPI.secondaryLocale) {
                    MultilingualTextForCountdownInternalNumbersView(event: source, locale: DoriAPI.secondaryLocale)
                        .onAppear {
                            primaryDisplayingLocale = DoriAPI.secondaryLocale
                        }
                } else if allAvailableLocales.contains(.jp) {
                    MultilingualTextForCountdownInternalNumbersView(event: source, locale: .jp)
                        .onAppear {
                            primaryDisplayingLocale = .jp
                        }
                }
                
                if allAvailableLocales.contains(DoriAPI.secondaryLocale), DoriAPI.secondaryLocale != primaryDisplayingLocale {
                    MultilingualTextForCountdownInternalNumbersView(event: source, locale: DoriAPI.secondaryLocale)
                        .foregroundStyle(.secondary)
                } else if allAvailableLocales.contains(.jp), .jp != primaryDisplayingLocale {
                    MultilingualTextForCountdownInternalNumbersView(event: source, locale: .jp)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    struct MultilingualTextForCountdownInternalNumbersView: View {
        let event: DoriFrontend.Event.Event
        let locale: DoriAPI.Locale
        var body: some View {
            Group {
                if let startDate = event.startAt.forLocale(locale),
                   let endDate = event.endAt.forLocale(locale),
                   let aggregateEndDate = event.aggregateEndAt.forLocale(locale),
                   let distributionStartDate = event.distributionStartAt.forLocale(locale) {
                    if startDate > .now {
                        Text("Event.countdown.start-at.\(Text(startDate, style: .relative)).\(localeToStringDict[locale] ?? "??")")
                    } else if endDate > .now {
                        Text("Event.countdown.end-at.\(Text(endDate, style: .relative)).\(localeToStringDict[locale] ?? "??")")
                    } else if aggregateEndDate > .now {
                        Text("Event.countdown.results-in.\(Text(endDate, style: .relative)).\(localeToStringDict[locale] ?? "??")")
                    } else if distributionStartDate > .now {
                        Text("Event.countdown.rewards-in.\(Text(endDate, style: .relative)).\(localeToStringDict[locale] ?? "??")")
                    } else {
                        Text("Event.countdown.completed.\(localeToStringDict[locale] ?? "??")")
                    }
                }
            }
        }
    }
}


struct ListItemView<Content1: View, Content2: View>: View {
    let title: Content1
    let value: Content2
    
    init(@ViewBuilder title: () -> Content1, @ViewBuilder value: () -> Content2) {
        self.title = title()
        self.value = value()
    }
    
    var body: some View {
        HStack {
            title
            Spacer()
            value
        }
    }
}

