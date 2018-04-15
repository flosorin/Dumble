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

    let testCardTexture = SKTexture(imageNamed: "deuce_of_clubs")
    let testCardTextureAlternate = SKTexture(imageNamed: "back")
    
    // IA's hands
    var handCounter = 5
    var handTop : SKSpriteNode!
    var handLeft : SKSpriteNode!
    var handRight : SKSpriteNode!
    
    // Player cards
    var playerCard1 : SKSpriteNode!
    var playerCard2 : SKSpriteNode!
    var playerCard3 : SKSpriteNode!
    var playerCard4 : SKSpriteNode!
    var playerCard5 : SKSpriteNode!
    
    var cardsList : [String : SKSpriteNode] = [:]
    
    override func didMove(to view: SKView) {
        
        handLeft = createHand(angle : CGFloat(Double.pi / 2), position : CGPoint(x: frame.width, y: frame.height * 5 / 8))
        handTop = createHand(angle : CGFloat(Double.pi), position : CGPoint(x: frame.width / 2, y: frame.height))
        handRight = createHand(angle : CGFloat(-Double.pi / 2), position : CGPoint(x: 0, y: frame.height * 5 / 8))
        addChild(handLeft)
        addChild(handTop)
        addChild(handRight)
        
        playerCard1 = createCard(cardTexture: testCardTexture, cardPosition: CGPoint(x: 0, y: 0))
        playerCard1.position = CGPoint(x: playerCard1.size.width, y: 2 * playerCard1.size.height)
        playerCard1.name = "card1"
        addChild(playerCard1)
        playerCard2 = createCard(cardTexture: testCardTexture, cardPosition: CGPoint(x: 2.25 * playerCard1.position.x, y: playerCard1.position.y))
        playerCard2.name = "card2"
        addChild(playerCard2)
        playerCard3 = createCard(cardTexture: testCardTexture, cardPosition: CGPoint(x: playerCard2.position.x + 1.25 * playerCard1.position.x, y: playerCard1.position.y))
        playerCard3.name = "card3"
        addChild(playerCard3)
        playerCard4 = createCard(cardTexture: testCardTexture, cardPosition: CGPoint(x: playerCard3.position.x + 1.25 * playerCard1.position.x, y: playerCard1.position.y))
        playerCard4.name = "card4"
        addChild(playerCard4)
        playerCard5 = createCard(cardTexture: testCardTexture, cardPosition: CGPoint(x: playerCard4.position.x + 1.25 * playerCard1.position.x, y: playerCard1.position.y))
        playerCard5.name = "card5"
        addChild(playerCard5)
        cardsList = ["card1" : playerCard1, "card2" : playerCard2, "card3" : playerCard3, "card4" : playerCard4, "card5" : playerCard5]
        
        let deck = SKSpriteNode(texture: SKTexture(imageNamed: "Deck"))
        let newHeight = playerCard1.size.height
        let newWidth = deck.size.width * (newHeight / deck.size.height)
        deck.size = CGSize(width: newWidth, height: newHeight)
        deck.position = CGPoint(x: frame.width / 2, y: frame.height * 5 / 8)
        addChild(deck)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            let location = touch.location(in: self)
            let node : SKNode = self.atPoint(location)
            if let nodeName = node.name {
                if let card = cardsList[nodeName] {
                    if (card.position.y == 2 * playerCard1.size.height) {
                        card.position.y += playerCard1.size.height / 2
                    } else {
                        card.position.y -= playerCard1.size.height / 2
                    }
                }
            } else {
                if (handCounter > 1) {
                    handCounter -= 1
                } else {
                    handCounter = 5
                }
            }
        }
    }
    
    // Called before each frame is rendered
    override func update(_ currentTime: TimeInterval) {
        
        handLeft.texture = SKTexture(imageNamed: "Hand_\(handCounter)")
        handTop.texture = SKTexture(imageNamed: "Hand_\(handCounter)")
        handRight.texture = SKTexture(imageNamed: "Hand_\(handCounter)")
    }
    
    func createCard(cardTexture : SKTexture, cardPosition : CGPoint) -> SKSpriteNode {
        
        // Create the base of a card
        let card = SKSpriteNode(texture: cardTexture)
        card.zPosition = 10
        card.position = cardPosition
        // Resize it keeping aspect ratio
        let newWidth = frame.width / 7
        let newHeight = card.size.height * (newWidth / card.size.width)
        card.size = CGSize(width: newWidth, height: newHeight)
        return card
    }
    
    func createHand(angle : CGFloat, position : CGPoint) -> SKSpriteNode {
        
        let hand = SKSpriteNode(texture: SKTexture(imageNamed: "Hand_5"))
        let newWidth = frame.width / 3
        let newHeight = hand.size.height * (newWidth / hand.size.width)
        hand.position = position
        hand.size = CGSize(width: newWidth, height: newHeight)
        hand.zRotation = angle
        return hand
    }
}

