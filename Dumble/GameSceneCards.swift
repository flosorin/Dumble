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
    
    func createCardsAnimation() {
        // Create animation according to the player
        let animationDuration = 0.25
        pileAnimations.append(SKAction.moveBy(x: 0.0, y: -frame.height * 0.4, duration: animationDuration))
        pileAnimations.append(SKAction.moveBy(x: -frame.width * 0.4, y: 0.0, duration: animationDuration))
        pileAnimations.append(SKAction.moveBy(x: 0.0, y: frame.height * 0.25, duration: animationDuration))
        pileAnimations.append(SKAction.moveBy(x: frame.width * 0.4, y: 0.0, duration: animationDuration))
        // Add a effect to move slower at the beginning and the end
        for action in pileAnimations {
            action.timingMode = .easeInEaseOut
        }
    }
    
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
    
    func dealCards() {
        // Update the display
        isDealingComplete = false
        updateDisplay()
        
        // Re-create a pile and melt it
        pile = Deck()
        pile.melt()
        
        // Reset players and show labels
        for (index, player) in players.enumerated() {
            player.reset(resetAll: dealButtonPressed)
            playersNameLabelNodes[index].isHidden = false
            playersScoreLabelNodes[index].isHidden = false
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
        // All the dealing is done in background to be able to wait for the animations to end
        DispatchQueue.global(qos: .background).async {
            // Deal the cards (all players still in game), starting with the starting player
            for _ in 0...4 {
                for index in self.startingPlayerIndex...(self.players.count - 1) {
                    self.dealOneCardToPlayer(index: index)
                }
                if self.startingPlayerIndex > 0 {
                    for index in 0...self.startingPlayerIndex - 1 {
                        self.dealOneCardToPlayer(index: index)
                    }
                }
            }
            
            // Now we can go back to main thread
            DispatchQueue.main.async {
                // Deal the initial discard card
                self.discard.append(self.pile.cards[self.pile.topCard])
                self.nbDiscardCardsToShow = 1
                self.pile.topCard -= 1
                
                // Update the display
                self.isDealingComplete = true
                self.updateDisplay()
                
                // Launch the turn
                self.turnCounter = 1
                self.playerIndex = self.startingPlayerIndex - 1 // Because playTurn starts by increasing the playerIndex
            
                self.playTurn() // Play the next player turn in main thread
            }
        }
    }
    
    func dealOneCardToPlayer(index: Int) {
        // Check if the player is still in game
        if !players[index].gameLose {
            // Give the top card to the player
            players[index].addCard(card: pile.cards[pile.topCard])
            pile.topCard -= 1
            // Animate and wait for the end of the animation
            animatePileTopToPlayer(index: index)
            while(!isCardGiven) {}
        }
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
        // Animate and wait for the end of the animation before playing next player turn
        DispatchQueue.global(qos: .background).async {
            self.animatePileTopToPlayer(index: self.playerIndex) // Launch the animation
            while(!self.isCardGiven) {} // Wait for the end of it
            DispatchQueue.main.async {
                self.playTurn() // Play the next player turn
            }
        }
    }
    
    func animatePileTopToPlayer(index: Int) {
        let cardNode = createCardNode(cardTexture: backTexture, cardPosition: CGPoint(x: frame.width / 2, y: frame.height * 5 / 8))
        addChild(cardNode)
        isCardGiven = false
        cardNode.run(self.pileAnimations[index], completion: {
            // Remove the temporary node
            self.removeChildren(in: [cardNode])
            self.updateDisplay()
            // Tell that the animation has been completed
            self.isCardGiven = true
        })
    }
    
    func discardTouchManager (cardNode: SKSpriteNode) {
        // Firstly, check if this is the user turn
        if playerIndex == 0 {
            // Check if the interaction is legit
            if (players[0] as! PlayerUser).isSwitchAllowed() {
                // Recover the true index
                let nodeIndexes = cardNodesIndexes[nbDiscardCardsToShow]
                if let nodeIndex = nodeIndexes.index(of: discardCardsNodes.index(of: cardNode)!) {
                    let index = discard.count - nbDiscardCardsToShow + nodeIndex
                    resetPlayerCardsPosition()
                    giveDiscardToPlayer(discardIndex: index) // Call generic method
                    (players[0] as! PlayerUser).resetSelectedFlags()
                }
            }
        }
    }
    
    func giveDiscardToPlayer(discardIndex: Int) {
        // The player recover the selected discard card
        switchPlayerCards(cardToPick: discard[discardIndex].clone())
        // The card is removed from the discard
        discard.remove(at: discardIndex)
        // Update the display
        updateDisplay()
        // Tells the next player that it is its turn
        playTurn()
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
    }
    
    func displayDiscardCards() {
        let nodeIndexes = cardNodesIndexes[nbDiscardCardsToShow]
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
