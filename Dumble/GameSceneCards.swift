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
    
    func createDiscardNodes() {
        // Create the first card
        discardCardsNodes.append(createCardNode(cardTexture: backTexture, cardPosition: CGPoint(x: 0, y: 0)))
        discardCardsNodes[0].position = CGPoint(x: discardCardsNodes[0].size.width, y: 3.5 * discardCardsNodes[0].size.height)
        discardCardsNodes[0].name = "discard0"
        discardCardsList.updateValue(discardCardsNodes[0], forKey: "discard0")
        addChild(discardCardsNodes[0])
        // Create the others according to the first card position
        for index in 1...4 {
            discardCardsNodes.append(createCardNode(cardTexture: backTexture, cardPosition: CGPoint(x: discardCardsNodes[index - 1].position.x + 1.25 * discardCardsNodes[0].position.x, y: discardCardsNodes[0].position.y)))
            discardCardsNodes[index].name = "discard\(index)"
            discardCardsList.updateValue(discardCardsNodes[index], forKey: "discard\(index)")
            addChild(discardCardsNodes[index])
        }
    }
    
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
    
    func discardTouchManager (cardNode: SKSpriteNode) {
        let index = (discard.count - 1) - discardCardsNodes.index(of: cardNode)!
        // Check if the interaction is legit
        if (player.isSwitchAllowed()) {
            resetPlayerCardsPosition()
            giveDiscardToPlayer(index: index) // Call generic method
            player.resetSelected()
            updatePlayerHandScore()
        }
    }
    
    func giveDiscardToPlayer(index: Int) {
        // The player recover the selected discard card
        switchPlayerCards(cardToPick: discard[index].clone())
        // The card is removed from the discard
        discard.remove(at: index)
    }
    
    func switchPlayerCards(cardToPick: Card) {
        // The selected cards go to the discard
        for card in player.cards {
            if card.isSelected {
                discard.append(card.clone())
                discard.last?.isSelected = false
            }
        }
        nbDiscardCardsToShow = player.nbCardsSelected()
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
        nbDiscardCardsToShow = 1
        pile.topCard -= 1
        
        // Update the hand score label
        updatePlayerHandScore()
        
        handLeft.isHidden = false
        handTop.isHidden = false
        handRight.isHidden = false
    }
    
    func displayDiscardCards() {
        if (nbDiscardCardsToShow != 0) {
            for index in 0...nbDiscardCardsToShow - 1 {
                discardCardsNodes[index].texture = discard[(discard.count - 1) - index].picture
                discardCardsNodes[index].isHidden = false
            }
            if (nbDiscardCardsToShow < discardCardsNodes.count) {
                for index in nbDiscardCardsToShow...discardCardsNodes.count - 1 {
                    discardCardsNodes[index].isHidden = true
                }
            }
        } else {
            for card in discardCardsNodes {
                card.isHidden = true
            }
        }
    }
}
