//
//  CharacterListVCViewModel.swift
//  RickMortyCharacters
//
//  Created by MAC on 6/9/23.
//

import Foundation
import RxSwift
import RxCocoa

class CharacterListVCViewModel {
    // MARK: Properties
    private let apiClient: RxHTTPRequest
    private let disposeBag = DisposeBag()
    
    private(set) lazy var isLoading = BehaviorRelay<Bool>(value: false)
    private(set) lazy var hasNextForApiCall = BehaviorRelay<Bool>(value: true)
    private(set) lazy var error = PublishRelay<Void>.init()

    private(set) lazy var page = BehaviorRelay<Int>(value: 1)
    private(set) lazy var charactersFromAPI = BehaviorRelay<[CharacterSummary]>(value: [])
    private(set) lazy var charactersFromAPIPer10 = BehaviorRelay<[[CharacterSummary]]>(value: [])
    
    private(set) lazy var pagePer10 = BehaviorRelay<Int>(value: 0)
    var characters: [CharacterSummary] {
        guard !charactersFromAPIPer10.value.isEmpty else { return []}
        
        return charactersFromAPIPer10.value[pagePer10.value]
    }
    
    // MARK: Lifecycle
    init(apiClient: RxHTTPRequest) {
        self.apiClient = apiClient
        
        charactersFromAPI
            .subscribe(onNext: {[weak self] characters in
                guard let self = self else { return }
              
                self.charactersFromAPIPer10.accept(characters.chunked(into: 10))
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: API methods
    func getCharacters() {
        guard hasNextForApiCall.value else {
            // Throw error
            return
        }
        
        isLoading.accept(true)
        
        let query = [
            "page": String(page.value)
        ]
        apiClient.get(returnType: CharacterListAPIResponse.self, path: "/character", query: query)
            .subscribe(onNext: {[weak self] apiResponse in
                guard let self = self else { return }
                
                if let next = apiResponse.info?.next, !next.isEmpty {
                    self.hasNextForApiCall.accept(true)
                } else {
                    self.hasNextForApiCall.accept(false)
                }
                
                let existingCharacters = self.charactersFromAPI.value
                let newCharacters = apiResponse.results
                    .map {
                        CharacterSummary(name: $0.name ?? "-", status: $0.status)
                    }
                self.charactersFromAPI.accept(existingCharacters + newCharacters)
                self.isLoading.accept(false)
            },
                       onError: {[weak self] error in
                self?.isLoading.accept(false)
                self?.error.accept(())
            })
            .disposed(by: disposeBag)
    }
}
