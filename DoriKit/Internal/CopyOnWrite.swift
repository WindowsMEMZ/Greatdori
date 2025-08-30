//===---*- Greatdori! -*---------------------------------------------------===//
//
// CopyOnWrite.swift
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

internal final class __Reference<T> {
    @safe
    nonisolated(unsafe)
    internal var value: T
    
    internal init(_ value: T) {
        self.value = value
    }
}

internal struct __COWWrapper<T> {
    internal var ref: __Reference<T>
    
    internal init(_ x: T) {
        ref = __Reference(x)
    }
    
    internal var value: T {
        _read {
            yield ref.value
        }
        set {
            if !isKnownUniquelyReferenced(&ref) {
                ref = __Reference(newValue)
                return
            }
            ref.value = newValue
        }
    }
}

extension __Reference: Sendable where T: Sendable {}
extension __COWWrapper: Sendable where T: Sendable {}

extension __COWWrapper: Equatable where T: Equatable {
    @_transparent
    internal static func == (lhs: __COWWrapper<T>, rhs: __COWWrapper<T>) -> Bool {
        lhs.value == rhs.value
    }
}
extension __COWWrapper: Hashable where T: Hashable {
    internal func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
}
extension __COWWrapper: Codable where T: Codable {
    internal init(from decoder: any Decoder) throws {
        self.init(try decoder.singleValueContainer().decode(T.self))
    }
    internal func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}
