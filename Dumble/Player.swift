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
    var cards: [Card] = []
    // Score management
    var fiftyReached = false
    var seventyFiveReached = false
    var hundredReached = false
    var score = 0
    var gameLose = false
    var dumbleSaid = false
    
    // Var used to manage multiple card selection
    var sameRankSelected = false
    var sameSuitSelected = false
    
    func addCard(card: Card) {
        cards.append(card)
    }
    
    func reset(resetAll: Bool) {
        cards.removeAll()
        dumbleSaid = false
        if resetAll {
            fiftyReached = false
            seventyFiveReached = false
            hundredReached = false
            score = 0
            gameLose = false
        }
    }
    
    func sortCards() {
        var cardsTmp: [Card] = []
        
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
        var cardsTmp: [Card] = []
        for card in cards {
            if !(card.isSelected) {
                cardsTmp.append(card)
            }
        }
        cards.removeAll()
        cards.append(contentsOf: cardsTmp)
        cardsTmp.removeAll()
    }
    
    func getHandScore() -> Int {
        var handScore = 0
        
        for card in cards {
            handScore += card.getDumbleValue()
        }
        
        return handScore
    }
    
    func resetSelectedFlags() {
        sameRankSelected = false
        sameSuitSelected = false
    }
    
    func specialCasesHandler() {
        if score == 50 && fiftyReached == false {
            score = 25
            fiftyReached = true
        } else if score == 75 && seventyFiveReached == false {
            score = 50
            fiftyReached = true
            seventyFiveReached = true
        } else if score == 100 && hundredReached == false {
            score = 75
            fiftyReached = true
            seventyFiveReached = true
            hundredReached = true
        } else if score > 100 {
            gameLose = true
        }
    }
}

class PlayerUser: Player {

