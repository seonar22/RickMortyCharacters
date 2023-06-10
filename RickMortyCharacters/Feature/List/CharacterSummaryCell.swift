//
//  CharacterSummaryCell.swift
//  RickMortyCharacters
//
//  Created by MAC on 6/9/23.
//

import UIKit

class CharacterSummaryCell: UITableViewCell {
    // MARK: Outlet
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    // MARK: Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none
    }
    
    // MARK: UI
    func setupCell(summary: CharacterSummary) {
        nameLabel.text = summary.name
        statusLabel.text = summary.status?.displayString
    }
}
