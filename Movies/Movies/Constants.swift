import Foundation
import UIKit

struct K {
    static let tmdbURLString = "https://image.tmdb.org/t/p/w500/"
    
    static let tmdbApiKey = "e9ddf3ad49781b8bed552c4367ae953f"

    static let tmdbHostString = "api.themoviedb.org"
    
    static let backgroundColorLightMode = UIColor(cgColor: CGColor(red: 255/255, green: 195/255, blue: 0/255, alpha: 1))
    
    static let backgroundColorDarkMode = UIColor(cgColor: CGColor(red: 65/255, green: 63/255, blue: 66/255, alpha: 1))
    
    static let posterImageCGSize = CGSize(width: 150, height: 250)

    static let castImageCGSize = CGSize(width: 150, height: 250)

    static func getBackgroundColor(interfaceStyle:  UIUserInterfaceStyle) -> UIColor {
        if interfaceStyle == .dark {
            return backgroundColorDarkMode
        }
        else{
            return backgroundColorLightMode
        }
    }
}
