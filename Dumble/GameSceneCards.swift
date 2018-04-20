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
    
    func createCardNode(cardTexture: SKTexture, cardPosition: CGPoint, angle: CGFloat = 0.0, depthPosition: CGFloat = 0.0, cardAnchor: CGPoint = CGPoint(x: 0.5, y: 0.5)) -> SKSpriteNode {
        // Create the base of a card
        let card = SKSpriteNode(texture: cardTexture)
        card.anchorPoint = cardAnchor
        card.position = cardPosition
        card.zRotation = angle
        card.zPosition = depthPosition
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
        // Firstly, check if this is the user turn
        if playerIndex == 0 {
            // Then, check if the interaction is legit
            if (players[0] as! PlayerUser).isSwitchAllowed() {
                resetPlayerCardsPosition()
                givePileTopToPlayer() // Call generic method
                (players[0] as! PlayerUser).resetSelectedFlags()
            }
        }
    }
    
    func givePileTopToPlayer() {
        // The player recover the top card of the pile
        switchPlayerCards(cardToPick: pile.cards[pile.topCard])
        // Update the pile top card
        if pile.topCard > 0 {
            pile.topCard -= 1
        } else { // If there is no card left, the discard become the new pile (we just keep the last card(s))
            // Copy the last cards before removing it to avoid copying it to the pile
            var discardTmp = discard[discard.count - nbDiscardCardsToShow...discard.count - 1]
            discard.removeLast(nbDiscardCardsToShow)
            // Reconstruct the pile
            pile.reconstruct(withCards: discard)
            // Reconstruct the discard
            discard.removeAll()
            discard.append(contentsOf: discardTmp)
            discardTmp.removeAll()
        }
    }
    
    func discardTouchManager (cardNode: SKSpriteNode) {
        // Firstly, check if this is the user turn
        if playerIndex == 0 {
            // Check if the interaction is legit
            if (players[0] as! PlayerUser).isSwitchAllowed() {
                // Recover the true index
                if let nodeIndexes = cardNodesIndexes[nbDiscardCardsToShow] {
                    if let nodeIndex = nodeIndexes.index(of: discardCardsNodes.index(of: cardNode)!) {
                        let index = (discard.count - 1) - nodeIndex
                        resetPlayerCardsPosition()
                        giveDiscardToPlayer(discardIndex: index) // Call generic method
                        (players[0] as! PlayerUser).resetSelectedFlags()
                    }
                }
            }
        }
    }
    
    func giveDiscardToPlayer(discardIndex: Int) {
        // The player recover the selected discard card
        switchPlayerCards(cardToPick: discard[discardIndex].clone())
        // The card is removed from the discard
        discard.remove(at: discardIndex)
    }
    
    func switchPlayerCards(cardToPick: Card) {
        // The selected cards go to the discard
        for card in players[playerIndex].cards {
            if card.isSelected {
                discard.append(card.clone())
                discard.last?.isSelected = false
            }
        }
        nbDiscardCardsToShow = players[playerIndex].nbCardsSelected()
        players[playerIndex].removeSelectedCards()
        // The player recover the card he wanted to pick
        players[playerIndex].addCard(card: cardToPick)
        // Tells the next player that it is its turn
        playTurn()
    }
    
    func dealCards() {
        // Melt the pile
        pile.melt()
        
        // Reset players
        for player in players {
            player.reset(resetAll: dealButtonPressed)
        }
        if dealButtonPressed {
            dealButtonPressed = false // Reset the state of the deal button
            startingPlayerIndex = -1 // Reset the starting player (always the user at the beginning of the game)
            updateScoreLabels() // Reset the score labels
        }
        
        // Update the starting player
        if startingPlayerIndex < players.count - 1 {
            startingPlayerIndex += 1
        } else {
            startingPlayerIndex = 0
        }
        
        // Deal the cards (all players still in game)
        for _ in 0...4 {
            for player in players {
                if !player.gameLose {
                    player.addCard(card: pile.cards[pile.topCard])
                    pile.topCard -= 1
                }
            }
        }
        
        // Deal the initial discard card
        discard.append(pile.cards[pile.topCard])
        nbDiscardCardsToShow = 1
        pile.topCard -= 1
        
        // Launch the turn
        turnCounter = 1
        playerIndex = startingPlayerIndex - 1 // Because playTurn starts by increasing the playerIndex
        playTurn()
    }
    
    func displayDiscardCards() {
        if let nodeIndexes = cardNodesIndexes[nbDiscardCardsToShow] {
            var cardIndex = nbDiscardCardsToShow - 1
            // Hide all nodes
            for cardNode in discardCardsNodes {
                cardNode.isHidden = true
            }
            // Modify and show nodes according to the index list
            for nodeIndex in nodeIndexes {
                discardCardsNodes[nodeIndex].texture = discard[(discard.count - 1) - cardIndex].picture
                discardCardsNodes[nodeIndex].isHidden = false
                cardIndex -= 1
            }
        }
    }
}
