//
//  PlayerNode.swift
//  tokyogame
//
//  Created by Antigravity on 10/11/26.
//

import SpriteKit

/// Cardinal and diagonal facing directions for top-down gameplay.
enum PlayerDirection {
    case down
    case up
    case left
    case right
    case downLeft
    case downRight
    case upLeft
    case upRight
    
    var isFacingUp: Bool {
        return self == .up || self == .upLeft || self == .upRight
    }
    
    var isFacingDown: Bool {
        return self == .down || self == .downLeft || self == .downRight
    }
    
    var isFacingLeft: Bool {
        return self == .left || self == .downLeft || self == .upLeft
    }
    
    var isFacingRight: Bool {
        return self == .right || self == .downRight || self == .upRight
    }
}

/// The player character node rendered from .imageset sprites (player_down, player_up, player_left, player_right)
/// with 2.5D Pokémon-like styling, walking animations, and physics feet-collision box.
class PlayerNode: SKNode {
    
    // Movement attributes
    var walkSpeed: CGFloat = 190.0 // points per second
    
    private(set) var currentDirection: PlayerDirection = .down
    private(set) var isMoving: Bool = false
    
    // Visual layers
    private let shadowNode: SKShapeNode
    private let characterContainer: SKNode
    private let spriteNode: SKSpriteNode
    
    // Walking animation state
    private var walkCycleTimer: TimeInterval = 0.0
    private var walkStep: Int = 0
    
    // Textures cached from .imageset
    private let downTexture = SKTexture(imageNamed: "player_down")
    private let upTexture = SKTexture(imageNamed: "player_up")
    private let leftTexture = SKTexture(imageNamed: "player_left")
    private let rightTexture = SKTexture(imageNamed: "player_right")
    
    override init() {
        // 1. Soft drop shadow (beneath player feet)
        let shadowPath = CGPath(ellipseIn: CGRect(x: -16, y: -6, width: 32, height: 12), transform: nil)
        self.shadowNode = SKShapeNode(path: shadowPath)
        self.shadowNode.fillColor = SKColor(white: 0.0, alpha: 0.35)
        self.shadowNode.strokeColor = .clear
        self.shadowNode.zPosition = -1.0
        
        // 2. Character container (for walking bob animations)
        self.characterContainer = SKNode()
        
        // 3. Player Sprite from .imageset
        self.spriteNode = SKSpriteNode(texture: downTexture)
        self.spriteNode.size = CGSize(width: 64, height: 64)
        self.spriteNode.anchorPoint = CGPoint(x: 0.5, y: 0.2) // Feet base
        self.spriteNode.zPosition = 1.0
        
        super.init()
        
        addChild(shadowNode)
        characterContainer.addChild(spriteNode)
        addChild(characterContainer)
        
        setupPhysics()
        updateDirectionVisuals(direction: .down)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Physics Setup
    
    private func setupPhysics() {
        // Feet collision circle: crucial for 2.5D Pokémon perspective!
        let feetRadius: CGFloat = 14.0
        let feetCenter = CGPoint(x: 0, y: 0.0)
        let body = SKPhysicsBody(circleOfRadius: feetRadius, center: feetCenter)
        body.isDynamic = true
        body.allowsRotation = false
        body.affectedByGravity = false
        body.friction = 0.0
        body.restitution = 0.0
        body.categoryBitMask = PhysicsCategory.player
        body.collisionBitMask = PhysicsCategory.obstacle | PhysicsCategory.building | PhysicsCategory.worldBoundary | PhysicsCategory.vehicle
        body.contactTestBitMask = PhysicsCategory.obstacle
        self.physicsBody = body
    }
    
    // MARK: - Movement & Direction
    
    func move(velocity: CGVector, deltaTime: TimeInterval) {
        guard let pBody = self.physicsBody else { return }
        
        let speed = walkSpeed
        
        if velocity.dx == 0 && velocity.dy == 0 {
            pBody.velocity = .zero
            if isMoving {
                stopWalkingAnimation()
            }
            return
        }
        
        // Apply physics velocity
        let targetVx = velocity.dx * speed
        let targetVy = velocity.dy * speed
        pBody.velocity = CGVector(dx: targetVx, dy: targetVy)
        
        // Determine 8-way direction
        let angle = atan2(velocity.dy, velocity.dx)
        let newDir = directionFrom(angle: angle)
        if newDir != currentDirection {
            currentDirection = newDir
            updateDirectionVisuals(direction: newDir)
        }
        
        // Update walk bob animation
        updateWalkCycle(deltaTime: deltaTime)
    }
    
    func stopMovement() {
        physicsBody?.velocity = .zero
        stopWalkingAnimation()
    }
    
    private func directionFrom(angle: CGFloat) -> PlayerDirection {
        var normalized = angle
        if normalized < 0 {
            normalized += 2 * .pi
        }
        let deg = normalized * (180.0 / .pi)
        
        if deg >= 337.5 || deg < 22.5 {
            return .right
        } else if deg >= 22.5 && deg < 67.5 {
            return .upRight
        } else if deg >= 67.5 && deg < 112.5 {
            return .up
        } else if deg >= 112.5 && deg < 157.5 {
            return .upLeft
        } else if deg >= 157.5 && deg < 202.5 {
            return .left
        } else if deg >= 202.5 && deg < 247.5 {
            return .downLeft
        } else if deg >= 247.5 && deg < 292.5 {
            return .down
        } else {
            return .downRight
        }
    }
    
    private func updateDirectionVisuals(direction: PlayerDirection) {
        switch direction {
        case .down, .downLeft, .downRight:
            spriteNode.texture = downTexture
            spriteNode.xScale = (direction == .downLeft) ? -1.0 : 1.0
        case .up, .upLeft, .upRight:
            spriteNode.texture = upTexture
            spriteNode.xScale = (direction == .upLeft) ? -1.0 : 1.0
        case .left:
            spriteNode.texture = leftTexture
            spriteNode.xScale = 1.0
        case .right:
            spriteNode.texture = rightTexture
            spriteNode.xScale = 1.0
        }
    }
    
    // MARK: - Walk Cycle Animation
    
    private func updateWalkCycle(deltaTime: TimeInterval) {
        isMoving = true
        walkCycleTimer += deltaTime
        
        let cycleInterval: TimeInterval = 0.14
        if walkCycleTimer >= cycleInterval {
            walkCycleTimer = 0.0
            walkStep = (walkStep + 1) % 4
            
            // Subtle chibi bobbing & tilt
            switch walkStep {
            case 0:
                characterContainer.position.y = 2.0
                characterContainer.zRotation = 0.04
            case 1:
                characterContainer.position.y = 0.0
                characterContainer.zRotation = 0.0
            case 2:
                characterContainer.position.y = 2.0
                characterContainer.zRotation = -0.04
            case 3:
                characterContainer.position.y = 0.0
                characterContainer.zRotation = 0.0
            default:
                break
            }
        }
    }
    
    private func stopWalkingAnimation() {
        isMoving = false
        walkCycleTimer = 0.0
        walkStep = 0
        characterContainer.position.y = 0.0
        characterContainer.zRotation = 0.0
    }
}
