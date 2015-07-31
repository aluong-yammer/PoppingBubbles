//
//  BubbleScene.swift
//  PoppingBubbles
//
//  Created by aluong on 7/31/15.
//  Copyright (c) 2015 YammerHackDay. All rights reserved.
//

import UIKit
import SpriteKit

enum BubbleCollisionType : UInt32 {
    case BubbleCategory = 1
    case CloudCategory = 2
    case PhysicalBorderCateogry = 3
}


class BubbleScene: SKScene, SKPhysicsContactDelegate {
    
    private let kSizeOfBubble:CGFloat = 50.0;
    private let kSizeOfWhiteCloud:CGFloat = 30.0;
    private let kBubbleNodeName = "bubble"
    private var contactQueue = Array<SKPhysicsContact>()
    var selectedNode = SKSpriteNode()
    
    override init(size:CGSize) {
        super.init(size:size)
        self.backgroundColor = SKColor.whiteColor()
        let bgImage = SKSpriteNode(imageNamed:"blue_background")
        self.addChild(bgImage)
        
        let aGreyCloud = SKSpriteNode(imageNamed:"cloud_grey")
        aGreyCloud.position = CGPointMake(100, 500)
        aGreyCloud.physicsBody?.categoryBitMask = BubbleCollisionType.CloudCategory.rawValue
        aGreyCloud.physicsBody?.contactTestBitMask = 0
        aGreyCloud.physicsBody?.collisionBitMask = 0
        self.addChild(aGreyCloud)
        
        let aWhiteCloud = SKSpriteNode(imageNamed:"cloud_white")
        aWhiteCloud.position = CGPointMake(300, 550)
        aWhiteCloud.physicsBody?.categoryBitMask = BubbleCollisionType.CloudCategory.rawValue
        aWhiteCloud.physicsBody?.contactTestBitMask = 0
        aWhiteCloud.physicsBody?.collisionBitMask = 0
        self.addChild(aWhiteCloud)
        
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsBody?.categoryBitMask = BubbleCollisionType.PhysicalBorderCateogry.rawValue
        self.physicsBody?.contactTestBitMask = BubbleCollisionType.BubbleCategory.rawValue
        self.physicsBody?.collisionBitMask = 0
        self.physicsWorld.contactDelegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        // tap gesture to make bubbles
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action:Selector("addBubble:"))
        tapGestureRecognizer.numberOfTapsRequired = 2
        self.view?.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func addBubble(tapRecognizer: UITapGestureRecognizer) {
        let tapLocationInView = tapRecognizer.locationInView(tapRecognizer.view!)
        let tapLocation = self.convertPointFromView(tapLocationInView)
        
        let aBubble = SKSpriteNode(imageNamed:"bubble")
        aBubble.name = kBubbleNodeName
        aBubble.size = CGSizeMake(kSizeOfBubble, kSizeOfBubble)
        aBubble.position = tapLocation
        
        aBubble.physicsBody = SKPhysicsBody(circleOfRadius: kSizeOfBubble/2-1)
        aBubble.physicsBody?.usesPreciseCollisionDetection = true
        aBubble.physicsBody?.linearDamping = 200
        
        aBubble.physicsBody?.categoryBitMask = BubbleCollisionType.BubbleCategory.rawValue
        aBubble.physicsBody?.contactTestBitMask = BubbleCollisionType.PhysicalBorderCateogry.rawValue  | BubbleCollisionType.BubbleCategory.rawValue
        aBubble.physicsBody?.collisionBitMask = BubbleCollisionType.PhysicalBorderCateogry.rawValue
        
        self.addChild(aBubble)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        let positionInScene = touch.locationInNode(self)
        selectNodeForTouch(positionInScene)
    }
    
    func selectNodeForTouch(touchLocation:CGPoint) {
        let touchedNode = self.nodeAtPoint(touchLocation)
        
        if touchedNode is SKSpriteNode {
            if !selectedNode.isEqual(touchedNode) {
                selectedNode.removeAllActions()
                selectedNode = touchedNode as! SKSpriteNode
                if selectedNode.name == kBubbleNodeName {
                    popBubble(selectedNode)
                }
                
            }
        }
    }
    
    func popBubble(node: SKSpriteNode)
    {
        let scaleAction = SKAction.scaleBy(1.4, duration: 1.0)
        let fadeAction = SKAction.fadeAlphaTo(0, duration: 1.5)
        node.runAction(scaleAction)
        node.runAction(fadeAction, completion: { () -> Void in
            node.removeFromParent()
        })
        
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        let positionInScene = touch.locationInNode(self)
        let previousPosition = touch.previousLocationInNode(self)
        let translation = CGPoint(x: positionInScene.x - previousPosition.x, y: positionInScene.y - previousPosition.y)
        
        panForTranslation(translation)
    }
    
    func panForTranslation(translation: CGPoint) {
        let position = selectedNode.position
        
        if selectedNode.name == kBubbleNodeName {
            selectedNode.position = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        contactQueue.append(contact)
    }
    
    func processContactsQueue()
    {
        if contactQueue.count > 0 {
            for (index, aContact) in enumerate(contactQueue) {
                let node = nodeAtPoint(aContact.contactPoint) as! SKSpriteNode
                popBubble(node)
                self.contactQueue.removeAtIndex(index)
            }
        }
    }
    
    override func update(currentTime: NSTimeInterval) {
        processContactsQueue()
    }
}
