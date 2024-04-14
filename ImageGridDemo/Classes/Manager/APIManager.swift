//
//  APIManager.swift
//  ImageGridDemo
//
//  Created by Sandeep on 14/04/24.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case invalidData(reason: String)
    case unauthorized
    case forbidden
    case notFound
    case internalServerError
    case badGateway
    case serviceUnavailable
    case customError(statusCode: Int) // Custom error case for specific status codes
   
    var errorMessage: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .invalidData(let reason):
            return "Invalid data: \(reason)"
        case .unauthorized:
            return "Unauthorized access"
        case .forbidden:
            return "Access forbidden"
        case .notFound:
            return "Resource not found"
        case .internalServerError:
            return "Internal server error"
        case .badGateway:
            return "Bad gateway"
        case .serviceUnavailable:
            return "Service unavailable"
        case .customError(let statusCode):
            return "Custom error with status code \(statusCode)"
        }
    }
}

enum APIManagerType: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
    case put = "PUT"
}

class APIManager {
    static let shared = APIManager()
    let session: URLSession
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 45
        configuration.timeoutIntervalForResource = 45
        session = URLSession(configuration: configuration)
    }

    func fetchData(from url: URL, type: APIManagerType, parameters: [String: Any]?) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = type.rawValue

        if let parameters = parameters {
            // If the request type is POST or PUT, encode parameters into the request body
            if type == .post || type == .put {
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
                } catch {
                    throw APIError.invalidData(reason: "Failed to encode parameters")
                }
            } else if type == .get || type == .delete {
                // If the request type is GET or DELETE, encode parameters into the URL query string
                if !parameters.isEmpty {
                    var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
                    components.queryItems = parameters.map { key, value in
                        URLQueryItem(name: key, value: "\(value)")
                    }
                    request.url = components.url
                }
            }
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            DebugManager.log("response: \(response)")
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            DebugManager.log("httpResponse.statusCode: \(httpResponse.statusCode)")

            guard (200...299).contains(httpResponse.statusCode) else {
                switch httpResponse.statusCode {
                case 400...499:
                    switch httpResponse.statusCode {
                    case 400:
                        throw APIError.invalidData(reason: "Bad request") // Bad request
                    case 401:
                        throw APIError.unauthorized // Unauthorized access
                    case 403:
                        throw APIError.forbidden // Forbidden
                    case 404:
                        throw APIError.notFound // Resource not found
                    default:
                        throw APIError.customError(statusCode: httpResponse.statusCode) // Other client-side errors
                    }
                case 500...599:
                    switch httpResponse.statusCode {
                    case 500:
                        throw APIError.internalServerError // Internal server error
                    case 502:
                        throw APIError.badGateway // Bad gateway
                    case 503:
                        throw APIError.serviceUnavailable // Service unavailable
                    default:
                        throw APIError.networkError(APIError.customError(statusCode: httpResponse.statusCode)) // Other server-side errors
                    }
                default:
                    throw APIError.invalidResponse // Other error
                }
            }
            return data
        } catch {
            if let urlError = error as? URLError {
                throw APIError.networkError(urlError) // Handle network-related errors
            } else {
                throw APIError.networkError(error) // Other unknown errors
            }
        }
    }
}
