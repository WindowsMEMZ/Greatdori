//
//  DebugView.swift
//  Greatdori
//
//  Created by ThreeManager785 on 2025/7/28.
//

import SwiftUI
import DoriKit
import SDWebImageSwiftUI

struct DebugBirthdayView: View {
    var dateList: [Date] = []
    init() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo")!
        var components = calendar.dateComponents([.month, .day], from: Date())
        components.year = 2000
        components.month = 1
        components.day = 1
        components.hour = 0
        components.minute = 0
        components.second = 0
        let JanFirstOfY2K = calendar.date(from: components)!
        dateList.append(JanFirstOfY2K)
        for i in 0...364 {
            dateList.append(dateList[i].addingTimeInterval(60*60*24))
        }
    }
    var body: some View {
        ScrollView {
            VStack {
                ForEach(0..<dateList.count, id: \.self) { i in
                    DebugBirthdayViewUnit(receivedToday: dateList[i])
                }
                Divider()
            }
        }
    }
}

struct DebugBirthdayViewUnit: View {
    @State var birthdays: [DoriFrontend.Character.BirthdayCharacter]?
    var receivedToday: Date?
    var formatter = DateFormatter()
    init(receivedToday: Date? = Date.now) {
        self.receivedToday = receivedToday
//        formatter.timeZone = .init(identifier: "Asia/Tokyo")
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("MM/dd")
        formatter.timeZone = .init(identifier: "Asia/Tokyo")
    }
//    init() {
//        
//    }
    var body: some View {
        Group {
            if let birthdays {
                HStack {
                    Text(formatter.string(from: receivedToday!))
                        .bold()
                    ForEach(birthdays) { character in
                        //                            HStack {
                        WebImage(url: character.iconImageURL)
                            .resizable()
                            .clipShape(Circle())
                            .frame(width: 30, height: 30)
                        Text(formatter.string(from: character.birthday))
                    }
                    Spacer()
                }
            } else {
                ProgressView()
            }
        }
        .task {
            DoriCache.withCache(id: "Home_Birthdays") {
                await DoriFrontend.Character.recentBirthdayCharacters(aroundDate: receivedToday ?? Date.now)
            } .onUpdate {
                birthdays = $0
            }
        }
    }
}
