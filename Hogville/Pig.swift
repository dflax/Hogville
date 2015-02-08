//
//  Pig.swift
//  Hogville
//
//  Created by Daniel Flax on 2/8/15.
//  Copyright (c) 2015 Jean-Pierre Distler. All rights reserved.
//

import SpriteKit

class Pig: SKSpriteNode {
	let POINTS_PER_SEC: CGFloat = 80.0
	var wayPoints: [CGPoint] = []
	var velocity = CGPoint(x: 0, y: 0)

	init(imageNamed name: String) {
		let texture = SKTexture(imageNamed: name)
		super.init(texture: texture, color: nil, size: texture.size())
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	func addMovingPoint(point: CGPoint) {
		wayPoints.append(point)
	}

	func move(dt: NSTimeInterval) {
		let currentPosition = position
		var newPosition = position

		//1
		if wayPoints.count > 0 {
			let targetPoint = wayPoints[0]

			//1
			let offset = CGPoint(x: targetPoint.x - currentPosition.x, y: targetPoint.y - currentPosition.y)
			let length = Double(sqrtf(Float(offset.x * offset.x) + Float(offset.y * offset.y)))
			let direction = CGPoint(x:CGFloat(offset.x) / CGFloat(length), y: CGFloat(offset.y) / CGFloat(length))
			velocity = CGPoint(x: direction.x * POINTS_PER_SEC, y: direction.y * POINTS_PER_SEC)

			//2
			newPosition = CGPoint(x:currentPosition.x + velocity.x * CGFloat(dt), y:currentPosition.y + velocity.y * CGFloat(dt))
			position = newPosition

			//3
			if frame.contains(targetPoint) {
				wayPoints.removeAtIndex(0)
			}
		} else {
			newPosition = CGPoint(x: currentPosition.x + velocity.x * CGFloat(dt),
				y: currentPosition.y + velocity.y * CGFloat(dt))
//			position = newPosition
			position = checkBoundaries(newPosition)
		}
	}

	func createPathToMove() -> CGPathRef? {
		//1
		if wayPoints.count <= 1 {
			return nil
		}

		//2
		var ref = CGPathCreateMutable()

		//3
		for var i = 0; i < wayPoints.count; ++i {
			let p = wayPoints[i]

			//4
			if i == 0 {
				CGPathMoveToPoint(ref, nil, p.x, p.y)
			} else {
				CGPathAddLineToPoint(ref, nil, p.x, p.y)
			}
		}

		return ref
	}

	// Check the boundries for the pig to bounce
	func checkBoundaries(position: CGPoint) -> CGPoint {
		//1
		var newVelocity = velocity
		var newPosition = position

		//2
		let bottomLeft = CGPoint(x: 0, y: 0)
		let topRight = CGPoint(x:scene!.size.width, y:scene!.size.height)

		//3
		if newPosition.x <= bottomLeft.x {
			newPosition.x = bottomLeft.x
			newVelocity.x = -newVelocity.x
		} else if newPosition.x >= topRight.x {
			newPosition.x = topRight.x
			newVelocity.x = -newVelocity.x
		}

		if newPosition.y <= bottomLeft.y {
			newPosition.y = bottomLeft.y
			newVelocity.y = -newVelocity.y
		} else if newPosition.y >= topRight.y {
			newPosition.y = topRight.y
			newVelocity.y = -newVelocity.y
		}

		velocity = newVelocity

		return newPosition
	}


}



