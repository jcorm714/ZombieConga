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
    private let catMove: CGFloat = 480
    let zombieAnimation: SKAction
    private var lives = 5
    private var gameOver = false
    private var trainCount = 0
    private var audio: AudioPlayer = AudioPlayer(filename: "./Sounds/backgroundMusic.mp3")
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    
    let livesLabel = SKLabelNode(fontNamed: "Glimstick")
    let catsLabel = SKLabelNode(fontNamed: "Glimstick")
    
    let cameraMove: CGFloat = 200.0
    
    let catCollisionSound: SKAction = SKAction.playSoundFileNamed(
      "./Sounds/hitCat.wav", waitForCompletion: false)
    let enemyCollisionSound: SKAction = SKAction.playSoundFileNamed(
      "./Sounds/hitCatLady.wav", waitForCompletion: false)
    
    let playableRect: CGRect
    
    let cameraNode = SKCameraNode()
    
    
    var cameraRect : CGRect {
        let x = cameraNode.position.x - size.width/2 + (size.width - playableRect.width)/2
        let y = cameraNode.position.y - size.height/2 + (size.height - playableRect.height)/2
        return CGRect( x: x, y: y, width: playableRect.width, height: playableRect.height)
    }
    
    
    override init(size: CGSize) {
    let maxAspectRatio:CGFloat = 16.0/9.0 // 1
    let playableHeight = size.width / maxAspectRatio // 2
    let playableMargin = (size.height-playableHeight)/2.0 // 3
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width,
        height: playableHeight) // 4
        
        var textures: [SKTexture] = []
        
        for i in 1...4{
            textures.append(SKTexture(imageNamed: "zombie\(i)"))
        }
        textures.append(textures[2])
        textures.append(textures[1])
        
        zombieAnimation = SKAction.animate(with: textures, timePerFrame: 0.1)
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
        
        
        zombie = SKSpriteNode(imageNamed: "zombie1")
        zombie.position = CGPoint(x: 400,y: 400)
        zombie.zPosition = 100
        
        for i in 0...1 {
            let background = backgroundNode()
            background.anchorPoint = CGPoint.zero
            background.position = CGPoint(x: CGFloat(i)*background.size.width, y: 0)
            background.name = "background"
            background.zPosition = -1
            addChild(background)
        }
  
        cameraNode.position = CGPoint(x: size.width/2, y: size.height/2)

        livesLabel.text = "Lives: \(lives)"
        livesLabel.fontColor = SKColor.black
        livesLabel.fontSize = 100
        livesLabel.zPosition = 150
        livesLabel.horizontalAlignmentMode = .left
        livesLabel.verticalAlignmentMode = .bottom
        livesLabel.position = CGPoint(x: 0 - cameraRect.width/2 + 100,
                                      y: 0 - cameraRect.height/2 + 120)
        
        catsLabel.text = "Cats: \(trainCount)"
             catsLabel.fontColor = SKColor.black
             catsLabel.fontSize = 100
             catsLabel.zPosition = 150
             catsLabel.horizontalAlignmentMode = .right
             catsLabel.verticalAlignmentMode = .bottom
        catsLabel.position = CGPoint(x:  cameraRect.width/2 - 100, y: 0 - cameraRect.height/2 + 120)
        
        cameraNode.addChild(livesLabel)
        cameraNode.addChild(catsLabel)
        
        self.camera = cameraNode
        
        self.addChild(zombie)
        self.addChild(cameraNode)
        audio.play()

        //spawn old lady
        run(SKAction.repeatForever(
            SKAction.sequence([SKAction.run(){
                [weak self] in self?.spawnEnemy()
                }, SKAction.wait(forDuration: 4.5)])))
        
        
        //spawn cats
        run(SKAction.repeatForever(
        SKAction.sequence([SKAction.run() { [weak self] in
                            self?.spawnCat()
                          },
                          SKAction.wait(forDuration: 1.0)])))
        
       // debugDrawPlayableArea()
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
    
    
    
    
    //Update loop
    //put lots of comments
    //notice me
    //stop scrolling over update
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        move(zombie, velocity)
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
            
        }
        lastUpdateTime = currentTime
        boundsCheckZombie()
        rotate(zombie, velocity)
        //arrivedAtPoint()
        moveTrain()
        moveCamera()
        
