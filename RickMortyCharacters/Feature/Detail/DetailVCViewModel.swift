//
//  DetailVCViewModel.swift
//  RickMortyCharacters
//
//  Created by MAC on 6/10/23.
//

import Foundation
import RxSwift
import RxCocoa

class DetailVCViewModel {
    // MARK: Properties
    private let apiClient: RxHTTPRequest
    private let disposeBag = DisposeBag()
    
    private(set) lazy var isLoading = BehaviorRelay<Bool>(value: false)
    private(set) lazy var error = PublishRelay<Void>.init()
    
    private(set) lazy var characterDetailFromAPI = BehaviorRelay<CharacterDetailAPIResponse?>(value: nil)
    private(set) lazy var profileImageData = BehaviorRelay<UIImage>(value: placeholderImage)
    private let placeholderImage = UIImage(systemName: "person.crop.square.fill")!
    
    // MARK: Lifecycle
    init(apiClient: RxHTTPRequest) {
        self.apiClient = apiClient
    }
    
    // MARK: API methods
    func getDetail(id: String) {
        apiClient.get(returnType: CharacterDetailAPIResponse.self, path: "/character/\(id)")
            .subscribe(onNext: {[weak self] apiResponse in
                guard let self = self else { return }
                
                self.characterDetailFromAPI.accept(apiResponse)
            },
                       onError: {[weak self] error in
                self?.isLoading.accept(false)
                self?.error.accept(())
            })
            .disposed(by: disposeBag)
    }
    
    func getAvatarImage(_ profileImageURL: URL) {
        ImageDownloader.shared.loadData(url: profileImageURL) { [weak self] data, _ in
            guard let self = self else { return }
            
            guard let data = data else {
                self.profileImageData.accept(self.placeholderImage)
                return
            }
            
            self.profileImageData.accept(UIImage(data: data) ?? placeholderImage)
        }
    }
}
