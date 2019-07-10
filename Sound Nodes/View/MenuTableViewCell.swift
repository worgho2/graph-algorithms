import UIKit

class MenuTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var executionLabel: UILabel!
    @IBOutlet weak var algorithmLabel: UILabel!
    @IBOutlet weak var othersLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupCell(at cell: Int) {
        
        if cell == 1 {
            self.nameLabel.attributedText = NSAttributedString(string: "Dsatur", attributes: [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.2234827876, green: 0.2264050841, blue: 0.2998364568, alpha: 1)])
            self.executionLabel.attributedText = NSAttributedString(string: "Execution: ") + NSAttributedString(string: " step-by-step ", attributes: [NSAttributedString.Key.backgroundColor: #colorLiteral(red: 0.2234827876, green: 0.2264050841, blue: 0.2998364568, alpha: 1), NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)])
            self.algorithmLabel.attributedText = NSAttributedString(string: "Algorithm: ") + NSAttributedString(string: " coloring ", attributes: [NSAttributedString.Key.backgroundColor: #colorLiteral(red: 0.2234827876, green: 0.2264050841, blue: 0.2998364568, alpha: 1), NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.8049387336, green: 0.3803427815, blue: 0.3928821683, alpha: 1)])
            self.othersLabel.attributedText = NSAttributedString(string: "Others: ") + NSAttributedString(string: " ... ", attributes: [NSAttributedString.Key.backgroundColor: #colorLiteral(red: 0.2234827876, green: 0.2264050841, blue: 0.2998364568, alpha: 1), NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)])
        } else {
            self.nameLabel.attributedText = NSAttributedString(string: "Coming Soon", attributes: [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.3185468912, green: 0.3776341677, blue: 0.4200345576, alpha: 1)])
            self.executionLabel.attributedText = NSAttributedString(string: "New executions", attributes: [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.4546341896, green: 0.5418918133, blue: 0.6037419438, alpha: 1)])
            self.algorithmLabel.attributedText = NSAttributedString(string: "New algorithms", attributes: [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.4546341896, green: 0.5418918133, blue: 0.6037419438, alpha: 1)])
            self.othersLabel.attributedText = NSAttributedString(string: "New fatures", attributes: [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.4546341896, green: 0.5418918133, blue: 0.6037419438, alpha: 1)])
            self.accessoryType = .none
        }
    }
}