//        cameraNode.position = zombie.position
        //game lost
        if lives <= 0 && !gameOver{
            gameOver = true
            let gameOverScene = GameOverScene(size: size, won: false)
            gameOverScene.scaleMode = scaleMode
                       
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            audio.stop()
            view?.presentScene(gameOverScene, transition: reveal)
        }
        
        //game win
        if trainCount >= 15 && !gameOver{
            gameOver = true
            
            let gameOverScene = GameOverScene(size: size, won: true)
            gameOverScene.scaleMode = scaleMode
            
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            audio.stop()
            view?.presentScene(gameOverScene, transition: reveal)
        }
        
    }
    
    //gets called before update
    override func didEvaluateActions() {
        checkCollisions()
    }
    
    //gross function to move sprite
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
        startZombieAnimation()
        
    }
    
    
    func boundsCheckZombie() {
        let bottomLeft = CGPoint(x: cameraRect.minX, y: cameraRect.minY)
        let topRight = CGPoint(x: cameraRect.maxX, y: cameraRect.maxY)
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
            stopZombieAnimation()
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
        enemy.position = CGPoint(x: cameraRect.maxX - (cameraRect.maxX * 0.1),
                                 y: random(min: cameraRect.minY + enemy.size.height/2,
                                            max: cameraRect.maxY - enemy.size.height/2))
        enemy.name = "enemy"
        addChild(enemy)
       
        let actionMove = SKAction.moveBy(
          x: -size.width/2-enemy.size.width/2,
          y: playableRect.height/2 - enemy.size.height/2,
          duration: 3.0)

        
         let actionRemove = SKAction.removeFromParent()
         enemy.run(SKAction.sequence([actionMove, actionRemove]))

    }
    
    func random() -> CGFloat{
        return CGFloat(Float(arc4random())/Float(UInt32.max))
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat{
        assert(min < max)
        return random() * (max - min) + min
    }
    
    
    func startZombieAnimation(){
        if zombie.action(forKey: "animation") == nil {
            zombie.run(
                SKAction.repeatForever(zombieAnimation),
                withKey: "animation"
            )
        }
    }
    
    func stopZombieAnimation(){
        zombie.removeAction(forKey: "animation")
    }
    
    func spawnCat() {
        let cat = SKSpriteNode(imageNamed: "cat")
        cat.position = CGPoint(x: random(min: cameraRect.minX, max:cameraRect.maxX),
                               y: random(min: cameraRect.minY, max:cameraRect.maxY))
        cat.setScale(0)
        cat.zPosition = 40
        cat.name = "cat"
        addChild(cat)
        
        let appear = SKAction.scale(to:1.0, duration: 0.5)
        cat.zRotation = -CGFloat.pi / 16.0
        let leftWiggle = SKAction.rotate(byAngle: CGFloat.pi/8.0, duration: 0.5)
        let rightWiggle = leftWiggle.reversed()
        let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
        let scaleUp = SKAction.scale(by: 1.2, duration: 0.25)
        let scaleDown = scaleUp.reversed()
        let fullScale = SKAction.sequence(
          [scaleUp, scaleDown, scaleUp, scaleDown])
        let group = SKAction.group([fullScale, fullWiggle])
        let groupWait = SKAction.repeat(group, count: 10)
        let disappear = SKAction.scale(to: 0, duration: 0.5)
        let removeFromParent = SKAction.removeFromParent()
        let actions = SKAction.sequence([appear, groupWait, disappear, removeFromParent])
        cat.run(actions)
    }
    
    
    func zombieHit(cat: SKSpriteNode){
        run(catCollisionSound)
        cat.name = "train"
        cat.removeAllActions()
        cat.setScale(1)
        cat.zRotation = 0.0
        trainCount += 1
        catsLabel.text = "Cats: \(trainCount)"
        let turnGreen = SKAction.colorize(with: .green, colorBlendFactor: 1, duration: 0.2)
        cat.run(turnGreen, withKey: "green")
        
    }
    
    func zombieHit(enemy: SKSpriteNode){
        run(enemyCollisionSound)
        loseCats()
        lives -= 1
        livesLabel.text = "Lives: \(lives)"
        catsLabel.text = "Cats: \(trainCount)"
        enemy.removeFromParent()
    }
    
    func checkCollisions(){
        var hitCats: [SKSpriteNode] = []
        enumerateChildNodes(withName: "cat", using: {
            node , _ in
            let cat = node as! SKSpriteNode
            if( cat.frame.intersects(self.zombie.frame))
            {
                hitCats.append(cat)
            }
        })
        
        for cat in hitCats{
            zombieHit(cat: cat)
        }
        
        var hitEnemies: [SKSpriteNode] = []
        enumerateChildNodes(withName: "enemy", using: {
            node, _ in
                let enemy = node as! SKSpriteNode
                if node.frame.insetBy(dx: 20, dy: 20).intersects(self.zombie.frame)
                {
                    hitEnemies.append(enemy);
                }
        })
        
        for enemy in hitEnemies {
            zombieHit(enemy: enemy)
        }
    }
    
    func moveTrain()
    {
        var targetPos = zombie.position
        enumerateChildNodes(withName: "train", using: {
            node, stop in
            if node.action(forKey: "moveTrain") == nil{
                let actionDuration: Float = 0.3
                let offset = CGPoint(x: targetPos.x - node.position.x, y:  targetPos.y - node.position.y)
                let length = sqrt(Double(offset.x * offset.x + offset.y * offset.y))
                let normal = CGPoint(x: Double(offset.x)/length, y: Double(offset.y)/length)
                let amountToMove = normal * self.catMove
                let amountToMovePerSec = CGPoint(x: amountToMove.x * CGFloat(actionDuration), y: amountToMove.y * CGFloat(actionDuration))
                let moveAction = SKAction.moveBy(x: amountToMovePerSec.x, y: amountToMovePerSec.y, duration: Double(actionDuration))
    
                node.run(moveAction, withKey: "moveTrain")
            }
            targetPos = node.position
        })
    }
    
    
    func loseCats(){
        var loseCount = 0
        enumerateChildNodes(withName: "train", using: {
            node, stop in
            var randomSpot = node.position
            randomSpot.x += self.random(min: -100, max: 100)
            randomSpot.y += self.random(min: -100, max: 100)
            
            node.name = ""
            node.run(SKAction.sequence([
                SKAction.group([
                    SKAction.rotate(byAngle: CGFloat.pi * 4, duration: 1.0),
                    SKAction.move(to: randomSpot, duration: 1.0),
                    SKAction.scale(to: 0, duration: 1)
                    
                ]),
                
                SKAction.removeFromParent()
                
            ]))
            loseCount += 1
            self.trainCount = self.trainCount >= 0 ? self.trainCount - 1 : self.trainCount
            if loseCount >= 2{
                stop[0] = true
            }
        })
    }
    
    
    func backgroundNode() -> SKSpriteNode {
        let backgroundNode = SKSpriteNode()
        backgroundNode.anchorPoint = CGPoint.zero
        backgroundNode.name = "background"
       
        let background1 = SKSpriteNode(imageNamed: "background1")
        background1.anchorPoint = CGPoint.zero
        background1.position = CGPoint(x: 0, y: 0)
        backgroundNode.addChild(background1)
       
        let background2 = SKSpriteNode(imageNamed: "background2")
        background2.anchorPoint = CGPoint.zero
        background2.position = CGPoint(x: background1.size.width, y: 0)
        backgroundNode.addChild(background2)
        backgroundNode.size = CGSize(
        width: background1.size.width + background2.size.width, height: background1.size.height)
          
        return backgroundNode
    }
    
    func moveCamera() {
        let backgroundVelocity = CGPoint(x: cameraMove, y: 0)
        let amountToMove = backgroundVelocity * CGFloat(dt)
        cameraNode.position += amountToMove
        
        enumerateChildNodes(withName: "background") {
            node, _ in
            let background = node as! SKSpriteNode
            if background.position.x + background.size.width < self.cameraRect.origin.x
            {
                background.position = CGPoint(
                    x: background.position.x + background.size.width*2,
                    y: background.position.y)
                
            }
        }
    }

}
