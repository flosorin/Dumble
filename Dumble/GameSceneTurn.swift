//
//  GameSceneTurn.swift
//  Dumble
//
//  Created by Florian Sorin on 18/04/2018.
//  Copyright © 2018 Florian Sorin. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

// Define all methods related to a game turn
extension GameScene {
    
    func playTurn() {
        // Update the player index
        if playerIndex < players.count - 1 {
            playerIndex += 1
        } else {
            playerIndex = 0
            turnCounter += 1 // If we go back to the first player, one turn has been completed
        }
        // Change the color of the name of the current player
        for (index, nameNode) in playersNameLabelNodes.enumerated() {
            if index == playerIndex {
                nameNode.fontColor = SKColor.red
            } else {
                nameNode.fontColor = SKColor.white
            }
        }
        // Check if an IA has to play
        if playerIndex > 0 {
            // Construct the list of available cards
            var cardsAvailable : [Card] = []
            for index in (discard.count - nbDiscardCardsToShow)...(discard.count - 1) {
                cardsAvailable.append(discard[index])
            }
            // Play the IA turn (1 second delay to see it)
            let cardToPickIndex = (self.players[self.playerIndex] as! PlayerIA).playTurn(cardsAvailable: cardsAvailable, nbTurn: turnCounter, otherPlayersNbCards: getOtherPlayersNbCard())
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                if  cardToPickIndex >= 0 {
                    self.giveDiscardToPlayer(discardIndex: (self.discard.count - 1) - cardToPickIndex)
                } else if cardToPickIndex == -1 {
                    self.givePileTopToPlayer()
                } else {
                    self.dumbleManagement()
                }
            })
        }
    }
    
    func getOtherPlayersNbCard() -> [Int] {
        var otherPlayersNbCard: [Int] = []
        
        for (index, player) in players.enumerated() {
            if index != playerIndex {
                otherPlayersNbCard.append(player.cards.count)
            }
        }
        
        return otherPlayersNbCard
    }
    
    func dumbleManagement() {
        print("Player \(playerIndex) said dumble") // TO BE REPLACED BY PROPER ANIMATION
        dealCards()
    }
}
