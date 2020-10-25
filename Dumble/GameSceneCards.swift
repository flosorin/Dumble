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
    // Create pile animations according to the player
    func createPileAnimations() {
        let animationsDuration = 0.5
        pileAnimations.append(SKAction.moveBy(x: 0.0, y: -frame.height * 0.4, duration: animationsDuration))
        pileAnimations.append(SKAction.moveBy(x: -frame.width * 0.4, y: 0.0, duration: animationsDuration))
        pileAnimations.append(SKAction.moveBy(x: 0.0, y: frame.height * 0.25, duration: animationsDuration))
        pileAnimations.append(SKAction.moveBy(x: frame.width * 0.4, y: 0.0, duration: animationsDuration))
        // Add a effect to move slower at the beginning and the end
        for animation in pileAnimations {
            animation.timingMode = .easeInEaseOut
        }
    }
    // Reconfigure the pile animation duration to match the usage
    func reconfigurePileAnimationsDuration(duration: TimeInterval) {
        for animation in pileAnimations {
            animation.duration = duration
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
        // Disable user interactions while dealing
        isUserInteractionEnabled = false
        
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
        
        // Reconfigure the animations duration to speed up the dealing
        reconfigurePileAnimationsDuration(duration: 0.15)
        
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
                
                // Reconfigure the animations duration for the game
                self.reconfigurePileAnimationsDuration(duration: 0.5)
                
                // Update the display
                self.isDealingComplete = true
                self.updateDisplay()
                
                // Launch the turn
                self.turnCounter = 1
                self.playerIndex = self.startingPlayerIndex - 1 // Because playTurn starts by increasing the playerIndex
                
                // Enable user interactions
                self.isUserInteractionEnabled = true
                
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
            updateDisplay()
        }
    }
    
    func pileTouchManager() {
        // Firstly, check if this is the user turn
        if playerIndex == 0 {
            // Then, check if the interaction is legit
            if (players[0] as! PlayerUser).isSwitchAllowed() {
                givePileTopToPlayer() // Call generic method
            }
        }
    }
    
    func givePileTopToPlayer() {
        nbDiscardCardsToShow = players[playerIndex].nbCardsSelected()
        DispatchQueue.global(qos: .background).async {
            // Animate and wait for the end of the animation before playing next player turn
            self.animatePileTopToPlayer(index: self.playerIndex)
            self.animatePlayerToDiscard()
            while (!self.isCardGiven) && (self.nbCardsDiscarded < self.nbDiscardCardsToShow) {}
            DispatchQueue.main.async {
                // The player recover the top card of the pile
                self.switchPlayerCards(cardToPick: self.pile.cards[self.pile.topCard])
                // Update the pile top card
                if self.pile.topCard > 0 {
                    self.pile.topCard -= 1
                } else { // If there is no card left, the discard become the new pile (we just keep the last card(s))
                    // Copy the last cards before removing it to avoid copying it to the pile
                    var discardTmp = self.discard[self.discard.count - self.nbDiscardCardsToShow...self.discard.count - 1]
                    self.discard.removeLast(self.nbDiscardCardsToShow)
                    // Reconstruct the pile
                    self.pile.reconstruct(withCards: self.discard)
                    // Reconstruct the discard
                    self.discard.removeAll()
                    self.discard.append(contentsOf: discardTmp)
                    discardTmp.removeAll()
                }
                // Update the display
                if self.playerIndex == 0 {
                    self.resetPlayerCardsPosition()
                    (self.players[0] as! PlayerUser).resetSelectedFlags()
                }
                self.updateDisplay()
                // Play the next player turn
                self.playTurn()
            }
        }
    }
    
    func animatePileTopToPlayer(index: Int) {
        if showAnimations {
            let cardNode = createCardNode(cardTexture: backTexture, cardPosition: CGPoint(x: frame.width / 2, y: frame.height * 5 / 8))
            animateGeneric(cardNode: cardNode, animation: pileAnimations[index])
        } else {
            isCardGiven = true
        }
    }
    
    func animateGeneric(cardNode: SKSpriteNode, animation: SKAction) {
        addChild(cardNode)
        isCardGiven = false
        cardNode.run(animation, completion: {
            // Remove the temporary node
            cardNode.removeFromParent()
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
                if let nodeIndex = nodeIndexes.firstIndex(of: discardCardsNodes.firstIndex(of: cardNode)!) {
                    let index = discard.count - nbDiscardCardsToShow + nodeIndex
                    giveDiscardToPlayer(discardIndex: index) // Call generic method
                }
            }
        }
    }
    
    func giveDiscardToPlayer(discardIndex: Int) {
        // Recover the discard node index before updating the number of discard cards to show
        let discardNodeIndex = self.cardNodesIndexes[self.nbDiscardCardsToShow][discardIndex - self.discard.count + self.nbDiscardCardsToShow]
        // Update the number of discard cards to show (for player to discard animation)
        nbDiscardCardsToShow = players[playerIndex].nbCardsSelected()
        DispatchQueue.global(qos: .background).async {
            // Animate and wait for the end of the animation before playing next player turn
            self.animateDiscardToPlayer(discardNodeIndex: discardNodeIndex)
            self.animatePlayerToDiscard()
            while (!self.isCardGiven) && (self.nbCardsDiscarded < self.nbDiscardCardsToShow) {}
            DispatchQueue.main.async {
                // The player recover the selected discard card
                self.switchPlayerCards(cardToPick: self.discard[discardIndex].clone())
                // The card is removed from the discard
                self.discard.remove(at: discardIndex)
                // Update the display
                if self.playerIndex == 0 {
                    self.resetPlayerCardsPosition()
                    (self.players[0] as! PlayerUser).resetSelectedFlags()
                }
                self.updateDisplay()
                // Play the next player turn
                self.playTurn()
            }
        }
    }
    
    func animateDiscardToPlayer(discardNodeIndex: Int) {
        if showAnimations {
            let cardNode = discardCardsNodes[discardNodeIndex].copy() as! SKSpriteNode
            let animation = getDiscardAnimation(discardNodeIndex: discardNodeIndex, reversed: true)
            discardCardsNodes[discardNodeIndex].isHidden = true
            animateGeneric(cardNode: cardNode, animation: animation)
        } else {
            isCardGiven = true
        }
    }
    
    func animatePlayerToDiscard() {
        if showAnimations {
            let discardNodeIndexes = cardNodesIndexes[nbDiscardCardsToShow]
            let playerNodeIndexes = cardNodesIndexes[players[playerIndex].cards.count]
            var nodeIndex = 0
            var cardNode = SKSpriteNode(texture: backTexture)
            if playerIndex > 0 {
                cardNode = createCardNode(cardTexture: backTexture, cardPosition: handsIA[playerIndex - 1].position)
            }
            var animation = getDiscardAnimation(discardNodeIndex: discardNodeIndexes[nodeIndex], reversed: false)
            self.nbCardsDiscarded = 0
            for (index, card) in players[playerIndex].cards.enumerated() {
                if card.isSelected {
                    if playerIndex == 0 {
                        let playerCardNodeIndex = playerNodeIndexes[index]
                        cardNode = playerCardsNodes[playerCardNodeIndex].copy() as! SKSpriteNode
                        playerCardsNodes[playerCardNodeIndex].isHidden = true
                        animation = getDiscardAnimation(discardNodeIndex: discardNodeIndexes[nodeIndex], reversed: false, playerCardNodeIndex: playerCardNodeIndex)
                    } else {
                        animation = getDiscardAnimation(discardNodeIndex: discardNodeIndexes[nodeIndex], reversed: false)
                    }
                    let cardNodeCopy = cardNode.copy() as! SKSpriteNode
                    addChild(cardNodeCopy)
                    cardNodeCopy.run(animation, completion: {
                        // Remove the temporary node
                        cardNodeCopy.removeFromParent()
                        // Update the number of discarded cards
                        self.nbCardsDiscarded += 1
                    })
                    nodeIndex += 1
                }
            }
        } else {
            isCardGiven = true
        }
    }
    
    // Get the discard animation according to the current player, the node and the way needed
    // reversed = true: from discard to player
    // reversed = false: from player to discard
    func getDiscardAnimation(discardNodeIndex: Int, reversed: Bool, playerCardNodeIndex: Int = 2) -> SKAction {
        let moveCoordinates = getDiscardMove(discardNodeIndex: discardNodeIndex, playerCardNodeIndex: playerCardNodeIndex)
        let way: CGFloat = reversed ? -1.0 : 1.0
        let animation = SKAction.moveBy(x: way * moveCoordinates.x, y: way * moveCoordinates.y, duration: 0.5)
        animation.timingMode = .easeInEaseOut
        return animation
    }
    
    func getDiscardMove(discardNodeIndex: Int, playerCardNodeIndex: Int = 2) -> CGPoint {
        let dx, dy: CGFloat
        if playerIndex == 0 {
            dx = discardCardsNodes[discardNodeIndex].position.x - playerCardsNodes[playerCardNodeIndex].position.x
            dy = discardCardsNodes[discardNodeIndex].position.y - playerCardsNodes[playerCardNodeIndex].position.y
        }  else {
            dx = discardCardsNodes[discardNodeIndex].position.x - handsIA[playerIndex - 1].position.x
            dy = discardCardsNodes[discardNodeIndex].position.y - handsIA[playerIndex - 1].position.y
        }

        return CGPoint(x: dx, y: dy)
    }
    
    func switchPlayerCards(cardToPick: Card) {
        // The selected cards go to the discard
        for card in players[playerIndex].cards {
            if card.isSelected {
                discard.append(card.clone())
                discard.last?.isSelected = false
            }
        }
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
