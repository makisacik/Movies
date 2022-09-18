import UIKit

class MoviesViewController: UIViewController, UITabBarDelegate {

    
    @IBOutlet weak var moviesTableView: UITableView! {
        didSet {
            moviesTableView.dataSource = self
            moviesTableView.delegate = self
            moviesTableView.register(UINib(nibName: String.init(describing: MoviesTableViewCell.self), bundle: nil), forCellReuseIdentifier: String.init(describing: MoviesTableViewCell.self))
        }
    }

    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
            searchBar.placeholder = "Search Movies Here".localized()
        }
    }

    @IBOutlet weak var searchBarCancelButton: UIButton!
    @IBOutlet weak var searchBarCancelButtonWidth: NSLayoutConstraint!
    
    private var movieArray: [Movie]?
    private var lastPage = 1
    private var movieApiCallType: Network.MovieApiCallType = .populars
    private var tap = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Network.shared.isConnected {
            moviesTableView.reloadData()
        } else {
            searchBar.text = "No Connection".localized()
        }
    }
    
    private func setup() {
        setNeedsStatusBarAppearanceUpdate()
        CoreDataManager.loadFavoriteMovies()

        view.backgroundColor = K.getBackgroundColor(interfaceStyle: traitCollection.userInterfaceStyle)
        tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        searchBarCancelButton.setTitle("Cancel".localized(), for: .normal)

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)

        getMovieData()
    }

    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismissKeyboard()
        searchBar.text = ""
        searchBarCancelButtonWidth.constant = 0
        UIView.animate(withDuration: 0.3,delay: 0,options: .curveEaseOut) {
            self.view.layoutIfNeeded()
        }
        scrollToTop()
        refreshDataToPopularMovies()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    //MARK: - API Call Functions

    private func getMovieData(searchText: String = "") {
        switch self.movieApiCallType {
        case .populars:
            Network.shared.getPopularMovies(completion: { result in
                switch result{
                case .success(let movies):
                    if let movs = movies.results {
                        if let _ = self.movieArray {
                            self.movieArray?.append(contentsOf: movs)
                            self.searchBar.text = ""
                            self.moviesTableView.reloadData()
                        } else {
                            if movs.isEmpty {
                                self.searchBar.text = "Network Error".localized()
                            }
                            self.movieArray = movs
                            self.moviesTableView.reloadData()
                            self.scrollToTop()
                        }
                    }
                case .failure(_):
                    self.movieArray = []
                    self.searchBar.text = "Network Error".localized()
                }
            }, page: lastPage)
        case .search:
            Network.shared.getSearchMovies(completion: { result in
                switch result{
                case .success(let movies):
                    if let movs = movies.results {
                        if let _ = self.movieArray {
                            self.movieArray?.append(contentsOf: movs)
                            self.searchBar.text = ""
                            self.moviesTableView.reloadData()
                        } else {
                            if movs.isEmpty {
                                self.searchBar.text = "Movie couldn't found".localized()
                            }
                            self.movieArray = movs
                            self.moviesTableView.reloadData()
                            self.scrollToTop()
                        }
                    }
                case .failure(_):
                    self.movieArray = []
                    self.searchBar.text = "Movie couldn't found!".localized()
                }
            }, page: lastPage, searchText: searchText)
        default:
            break
        }
    }

    private func refreshDataToPopularMovies() {
        movieApiCallType = .populars
        lastPage = 1
        movieArray = nil
        getMovieData()
    }

//MARK: - Keyboard Functions

    @objc private func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }

    @objc private func keyboardWillShow() {
        view.addGestureRecognizer(tap)
    }

    @objc private func keyboardDidHide() {
        view.removeGestureRecognizer(tap)
        if movieApiCallType == .populars{
            searchBarCancelButtonWidth.constant = 0
            UIView.animate(withDuration: 0.3,delay: 0,options: .curveEaseOut) {
                self.view.layoutIfNeeded()
            }
        }
    }
}

//MARK: - Table View Functions

extension MoviesViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = moviesTableView.dequeueReusableCell(withIdentifier: String.init(describing: MoviesTableViewCell.self), for: indexPath) as? MoviesTableViewCell else {
            return UITableViewCell()
        }
        
        if let movs = movieArray {
            cell.setup(title: movs[indexPath.row].title, releaseDate: movs[indexPath.row].releaseDate, rating: movs[indexPath.row].voteAverage, posterPath: movs[indexPath.row].posterPath, id: movs[indexPath.row].id)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let movs = movieArray {
            if indexPath.row == movs.count - 1{
                lastPage += 1
                getMovieData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let movieDetailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: String(describing: MovieDetailViewController.self)) as? MovieDetailViewController else {
            return
        }
        if let movs = movieArray {
            movieDetailViewController.movieID = movs[indexPath.row].id ?? 0
        }
        
        movieDetailViewController.modalPresentationStyle = .overFullScreen
        self.navigationController?.pushViewController(movieDetailViewController, animated: true)
    }

    private func scrollToTop() {
        if !(self.movieArray?.isEmpty ?? true) {
            let indexPath = IndexPath(row: 0, section: 0)
            self.moviesTableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }

}

//MARK: - Search Bar Delegate Functions-

extension MoviesViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBarCancelButtonWidth.constant = 80
        UIView.animate(withDuration: 0.3,delay: 0,options: .curveEaseOut) {
            self.view.layoutIfNeeded()
        }
        lastPage = 1
        movieApiCallType = .search
        movieArray = nil

        getMovieData(searchText: searchBar.text ?? "")
    }
}
