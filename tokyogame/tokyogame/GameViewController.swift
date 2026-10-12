//
//  GameViewController.swift
//  tokyogame
//
//  Created by Austin Gao on 10/11/26.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let skView = self.view as? SKView, skView.scene == nil else { return }
        guard skView.bounds.width > 0 && skView.bounds.height > 0 else { return }
        
        // Present MainMenuScene as the game entry point
        let scene = MainMenuScene(size: skView.bounds.size)
        scene.scaleMode = .resizeFill
        
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        skView.presentScene(scene)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
