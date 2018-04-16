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
}

class PlayerUser : Player {
    
    // Var used to manage multiple card selection
    var sameRankSelected = false
    var sameSuitSelected = false
    
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
    
    func isCardSelectable(index: Int) -> Bool {
        // If there is no card selected, we can obviously select this one
        if (cardsSelected() == 0) {
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
    
    func cardsSelected() -> Int {
        var cardsSelected = 0
        
        for card in cards {
            if card.isSelected {
                cardsSelected += 1
            }
        }
        
        return cardsSelected
    }
    
    func resetSelected() {
        sameRankSelected = false
        sameSuitSelected = false
    }
}

class PlayerIA : Player {
    
    var cardToPick : Card?
    var cardsToPlay : [Card]?
    private var cardsNotToPlay : [Card]?
    
    private func checkDumble() -> Bool {
        // TO BE COMPLETED
        return true
    }
    
    func chooseNewCard() {
        // TO BE COMPLETED
    }
    
    private func defMoove() {
        // TO BE COMPLETED
    }
    
    func playTurn() {
        
        if (!checkDumble()) {
            chooseNewCard()
            defMoove()
        }
    }
}
