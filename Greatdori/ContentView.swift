//
//  ContentView.swift
//  Greatdori
//
//  Created by Mark Chan on 7/18/25.
//

import SwiftUI
import DoriKit


enum AppSection: Hashable {
    case home, community, leaderboard, info, tools, settings
}

struct ContentView: View {
    @State private var selection: AppSection? = .home
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.platform) var platform
    @AppStorage("isFirstLaunch") var isFirstLaunch = true
    @AppStorage("isFirstLaunchResettable") var isFirstLaunchResettable = true
    @State var showWelcomeScreen = false
    
    var body: some View {
        Group {
            if platform == .mac || sizeClass == .regular {
                NavigationSplitView {
                    List(selection: $selection) {
                        Label("App.home", systemImage: "house").tag(AppSection.home)
                        Label("App.community", systemImage: "at").tag(AppSection.community)
                        Label("App.leaderboard", systemImage: "chart.bar").tag(AppSection.leaderboard)
                        Section("App.info", content: {
                            Label("App.info.characters", systemImage: "person.2").tag(AppSection.info)
                        })
                        //                    Label("App.info", systemImage: "rectangle.stack").tag(AppSection.info)
                        Label("App.tools", systemImage: "slider.horizontal.3").tag(AppSection.tools)
#if os(iOS)
                        Label("App.settings", systemImage: "gear").tag(AppSection.settings)
#endif
                    }
                    .navigationTitle("Greatdori")
                } detail: {
                    detailView(for: selection)
                }
            } else {
                TabView(selection: $selection) {
                    detailView(for: .home)
                        .tabItem { Label("App.home", systemImage: "house") }
                        .tag(AppSection.home)
                    
                    detailView(for: .community)
                        .tabItem { Label("App.community", systemImage: "at") }
                        .tag(AppSection.community)
                    
                    detailView(for: .leaderboard)
                        .tabItem { Label("App.leaderboard", systemImage: "chart.bar") }
                        .tag(AppSection.leaderboard)
                    
                    detailView(for: .info)
                        .tabItem { Label("App.info", systemImage: "rectangle.stack") }
                        .tag(AppSection.info)
                    
                    detailView(for: .tools)
                        .tabItem { Label("App.tools", systemImage: "slider.horizontal.3") }
                        .tag(AppSection.tools)
                }
            }
        }
        .onAppear {
            if isFirstLaunch {
                showWelcomeScreen = true
                isFirstLaunch = !isFirstLaunchResettable
                
            }
        }
        .sheet(isPresented: $showWelcomeScreen, content: {
            WelcomeView(showWelcomeScreen: $showWelcomeScreen)
        })
    }
    
    @ViewBuilder
    func detailView(for section: AppSection?) -> some View {
        switch section {
        case .home: HomeView()
        case .community: HomeView()
        case .leaderboard: HomeView()
        case .info: HomeView()
        case .tools: HomeView()
        case .settings: SettingsView()
        case nil: EmptyView()
        }
    }
}

enum Platform {
    case iOS, mac, tv, watch, unknown
}

struct PlatformKey: EnvironmentKey {
    static let defaultValue: Platform = {
#if os(iOS)
        return .iOS
#elseif os(macOS)
        return .mac
#elseif os(tvOS)
        return .tv
#elseif os(watchOS)
        return .watch
#else
        return .unknown
#endif
    }()
}

extension EnvironmentValues {
    var platform: Platform {
        self[PlatformKey.self]
    }
}


struct CustomGroupBox<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    let content: () -> Content
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    var body: some View {
#if os(iOS)
        content()
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundStyle(Color(.secondarySystemGroupedBackground))
            }
#elseif os(macOS)
        GroupBox {
            content()
                .padding()
        }
#endif
    }
}

func groupedContentBackgroundColor() -> Color {
#if os(iOS)
    return Color(.systemGroupedBackground)
#elseif os(macOS)
    return Color(NSColor.windowBackgroundColor)
#endif
}

