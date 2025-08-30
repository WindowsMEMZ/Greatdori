//===---*- Greatdori! -*---------------------------------------------------===//
//
// DoriCache.swift
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

import SwiftUI
import Foundation

/// Manage caches for DoriKit.
public final class DoriCache {
    private init() {}
    
    /// A type that can be cached by DoriKit.
    public protocol Cacheable: Codable {
        /// Creates a new instance by decoding from the given cache data.
        ///
        /// This initializer returns `nil`if the data read is invalid.
        ///
        /// - Parameter cache: The cache data for decoding.
        init?(fromCache cache: Data)
        
        /// The data for cache of this value.
        var dataForCache: Data { get }
    }
    
    /// A promise for result.
    ///
    /// You'll get a promise after calling ``withCache(id:trait:invocation:)``
    /// which provides you data.
    ///
    /// Generally, you should register a closure to receive updates
    /// by ``onUpdate(_:)`` immediately after getting a promise
    /// to prevent missing updates. If you registers a closure for updates
    /// after the value updates, it will still be called with the last value,
    /// but miss values before it.
    ///
    /// - IMPORTANT:
    ///     You should register a closure for update to a promise
    ///     only **once**. Attempting register multiple closures
    ///     to one promise instance results in undefined behaviors.
    public final class Promise<Result> {
        @safe nonisolated(unsafe)
        private var _onUpdate: ((Result) -> Void)?
        @safe nonisolated(unsafe)
        private var initialValue: Result?
        @safe nonisolated(unsafe)
        private var isValueFirstUpdated: Bool = false
        @safe nonisolated(unsafe)
        private var isCancelled: Bool = false
        @safe nonisolated(unsafe)
        private var _onCancel: (() -> Void)?
        
        internal init(_ initialValue: Result? = nil) {
            self.initialValue = initialValue
        }
        
        @MainActor
        internal func updateValue(_ value: Result) {
            if _fastPath(!isCancelled) {
                _onUpdate?(value)
            }
            isValueFirstUpdated = true
        }
        @discardableResult
        internal func onCancel(perform action: @escaping () -> Void) -> Self {
            self._onCancel = action
            return self
        }
        
        /// Registers a closure for receiving value updates.
        ///
        /// - Parameter action: A closure called when value updates.
        /// - Returns: The promise itself.
        ///
        /// If you registers a closure for updates
        /// after the value updates, it will still be called with the last value,
        /// but miss values before it.
        ///
        /// - IMPORTANT:
        ///     You should register a closure for update to a promise
        ///     only **once**. Attempting register multiple closures
        ///     to one promise instance results in undefined behaviors.
        @discardableResult
        public func onUpdate(_ action: @escaping (Result) -> Void) -> Self {
            self._onUpdate = action
            if !isValueFirstUpdated, let initialValue {
                action(initialValue)
            }
            return self
        }
        
        /// Cancels the promise.
        ///
        /// Canceling a promise also notifies the creator of promise
        /// to cancel its ongoing tasks for updating data if possible.
        ///
        /// A promise can't be "re-enabled" after canceling.
        public func cancel() {
            self._onCancel?()
            self.isCancelled = true
        }
    }
    
    /// Trait of data for cacheing.
    ///
    /// - IMPORTANT:
    ///     Using ``invocationElidable`` allows DoriKit elide the `invocation`
    ///     if cached data is new enough, like its name.
    public enum CacheTrait: Sendable {
        /// Data that changes frequently.
        case realTime
        /// Data that hardly changes and allows out-of-date one.
        ///
        /// - IMPORTANT:
        ///     Using this trait allows DoriKit elide the `invocation`
        ///     if cached data is new enough, like its name.
        case invocationElidable
    }
    
    private static let cacheDateEncoder = PropertyListEncoder()
    private static let cacheDateDecoder = PropertyListDecoder()
    
