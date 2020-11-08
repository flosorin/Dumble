//
//  Utils.swift
//  Dumble
//
//  Created by Florian Sorin on 16/04/2018.
//  Copyright © 2018 Florian Sorin. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

// Resize functions keeping aspect ratio

func resizeHeight(oldSize: CGSize, newHeight: CGFloat) -> CGSize {
    let newWidth = oldSize.width * (newHeight / oldSize.height)
    return CGSize(width: newWidth, height: newHeight)
}

func resizeWidth(oldSize: CGSize, newWidth: CGFloat) -> CGSize {
    let newHeight = oldSize.height * (newWidth / oldSize.width)
    return CGSize(width: newWidth, height: newHeight)
}

func adjustLabelFontSizeToFitRect(labelNode:SKLabelNode, rect:CGRect, offset:CGFloat = 0.0) {

// Determine the font scaling factor that should let the label text fit in the given rectangle.
let scalingFactor = min((rect.width - offset) / labelNode.frame.width, rect.height / labelNode.frame.height)

// Change the fontSize.
labelNode.fontSize *= scalingFactor

// Optionally move the SKLabelNode to the center of the rectangle.
labelNode.position = CGPoint(x: rect.midX, y: rect.midY - labelNode.frame.height / 2.0)
}
