//
//  CastSearchTableViewCell.swift
//  Movies
//
//  Created by Mehmet Ali Kısacık on 19.08.2022.
//

import UIKit
import Kingfisher

class CastTableViewCell: UITableViewCell {

    @IBOutlet weak var castNameLabel: UILabel!
    @IBOutlet weak var castImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = K.getBackgroundColor(interfaceStyle: traitCollection.userInterfaceStyle)
    }

    func setup(castName: String?, castImagePath: String?) {
        if let castName = castName {
            castNameLabel.text = castName
        }
        castImageView.setImageWithPath(imagePath: castImagePath)
        self.selectionStyle = .none
        castImageView.layer.cornerRadius = 10
    }
}
