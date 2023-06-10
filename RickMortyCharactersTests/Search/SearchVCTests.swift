//
//  SearchVCTests.swift
//  RickMortyCharactersTests
//
//  Created by MAC on 6/10/23.
//

import XCTest
import RxSwift

@testable import RickMortyCharacters

final class SearchVCTests: XCTestCase {
    // MARK: Instance Properties
    var sut: SearchVC!
    var disposeBag: DisposeBag!
    
    // MARK: Test Lifecycle
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        sut = StoryboardScene.Character.Screen.search.getViewController() as? SearchVC
        
        sut.viewModel = MockSearchVCViewModel(apiClient: RickMortyRequest.shared)
        
        disposeBag = DisposeBag()
    }
    
    override func tearDownWithError() throws {
        disposeBag = nil
        sut = nil
        try super.tearDownWithError()
    }
    
    // MARK: Outlet Tests
    func testVC_outlets_areConnected() {
        // given
        sut.loadViewIfNeeded()
        
        // when
        sut.viewDidLoad()
        
        // then
        XCTAssertTrue(sut.tableView.isDescendant(of: sut.view))
        XCTAssertTrue(sut.previousButton.isDescendant(of: sut.view))
        XCTAssertTrue(sut.nextButton.isDescendant(of: sut.view))
    }
    
    // MARK: Lifecycle Tests
    func testVC_whenViewDidLoad_initialStateIsCorrect() {
        // given
        sut.loadViewIfNeeded()
        
        // when
        sut.viewDidLoad()
        
        // then
        XCTAssertTrue(sut.viewModel.characters.isEmpty)
    }
    
    func testVC_whenGetCharacterList_withDataResponse_stateIsCorrect() {
        // given
        (sut.viewModel as! MockSearchVCViewModel).typeOfApiCall = .successful
        
        let promise = expectation(description: "Get Character List")
        sut.loadViewIfNeeded()
        
        // when
        sut.viewDidLoad()
        sut.viewModel.search(searchText: "example")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            promise.fulfill()
        }
        wait(for: [promise], timeout: 1.5)
        
        // then
        XCTAssertFalse(sut.viewModel.characters.isEmpty)
    }
    
    func testVC_whenGetCharacterList_withError_stateIsCorrect() {
        // given
        (sut.viewModel as! MockSearchVCViewModel).typeOfApiCall = .error
        
        let promise = expectation(description: "Get Character List")
        sut.loadViewIfNeeded()
        
        // when
        sut.viewDidLoad()
        sut.textField.text = "example"
        sut.textField.rx.text.onNext("example")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            promise.fulfill()
        }
        wait(for: [promise], timeout: 1)
        
        // then
        XCTAssertTrue(sut.viewModel.characters.isEmpty)
    }
}

