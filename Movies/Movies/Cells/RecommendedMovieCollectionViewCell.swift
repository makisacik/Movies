import UIKit
import Kingfisher

class RecommendedMovieCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var movieImageView: UIImageView!

    func setup(moviePosterPath: String?) {
        movieImageView.setImageWithPath(imagePath: moviePosterPath)
        movieImageView.layer.cornerRadius = 10
    }
}
