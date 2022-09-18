//
//  ReviewDetailViewController.swift
//  Movies
//
//  Created by Mehmet Ali Kısacık on 18.08.2022.
//

import UIKit
import Kingfisher

class ReviewDetailViewController: UIViewController {

    @IBOutlet weak var authorAvatarImageView: UIImageView!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var reviewTextView: UITextView!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var updatedAtLabel: UILabel!
    @IBOutlet weak var reviewHeightContent: NSLayoutConstraint!
    @IBOutlet weak var backgroundView: UIView!

    var review: Review?

    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.backgroundColor = K.getBackgroundColor(interfaceStyle: traitCollection.userInterfaceStyle)
        backgroundView.layer.cornerRadius = 10

        setup()
    }

    private func setup() {
        authorAvatarImageView.layer.cornerRadius = 10

        if let review = review {
            authorAvatarImageView.setAvatarWithPath(avatarPath: review.authorDetails?.avatarPath)
            authorNameLabel.text = review.author

            if let content = review.content {

                if content.count > 200 {
                    reviewHeightContent.constant = 300
                } else {
                    reviewHeightContent.constant = 100
                }
            }

            reviewTextView.text = review.content

            if let createdAt = formatDate(dateString: review.createdAt) {
                createdAtLabel.text = "Published At: ".localized() + createdAt
            } else {
                createdAtLabel.removeFromSuperview()
            }

            if let updatedAt = formatDate(dateString: review.updatedAt) {
                if createdAtLabel.text?.replacingOccurrences(of: "Published At: ".localized(), with: "") == updatedAt {
                    updatedAtLabel.removeFromSuperview()
                } else {
                    updatedAtLabel.text = "Uploaded At: " + updatedAt
                }
            } else {
                updatedAtLabel.removeFromSuperview()
            }
        }

        let tappedOutside = UITapGestureRecognizer(target: self ,action: #selector(dismissKeyboard))
        tappedOutside.delegate = self
        view.addGestureRecognizer(tappedOutside)
    }

    @objc func dismissKeyboard() {
        self.dismiss(animated: true)
    }

    private func formatDate(dateString: String?) -> String? {
        if let dateString = dateString {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
            let date = formatter.date(from: dateString)
            if let date = date {
                let calender = Calendar.current
                let components = calender.dateComponents([.year,.month,.day,.minute], from: date)
                if let year = components.year, let month = components.month, let day = components.day {
                    let dateString = String(day) + ". of " + formatter.shortMonthSymbols[month] + " " + String(year)
                    return dateString
                }
            }
        }
        return nil
    }

}

extension ReviewDetailViewController: UIGestureRecognizerDelegate {

  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                         shouldReceive touch: UITouch) -> Bool {
    return (touch.view === self.view)
  }
}
