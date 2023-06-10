//
//  AlertView.swift
//  RickMortyCharacters
//
//  Created by MAC on 6/10/23.
//

import UIKit

class AlertView {
    class func showAlert(_ title: String?, message: String?, in viewController: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let alertDismissAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(alertDismissAction)
        
        DispatchQueue.main.async {
            viewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    class func showApiFailureAlert(in viewController: UIViewController) {
        showAlert("Cannot get data.", message: "Please try again later.", in: viewController)
    }
}
