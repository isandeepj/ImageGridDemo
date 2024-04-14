//
//  CoverageFeed.swift
//  ImageGridDemo
//
//  Created by Sandeep on 14/04/24.
//

import Foundation

struct CoverageFeed: Codable, Hashable {
    let id: String
    let title: String
    let language: String
    let thumbnail: Thumbnail?
    let mediaType: Int
    let coverageURL: String?
    let publishedAt: String
    let publishedBy: String
    let backupDetails: BackupDetails?

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(language)
    }
    
    static func == (lhs: CoverageFeed, rhs: CoverageFeed) -> Bool {
        return lhs.id == rhs.id
    }
}

struct Thumbnail: Codable, Hashable {
    let id: String
    let version: Int
    let domain: String
    let basePath: String
    let key: String
    let qualities: [Int]
    let aspectRatio: Double
    var defaultMaxQuality: Int
    var imageURL: URL?

    private enum CodingKeys: String, CodingKey {
        case id, version, domain, basePath, qualities, aspectRatio
        case key = "key"
    }

 
    // Encoding method
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(version, forKey: .version)
        try container.encode(domain, forKey: .domain)
        try container.encode(basePath, forKey: .basePath)
        try container.encode(key, forKey: .key)
        try container.encode(qualities, forKey: .qualities)
        try container.encode(aspectRatio, forKey: .aspectRatio)
    }
    
    // Decoding method
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        version = try container.decode(Int.self, forKey: .version)
        domain = try container.decode(String.self, forKey: .domain)
        basePath = try container.decode(String.self, forKey: .basePath)
        key = try container.decode(String.self, forKey: .key)
        qualities = try container.decode([Int].self, forKey: .qualities)
        aspectRatio = try container.decode(Double.self, forKey: .aspectRatio)
        
        defaultMaxQuality = qualities.max() ?? qualities.last ?? 20
        let urlString = "\(domain)/\(basePath)/\(defaultMaxQuality)/\(key)"
        imageURL = URL(string: urlString)
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(version)
        hasher.combine(domain)
        hasher.combine(basePath)
        hasher.combine(key)
    }
    static func == (lhs: Thumbnail, rhs: Thumbnail) -> Bool {
        return lhs.id == rhs.id && lhs.key == rhs.key
    }
}

struct BackupDetails: Codable {
    let pdfLink: String?
    let screenshot: String?
    var pdfLinkURL: URL?
    var screenshotURL: URL?

    // Define CodingKeys enumeration
    private enum CodingKeys: String, CodingKey {
        case pdfLink
        case screenshot = "screenshotURL"
    }

    // Encoding method
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(pdfLink, forKey: .pdfLink)
        try container.encodeIfPresent(screenshot, forKey: .screenshot)
    }

    // Decoding method
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        pdfLink = try container.decodeIfPresent(String.self, forKey: .pdfLink)
        screenshot = try container.decodeIfPresent(String.self, forKey: .screenshot)
        
        if let urlString = pdfLink, !urlString.isEmpty {
            pdfLinkURL = URL(string: urlString)
        }
        
        if let urlString = screenshot, !urlString.isEmpty {
            screenshotURL = URL(string: urlString)
        }
    }

}
