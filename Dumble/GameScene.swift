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
    var players : [Player] = []
    
    // IA's hands
    var handCounter = 5
    var handTop : SKSpriteNode!
    var handLeft : SKSpriteNode!
    var handRight : SKSpriteNode!
    
    // Player view
    // Player cards
    var playerCardsNodes : [SKSpriteNode] = []
    var playerCardsList : [String : SKSpriteNode] = [:]
    // Player hand score
    var playerHandScoreLabelNode : SKLabelNode!
    
    // Pile and discard
    var pile = Deck()
    var discard : [Card] = []
    var discardCardsNodes : [SKSpriteNode] = []
    var discardCardsList : [String : SKSpriteNode] = [:]
    var nbDiscardCardsToShow = 0
    
    // Texture for the back of a card
    let backTexture = SKTexture(imageNamed: "back")
    
    // TO BE REMOVED: temporary "deal" button
    var dealButtonLabelNode : SKLabelNode!
    
    override func didMove(to view: SKView) {
        // Init players array
        createPlayers()
        
        // IA's hands
        createIAHands()
        
        // Player user display
        createPlayerDisplay()
        
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
        for _ in 1...3 {
            players.append(PlayerIA())
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
                } else if let cardNode = discardCardsList[nodeName] {
                    discardTouchManager(cardNode: cardNode)
                } else if nodeName == "deal" {
                    dealCards()
                }
            }
        }
    }
    
    // Called before each frame is rendered
    override func update(_ currentTime: TimeInterval) {
        displayIAHands()
        displayPlayerCards()
        displayDiscardCards() 
    }
}
