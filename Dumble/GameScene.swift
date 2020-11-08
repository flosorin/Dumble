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
    var players: [Player] = []
    var startingPlayerIndex = -1 // Tells which player starts (-1 because dealCards will increase it)
    var playerIndex = 0 // Tells which player has to play
    var playersNameLabelNodes: [SKLabelNode] = []
    var playersScoreLabelNodes: [SKLabelNode] = []
    
    // IA's hands
    var handsIA: [SKSpriteNode] = []
    var showIAHands = false
    
    // Player user view
    // Player cards
    var playerCardsNodes: [SKSpriteNode] = []
    var playerCardsList: [String : SKSpriteNode] = [:]
    // Player hand score
    var playerHandScoreLabelNode: SKLabelNode!
    // "dumble" button
    var dumbleButton: SKSpriteNode!
    // Dumble said label node
    var dumbleSaidLabelNode: SKLabelNode!
    
    // Pile and discard
    var pile = Deck()
    var discard: [Card] = []
    var discardCardsNodes: [SKSpriteNode] = []
    var discardCardsList: [String: SKSpriteNode] = [:]
    var nbDiscardCardsToShow = 0
    var nbCardsDiscarded = 0
    var isCardGiven = false
    var isDealingComplete = false
    var isWaitingForRedealing = false
    
    // Texture for the back of a card
    let backTexture = SKTexture(imageNamed: "back")
    
    // Card node indexes to display
    let cardNodesIndexes = [[], [2], [1, 2], [1, 2, 3], [0, 1, 2, 3], [0, 1, 2, 3, 4]]
    
    // Cards animation according to the current player
    var pileAnimations: [SKAction] = [] // Pile to player
    var showAnimations = true
    
    // Basically tells if we need to reset all (new game started by pressing the deal button) or just cards and dumble flag (cards dealt because dumble has been said)
    var dealButtonPressed = false
    
    // Turn counter
    var turnCounter = 0
    
    // PopUps
    var popUp: SKShapeNode!
    var isPopUpPresent = false
    
    override func didMove(to view: SKView) {
        
        // Settings button
        createSettingsButton()
        
        // Init players array
        createPlayers()
        
        // IA's hands and infos
        createIAHands()
        
        // Player user display
        createPlayerDisplay()
        
        // Init players name and score
        createPlayersDisplay()
        
        // Cards animations
        createPileAnimations()
        
        // Pile
        createPileNode()
        
        // Discard
        createDiscardNodes()
        
        // Update the display
        updateDisplay()
        
        // Tells that we can deal cards by touching the pile
        isWaitingForRedealing = true
    }
    
    func createSettingsButton() {
        let settingsButton = SKSpriteNode(imageNamed: "settings")
        settingsButton.position = CGPoint(x: frame.maxX - settingsButton.frame.width, y: frame.maxY - settingsButton.frame.height)
        settingsButton.name = "settings"
        addChild(settingsButton)
    }
    
    func createPlayers() {
        players.append(PlayerUser())
        players[0].name = "Player"
        for _ in 1...3 {
            players.append(PlayerIA())
        }
        players[1].name = "Joe"
        players[2].name = "Jack"
        players[3].name = "Bill"
    }
    
    func createPlayersDisplay() {
        // Init with common parameters
        for (index, player) in players.enumerated() {
            playersNameLabelNodes.append(SKLabelNode(text: player.name))
            playersScoreLabelNodes.append(SKLabelNode(text: "0"))
            playersNameLabelNodes[index].fontSize = 22
            playersScoreLabelNodes[index].fontSize = 22
            playersNameLabelNodes[index].fontColor = SKColor.white
            playersScoreLabelNodes[index].fontColor = SKColor.white
            playersNameLabelNodes[index].isHidden = true
            playersScoreLabelNodes[index].isHidden = true
            addChild(playersNameLabelNodes[index])
            addChild(playersScoreLabelNodes[index])
        }
        // Configure the specific position
        // Player user
        let labelNameRect = CGRect(x: 0.0, y: 0.0, width: playerCardsNodes[0].size.width, height: playerCardsNodes[0].size.height / 3)
        adjustLabelFontSizeToFitRect(labelNode: playersNameLabelNodes[0], rect: labelNameRect)
        playersNameLabelNodes[0].position = CGPoint(x: playerCardsNodes[0].position.x, y: playerCardsNodes[0].size.height / 2)
        playersScoreLabelNodes[0].fontSize = playersNameLabelNodes[0].fontSize
        playersScoreLabelNodes[0].position = CGPoint(x: (playerCardsNodes[1].position.x - (playerCardsNodes[0].size.width / 4)), y: playersNameLabelNodes[0].position.y)
        // IA #1
        playersNameLabelNodes[1].position = CGPoint(x: (playersNameLabelNodes[1].frame.width / 2) + (playerCardsNodes[0].size.width / 4), y: frame.height * 0.8)
        // IA #2
        playersNameLabelNodes[2].position = CGPoint(x: (playersNameLabelNodes[2].frame.width / 2) + (playerCardsNodes[0].size.width / 2), y: frame.maxY - playersNameLabelNodes[2].frame.height * 2)
        // IA #3
        playersNameLabelNodes[3].position = CGPoint(x: frame.width - (playersNameLabelNodes[1].frame.width / 2) - (playerCardsNodes[0].size.width / 4), y: frame.height * 0.8)
        // All IA
        for nodeIndex in 1...playersScoreLabelNodes.count - 1 {
            playersScoreLabelNodes[nodeIndex].position = CGPoint(x: playersNameLabelNodes[nodeIndex].position.x, y: playersNameLabelNodes[nodeIndex].position.y - playersScoreLabelNodes[nodeIndex].frame.height * 1.5)
        }
    }
    
    func updateScoreLabels() {
        for (index, scoreNode) in playersScoreLabelNodes.enumerated() {
            scoreNode.text = "\(players[index].score)"
        }
    }
    
    // Touch management
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let node : SKNode = self.atPoint(location)
            if let nodeName = node.name {
                if !isPopUpPresent {
                    if !isWaitingForRedealing {
                        if let cardNode = playerCardsList[nodeName] { // Check if the node is a player card
                            playerCardsTouchManager(cardNode: cardNode)
                        } else if nodeName == "pile" { // Check if the node is the pile
                            pileTouchManager()
                        } else if let cardNode = discardCardsList[nodeName] { // Check if the node is a discard card
                            discardTouchManager(cardNode: cardNode)
                        } else if nodeName == "DUMBLE" { // Check if the node is the user dumble button
                            dumbleButtonTouchManager()
                        }
                    } else if nodeName == "pile" { // Pile node is used to deal cards when waiting for re-dealing (after dumble or at the beginning of a new game)
                        isWaitingForRedealing = false
                        isUserInteractionEnabled = false
                        // If this is the beginning of a new game, simply reset all and deal the cards
                        if !isDealingComplete {
                            dealButtonPressed = true
                            dealCards()
                        }
                    }
                    popUpTouchManagement(nodeName: nodeName) // PopUp showing management
                } else {
                    popUpTouchManagement(nodeName: nodeName) // PopUp buttons management
                }
            }
        }
    }
    
    // Called before each frame is rendered
    override func update(_ currentTime: TimeInterval) {
        
    }
    
    // Update the display
    func updateDisplay() {
        self.displayIAHands()
        self.displayPlayerUserInfos()
        self.displayDiscardCards()
    }
}
