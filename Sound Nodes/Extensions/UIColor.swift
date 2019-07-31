import UIKit

extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: CGFloat(((red >= 0 && red <= 255) ? red : 255)) / 255.0, green: CGFloat(((green >= 0 && green <= 255) ? green : 255)) / 255.0, blue: CGFloat(((blue >= 0 && blue <= 255) ? blue : 255)) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(red: (rgb >> 16) & 0xFF, green: (rgb >> 8) & 0xFF, blue: rgb & 0xFF)
    }
    
    struct MyPallete {
        static let black: UIColor = #colorLiteral(red: 0.09803921569, green: 0.09019607843, blue: 0.0862745098, alpha: 1)
        static let white: UIColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        static let gray: UIColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
    }
    
}

