//
//  MainMenuScene.swift
//  ZombieConga
//
//  Created by Josh Cormier on 3/5/20.
//  Copyright © 2020 Josh Cormier. All rights reserved.
//

import Foundation
import SpriteKit

class MainMenuScene: SKScene{
    
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "MainMenu")
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(background)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
           guard let touch = touches.first else {
               return
           }
           let game = GameScene(size: size)
           game.scaleMode = scaleMode
                                 
           let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
           view?.presentScene(game, transition: reveal)
           
           
       }
    
}
