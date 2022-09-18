import UIKit
import Kingfisher

class MovieCastCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var castNameLabel: UILabel!
    @IBOutlet weak var characterNameLabel: UILabel!
    @IBOutlet weak var castImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = K.getBackgroundColor(interfaceStyle: traitCollection.userInterfaceStyle)
    }

    func setup(castName: String?, castImagePath: String?,characterName: String?) {
        if let castName = castName {
            castNameLabel.text = castName
        }
        if let characterName = characterName {
            characterNameLabel.text = "as ".localized() + characterName
        }
        castImageView.setCastImageWithPath(imagePath: castImagePath)
        castImageView.layer.cornerRadius = 10
    }
}
