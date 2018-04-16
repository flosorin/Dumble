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
    var playerCardsList : [String : SKSpriteNode] = [:]
    
    // Pile and discard
    var pile = Deck()
    var discard : [Card] = []
    
    // Texture for the back of a card
    let backTexture = SKTexture(imageNamed: "back")
    
    override func didMove(to view: SKView) {
        
        // IA's hands
        createIAHands()
        
        // Player hand display (init with back, modified when the cards are dealt)
        createPlayerHand()
        
        // Pile
        createPileNode()
    }
    
    func createIAHands() {
        handLeft = createHandNode(angle : CGFloat(Double.pi / 2), position : CGPoint(x: frame.width, y: frame.height * 5 / 8))
        handLeft.isHidden = true
        handTop = createHandNode(angle : CGFloat(Double.pi), position : CGPoint(x: frame.width / 2, y: frame.height))
        handTop.isHidden = true
        handRight = createHandNode(angle : CGFloat(-Double.pi / 2), position : CGPoint(x: 0, y: frame.height * 5 / 8))
        handRight.isHidden = true
        addChild(handLeft)
        addChild(handTop)
        addChild(handRight)
    }
    
    func createHandNode(angle : CGFloat, position : CGPoint) -> SKSpriteNode {
        let hand = SKSpriteNode(texture: SKTexture(imageNamed: "Hand_5"))
        hand.position = position
        hand.size = resizeWidth(oldSize: hand.size, newWidth: frame.width / 3)
        hand.zRotation = angle
        return hand
    }
    
    func createPlayerHand() {
        // Create the first card
        playerCardsNodes.append(createCardNode(cardTexture: backTexture, cardPosition: CGPoint(x: 0, y: 0)))
        playerCardsNodes[0].position = CGPoint(x: playerCardsNodes[0].size.width, y: 2 * playerCardsNodes[0].size.height)
        playerCardsNodes[0].name = "card0"
        playerCardsList.updateValue(playerCardsNodes[0], forKey: "card0")
        addChild(playerCardsNodes[0])
        // Create the others according to the first card position
        for index in 1...4 {
            playerCardsNodes.append(createCardNode(cardTexture: backTexture, cardPosition: CGPoint(x: playerCardsNodes[index - 1].position.x + 1.25 * playerCardsNodes[0].position.x, y: playerCardsNodes[0].position.y)))
            playerCardsNodes[index].name = "card\(index)"
            playerCardsList.updateValue(playerCardsNodes[index], forKey: "card\(index)")
            addChild(playerCardsNodes[index])
        }
    }
    
    func createCardNode(cardTexture : SKTexture, cardPosition : CGPoint) -> SKSpriteNode {
        // Create the base of a card
        let card = SKSpriteNode(texture: cardTexture)
        card.zPosition = 10
        card.position = cardPosition
        // Resize it keeping aspect ratio
        card.size = resizeWidth(oldSize: card.size, newWidth: frame.width / 7)
        return card
    }
    
    func createPileNode() {
        let pileNode = SKSpriteNode(texture: SKTexture(imageNamed: "pile"))
        pileNode.size = resizeHeight(oldSize: pileNode.size, newHeight: playerCardsNodes[0].size.height)
        pileNode.position = CGPoint(x: frame.width / 2, y: frame.height * 5 / 8)
        pileNode.name = "pile"
        addChild(pileNode)
    }

    // Touch management
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            let location = touch.location(in: self)
            let node : SKNode = self.atPoint(location)
            if let nodeName = node.name { // Check if the node is a player card
                if let cardNode = playerCardsList[nodeName] {
                    playerCardsTouchManager(cardNode: cardNode)
                } else if nodeName == "pile" { // Check if the node is the pile
                    pileTouchManager()
                }
            } else {
                // Still debug, we definitely need a real "deal button"
                dealCards()
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
            if (player.nbCardsSelected() <= 1) {
                player.resetSelected()
            }
        }
    }
    
    func pileTouchManager() {
        // Check if the interaction is legit
        if (player.isSwitchAllowed()) {
            resetPlayerCardsPosition()
            givePileTopToPlayer() // Call generic method
            player.resetSelected()
        }
    }
    
    func resetPlayerCardsPosition() {
        for cardNode in playerCardsNodes {
            cardNode.position.y = 2 * playerCardsNodes[0].size.height
        }
    }
    
    func givePileTopToPlayer() {
        // The player recover the top card of the pile
        switchPlayerCards(cardToPick: pile.cards[pile.topCard])
        // Update the pile top card
        if pile.topCard > 0 {
            pile.topCard -= 1
        } else { // If there is no card left, the discard become the new pile
            if let cardTmp = discard.last {
                discard.removeLast()
                pile.reconstruct(withCards: discard)
                discard.removeAll()
                discard.append(cardTmp)
            }
        }
    }
    
    func switchPlayerCards(cardToPick: Card) {
        // The selected cards go to the discard
        for card in player.cards {
            if card.isSelected {
                discard.append(card)
            }
        }
        player.removeSelectedCards()
        player.addCard(card: cardToPick)
    }
    
    func dealCards() {
        // Melt the pile
        pile.melt()
        
        // Reset players (remove all cards and reset scores)
        player.reset()
        playerIA1.reset()
        playerIA2.reset()
        playerIA3.reset()
        
        // Deal the cards (all players)
        for _ in 0...4 {
            player.addCard(card: pile.cards[pile.topCard])
            pile.topCard -= 1
            playerIA1.addCard(card: pile.cards[pile.topCard])
            pile.topCard -= 1
            playerIA2.addCard(card: pile.cards[pile.topCard])
            pile.topCard -= 1
            playerIA3.addCard(card: pile.cards[pile.topCard])
            pile.topCard -= 1
        }
        // Deal the initial discard card
        discard.append(pile.cards[pile.topCard])
        pile.topCard -= 1
        
        handLeft.isHidden = false
        handTop.isHidden = false
        handRight.isHidden = false
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
        case 0:
            for index in 0...4 {
                playerCardsNodes[index].isHidden = true
            }
        default:
            player.sortCards()
            for index in 0...player.cards.count - 1 {
                playerCardsNodes[index].texture = player.cards[index].picture
                playerCardsNodes[index].isHidden = false
            }
            if player.cards.count < playerCardsNodes.count {
                for index in player.cards.count...playerCardsNodes.count - 1 {
                    playerCardsNodes[index].isHidden = true
                }
            }
        }
    }
}

