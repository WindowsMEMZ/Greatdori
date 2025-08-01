//
//  GachaListView.swift
//  Greatdori
//
//  Created by Mark Chan on 8/1/25.
//

import SwiftUI
import DoriKit

struct GachaListView: View {
    @State var filter = DoriFrontend.Filter()
    @State var gacha: [DoriFrontend.Gacha.PreviewGacha]?
    @State var isFilterSettingsPresented = false
    @State var isSearchPresented = false
    @State var searchInput = ""
    @State var searchedGacha: [DoriFrontend.Gacha.PreviewGacha]?
    @State var availability = true
    var body: some View {
        List {
            if let gacha = searchedGacha ?? gacha {
                ForEach(gacha) { gacha in
                    NavigationLink(destination: { GachaDetailView(id: gacha.id) }) {
                        GachaCardView(gacha)
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
            } else {
                if availability {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                } else {
                    UnavailableView("载入招募时出错", systemImage: "line.horizontal.star.fill.line.horizontal", retryHandler: getGacha)
                }
            }
        }
        .navigationTitle("招募")
        .sheet(isPresented: $isFilterSettingsPresented) {
            Task {
                gacha = nil
                await getGacha()
            }
        } content: {
            FilterView(filter: $filter, includingKeys: [
                .attribute,
                .character,
                .server,
                .timelineStatus,
                .gachaType,
                .sort
            ]) {
                if let gacha {
                    SearchView(items: gacha, text: $searchInput) { result in
                        searchedGacha = result
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    isFilterSettingsPresented = true
                }, label: {
                    Image(systemName: "line.3.horizontal.decrease")
                })
                .tint(filter.isFiltered || !searchInput.isEmpty ? .accent : nil)
            }
        }
        .task {
            await getGacha()
        }
    }
    
    func getGacha() async {
        availability = true
        DoriCache.withCache(id: "GachaList_\(filter.identity)") {
            await DoriFrontend.Gacha.list(filter: filter)
        }.onUpdate {
            if let gacha = $0 {
                self.gacha = gacha
            } else {
                availability = false
            }
        }
    }
}
