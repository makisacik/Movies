//
//  ReviewCollectionViewCell.swift
//  Movies
//
//  Created by Mehmet Ali Kısacık on 17.08.2022.
//

import UIKit
import Kingfisher
class ReviewCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var authorAvatarImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = K.getBackgroundColor(interfaceStyle: traitCollection.userInterfaceStyle)
        authorAvatarImageView.layer.cornerRadius = 10
    }

    func setup(authorName: String?, review: String?, authorAvatarPath: String?) {
        authorNameLabel.text = authorName
        reviewLabel.text = review
        authorAvatarImageView.setAvatarWithPath(avatarPath: authorAvatarPath)
    }
}
