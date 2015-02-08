//
//  GameScene.swift
//  Hogville
//
//  Created by Jean-Pierre Distler on 23.08.14.
//  Copyright (c) 2014 Jean-Pierre Distler. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {

	override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
		// Called when a touch begins
	}

	override func update(currentTime: CFTimeInterval) {
		/* Called before each frame is rendered */
	}

	override init(size: CGSize) {
		super.init(size: size)

		let bg = SKSpriteNode(imageNamed: "bg_2_grassy")
		bg.anchorPoint = CGPoint(x: 0, y: 0)
		addChild(bg)

		let pig = SKSpriteNode(imageNamed: "pig_1")
		pig.position = CGPoint(x: size.width / 2, y: size.height / 2)
		addChild(pig)
	}

	required init(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


}
