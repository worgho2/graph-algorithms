import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) { self.init(red: CGFloat(((red >= 0 && red <= 255) ? red : 255)) / 255.0, green: CGFloat(((green >= 0 && green <= 255) ? green : 255)) / 255.0, blue: CGFloat(((blue >= 0 && blue <= 255) ? blue : 255)) / 255.0, alpha: 1.0) }
    convenience init(rgb: Int) { self.init(red: (rgb >> 16) & 0xFF, green: (rgb >> 8) & 0xFF, blue: rgb & 0xFF) }
}
