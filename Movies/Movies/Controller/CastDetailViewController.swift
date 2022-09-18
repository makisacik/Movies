import UIKit
import Kingfisher

class CastDetailViewController: UIViewController {

    @IBOutlet weak var knownForMoviesCollectionView: UICollectionView! {
        didSet {
            knownForMoviesCollectionView.delegate = self
            knownForMoviesCollectionView.dataSource = self
            knownForMoviesCollectionView.backgroundColor = K.getBackgroundColor(interfaceStyle: traitCollection.userInterfaceStyle)
            knownForMoviesCollectionView.register(UINib(nibName: String.init(describing: KnownForMovieCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: String.init(describing: KnownForMovieCollectionViewCell.self))
        }
    }

    @IBOutlet weak var castNameLabel: UILabel!
    @IBOutlet weak var castImageView: UIImageView!
    @IBOutlet weak var informationsTitleLabel: UILabel!
    @IBOutlet weak var placeOfBirthLabel: UILabel!
    @IBOutlet weak var placeOfBirthTextLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var birthdayTextLabel: UILabel!
    @IBOutlet weak var deathdayLabel: UILabel!
    @IBOutlet weak var deathdayTextLabel: UILabel!
    @IBOutlet weak var deathdayStackView: UIStackView!
    @IBOutlet weak var imdbIDLabel: UILabel!
    @IBOutlet weak var imdbIDTextLabel: UILabel!
    @IBOutlet weak var biographyLabel: UILabel!
    @IBOutlet weak var biographyTextLabel: UILabel!
    @IBOutlet weak var knownForLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!

    var knownForMovies: [Movie]?
    var castID: Int?
    var loader: UIAlertController?
    let loadingDispatchGroup = DispatchGroup()

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
    }

    private func setup() {
        view.backgroundColor = K.getBackgroundColor(interfaceStyle: traitCollection.userInterfaceStyle)
        scrollView.isHidden = true
        loader = self.loader()

        informationsTitleLabel.text =  "Informations".localized()
        placeOfBirthLabel.text = "Place of Birth: "
        birthdayLabel.text = "Birth Date: ".localized()
        imdbIDLabel.text = "IMDB Id: ".localized()
        deathdayLabel.text = "Death Date".localized()
        biographyLabel.text = "Biography".localized()
        knownForLabel.text = "Known For".localized()
        castImageView.layer.cornerRadius = 20
        castImageView.layer.masksToBounds = true
    }

//MARK: - API Call Functions

    private func makeAPICalls() {
        getCastMovies(castID: castID)
        getCastDetail(castID: castID)
    }

    private func getCastMovies(castID: Int?) {
        loadingDispatchGroup.enter()
        if let castID = castID {
            Network.shared.getCastMovies(completion: { [self] results in
                switch results {
                case .success(let result):
                    knownForMovies = result.cast
                    knownForMoviesCollectionView.reloadData()
                case .failure(let err):
                    print(err)
                }
                self.loadingDispatchGroup.leave()
            }, castID: castID)
        }
    }

    private func getCastDetail(castID: Int?) {
        loadingDispatchGroup.enter()
        if let castID = castID {
            Network.shared.getCastDetail(completion: { [self] results in
                switch results{
                case .success(let result):
                    castNameLabel.text = result.name
                    if let profilePath = result.profilePath {
                        if profilePath == "" {
                            castImageView.image = UIImage(named: "QuestionMark")
                        } else {
                            castImageView.kf.setImage(with: URL(string: K.tmdbURLString + profilePath))
                        }
                    } else {
                        castImageView.image = UIImage(named: "QuestionMark")
                    }

                    if let placeOfBirth = result.placeOfBirth {
                        if placeOfBirth == "" {
                            placeOfBirthTextLabel.isHidden = true
                        } else {
                            placeOfBirthTextLabel.text = placeOfBirth
                        }
                    } else {
                        placeOfBirthTextLabel.isHidden = true
                    }

                    birthdayTextLabel.text = result.birthday ?? "Unknown".localized()

                    if let deathday = result.deathday {
                        deathdayTextLabel.text = deathday
                    } else {
                        deathdayStackView.removeFromSuperview()
                    }

                    if let biography = result.biography {
                        if biography == "" {
                            biographyLabel.isHidden = true
                        } else {
                            biographyTextLabel.text = biography
                        }
                    } else {
                        biographyLabel.isHidden = true
                    }

                    imdbIDTextLabel.text = result.imdbID

                case .failure(let err):
                    print(err)
                }
                self.loadingDispatchGroup.leave()
            }, castID: castID)
        }
    }

}

//MARK: - Collection View Functions

extension CastDetailViewController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return knownForMovies?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = knownForMoviesCollectionView.dequeueReusableCell(withReuseIdentifier: String.init(describing: KnownForMovieCollectionViewCell.self), for: indexPath) as? KnownForMovieCollectionViewCell else {
            return UICollectionViewCell()
        }

        if let knownForMovies = knownForMovies {
            cell.setup(moviePosterPath: knownForMovies[indexPath.row].posterPath, movieName: knownForMovies[indexPath.row].title)
            cell.backgroundColor = K.getBackgroundColor(interfaceStyle: traitCollection.userInterfaceStyle)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let movieDetailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: String(describing: MovieDetailViewController.self)) as? MovieDetailViewController else {
            return
        }

        if let knownForMovies = knownForMovies {
            movieDetailViewController.movieID = knownForMovies[indexPath.row].id ?? 0
            movieDetailViewController.modalPresentationStyle = .overFullScreen
            self.navigationController?.pushViewController(movieDetailViewController, animated: true)
        }

    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: 160, height: 305)

    }

}
