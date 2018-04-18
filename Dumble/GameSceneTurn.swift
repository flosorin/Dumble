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
        if (playerIndex < players.count - 1) {
            playerIndex += 1
        } else {
            playerIndex = 0
        }
        // Check if an IA has to play
        if (playerIndex > 0) {
            // TO BE REMOVED
            tmpWaitingForYouLabelNode.isHidden = true
            // Construct the list of available cards
            var cardsAvailable : [Card] = []
            for index in (discard.count - nbDiscardCardsToShow)...(discard.count - 1) {
                cardsAvailable.append(discard[index])
            }
            // Play the IA turn (1 second delay to see it)
            let cardToPickIndex = (self.players[self.playerIndex] as! PlayerIA).playTurn(cardsAvailable: cardsAvailable)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                if  cardToPickIndex >= 0 {
                    self.giveDiscardToPlayer(discardIndex: (self.discard.count - 1) - cardToPickIndex)
                } else {
                    self.givePileTopToPlayer()
                }
            })
        }
        else {
            tmpWaitingForYouLabelNode.isHidden = false
        }
    }
}
