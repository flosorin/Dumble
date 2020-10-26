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
        createPlayerDumbleSaidLabel()
    }
    
    func createPlayerHand() {
        // Create the first card
        playerCardsNodes.append(createCardNode(cardTexture: backTexture, cardPosition: CGPoint(x: 0, y: 0)))
        playerCardsNodes[0].position = CGPoint(x: playerCardsNodes[0].size.width * 1.25, y: 1.5 * playerCardsNodes[0].size.height)
        playerCardsNodes[0].name = "card0"
        playerCardsList.updateValue(playerCardsNodes[0], forKey: "card0")
        addChild(playerCardsNodes[0])
        // Create the others according to the first card position
        for index in 1...4 {
            playerCardsNodes.append(createCardNode(cardTexture: backTexture, cardPosition: CGPoint(x: playerCardsNodes[index - 1].position.x + playerCardsNodes[0].position.x, y: playerCardsNodes[0].position.y)))
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
        dumbleButton = createButton(title: "DUMBLE", textSize: 20)
        dumbleButton.position = CGPoint(x: frame.width - dumbleButton.frame.width * 1.25, y: playerCardsNodes[0].size.height / 2)
        addChild(dumbleButton)
    }
    
    func createPlayerDumbleSaidLabel() {
        dumbleSaidLabelNode = SKLabelNode(text: "DUMBLE")
        dumbleSaidLabelNode.fontSize = 20
        dumbleSaidLabelNode.fontColor = SKColor.white
        dumbleSaidLabelNode.position = CGPoint(x: playerCardsNodes[2].position.x, y: playerCardsNodes[2].position.y + playerCardsNodes[2].size.height / 2 + dumbleSaidLabelNode.frame.height)
        dumbleSaidLabelNode.isHidden = true
        addChild(dumbleSaidLabelNode)
    }
    
    func displayPlayerUserInfos() {
        let handScore = players[0].getHandScore()
        // Update the player cards display
        displayPlayerCards()
        // Show only if we are currently on game
        if (isDealingComplete && !players[0].gameLose) {
            // Update the hand score label
            playerHandScoreLabelNode.isHidden = false
            playerHandScoreLabelNode.text = "Hand: \(handScore)"
        } else {
            playerHandScoreLabelNode.isHidden = true
            dumbleButton.isHidden = true
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
        if let nodeIndex = nodeIndexes.firstIndex(of: playerCardsNodes.firstIndex(of: cardNode)!) {
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
        // Firstly, check if this is the user turn (paranoid as the button is not supposed to be shown if not)
        if playerIndex == 0 {
            // Hide button
            dumbleButton.isHidden = true
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
