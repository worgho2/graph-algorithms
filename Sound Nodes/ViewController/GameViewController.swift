//
//  GameViewController.swift
//  Sound Nodes
//
//  Created by Otávio Baziewicz Filho on 25/06/19.
//  Copyright © 2019 Otávio Baziewicz Filho. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController, UpdateStatusObserver {

    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var run_stepButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var rerunButton: UIButton!
    @IBOutlet weak var homeButton: UIButton!
    
    @IBOutlet weak var colorIndicator: UIButton!
    @IBOutlet weak var standardDeviationDegree: UIButton!
    @IBOutlet weak var maxDegree: UIButton!
    @IBOutlet weak var minDegree: UIButton!
    @IBOutlet weak var averageDegree: UIButton!
    
    
    @IBOutlet weak var gameView: SKView!
    var scene: GameScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Model.instance.updateStatusObservers.append(self)
        
        
        if let view = self.gameView {
            scene = GameScene(size: view.bounds.size)
            scene.scaleMode = .aspectFill
            view.presentScene(scene)
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
            self.updateStatus()
        }
        self.scene.resetGraph()
    }
    
    func updateStatus() {
        self.infoButton.isEnabled = true
        self.run_stepButton.isEnabled = ((Model.instance.stepIsAvaliable && !Model.instance.graphIsEmpty) ? true : false)
        self.clearButton.isEnabled = ((!Model.instance.graphIsEmpty) ? true : false)
        self.rerunButton.isEnabled = ((!Model.instance.graphIsEmpty) ? true : false)
        self.homeButton.isEnabled = true
        self.run_stepButton.setImage((Model.instance.algorithmIsRunnig) ? UIImage(named: "step_button") : UIImage(named: "run_button"), for: .normal)
        self.updateStatistics()
    }
    
    func updateStatistics() {
        self.colorIndicator.setTitle("🎨 : " + String(self.scene.graph.numberOfColors), for: .normal)
        self.standardDeviationDegree.setTitle("σ:  : " + String(NSString(format: "%.01f", self.scene.graph.standardDeviationDegree)), for: .normal)
        self.maxDegree.setTitle("↑:  : " + String(self.scene.graph.maxDegree), for: .normal)
        self.minDegree.setTitle("↓:  : " + String(self.scene.graph.minDegree), for: .normal)
        self.averageDegree.setTitle("x̅:  : " + String(NSString(format: "%.01f", self.scene.graph.averageDegree)), for: .normal)
    }
  
    @IBAction func onHomeButton(_ sender: Any) {
        self.scene.resetGraph()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onRerunButton(_ sender: Any) {
        self.scene.reRunGraphAlgorithm()
    }
    
    @IBAction func onClearButton(_ sender: Any) {
        self.scene.resetGraph()
    }
    
    @IBAction func onRun_stepButton(_ sender: Any) {
        self.scene.runGraphAlgorithm()
    }
    
    @IBAction func onInfoButton(_ sender: Any) {
        self.alertInfo()
    }
    
    @IBAction func onColorIndicator(_ sender: Any) {
        self.alertInfoIndicator(title: "Number of Colors")
    }
    
    @IBAction func onStandardDeviation(_ sender: Any) {
        self.alertInfoIndicator(title: "Standart Deviation of node degree")
    }
    
    @IBAction func onMaxDegree(_ sender: Any) {
        self.alertInfoIndicator(title: "Maximum node degree")
    }
    
    @IBAction func onMinDegree(_ sender: Any) {
        self.alertInfoIndicator(title: "Minimum node degree")
    }
    
    @IBAction func onAverageDegree(_ sender: Any) {
        self.alertInfoIndicator(title: "Average node degree")
    }
    
    func notifyObservers() {
        self.updateStatus()
    }
    
    func alertInfoIndicator(title: String) {
        let alert = UIAlertController(title: "", message: nil, preferredStyle: .alert)
        let titleFont = [NSAttributedString.Key.font: UIFont(name: "KenVector Bold", size: 17.0)!]
        let titleAttrString = NSMutableAttributedString(string: title, attributes: titleFont)
        alert.setValue(titleAttrString, forKey: "attributedTitle")
        self.present(alert, animated: true, completion: {
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (Timer) in
                self.dismiss(animated: true, completion: nil)
            })
        } )
    }
    
    func alertInfo() {
        let alert = UIAlertController(title: "", message: nil, preferredStyle: .alert)
        let titleFont = [NSAttributedString.Key.font: UIFont(name: "KenVector Bold", size: 20.0)!]
        let messageFont = [NSAttributedString.Key.font: UIFont(name: "KenVector Bold", size: 11.0)!]
        let titleAttrString = NSMutableAttributedString(string: "DSATUR", attributes: titleFont)
        let messageAttrString = NSMutableAttributedString(string: "\nis a graph colouring algorithm put forward by Daniel Brelaz. DSATUR colours the vertices of a graph one after another, expending a previously unused colour when needed. Once a new vertex has been coloured, the algorithm determines which of the remaining uncoloured vertices has the highest number of colours in its neighbourhood and colours this vertex next. Brelaz defines this number as the degree of saturation of a given vertex.", attributes: messageFont)
        alert.setValue(titleAttrString, forKey: "attributedTitle")
        alert.setValue(messageAttrString, forKey: "attributedMessage")
        
        alert.addAction(UIAlertAction(title: "Back", style: .default, handler: { (UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true)

        
    }

}
