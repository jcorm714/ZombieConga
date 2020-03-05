//
//  GameScene.swift
//  ZombieConga
//
//  Created by Josh Cormier on 3/3/20.
//  Copyright © 2020 Josh Cormier. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    private var zombie: SKSpriteNode!
    private var zombieSpeed: Float = 480
    private var velocity: CGPoint = CGPoint(x:0, y:0)
    private var lastPoint: CGPoint = CGPoint(x:0, y:0)
    private var zombieRad: CGFloat = 4.0 * CGFloat.pi
    private var shortest: CGFloat = CGFloat(0)
    
    
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    
    let playableRect: CGRect
    
    override init(size: CGSize) {
    let maxAspectRatio:CGFloat = 16.0/9.0 // 1
    let playableHeight = size.width / maxAspectRatio // 2
    let playableMargin = (size.height-playableHeight)/2.0 // 3
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width,
        height: playableHeight) // 4
        super.init(size: size) // 5
        }
        required init(coder aDecoder: NSCoder) {
          fatalError("init(coder:) has not been implemented") // 6
        }
    func debugDrawPlayableArea() {
        let shape = SKShapeNode(rect: playableRect)
        shape.strokeColor = SKColor.red
        shape.lineWidth = 4.0
        addChild(shape)
    }
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "background1")
        zombie = SKSpriteNode(imageNamed: "zombie1")
        zombie.position = CGPoint(x: 400,y: 400)
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        //background.zRotation = CGFloat.pi / 8
        background.zPosition = -1
        self.addChild(background)
        self.addChild(zombie)
        spawnEnemy()
        let mySize = background.size
        print("Size: \(mySize)")
        debugDrawPlayableArea()
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
            
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    func sceneTouched(touchLocation:CGPoint) {
        self.lastPoint = touchLocation
      moveZombie(location: touchLocation)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        sceneTouched(touchLocation: touchLocation)
        
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        sceneTouched(touchLocation: touchLocation)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        move(zombie, velocity)
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
            
        }
        lastUpdateTime = currentTime
        print("\(dt*1000) milliseconds since last update")
        boundsCheckZombie()
        rotate(zombie, velocity)
        arrivedAtPoint()
    }
    
    func move( _ sprite: SKSpriteNode, _ velocity: CGPoint){
        let dist = CGPoint(x: velocity.x * CGFloat(dt),
            y: velocity.y * CGFloat(dt) )
        sprite.position = CGPoint (
            x: sprite.position.x + dist.x,
            y: sprite.position.y + dist.y
        )
    }
    
    
    func moveZombie(location: CGPoint){
        let offset = CGPoint(x: location.x - zombie.position.x, y: location.y - zombie.position.y)
        let length = sqrt(Double(offset.x * offset.x + offset.y * offset.y))
        
        let direction = CGPoint(x: offset.x / CGFloat(length), y: offset.y / CGFloat(length))
        velocity = CGPoint(x: Int(Float(direction.x) * zombieSpeed), y: Int(Float(direction.y) * zombieSpeed))
        
    }
    
    
    func boundsCheckZombie() {
        let bottomLeft = CGPoint(x: 0, y: playableRect.minY)
        let topRight = CGPoint(x: size.width, y: playableRect.maxY)
        if zombie.position.x <= bottomLeft.x {
            zombie.position.x = bottomLeft.x
            velocity.x = -velocity.x
            
        }
        if zombie.position.x >= topRight.x {
            zombie.position.x = topRight.x
            velocity.x = -velocity.x
            
        }
        if zombie.position.y <= bottomLeft.y {
            zombie.position.y = bottomLeft.y
            velocity.y = -velocity.y
            
        }
        if zombie.position.y >= topRight.y {
            zombie.position.y = topRight.y
            velocity.y = -velocity.y
            
        }
    }
    func rotate(_ sprite: SKSpriteNode, _ direction: CGPoint) {
        sprite.zRotation = atan2(direction.y, direction.x)
        
    }
    func arrivedAtPoint()
    {
        let offset = CGPoint(x: lastPoint.x - zombie.position.x, y: lastPoint.y - zombie.position.y)
        let length = sqrt(Double(offset.x * offset.x + offset.y * offset.y))
        
        
        
        if(Float(length) <= Float(dt) * Float(zombieSpeed)){
            zombie.position = lastPoint
            velocity = CGPoint(x: 0, y: 0)
        }
        
    }
    
    
    func shortestAng(angle1: CGFloat, angle2: CGFloat) ->CGFloat{
        let twoPi = 2.0 * CGFloat.pi
        var angle = (angle1 - angle2).truncatingRemainder(dividingBy: twoPi)
        if angle >= CGFloat.pi {
            angle = angle - twoPi
        }
        if angle <= -CGFloat.pi {
            angle = angle + twoPi
          }
        return angle
    }
    
    func sign(num: CGFloat)->CGFloat {
        return num >= 0.0 ? 1.0 : -1.0
        
    }
    
    func spawnEnemy(){
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.position = CGPoint(x: size.width + enemy.size.width/2, y: size.height/2)
        addChild(enemy)
        let actionMove = SKAction.move(to: CGPoint(x: -enemy.size.width/2, y: enemy.position.y), duration: 2.0)
        enemy.run(actionMove)

    }
    
    
}








