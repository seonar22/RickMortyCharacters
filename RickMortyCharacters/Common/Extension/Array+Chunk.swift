//
//  Array+Chunk.swift
//  RickMortyCharacters
//
//  Created by MAC on 6/10/23.
//

import Foundation

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
