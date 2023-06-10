//
//  MockDetailVCViewModel.swift
//  RickMortyCharactersTests
//
//  Created by MAC on 6/10/23.
//

import Foundation
import RxSwift

@testable import RickMortyCharacters

final class MockDetailVCViewModel: DetailVCViewModel {
    enum TypeOfApiCall {
        case successful
        case error
    }
    
    private let testImage = UIImage(systemName: "plus.square")!
    var typeOfApiCall: TypeOfApiCall?
    
    // MARK: API methods
    override func getDetail(id: String) {
        guard let typeOfApiCall = typeOfApiCall else { return }
        
        switch typeOfApiCall {
        case .error:
            error.accept(())
        case .successful:
            generateCharacterDetail()
        }
    }
    
    override func getAvatarImage(_ profileImageURL: URL) {
        guard let typeOfApiCall = typeOfApiCall else { return }
        
        switch typeOfApiCall {
        case .error:
            error.accept(())
        case .successful:
            profileImageData.accept(testImage)
        }
    }
    
    private func generateCharacterDetail() {
        let data = try! Data.fromJSON(fileName: "CharacterDetail")
        
        let decoder = JSONDecoder()
        let apiResponse = try! decoder.decode(CharacterDetailAPIResponse.self, from: data)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.characterDetailFromAPI.accept(apiResponse)
        }
    }
}
