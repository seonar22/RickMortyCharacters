//
//  NSMutableAttributedString+hyperlink.swift
//  RickMortyCharacters
//
//  Created by MAC on 6/10/23.
//

import UIKit

extension NSMutableAttributedString {
    static func hyperLink(hyperLinkText: String?, url: String?) -> NSMutableAttributedString? {
        if let hyperLinkText = hyperLinkText, let url = url, !url.isEmpty {
            let attributedString = NSMutableAttributedString(string: hyperLinkText)
            let nsText = hyperLinkText as NSString
            let textRange = NSMakeRange(0, nsText.length)
            let url = URL(string: url)!
            attributedString.setAttributes([.link: url, .font: UIFont.systemFont(ofSize: 18)], range: textRange)
            return attributedString
        } else if let hyperLinkText = hyperLinkText {
            let attributedString = NSMutableAttributedString(string: hyperLinkText,
                                                             attributes: [.foregroundColor: UIColor.label, .font: UIFont.systemFont(ofSize: 18)])
            return attributedString
        }
        
        return nil
    }
    
    static func attributedText(text: String, attributes: [NSAttributedString.Key : Any]?) -> NSMutableAttributedString {
        return NSMutableAttributedString(string: text, attributes: attributes)
    }
    
    static func dynamicText(text: String) -> NSMutableAttributedString {
        return NSMutableAttributedString(string: text, attributes: [.foregroundColor: UIColor.label, .font: UIFont.systemFont(ofSize: 18)])
    }
}


