//
//  Player.swift
//  Dumble
//
//  Created by Florian Sorin on 15/04/2018.
//  Copyright © 2018 Florian Sorin. All rights reserved.
//

import Foundation

class Player {
    
    var name = "player"
    var cards : [Card] = []
    var score = 0
    var handScore = 0
    var dumbleSaid = false
    
    func addCard(card : Card) {
        cards.append(card)
    }
    
    func reset() {
        cards.removeAll()
        score = 0
        handScore = 0
        dumbleSaid = false
    }
    
    func sortCards() {
        
        var cardsTmp : [Card] = []
        
        for cardValue in 0...13 {
            for card in cards {
                if card.rank.rawValue == cardValue {
                    cardsTmp.append(card)
                }
            }
        }
        
        cards.removeAll()
        cards.append(contentsOf: cardsTmp)
        cardsTmp.removeAll()
    }
    
    func nbCardsSelected() -> Int {
        var cardsSelected = 0
        
        for card in cards {
            if card.isSelected {
                cardsSelected += 1
            }
        }
        
        return cardsSelected
    }
    
    func removeSelectedCards() {
        var cardsTmp : [Card] = []
        for card in cards {
            if !(card.isSelected) {
                cardsTmp.append(card)
            }
        }
        cards.removeAll()
        cards.append(contentsOf: cardsTmp)
        cardsTmp.removeAll()
    }
    
    func updateHandScore() {
        handScore = 0
        for card in cards {
            handScore += card.getDumbleValue()
        }
    }
}

class PlayerUser : Player {
    
    // Var used to manage multiple card selection
    var sameRankSelected = false
    var sameSuitSelected = false
    
    
    
    func isCardSelectable(index: Int) -> Bool {
        // If there is no card selected, we can obviously select this one
        if (nbCardsSelected() == 0) {
            return true
        }
        
        let cardToCheck = cards[index]
        
        for (i, card) in cards.enumerated() {
            // Ensure that we do not compare the card to itself
            if (i != index) {
                if (card.isSelected) {
                    // If a card with the same rank has been selected previously
                    if (cardToCheck.rank.rawValue == card.rank.rawValue) && (!sameSuitSelected) {
                        sameRankSelected = true
                        return true
                    }
                    // If a card from the same suit and with a rank directly upper or lower has been selected previously, that is also valid
                    if (cardToCheck.suit.rawValue == card.suit.rawValue) && (!sameRankSelected) {
                        if (cardToCheck.rank.rawValue == card.rank.rawValue - 1) || (cardToCheck.rank.rawValue == card.rank.rawValue + 1) {
                            sameSuitSelected = true
                            return true
                        }
                    }
                }
            }
        }
        return false
    }
    
    func isSwitchAllowed() -> Bool {
        // First of all, if there is no card selected, there is nothing to switch
        if (nbCardsSelected() == 0) {
            return false
        }
        // Then, if we try to switch cards of the same suit, there must be at least three of them
        if (sameSuitSelected && nbCardsSelected() < 3) {
            return false
        }
        // If we are here, then everything is legit
        return true
    }
    
    func resetSelected() {
        sameRankSelected = false
        sameSuitSelected = false
    }
}

class PlayerIA : Player {
    
    func playTurn(cardsAvailable : [Card]) -> Int? {
        
        if (!checkDumble()) {
            sortCards()
            return defSwitch(cardsAvailable: cardsAvailable)
        }
        
        return -1 // Means that there is a dumble
    }
    
    private func checkDumble() -> Bool {
        // TO BE COMPLETED
        return false
    }
    
