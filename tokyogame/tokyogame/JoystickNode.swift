//
//  JoystickNode.swift
//  tokyogame
//
//  Created by Antigravity on 10/11/26.
//

import SpriteKit

/// Delegate protocol for receiving joystick input events.
protocol JoystickDelegate: AnyObject {
    func joystickDidUpdate(velocity: CGVector, angle: CGFloat)
    func joystickDidRelease()
}

/// A responsive on-screen virtual analog joystick node for iOS touch controls.
/// Supports both fixed anchoring and adaptive floating positioning within the bottom-left zone.
class JoystickNode: SKNode {
    
    weak var delegate: JoystickDelegate?
    
    // Configuration
    let baseRadius: CGFloat
    let knobRadius: CGFloat
    private let deadZone: CGFloat = 0.06
    
    // Default home position on the HUD
    var homePosition: CGPoint = .zero
    
    // Visual nodes
    private let baseNode: SKShapeNode
    private let outerRingNode: SKShapeNode
    private let knobNode: SKShapeNode
    private let knobCenterDot: SKShapeNode
    private let directionalTicks: [SKShapeNode]
    
    // Touch tracking
    private var trackingTouch: UITouch?
    private(set) var currentVelocity: CGVector = .zero
    private(set) var isTracking: Bool = false
    
    init(baseRadius: CGFloat = 62.0, knobRadius: CGFloat = 28.0) {
        self.baseRadius = baseRadius
        self.knobRadius = knobRadius
        
        // Base background circle (glassmorphism dark translucent with subtle cyan tint)
        self.baseNode = SKShapeNode(circleOfRadius: baseRadius)
        self.baseNode.fillColor = SKColor(red: 0.08, green: 0.12, blue: 0.18, alpha: 0.65)
        self.baseNode.strokeColor = SKColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 0.5)
        self.baseNode.lineWidth = 2.0
        
        // Outer accent ring
        self.outerRingNode = SKShapeNode(circleOfRadius: baseRadius + 6)
        self.outerRingNode.fillColor = .clear
        self.outerRingNode.strokeColor = SKColor(white: 1.0, alpha: 0.2)
        self.outerRingNode.lineWidth = 1.0
        
        // Directional tick marks (N, S, E, W)
        var ticks: [SKShapeNode] = []
        let tickDist = baseRadius - 8
        for i in 0..<4 {
            let angle = CGFloat(i) * (.pi / 2)
            let tick = SKShapeNode(circleOfRadius: 2.5)
            tick.fillColor = SKColor(white: 1.0, alpha: 0.6)
            tick.strokeColor = .clear
            tick.position = CGPoint(x: cos(angle) * tickDist, y: sin(angle) * tickDist)
            ticks.append(tick)
        }
        self.directionalTicks = ticks
        
        // Knob handle
        self.knobNode = SKShapeNode(circleOfRadius: knobRadius)
        self.knobNode.fillColor = SKColor(red: 0.16, green: 0.24, blue: 0.38, alpha: 0.9)
        self.knobNode.strokeColor = SKColor(red: 0.3, green: 0.85, blue: 1.0, alpha: 0.95)
        self.knobNode.lineWidth = 2.5
        
        self.knobCenterDot = SKShapeNode(circleOfRadius: 6.0)
        self.knobCenterDot.fillColor = SKColor(red: 0.3, green: 0.9, blue: 1.0, alpha: 1.0)
        self.knobCenterDot.strokeColor = .clear
        
        super.init()
        
        self.isUserInteractionEnabled = false
        self.zPosition = 1000
        
        addChild(baseNode)
        addChild(outerRingNode)
        for tick in ticks {
            addChild(tick)
        }
        knobNode.addChild(knobCenterDot)
        addChild(knobNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Touch Tracking
    
    func containsTouch(at point: CGPoint) -> Bool {
        let dist = hypot(point.x - position.x, point.y - position.y)
        return dist <= baseRadius * 1.6
    }
    
    func beginTracking(touch: UITouch, touchLocationInParent: CGPoint) {
        guard trackingTouch == nil else { return }
        trackingTouch = touch
        isTracking = true
        
        // If touch is far from home position, adaptively place joystick under thumb
        let distFromHome = hypot(touchLocationInParent.x - homePosition.x, touchLocationInParent.y - homePosition.y)
        if distFromHome > baseRadius * 1.2 {
            self.position = touchLocationInParent
        }
        
        // Highlight active state
        baseNode.strokeColor = SKColor(red: 0.3, green: 0.9, blue: 1.0, alpha: 0.9)
        knobNode.run(SKAction.scale(to: 1.12, duration: 0.08))
        
        updateKnobPosition(with: touch)
    }
    
    func updateTracking(touch: UITouch) {
        guard trackingTouch == touch else { return }
        updateKnobPosition(with: touch)
    }
    
    func endTracking(touch: UITouch) {
        guard trackingTouch == touch else { return }
        resetJoystick()
    }
    
    func cancelTracking() {
        resetJoystick()
    }
    
    private func resetJoystick() {
        trackingTouch = nil
        isTracking = false
        currentVelocity = .zero
        
        // Spring knob back to center
        let returnKnob = SKAction.move(to: .zero, duration: 0.12)
        returnKnob.timingMode = .easeOut
        knobNode.run(returnKnob)
        knobNode.run(SKAction.scale(to: 1.0, duration: 0.12))
        
        // Return joystick base to home position
        let returnBase = SKAction.move(to: homePosition, duration: 0.15)
        returnBase.timingMode = .easeOut
        self.run(returnBase)
        
        baseNode.strokeColor = SKColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 0.5)
        
        delegate?.joystickDidRelease()
    }
    
    private func updateKnobPosition(with touch: UITouch) {
        let touchLocation = touch.location(in: self)
        let distance = hypot(touchLocation.x, touchLocation.y)
        let angle = atan2(touchLocation.y, touchLocation.x)
        
        let clampedDist = min(distance, baseRadius)
        let knobX = cos(angle) * clampedDist
        let knobY = sin(angle) * clampedDist
        
        knobNode.position = CGPoint(x: knobX, y: knobY)
        
        // Normalized velocity calculation
        let normalizedDist = clampedDist / baseRadius
        if normalizedDist < deadZone {
            currentVelocity = .zero
            delegate?.joystickDidUpdate(velocity: .zero, angle: angle)
        } else {
            let remapped = (normalizedDist - deadZone) / (1.0 - deadZone)
            let vx = cos(angle) * remapped
            let vy = sin(angle) * remapped
            currentVelocity = CGVector(dx: vx, dy: vy)
            delegate?.joystickDidUpdate(velocity: currentVelocity, angle: angle)
        }
    }
}
