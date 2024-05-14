//
//  NewsModel.swift
//  SchoolDiary
//
//  Created by Wolf on 25.04.2024.
//

import Foundation



struct NewsModel: Decodable {
    let status: String
    let totalResults: Int
    let articles: [Article]
//    let description: String
//    let url: String
//    let urlToImage: String
//    let publishedAt: String
//    let content: String
}

struct Article: Decodable {
    let source: ArticleSource
    let author: String?
    let title: String?
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String?
    let content: String?
}

struct ArticleSource: Decodable {
    let id: String?
    let name: String?
}
