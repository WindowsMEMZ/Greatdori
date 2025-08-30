//===---*- Greatdori! -*---------------------------------------------------===//
//
// DoriKitMacros.swift
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

import SwiftSyntaxMacros
import SwiftCompilerPlugin

@main
struct DoriKitMacros: CompilerPlugin {
    var providingMacros: [any Macro.Type] = [
        OfflineAssetURLMacro.self,
        CopyOnWriteMacro.self,
        _CopyOnWriteVarPeerImplMacro.self,
        _CopyOnWriteVarAccessorImplMacro.self,
        _CopyOnWriteInitializerImplMacro.self
    ]
}
