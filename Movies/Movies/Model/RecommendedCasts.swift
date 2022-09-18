import Foundation

struct RecommendedCasts: Codable {
    let id: Int?
    let cast: [RecommendedCast]?
}

struct RecommendedCast: Codable {
    let adult: Bool?
    let gender, id: Int?
    let knownFor: Movie?
    let knownForDepartment: String?
    let name, originalName: String?
    let popularity: Double?
    let profilePath: String?
    let castID: Int?
    let character, creditID: String?
    let order: Int?
    let department: String?
    let job: String?

    enum CodingKeys: String, CodingKey {
        case adult, gender, id
        case knownForDepartment = "known_for_department"
        case knownFor = "known_for"
        case name
        case originalName = "original_name"
        case popularity
        case profilePath = "profile_path"
        case castID = "cast_id"
        case character
        case creditID = "credit_id"
        case order, department, job
    }
}

