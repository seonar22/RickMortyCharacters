//
//  StoryboardScene.swift
//  RickMortyCharacters
//
//  Created by MAC on 6/9/23.
//

import UIKit

enum StoryboardScene: String {
    case main
    
    var nibName: String {
        switch self {
        case .main:
            return "Main"
        }
    }
    
    struct Character {
        static let storyboard = StoryboardScene.main.getStoryBoard()
        public enum Screen: String {
            case list
            case search
            case detail
            
            var nibName: String {
                switch self {
                case .list:
                    return "CharacterListVC"
                case .search:
                    return "SearchVC"
                case .detail:
                    return "DetailVC"
                }
            }
            
            func getViewController() -> UIViewController {
                return storyboard.instantiateViewController(withIdentifier: self.nibName)
            }
        }
    }
    
    func instantiateInitialViewController() -> UIViewController? {
        let storyboard = UIStoryboard(name: self.nibName, bundle: nil)
        return storyboard.instantiateInitialViewController()
    }
    
    func getStoryBoard() -> UIStoryboard {
        return UIStoryboard(name: self.nibName, bundle: nil)
    }
}
