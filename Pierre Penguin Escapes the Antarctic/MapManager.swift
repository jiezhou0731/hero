import SpriteKit

class MapManager {
    // Store your item file names:
    let itemNames:[String] = [
        "map1"
    ]
    // Each item is an SKNode, store an array:
    var items:[SKNode] = []
    var currentItemIndex:Int?
    var previousItemIndex:Int?
    
    init() {
        for itemFileName in itemNames {
            // Create a new node for the item:
            let node = SKNode()
            // Try to load this scene file into a new SKScene instance:
            if let itemScene = SKScene(fileNamed: itemFileName) {
                // Loop through each placeholder, spawn the appropriate game object:
                for placeholder in itemScene.children {
                    if let node = placeholder as? SKNode {
                        let args = node.name!.characters.split {$0 == "_"}.map(String.init)
                        node.name = args[0]
                        print (args[0])
                        switch node.name! {
                        case "RoomFrameX":
                            let item = RoomFrameX()
                            item.spawn((ObjectPool.gameScene?.world)!, position: node.position)
                        case "RoomFrameY":
                            let item = RoomFrameY()
                            item.spawn((ObjectPool.gameScene?.world)!, position: node.position)
                        case "Floor":
                            let item = Floor()
                            let width = CGFloat(NSNumberFormatter().numberFromString(args[1])!)
                            item.spawn((ObjectPool.gameScene?.world)!, position: node.position,  size: CGSize(width: width, height: 3) )
                        default:
                            print("item node name not found: \(node.name)")
                        }
                    }
                }
            }
            print (SKScene(fileNamed: itemFileName))
            // Add the populated item node to the item array:
            items.append(node)
            // Save initial sprite positions for this item:
            saveSpritePositions(node)
        }
    }
    
    // This function will append all of the item nodes
    // to the world node from our GameScene:
    func addItemsToWorld(world:SKNode) {
    }
    
    func placeNextitem(currentXPos:CGFloat) {
        // Count the items in a random ready type (Uint32):
        let itemCount = UInt32(items.count)
        // The game requires at least 3 items to function properly,
        // so exit this function if there are less than 3
        if itemCount < 3 { return }
        
        // We need to make sure to pick an item that is not
        // currently displayed on the screen.
        var nextItemIndex:Int?
        var trulyNew:Bool?
        // The current item and the directly previous item
        // can potentially be on the screen at this time.
        // Pick until we get a new item
        while trulyNew == false || trulyNew == nil {
            // Pick a random item to set next:
            nextItemIndex = Int(arc4random_uniform(itemCount))
            // To begin, assert that this is a new item:
            trulyNew = true
            // Test if it is a current item:
            if let currentIndex = currentItemIndex {
                if (nextItemIndex == currentIndex) {
                    trulyNew = false
                }
            }
            // Test if it is the directly previous item:
            if let previousIndex = previousItemIndex {
                if (nextItemIndex == previousIndex) {
                    trulyNew = false
                }
            }
        }
        
        // Keep track of the current item:
        previousItemIndex = currentItemIndex
        currentItemIndex = nextItemIndex
        
        // Reset the new item and position it ahead of the player
        let item = items[currentItemIndex!]
        item.position = CGPoint(x: currentXPos + 1000, y: 0)
        resetSpritePositions(item)
    }
    
    // Store the initial positions of the children of a node:
    func saveSpritePositions(node:SKNode) {
        for sprite in node.children {
            if let spriteNode = sprite as? SKSpriteNode {
                let initialPositionValue = NSValue(CGPoint: sprite.position)
                spriteNode.userData = ["initialPosition": initialPositionValue]
                // Recursively save the positions for children of this node:
                saveSpritePositions(spriteNode)
            }
        }
    }
    
    // Reset all children nodes to their original position:
    func resetSpritePositions(node:SKNode) {
        for sprite in node.children {
            if let spriteNode = sprite as? SKSpriteNode {
                // Remove any linear or angular velocity:
                spriteNode.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                spriteNode.physicsBody?.angularVelocity = 0
                // Reset the rotation of the sprite:
                spriteNode.zRotation = 0
                if let initialPositionVal = spriteNode.userData?.valueForKey("initialPosition") as? NSValue {
                    // Reset the position of the sprite:
                    spriteNode.position = initialPositionVal.CGPointValue()
                }
                
                // Reset positions on this node's children
                resetSpritePositions(spriteNode)
            }
        }
    }
}
