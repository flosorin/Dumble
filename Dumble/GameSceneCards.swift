//
//  GameSceneCards.swift
//  Dumble
//
//  Created by Florian Sorin on 16/04/2018.
//  Copyright © 2018 Florian Sorin. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

// Define all methods related to cards management
extension GameScene {
    
    func createCardNode(cardTexture : SKTexture, cardPosition : CGPoint) -> SKSpriteNode {
        // Create the base of a card
        let card = SKSpriteNode(texture: cardTexture)
        card.zPosition = 10
        card.position = cardPosition
        // Resize it keeping aspect ratio
        card.size = resizeWidth(oldSize: card.size, newWidth: frame.width / 7)
        return card
    }
    
    func createPileNode() {
        let pileNode = SKSpriteNode(texture: SKTexture(imageNamed: "pile"))
        pileNode.size = resizeHeight(oldSize: pileNode.size, newHeight: playerCardsNodes[0].size.height)
        pileNode.position = CGPoint(x: frame.width / 2, y: frame.height * 5 / 8)
        pileNode.name = "pile"
        addChild(pileNode)
    }
    
    func pileTouchManager() {
        // Check if the interaction is legit
        if (player.isSwitchAllowed()) {
            resetPlayerCardsPosition()
            givePileTopToPlayer() // Call generic method
            player.resetSelected()
            updatePlayerHandScore()
        }
    }
    
    func givePileTopToPlayer() {
        // The player recover the top card of the pile
        switchPlayerCards(cardToPick: pile.cards[pile.topCard])
        // Update the pile top card
        if pile.topCard > 0 {
            pile.topCard -= 1
        } else { // If there is no card left, the discard become the new pile
            if let cardTmp = discard.last {
                discard.removeLast()
                pile.reconstruct(withCards: discard)
                discard.removeAll()
                discard.append(cardTmp)
            }
        }
    }
    
    func switchPlayerCards(cardToPick: Card) {
        // The selected cards go to the discard
        for card in player.cards {
            if card.isSelected {
                discard.append(card)
            }
        }
        player.removeSelectedCards()
        player.addCard(card: cardToPick)
    }
    
    func dealCards() {
        // Melt the pile
        pile.melt()
        
        // Reset players (remove all cards and reset scores)
        player.reset()
        playerIA1.reset()
        playerIA2.reset()
        playerIA3.reset()
        
        // Deal the cards (all players)
        for _ in 0...4 {
            player.addCard(card: pile.cards[pile.topCard])
            pile.topCard -= 1
            playerIA1.addCard(card: pile.cards[pile.topCard])
            pile.topCard -= 1
            playerIA2.addCard(card: pile.cards[pile.topCard])
            pile.topCard -= 1
            playerIA3.addCard(card: pile.cards[pile.topCard])
            pile.topCard -= 1
        }
        // Deal the initial discard card
        discard.append(pile.cards[pile.topCard])
        pile.topCard -= 1
        
        // Update the hand score label
        updatePlayerHandScore()
        
        handLeft.isHidden = false
        handTop.isHidden = false
        handRight.isHidden = false
    }
}