struct DismissButton<L: View>: View {
    var action: () -> Void
    var label: () -> L
    var doDismiss: Bool = true
    @Environment(\.dismiss) var dismiss
    var body: some View {
        Button(action: {
            action()
            if doDismiss {
                dismiss()
            }
        }, label: {
            label()
        })
    }
}


struct WelcomeView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @State var primaryLocale = "jp"
    @State var secondaryLocale = "en"
    @Binding var showWelcomeScreen: Bool
    var body: some View {
        VStack(alignment: .leading) {
            Image("MacAppIcon")
                .resizable()
                .antialiased(true)
                .frame(width: 64, height: 64)
            Rectangle()
                .frame(height: 1)
                .opacity(0)
            Text("Welcome.title")
                .font(.title)
                .bold()
            Rectangle()
                .frame(height: 1)
                .opacity(0)
            Text("Welcome.message")
            Rectangle()
                .frame(height: 1)
                .opacity(0)
            HStack {
#if os(iOS)
                Text("Welcome.primaryLocale")
                Spacer()
#endif
                Picker(selection: $primaryLocale, content: {
                    Text("Home.servers.selection.jp")
                        .tag("jp")
                        .disabled(secondaryLocale == "jp")
                    Text("Home.servers.selection.en")
                        .tag("en")
                        .disabled(secondaryLocale == "en")
                    Text("Home.servers.selection.cn")
                        .tag("cn")
                        .disabled(secondaryLocale == "cn")
                    Text("Home.servers.selection.tw")
                        .tag("tw")
                        .disabled(secondaryLocale == "tw")
                    Text("Home.servers.selection.kr")
                        .tag("kr")
                        .disabled(secondaryLocale == "kr")
                }, label: {
                    Text("Welcome.primaryLocale")
                })
                .onChange(of: primaryLocale, {
                    DoriAPI.preferredLocale = localeFromStringDict[primaryLocale] ?? .jp
                })
            }
            HStack {
                #if os(iOS)
                Text("Welcome.secondaryLocale")
                Spacer()
                #endif
                Picker(selection: $secondaryLocale, content: {
                    Text("Home.servers.selection.jp")
                        .tag("jp")
                        .disabled(primaryLocale == "jp")
                    Text("Home.servers.selection.en")
                        .tag("en")
                        .disabled(primaryLocale == "en")
                    Text("Home.servers.selection.cn")
                        .tag("cn")
                        .disabled(primaryLocale == "cn")
                    Text("Home.servers.selection.tw")
                        .tag("tw")
                        .disabled(primaryLocale == "tw")
                    Text("Home.servers.selection.kr")
                        .tag("kr")
                        .disabled(primaryLocale == "kr")
                }, label: {
                    Text("Welcome.secondaryLocale")
                })
                .onChange(of: secondaryLocale, {
                    DoriAPI.secondaryLocale = localeFromStringDict[secondaryLocale] ?? .en
                })
            }
            Rectangle()
                .frame(height: 1)
                .opacity(0)
            Text("Welcome.footnote")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            #if os(iOS)
            Button(action: {
                //ANIMATION?
                showWelcomeScreen = false
            }, label: {
                ZStack {
                    if #available(iOS 26.0, *) {
                        Capsule()
                        .frame(height: 50)
                        .glassEffect(.identity)
                    } else {
                        RoundedRectangle(cornerRadius: 50)
                            .frame(height: 20)
                    }
                    Text("Done")
                        .bold()
                        .foregroundStyle(colorScheme == .dark ? .black : .white)
//                        .colorInvert()
                }
            })
            #endif
        }
        .padding()
        .onAppear {
            primaryLocale = localeToStringDict[DoriAPI.preferredLocale]?.lowercased() ?? "jp"
            secondaryLocale = localeToStringDict[DoriAPI.secondaryLocale]?.lowercased() ?? "en"
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction, content: {
                Button(action: {
                    //ANIMATION?
//                    dismiss()
                    showWelcomeScreen = false
                }, label: {
                    Text("Done")
                })
            })
        }
    }
}
