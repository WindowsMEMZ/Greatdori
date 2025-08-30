//===---*- Greatdori! -*---------------------------------------------------===//
//
// CopyOnWriteMacro.swift
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

import SwiftSyntax
import SwiftSyntaxMacros
internal import SwiftOperators
internal import SwiftDiagnostics
internal import SwiftSyntaxBuilder

public struct CopyOnWriteMacro: MemberAttributeMacro {
    static public func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        if let decl = member.as(VariableDeclSyntax.self) {
            guard decl.bindings.count == 1 else {
                return []
            }
            
            let binding = decl.bindings.first!
            // Don't attach to computed properties
            guard binding.accessorBlock == nil
                    || (binding.accessorBlock!.accessors.is(AccessorDeclListSyntax.self)
                        && binding.accessorBlock!.accessors.cast(AccessorDeclListSyntax.self).allSatisfy({
                        $0.accessorSpecifier.text.hasPrefix("will")
                        || $0.accessorSpecifier.text.hasPrefix("did")
                    })) else { return [] }
            
            return ["@_CopyOnWriteVarPeerImpl", "@_CopyOnWriteVarAccessorImpl"]
        }
        
        if member.is(InitializerDeclSyntax.self) {
            let declBodyVarNames = declaration.memberBlock.members.compactMap { (element) -> String? in
                if let decl = element.decl.as(VariableDeclSyntax.self) {
                    guard decl.bindings.count == 1 else {
                        return nil
                    }
                    
                    let binding = decl.bindings.first!
                    // Don't contain computed properties
                    guard binding.accessorBlock == nil
                            || (binding.accessorBlock!.accessors.is(AccessorDeclListSyntax.self)
                                && binding.accessorBlock!.accessors.cast(AccessorDeclListSyntax.self).allSatisfy({
                                $0.accessorSpecifier.text.hasPrefix("will")
                                || $0.accessorSpecifier.text.hasPrefix("did")
                            })) else { return nil }
                    
                    return binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
                } else {
                    return nil
                }
            }
            return ["@_CopyOnWriteInitializerImpl(\"\(raw: declBodyVarNames.joined(separator: ", "))\")"]
        }
        
        return []
    }
}

public struct _CopyOnWriteVarPeerImplMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let decl = declaration.cast(VariableDeclSyntax.self)
        let binding = decl.bindings.first!
        var result = VariableDeclSyntax(
            modifiers: [.init(name: "private")],
            .var,
            name: "__13DoriKitMacros28_CopyOnWriteVarPeerImplMacroV_\(raw: binding.pattern.cast(IdentifierPatternSyntax.self).identifier.text)"
        )
        
        var initValueExpr: ExprSyntax?
        if let initializer = binding.initializer {
            initValueExpr = initializer.value
        }
        
        var typeAnonTypeExpr: TypeSyntax? // not a typo
        if let typeAnnotation = binding.typeAnnotation {
            typeAnonTypeExpr = typeAnnotation.type
        }
        
        if let initValueExpr {
            // Wrap the initial value with `__COWWrapper(_:)`
            let binding = result.bindings.first!
            result = result.with(
                \.bindings,
                 [binding.with(
                    \.initializer,
                     .init(
                        value: FunctionCallExprSyntax(
                            calledExpression: DeclReferenceExprSyntax(baseName: "__COWWrapper"),
                            leftParen: .leftParenToken(),
                            arguments: [.init(expression: initValueExpr)],
                            rightParen: .rightParenToken()
                        )
                     )
                 )]
            )
        }
        
        if let typeAnonTypeExpr {
            // Wrap the type annotation with `__COWWrapper<T>`
            let binding = result.bindings.first!
            result = result.with(
                \.bindings,
                 [binding.with(
                    \.typeAnnotation,
                     .init(
                        type: IdentifierTypeSyntax(
                            name: "__COWWrapper",
                            genericArgumentClause: .init(
                                arguments: [.init(
                                    argument: .type(typeAnonTypeExpr))]
                            )
                        )
                     )
                 )]
            )
        }
        
        return [DeclSyntax(result)]
    }
}

public struct _CopyOnWriteVarAccessorImplMacro: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        let decl = declaration.cast(VariableDeclSyntax.self)
        let binding = decl.bindings.first!
        let wrapperName: PatternSyntax = "__13DoriKitMacros28_CopyOnWriteVarPeerImplMacroV_\(raw: binding.pattern.cast(IdentifierPatternSyntax.self).identifier.text)"
        
        let read: AccessorDeclSyntax = "_read { yield \(wrapperName).value }"
        let modify: AccessorDeclSyntax = "_modify { yield &\(wrapperName).value }"
        
        return [read, modify]
    }
}

