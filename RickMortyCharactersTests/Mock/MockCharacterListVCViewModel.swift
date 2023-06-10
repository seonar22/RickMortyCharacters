//
//  MockCharacterListVCViewModel.swift
//  RickMortyCharactersTests
//
//  Created by MAC on 6/10/23.
//

import Foundation
import RxSwift

@testable import RickMortyCharacters

final class MockCharacterListVCViewModel: CharacterListVCViewModel {
    enum TypeOfApiCall {
        case successful
        case error
    }
    
    var typeOfApiCall: TypeOfApiCall?

    override func getCharacters() {
        guard let typeOfApiCall = typeOfApiCall else { return }
        
        switch typeOfApiCall {
        case .error:
            error.accept(())
        case .successful:
            generateCharacters()
        }
    }
    
    private func generateCharacters() {
        let data = try! Data.fromJSON(fileName: "CharacterList")
        
        let decoder = JSONDecoder()
        let apiResponse = try! decoder.decode(CharacterListAPIResponse.self, from: data)
        
        if let next = apiResponse.info?.next, !next.isEmpty {
            self.hasNextForApiCall.accept(true)
        } else {
            self.hasNextForApiCall.accept(false)
        }
        
        let existingCharacters = self.charactersFromAPI.value
        let newCharacters = apiResponse.results
            .map {
                CharacterSummary(id: $0.id, name: $0.name ?? "-", status: $0.status)
            }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.charactersFromAPI.accept(existingCharacters + newCharacters)
        }
    }
}

