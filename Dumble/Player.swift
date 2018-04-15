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
}

class PlayerUser : Player {
    
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
