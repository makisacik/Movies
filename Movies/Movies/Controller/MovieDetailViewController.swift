import UIKit
import Kingfisher

class MovieDetailViewController: UIViewController,UITextViewDelegate {

    @IBOutlet weak var movieCastCollectionView: UICollectionView! {
        didSet {
            movieCastCollectionView.delegate = self
            movieCastCollectionView.dataSource = self
            movieCastCollectionView.register(UINib(nibName: String.init(describing: MovieCastCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: String.init(describing: MovieCastCollectionViewCell.self))
            movieCastCollectionView.backgroundColor = K.getBackgroundColor(interfaceStyle: traitCollection.userInterfaceStyle)
        }
    }

    @IBOutlet weak var recommendationsCollectionView: UICollectionView! {
        didSet {
            recommendationsCollectionView.delegate = self
            recommendationsCollectionView.dataSource = self
            recommendationsCollectionView.backgroundColor = K.getBackgroundColor(interfaceStyle: traitCollection.userInterfaceStyle)
            recommendationsCollectionView.register(UINib(nibName: String.init(describing: RecommendedMovieCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: String.init(describing: RecommendedMovieCollectionViewCell.self))
        }
    }

    @IBOutlet weak var reviewsCollectionView: UICollectionView! {
        didSet {
            reviewsCollectionView.delegate = self
            reviewsCollectionView.dataSource = self
            reviewsCollectionView.register(UINib(nibName: String.init(describing: ReviewCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: String.init(describing: ReviewCollectionViewCell.self))
            reviewsCollectionView.backgroundColor = K.getBackgroundColor(interfaceStyle: traitCollection.userInterfaceStyle)
        }
    }

    @IBOutlet weak var favoriteButton: UIButton! {
        didSet {
            if CoreDataManager.isFavoritedMovieExists(movieID: movieID ?? 0) {
                favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            } else {
                favoriteButton.setImage(UIImage(systemName: "star"),for: .normal)
            }
        }
    }

    @IBOutlet weak var movieWebsiteButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var originalTitleLabel: UILabel!
    @IBOutlet weak var originalTitleTextLabel: UILabel!
    @IBOutlet weak var originalLanguageLabel: UILabel!
    @IBOutlet weak var originalLanguageTextLabel: UILabel!
    @IBOutlet weak var runtimeLabel: UILabel!
    @IBOutlet weak var runtimeTextLabel: UILabel!
    @IBOutlet weak var budgetLabel: UILabel!
    @IBOutlet weak var budgetTextLabel: UILabel!
    @IBOutlet weak var revenueLabel: UILabel!
    @IBOutlet weak var revenueTextLabel: UILabel!
    @IBOutlet weak var voteCountLabel: UILabel!
    @IBOutlet weak var voteCountTextLabel: UILabel!
    @IBOutlet weak var voteAverageLabel: UILabel!
    @IBOutlet weak var voteAverageTextLabel: UILabel!
    @IBOutlet weak var productionCompaniesLabel: UILabel!
    @IBOutlet weak var productionCompaniesTextLabel: UILabel!
    @IBOutlet weak var productionCountriesLabel: UILabel!
    @IBOutlet weak var productionCountriesTextLabel: UILabel!
    @IBOutlet weak var imdbIdLabel: UILabel!
    @IBOutlet weak var imdbIdLabelText: UILabel!
    @IBOutlet weak var overviewTitleLabel: UILabel!
    @IBOutlet weak var castsTitleLabel: UILabel!
    @IBOutlet weak var recommendationsTitleLabel: UILabel!
    @IBOutlet weak var informationsLabel: UILabel!
    @IBOutlet weak var reviewTitleLabel: UILabel!
    @IBOutlet weak var reviewTitleLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var reviewsCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var castsTitleLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var castCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var recommendationsCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var recommendationsTitleLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var movieWebsiteButtonHeight: NSLayoutConstraint!

    private var castArray: [RecommendedCast] = []
    private var recommendationMoviesArray: [Movie] = []
    private var reviewsArray: [Review] = []
    private var movieWebsiteURL: URL?
    private var moviePosterPath: String?
    private var movieRating: String?
    private var loader: UIAlertController?
    private let loadingDispatchGroup = DispatchGroup()
    var movieID: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        makeAPICalls()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadingDispatchGroup.notify(queue: .main) {
            self.stopLoader(loader: self.loader!)
            self.scrollView.isHidden = false
        }

        if let movieID = movieID {
            if CoreDataManager.isFavoritedMovieExists(movieID: movieID) {
                favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            } else {
                favoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
            }
        }
    }

    private func setup() {
        view.backgroundColor = K.getBackgroundColor(interfaceStyle: traitCollection.userInterfaceStyle)
        scrollView.isHidden = true
        loader = self.loader()
        originalTitleLabel.text = "Original Title:".localized()
        originalLanguageLabel.text = "Original Language:".localized()
        runtimeLabel.text = "Runtime:".localized()
        budgetLabel.text = "Budget:".localized()
        revenueLabel.text = "Revenue:".localized()
        voteCountLabel.text = "Vote Count:".localized()
        voteAverageLabel.text = "Vote Average:".localized()
        imdbIdLabel.text  = "IMDB ID:".localized()
        productionCompaniesLabel.text = "Production Companies".localized()
        productionCountriesLabel.text = "Production Countries".localized()
        movieWebsiteButton.setTitle("Link For Movie Website".localized(), for: .normal)
        overviewTitleLabel.text = "Overview".localized()
        castsTitleLabel.text = "Casts".localized()
        informationsLabel.text = "Informations".localized()
    }

//MARK: - API Call Functions
    
    private func makeAPICalls() {
        getMovieDetails()
        getCasts()
        getRecommendedMovies()
        getReviews()
    }

    private func getCasts() {
        if let movieID = movieID {
            loadingDispatchGroup.enter()
            Network.shared.getRecommendedCasts(completion: { results in
                switch results{
                case .success(let result):
                    if let casts = result.cast{
                        self.castArray = casts
                    }
                    self.movieCastCollectionView.reloadData()
                    self.loadingDispatchGroup.leave()

                case .failure(let err):
                    print(err)
                }
            }, movieId: movieID)
        }
    }
    
    private func getMovieDetails() {
        Network.shared.getMovieDetails(completion: { result in
            self.loadingDispatchGroup.enter()
            switch result{
            case .success(let movie):
                self.movieID = movie.id ?? 0
                self.titleLabel.text = movie.title ?? ""
                self.backgroundImageView.setImageWithPath(imagePath: K.tmdbURLString + (movie.backdropPath ?? ""))
                
                if let overviewText =  movie.overview {
                    if overviewText == "" {
                        self.overviewLabel.text = "No Overview Text Available".localized()
                    } else {
                        self.overviewLabel.text = overviewText
                    }
                } else {
                    self.overviewLabel.text = "No Overview Text Available".localized()
                }
                
                var genres: [String] = []
                for genre in movie.genres ?? [] {
                    if let genreName = genre.name {
                        genres.append(genreName)
                    }
                }
                self.genresLabel.text = "Genres: ".localized() + genres.joined(separator: ", ")

                var productionCountries: [String] = []
                for country in movie.productionCountries ?? [] {
                    productionCountries.append(country.name?.localized() ?? "")
                }
                self.productionCountriesTextLabel.text = productionCountries.joined(separator: ",")
                
                var productionCompanies: [String] = []
                for company in movie.productionCompanies ?? [] {
                    productionCompanies.append(company.name ?? "")
                }
                self.productionCompaniesTextLabel.text = productionCompanies.joined(separator: ",")
                self.releaseDateLabel.text = movie.releaseDate ?? "Unknown".localized()

                self.originalLanguageTextLabel.text = Locale(identifier: Locale.preferredLanguages.first ?? "en").localizedString(forLanguageCode: movie.originalLanguage ?? "" ) ?? "Unknown".localized()

                self.originalTitleTextLabel.text = movie.originalTitle ?? "Unknown".localized()
                
                self.imdbIdLabelText.text = movie.imdbID
                
                if let runtime = movie.runtime {
                    self.runtimeTextLabel.text = String(runtime) + " minutes".localized()
                } else {
                    self.runtimeTextLabel.text = "Unknown".localized()
                }
                
                if let budget = movie.budget{
                    if budget == 0 {
                        self.budgetTextLabel.text = "Unknown".localized()
                    } else {
                        self.budgetTextLabel.text = String(budget)+"$"
                    }
                } else {
                    self.budgetTextLabel.text = "Unknown".localized()
                }
                
                if let revenue = movie.revenue, revenue > 0 {
                    self.revenueTextLabel.text = String(revenue)+"$"
                } else {
                    self.revenueTextLabel.text = "Unknown".localized()
                }
                
                if let voteCount = movie.voteCount {
                    self.voteCountTextLabel.text = String(voteCount)
                } else {
                    self.voteAverageTextLabel.text = "Unknown".localized()
                }
                
                if let voteAverage = movie.voteAverage {
                    self.voteAverageTextLabel.text = String(voteAverage)
                } else {
                    self.voteAverageTextLabel.text = "Unknown".localized()
                }
                
                if let homepageLink = movie.homepage {
                    self.movieWebsiteURL = URL(string: homepageLink)
                }
                self.recommendationsTitleLabel.text = "Recommendations".localized()
                self.castsTitleLabel.text = "Casts".localized()
                self.loadingDispatchGroup.leave()
            case .failure(let err):
                print(err)
                return
            }
        }, movieId: movieID ?? 0)
    }
    
    private func getRecommendedMovies() {
        Network.shared.getRecommendationMovies(completion: { result in
            self.loadingDispatchGroup.enter()
            switch result {
            case .success(let movies):
                if let movs = movies.results {
                    self.recommendationMoviesArray = movs
                    self.recommendationsCollectionView.reloadData()
                }
                self.loadingDispatchGroup.leave()
            case .failure(let err):
                print(err)
                return
            }
        }, movieID: movieID ?? 0)
    }
    
    private func getReviews() {
        Network.shared.getReviews(completion: { result in
            self.loadingDispatchGroup.enter()
            switch result {
            case .success(let reviews):
                if let reviews = reviews.results {
                    if reviews.count == 0 {
                        self.reviewTitleLabelHeight.constant = 0
                        self.reviewsCollectionViewHeight.constant = 0
                    } else {
                        self.reviewsArray = reviews
                        self.reviewsCollectionView.reloadData()
                    }
                }
                self.loadingDispatchGroup.leave()
            case .failure(_):
                self.reviewTitleLabelHeight.constant = 0
                self.reviewsCollectionViewHeight.constant = 0
                return
            }
        }, movieId: movieID ?? 0)
    }

    //MARK: - Button Actions

        @IBAction func favoriteButtonTapped(_ sender: UIButton) {
            UIView.animate(withDuration: 0.3) {
                sender.alpha = 0.2
                sender.alpha = 1
            }

            if let movieID = movieID {
                if CoreDataManager.isFavoritedMovieExists(movieID: movieID) {
                    favoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
                    CoreDataManager.deleteFavoritedMovie(movieID: movieID)
                } else {
                    favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
                    Network.shared.getMovieDetails(completion: { result in
                        switch result {
                        case .success(let movie):
                            let favoritedMovie = FavoritedMovie(context: context)
                            favoritedMovie.moviePosterPath = movie.posterPath
                            favoritedMovie.movieID = Double(movieID)
                            favoritedMovie.movieRating = movie.voteAverage ?? 0
                            favoritedMovie.movieReleaseDate = movie.releaseDate
                            favoritedMovie.movieTitle = movie.title
                            CoreDataManager.addFavoriedMovie(favoritedMovie: favoritedMovie)
                        case .failure(let err):
                            print(err)
                            return
                        }
                    }, movieId: movieID )
                }
            }
        }

        @IBAction func movieWebsiteButtonClicked(_ sender: UIButton) {
            if let homePageLink = movieWebsiteURL{
                UIApplication.shared.open(homePageLink)
            }
        }
}

//MARK: - Collection View Functions

extension MovieDetailViewController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == movieCastCollectionView {
            guard let castDetailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: String(describing: CastDetailViewController.self)) as? CastDetailViewController else {
                return
            }
            castDetailViewController.castID = castArray[indexPath.row].id
            castDetailViewController.modalPresentationStyle = .overFullScreen
            self.navigationController?.pushViewController(castDetailViewController, animated: true)
        } else if collectionView == recommendationsCollectionView {
            guard let movieDetailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: String(describing: MovieDetailViewController.self)) as? MovieDetailViewController else {
                return
            }
            
            movieDetailViewController.movieID = recommendationMoviesArray[indexPath.row].id ?? 0
            movieDetailViewController.modalPresentationStyle = .overFullScreen
            self.navigationController?.pushViewController(movieDetailViewController, animated: true)
        } else {
            guard let reviewDetailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: String(describing: ReviewDetailViewController.self)) as? ReviewDetailViewController else {
                return
            }

            reviewDetailViewController.review = reviewsArray[indexPath.row]
            self.present(reviewDetailViewController, animated: true)

        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == movieCastCollectionView {
            if castArray.count  == 0 {
                castCollectionViewHeight.constant = 0
                castsTitleLabelHeight.constant = 0
            } else {
                castCollectionViewHeight.constant = 370
                castsTitleLabelHeight.constant = 30
            }
            return castArray.count
        } else if collectionView == recommendationsCollectionView {
            if recommendationMoviesArray.count  == 0 {
                recommendationsCollectionViewHeight.constant = 0
                recommendationsTitleLabelHeight.constant = 0
            } else {
                recommendationsCollectionViewHeight.constant = 250
                recommendationsTitleLabelHeight.constant = 30
            }
            return recommendationMoviesArray.count
        }
        else {
            return reviewsArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == movieCastCollectionView {
            guard let cell = movieCastCollectionView.dequeueReusableCell(withReuseIdentifier: String.init(describing: MovieCastCollectionViewCell.self), for: indexPath) as? MovieCastCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.setup(castName: castArray[indexPath.row].name, castImagePath: castArray[indexPath.row].profilePath,characterName: castArray[indexPath.row].character)
            
            return cell
        } else if collectionView == recommendationsCollectionView {
            guard let cell = recommendationsCollectionView.dequeueReusableCell(withReuseIdentifier: String.init(describing: RecommendedMovieCollectionViewCell.self), for: indexPath) as? RecommendedMovieCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            cell.setup(moviePosterPath: recommendationMoviesArray[indexPath.row].posterPath)
            cell.backgroundColor = K.getBackgroundColor(interfaceStyle: traitCollection.userInterfaceStyle)

            return cell
        } else {
            guard let cell = reviewsCollectionView.dequeueReusableCell(withReuseIdentifier: String.init(describing: ReviewCollectionViewCell.self), for: indexPath) as? ReviewCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.setup(authorName: reviewsArray[indexPath.row].author, review: reviewsArray[indexPath.row].content, authorAvatarPath: reviewsArray[indexPath.row].authorDetails?.avatarPath)
            cell.backgroundColor = K.getBackgroundColor(interfaceStyle: traitCollection.userInterfaceStyle)

            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == movieCastCollectionView {
            return CGSize(width: 160, height: 350)
        } else if collectionView == recommendationsCollectionView {
            return CGSize(width: 160, height: 250)
        } else {
            return CGSize(width: 260, height: 195)
        }
    }
}

