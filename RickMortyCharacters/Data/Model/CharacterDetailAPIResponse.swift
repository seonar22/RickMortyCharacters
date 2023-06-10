//
//  CharacterDetailAPIResponse.swift
//  RickMortyCharacters
//
//  Created by MAC on 6/9/23.
//

import Foundation

// MARK: - CharacterDetailAPIResponse
struct CharacterDetailAPIResponse: Codable {
    let id: Int?
    let name, status, species, type: String?
    let gender: String?
    let origin, location: Location?
    let image: String?
    let episode: [String]?
    let url: String?
    let created: String?
}
