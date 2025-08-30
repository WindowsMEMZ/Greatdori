//===---*- Greatdori! -*---------------------------------------------------===//
//
// DoriEmoji.swift
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

import Foundation

#if os(macOS)
import AppKit
#else
import UIKit
#endif

internal let _doriEmojiBundle = Bundle(path: #bundle.path(forResource: "DoriEmoji", ofType: "bundle")!)!

extension RichContent {
    /// Represent an emoji for ``RichContent``.
    ///
    /// > Beta API:
    /// >
    /// > This API is currently in development and is unstable.
    /// > It is subject to change, and software implemented with this API should be tested with its stable version.
    @frozen
    public struct Emoji: Hashable {
        public static var all: [Emoji] {
            let namesFile = _doriEmojiBundle.url(forResource: "emoji_names", withExtension: "plist")!
            let data = try! Data(contentsOf: namesFile)
            let decoder = PropertyListDecoder()
            let names = try! decoder.decode([String].self, from: data)
            
            var result = [Emoji]()
            for name in names {
                #if !os(watchOS)
                result.append(.init(_name: name, image: .init(resource: .init(name: name, bundle: _doriEmojiBundle))))
                #else
                result.append(.init(_name: name, image: .init(named: name, in: _doriEmojiBundle, with: nil)!))
                #endif
            }
            return result
        }
        
        public var _name: String
        #if os(macOS)
        public var image: NSImage
        #else
        public var image: UIImage
        #endif
        
        #if os(macOS)
        public init(_name: String, image: NSImage) {
            self._name = _name
            self.image = image
        }
        #else
        public init(_name: String, image: UIImage) {
            self._name = _name
            self.image = image
        }
        #endif
        
        public init(_resourceName name: String) {
            #if !os(watchOS)
            self = .init(_name: name, image: .init(resource: .init(name: name, bundle: _doriEmojiBundle)))
            #else
            self = .init(_name: name, image: .init(named: name, in: _doriEmojiBundle, with: nil) ?? .init())
            #endif
        }
    }
}

extension RichContent.Emoji: Codable {
    public enum CodingKeys: CodingKey {
        case name
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(_resourceName: try container.decode(String.self, forKey: .name))
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self._name, forKey: .name)
    }
}

extension RichContent.Emoji: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs._name == rhs._name
    }
}

#if !os(macOS)
extension UIImage {
    internal func resized(to newSize: CGSize) -> UIImage {
        let widthRatio = newSize.width / size.width
        let heightRatio = newSize.height / size.height
        let scaleFactor = min(widthRatio, heightRatio)
        let newSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}
#else
extension NSImage {
    internal func resized(to newSize: CGSize) -> NSImage {
        let widthRatio  = newSize.width / size.width
        let heightRatio = newSize.height / size.height
        let scaleFactor = min(widthRatio, heightRatio)
        let newSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )
        let newImage = NSImage(size: newSize)
        newImage.lockFocus()
        defer { newImage.unlockFocus() }
        let rect = CGRect(origin: .zero, size: newSize)
        draw(in: rect,
             from: .zero,
             operation: .copy,
             fraction: 1.0)
        return newImage
    }
}
#endif

#endif // HAS_BINARY_RESOURCE_BUNDLES
