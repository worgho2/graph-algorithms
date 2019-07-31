import UIKit

func + (left: NSAttributedString, right: NSAttributedString) -> NSAttributedString{
    let result = NSMutableAttributedString()
    result.append(left)
    result.append(right)
    return result
}
