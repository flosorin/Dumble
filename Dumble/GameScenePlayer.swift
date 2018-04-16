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
    
    func createPlayer() {
        createPlayerHand()
        createPlayerHandScoreLabel()
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
        playerHandScoreLabelNode.position = CGPoint(x: playerCardsNodes[0].size.width, y: playerCardsNodes[0].size.height / 2)
        addChild(playerHandScoreLabelNode)
    }
    
    func displayPlayerCards() {
        switch player.cards.count {
        case 0:
            for index in 0...4 {
                playerCardsNodes[index].isHidden = true
            }
        default:
            player.sortCards()
            for index in 0...player.cards.count - 1 {
                playerCardsNodes[index].texture = player.cards[index].picture
                playerCardsNodes[index].isHidden = false
            }
            if player.cards.count < playerCardsNodes.count {
                for index in player.cards.count...playerCardsNodes.count - 1 {
                    playerCardsNodes[index].isHidden = true
                }
            }
        }
    }
    
    func playerCardsTouchManager (cardNode: SKSpriteNode) {
        let index = playerCardsNodes.index(of: cardNode)!
        // If the card is in its standard position, check if we can select it
        if (cardNode.position.y == 1.5 * playerCardsNodes[0].size.height) {
            if (player.isCardSelectable(index: index)) {
                // Make the card goes up to indicate that it is selected
                cardNode.position.y += playerCardsNodes[0].size.height / 2
                player.cards[index].isSelected = true
            }
        } else {
            // Always possible to go back to initial position
            cardNode.position.y -= playerCardsNodes[0].size.height / 2
            player.cards[index].isSelected = false
            // Reset player selected flags if there is one or less card(s) selected
            if (player.nbCardsSelected() <= 1) {
                player.resetSelected()
            }
        }
    }
    
    func resetPlayerCardsPosition() {
        for cardNode in playerCardsNodes {
            cardNode.position.y = 1.5 * playerCardsNodes[0].size.height
        }
    }
    
    func updatePlayerHandScore() {
        player.updateHandScore()
        playerHandScoreLabelNode.text = "Hand: \(player.handScore)"
    }
}
