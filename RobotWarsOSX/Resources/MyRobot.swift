//
//  myRobot.swift
//  RobotWarsOSX
//
//  Created by MakeSchool on 30/06/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import Foundation

class MyRobot: Robot {
    
    enum RobotState {                    // enum for keeping track of RobotState
        case Scanning, Firing
    }
    
    var currentRobotState: RobotState = .Scanning
    var lastEnemyHit = CGFloat(0.0)
    let gunToleranceAngle = CGFloat(2.0)
    let firingTimeout = CGFloat(2.5)
    
    var angle : Int = 15
    var angRight : Bool = true
    
    override func run() {
        performFirstMoveAction()
        while true {
            switch currentRobotState {
            case .Scanning:
                shootingScanning()
            case .Firing:
                if currentTimestamp() - lastEnemyHit > firingTimeout {
                    cancelActiveAction()
                    turnToCenter()
                    turnGunLeft(90)
                    angle = 0
                    turnGunRight(180)
                    turnGunLeft(180)
                    currentRobotState = .Scanning
                } else {
                    shoot()
                }
            }
        }
    }
    
    func performFirstMoveAction() {
        let arenaSize = arenaDimensions()
        // find and turn towards the middle of a side
        let currentPosition = position()
        let middle = arenaSize.height/2
        moveBack(Int(currentPosition.x)/2)
        turnRobotLeft(90)
        if currentPosition.y < middle {
            // bottom
            moveAhead(Int(middle)-Int(currentPosition.y))
        } else {
            // top
            moveBack(Int(currentPosition.y)-Int(middle))
        }
    }
    override func scannedRobot(robot: Robot!, atPosition position: CGPoint) {
        turnToEnemyPosition(position)
        
        lastEnemyHit = currentTimestamp()
        currentRobotState = .Firing
    }
    
    override func gotHit() {
        // unimplemented
    }
    
    override func hitWall(hitDirection: RobotWallHitDirection, hitAngle: CGFloat) {
        // unimplemented
    }
    
    override func bulletHitEnemy(bullet: Bullet!) {
        lastEnemyHit = currentTimestamp()
        if currentRobotState == .Scanning{
            if angRight{
                turnGunLeft(15)
                angle -= 15
            } else {
                turnGunRight(15)
                angle += 15
            }
        }
        currentRobotState = .Firing
    }
    
    func turnToEnemyPosition(position: CGPoint) {
        cancelActiveAction()
        
        // calculate angle between turret and enemey
        let angleBetweenTurretAndEnemy = angleBetweenGunHeadingDirectionAndWorldPosition(position)
        
        // turn if necessary
        if angleBetweenTurretAndEnemy > gunToleranceAngle {
            turnGunRight(Int(abs(angleBetweenTurretAndEnemy)))
        } else if angleBetweenTurretAndEnemy < -gunToleranceAngle {
            turnGunLeft(Int(abs(angleBetweenTurretAndEnemy)))
        }
    }
    
    func shootingScanning(){
        if angle == 0{
            shoot()
        }
        if angle < 180 && angRight {
            turnGunRight(15)
            shoot()
            angle += 15
        } else {
            angRight = false
        }
        if angRight == false {
            turnGunLeft(15)
            shoot()
            angle -= 15
            if angle < 15 {
                angRight = true
            }
        }
    }
    
    func turnToCenter() {
        let arenaSize = arenaDimensions()
        let angle = Int(angleBetweenGunHeadingDirectionAndWorldPosition(CGPoint(x: arenaSize.width/2, y: arenaSize.height/2)))
        if angle < 0 {
            turnGunLeft(abs(angle))
        } else {
            turnGunRight(angle)
        }
    }
    
}

