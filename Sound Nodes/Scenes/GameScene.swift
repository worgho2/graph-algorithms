//
//  GameScene.swift
//  Sound Nodes
//
//  Created by Otávio Baziewicz Filho on 25/06/19.
//  Copyright © 2019 Otávio Baziewicz Filho. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, UIGestureRecognizerDelegate, NodeConsumer {
   
    var graph: Graph = Graph()                              //GRAFO
    var nodes = [NodeGraph]() {                             //NODOS
        didSet {
            if nodes.count == 0 {
                Model.instance.graphIsEmpty = true
            } else {
                Model.instance.graphIsEmpty = false
            }
        }
    }
    var edges = [EdgeGraph]() {                             //ARESTAS
        didSet {
            Model.instance.updateStatusObservers.forEach( { $0.notifyObservers() } )
        }
    }
        
    var temporaryEdge: SKShapeNode!                         //ARESTAS TEMPORARIAS
    var permanentEdge: SKShapeNode!                         //ARESTA PERMANENTE
    var pathBeginning = NodeGraph(reference: Node())        //NODO INICIAL QUANDO UMA ARESTA É INICIDA
    
    var creatingEdge: Bool = false                          //CONTROLE PARA CRIAÇÃO DE ARESTA
    var intersect: Bool = true                              //IDENTIFICAÇÃO DE INTERSECÇÃO PARA CRIAÇÃO DE ARESTA
    var moved: Bool = false                                 //IDENTIFICAÇÃO DE MOVIMENTO
    
    let notification = UINotificationFeedbackGenerator()    //FEEDBACK TÁTIL DE NOTIFICAÇÃO
    let impact = UIImpactFeedbackGenerator()                //FEEDBACK TÁTIL DE IMPACTO
    let selection = UISelectionFeedbackGenerator()          //FEEDBACK TÁTIL DE SELEÇÃO
    
    override func didMove(to view: SKView) {
        layoutScene()
    }
    
    //CARREGAR LAYAOUT
    func layoutScene() {
        backgroundColor = #colorLiteral(red: 0.09803921569, green: 0.09019607843, blue: 0.0862745098, alpha: 1)
    }
    
    //CRIAÇÃO DO CAMINHO DA ARESTA
    func createPath(beginning: CGPoint, end: CGPoint) -> CGMutablePath {
        let path = CGMutablePath()
        path.move(to: beginning)
        path.addLine(to: end)
        path.closeSubpath()
        return path
    }
    
    //CRIAÇÃO DE ARESTA TEMPORÁRIA
    func createTemporaryEdge(beginning: CGPoint, end: CGPoint) {
        let path = self.createPath(beginning: beginning, end: end)
        temporaryEdge = SKShapeNode(path: path)
        temporaryEdge.fillColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        temporaryEdge.strokeColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        temporaryEdge.zPosition = -1
        self.addChild(temporaryEdge)
    }
    
    //EXECUTAR ETAPA DO ALGORITMO
    func runGraphAlgorithm() {
        Model.instance.stepIsAvaliable = (GraphAlgorithms.stepDSATUR(inGraph: self.graph, nodeConsumer: self)) ? true : false
        
        Model.instance.stepIsAvaliable = (GraphAlgorithms.canGetNextNodeDSATUR) ? true : false
        Model.instance.algorithmIsRunnig = Model.instance.stepIsAvaliable
    }
    
    //LIMPAR O GRAFO
    func resetGraph() {
        Model.instance.setToDefault()
        self.edges.forEach( { $0.removeFromParent() } )
        self.nodes.forEach( { $0.removeFromParent() } )
        self.edges.removeAll()
        self.nodes.removeAll()
        self.creatingEdge = false
        self.intersect = true
        self.moved = false
        graph.reset()
    }
    
    //PREPARAR PARA EXECUTAR ALGORITMO NOVAMENTE
    func reRunGraphAlgorithm() {
        Model.instance.prepareToReRun()
        nodes.forEach( { $0.ball.fillColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)} )
        graph.prepareToReRun()
    }
    
    //ATRIBUIR CARACTERISTICAS ENTRE CODE-LAYER E GRAPH-LAYER
    func updateNodeProperties(node: Node) {
        let nodeIndex = nodes.firstIndex(where: { $0.reference.id == node.id } )!
        self.nodes[nodeIndex].ball.fillColor = node.color!.tone
        let allNeighboursEdges = node.neighbours
        
        var nodesIDs: [Int] = []
        for edge in allNeighboursEdges {
            nodesIDs.append(edge.destination.id)
            nodesIDs.append(edge.origin.id)
        }
        
        let neighboursIDs = Array(Set(nodesIDs)).filter( {$0 != node.id} )
        let neighbours = nodes.filter( { neighboursIDs.contains($0.reference.id) } )
        let uncoloredNeighbours = neighbours.filter( { $0.reference.color == nil } )
        
        for neighbour in uncoloredNeighbours {
            let ball: SKShapeNode = SKShapeNode(circleOfRadius: 5)
            ball.fillColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            ball.strokeColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            ball.zPosition = -1
            self.addChild(ball)
            ball.position = nodes[nodeIndex].position

            ball.run(.move(to: neighbour.position, duration: 1.5), completion: {
                ball.removeFromParent()
            })
        }
    }
    
    //(TOUCH DOWN) - INICIOU
    func touchDown(atPoint pos : CGPoint) {
        if nodes.filter( { $0.contains(pos) } ).count > 0 {
            if creatingEdge { touchUp(atPoint: pos) } // ERRO DE MULTITOUCH
            let touchedNode = nodes.filter( { $0.contains(pos) } ).first
            self.creatingEdge = true
            pathBeginning = touchedNode!
            createTemporaryEdge(beginning: pathBeginning.position, end: pos)
        } else {
            let newNode = NodeGraph(reference: Node())
            let graphNode = Node()
            newNode.position = pos
            addChild(newNode)
            nodes.append(newNode)
            graph.nodeList.append(graphNode)
            newNode.reference = graphNode
            self.impact.impactOccurred()
        }
    }
    
    //(TOUCH MOVE) - MOVEU
    func touchMove(atPoint pos: CGPoint) {
        if creatingEdge {
            temporaryEdge.removeFromParent() //REMOVER A ARESTA TEMPORÁRIA ANTERIOR, SE COMENTAR, FICA >DISRUPTIVO<
            createTemporaryEdge(beginning: pathBeginning.position, end: pos)
            
            if nodes.filter( { $0.contains(pos) } ).count > 0 && self.intersect == false{
                self.intersect = true
                self.impact.impactOccurred()
            } else if nodes.filter( { $0.contains(pos) } ).count == 0 {
                self.intersect = false
            }
        }
    }
    
    //(TOUCH UP) - FINALIZOU
    func touchUp(atPoint pos: CGPoint) {
        if creatingEdge {
            self.creatingEdge = false
            
            if self.intersect {
                temporaryEdge.removeFromParent()
                let intersectedNode = nodes.filter( { $0.contains(pos) } ).first
                
                if intersectedNode != nil && intersectedNode != pathBeginning && !pathBeginning.reference.isConnected(to: intersectedNode!.reference) {
                    pathBeginning.reference.addEdge(to: intersectedNode!.reference)
                    let edgeReference = pathBeginning.reference.getEdge(to: intersectedNode!.reference)
                    let path = self.createPath(beginning: pathBeginning.position, end: intersectedNode!.position)
                    let edgeGraph = EdgeGraph(reference: edgeReference!, path: path)
                    self.addChild(edgeGraph)
                    edges.append(edgeGraph)
                    notification.notificationOccurred(.success)
                } else if intersectedNode != nil && pathBeginning.reference.isConnected(to: intersectedNode!.reference) && intersectedNode!.reference.id != pathBeginning.reference.id {
                    let edgeReference = pathBeginning.reference.getEdge(to: intersectedNode!.reference)!
                    let edgeGraph = edges.filter( { $0.reference.id == edgeReference.id } ).first!
                    edgeGraph.removeFromParent()
                    pathBeginning.reference.removeEdge(to: intersectedNode!.reference)
                    intersectedNode!.reference.removeEdge(to: pathBeginning.reference)
                } else {
                    if pathBeginning.reference.neighbours.count > 0 {
                        let codeEdges = pathBeginning.reference.neighbours
                        let visualEdges = edges.filter( { codeEdges.contains($0.reference) } )
                        visualEdges.forEach({ $0.removeFromParent() })
                        codeEdges.forEach({ $0.autoDelete() })
                    } else {
                        pathBeginning.removeFromParent()
                        nodes.remove(at: nodes.firstIndex(where: {$0.reference.id == pathBeginning.reference.id } )!)
                        graph.nodeList.remove(at: graph.nodeList.firstIndex(where: {$0.id == pathBeginning.reference.id})!)
                    }
                }
            } else {
                let position = (pos - pathBeginning.position).normalized() * 50
                let move = SKAction.moveBy(x: position.x, y: position.y, duration: 0.534237)
                move.timingMode = .easeOut
                temporaryEdge.run(move)
                let temporaryEdgeFix = self.temporaryEdge
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.534237, execute: { temporaryEdgeFix!.removeFromParent() })
                notification.notificationOccurred(.error)
            }
        }
    }
    
    //TOUCH
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !Model.instance.algorithmIsRunnig {
            for t in touches { touchDown(atPoint: t.location(in: self))}
        }
    }
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !Model.instance.algorithmIsRunnig {
            for t in touches { touchMove(atPoint: t.location(in: self)) }
        }
    }
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !Model.instance.algorithmIsRunnig {
            for t in touches { touchUp(atPoint: t.location(in: self)) }
        }
    }
}
