import UIKit

protocol MovieTableViewCellDelegate: AnyObject{
    func favoriteButtonTapped()
}

class FavoritedMoviesViewController: UIViewController {

    @IBOutlet weak var favoritedMoviesTableView: UITableView! {
        didSet {
            favoritedMoviesTableView.delegate = self
            favoritedMoviesTableView.dataSource = self
            favoritedMoviesTableView.backgroundColor = K.getBackgroundColor(interfaceStyle: traitCollection.userInterfaceStyle)
            favoritedMoviesTableView.register(UINib(nibName: String.init(describing: MoviesTableViewCell.self), bundle: nil), forCellReuseIdentifier: String.init(describing: MoviesTableViewCell.self))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = K.getBackgroundColor(interfaceStyle: traitCollection.userInterfaceStyle)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        CoreDataManager.loadFavoriteMovies()
        favoritedMoviesTableView.reloadData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }
}

//MARK: - Favorited Movies Table View Functions

extension FavoritedMoviesViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CoreDataManager.favoritedMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = favoritedMoviesTableView.dequeueReusableCell(withIdentifier: String.init(describing: MoviesTableViewCell.self), for: indexPath) as? MoviesTableViewCell else {
            return UITableViewCell()
        }
        
        cell.setup(title: CoreDataManager.favoritedMovies[indexPath.row].movieTitle, releaseDate: CoreDataManager.favoritedMovies[indexPath.row].movieReleaseDate, rating: CoreDataManager.favoritedMovies[indexPath.row].movieRating, posterPath: CoreDataManager.favoritedMovies[indexPath.row].moviePosterPath, id: Int(CoreDataManager.favoritedMovies[indexPath.row].movieID))
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let movieDetailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: String(describing: MovieDetailViewController.self)) as? MovieDetailViewController else {
            return
        }
        
        movieDetailViewController.movieID = Int(CoreDataManager.favoritedMovies[indexPath.row].movieID)
        movieDetailViewController.modalPresentationStyle = .overFullScreen
        self.navigationController?.pushViewController(movieDetailViewController, animated: true)
    }
}

//MARK: - MovieTableViewCellDelegate Functions

extension FavoritedMoviesViewController: MovieTableViewCellDelegate{
    func favoriteButtonTapped() {
        self.favoritedMoviesTableView.reloadData()
    }
}
