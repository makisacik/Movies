import Foundation

struct Casts: Codable {
    let page: Int?
    let results: [Cast]?
    let totalPages, totalResults: Int?

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

struct Cast: Codable {
    let adult: Bool?
    let gender, id: Int?
    let knownFor: [Movie]?
    let name: String?
    let popularity: Double?
    let profilePath: String?

    enum CodingKeys: String, CodingKey {
        case adult, gender, id
        case knownFor = "known_for"
        case name, popularity
        case profilePath = "profile_path"
    }
}