    // /!\ HUGE function TO BE REFACTORED
    func defSwitch(cardsAvailable : [Card]) -> Int? {
        var cardsNotToPlayIndex : [Int] = [] // Cards needed by the card to pick that, therefore, cannot be switched
        var cardsToPlayIndex : [Int] = [] // Cards that we can discard together that, therefore, must not be considered when looking for the card to pick
        var cardToPickIndex : Int?
        // If a card in the list creates following, we take it.
        for (index, cardToChoose) in cardsAvailable.enumerated() {
            cardsNotToPlayIndex = checkFollowingCards(newCard: cardToChoose)
            if (cardsNotToPlayIndex.count != 0) {
                cardToPickIndex = index
                break // We found the one, we can quit the for
            }
        }
        // If we have following cards in hand (that cannot be improved by the card to pick), we discard them
        followingHand: for (index, cardInHand) in cards.enumerated() {
            // First, check that we can consider this card without destroying previous plans
            if let _ = cardsNotToPlayIndex.index(of: index) {
                continue followingHand // Check next card
            }
            let tmpIndexes = checkFollowingCards(newCard: cardInHand)
            if (tmpIndexes.count != 0) {
                // Same check for the following cards
                for index2 in tmpIndexes {
                    if let _ = cardsNotToPlayIndex.index(of: index2) {
                        continue followingHand // Check next card
                    }
                }
                // If we reach this point, we can safely select the cards to play and quit the for
                cards[index].isSelected = true
                for index2 in cardsToPlayIndex {
                    cards[index2].isSelected = true
                }
                cardsToPlayIndex = tmpIndexes
                break
            }
        }
        // If we have not found a card to pick yet, check for pairs that do not conflict with cards to play
        if cardToPickIndex == nil {
            pairingPick: for (index, cardToChoose) in cardsAvailable.enumerated() {
                let tmpIndexes = checkPairs(newCard: cardToChoose)
                if (tmpIndexes.count != 0) {
                    // Check that these cards will not be discarded
                    for index2 in tmpIndexes {
                        if let _ = cardsToPlayIndex.index(of: index2) {
                            continue pairingPick // Check next card
                        }
                    }
                    // If we reach this point, we can safely pick the card and quit the for
                    cardToPickIndex = index
                    cardsNotToPlayIndex = tmpIndexes
                    break
                }
            }
        }
        // Now, if we have not found the card(s) to discard, we try to make pairs
        if (cardsToPlayIndex.count == 0) {
            pairingHand: for (index, cardInHand) in cards.enumerated() {
                let tmpIndexes = checkPairs(newCard: cardInHand)
                if (tmpIndexes.count != 0) {
                    // check that we can consider these cards without destroying previous plans
                    for index2 in tmpIndexes {
                        if let _ = cardsNotToPlayIndex.index(of: index2) {
                            continue pairingHand // Check next card
                        }
                    }
                    // If we reach this point, we can safely select the cards to play and quit the for
                    cards[index].isSelected = true
                    for index2 in cardsToPlayIndex {
                        cards[index2].isSelected = true
                    }
                    cardsToPlayIndex = tmpIndexes
                    break
                }
            }
        }
        // Last chance for the card to pick: pick the lowest car with a value under five
        if (cardToPickIndex == nil) {
            for (index, cardToChoose) in cardsAvailable.enumerated() {
                // First, check that we can consider this card without destroying previous plans
                if let _ = cardsToPlayIndex.index(of: index) {
                    continue // Check next card
                }
                // Then we check its value
                if (cardToChoose.getDumbleValue() <= 5) {
                    cardToPickIndex = index
                    break
                }
            }
        }
        // If we have not chosen a card to discard, we discard the highest one which does not conflict with previous plans
        if (cardsToPlayIndex.count == 0) {
            // The cards are already sorted so we can iterate in the reverse way
            for (index, cardInHand) in cards.enumerated().reversed() {
                // First, check that we can consider this card without destroying previous plans
                if let _ = cardsNotToPlayIndex.index(of: index) {
                    continue // Check next card
                }
                // If we reach this point, we just select this card
                cardInHand.isSelected = true
                break
            }
        }
        // Finally, if all cards are "not to play", then we play all and redo the checking for the lowest value in available cards. This case is quite unlikely to happen because it means that the player owns five following cards and one of the discard cards also follows. Yet, if it happens, the player will not be able to decide what to do, so we have to tell "him"
        if (cardsNotToPlayIndex.count == 5) {
            // Select all cards
            for cardInHand in cards {
                cardInHand.isSelected = true
            }
            // Reasign the card to pick
            cardToPickIndex = nil
            for (index, cardToChoose) in cardsAvailable.enumerated() {
                if (cardToChoose.getDumbleValue() <= 5) {
                    cardToPickIndex = index
                    break
                }
            }
        }
        
        return cardToPickIndex
    }
    
    // Check for cards making following list with the given card and return them if existing
    private func checkFollowingCards(newCard: Card) ->  [Int] {
        var followingCardsIndex : [Int] = []
        var ranksOfSameSuitCards : [Int] = []
        var indexOfSameSuitCards : [Int] = []
        // Check if we have cards of the same suit and store their rank
        for (index, cardInHand) in cards.enumerated() {
            if (cardInHand.suit.rawValue == newCard.suit.rawValue) {
                ranksOfSameSuitCards.append(cardInHand.rank.rawValue)
                indexOfSameSuitCards.append(index)
            }
        }
        // We need at least three following cards so there is no need to do further checking if we do not have enough cards
        if (ranksOfSameSuitCards.count >= 2) {
            // Check if the IA owns the 2 upper cards
            if let index1 = ranksOfSameSuitCards.index(of: newCard.rank.rawValue + 1), let index2 = ranksOfSameSuitCards.index(of: newCard.rank.rawValue + 2) {
                // Update the list of following cards
                followingCardsIndex.append(indexOfSameSuitCards[index1])
                followingCardsIndex.append(indexOfSameSuitCards[index2])
            }
            // Also check if it owns the 2 lower cards (not else to cover all cases)
            if let index1 = ranksOfSameSuitCards.index(of: newCard.rank.rawValue - 1), let index2 = ranksOfSameSuitCards.index(of: newCard.rank.rawValue - 2) {
                // Update the list of cards not to play
                followingCardsIndex.append(indexOfSameSuitCards[index1])
                followingCardsIndex.append(indexOfSameSuitCards[index2])
            }
            // Finally, if it owns the directly lower and directly upper cards (not else to cover all cases)
            if let index1 = ranksOfSameSuitCards.index(of: newCard.rank.rawValue - 1), let index2 = ranksOfSameSuitCards.index(of: newCard.rank.rawValue + 1) {
                // Update the list of cards not to play
                followingCardsIndex.append(indexOfSameSuitCards[index1])
                followingCardsIndex.append(indexOfSameSuitCards[index2])
            }
        }
        
        return followingCardsIndex
    }
    
    // Check for cards making pair with the given card and return them if existing
    private func checkPairs(newCard: Card) -> [Int] {
        var pairsIndex : [Int] = []
        for (index, cardInHand) in cards.enumerated() {
            if (cardInHand.rank.rawValue == newCard.rank.rawValue) {
                pairsIndex.append(index)
            }
        }
        return pairsIndex
    }
}
