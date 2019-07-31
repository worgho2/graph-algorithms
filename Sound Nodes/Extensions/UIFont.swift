import UIKit

extension UIFont {
    
    static let myFontName: String = "KenVector Bold"
    
    static func myFont(size: CGFloat) -> UIFont {
        return UIFont(name: myFontName, size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
}
