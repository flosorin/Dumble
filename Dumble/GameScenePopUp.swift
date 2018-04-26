//
//  GameScenePopUp.swift
//  Dumble
//
//  Created by Florian Sorin on 25/04/2018.
//  Copyright © 2018 Florian Sorin. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

// Define all methods related to pop ups (game over, options,...)
extension GameScene {
    
    func createSettingsPopUp() -> SKShapeNode {
        let popUp = createPopUp(title: "Settings")
        let restartButton = createButton(title: "Restart")
        popUp.addChild(restartButton)
        if let titlePositionY = popUp.childNode(withName: "popUpTitle")?.position.y {
            restartButton.position = CGPoint(x: (restartButton.parent?.frame.midX)!, y: titlePositionY - 1.5 * restartButton.frame.height)
        }
        return popUp
    }
    
    func createGameOverPopUp() -> SKShapeNode {
        let popUp = createPopUp(title: "Congratulations!", height: frame.height * 0.2)
        let okButton = createButton(title: "OK", textSize: 25, position: CGPoint(x: frame.midX, y: frame.height * 0.45), customSideWidth: popUp.frame.width * 0.2)
        popUp.addChild(okButton)
        return popUp
    }
    
    func createPopUp(title: String, height: CGFloat = 0.0) -> SKShapeNode {
        var popUpHeight = frame.height / 2
        if height != 0.0 {
            popUpHeight = height
        }
        let popUpNodeSize = CGSize(width: frame.width * 0.6, height: popUpHeight)
        let popUpNodePosition = CGPoint(x: frame.midX - popUpNodeSize.width / 2, y: frame.midY - popUpNodeSize.height / 2)
        let popUpNode = SKShapeNode(rect: CGRect(origin: popUpNodePosition, size: popUpNodeSize), cornerRadius: 10)
        popUpNode.fillColor = backgroundColor
        popUpNode.zPosition = 100 // Above everything
        // Title
        let popUpTitle = SKLabelNode(text: title)
        popUpTitle.fontSize = 25
        popUpTitle.fontColor = SKColor.white
        popUpTitle.horizontalAlignmentMode = .center;
        popUpTitle.verticalAlignmentMode = .center
        popUpTitle.fontName = "HelveticaNeue-Bold"
        popUpNode.addChild(popUpTitle)
        popUpTitle.position = CGPoint(x: (popUpTitle.parent?.frame.midX)!, y: (popUpTitle.parent?.frame.maxY)! - popUpTitle.frame.height)
        popUpTitle.name = "popUpTitle"
        // Close button
        let popUpClose = SKSpriteNode(imageNamed: "close")
        popUpClose.name = "close"
        popUpClose.size = resizeHeight(oldSize: popUpClose.size, newHeight: popUpTitle.frame.height)
        popUpNode.addChild(popUpClose)
        popUpClose.position = CGPoint(x: (popUpClose.parent?.frame.maxX)! - popUpClose.frame.width, y: (popUpClose.parent?.frame.maxY)! - popUpClose.frame.height)
        return popUpNode
    }
    
    func createButton(title: String, textSize: CGFloat = 25, position: CGPoint = CGPoint(x: 0, y: 0), customSideWidth: CGFloat = 0.0) -> SKShapeNode {
        // Title
        let buttonTitle = SKLabelNode(text: title)
        buttonTitle.fontSize = textSize
        buttonTitle.fontColor = SKColor.white
        buttonTitle.fontName = "HelveticaNeue-Bold"
        buttonTitle.name = title
        // Button
        var buttonSideWidth = buttonTitle.frame.width * 0.1
        if customSideWidth != 0.0 {
            buttonSideWidth = customSideWidth
        }
        let buttonRect = buttonTitle.frame.insetBy(dx: -buttonSideWidth, dy: -buttonTitle.frame.midY)
        let buttonNode = SKShapeNode(rect: buttonRect, cornerRadius: 10)
        buttonNode.position = CGPoint(x: position.x - buttonNode.frame.midX, y: position.y - buttonNode.frame.midY)
        buttonNode.name = title
        buttonNode.fillColor = UIColor.black
        buttonNode.addChild(buttonTitle)
        return buttonNode
    }
    
    func popUpTouchManagement(nodeName: String) {
        if !isPopUpPresent { // Display the pop up according to the name
            if (nodeName == "settings") {
                popUp = createSettingsPopUp()
                addChild(popUp)
                isPopUpPresent = true
            }
        } else { // Look for touches in the popup
            if nodeName == "close" {
                closePopUp()
            }
            if nodeName == "Restart" {
                dealButtonPressed = true
                closePopUp()
                if !players[0].gameLose {
                    // Wait for the end of the turn and restart
                    DispatchQueue.global(qos: .background).async {
                        while self.playerIndex != 0 {}
                        DispatchQueue.main.async {
                            self.dealCards()
                        }
                    }
                }
            }
        }
    }
    
    func closePopUp() {
        popUp.removeFromParent()
        isPopUpPresent = false
    }
}
