//
//  Ground.swift
//  Pierre Penguin Escapes the Antarctic
//

import SpriteKit

class Ground: SKSpriteNode, GameSprite {
    var textureAtlas:SKTextureAtlas = SKTextureAtlas(named:"ground.atlas")
    var groundTexture:SKTexture?
    var jumpWidth = CGFloat()
    var jumpCount = CGFloat(1)
    
    func spawn(parentNode:SKNode, position: CGPoint, size: CGSize) {
        parentNode.addChild(self)
        self.size = size
        self.position = position
        self.anchorPoint = CGPointMake(0, 1)
    
        if groundTexture == nil {
            groundTexture = textureAtlas.textureNamed("ice-tile.png");
        }

        createChildren()
    
        // Draw an edge physics body along the top of the ground node.
        // Note: physics body positions are relative to their nodes.
        // The top left is X: 0, Y: 0, given our anchor point.
        // The top right is X: size.width, Y: 0
        let pointTopRight = CGPoint(x: size.width, y: 0)
        self.physicsBody = SKPhysicsBody(edgeFromPoint: CGPointZero, toPoint: pointTopRight)
        self.physicsBody?.categoryBitMask = PhysicsCategory.ground.rawValue
    }
    
    func createChildren() {
        if let texture = groundTexture {
            var tileCount:CGFloat = 0
            let textureSize = texture.size()
            let tileSize = CGSize(width: textureSize.width / 2, height: textureSize.height / 2)
            
            while tileCount * tileSize.width < self.size.width {
                let tileNode = SKSpriteNode(texture: texture)
                tileNode.size = tileSize
                tileNode.position.x = tileCount * tileSize.width
                tileNode.anchorPoint = CGPoint(x: 0, y: 1)
                self.addChild(tileNode)
                
                tileCount++
            }
            
            jumpWidth = tileSize.width * floor(tileCount / 3)
        }
    }
    
    func checkForReposition(playerProgress:CGFloat) {
        // The ground needs to jump every time the player has moved this distance:
        let groundJumpPosition = jumpWidth * jumpCount
        
        if playerProgress >= groundJumpPosition {
            // The player has moved past the jump position!
            // Move the ground forward:
            self.position.x += jumpWidth
            // Add one to the jump count:
            jumpCount++
        }
    }
    
    func onTap() {}
}