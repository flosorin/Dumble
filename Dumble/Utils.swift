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