    func isCardSelectable(index: Int) -> Bool {
        // If there is no card selected, we can obviously select this one
        if nbCardsSelected() == 0 {
            return true
        }
        
        let cardToCheck = cards[index]
        
        for (i, card) in cards.enumerated() {
            // Ensure that we do not compare the card to itself
            if i != index {
                if card.isSelected {
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
        if nbCardsSelected() == 0 {
            return false
        }
        // Then, if we try to switch cards of the same suit, there must be at least three of them
        if sameSuitSelected && (nbCardsSelected() < 3) {
            return false
        }
        // If we are here, then everything is legit
        return true
    }
}

class PlayerIA: Player {
    
    var cardsNotToPlayIndex: [Int] = [] // Cards needed by the card to pick that, therefore, cannot be switched
    var cardsToPlayIndex: [Int] = [] // Cards that we can discard together that, therefore, must not be considered when looking for the card to pick
    var cardToPickIndex = -1

    func playTurn(cardsAvailable: [Card], nbTurn: Int, otherPlayersNbCards: [Int]) -> Int {
        if !checkDumble(nbTurn: nbTurn, otherPlayersNbCards: otherPlayersNbCards) {
            return defSwitch(cardsAvailable: cardsAvailable)
        }
        return -2 // Means that there is a dumble (-1 means that we want to pick the top pile card)
    }
    
    private func checkDumble(nbTurn: Int, otherPlayersNbCards: [Int]) -> Bool {
        // First, update the hand score
        let handScore = getHandScore()
        // Then, if the hand score is above 9, we cannot say dumble
        if handScore > 9 {
            return false
        }
        // Then, check the number of turn
        let nbTurnAllowed = 4 + 9 - handScore
        if (nbTurn > nbTurnAllowed) || (handScore < 3) {
            return false
        }
        // Finally, check the other players cards number (TO BE IMPROVED)
        // If at least one other player has only one card, do not attempt to dumble above five
        if let _ = otherPlayersNbCards.index(of: 1) {
            if handScore > 5 {
                return false
            }
        }
        // If at least one other player has two cards, do not attempt to dumble above seven
        if let _ = otherPlayersNbCards.index(of: 1) {
            if handScore > 7 {
                return false
            }
        }
        
        dumbleSaid = true
        return true
    }
    
    private func defSwitch(cardsAvailable: [Card]) -> Int {
        // Reset useful vars
        cardsNotToPlayIndex.removeAll()
        cardsToPlayIndex.removeAll()
        cardToPickIndex = -1
        resetSelectedFlags()
        
        // If a card in the list creates following, we take it.
        checkFollowingAvailable(cardsAvailable: cardsAvailable)
        
        // If we have following cards in hand (that cannot be improved by the card to pick), we discard them
        checkFollowingInHand()
        
        // If we have not found a card to pick yet, check for pairs that do not conflict with cards to play
        if cardToPickIndex == -1 {
            checkPairsAvailable(cardsAvailable: cardsAvailable)
        }
        
        // Now, if we found following cards in hand, we have to check if the following cards total value is above the value of the highest card playable (i.e. : nope, we do not drop '1, 2, 3' if we also have a jack in hand...)
        if cardsToPlayIndex.count != 0 {
            // If the following cards were not valid, we can try to make pairs again, if needed
            if !areFollowingCardsValid() {
                if cardToPickIndex == -1 {
                    checkPairsAvailable(cardsAvailable: cardsAvailable)
                }
            }
        }
        
        // Now, if we have not found the card(s) to discard, we try to make pairs
        if cardsToPlayIndex.count == 0 {
            checkPairsInHand()
        }
        
        // Last chance for the card to pick: pick the lowest car with a value under five
        if cardToPickIndex == -1 {
            checkLowestAvailable(cardsAvailable: cardsAvailable)
        }
        
        // If we have not chosen a card to discard, we discard the highest one which does not conflict with previous plans
        if cardsToPlayIndex.count == 0 {
            cards[getHighestInHand()].isSelected = true
        }
        // Finally, if all cards are "not to play", then we play all and redo the checking for the lowest value in available cards. This case is quite unlikely to happen because it means that the player owns five following cards and one of the discard cards also follows. Yet, if it happens, the player will not be able to decide what to do, so we have to tell "him"
        if cardsNotToPlayIndex.count == 5 {
            // Select all cards
            for cardInHand in cards {
                cardInHand.isSelected = true
            }
            // Reasign the card to pick
            cardToPickIndex = -1
            for (index, cardToChoose) in cardsAvailable.enumerated() {
                if cardToChoose.getDumbleValue() <= 5 {
                    cardToPickIndex = index
                    break
                }
            }
        }
        
        return cardToPickIndex
    }
    
    // Check following cards with discard
    private func checkFollowingAvailable(cardsAvailable: [Card]) {
        for (index, cardToChoose) in cardsAvailable.enumerated() {
            cardsNotToPlayIndex = checkFollowingCards(newCard: cardToChoose)
            if cardsNotToPlayIndex.count != 0 {
                cardToPickIndex = index
                break // We found the one, we can quit the for
            }
        }
    }
    
    // Check following cards in hand
    private func checkFollowingInHand() {
        followingHand: for (index, cardInHand) in cards.enumerated() {
            // First, check that we can consider this card without destroying previous plans
            if let _ = cardsNotToPlayIndex.index(of: index) {
                continue followingHand // Check next card
            }
            let tmpIndexes = checkFollowingCards(newCard: cardInHand)
            if tmpIndexes.count != 0 {
                // Same check for the following cards
                for index2 in tmpIndexes {
                    if let _ = cardsNotToPlayIndex.index(of: index2) {
                        continue followingHand // Check next card
                    }
                }
                // If we reach this point, we can safely select the cards to play and quit the for
                cards[index].isSelected = true
                cardsToPlayIndex.append(contentsOf: tmpIndexes)
                for index2 in cardsToPlayIndex {
                    cards[index2].isSelected = true
                }
                sameSuitSelected = true
                break
            }
        }
    }
    
    // Check for cards making following list with the given card and return them if existing
    private func checkFollowingCards(newCard: Card) ->  [Int] {
        var followingCardsIndex: [Int] = []
        var ranksOfSameSuitCards: [Int] = []
        var indexOfSameSuitCards: [Int] = []
        // Check if we have cards of the same suit and store their rank
        for (index, cardInHand) in cards.enumerated() {
            if cardInHand.suit.rawValue == newCard.suit.rawValue {
                ranksOfSameSuitCards.append(cardInHand.rank.rawValue)
                indexOfSameSuitCards.append(index)
            }
        }
        // We need at least three following cards so there is no need to do further checking if we do not have enough cards
        if ranksOfSameSuitCards.count >= 2 {
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
    
    // Check pairs with discard
    private func checkPairsAvailable(cardsAvailable: [Card]) {
        pairingPick: for (index, cardToChoose) in cardsAvailable.enumerated() {
            let tmpIndexes = checkPairs(newCard: cardToChoose)
            if tmpIndexes.count != 0 {
                // Check that these cards will not be discarded
                for index2 in tmpIndexes {
                    if let _ = cardsToPlayIndex.index(of: index2) {
                        continue pairingPick // Check next card
                    }
                }
                // If we reach this point, we can safely pick the card and quit the for
                cardToPickIndex = index
                cardsNotToPlayIndex.append(contentsOf: tmpIndexes)
                break
            }
        }
    }
    
    // Check pairs in hand
    private func checkPairsInHand() {
        // Check for pairs starting with the highest card
        pairingHand: for (index, cardInHand) in cards.enumerated().reversed() {
            let tmpIndexes = checkPairs(newCard: cardInHand, forbiddenIndex: index) // Do not compare the card to itself !
            if tmpIndexes.count != 0 {
                // Check that we can consider these cards without destroying previous plans
                for index2 in tmpIndexes {
                    if let _ = cardsNotToPlayIndex.index(of: index2) {
                        continue pairingHand // Check next card
                    }
                }
                // Now, check if the total value of the pair exceeds the value of the highest card playable
                // Get the value of the highest card playable
                let highestValue = cards[getHighestInHand()].getDumbleValue()
                // Get the value of the list of cards
                var cardList: [Card] = []
                for index in tmpIndexes {
                    cardList.append(cards[index])
                }
                cardList.append(cardInHand)
                // Compare these values
                if getCardsValue(cards: cardList) < highestValue {
                    continue
                }
                // If we reach this point, we can safely select the cards to play and quit the for
                cards[index].isSelected = true
                cardsToPlayIndex.append(contentsOf: tmpIndexes)
                for index2 in cardsToPlayIndex {
                    cards[index2].isSelected = true
                }
                sameRankSelected = true
                break
            }
        }
    }
    
    // Check for cards making pair with the given card and return them if existing
    private func checkPairs(newCard: Card, forbiddenIndex: Int = -1) -> [Int] {
        var pairsIndex : [Int] = []
        for (index, cardInHand) in cards.enumerated() {
            if (index != forbiddenIndex) && (cardInHand.rank.rawValue == newCard.rank.rawValue) {
                pairsIndex.append(index)
            }
        }
        return pairsIndex
    }
    
    // Pick the card if its dumble value is under five
    private func checkLowestAvailable(cardsAvailable: [Card]) {
        for (index, cardToChoose) in cardsAvailable.enumerated() {
            // First, check that we can consider this card without destroying previous plans
            if let _ = cardsToPlayIndex.index(of: index) {
                continue // Check next card
            }
            // Then we check its value
            if cardToChoose.getDumbleValue() <= 5 {
                cardToPickIndex = index
                break
            }
        }
    }
    
    // Give the index of the highest playable card
    private func getHighestInHand() -> Int {
        // The cards are already sorted so we can iterate in the reverse way
        for index in (0...(cards.count - 1)).reversed() {
            // First, check that we can consider this card without destroying previous plans
            if let _ = cardsNotToPlayIndex.index(of: index) {
                continue // Check next card
            }
            // If we reach this point, we have found the card
            return index
        }
        
        return 0 // That is the lowest card but still better than returning nothing
    }
    
    // Return the total dumble value of a list of cards
    private func getCardsValue(cards: [Card]) -> Int {
        var dumbleValue = 0
        
        for card in cards {
            dumbleValue += card.getDumbleValue()
        }
        
        return dumbleValue
    }
    
    // Cancel following or pairs selection if their total value is under the highest card playable value
    private func areFollowingCardsValid() -> Bool {
        // Get the value of the highest card playable
        let highestValue = cards[getHighestInHand()].getDumbleValue()
        // Get the value of the list of cards
        var cardList : [Card] = []
        for index in cardsToPlayIndex {
            cardList.append(cards[index])
        }
        // Compare these values
        if getCardsValue(cards: cardList) < highestValue {
            // Reset variables
            cardsToPlayIndex.removeAll()
            for card in cards {
                if card.isSelected {
                    card.isSelected = false
                }
            }
            
            return false
        }
        
        return true
    }
}
