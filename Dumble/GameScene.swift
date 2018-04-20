//
//  GameScene.swift
//  Dumble
//
//  Created by Florian Sorin on 31/08/2017.
//  Copyright © 2017 Florian Sorin. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Players
    var players: [Player] = []
    var startingPlayerIndex = -1 // Tells which player starts (-1 because dealCards will increase it)
    var playerIndex = 0 // Tells which player has to play
    var playersNameLabelNodes: [SKLabelNode] = []
    var playersScoreLabelNodes: [SKLabelNode] = []
    
    // IA's hands
    var handsIA: [SKSpriteNode] = []
    var showIAHands = true
    
    // Player user view
    // Player cards
    var playerCardsNodes: [SKSpriteNode] = []
    var playerCardsList: [String : SKSpriteNode] = [:]
    // Player hand score
    var playerHandScoreLabelNode: SKLabelNode!
    
    // Pile and discard
    var pile = Deck()
    var discard: [Card] = []
    var discardCardsNodes: [SKSpriteNode] = []
    var discardCardsList: [String: SKSpriteNode] = [:]
    var nbDiscardCardsToShow = 0
    
    // Texture for the back of a card
    let backTexture = SKTexture(imageNamed: "back")
    
    // Card node indexes to display
    let cardNodesIndexes: [Int: [Int]] = [0: [], 1: [2], 2: [1, 2], 3: [1, 2, 3], 4: [0, 1, 2, 3], 5: [0, 1, 2, 3, 4]]
    
    // TO BE REMOVED: temporary "deal" button
    var dealButtonLabelNode: SKLabelNode!
    var dealButtonPressed = false // Basically tells if we need to reset all (new game started by pressing the deal button) or just cards and dumble flag (cards dealt because dumble has been said)
    
    // Turn counter
    var turnCounter = 1
    
    override func didMove(to view: SKView) {
        // Init players array
        createPlayers()
        
        // IA's hands and infos
        createIAHands()
        
        // Player user display
        createPlayerDisplay()
        
        // Init players name and score
        createPlayersDisplay()
        
        // Pile
        createPileNode()
        
        // Discard
        createDiscardNodes()
        
        // TO BE REMOVED: temporary "deal" button
        dealButtonLabelNode = SKLabelNode(text: "DEAL")
        dealButtonLabelNode.fontSize = 30
        dealButtonLabelNode.fontColor = SKColor.white
        dealButtonLabelNode.position = CGPoint(x: dealButtonLabelNode.frame.width * 0.75, y: frame.maxY - dealButtonLabelNode.frame.height * 1.5)
        dealButtonLabelNode.name = "deal"
        addChild(dealButtonLabelNode)
    }
    
    func createPlayers() {
        players.append(PlayerUser())
        players[0].name = "User"
        for _ in 1...3 {
            players.append(PlayerIA())
        }
        players[1].name = "Joe"
        players[2].name = "Jack"
        players[3].name = "Bill"
    }
    
    func createPlayersDisplay() {
        // Init with common parameters
        for (index, player) in players.enumerated() {
            playersNameLabelNodes.append(SKLabelNode(text: player.name))
            playersScoreLabelNodes.append(SKLabelNode(text: "0"))
            playersNameLabelNodes[index].fontSize = 20
            playersScoreLabelNodes[index].fontSize = 20
            playersNameLabelNodes[index].fontColor = SKColor.white
            playersScoreLabelNodes[index].fontColor = SKColor.white
            addChild(playersNameLabelNodes[index])
            addChild(playersScoreLabelNodes[index])
        }
        // Configure the specific position
        // Player user
        playersNameLabelNodes[0].position = CGPoint(x: playerCardsNodes[0].size.width, y: playerCardsNodes[0].size.height / 2)
        playersScoreLabelNodes[0].position = CGPoint(x: frame.midX, y: playerCardsNodes[0].size.height / 2)
        // IA #1
        playersNameLabelNodes[1].position = CGPoint(x: frame.width * 0.1, y: frame.height * 0.82)
        // IA #2
        playersNameLabelNodes[2].position = CGPoint(x: frame.width * 0.85, y: frame.maxY - playersNameLabelNodes[2].frame.height * 1.5)
        // IA #3
        playersNameLabelNodes[3].position = CGPoint(x: frame.width * 0.9, y: frame.height * 0.78)
        // All IA
        for nodeIndex in 1...playersScoreLabelNodes.count - 1 {
            playersScoreLabelNodes[nodeIndex].position = CGPoint(x: playersNameLabelNodes[nodeIndex].position.x, y: playersNameLabelNodes[nodeIndex].position.y - playersScoreLabelNodes[nodeIndex].frame.height * 1.5)
        }
    }
    
    func updateScoreLabels() {
        for (index, scoreNode) in playersScoreLabelNodes.enumerated() {
            scoreNode.text = "\(players[index].score)"
        }
    }
    
    // Touch management
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let node : SKNode = self.atPoint(location)
            if let nodeName = node.name { // Check if the node is a player card
                if let cardNode = playerCardsList[nodeName] {
                    playerCardsTouchManager(cardNode: cardNode)
                } else if nodeName == "pile" { // Check if the node is the pile
                    pileTouchManager()
                } else if let cardNode = discardCardsList[nodeName] { // Check if the node is a discard card
                    discardTouchManager(cardNode: cardNode)
                } else if nodeName == "deal" { // Check if the node is the deal button
                    dealButtonPressed = true
                    dealCards()
                }
            }
        }
    }
    
    // Called before each frame is rendered
    override func update(_ currentTime: TimeInterval) {
        displayIAHands()
        displayPlayerUserInfos()
        displayDiscardCards() 
    }
}
