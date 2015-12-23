//
//  Background.swift
//  Pierre Penguin Escapes the Antarctic
//

import SpriteKit

class Background: SKSpriteNode {
    // movementMultiplier will store a value from 0-1 to indicate
    // how fast the background should move past.
    // 0 is full adjustment, no movement as the world goes past
    // 1 is no adjustment, background passes at normal speed
    var movementMultiplier = CGFloat(0)
    // Store a jump adjustment amount for looping with parallax positioning
    var adjustedPosition = CGPoint(x:0 , y:0)
    // Constant for background node size:
    let backgroundSize = CGSize(width: 960, height: 540)
    
    func spawn(parentNode:SKNode, imageName:String, zPosition:CGFloat) {
        // Position from the bottom left:
        self.anchorPoint = CGPointZero
        // Start backgrounds at the top of the ground (30 on the y-axis):
        self.position = CGPoint(x: 0, y: 30)
        // We can control the order of the backgrounds with zPosition:
        self.zPosition = zPosition
        // Add the background to the parentNode:
        parentNode.addChild(self)
        
        // Build three child node instances of the texture,
        // Looping from -1 to 1 so the backgrounds cover both
        // forward and behind the player at position zero.
        // The closed range operator, used here, includes both end points:
        for i in -2...2 {
            for j in -2...2 {
                let newBGNode = SKSpriteNode(imageNamed: imageName)
                // Set the size for this node from our backgroundSize constant:
                newBGNode.size = backgroundSize
                // Position these nodes by their lower left corner:
                newBGNode.anchorPoint = CGPointZero
                // Position this background node:
                newBGNode.position = CGPoint(x: i * Int(backgroundSize.width), y: j * Int(backgroundSize.height))
                newBGNode.zPosition = 1
                // Add the node to the Background:
                self.addChild(newBGNode)
            }
        }
    }
    
    // We will call updatePosition every update to
    // reposition the background:
    func updatePosition(playerPosition:CGPoint) {
        if (fabs(playerPosition.x - adjustedPosition.x) > backgroundSize.width) {
            if (playerPosition.x - adjustedPosition.x < backgroundSize.width){
                adjustedPosition.x -= backgroundSize.width
            } else {
                adjustedPosition.x += backgroundSize.width
            }
        }
        
        if (fabs(playerPosition.y - adjustedPosition.y) > backgroundSize.height) {
            if (playerPosition.y - adjustedPosition.y < backgroundSize.height){
                adjustedPosition.y -= backgroundSize.height
            } else {
                adjustedPosition.y += backgroundSize.height
            }
        }
        
        self.position = adjustedPosition
    }
    
}