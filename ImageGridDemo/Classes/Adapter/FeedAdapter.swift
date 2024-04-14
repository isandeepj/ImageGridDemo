//
//  FeedAdapter.swift
//  ImageGridDemo
//
//  Created by Sandeep on 14/04/24.
//

import Foundation


enum FeedAdapterError: Error {
    case apiError(APIError)
    case dataParsingError
    
    var errorMessage: String {
        switch self {
        case .dataParsingError:
            return "Data parsing error"
        case .apiError(let error):
            return "API error: \(error.localizedDescription)"
        }
    }
}
 
struct FeedAdapter {
    static let baseURLString = "https://acharyaprashant.org/api/v2/content/misc/media-coverages"
    
    static func fetchCoverageFeed(limit: Int = 100) async throws -> [CoverageFeed] {
        guard let url = URL(string: baseURLString) else {
            throw APIError.invalidURL
        }
        
        do {
            let data = try await APIManager.shared.fetchData(from: url, type: .get, parameters: ["limit": limit])
            let decoder = JSONDecoder()
            let coverageFeeds = try decoder.decode([CoverageFeed].self, from: data)
            return coverageFeeds
        } catch let apiError as APIError {
            throw FeedAdapterError.apiError(apiError)
        } catch {
            throw FeedAdapterError.dataParsingError
        }
    }
}
