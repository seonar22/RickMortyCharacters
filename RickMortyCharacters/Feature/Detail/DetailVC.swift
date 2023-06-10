//
//  DetailVC.swift
//  RickMortyCharacters
//
//  Created by MAC on 6/10/23.
//

import UIKit
import RxSwift
import RxGesture

class DetailVC: UIViewController {
    // MARK: Outlet
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var infoTextView: UITextView!
    
    // MARK: Properties
    var viewModel = DetailVCViewModel(apiClient: RickMortyRequest.shared)
    private let disposeBag = DisposeBag()
    private let placeholderImage = UIImage(systemName: "person.crop.square.fill")!
    // set by caller
    var id: Int?
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialUI()
        bind()
        
        guard let id = id else {
            AlertView.showApiFailureAlert(in: self)
            return
        }
        
        viewModel.getDetail(id: String(id))
    }
    
    private func bind() {
        viewModel.characterDetailFromAPI
            .asDriver()
            .drive(onNext: {[weak self] detail in
                guard let self = self else { return }
                
                self.reloadUI(detail)
            })
            .disposed(by: disposeBag)
        viewModel.error.asDriver(onErrorJustReturn: ())
            .drive(onNext: {[weak self] _ in
                guard let self = self else { return }
                
                AlertView.showApiFailureAlert(in: self)
            })
            .disposed(by: disposeBag)
        viewModel.profileImageData.asDriver()
            .drive(onNext: {[weak self] image in
                guard let self = self else { return }
                
                self.avatarImageView.image = image
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: UI
    private func initialUI() {
        resetAvatarImage()
        resetInfo()
        
        infoTextView.linkTextAttributes = [
            .foregroundColor: UIColor.blue,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        infoTextView.isUserInteractionEnabled = true
        infoTextView.isEditable = false
    }
    
    private func resetAvatarImage() {
        avatarImageView.image = placeholderImage
    }
    
    private func resetInfo() {
        infoTextView.text = "-"
    }
    
    private func reloadUI(_ detail: CharacterDetailAPIResponse?) {
        guard let detail = detail else { return }
        if let profileImageURLString = detail.image, let profileImageURL = URL(string: profileImageURLString) {
            setAvatarImage(profileImageURL)
        }
        
        setInfo(detail)
    }
}

extension DetailVC {
    private func setAvatarImage(_ profileImageURL: URL) {
        viewModel.getAvatarImage(profileImageURL)
    }
    
    private func setInfo(_ detail: CharacterDetailAPIResponse) {
        let infoText = NSMutableAttributedString.dynamicText(text: "")
        
        if let id = detail.id {
            infoText.append(NSMutableAttributedString.dynamicText(text: "ID: \(id)"))
        }
        if let name = detail.name, !name.isEmpty {
            infoText.append(NSMutableAttributedString.dynamicText(text: "\nName: \(name)"))
        }
        if let status = detail.status {
            infoText.append(NSMutableAttributedString.dynamicText(text: "\nStatus: \(status.displayString)"))
        }
        if let species = detail.species, !species.isEmpty {
            infoText.append(NSMutableAttributedString.dynamicText(text: "\nSpecies: \(species)"))
        }
        if let type = detail.type, !type.isEmpty {
            infoText.append(NSMutableAttributedString.dynamicText(text: "\nType: \(type)"))
        }
        if let gender = detail.gender, !gender.isEmpty {
            infoText.append(NSMutableAttributedString.dynamicText(text: "\nGender: \(gender)"))
        }
        if let originName = detail.origin?.name, let originURL = detail.origin?.url,
           let attributedString = NSMutableAttributedString.hyperLink(hyperLinkText: originName, url: originURL) {
            infoText.append(NSMutableAttributedString(string: "\nOrigin: ", attributes: [.foregroundColor: UIColor.label, .font: UIFont.systemFont(ofSize: 18)]))
            infoText.append(attributedString)
        }
        
        if let locationName = detail.location?.name, let locationURL = detail.location?.url,
           let attributedString = NSMutableAttributedString.hyperLink(hyperLinkText: locationName, url: locationURL) {
            infoText.append(NSMutableAttributedString(string: "\nLocation: ", attributes: [.foregroundColor: UIColor.label, .font: UIFont.systemFont(ofSize: 18)]))
            infoText.append(attributedString)
        }
        
        if let episodes = detail.episode {
            var episodeNames: [String] = []
            episodes.forEach { episodeURL in
                if let lastValue = episodeURL.split(separator: "/").last {
                    episodeNames.append(String(lastValue))
                }
            }
            let episodesNamesString = episodeNames.joined(separator: ",")
            let displayString = episodesNamesString.isEmpty ? "-" : episodesNamesString
            infoText.append(NSMutableAttributedString(string: "\nEpisodes: \(displayString)", attributes: [.foregroundColor: UIColor.label, .font: UIFont.systemFont(ofSize: 18)]))
        }
        
        if let created = detail.created, !created.isEmpty {
            infoText.append(NSMutableAttributedString.dynamicText(text: "\nCreated: \(created)"))
        }
        
        if infoText.length != 0 {
            infoTextView.attributedText = infoText
        } else {
            resetInfo()
        }
    }
}
