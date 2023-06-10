//
//  DetailVCTests.swift
//  RickMortyCharactersTests
//
//  Created by MAC on 6/10/23.
//

import XCTest
import RxSwift

@testable import RickMortyCharacters

final class DetailVCTests: XCTestCase {
    // MARK: Properties
    private let correctImage = UIImage(systemName: "plus.square")!
    private let placholderImage = UIImage(systemName: "person.crop.square.fill")!
    private let placholderInfoText = "-"

    // MARK: Instance Properties
    var sut: DetailVC!
    var disposeBag: DisposeBag!
    
    // MARK: Test Lifecycle
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        sut = StoryboardScene.Detail.Screen.detail.getViewController() as? DetailVC
        
        sut.viewModel = MockDetailVCViewModel(apiClient: RickMortyRequest.shared)
        
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
        XCTAssertTrue(sut.avatarImageView.isDescendant(of: sut.view))
        XCTAssertTrue(sut.infoTextView.isDescendant(of: sut.view))
    }
    
    // MARK: Lifecycle Tests
    func testVC_whenViewDidLoad_initialStateIsCorrect() {
        // given
        sut.id = 1
        sut.loadViewIfNeeded()
        
        // when
        sut.viewDidLoad()
        
        // then
        XCTAssertNil(sut.viewModel.characterDetailFromAPI.value)
        XCTAssertEqual(sut.avatarImageView.image, placholderImage)
        XCTAssertEqual(sut.infoTextView.text, placholderInfoText)
    }
    
    func testVC_whenGetCharacterDetail_withDataResponse_stateIsCorrect() {
        // given
        let mockVM = (sut.viewModel as! MockDetailVCViewModel)
        mockVM.typeOfApiCall = .successful
        
        let promise = expectation(description: "Get Character Detail")
        
        sut.id = 1
        sut.loadViewIfNeeded()
        
        // when
        sut.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            promise.fulfill()
        }
        wait(for: [promise], timeout: 1.5)
        
        // then
        XCTAssertNotNil(sut.viewModel.characterDetailFromAPI.value)
        XCTAssertNotEqual(sut.avatarImageView.image, placholderImage)
        XCTAssertEqual(sut.avatarImageView.image, correctImage)
        XCTAssertFalse(sut.infoTextView.text.isEmpty)
    }
    
    func testVC_whenGetCharacterDetail_withError_stateIsCorrect() {
        // given
        (sut.viewModel as! MockDetailVCViewModel).typeOfApiCall = .error
        
        let promise = expectation(description: "Get Character Detail")
        
        sut.id = 1
        sut.loadViewIfNeeded()
        
        // when
        sut.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            promise.fulfill()
        }
        wait(for: [promise], timeout: 1)
        
        // then
        XCTAssertNil(sut.viewModel.characterDetailFromAPI.value)
        XCTAssertEqual(sut.avatarImageView.image, placholderImage)
        XCTAssertEqual(sut.infoTextView.text, placholderInfoText)
    }
}

