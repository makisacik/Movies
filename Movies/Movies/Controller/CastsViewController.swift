import UIKit
import Kingfisher

class CastsViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
            searchBar.placeholder = "Search Casts Here".localized()
        }
    }

    @IBOutlet weak var castsTableView: UITableView! {
        didSet {
            castsTableView.register(UINib(nibName: String(describing: CastTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: CastTableViewCell.self))
            castsTableView.delegate = self
            castsTableView.dataSource = self
        }
    }

    @IBOutlet weak var searchBarCancelButton: UIButton!
    @IBOutlet weak var searchBarCancelButtonWidth: NSLayoutConstraint!

    private var castArray: [Cast]?
    private var lastPage = 1
    private var castApiCallType: Network.CastApiCallType = .populars
    private var currentSearchText = ""
    private var tap = UITapGestureRecognizer()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    private func setup() {
        setNeedsStatusBarAppearanceUpdate()
        view.backgroundColor = K.getBackgroundColor(interfaceStyle: traitCollection.userInterfaceStyle)
        getCasts()
        tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        searchBarCancelButton.setTitle("Cancel".localized(), for: .normal)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
    }

    @IBAction func searchBarCancelButtonPressed(_ sender: UIButton) {
        dismissKeyboard()
        searchBar.text = ""
        searchBarCancelButtonWidth.constant = 0
        UIView.animate(withDuration: 0.3,delay: 0,options: .curveEaseOut) {
            self.view.layoutIfNeeded()
        }
        refreshDataToPopularCasts()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }

    //MARK: - API Call Functions

    private func getCasts(searchText: String = "") {
        switch castApiCallType {
        case .populars:
            Network.shared.getCastPopularTest(completion: { [self] results in
                switch results{
                case .success(let result):
                    if let _ = castArray {
                        castArray?.append(contentsOf: result.results ?? [])
                    } else {
                        castArray = result.results ?? []
                    }
                case .failure(let err):
                    print(err)
                }
                self.castsTableView.reloadData()
            }, page: lastPage)

        case .search:
            Network.shared.getCastSearchTest(completion: { [self] results in
                switch results {
                case .success(let result):
                    if let _ = castArray {
                        castArray?.append(contentsOf: result.results ?? [])
                    } else {
                        castArray = result.results ?? []
                    }
                case .failure(let err):
                    print(err)
                }
                self.castsTableView.reloadData()
            }, searchText: searchText, page: lastPage)
        }
    }

    private func refreshDataToPopularCasts() {
        scrollToTop()
        castApiCallType = .populars
        lastPage = 1
        castArray = []
        getCasts()
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
        if castApiCallType == .populars {
            searchBarCancelButtonWidth.constant = 0
            UIView.animate(withDuration: 0.3,delay: 0,options: .curveEaseOut) {
                self.view.layoutIfNeeded()
            }
        }
    }
}

//MARK: - Table View Functions

extension CastsViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return castArray?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = castsTableView.dequeueReusableCell(withIdentifier: String.init(describing: CastTableViewCell.self), for: indexPath) as? CastTableViewCell else {
            return UITableViewCell()
        }
        if let castArray = castArray {
            cell.setup(castName: castArray[indexPath.row].name, castImagePath: castArray[indexPath.row].profilePath)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            if indexPath.row == (castArray?.count ?? 0) - 1 {
                lastPage += 1
                switch castApiCallType {
                case .populars:
                    getCasts()
                case .search:
                    getCasts(searchText: currentSearchText)
                }
            }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let castDetailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: String(describing: CastDetailViewController.self)) as? CastDetailViewController else {
            return
        }
        if let castArray = castArray {
            castDetailViewController.castID = castArray[indexPath.row].id
            castDetailViewController.modalPresentationStyle = .overFullScreen
            self.navigationController?.pushViewController(castDetailViewController, animated: true)
        }
    }
    private func scrollToTop() {
        if !(self.castArray?.isEmpty ?? true) {
            let indexPath = IndexPath(row: 0, section: 0)
            self.castsTableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
}

//MARK: - Search Bar Functions

extension CastsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        scrollToTop()
        searchBarCancelButtonWidth.constant = 80
        UIView.animate(withDuration: 0.3,delay: 0,options: .curveEaseOut) {
            self.view.layoutIfNeeded()
        }
        lastPage = 1
        castApiCallType = .search
        currentSearchText = searchBar.text ?? ""
        castArray = nil
        getCasts(searchText: searchBar.text ?? "")
    }
}

