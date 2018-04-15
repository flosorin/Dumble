//
//  Cards.swift
//  Dumble
//
//  Created by Florian Sorin on 15/04/2018.
//  Copyright © 2018 Florian Sorin. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

enum Rank : Int {
    case ace = 1
    case deuce = 2
    case three = 3
    case four = 4
    case five = 5
    case six = 6
    case seven = 7
    case eight = 8
    case nine = 9
    case ten = 10
    case jack = 11
    case queen = 12
    case king = 13
    case joker = 0
    case none = -1
    
    var name: String {
        get { return String(describing: self) }
    }
}

enum Suit : Int {
    case clubs = 0
    case diamonds = 1
    case hearts = 2
    case spades = 3
    case blackJoker = 4
    case redJoker = 5
    case none = -1
    
    var name: String {
        get { return String(describing: self) }
    }
}

class Card : NSObject, NSCopying {
    
    var rank : Rank
    var suit : Suit
    var picture : SKTexture
    
    init (rank : Rank, suit : Suit) {
        self.rank = rank
        self.suit = suit
        self.picture = SKTexture(imageNamed: rank.name + "_of_" + suit.name)
    }
    
    func getDumbleValue() -> Int {
        
        if (rank.rawValue > 10) {
            return 10
        } else {
            return rank.rawValue
        }
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Card(rank: rank, suit: suit)
        return copy
    }
}

class Deck {
    
    var cards : [Card] = []
    
    init() {
        
        cards.append(Card(rank: Rank.joker, suit: Suit.blackJoker))
        for rankIndex in 0...13 {
            for suitIndex in 0...3 {
                cards.append(Card(rank: Rank.init(rawValue: rankIndex)!, suit: Suit.init(rawValue: suitIndex)!))
            }
        }
        cards.append(Card(rank: Rank.joker, suit: Suit.redJoker))
    }
    
    func melt() {
        
        var randomIndex = 0
        var cardTmp : Card
        
        for deckIndex in (1...cards.count).reversed() {
            randomIndex = Int(arc4random_uniform(UInt32(deckIndex)))
            cardTmp = (cards[deckIndex].copy() as Card?)!
            cards[deckIndex] = (cards[randomIndex].copy() as Card?)!
            cards[randomIndex] = (cardTmp.copy() as Card?)!
        }
    }
}
