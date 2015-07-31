//
//  ViewController.swift
//  PoppingBubbles
//
//  Created by aluong on 7/31/15.
//  Copyright (c) 2015 YammerHackDay. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {
    var bubbleScene: BubbleScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let skView = view as! SKView
        bubbleScene = BubbleScene(size: skView.bounds.size)
        bubbleScene.scaleMode = .AspectFill
        skView.presentScene(bubbleScene)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

