import UIKit
import Kingfisher

class MoviesTableViewCell: UITableViewCell {


    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!

    @IBOutlet weak var movieReleaseDateLabel: UILabel!

    @IBOutlet weak var movieRatingLabel: UILabel!
    @IBOutlet weak var movieFavouriteButton: UIButton!

    private var moviePosterPath: String?
    private var movieID: Int?
    private var movieTitle: String?
    private var movieReleaseDate : String?
    private var movieRating :Double?

    weak var delegate: MovieTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = K.getBackgroundColor(interfaceStyle: traitCollection.userInterfaceStyle)
        movieImage.layer.cornerRadius = 40
        selectionStyle = .none
    }

    func setup(title: String?,releaseDate: String?,rating: Double?, posterPath: String? ,id: Int?) {
        movieTitle = title
        movieReleaseDate = releaseDate
        movieRating = rating
        movieID = id
        moviePosterPath = posterPath
        movieTitleLabel.text = movieTitle
        movieReleaseDateLabel.text = "Release Date: ".localized() + (movieReleaseDate ?? "Unknown")

        if let movieRating = movieRating {
            movieRatingLabel.text = "Rating: ".localized() + String(describing: movieRating )
        } else {
            movieRatingLabel.text = "Rating: ".localized() + "Unknown"
        }

        movieImage.setImageWithPath(imagePath: moviePosterPath)

        if CoreDataManager.isFavoritedMovieExists(movieID: movieID ?? 0) {
            movieFavouriteButton.setImage(UIImage(systemName: "star.fill"),for: .normal)
        } else {
            movieFavouriteButton.setImage(UIImage(systemName: "star"),for: .normal)
        }
    }

    @IBAction func favoriteButtonPressed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.movieFavouriteButton.alpha = 0.2
            self.movieFavouriteButton.alpha = 1
        }

        if let movieID = movieID {
            if CoreDataManager.isFavoritedMovieExists(movieID: movieID) {
                CoreDataManager.deleteFavoritedMovie(movieID: movieID)
                movieFavouriteButton.setImage(UIImage(systemName: "star"),for: .normal)
                delegate?.favoriteButtonTapped()
                return
            } else {
                movieFavouriteButton.setImage(UIImage(systemName: "star.fill"),for: .normal)
                let favoritedMovie = FavoritedMovie(context: context)
                favoritedMovie.moviePosterPath = moviePosterPath
                favoritedMovie.movieID = Double(movieID)
                favoritedMovie.movieRating = movieRating ?? 0
                favoritedMovie.movieReleaseDate = movieReleaseDate
                favoritedMovie.movieTitle = movieTitle

                CoreDataManager.addFavoriedMovie(favoritedMovie: favoritedMovie)
            }
        }
    }

}
