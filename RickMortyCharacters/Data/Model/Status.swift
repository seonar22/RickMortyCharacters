//
//  Status.swift
//  RickMortyCharacters
//
//  Created by MAC on 6/10/23.
//

import Foundation

enum Status: String, Codable {
    case alive = "Alive"
    case dead = "Dead"
    case unknown = "unknown"
    
    var displayString: String {
        switch self {
        case .alive, .dead:
            return self.rawValue
        case .unknown:
            return "Unknown"
        }
    }
}
