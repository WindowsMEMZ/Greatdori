//===---*- Greatdori! -*---------------------------------------------------===//
//
// LinuxSupport.swift
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

#if !canImport(Darwin)

import Foundation

extension RangeReplaceableCollection where Self: MutableCollection {
    public mutating func remove(atOffsets offsets: IndexSet) {
        for offset in offsets.reversed() {
            let idx = index(startIndex, offsetBy: offset)
            remove(at: idx)
        }
    }
}

#endif
