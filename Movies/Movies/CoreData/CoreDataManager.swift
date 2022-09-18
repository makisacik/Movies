import Foundation
import CoreData
import UIKit

internal let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

class CoreDataManager {
    
    static var favoritedMovies: [FavoritedMovie] = []

    static func saveContext(){
        do {
            try context.save()
        } catch {
            print("Error on saving data \(error)")
        }
    }

    static func addFavoriedMovie(favoritedMovie: FavoritedMovie) {
        CoreDataManager.favoritedMovies.append(favoritedMovie)
        CoreDataManager.saveContext()
    }
    
    static func loadFavoriteMovies() {
        let request:NSFetchRequest<FavoritedMovie> = FavoritedMovie.fetchRequest()
        do {
            favoritedMovies = try context.fetch(request)
            favoritedMovies.reverse()
        } catch {
            print("Error fetching data \(error)")
        }
    }
    
    static func isFavoritedMovieExists(movieID: Int) -> Bool {
        loadFavoriteMovies()
        for favoritedMovie in favoritedMovies {
            if Double(movieID) == favoritedMovie.movieID {
                return true
            }
        }
        return false
    }
    
    static func deleteFavoritedMovie(movieID: Int?) {
        if let movieID = movieID {
            for favoritedMovie in favoritedMovies {
                if Double(movieID) == favoritedMovie.movieID {
                    context.delete(favoritedMovie)
                    saveContext()
                    loadFavoriteMovies()
                    return
                }
            }
        }
    }
}
