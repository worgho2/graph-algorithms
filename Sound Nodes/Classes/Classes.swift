import UIKit
import SpriteKit

//EDGE (CODE-LAYER)
class Edge: Equatable {
    static func == (lhs: Edge, rhs: Edge) -> Bool {
        return lhs.id == rhs.id
    }
    
    static var next_id = 0
    
    let id: Int
    let origin: Node
    let destination: Node
    let weight: Float
    let directed: Bool = false
    
    init(origin: Node, destination: Node, weight: Float) {
        self.id = Edge.next_id
        Edge.next_id += 1
        
        self.origin = origin
        self.destination = destination
        self.weight = weight
    }
    
    //REMOVER ARESTA ENTRE NODOS
    func autoDelete() {
        origin.neighbours.remove(at: origin.neighbours.firstIndex(where: {$0.id == self.id})!)
        destination.neighbours.remove(at: destination.neighbours.firstIndex(where: {$0.id == self.id})!)
    }
}

//NODE (CODE-LAYER)
class Node {
    static var next_id = 0
    
    let id: Int
    var neighbours: [Edge] = []
    var color: Color?
    var scale: Float
    var saturation: Int
    var degree: Int { return neighbours.count }
    
    init() {
        self.id = Node.next_id
        Node.next_id += 1
        
        self.neighbours = []
        self.saturation = 0
        self.scale = 20
    }
    
    //ADICIONAR ARESTA ENTRE NODOS
    func addEdge(to node: Node, weight: Float = 1) {
        let edge = Edge(origin: self, destination: node, weight: weight)
        self.neighbours.append(edge)
        node.neighbours.append(edge)
    }
    
    //REMOVER ARESTA ENTRE NODOS
    func removeEdge(to node: Node) {
        guard let edge = self.getEdge(to: node) else {
            return
        }
        edge.autoDelete()
    }
    
    //RETORNA ARESTA ENTRE DOIS NODOS
    func getEdge(to otherNode: Node) -> Edge? {
        for edge in self.neighbours {
            if edge.directed {
                if edge.destination.id == otherNode.id {
                    return edge
                }
            } else  {
                if edge.origin.id == otherNode.id || edge.destination.id == otherNode.id{
                    return edge
                }
            }
        }
        return nil
    }
    
    //RETORNA TRUE SE DOIS NODOS ESTÃO CONECTADOS
    func isConnected(to otherNode: Node) -> Bool {
        for edge in self.neighbours {
            if edge.directed {
                
                //GRAFO DIRECIONADO
                if edge.destination.id == otherNode.id {
                    return true
                }
                
            } else  {
                
                //GRAFO NÃO DIRECIONADO
                if edge.origin.id == otherNode.id || edge.destination.id == otherNode.id{
                    return true
                }
                
            }
        }
        return false
    }
}

//GRAPH (CODE-LAYER)
class Graph {
    var nodeList: [Node]
    var minDegree: Int { return (nodeList.map( {$0.degree} )).min() ?? 0 } //GRAU MÍNIMO
    var maxDegree: Int { return (nodeList.map( {$0.degree} )).max() ?? 0 } //GRAU MÁXIMO
    var averageDegree: Float { return Float(nodeList.reduce(0, {$0 + $1.degree} )) / Float(nodeList.count) } //GRAU MÉDIO,
    var standardDeviationDegree: Float { return sqrt(Float(nodeList.reduce(0.0, {Float($0) + pow((Float($1.degree) - self.averageDegree), 2)} )) / Float(nodeList.count)) } //DESVIO PADRÃO ENTRE OS GRAUS
    var numberOfColors: Int { return GraphAlgorithms.colorListDSATUR.count } // NÚMERO DE CORES USADAS
    
    func reset() {
        nodeList.removeAll()
        GraphAlgorithms.colorListDSATUR.removeAll()
        GraphAlgorithms.canGetNextNodeDSATUR = true
    }
    
    func prepareToReRun() {
        GraphAlgorithms.prepareForDSATUR(g: self)
    }
    
    init() {
        self.nodeList = []
    }
}