public struct _CopyOnWriteInitializerImplMacro: BodyMacro {
    static public func expansion(
        of node: AttributeSyntax,
        providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
        in context: some MacroExpansionContext
    ) throws -> [CodeBlockItemSyntax] {
        let argRawStr = node.arguments!
            .cast(LabeledExprListSyntax.self).first!.expression
            .cast(StringLiteralExprSyntax.self).segments.first!
            .cast(StringSegmentSyntax.self).content.text
        let declBodyVarNames = argRawStr.split(separator: ", ").map { String($0) }
        
        let funcParamNames = declaration
            .cast(InitializerDeclSyntax.self)
            .signature
            .parameterClause
            .parameters.map {
                ($0.secondName ?? $0.firstName).text
        }
        
        let operatorFoldedBody = try! OperatorTable.standardOperators.foldAll(declaration.body!).cast(CodeBlockSyntax.self)
        let rewriter = COWInitizerRewriter(replacing: declBodyVarNames, requireSelf: funcParamNames)
        
        return operatorFoldedBody.statements.map {
            rewriter.rewrite($0).cast(CodeBlockItemSyntax.self)
        }
    }
}

private class COWInitizerRewriter: SyntaxRewriter {
    let replacingCalls: [String]
    let requireSelfCalls: [String]
    
    init(replacing: [String], requireSelf: [String]) {
        self.replacingCalls = replacing
        self.requireSelfCalls = requireSelf
    }
    
    override func visit(_ node: InfixOperatorExprSyntax) -> ExprSyntax {
        if node.operator.is(AssignmentExprSyntax.self),
           (node.leftOperand.is(DeclReferenceExprSyntax.self)
            && replacingCalls.contains(node.leftOperand.cast(DeclReferenceExprSyntax.self).baseName.text)
            && !requireSelfCalls.contains(node.leftOperand.cast(DeclReferenceExprSyntax.self).baseName.text))
            || (node.leftOperand.is(MemberAccessExprSyntax.self)
                && node.leftOperand.cast(MemberAccessExprSyntax.self).base?.as(DeclReferenceExprSyntax.self)?.baseName.text == "self"
                && replacingCalls.contains(node.leftOperand.cast(MemberAccessExprSyntax.self).declName.baseName.text)) {
            // Wrap the value with `__COWWrapper(_:)`
            let wrappedRightExpr = FunctionCallExprSyntax(
                calledExpression: DeclReferenceExprSyntax(baseName: "__COWWrapper"),
                leftParen: .leftParenToken(),
                arguments: [.init(expression: self.visit(node.rightOperand))],
                rightParen: .rightParenToken()
            )
            
            if let leftRef = node.leftOperand.as(DeclReferenceExprSyntax.self) {
                let newLeftRef = DeclReferenceExprSyntax(baseName: "__13DoriKitMacros28_CopyOnWriteVarPeerImplMacroV_\(leftRef.baseName)")
                return ExprSyntax(
                    node
                        .with(\.leftOperand, ExprSyntax(newLeftRef))
                        .with(\.operator, self.visit(node.operator))
                        .with(\.rightOperand, ExprSyntax(wrappedRightExpr))
                )
            } else if let leftRef = node.leftOperand.as(MemberAccessExprSyntax.self) {
                let leftDecl = leftRef.declName
                let newLeftRef = MemberAccessExprSyntax(
                    base: DeclReferenceExprSyntax(baseName: "self"),
                    period: .periodToken(),
                    declName: DeclReferenceExprSyntax(baseName: "__13DoriKitMacros28_CopyOnWriteVarPeerImplMacroV_\(leftDecl.baseName)")
                )
                return ExprSyntax(
                    node
                        .with(\.leftOperand, ExprSyntax(newLeftRef))
                        .with(\.operator, self.visit(node.operator))
                        .with(\.rightOperand, ExprSyntax(wrappedRightExpr))
                )
            }
        }
        
        return ExprSyntax(
            node
                .with(\.leftOperand, self.visit(node.leftOperand))
                .with(\.operator, self.visit(node.operator))
                .with(\.rightOperand, self.visit(node.rightOperand))
        )
    }
}
