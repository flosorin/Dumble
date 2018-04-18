//
//  GameSceneIA.swift
//  Dumble
//
//  Created by Florian Sorin on 16/04/2018.
//  Copyright © 2018 Florian Sorin. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

// Define all methods related to IA
extension GameScene {
    
    func createIAHands() {
        handsIA.append(createHandNode(angle : CGFloat(-Double.pi / 2), position : CGPoint(x: 0, y: frame.height * 5 / 8)))
        handsIA.append(createHandNode(angle : CGFloat(Double.pi), position : CGPoint(x: frame.width / 2, y: frame.height)))
        handsIA.append(createHandNode(angle : CGFloat(Double.pi / 2), position : CGPoint(x: frame.width, y: frame.height * 5 / 8)))
        
        for hand in handsIA {
            addChild(hand)
        }
    }
    
    func createHandNode(angle : CGFloat, position : CGPoint) -> SKSpriteNode {
        // Middle card
        let card3 = createCardNode(cardTexture: backTexture, cardPosition: position)
        card3.name = "card3"
        // Hand
        let handNodeSize = card3.size // CGSize(width: frame.width, height: 2 * card1.size.height)
        let handNode = SKSpriteNode(color: self.backgroundColor, size: handNodeSize)
        handNode.position = position
        handNode.zPosition = -100
        // Correct middle card position
        card3.position = CGPoint(x: 0, y: 0)
        // Other cards custom parameters
        let cardsAngle = CGFloat(Double.pi / 8)
        let cardsAnchor = CGPoint(x: 0, y: 0)
        // Correct position to match the anchor changing
        let dx = (cardsAnchor.x - card3.anchorPoint.x) * card3.size.width
        let dy = (cardsAnchor.y - card3.anchorPoint.y) * card3.size.height
        let relativePosition = CGPoint(x: card3.position.x + dx, y: card3.position.y + dy)
        // Upper cards
        let card4 = createCardNode(cardTexture: backTexture, cardPosition: relativePosition, angle: -cardsAngle, depthPosition: 10, cardAnchor: cardsAnchor)
        card4.name = "card4"
        let card5 = createCardNode(cardTexture: backTexture, cardPosition: relativePosition, angle: -2 * cardsAngle, depthPosition: 20, cardAnchor: cardsAnchor)
        card5.name = "card5"
        // Lower cards
        let card2 = createCardNode(cardTexture: backTexture, cardPosition: relativePosition, angle: cardsAngle, depthPosition: -10, cardAnchor: cardsAnchor)
        card2.name = "card2"
        let card1 = createCardNode(cardTexture: backTexture, cardPosition: relativePosition, angle: 2 * cardsAngle, depthPosition: -20, cardAnchor: cardsAnchor)
        card1.name = "card1"
        // Add cards to the hand
        handNode.addChild(card1)
        handNode.addChild(card2)
        handNode.addChild(card3)
        handNode.addChild(card4)
        handNode.addChild(card5)
        // Rotate the hand
        handNode.zRotation = angle
        return handNode
    }
    
    func displayIAHands() {
        for index in 1...players.count - 1 {
            players[index].sortCards()
            for (index2, card) in players[index].cards.enumerated() {
                if let cardNode : SKSpriteNode = handsIA[index - 1].childNode(withName: "card\(index2 + 1)") as? SKSpriteNode {
                    cardNode.texture = showIAHands ? card.picture : backTexture
                    cardNode.isHidden = false
                }
            }
            if players[index].cards.count < 5 {
                for index2 in players[index].cards.count...5 {
                    if let cardNode : SKSpriteNode = handsIA[index - 1].childNode(withName: "card\(index2 + 1)") as? SKSpriteNode {
                        cardNode.isHidden = true
                    }
                }
            }
        }
        

    }
}
