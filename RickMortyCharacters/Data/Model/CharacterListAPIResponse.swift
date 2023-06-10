//
//  CharacterListAPIResponse.swift
//  RickMortyCharacters
//
//  Created by MAC on 6/9/23.
//

import Foundation

// MARK: - CharacterListAPIResponse
struct CharacterListAPIResponse: Codable {
    let info: Info?
    let results: [Result]
    
    //    private enum CodingKeys: CodingKey {
    //        case info, results
    //    }
    
    // MARK: - Info
    struct Info: Codable {
        let count, pages: Int
        let next: String?
        let prev: String?
    }
    
    // MARK: - Result
    struct Result: Codable {
        let id: Int?
        let name: String?
        let status: Status?
        let species: String?
        let type: String?
        let gender: String?
        let origin, location: Location?
        let image: String?
        let episode: [String]?
        let url: String?
        let created: String?
    }
}