    /// Get result with automatic cache.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for cache.
    ///   - trait: Trait of data being cached, see ``CacheTrait`` for more details.
    ///   - invocation: A closure that returns a result that can be cached.
    /// - Returns: A ``Promise`` for result.
    ///
    /// Call this function with an identifier to get a promise for result,
    /// then register an `onUpdate` closure for receiving new data:
    /// ```swift
    /// DoriCache.withCache(id: "CacheID") {
    ///     await DoriAPI.Character.Character(id: 39)
    /// }.onUpdate {
    ///     let myFavoriteCharacter = $0
    /// }
    /// ```
    ///
    /// The `onUpdate` closure registered to a promise may be called more than once
    /// (we call this *return twice*).
    ///
    /// If a cache is available on disk, the promise will be update immediately,
    /// which allows you to get data faster. Then if `invocation` returns a result
    /// other than `nil`, the promise will be update again with the latest data from `invocation`.
    ///
    /// If a cache is available on disk but `invocation` returns `nil`, the promise
    /// will be update only once with data from cache, and cache on disk won't be update.
    /// If cache is unavailable and `invocation` returns `nil`, the promise will be updated
    /// with `nil`.
    ///
    /// The mechanism above implies the promise will be update **at least once**
    /// and may **more than once**.
    ///
    /// - Note:
    ///     You can use the same ID in different places if the result types aren't same.
    ///     Caches with the same ID but different types will be stored separately.
    public static func withCache<Result: Sendable & Cacheable>(
        id: String,
        trait: CacheTrait = .invocationElidable,
        invocation: sending @escaping () async -> Result?
    ) -> Promise<Result?> {
        let cacheURL = URL(filePath: NSHomeDirectory() + "/Library/Caches/DoriKit_\(Result.self)_\(id).cache")
        
        let promise: Promise<Result?> = .init()
        
        #if canImport(DoriAssetShims)
        let offlineAssetBehavior = DoriOfflineAsset.localBehavior
        #endif
        
        let task = Task.detached(priority: .userInitiated) {
            var cachedResult: Result?
            if let cachedData = try? Data(contentsOf: cacheURL) {
                cachedResult = Result(fromCache: cachedData)
            } else {
                #if DORIKIT_ENABLE_PRECACHE
                if let preCache = preCachedData(byID: id) {
                    if let typed = preCache as? Result {
                        cachedResult = typed
                    }
                }
                #endif
            }
            
            if let cachedResult {
                await promise.updateValue(cachedResult)
                if trait == .invocationElidable {
                    let cacheInfoURL = URL(filePath: NSHomeDirectory() + "/Library/Caches/DoriCacheInfo.plist")
                    let nowDate = Date.now
                    let newCacheDates: [String: TimeInterval]
                    if let _data = try? Data(contentsOf: cacheInfoURL),
                       var cacheDates = try? cacheDateDecoder.decode([String: TimeInterval].self, from: _data) {
                        if let thisDate = cacheDates["\(Result.self)_\(id)"],
                           nowDate.timeIntervalSince1970 - thisDate <= 24 * 60 * 60 {
                            // Current cache is new enough, we elide request from network
                            return
                        }
                        cacheDates.updateValue(nowDate.timeIntervalSince1970, forKey: "\(Result.self)_\(id)")
                        newCacheDates = cacheDates
                    } else {
                        newCacheDates = ["\(Result.self)_\(id)": nowDate.timeIntervalSince1970]
                    }
                    try? cacheDateEncoder.encode(newCacheDates).write(to: cacheInfoURL)
                }
            }
            
            #if canImport(DoriAssetShims)
            // We have to explicitly call `withValue` to keep the localBehavior
            // because we're running in a detached task.
            let result = await DoriOfflineAsset.$localBehavior.withValue(offlineAssetBehavior, operation: invocation)
            #else
            let result = await invocation()
            #endif
            
            // If result is nil but there's data in cache,
            // we don't update value of promise.
            if result == nil && cachedResult != nil {
                return
            }
            
            await promise.updateValue(result)
            
            // Don't save cache if result is nil
            if result == nil {
                return
            }
            
            let cache = result.dataForCache
            try? cache.write(to: cacheURL)
        }
        
        promise.onCancel {
            task.cancel()
        }
        
        return promise
    }
    
