//===---*- Greatdori! -*---------------------------------------------------===//
//
// RichContentRendering.swift
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

#if canImport(SwiftUI)

import SwiftUI
import Foundation

extension RichContent {
    internal func _makeView(in environment: RichContentEnvironment) -> ViewContainer {
        @ViewBuilder
        func imagesView(from urls: [URL]) -> some View {
            VStack {
                ForEach(urls, id: \.absoluteString) { url in
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 8)
                    }
                    .scaledToFit()
                }
            }
        }
        func linkText(from url: URL) -> Text {
            var attributedString = AttributedString(url.absoluteString)
            var container = AttributeContainer()
            container.link = url
            attributedString.setAttributes(container)
            return Text(attributedString)
        }
        func emojiText(from emoji: Emoji) -> Text {
            #if !os(macOS)
            Text("\(Image(uiImage: emoji.image.resized(to: environment.emojiFrame)).resizable())")
            #else
            Text("\(Image(nsImage: emoji.image.resized(to: environment.emojiFrame)).resizable())")
            #endif
        }
        
        return switch self {
        case .br: .text(Text("\n"))
        case .text(let text): .text(Text(text))
        case .image(let urls): .other(AnyView(imagesView(from: urls)))
        case .link(let url): .text(linkText(from: url))
        case .emoji(let emoji): .text(emojiText(from: emoji))
        }
    }
}
extension RichContentGroup {
    internal func _makeViewGroup(in environment: RichContentEnvironment) -> [ViewContainer] {
        let eachView = map { $0._makeView(in: environment) }
        guard !eachView.isEmpty else { return [] }
        
        var result = [eachView.first!]
        for view in eachView.dropFirst() {
            switch view {
            case .text(let text):
                switch result.last! {
                case .text(let previous):
                    let new = Text("\(previous)\(text)")
                    result[result.count - 1] = .text(new)
                case .other:
                    result.append(view)
                }
            case .other:
                result.append(view)
            }
        }
        return result
    }
}

internal enum ViewContainer {
    case text(Text)
    case other(AnyView)
    
    @ViewBuilder
    internal func makeView() -> some View {
        switch self {
        case .text(let text): text
        case .other(let anyView): anyView
        }
    }
}

internal struct RichContentEnvironment {
    internal var emojiFrame: CGSize = .init(width: 20, height: 20)
}

#endif
