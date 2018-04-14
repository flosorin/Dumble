//
//  GameScene.swift
//  Dumble
//
//  Created by Florian Sorin on 31/08/2017.
//  Copyright © 2017 Florian Sorin. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate
{

    let testCardTexture = SKTexture(imageNamed: "deuce_of_clubs")
    let testCardTextureAlternate = SKTexture(imageNamed: "back")
    
    // IA's hands
    var handCounter = 5
    var handTop : SKSpriteNode!
    var handLeft : SKSpriteNode!
    var handRight : SKSpriteNode!
    
    // Player cards
    var card1 : SKSpriteNode!
    var card2 : SKSpriteNode!
    var card3 : SKSpriteNode!
    var card4 : SKSpriteNode!
    var card5 : SKSpriteNode!
    
    var cardsList : [String : SKSpriteNode] = [:]
    
    override func didMove(to view: SKView)
    {
        handLeft = createHand(angle : CGFloat(Double.pi / 2), position : CGPoint(x: frame.width, y: frame.height * 5 / 8))
        handTop = createHand(angle : CGFloat(Double.pi), position : CGPoint(x: frame.width / 2, y: frame.height))
        handRight = createHand(angle : CGFloat(-Double.pi / 2), position : CGPoint(x: 0, y: frame.height * 5 / 8))
        addChild(handLeft)
        addChild(handTop)
        addChild(handRight)
        
        card1 = createCard(cardTexture: testCardTexture, cardPosition: CGPoint(x: 0, y: 0))
        card1.position = CGPoint(x: card1.size.width, y: 2 * card1.size.height)
        card1.name = "card1"
        addChild(card1)
        card2 = createCard(cardTexture: testCardTexture, cardPosition: CGPoint(x: 2.25 * card1.position.x, y: card1.position.y))
        card2.name = "card2"
        addChild(card2)
        card3 = createCard(cardTexture: testCardTexture, cardPosition: CGPoint(x: card2.position.x + 1.25 * card1.position.x, y: card1.position.y))
        card3.name = "card3"
        addChild(card3)
        card4 = createCard(cardTexture: testCardTexture, cardPosition: CGPoint(x: card3.position.x + 1.25 * card1.position.x, y: card1.position.y))
        card4.name = "card4"
        addChild(card4)
        card5 = createCard(cardTexture: testCardTexture, cardPosition: CGPoint(x: card4.position.x + 1.25 * card1.position.x, y: card1.position.y))
        card5.name = "card5"
        addChild(card5)
        cardsList = ["card1" : card1, "card2" : card2, "card3" : card3, "card4" : card4, "card5" : card5]
        
        let deck = SKSpriteNode(texture: SKTexture(imageNamed: "Deck"))
        let newHeight = card1.size.height
        let newWidth = deck.size.width * (newHeight / deck.size.height)
        deck.size = CGSize(width: newWidth, height: newHeight)
        deck.position = CGPoint(x: frame.width / 2, y: frame.height * 5 / 8)
        addChild(deck)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        for touch in touches {
            let location = touch.location(in: self)
            let node : SKNode = self.atPoint(location)
            if let nodeName = node.name {
                if let card = cardsList[nodeName] {
                    if (card.position.y == 2 * card1.size.height) {
                        card.position.y += card1.size.height / 2
                    } else {
                        card.position.y -= card1.size.height / 2
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
    override func update(_ currentTime: TimeInterval)
    {
        handLeft.texture = SKTexture(imageNamed: "Hand_\(handCounter)")
        handTop.texture = SKTexture(imageNamed: "Hand_\(handCounter)")
        handRight.texture = SKTexture(imageNamed: "Hand_\(handCounter)")
    }
    
    func createCard(cardTexture : SKTexture, cardPosition : CGPoint) -> SKSpriteNode
    {    
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
    
    func createHand(angle : CGFloat, position : CGPoint) -> SKSpriteNode
    {
        let hand = SKSpriteNode(texture: SKTexture(imageNamed: "Hand_5"))
        let newWidth = frame.width / 3
        let newHeight = hand.size.height * (newWidth / hand.size.width)
        hand.position = position
        hand.size = CGSize(width: newWidth, height: newHeight)
        hand.zRotation = angle
        return hand
    }
}

