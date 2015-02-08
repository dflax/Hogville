//
//  GameScene.swift
//  Hogville
//
//  Created by Jean-Pierre Distler on 23.08.14.
//  Copyright (c) 2014 Jean-Pierre Distler. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {

	var movingPig: Pig?
	var lastUpdateTime: NSTimeInterval = 0.0
	var dt: NSTimeInterval = 0.0

	// Touch handling
	override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
		let location = touches.anyObject()!.locationInNode(self)
		let node = nodeAtPoint(location)

		if node.name? == "pig" {
			let pig = node as Pig
			pig.addMovingPoint(location)
			movingPig = pig
		}
	}

	override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
		let location = touches.anyObject()!.locationInNode(scene)
		if let pig = movingPig {
			pig.addMovingPoint(location)
		}
	}

	override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
		movingPig = nil
	}

	// Update Method
	override func update(currentTime: CFTimeInterval) {
		dt = currentTime - lastUpdateTime
		lastUpdateTime = currentTime

		enumerateChildNodesWithName("pig", usingBlock: {node, stop in
			let pig = node as Pig
			pig.move(self.dt)
		})

		drawLines()

	}


	override init(size: CGSize) {
		super.init(size: size)

		let bg = SKSpriteNode(imageNamed: "bg_2_grassy")
		bg.anchorPoint = CGPoint(x: 0, y: 0)
		addChild(bg)

		let pig = Pig(imageNamed: "pig_1")
		pig.name = "pig"

		pig.position = CGPoint(x: size.width / 2, y: size.height / 2)
		addChild(pig)
	}

	required init(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// Draw the lines
	func drawLines() {
		//1
		enumerateChildNodesWithName("line", usingBlock: {node, stop in
			node.removeFromParent()
		})

		//2
		enumerateChildNodesWithName("pig", usingBlock: {node, stop in

			//3
			let pig = node as Pig
			if let path = pig.createPathToMove() {
				let shapeNode = SKShapeNode()
				shapeNode.path = path
				shapeNode.name = "line"
				shapeNode.strokeColor = UIColor.grayColor()
				shapeNode.lineWidth = 2
				shapeNode.zPosition = 1

				self.addChild(shapeNode)
			}
		})
	}


}
