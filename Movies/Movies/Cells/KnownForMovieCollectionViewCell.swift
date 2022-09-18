//
//  KnownForMovieCollectionViewCell.swift
//  Movies
//
//  Created by Mehmet Ali Kısacık on 21.08.2022.
//

import UIKit
import Kingfisher

class KnownForMovieCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var movieNameLabel: UILabel!

    func setup(moviePosterPath: String?, movieName: String?) {
        movieImageView.setImageWithPath(imagePath: moviePosterPath)
        if let movieName = movieName {
            movieNameLabel.text = movieName
            movieImageView.layer.cornerRadius = 10
        }
    }

}