    /// Invalidates a cache with type and ID.
    ///
    /// - Parameters:
    ///   - type: Type of cache.
    ///   - id: A unique identifier of cache.
    ///
    /// This function has no effects if provided `type` and `id`
    /// don't match any cache on disk.
    public static func invalidate<T>(_ type: T.Type, withID id: String) {
        let cacheURL = URL(filePath: NSHomeDirectory() + "/Library/Caches/DoriKit_\(type)_\(id).cache")
        try? FileManager.default.removeItem(at: cacheURL)
    }
    /// Invalidates all cache on disk.
    public static func invalidateAll() {
        let cacheRootPath = NSHomeDirectory() + "/Library/Caches"
        guard let files = try? FileManager.default.contentsOfDirectory(atPath: cacheRootPath) else { return }
        for file in files where file.hasPrefix("DoriKit") && file.hasSuffix(".cache") && !file.hasPrefix(".") {
            try? FileManager.default.removeItem(atPath: "\(cacheRootPath)/\(file)")
        }
    }
}

extension DoriCache.Promise: Sendable where Result: Sendable {}

extension DoriCache.Cacheable {
    public init?(fromCache cache: Data) {
        let decoder = PropertyListDecoder()
        if let data = try? decoder.decode(Self.self, from: cache) {
            self = data
        } else if let wrapped = try? decoder.decode(CacheWrapper<Self>.self, from: cache) {
            self = wrapped.value
        } else {
            return nil
        }
    }
    public var dataForCache: Data {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary
        do {
            return try encoder.encode(self)
        } catch {
            // If `self` is a single value (e.g. String),
            // PropertyListEncoder can't encode it,
            // we use a wrapper then.
            let wrappedValue = CacheWrapper(value: self)
            return try! encoder.encode(wrappedValue)
        }
    }
}
private struct CacheWrapper<T: DoriCache.Cacheable>: DoriCache.Cacheable {
    var value: T
}

extension Color: @retroactive Encodable {
    enum CodingKeys: CodingKey {
        case red
        case green
        case blue
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let resolved = self.resolve(in: .init())
        try container.encode(resolved.red, forKey: .red)
        try container.encode(resolved.green, forKey: .green)
        try container.encode(resolved.blue, forKey: .blue)
    }
}
extension Color: @retroactive Decodable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let red = try container.decode(Double.self, forKey: .red)
        let green = try container.decode(Double.self, forKey: .green)
        let blue = try container.decode(Double.self, forKey: .blue)
        self.init(red: red, green: green, blue: blue)
    }
}
extension Color: DoriCache.Cacheable {}

extension String: DoriCache.Cacheable {}
extension Int: DoriCache.Cacheable {}
extension Int8: DoriCache.Cacheable {}
extension Int16: DoriCache.Cacheable {}
extension Int32: DoriCache.Cacheable {}
extension Int64: DoriCache.Cacheable {}
extension UInt: DoriCache.Cacheable {}
extension UInt8: DoriCache.Cacheable {}
extension UInt16: DoriCache.Cacheable {}
extension UInt32: DoriCache.Cacheable {}
extension UInt64: DoriCache.Cacheable {}
extension Bool: DoriCache.Cacheable {}
extension Double: DoriCache.Cacheable {}
extension Float: DoriCache.Cacheable {}
extension Date: DoriCache.Cacheable {}
extension Array: DoriCache.Cacheable where Element: DoriCache.Cacheable {}
extension Dictionary: DoriCache.Cacheable where Key: DoriCache.Cacheable, Value: DoriCache.Cacheable {}
extension Set: DoriCache.Cacheable where Element: DoriCache.Cacheable {}
extension Optional: DoriCache.Cacheable where Wrapped: DoriCache.Cacheable {}
