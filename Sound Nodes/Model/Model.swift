class Model {
    static let instance = Model()
    private init() { }
    
    var algorithmIsRunnig: Bool = false {
        didSet {
            updateStatusObservers.forEach( { $0.notifyObservers() } )
        }
    }
    
    var stepIsAvaliable: Bool = true {
        didSet {
            updateStatusObservers.forEach( { $0.notifyObservers() } )
        }
    }
    
    var graphIsEmpty: Bool = true {
        didSet {
            updateStatusObservers.forEach( { $0.notifyObservers() } )
        }
    }
    
    func setToDefault() {
        self.stepIsAvaliable = true
        self.algorithmIsRunnig = false
        self.graphIsEmpty = true
    }
    
    func prepareToReRun() {
        self.stepIsAvaliable = true
        self.algorithmIsRunnig = false
    }
    
    var updateStatusObservers: [UpdateStatusObserver] = []
    
    
}
