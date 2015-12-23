import SpriteKit

class Floor: SKSpriteNode, GameSprite {
    var textureAtlas:SKTextureAtlas = SKTextureAtlas(named:"map.atlas")
    var flyAnimation = SKAction()

    func spawn(parentNode:SKNode, position: CGPoint, size: CGSize = CGSize(width: 800, height: 3)) {
        parentNode.addChild(self)
        createAnimations()
        self.size = size
        self.position = position
        self.runAction(flyAnimation)
        
        self.physicsBody = SKPhysicsBody(rectangleOfSize: size)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.dynamic = false
        self.physicsBody?.categoryBitMask = PhysicsCategory.geo.rawValue
        self.physicsBody?.collisionBitMask = ~PhysicsCategory.geo.rawValue
    }

    func createAnimations() {
        let flyFrames:[SKTexture] = [textureAtlas.textureNamed("roomFrameX.png")]
        let flyAction = SKAction.animateWithTextures(flyFrames, timePerFrame: 0.14)
        flyAnimation = SKAction.repeatActionForever(flyAction)
    }
    
    func onTap() {}
}