//
//  SearchVC.swift
//  RickMortyCharacters
//
//  Created by MAC on 6/9/23.
//

import UIKit
import RxSwift

// - Search page using a name to search debound 1.5 sec and then search / show list on page / 10 item per page
class SearchVC: UIViewController {
    // MARK: Outlet
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    // MARK: Properties
    private(set) lazy var previousButttonTap = previousButton.rx
        .tap
        .throttle(.milliseconds(700), scheduler: MainScheduler.instance)
        .share()
    private(set) lazy var nextButttonTap = nextButton.rx
        .tap
        .throttle(.milliseconds(700), scheduler: MainScheduler.instance)
        .share()
    
    private let viewModel = SearchVCVIewModel(apiClient: RickMortyRequest.shared)
    private let disposeBag = DisposeBag()
        
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "CharacterSummaryCell", bundle: nil), forCellReuseIdentifier: "CharacterSummaryCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        initialUI()
        bind()
    }
    
    private func bind() {
        viewModel.charactersFromAPI.asDriver()
            .drive(onNext: {[weak self] _ in
                guard let self = self else { return }
                
                self.reloadUI()
            })
            .disposed(by: disposeBag)
        viewModel.error.asDriver(onErrorJustReturn: ())
            .drive(onNext: {[weak self] _ in
                guard let self = self else { return }
                
                AlertView.showApiFailureAlert(in: self)
            })
            .disposed(by: disposeBag)
        
        textField.rx.text
            .orEmpty
            .debounce(.milliseconds(1500), scheduler: MainScheduler.instance)
            .filter({[weak self] in
                $0 != self?.viewModel.searchText
            })
            .subscribe(onNext: { [weak self] text in
                guard !text.isEmpty else { return }
                
                self?.viewModel.searchText = text
                self?.viewModel.pagePer10.accept(0)
                self?.viewModel.page.accept(1)
                self?.viewModel.search(searchText: text)
                self?.viewModel.hasNextForApiCall.accept(false)
            })
            .disposed(by: disposeBag)
        
        previousButttonTap
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else { return }
                
                guard !self.viewModel.charactersFromAPI.value.isEmpty else {
                    self.viewModel.search(searchText: self.textField.text ?? "")
                    return
                }
                
                let currentPagePer10Index = self.viewModel.pagePer10.value
                guard currentPagePer10Index > 0 else { return }
                self.viewModel.pagePer10.accept(currentPagePer10Index - 1)
                self.reloadUI()
            })
            .disposed(by: disposeBag)
        nextButttonTap
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else { return }
                guard !self.viewModel.isLoading.value else { return }
                
                let currentPagePer10Index = self.viewModel.pagePer10.value
                guard currentPagePer10Index != (self.viewModel.charactersFromAPIPer10.value.count - 1) else {
                    let currentPage = self.viewModel.page.value
                    self.viewModel.page.accept(currentPage + 1)
                    self.viewModel.pagePer10.accept(currentPagePer10Index + 1)
                    self.viewModel.search(searchText: self.textField.text ?? "")
                    return
                }
                
                self.viewModel.pagePer10.accept(currentPagePer10Index + 1)
                self.reloadUI()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: UI
    private func reloadUI() {
        tableView.reloadData()
        updateButtonUI()
    }
    
    private func updateButtonUI() {
        let hasPrevious = viewModel.pagePer10.value != 0
        previousButton.isEnabled = hasPrevious ? true : false
        previousButton.alpha = hasPrevious ? 1 : 0.7
        
        let hasNext = viewModel.charactersFromAPI.value.count > 0 && (viewModel.pagePer10.value != (viewModel.charactersFromAPIPer10.value.count - 1) || viewModel.hasNextForApiCall.value)
        nextButton.isEnabled = hasNext ? true : false
        nextButton.alpha = hasNext ? 1 : 0.7
    }
    
    private func initialUI() {
        previousButton.setTitle("Previous", for: .normal)
        nextButton.setTitle("Next", for: .normal)
    }
    
    // MARK: Navigation
    private func moveToDetail(_ summary: CharacterSummary) {
        let vc = StoryboardScene.Detail.Screen.detail.getViewController() as! DetailVC
        vc.id = summary.id
        navigationController?.pushViewController(vc, animated: true)
    }
}
// MARK: - UITableViewDelegate, UITableViewDataSource
extension SearchVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.characters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CharacterSummaryCell.self), for: indexPath) as! CharacterSummaryCell
        let summary = viewModel.characters[indexPath.row]
        cell.setupCell(summary: summary)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let summary = viewModel.characters[indexPath.row]
        moveToDetail(summary)
    }
}