//COLOR (CODE-LAYER)
class Color {
    static var next_id = 0
    static var baseColors: [UIColor] = [#colorLiteral(red: 0.9976105094, green: 0.9978497624, blue: 0.2008121014, alpha: 1), #colorLiteral(red: 0.970996201, green: 0.7363321185, blue: 0.7800995291, alpha: 1), #colorLiteral(red: 0.9841905236, green: 0.6016695499, blue: 0, alpha: 1), #colorLiteral(red: 0.989828527, green: 0.3159272671, blue: 0.03665245697, alpha: 1), #colorLiteral(red: 1, green: 0.1497657001, blue: 0.07186754793, alpha: 1), #colorLiteral(red: 0.6569766402, green: 0.09287301451, blue: 0.3004829884, alpha: 1), #colorLiteral(red: 0.5293875337, green: 0.0004829418031, blue: 0.692139864, alpha: 1), #colorLiteral(red: 0.2485940158, green: 0, blue: 0.6498000026, alpha: 1), #colorLiteral(red: 0.02485025488, green: 0.2667770386, blue: 0.9991496205, alpha: 1), #colorLiteral(red: 0.01578689367, green: 0.5690202117, blue: 0.8129312396, alpha: 1), #colorLiteral(red: 0.4073485732, green: 0.6892473102, blue: 0.1968636811, alpha: 1), #colorLiteral(red: 0.2491973459, green: 0, blue: 0, alpha: 1), #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), #colorLiteral(red: 0.1294117719, green: 0.2156862766, blue: 0.06666667014, alpha: 1), #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)]
    
    let id: Int
    var tone: UIColor
    var count: Int
    
    init(tone: UIColor) {
        self.id = Color.next_id
        Color.next_id += 1
        self.tone = tone
        self.count = 0
    }
}

//GRAPHALGORITHMS (CODE-LAYER)
class GraphAlgorithms {
    
    //(DSATUR) - VARIAVEIS DE CONTROLE
    static var canGetNextNodeDSATUR = true
    static var colorListDSATUR: [Color] = []
    
    //(DSATUR) - PREPARA O GRAFO PARA SER COLORIDO PELO ALGORITMO
    static func prepareForDSATUR(g: Graph) {
        GraphAlgorithms.canGetNextNodeDSATUR = true
        GraphAlgorithms.colorListDSATUR.removeAll()
        for node in g.nodeList {
            node.color = nil
            node.saturation = 0
        }
    }
    
    //(DSATUR) - BUSCAR O PRÓXIMO NODO A SER COLORIDO PELO ALGORITMO
    static func getNextNodeDSATUR(g: Graph) -> Node {
        let unpaintedNodes = g.nodeList.filter({$0.color == nil})
        
        if unpaintedNodes.count == 1 {
            GraphAlgorithms.canGetNextNodeDSATUR = false
        }
        
        let unpaintedNodesSaturationDESC = unpaintedNodes.sorted(by: {$0.saturation > $1.saturation} )
        let maxSaturationNode = unpaintedNodesSaturationDESC.first!
        let maximumSaturationNodes = unpaintedNodesSaturationDESC.filter( {$0.saturation == maxSaturationNode.saturation} )
        
        if maximumSaturationNodes.count > 1 {
            let unpaintedNodesMaximumSaturationDegreeDESC = maximumSaturationNodes.sorted(by: {$0.degree > $1.degree } )
            let maxDegreeNode = unpaintedNodesMaximumSaturationDegreeDESC.first!
            let maximumDegreeNodes = unpaintedNodesMaximumSaturationDegreeDESC.filter( {$0.degree == maxDegreeNode.degree } )
            
            if maximumDegreeNodes.count > 1 {
                let unpaintedNodesMaximumSaturationMaximumDegreeIdASC = maximumDegreeNodes.sorted(by: {$0.id < $1.id } )
                let minIdNode = unpaintedNodesMaximumSaturationMaximumDegreeIdASC.first!
                return minIdNode
            } else {
                return maxDegreeNode
            }
        } else {
            return maxSaturationNode
        }
    }
    
    
    //(DSATUR) - COLORIR O NODO ESCOLHIDO PELO ALGORITMO
    static func paintNodeDSATUR(node: Node) {
        let colorListCountASC = GraphAlgorithms.colorListDSATUR.sorted(by: {$0.count < $1.count})
        var neighboursColors: [Color] = []
        var newUIColor: UIColor!
        var unusedColor: Bool = false
        
        for edge in node.neighbours {
            if (edge.destination.id != node.id && edge.destination.color != nil) {
                neighboursColors.append(edge.destination.color!)
            } else if (edge.origin.id != node.id && edge.origin.color != nil) {
                neighboursColors.append(edge.origin.color!)
            }
        }
        
        for color in colorListCountASC {
            if !neighboursColors.contains(where: {$0.id == color.id}) {
                node.color = color
                color.count += 1
                return
            }
        }
        
        while !unusedColor {
            newUIColor = Color.baseColors[.random(in: 0..<Color.baseColors.count)]
            if GraphAlgorithms.colorListDSATUR.filter( { $0.tone == newUIColor } ).count == 0 {
                unusedColor = true
            }
        }
        
        let newColor = Color(tone: newUIColor)
        node.color = newColor
        newColor.count += 1
        GraphAlgorithms.colorListDSATUR.append(newColor)
    }
    
