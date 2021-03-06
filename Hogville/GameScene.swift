//
//  GameScene.swift
//  Hogville
//
//  Created by Jean-Pierre Distler on 23.08.14.
//  Copyright (c) 2014 Jean-Pierre Distler. All rights reserved.
//

import SpriteKit

enum ColliderType: UInt32 {
	case Animal = 1
	case Food = 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {

	var movingPig: Pig?
	var lastUpdateTime: NSTimeInterval = 0.0
	var dt: NSTimeInterval = 0.0

	var homeNode = SKNode()
	var currentSpawnTime: NSTimeInterval = 5.0

	var gameOver = false

	// Touch handling
	override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {

		// If the game is over, just start over.
		if gameOver {
			restartGame()
		}

		let aTouch = touches.first as! UITouch
		let location = aTouch.locationInNode(scene)

//		let location = touches.first().locationInNode(self)
		let node = nodeAtPoint(location)

		if node.name == "pig" {
			let pig = node as! Pig

			// Clear any previoius points on the path
			pig.clearWayPoints()

			pig.addMovingPoint(location)
			movingPig = pig
		}
	}

	override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {

		let aTouch = touches.first as! UITouch
		let location = aTouch.locationInNode(scene)
		if let pig = movingPig {
			pig.addMovingPoint(location)
		}
	}

	override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
		movingPig = nil
	}

	// Update Method
	override func update(currentTime: CFTimeInterval) {

		if !gameOver {
			dt = currentTime - lastUpdateTime
			lastUpdateTime = currentTime

			enumerateChildNodesWithName("pig", usingBlock: {node, stop in
				let pig = node as! Pig
				pig.move(self.dt)
			})

			drawLines()
		}
	}

	override init(size: CGSize) {
		super.init(size: size)

		physicsWorld.gravity = CGVectorMake(0.0, 0.0)
		physicsWorld.contactDelegate = self

		// Load the background and base scene elements
		loadLevel()

		// Set up the pigs to load - first and forever
		spawnAnimal()
	}

	required init(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func loadLevel () {
		//1
		let bg = SKSpriteNode(imageNamed:"bg_2_grassy")
		bg.anchorPoint = CGPoint(x: 0, y: 0)
		addChild(bg)

		//2
		let foodNode = SKSpriteNode(imageNamed:"trough_3_full")
		foodNode.name = "food"
		foodNode.position = CGPoint(x:250, y:200)
		foodNode.zPosition = 1

		foodNode.physicsBody = SKPhysicsBody(rectangleOfSize: foodNode.size)
		foodNode.physicsBody!.categoryBitMask = ColliderType.Food.rawValue
		foodNode.physicsBody!.dynamic = false
		addChild(foodNode)

		//3
		homeNode = SKSpriteNode(imageNamed: "barn")
		homeNode.name = "home"
		homeNode.position = CGPoint(x: 500, y: 20)
		homeNode.zPosition = 1
		addChild(homeNode)

		currentSpawnTime = 5.0
	}

	func spawnAnimal() {

		// If the game is over, never mind
		if gameOver {
			return
		}

		//1
		currentSpawnTime -= 0.2

		//2
		if currentSpawnTime < 1.0 {
			currentSpawnTime = 1.0
		}

		let pig = Pig(imageNamed: "pig_1")
		pig.position = CGPoint(x: 20, y: Int(arc4random_uniform(300)))
		pig.name = "pig"

		addChild(pig)

		pig.moveRandom()

		runAction(SKAction.sequence([SKAction.waitForDuration(currentSpawnTime), SKAction.runBlock({
			self.spawnAnimal()
			}
			)]))
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
			let pig = node as! Pig
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

	// Physics World Contact Delegate
	func didBeginContact(contact: SKPhysicsContact) {
		// 1
		let firstNode = contact.bodyA.node
		let secondNode = contact.bodyB.node

		//2
		let collision = firstNode!.physicsBody!.categoryBitMask | secondNode!.physicsBody!.categoryBitMask

		//3
		if collision == ColliderType.Animal.rawValue | ColliderType.Animal.rawValue {
			NSLog("Animal collision detected")

			// Pigs collided - handle the collision
			handleAnimalCollision()

		} else if collision == ColliderType.Animal.rawValue | ColliderType.Food.rawValue {
			NSLog("Food collision detected.")

			var pig: Pig!

			if firstNode!.name == "pig" {
				pig = firstNode as! Pig
				pig.eat()
			} else {
				pig = secondNode as! Pig
				pig.eat()
			}
		} else {
			NSLog("Error: Unknown collision category \(collision)")
		}
	}

	// When two pigs collide
	func handleAnimalCollision() {
		gameOver = true

		let gameOverLabel = SKLabelNode(fontNamed: "Thonburi-Bold")
		gameOverLabel.text = "Game Over!"
		gameOverLabel.name = "label"
		gameOverLabel.fontSize = 35.0
		gameOverLabel.position = CGPointMake(size.width / 2.0, size.height / 2.0 + 20.0)
		gameOverLabel.zPosition = 5

		let tapLabel = SKLabelNode(fontNamed: "Thonburi-Bold")
		tapLabel.text = "Tap to restart."
		tapLabel.name = "label"
		tapLabel.fontSize = 25.0
		tapLabel.position = CGPointMake(size.width / 2.0, size.height / 2.0 - 20.0)
		tapLabel.zPosition = 5

		addChild(gameOverLabel)
		addChild(tapLabel)
	}

	// Allow the game to restart
	func restartGame() {
		enumerateChildNodesWithName("line", usingBlock: {node, stop in
			node.removeFromParent()
		})

		enumerateChildNodesWithName("pig", usingBlock: {node, stop in
			node.removeFromParent()
		})

		enumerateChildNodesWithName("label", usingBlock: {node, stop in
			node.removeFromParent()
		})

		currentSpawnTime = 5.0
		gameOver = false
		spawnAnimal()
	}


}
