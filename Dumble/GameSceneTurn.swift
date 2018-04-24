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
        // Update the player index (also avoid attributing it to a player who lost the game)
        repeat {
            if playerIndex < players.count - 1 {
                playerIndex += 1
            } else {
                playerIndex = 0
                turnCounter += 1 // If we go back to the first player, one turn has been completed
            }
        } while players[playerIndex].gameLose
        
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
        isUserInteractionEnabled = false
        // Reset user specific elements
        resetPlayerCardsPosition()
        (players[0] as! PlayerUser).resetSelectedFlags()
        // Reset the color of the label of the current player name
        playersNameLabelNodes[playerIndex].fontColor = SKColor.white
        // Show the cards of the IA and the dumble said label for the current player
        showIAHands = true
        displayDumbleSaidLabel(hide: false, playerIndex: playerIndex)
        // Check if the player as the lower score
        let counterPlayerIndex = playerWithLowestHandScoreIndex()
        if counterPlayerIndex == playerIndex {
            for (index, player) in players.enumerated() {
                if index != playerIndex {
                    player.updateScore() // All other players add their hand score to their score
                }
            }
        } else {
            players[playerIndex].updateScore(dumbleFailed: true) // The player adds 25 to its score
            displayDumbleSaidLabel(hide: false, playerIndex: counterPlayerIndex, text: "NOPE!")
        }
        updateDisplay()
        // Wait 3 seconds for the user to see the animations
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
            // Update score labels
            self.updateScoreLabels()
            // Empty the discard
            self.discard.removeAll()
            self.nbDiscardCardsToShow = 0
            // Re-deal the cards if the game is not over
            if !self.isGameOver() {
                // First, re-hide the IA cards and the dumble said label
                self.showIAHands = false
                self.displayDumbleSaidLabel(hide: true, playerIndex: self.playerIndex)
                self.displayDumbleSaidLabel(hide: true, playerIndex: counterPlayerIndex)
                self.dealCards()
            }
        })
    }
    
    func displayDumbleSaidLabel(hide: Bool, playerIndex: Int, text: String = "DUMBLE") {
        if playerIndex == 0 {
            dumbleSaidLabelNode.text = text
            dumbleSaidLabelNode.isHidden = hide
        } else {
            (handsIA[playerIndex - 1].childNode(withName: "DumbleSaid") as! SKLabelNode).text = text
            handsIA[playerIndex - 1].childNode(withName: "DumbleSaid")?.isHidden = hide
        }
    }
    
    func playerWithLowestHandScoreIndex() -> Int {
        // Check for lower hand scores
        for (index, player) in players.enumerated() {
            if (index != playerIndex) && (!player.gameLose) && (player.getHandScore() <= players[playerIndex].getHandScore()) {
                return index
            }
        }
        
        return playerIndex
    }
    
    func isGameOver() -> Bool {
        var nbLost = 0
        
        for player in players {
            if player.gameLose {
                nbLost += 1
            }
        }
        
        if nbLost == players.count - 1 {
            return true
        }
        
        return false
    }
}
