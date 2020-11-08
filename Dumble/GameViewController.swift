//
//  GameViewController.swift
//  Dumble
//
//  Created by Florian Sorin on 31/08/2017.
//  Copyright © 2017 Florian Sorin. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    var layoutInitialized = false;

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if !layoutInitialized {
            layoutInitialized = true
            
            if let view = self.view as! SKView? {
                // Load the SKScene from 'GameScene.sks'
                let scene = GameScene(size: view.safeAreaLayoutGuide.layoutFrame.size) // view.frame.size)
                
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFit
                
                scene.backgroundColor = UIColor.black
                
                // Present the scene
                view.presentScene(scene)
                
                view.ignoresSiblingOrder = true
                
                // view.showsFPS = true
                // view.showsNodeCount = true
            }
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
