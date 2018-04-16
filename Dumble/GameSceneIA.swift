//
//  GameSceneIA.swift
//  Dumble
//
//  Created by Florian Sorin on 16/04/2018.
//  Copyright © 2018 Florian Sorin. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

// Define all methods related to IA
extension GameScene {
    
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
}
