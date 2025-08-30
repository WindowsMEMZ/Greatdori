//===---*- Greatdori! -*---------------------------------------------------===//
//
// Post.swift
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
internal import Alamofire
internal import SwiftyJSON

extension DoriAPI {
    /// Request and fetch data about community posts in Bandori.
    ///
    /// > Beta API:
    /// >
    /// > This API is currently in development and is unstable.
    /// > It is subject to change, and software implemented with this API should be tested with its stable version.
    public enum Post {
        public static func _list(_ request: ListRequest) async -> PagedPosts? {
            let result = await requestJSON("https://bestdori.com/api/post/list", method: .post, parameters: request, encoder: JSONParameterEncoder.default)
            if case let .success(respJSON) = result {
                let task = Task.detached(priority: .userInitiated) { () async -> PagedPosts? in
                    guard respJSON["result"].boolValue else { return nil }
                    return .init(
                        total: respJSON["count"].intValue,
                        currentOffset: request.offset,
                        content: respJSON["posts"].map {
                            var storyMetadata: Post.StoryMetadata? = nil
                            let categoryName = Category(rawValue: $0.1["categoryName"].stringValue) ?? .selfPost
                            let categoryID = $0.1["categoryId"].stringValue
                            if categoryName == .selfPost && categoryID == "story" {
                                storyMetadata = .init(
                                    storyType: $0.1["storyType"].intValue,
                                    summary: $0.1["summary"].stringValue,
                                    rating: .init(rawValue: $0.1["rating"].intValue) ?? .general,
                                    warningViolence: $0.1["warningViolence"].boolValue,
                                    warningDeath: $0.1["warningDeath"].boolValue,
                                    warningNonCon: $0.1["warningNonCon"].boolValue,
                                    warningUnderage: $0.1["warningUnderage"].boolValue,
                                    time: .init(timeIntervalSince1970: $0.1["time"].doubleValue / 1000),
                                    author: .init(
                                        username: $0.1["author"]["username"].stringValue,
                                        nickname: $0.1["author"]["nickname"].stringValue,
                                        titles: $0.1["author"]["titles"].map {
                                            .init(
                                                id: $0.1["id"].intValue,
                                                type: $0.1["type"].stringValue,
                                                server: .init(rawIntValue: $0.1["server"].intValue) ?? .jp
                                            )
                                        }
                                    ),
                                    likes: $0.1["likes"].intValue,
                                    liked: $0.1["liked"].boolValue,
                                    tags: $0.1["tags"].compactMap {
                                        .init(parsing: $0.1)
                                    },
                                    storyParent: $0.1["storyParent"]["id"].int != nil ? .init(
                                        id: $0.1["storyParent"]["id"].intValue,
                                        title: $0.1["storyParent"]["title"].stringValue,
                                        summary: $0.1["storyParent"]["summary"].stringValue,
                                        rating: .init(rawValue: $0.1["storyParent"]["rating"].intValue) ?? .general,
                                        warningViolence: $0.1["storyParent"]["warningViolence"].boolValue,
                                        warningDeath: $0.1["storyParent"]["warningDeath"].boolValue,
                                        warningNonCon: $0.1["storyParent"]["warningNonCon"].boolValue,
                                        warningUnderage: $0.1["storyParent"]["warningUnderage"].boolValue
                                    ) : nil
                                )
                            }
                            return .init(
                                id: $0.1["id"].intValue,
                                categoryName: categoryName,
                                categoryID: categoryID,
                                title: $0.1["title"].stringValue,
                                content: .init(parsing: $0.1["content"]),
                                storyMetadata: storyMetadata
                            )
                        }
                    )
                }
                return await task.value
            }
            return nil
        }
        
        @inlinable
        public static func communityPosts(limit: Int = 20, offset: Int) async -> PagedPosts? {
            await _list(.init(categoryName: .selfPost, categoryId: "text", order: .timeDescending, limit: limit, offset: offset))
        }
        
        @inlinable
        public static func communityStories(limit: Int = 20, offset: Int) async -> PagedPosts? {
            await _list(.init(categoryName: .selfPost, categoryId: "story", order: .timeDescending, limit: limit, offset: offset))
        }
    }
}

extension DoriAPI.Post {
    public struct Post: Identifiable, Sendable, Hashable {
        public var id: Int
        public var categoryName: Category
        public var categoryID: String
        public var title: String
        public var content: RichContentGroup
        public var storyMetadata: StoryMetadata?
        
        public struct StoryMetadata: Sendable, Hashable {
            public var storyType: Int
            public var summary: String
            public var rating: AgeRating
            public var warningViolence: Bool
            public var warningDeath: Bool
            public var warningNonCon: Bool
            public var warningUnderage: Bool
            public var time: Date // Int64(JSON) -> Date(Swift)
            public var author: Author
            public var likes: Int
            public var liked: Bool
            public var tags: [Tag]
            public var storyParent: StoryParent?
            
            public enum AgeRating: Int, Sendable, Hashable {
                case general
                case teenAndUp
                case mature
                case explicit
            }
            public struct Author: Sendable, Hashable {
                public var username: String
                public var nickname: String
                public var titles: [Title]
                
                public struct Title: Sendable, Identifiable, Hashable {
                    public var id: Int
                    public var type: String
                    public var server: DoriAPI.Locale // Int(JSON) -> Locale(Swift)
                }
            }
            public enum Tag: Sendable, Hashable {
                case text(String)
                case character(Int) // String(JSON) -> Int(Swift) CharacterID
                case card(Int) // String(JSON) -> Int(Swift) CardID
                
                internal init?(parsing json: JSON) {
                    if let type = json["type"].string {
                        switch type {
                        case "text":
                            self = .text(json["data"].stringValue)
                        case "character":
                            if let id = Int(json["data"].stringValue) {
                                self = .character(id)
                            } else {
                                return nil
                            }
                        case "card":
                            if let id = Int(json["data"].stringValue) {
                                self = .card(id)
                            } else {
                                return nil
                            }
                        default: return nil
                        }
                    } else {
                        return nil
                    }
                }
            }
            public struct StoryParent: Sendable, Identifiable, Hashable {
                public var id: Int
                public var title: String
                public var summary: String
                public var rating: AgeRating
                public var warningViolence: Bool
                public var warningDeath: Bool
                public var warningNonCon: Bool
                public var warningUnderage: Bool
            }
        }
    }
    
    public struct PagedPosts: PagedContent, Sendable, Hashable {
        public var total: Int
        public var currentOffset: Int
        public var content: [Post]
    }
    
    public enum Category: String, Sendable, Hashable {
        case selfPost = "SELF_POST"
    }
    
    public struct ListRequest: Encodable, Sendable, Hashable {
        public var following: Bool
        public var categoryName: String
        public var categoryId: String
        public var order: String
        public var limit: Int
        public var offset: Int
        
        public init(
            _following following: Bool = false,
            categoryName: Category,
            categoryId: String,
            order: ListOrder,
            limit: Int = 20,
            offset: Int
        ) {
            self.following = following
            self.categoryName = categoryName.rawValue
            self.categoryId = categoryId
            self.order = order.rawValue
            self.limit = limit
            self.offset = offset
        }
    }
    public enum ListOrder: String, Hashable {
        case timeAscending = "TIME_ASC"
        case timeDescending = "TIME_DESC"
    }
}

#endif // HAS_BINARY_RESOURCE_BUNDLES
