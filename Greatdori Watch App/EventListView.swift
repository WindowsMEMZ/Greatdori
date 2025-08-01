//
//  EventListView.swift
//  Greatdori
//
//  Created by Mark Chan on 7/26/25.
//

import SwiftUI
import DoriKit

struct EventListView: View {
    @State var filter = DoriFrontend.Filter()
    @State var events: [DoriFrontend.Event.PreviewEvent]?
    @State var isFilterSettingsPresented = false
    @State var isSearchPresented = false
    @State var searchInput = ""
    @State var searchedEvents: [DoriFrontend.Event.PreviewEvent]?
    @State var availability = true
    var body: some View {
        List {
            if let events = searchedEvents ?? events {
                ForEach(events) { event in
                    NavigationLink(destination: { EventDetailView(id: event.id) }) {
                        EventCardView(event, inLocale: nil)
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
                    UnavailableView("载入活动时出错", systemImage: "star.hexagon.fill", retryHandler: getEvents)
                }
            }
        }
        .navigationTitle("活动")
        .sheet(isPresented: $isFilterSettingsPresented) {
            Task {
                events = nil
                await getEvents()
            }
        } content: {
            FilterView(filter: $filter, includingKeys: [
                .attribute,
                .character,
                .server,
                .timelineStatus,
                .eventType,
                .sort
            ]) {
                if let events {
                    SearchView(items: events, text: $searchInput) { result in
                        searchedEvents = result
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
            await getEvents()
        }
    }
    
    func getEvents() async {
        availability = true
        DoriCache.withCache(id: "EventList_\(filter.identity)") {
            await DoriFrontend.Event.list(filter: filter)
        }.onUpdate {
            if let events = $0 {
                self.events = events
            } else {
                availability = false
            }
        }
    }
}
