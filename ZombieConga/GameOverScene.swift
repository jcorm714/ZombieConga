//
//  GameOverScene.swift
//  ZombieConga
//
//  Created by Josh Cormier on 3/5/20.
//  Copyright © 2020 Josh Cormier. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene{
    let won: Bool
    
    init(size: CGSize, won: Bool) {
        self.won = won
        super.init(size: size)
    }
    
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    
    override func didMove(to view: SKView) {
      var background: SKSpriteNode
      if (won) {
        background = SKSpriteNode(imageNamed: "YouWin")
        run(SKAction.playSoundFileNamed("./Sounds/win.wav", waitForCompletion: false))
      } else {
        background = SKSpriteNode(imageNamed: "YouLose")
        run(SKAction.playSoundFileNamed("./Sounds/lose.wav",
        waitForCompletion: false))
      }
      background.position = CGPoint(x: size.width/2, y: size.height/2)
      self.addChild(background)
        
      let wait = SKAction.wait(forDuration: 3.0)
      let block = SKAction.run {
          let s = GameScene(size: self.size)
          s.scaleMode = self.scaleMode
          let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            self.view?.presentScene(s, transition: reveal)
      }
      self.run(SKAction.sequence([wait, block]))
    }
    
 
}
