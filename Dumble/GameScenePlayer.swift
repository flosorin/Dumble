//
//  GameScenePlayer.swift
//  Dumble
//
//  Created by Florian Sorin on 16/04/2018.
//  Copyright © 2018 Florian Sorin. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

// Define all methods related to the player "user"
extension GameScene {
    
    func createPlayerDisplay() {
        createPlayerHand()
        createPlayerHandScoreLabel()
        createPlayerDumbleButton()
    }
    
    func createPlayerHand() {
        // Create the first card
        playerCardsNodes.append(createCardNode(cardTexture: backTexture, cardPosition: CGPoint(x: 0, y: 0)))
        playerCardsNodes[0].position = CGPoint(x: playerCardsNodes[0].size.width, y: 1.5 * playerCardsNodes[0].size.height)
        playerCardsNodes[0].name = "card0"
        playerCardsList.updateValue(playerCardsNodes[0], forKey: "card0")
        addChild(playerCardsNodes[0])
        // Create the others according to the first card position
        for index in 1...4 {
            playerCardsNodes.append(createCardNode(cardTexture: backTexture, cardPosition: CGPoint(x: playerCardsNodes[index - 1].position.x + 1.25 * playerCardsNodes[0].position.x, y: playerCardsNodes[0].position.y)))
            playerCardsNodes[index].name = "card\(index)"
            playerCardsList.updateValue(playerCardsNodes[index], forKey: "card\(index)")
            addChild(playerCardsNodes[index])
        }
    }
    
    func createPlayerHandScoreLabel() {
        playerHandScoreLabelNode = SKLabelNode(text: "Hand: 0")
        playerHandScoreLabelNode.fontSize = 20
        playerHandScoreLabelNode.fontColor = SKColor.white
        playerHandScoreLabelNode.position = CGPoint(x: frame.midX, y: playerCardsNodes[0].size.height / 2)
        addChild(playerHandScoreLabelNode)
    }
    
    func createPlayerDumbleButton() {
        // TO BE REPLACED BY REAL BUTTON
        dumbleButtonLabelNode = SKLabelNode(text: "DUMBLE!")
        dumbleButtonLabelNode.fontSize = 20
        dumbleButtonLabelNode.fontColor = SKColor.white
        dumbleButtonLabelNode.position = CGPoint(x: frame.width - dumbleButtonLabelNode.frame.width * 0.75, y: playerCardsNodes[0].size.height / 2)
        dumbleButtonLabelNode.name = "dumble"
        addChild(dumbleButtonLabelNode)
    }
    
    func displayPlayerUserInfos() {
        let handScore = players[0].getHandScore()
        // Update the player cards display
        displayPlayerCards()
        // Show only if we are currently on game
        if (isDealingComplete) {
            // Update the hand score label
            playerHandScoreLabelNode.isHidden = false
            playerHandScoreLabelNode.text = "Hand: \(handScore)"
            // Show or hide the dumble button
            if handScore > 9 {
                dumbleButtonLabelNode.isHidden = true
            } else {
                dumbleButtonLabelNode.isHidden = false
            }
        } else {
            playerHandScoreLabelNode.isHidden = true
            dumbleButtonLabelNode.isHidden = true
        }
    }
    
    func displayPlayerCards() {
        let nodeIndexes = cardNodesIndexes[players[0].cards.count]
        var cardIndex = 0
        players[0].sortCards()
        // Hide all nodes
        for cardNode in playerCardsNodes {
            cardNode.isHidden = true
        }
        // Modify and show nodes according to the index list
        for nodeIndex in nodeIndexes {
            playerCardsNodes[nodeIndex].texture = players[0].cards[cardIndex].picture
            playerCardsNodes[nodeIndex].isHidden = false
            cardIndex += 1
        }
    }
    
    func playerCardsTouchManager(cardNode: SKSpriteNode) {
        let nodeIndexes = cardNodesIndexes[players[0].cards.count]
        if let nodeIndex = nodeIndexes.index(of: playerCardsNodes.index(of: cardNode)!) {
            // If the card is in its standard position, check if we can select it
            if cardNode.position.y == 1.5 * playerCardsNodes[0].size.height {
                if (players[0] as! PlayerUser).isCardSelectable(index: nodeIndex) {
                    // Make the card goes up to indicate that it is selected
                    cardNode.position.y += playerCardsNodes[0].size.height / 2
                    players[0].cards[nodeIndex].isSelected = true
                }
            } else {
                // Always possible to go back to initial position
                cardNode.position.y -= playerCardsNodes[0].size.height / 2
                players[0].cards[nodeIndex].isSelected = false
                // Reset player selected flags if there is one or less card(s) selected
                if players[0].nbCardsSelected() <= 1 {
                    (players[0] as! PlayerUser).resetSelectedFlags()
                }
            }
        }
    }
    
    func dumbleButtonTouchManager() {
        // Firstly, check if this is the user turn
        if playerIndex == 0 {
            // Call generic method
            dumbleManagement()
        }
    }
    
    func resetPlayerCardsPosition() {
        for cardNode in playerCardsNodes {
            cardNode.position.y = 1.5 * playerCardsNodes[0].size.height
        }
    }
}
