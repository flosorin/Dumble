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
        // Create dummy card just to recover its dimensions
        let card = createCardNode(cardTexture: backTexture, cardPosition: CGPoint(x: 0, y: 0))
        // Create hands based on card size
        handsIA.append(createHandNode(angle: CGFloat(-Double.pi / 2), position: CGPoint(x: card.size.height / 3, y: frame.height * 5 / 8)))
        handsIA.append(createHandNode(angle: CGFloat(Double.pi), position: CGPoint(x: frame.width / 2, y: frame.height - (card.size.height / 3))))
        handsIA.append(createHandNode(angle: CGFloat(Double.pi / 2), position: CGPoint(x: frame.width - (card.size.height / 3), y: frame.height * 5 / 8)))
        
        for hand in handsIA {
            addChild(hand)
        }
    }
    
    func createHandNode(angle: CGFloat, position: CGPoint) -> SKSpriteNode {
        // Middle card
        let card3 = createCardNode(cardTexture: backTexture, cardPosition: position)
        card3.name = "card3"
        // Hand
        let handNode = SKSpriteNode(color: self.backgroundColor, size: card3.size)
        handNode.position = position
        handNode.zPosition = -100
        // Correct middle card position
        card3.position = CGPoint(x: 0, y: card3.size.height / 4)
        // Other cards custom parameters
        let cardsAngle = CGFloat(Double.pi / 8)
        let cardsAnchor = CGPoint(x: 0.5, y: 0)
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
        // Create the dumble said label node
        let dumbleSaidLabelNode = SKLabelNode(text: "DUMBLE")
        dumbleSaidLabelNode.name = "DumbleSaid"
        dumbleSaidLabelNode.fontSize = 20
        dumbleSaidLabelNode.fontColor = SKColor.white
        dumbleSaidLabelNode.position = CGPoint(x: card3.position.x, y: card3.position.y + card3.frame.height / 2 + dumbleSaidLabelNode.frame.height)
        dumbleSaidLabelNode.isHidden = true
        handNode.addChild(dumbleSaidLabelNode)
        // Rotate the hand
        handNode.zRotation = angle
        return handNode
    }
    
    func displayIAHands() {
        for index in 1...players.count - 1 {
            let nodeIndexes = cardNodesIndexes[players[index].cards.count]
            var cardIndex = 0
            players[index].sortCards()
            // Hide all nodes
            for nodeIndex in 1...5 {
                if let cardNode : SKSpriteNode = handsIA[index - 1].childNode(withName: "card\(nodeIndex)") as? SKSpriteNode {
                    cardNode.isHidden = true
                }
            }
            // Modify and show nodes according to the index list
            for nodeIndex in nodeIndexes {
                if let cardNode : SKSpriteNode = handsIA[index - 1].childNode(withName: "card\(nodeIndex + 1)") as? SKSpriteNode {
                    cardNode.texture = showIAHands ? players[index].cards[cardIndex].picture : backTexture
                    cardNode.isHidden = false
                }
                cardIndex += 1
            }
        }
    }
}
