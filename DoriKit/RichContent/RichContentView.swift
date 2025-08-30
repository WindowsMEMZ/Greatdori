//===---*- Greatdori! -*---------------------------------------------------===//
//
// RichContentView.swift
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

#if HAS_BINARY_RESOURCE_BUNDLES

import SwiftUI
import Foundation

/// Render a ``RichContentGroup``.
///
/// > Beta API:
/// >
/// > This API is currently in development and is unstable.
/// > It is subject to change, and software implemented with this API should be tested with its stable version.
public struct RichContentView: View {
    private var content: RichContentGroup
    
    public init(_ content: RichContentGroup) {
        self.content = content
    }
    
    internal var environment = RichContentEnvironment()
    
    public var body: some View {
        VStack(alignment: .leading) {
            let viewGroup = content._makeViewGroup(in: environment)
            ForEach(0..<viewGroup.count, id: \.self) { i in
                viewGroup[i].makeView()
            }
        }
    }
}

extension RichContentView {
    /// Changes the frame for all emojis in a ``RichContentView``.
    ///
    /// - Parameters:
    ///   - width: A width for emoji. If `width` is nil,
    ///         it uses the default frame.
    ///   - height: A height for emoji. If `height` is nil,
    ///         it uses the default frame.
    /// - Returns: A view that shows rich content with fixed frames
    ///     for emojis in the view.
    ///
    /// > Beta API:
    /// >
    /// > This API is currently in development and is unstable.
    /// > It is subject to change, and software implemented with this API should be tested with its stable version.
    public func richEmojiFrame(width: CGFloat? = nil, height: CGFloat? = nil) -> RichContentView {
        var mutating = self
        if let width {
            mutating.environment.emojiFrame.width = width
        }
        if let height {
            mutating.environment.emojiFrame.height = height
        }
        return mutating
    }
}

#endif // HAS_BINARY_RESOURCE_BUNDLES
