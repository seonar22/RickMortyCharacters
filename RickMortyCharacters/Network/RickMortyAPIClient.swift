//
//  RickMortyAPIClient.swift
//  RickMortyCharacters
//
//  Created by MAC on 6/9/23.
//

final class RickMortyRequest: RxHTTPRequest {
    static let shared = RickMortyRequest()
    
    private init() {
        let host = "https://rickandmortyapi.com"
        let basePath = "/api"
        super.init(host: host, basePath: basePath)
    }
}
