//===---*- Greatdori! -*---------------------------------------------------===//
//
// Asset.swift
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
internal import SwiftyJSON

extension DoriAPI {
    /// Request and fetch data about assets in Bandori.
    public enum Asset {
        /// Get asset information of locale.
        /// - Parameter locale: Target locale.
        /// - Returns: Asset information of requested locale, nil if failed to fetch.
        public static func info(in locale: Locale) async -> AssetList? {
            let request = await requestJSON("https://bestdori.com/api/explorer/\(locale.rawValue)/assets/_info.json")
            if case let .success(respJSON) = request {
                let task = Task.detached(priority: .userInitiated) {
                    func resolveList(_ json: JSON) -> AssetList {
                        var result = AssetList()
                        for (key, value) in json {
                            if let count = value.int {
                                result.updateValue(.files(count), forKey: key)
                            } else {
                                result.updateValue(.list(resolveList(value)), forKey: key)
                            }
                        }
                        return result
                    }
                    return resolveList(respJSON)
                }
                return await task.value
            }
            return nil
        }
        
        /// Get contents of a ``Child/files(_:)`` by path.
        /// - Parameter path: Path descriptor.
        /// - Returns: Contents, nil if failed to fetch.
        @inlinable
        public static func contentsOf(_ path: PathDescriptor) async -> [String]? {
            await _contentsOf(path._path, in: path.locale)
        }
        public static func _contentsOf(_ path: String, in locale: Locale) async -> [String]? {
            let request = await requestJSON("https://bestdori.com/api/explorer/\(locale.rawValue)/assets\(path).json")
            if case let .success(respJSON) = request {
                let task = Task.detached(priority: .userInitiated) {
                    respJSON.map { $0.1.stringValue }
                }
                return await task.value
            }
            return nil
        }
    }
}

extension DoriAPI.Asset {
    public typealias AssetList = [String: Child]
    @frozen
    public enum Child: Sendable {
        case files(Int) // Int -> file count
        case list(AssetList)
    }
    public struct PathDescriptor: Sendable {
        @usableFromInline
        internal var _path: String
        
        public var locale: DoriAPI.Locale
        
        public init(locale: DoriAPI.Locale) {
            self._path = "/"
            self.locale = locale
        }
        
        @inlinable
        public func resourceURL(name: String) -> URL {
            var separatedPath = _path.split(separator: "/")
            if !separatedPath.isEmpty {
                separatedPath[separatedPath.count - 1] += "_rip"
            }
            return .init(string: "https://bestdori.com/assets/\(locale.rawValue)\(separatedPath.joined(separator: "/"))/\(name)")!
        }
    }
}
extension DoriAPI.Asset.AssetList {
    @inlinable
    public func access(_ key: String) -> DoriAPI.Asset.Child? {
        self[key]
    }
    @inlinable
    public func access(_ key: String, updatingPath descriptor: inout DoriAPI.Asset.PathDescriptor) -> DoriAPI.Asset.Child? {
        descriptor._path += "\(key)/"
        return self[key]
    }
}
