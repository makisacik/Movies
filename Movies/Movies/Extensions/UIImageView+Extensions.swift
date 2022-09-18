import Foundation
import UIKit
import Kingfisher

extension UIImageView{

    func setImageWithPath(imagePath: String?) {
        if let imagePath = imagePath {
            let processor = DownsamplingImageProcessor(size: K.posterImageCGSize )
            self.kf.setImage(with: URL(string: K.tmdbURLString + imagePath ), options: [.processor(processor),.scaleFactor(UIScreen.main.scale),.transition(.fade(1)),.cacheOriginalImage] )
        } else {
            self.image = UIImage(named: "QuestionMark")
        }
    }

    func setCastImageWithPath(imagePath: String?) {
        if let imagePath = imagePath {
            let processor = DownsamplingImageProcessor(size: K.castImageCGSize )
            self.kf.setImage(with: URL(string: K.tmdbURLString + imagePath ), options: [.processor(processor),.scaleFactor(UIScreen.main.scale),.transition(.fade(1)),.cacheOriginalImage] )
        } else {
            self.image = UIImage(named: "QuestionMark")
        }
    }

    func setAvatarWithPath(avatarPath: String?) {
        if var authorAvatarPath =  avatarPath{
            if authorAvatarPath.contains("https") {
                authorAvatarPath.removeFirst()
                self.kf.setImage(with: URL(string: authorAvatarPath))
            } else {
                self.kf.setImage(with: URL(string:K.tmdbURLString + authorAvatarPath))
            }
        } else {
            self.image = UIImage(named: "AuthorPlaceholder")
        }
    }

}
