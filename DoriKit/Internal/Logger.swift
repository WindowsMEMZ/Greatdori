//===---*- Greatdori! -*---------------------------------------------------===//
//
// Logger.swift
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

#if canImport(OSLog)

import OSLog

internal let logger = Logger(subsystem: "com.apple.runtime-issues", category: "DoriKit")

extension Logger {
    internal func log<T>(_ message: @autoclosure @escaping () -> String, evaluate closure: @autoclosure () -> T) -> T {
        self.log("\(message())")
        return closure()
    }
    
    internal func log<T>(level: OSLogType, _ message: @autoclosure @escaping () -> String, evaluate closure: @autoclosure () -> T) -> T {
        self.log(level: level, "\(message())")
        return closure()
    }
    
    internal func trace<T>(_ message: @autoclosure @escaping () -> String, evaluate closure: @autoclosure () -> T) -> T {
        self.trace("\(message())")
        return closure()
    }
    
    internal func debug<T>(_ message: @autoclosure @escaping () -> String, evaluate closure: @autoclosure () -> T) -> T {
        self.debug("\(message())")
        return closure()
    }
    
    internal func info<T>(_ message: @autoclosure @escaping () -> String, evaluate closure: @autoclosure () -> T) -> T {
        self.info("\(message())")
        return closure()
    }
    
    internal func notice<T>(_ message: @autoclosure @escaping () -> String, evaluate closure: @autoclosure () -> T) -> T {
        self.notice("\(message())")
        return closure()
    }
    
    internal func warning<T>(_ message: @autoclosure @escaping () -> String, evaluate closure: @autoclosure () -> T) -> T {
        self.warning("\(message())")
        return closure()
    }
    
    internal func error<T>(_ message: @autoclosure @escaping () -> String, evaluate closure: @autoclosure () -> T) -> T {
        self.error("\(message())")
        return closure()
    }
    
    internal func critical<T>(_ message: @autoclosure @escaping () -> String, evaluate closure: @autoclosure () -> T) -> T {
        self.critical("\(message())")
        return closure()
    }
    
    internal func fault<T>(_ message: @autoclosure @escaping () -> String, evaluate closure: @autoclosure () -> T) -> T {
        self.fault("\(message())")
        return closure()
    }
}

#else

@dynamicCallable
@dynamicMemberLookup
internal struct Logger {
    internal func dynamicallyCall<T>(withArguments args: [T]) {
        
    }
    internal func dynamicallyCall<T>(withKeywordArguments args: KeyValuePairs<String, T>) {
        
    }
    internal subscript<S: ExpressibleByStringLiteral>(dynamicMember dynamicMember: S) -> Self {
        self
    }
}

internal let logger = Logger()

#endif