    //EXECUTAR UMA ETAPA DO ALGORITMO SE EXISTE UM PRÓXIMO NODO
    static func stepDSATUR(inGraph g: Graph, nodeConsumer: NodeConsumer) -> Bool {
        if !GraphAlgorithms.canGetNextNodeDSATUR {
            return false
        } else {
            let nextNode = GraphAlgorithms.getNextNodeDSATUR(g: g)
            GraphAlgorithms.paintNodeDSATUR(node: nextNode)
            for edge in nextNode.neighbours {
                if edge.origin.id == nextNode.id && edge.destination.color != nil {
                    edge.destination.saturation += 1
                }
            }
            nodeConsumer.updateNodeProperties(node: nextNode)
        }
        return true
    }
}

//PROTOCOLO PARA CONEXÃO ENTRE CODE-LAYER E GRAPH-LAYER
protocol NodeConsumer {
    func updateNodeProperties(node: Node)
}

//NODEGRAPH (GRAPH-LAYER)
class NodeGraph: SKShapeNode {
    var reference: Node
    var ball: SKShapeNode
    var arc: SKShapeNode
    
    init(reference: Node, radius: CGFloat = 20) {
        let arcRadius: CGFloat = radius * 1.5
        let arcWidth: CGFloat = 1.5
        let collisionRadius: CGFloat = arcRadius * 4
        
        self.reference = reference
        self.ball = SKShapeNode(circleOfRadius: radius)
        ball.fillColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        let arcPath = CGMutablePath()
        arcPath.move(to: CGPoint(x: arcRadius, y: 0))
        arcPath.addArc(center: .zero, radius: arcRadius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: false)
        arcPath.addArc(center: .zero, radius: arcRadius + arcWidth, startAngle: CGFloat.pi * 2, endAngle: 0, clockwise: true)
        arcPath.closeSubpath()
        
        self.arc = SKShapeNode(path: arcPath)
        self.arc.fillColor = .white
        self.arc.lineWidth = 0
        self.arc.alpha = 0.4
        
        super.init()
        self.path = CGPath(ellipseIn: CGRect(origin: CGPoint(x: -collisionRadius/2, y: -collisionRadius/2), size: CGSize(width: collisionRadius, height: collisionRadius)), transform: nil)
        self.lineWidth = 0
        self.addChild(ball)
        self.addChild(arc)
        self.scaleEffect()
    }
    
    //EFEITO PULSANTE DA AURA DE CADA NODO
    func scaleEffect() {
        let size = self.arc.xScale
        self.arc.alpha = 0
        self.arc.run(.fadeAlpha(to: 0.6, duration: 1), completion: { self.arc.run(.fadeAlpha(to: 0.0, duration: 1)) } )
        self.arc.run(.scale(to: self.arc.xScale + 0.1, duration: 1), completion: { self.arc.run(.scale(to: size, duration: 1)) } )
        
        //FADE EFFECT
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { (Timer) in
            self.arc.run(.fadeAlpha(to: 0.6, duration: 1), completion: { self.arc.run(.fadeAlpha(to: 0.0, duration: 1)) } )
        }
        
        
        //SCALE EFFECT
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { (Timer) in
            self.arc.run(.scale(to: self.arc.xScale + 0.1, duration: 1), completion: { self.arc.run(.scale(to: size, duration: 1)) } )
        }
        
    }
    
    //NÃO USADO
    required init?(coder aDecoder: NSCoder) {
        self.reference = Node()
        ball = SKShapeNode(circleOfRadius: 20)
        arc = SKShapeNode()
        super.init(coder: aDecoder)
        self.addChild(ball)
    }
}

//EDGEGRAPH (GRAPH-LAYER)
class EdgeGraph: SKShapeNode {
    var reference: Edge
    
    init(reference: Edge, path: CGMutablePath) {
        self.reference = reference
        super.init()
        self.path = path
        self.zPosition = -2
        self.lineWidth = 1
        self.fillColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.strokeColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.alpha = 1.0
    }
    
    //NÃO USADO
    required init?(coder aDecoder: NSCoder) {
        self.reference = Edge(origin: Node(), destination: Node(), weight: 1)
        super.init(coder: aDecoder)
    }
}
