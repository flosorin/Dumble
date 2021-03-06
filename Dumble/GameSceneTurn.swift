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
            let delay = showAnimations ? DispatchTime.now() + .seconds(1) : .now()
            DispatchQueue.main.asyncAfter(deadline: delay, execute: {
                if  cardToPickIndex >= 0 {
                    self.giveDiscardToPlayer(discardIndex: (self.discard.count - 1) - cardToPickIndex)
                } else if cardToPickIndex == -1 {
                    self.givePileTopToPlayer()
                } else {
                    self.dumbleManagement()
                }
            })
        }
        // Display the user dumble button if needed
        if (playerIndex == 0) && (players[0].getHandScore() <= 9) && (!isWaitingForRedealing) {
            dumbleButton.isHidden = false
        } else {
            dumbleButton.isHidden = true
        }
    }
    
    func getOtherPlayersNbCard() -> [Int] {
        var otherPlayersNbCard: [Int] = []
        
        for (index, player) in players.enumerated() {
            if index != playerIndex && !player.gameLose {
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
                    if index != 0 { // Display the score of losers, except for the user (always displayed as hand score)
                        displayDumbleSaidLabel(hide: false, playerIndex: index, text: "")
                    }
                }
            }
        } else {
            players[playerIndex].updateScore(dumbleFailed: true) // The player adds 25 to its score
            displayDumbleSaidLabel(hide: false, playerIndex: counterPlayerIndex, text: "NOPE!")
        }
        isUserInteractionEnabled = true
        isWaitingForRedealing = true
        updateDisplay()
        // Check if the game is over
        if self.players[0].gameLose {
            self.gameOverManagement(userWon: false)
        } else if isGameOver() {
            self.gameOverManagement()
        }
        
        // Wait for the user to claim for redealing
        DispatchQueue.global(qos: .background).async {
            while self.isWaitingForRedealing {}
            // Go back to the main thread
            DispatchQueue.main.async {
                // Update score labels
                self.updateScoreLabels()
                // Empty the discard
                self.discard.removeAll()
                self.nbDiscardCardsToShow = 0
                // Re-hide the IA cards and the dumble said labels
                self.showIAHands = false
                for (index, _) in self.players.enumerated() {
                    self.displayDumbleSaidLabel(hide: true, playerIndex: index)
                }
                // Re-deal the cards if the game is not over
                if self.isDealingComplete {
                    self.dealCards()
                } else {
                    self.isWaitingForRedealing = true
                }
            }
        }
    }
    
    func displayDumbleSaidLabel(hide: Bool, playerIndex: Int, text: String = "DUMBLE") {
        let textCompleted = text + " (\(players[playerIndex].getHandScore()))"
        if playerIndex == 0 {
            dumbleSaidLabelNode.text = textCompleted
            dumbleSaidLabelNode.isHidden = hide
        } else {
            (handsIA[playerIndex - 1].childNode(withName: "DumbleSaid") as! SKLabelNode).text = textCompleted
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
        
    func gameOverManagement(userWon: Bool = true) {
        popUp = createGameOverPopUp(userWon: userWon)
        addChild(popUp)
        isPopUpPresent = true
    }
}
