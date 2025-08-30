//===---*- Greatdori! -*---------------------------------------------------===//
//
// PagedContent.swift
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

/// A type that stores contents which can be separated into multiple pages.
///
/// > Beta API:
/// >
/// > This API is currently in development and is unstable.
/// > It is subject to change, and software implemented with this API should be tested with its stable version.
public protocol PagedContent {
    associatedtype Content
    
    var total: Int { get }
    var currentOffset: Int { get }
    var content: [Content] { get }
}

extension PagedContent {
    @inlinable
    public var pageCapacity: Int {
        content.count
    }
    @inlinable
    public var hasMore: Bool {
        currentOffset + pageCapacity < total
    }
    @inlinable
    public var nextOffset: Int {
        currentOffset + pageCapacity
    }
    @inlinable
    public var pageCount: Int {
        Int(ceil(Double(total) / Double(pageCapacity)))
    }
    @inlinable
    public var currentPage: Int {
        currentOffset / pageCount + 1
    }
}
