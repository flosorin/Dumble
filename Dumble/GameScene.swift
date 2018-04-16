//
//  GameScene.swift
//  Dumble
//
//  Created by Florian Sorin on 31/08/2017.
//  Copyright © 2017 Florian Sorin. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Players
    var player = PlayerUser()
    var playerIA1 = PlayerIA()
    var playerIA2 = PlayerIA()
    var playerIA3 = PlayerIA()
    
    // IA's hands
    var handCounter = 5
    var handTop : SKSpriteNode!
    var handLeft : SKSpriteNode!
    var handRight : SKSpriteNode!
    
    // Player cards
    var playerCardsNodes : [SKSpriteNode] = []
    var cardsList : [String : SKSpriteNode] = [:]
    
    // Deck
    var deck = Deck()
    
    // Texture for the back of a card
    let backTexture = SKTexture(imageNamed: "back")
    
    override func didMove(to view: SKView) {
        
        // IA's hands
        createIAHands()
        
        // Player hand display (init with back, modified when the cards are dealt)
        createPlayerHand()
        
        // Deck
        createDeckNode()
    }
    
    func createIAHands() {
        handLeft = createHandNode(angle : CGFloat(Double.pi / 2), position : CGPoint(x: frame.width, y: frame.height * 5 / 8))
        handTop = createHandNode(angle : CGFloat(Double.pi), position : CGPoint(x: frame.width / 2, y: frame.height))
        handRight = createHandNode(angle : CGFloat(-Double.pi / 2), position : CGPoint(x: 0, y: frame.height * 5 / 8))
        addChild(handLeft)
        addChild(handTop)
        addChild(handRight)
    }
    
    func createHandNode(angle : CGFloat, position : CGPoint) -> SKSpriteNode {
        let hand = SKSpriteNode(texture: SKTexture(imageNamed: "Hand_5"))
        let newWidth = frame.width / 3
        let newHeight = hand.size.height * (newWidth / hand.size.width)
        hand.position = position
        hand.size = CGSize(width: newWidth, height: newHeight)
        hand.zRotation = angle
        return hand
    }
    
    func createPlayerHand() {
        // Create the first card
        playerCardsNodes.append(createCardNode(cardTexture: backTexture, cardPosition: CGPoint(x: 0, y: 0)))
        playerCardsNodes[0].position = CGPoint(x: playerCardsNodes[0].size.width, y: 2 * playerCardsNodes[0].size.height)
        playerCardsNodes[0].name = "card0"
        cardsList.updateValue(playerCardsNodes[0], forKey: "card0")
        addChild(playerCardsNodes[0])
        // Create the others according to the first card position
        for index in 1...4 {
            playerCardsNodes.append(createCardNode(cardTexture: backTexture, cardPosition: CGPoint(x: playerCardsNodes[index - 1].position.x + 1.25 * playerCardsNodes[0].position.x, y: playerCardsNodes[0].position.y)))
            playerCardsNodes[index].name = "card\(index)"
            cardsList.updateValue(playerCardsNodes[index], forKey: "card\(index)")
            addChild(playerCardsNodes[index])
        }
    }
    
    func createCardNode(cardTexture : SKTexture, cardPosition : CGPoint) -> SKSpriteNode {
        // Create the base of a card
        let card = SKSpriteNode(texture: cardTexture)
        card.zPosition = 10
        card.position = cardPosition
        // Resize it keeping aspect ratio
        let newWidth = frame.width / 7
        let newHeight = card.size.height * (newWidth / card.size.width)
        card.size = CGSize(width: newWidth, height: newHeight)
        return card
    }
    
    func createDeckNode() {
        let deckNode = SKSpriteNode(texture: SKTexture(imageNamed: "Deck"))
        let newHeight = playerCardsNodes[0].size.height // Ensure that the deck cards have the same size as the player cards
        let newWidth = deckNode.size.width * (newHeight / deckNode.size.height)
        deckNode.size = CGSize(width: newWidth, height: newHeight)
        deckNode.position = CGPoint(x: frame.width / 2, y: frame.height * 5 / 8)
        deckNode.name = "deck"
        addChild(deckNode)
    }

    // Touch management
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            let location = touch.location(in: self)
            let node : SKNode = self.atPoint(location)
            if let nodeName = node.name {
                if let cardNode = cardsList[nodeName] {
                    playerCardsTouchManager(cardNode: cardNode)
                } else if nodeName == "deck" {
                    dealCards()
                }
            } else {
                // TO BE REMOVED (debug only)
                if (handCounter > 1) {
                    handCounter -= 1
                } else {
                    handCounter = 5
                }
            }
        }
    }
    
    func playerCardsTouchManager (cardNode: SKSpriteNode) {
        let index = playerCardsNodes.index(of: cardNode)!
        // If the card is in its standard position, check if we can select it
        if (cardNode.position.y == 2 * playerCardsNodes[0].size.height) {
            if (player.isCardSelectable(index: index)) {
                // Make the card goes up to indicate that it is selected
                cardNode.position.y += playerCardsNodes[0].size.height / 2
                player.cards[index].isSelected = true
            }
        } else {
            // Always possible to go back to initial position
            cardNode.position.y -= playerCardsNodes[0].size.height / 2
            player.cards[index].isSelected = false
            // Reset player selected flags if there is one or less card(s) selected
            if (player.cardsSelected() <= 1) {
                player.resetSelected()
            }
        }
    }
    
    
    // Called before each frame is rendered
    override func update(_ currentTime: TimeInterval) {
        
        handLeft.texture = SKTexture(imageNamed: "Hand_\(handCounter)")
        handTop.texture = SKTexture(imageNamed: "Hand_\(handCounter)")
        handRight.texture = SKTexture(imageNamed: "Hand_\(handCounter)")
        
        displayPlayerCards()
    }
    
    func displayPlayerCards() {
        switch player.cards.count {
        case 5:
            for index in 0...4 {
                playerCardsNodes[index].isHidden = false
                playerCardsNodes[index].texture = player.cards[index].picture
            }
        default:
            for index in 0...4 {
                playerCardsNodes[index].isHidden = true
            }
        }
    }
    
    func dealCards() {
        
        deck.melt()
        player.reset()
        playerIA1.reset()
        playerIA2.reset()
        playerIA3.reset()
        
        for _ in 0...4 {
            player.addCard(card: deck.cards[deck.topCard])
            deck.topCard -= 1
            playerIA1.addCard(card: deck.cards[deck.topCard])
            deck.topCard -= 1
            playerIA2.addCard(card: deck.cards[deck.topCard])
            deck.topCard -= 1
            playerIA3.addCard(card: deck.cards[deck.topCard])
            deck.topCard -= 1
        }
        
        player.sortCards()
    }


}

