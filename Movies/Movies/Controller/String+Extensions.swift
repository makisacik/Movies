import Foundation

extension String {
    func localized() -> String{
        return NSLocalizedString(self, tableName: "Localizable", bundle: .main, value: self, comment: self)
    }

    var numberOfLines: Int {
        return self.components(separatedBy: "\n").count
    }
}
