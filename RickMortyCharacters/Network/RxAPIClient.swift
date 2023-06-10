//
//  RxAPIClient.swift
//  RickMortyCharacters
//
//  Created by MAC on 6/9/23.
//

import Foundation
import RxSwift
import RxCocoa

protocol RxHTTPRequestProtocol {
    func get<U: Decodable>(returnType: U.Type, path: String, query: [String: String]?, token: String?) -> Observable<U>
    func get(path: String, query: [String: String]?, token: String?) -> Observable<Void>
    func post<T: Encodable, U: Decodable>(returnType: U.Type, path: String, query: [String: String]?, body: T, token: String?) -> Observable<U>
    func post<T: Encodable>(path: String, query: [String: String]?, body: T, token: String?) -> Observable<Void>
    func put<T: Encodable, U: Decodable>(returnType: U.Type, path: String, query: [String: String]?, body: T, token: String?) -> Observable<U>
    func put<T: Encodable>(path: String, query: [String: String]?, body: T, token: String?) -> Observable<Void>
    func delete<U: Decodable>(returnType: U.Type, path: String, query: [String: String]?, token: String?) -> Observable<U>
    func delete(path: String, query: [String: String]?, token: String?) -> Observable<Void>
}

class RxHTTPRequest: RxHTTPRequestProtocol {
    private let host: String
    private let basePath: String
    
    init(host: String, basePath: String) {
        self.host = host
        self.basePath = basePath
    }
    
    enum Method: String, CustomStringConvertible {
        case get
        case post
        case put
        case delete
        var description: String { return self.rawValue }
    }
    
    private struct Dummy: Codable {}
    
    func get<U: Decodable>(returnType: U.Type, path: String, query: [String: String]? = nil, token: String? = nil) -> Observable<U> {
        return request(.get, U.self, path, query, Dummy?.none, token)
    }
    func get(path: String, query: [String: String]? = nil, token: String? = nil) -> Observable<Void> {
        return request(.get, path, query, Dummy?.none, token)
    }
    func post<T: Encodable, U: Decodable>(returnType: U.Type, path: String, query: [String: String]? = nil, body: T, token: String? = nil) -> Observable<U> {
        return request(.post, U.self, path, query, body, token)
    }
    func post<T: Encodable>(path: String, query: [String: String]? = nil, body: T, token: String? = nil) -> Observable<Void> {
        return request(.post, path, query, body, token)
    }
    func put<T: Encodable, U: Decodable>(returnType: U.Type, path: String, query: [String: String]? = nil, body: T, token: String? = nil) -> Observable<U> {
        return request(.put, U.self, path, query, body, token)
    }
    func put<T: Encodable>(path: String, query: [String: String]? = nil, body: T, token: String? = nil) -> Observable<Void> {
        return request(.put, path, query, body, token)
    }
    func delete<U: Decodable>(returnType: U.Type, path: String, query: [String: String]? = nil, token: String? = nil) -> Observable<U> {
        return request(.delete, U.self, path, query, Dummy?.none, token)
    }
    func delete(path: String, query: [String: String]? = nil, token: String? = nil) -> Observable<Void> {
        return request(.delete, path, query, Dummy?.none, token)
    }
    
    private func request<T: Encodable, U: Decodable>(_ method: Method, _ returnType: U.Type, _ path: String, _ query: [String: String]?, _ body: T?, _ token: String?) -> Observable<U> {
        let req = getURLRequest(method, path, query, body, token)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        return session.rx.data(request: req)
            .map { data in
                if "" is U {
                    return (String(data: data, encoding: .utf8) ?? "") as! U
                } else {
                    let decoder = JSONDecoder()
                    do {
                       return try decoder.decode(U.self, from: data)
                    } catch (let error) {
                        print(error)
                        fatalError()
                    }
                }
            }
    }
    private func request<T: Encodable>(_ method: Method, _ path: String, _ query: [String: String]?, _ body: T?, _ token: String?) -> Observable<Void> {
        let req = getURLRequest(method, path, query, body, token)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        return session.rx.data(request: req).map { _ in }
    }
    
    private func getURLRequest<T: Encodable>(_ method: Method, _ path: String, _ query: [String: String]?, _ body: T?, _ token: String?) -> URLRequest {
        // URL with query
        var components = URLComponents(string: host + basePath + path)
        if let query = query {
            var queryItems: [URLQueryItem] = []
            for (key, value) in query {
                let queryItem = URLQueryItem(name: key, value: value)
                queryItems.append(queryItem)
            }
            components?.queryItems = queryItems
        }
        guard let url = components?.url else { fatalError("URL is invalid") }
        print(url)
        
        // URLRequest
        var req = URLRequest(url: url)
        req.httpMethod = method.description
        
        // token
        if let token = token {
            req.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // body
        if let body = body {
            req.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            let encoder = JSONEncoder()
            do {
                let data = try encoder.encode(body)
                req.httpBody = data
            } catch {
                fatalError("Request body is invalid")
            }
        }
        return req
    }
}
