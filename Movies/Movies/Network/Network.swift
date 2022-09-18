import Foundation
import Alamofire

class Network {
    static let shared = Network()

    var components = URLComponents() {
        didSet{
            components.scheme = "https"
            components.host = K.tmdbHostString
        }
    }

    let queryApiKeyItem = URLQueryItem(name: "api_key", value: K.tmdbApiKey)
    let queryLanguageItem = URLQueryItem(name: "language", value: Locale.preferredLanguages.first ?? "en-US")

    var manager = NetworkReachabilityManager(host: "www.apple.com")
    fileprivate var isReachable = false

    var isConnected:Bool {
        return NetworkReachabilityManager()!.isReachable
    }

    func startMonitoring() {
        self.manager?.startListening(onQueue: DispatchQueue.global(), onUpdatePerforming: { (networkStatus) in
            if networkStatus == .notReachable {
                self.isReachable = false
            }
            else{
                self.isReachable = true
            }
        })
    }

    enum MovieApiCallType {
        case populars
        case search
        case recommendations
    }

    enum CastApiCallType {
        case populars
        case search
    }

    func getPopularMovies(completion: @escaping (Result<Movies,AFError>) -> Void , page: Int = 1) {
        if Network.shared.isConnected {
            let queryPageItem = URLQueryItem(name:"page" , value: String(page))

            components.path = "/3/movie/popular"
            components.queryItems = [queryApiKeyItem, queryLanguageItem, queryPageItem]

            if let urlString = components.string {
                AF.request(urlString, method: .get).responseDecodable(of: Movies.self) { response in
                    completion(response.result)
                }
            }
        }
    }

    func getSearchMovies(completion: @escaping (Result<Movies,AFError>) -> Void , page: Int = 1,searchText: String = "") {
        if Network.shared.isConnected {
            let queryPageItem = URLQueryItem(name:"page" , value: String(page))
            let querySearchTextItem = URLQueryItem(name: "query", value: searchText)
            components.path = "/3/search/movie"
            components.queryItems = [queryApiKeyItem, queryLanguageItem, queryPageItem, querySearchTextItem]

            if let urlString = components.string {
                AF.request(urlString, method: .get).responseDecodable(of: Movies.self) { response in
                    completion(response.result)

                }
            }
        }
    }

    func getRecommendationMovies(completion: @escaping (Result<Movies,AFError>) -> Void , movieID: Int = 0){
        components.path = "/3/movie/\(movieID)/recommendations"
        components.queryItems = [queryApiKeyItem, queryLanguageItem]

        if let urlString = components.string {
            AF.request(urlString, method: .get).responseDecodable(of: Movies.self) { response in
                completion(response.result)
            }
        }
    }

    func getCastMovies(completion: @escaping (Result<CastMovies,AFError>) -> Void ,castID: Int) {
        components.path = "/3/person/\(castID)/movie_credits"
        components.queryItems = [queryApiKeyItem, queryLanguageItem]

        if let urlString = components.string{
            AF.request(urlString, method: .get).responseDecodable(of: CastMovies.self) { response in
                completion(response.result)
            }
        }
    }
    
    func getMovieDetails(completion: @escaping (Result<MovieDetail,AFError>) -> Void ,movieId: Int) {
        components.path = "/3/movie/\(movieId)"

        let queryApiKeyItem = URLQueryItem(name: "api_key", value: K.tmdbApiKey)
        let queryLanguageItem = URLQueryItem(name: "language", value: Locale.preferredLanguages.first ?? "en-US")

        components.queryItems = [queryApiKeyItem, queryLanguageItem]

        if let urlString = components.string {
            AF.request(urlString, method: .get).responseDecodable(of: MovieDetail.self) { response in
                completion(response.result)
            }
        }
    }
    
    func getRecommendedCasts(completion: @escaping (Result<RecommendedCasts,AFError>) -> Void ,movieId: Int) {
        components.path = "/3/movie/\(movieId)/credits"

        let queryApiKeyItem = URLQueryItem(name: "api_key", value: K.tmdbApiKey)
        let queryLanguageItem = URLQueryItem(name: "language", value: Locale.preferredLanguages.first ?? "en-US")

        components.queryItems = [queryApiKeyItem, queryLanguageItem]

        if let urlString = components.string {
            AF.request(urlString, method: .get).responseDecodable(of: RecommendedCasts.self) { response in
                completion(response.result)
            }
        }
    }

    func getCastDetail(completion: @escaping (Result<CastDetail,AFError>) -> Void ,castID: Int) {
        components.path = "/3/person/\(castID)"

        let queryApiKeyItem = URLQueryItem(name: "api_key", value: K.tmdbApiKey)
        let queryLanguageItem = URLQueryItem(name: "language", value: Locale.preferredLanguages.first ?? "en-US")

        components.queryItems = [queryApiKeyItem, queryLanguageItem]

        if let urlString = components.string {
            AF.request(urlString, method: .get).responseDecodable(of: CastDetail.self) { response in
                completion(response.result)
            }
        }
    }

    func getReviews(completion: @escaping (Result<Reviews,AFError>) -> Void, movieId: Int) {
        components.path = "/3/movie/\(movieId)/reviews"

        let queryApiKeyItem = URLQueryItem(name: "api_key", value: K.tmdbApiKey)
        let queryLanguageItem = URLQueryItem(name: "language", value: Locale.preferredLanguages.first ?? "en-US")

        components.queryItems = [queryApiKeyItem, queryLanguageItem]

        if let urlString = components.string {
            AF.request(urlString, method: .get).responseDecodable(of: Reviews.self) { response in
                completion(response.result)
            }
        }
    }

    func getCastPopularTest(completion: @escaping (Result<Casts,AFError>) -> Void, page: Int = 1) {
        let queryPageItem = URLQueryItem(name:"page" , value: String(page))

        components.path = "/3/person/popular"
        components.queryItems = [queryApiKeyItem, queryLanguageItem, queryPageItem]

        if let urlString = components.string {
            AF.request(urlString, method: .get).responseDecodable(of: Casts.self) { response in
                completion(response.result)
            }
        }
    }

    func getCastSearchTest(completion: @escaping (Result<Casts,AFError>) -> Void, searchText: String = "", page: Int = 1) {
        let queryPageItem = URLQueryItem(name:"page" , value: String(page))
        components.path = "/3/search/person"

        let querySearchTextItem = URLQueryItem(name: "query", value: searchText)

        components.queryItems = [queryApiKeyItem, queryLanguageItem, querySearchTextItem, queryPageItem]

        if let urlString = components.string {
            AF.request(urlString, method: .get).responseDecodable(of: Casts.self) { response in
                completion(response.result)
            }
        }
    }


    func getPopularCasts(completion: @escaping (Result<Casts,AFError>) -> Void, page: Int = 1) {
        components.scheme = "https"
        components.host = K.tmdbHostString
        components.path = "/3/person/popular"

        let queryApiKeyItem = URLQueryItem(name: "api_key", value: K.tmdbApiKey)
        let queryLanguageItem = URLQueryItem(name: "language", value: Locale.preferredLanguages.first ?? "en-US")
        let queryPageItem = URLQueryItem(name:"page" , value: String(page))

        components.queryItems = [queryApiKeyItem, queryLanguageItem, queryPageItem]

        if let urlString = components.string {
            AF.request(urlString, method: .get).responseDecodable(of: Casts.self) { response in
                completion(response.result)
            }
        }
    }
}

