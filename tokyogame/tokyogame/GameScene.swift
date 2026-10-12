//
//  GameScene.swift
//  tokyogame
//
//  Created by Austin Gao on 10/11/26.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, JoystickDelegate, GameMenuDelegate, SKPhysicsContactDelegate {
    
    // Save slot and spawn location configuration
    var activeSlotId: Int = 1
    var initialPlayerPosition: CGPoint = CGPoint(x: -1250, y: -450)
    
    // Core game components
    private var worldNode: TokyoWorldNode!
    private var player: PlayerNode!
    private var cameraNode: SKCameraNode!
    private var hudNode: GameHUDNode!
    
    // Game pause state
    private var isGamePaused: Bool = false
    
    // Joystick tracking
    private var joystickVelocity: CGVector = .zero
    private var activeJoystickTouch: UITouch?
    
    // Frame timing
    private var lastUpdateTime: TimeInterval = 0.0
    
    // Camera damping / lerp speed
    private let cameraLerpFactor: CGFloat = 0.12
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.15, green: 0.16, blue: 0.18, alpha: 1.0)
        
        // Setup 2D physics world
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        // 1. Build Tokyo City 2.5D World (Expanded 11-District Open World)
        worldNode = TokyoWorldNode(mapSize: CGSize(width: 3800, height: 3400))
        addChild(worldNode)
        
        // 2. Spawn Player at configured position
        player = PlayerNode()
        player.position = initialPlayerPosition
        worldNode.addPlayerToWorld(player)
        
        // 3. Setup Camera & Viewport
        cameraNode = SKCameraNode()
        camera = cameraNode
        addChild(cameraNode)
        cameraNode.position = player.position
        
        // 4. Attach HUD directly to Camera
        hudNode = GameHUDNode(viewSize: size)
        hudNode.activeSlotId = activeSlotId
        hudNode.joystick.delegate = self
        hudNode.menuDelegate = self
        cameraNode.addChild(hudNode)
        
        // Initial depth sort
        worldNode.updateDepthSorting()
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        hudNode?.layoutForSize(size)
    }
    
    // Keyboard input state (for iOS Simulator / Mac testing)
    private var pressedKeyDirections: Set<String> = []
    private var keyboardVelocity: CGVector = .zero
    
    // MARK: - Game Loop Update
    
    override func update(_ currentTime: TimeInterval) {
        guard !isGamePaused else { return }
        
        // Compute delta time
        if lastUpdateTime == 0.0 {
            lastUpdateTime = currentTime
        }
        let dt = min(currentTime - lastUpdateTime, 0.1) // clamp against frame spikes
        lastUpdateTime = currentTime
        
        // 1. Determine effective velocity (touch joystick takes priority over keyboard)
        let effectiveVelocity = (joystickVelocity != .zero) ? joystickVelocity : keyboardVelocity
        
        // 2. Update Player Movement
        player.move(velocity: effectiveVelocity, deltaTime: dt)
        
        // 3. Update Moving Tokyo Vehicles
        worldNode.updateVehicles(dt: dt)
    }
    
    override func didSimulatePhysics() {
        super.didSimulatePhysics()
        guard !isGamePaused else { return }
        
        // 4. Dynamic 2.5D Depth Sorting (Pokémon style)
        worldNode.updateDepthSorting()
        
        // 5. Smooth Camera Following with Boundary Clamping
        updateCamera()
        
        // 6. Dynamic Tokyo District Detection & HUD Banner
        let currentDistrict = worldNode.district(at: player.position)
        hudNode.updateDistrictBanner(title: currentDistrict.hudTitle)
    }
    
    // MARK: - SKPhysicsContactDelegate
    
    func didBegin(_ contact: SKPhysicsContact) {
        // Collectible items have been removed in favor of dense physical Tokyo scenery.
    }

    
    // MARK: - Joystick Delegate
    
    func joystickDidUpdate(velocity: CGVector, angle: CGFloat) {
        guard !isGamePaused else { return }
        self.joystickVelocity = velocity
    }
    
    func joystickDidRelease() {
        self.joystickVelocity = .zero
    }
    
    // MARK: - Game Menu & Save Delegate
    
    func hudDidRequestSave() {
        let currentDistrict = worldNode.district(at: player.position)
        let success = SaveDataManager.shared.saveGame(
            slotId: activeSlotId,
            playerPosition: player.position,
            districtName: currentDistrict.saveName
        )
        if success {
            hudNode.showSaveConfirmation(message: "SAVED TO SLOT \(activeSlotId)! [\(currentDistrict.name)] (X: \(Int(player.position.x)), Y: \(Int(player.position.y)))")
        }
    }
    
    func hudDidRequestLoadSlot(slotId: Int) {
        activeSlotId = slotId
        hudNode.activeSlotId = slotId
        
        if let save = SaveDataManager.shared.loadGame(slotId: slotId) {
            player.position = save.playerPosition
            cameraNode.position = save.playerPosition
            worldNode.updateDepthSorting()
            hudNode.showSaveConfirmation(message: "LOADED SLOT \(slotId)! (X: \(Int(save.playerX)), Y: \(Int(save.playerY)))")
        } else {
            hudNode.showSaveConfirmation(message: "SLOT \(slotId) IS EMPTY. TAP SAVE TO STORE POSITION.")
        }
    }
    
    func hudDidRequestExitToMainMenu() {
        guard let view = self.view else { return }
        let titleScene = MainMenuScene(size: view.bounds.size)
        titleScene.scaleMode = .resizeFill
        let transition = SKTransition.fade(withDuration: 0.4)
        view.presentScene(titleScene, transition: transition)
    }
    
    func hudDidTogglePause(isPaused: Bool) {
        self.isGamePaused = isPaused
        if isPaused {
            player.stopMovement()
            joystickVelocity = .zero
        }
    }
    
    // MARK: - Multi-Touch Input Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchInCam = touch.location(in: cameraNode)
            
            // Check if touch hits HUD menu or modal buttons first
            if hudNode.handleTouchBegan(at: touchInCam, in: self) {
                continue
            }
            
            guard !isGamePaused else { continue }
            
            // Check if touch is in bottom-left zone for joystick control
            let isBottomLeftZone = touchInCam.x < 0 && touchInCam.y < 0
            if (hudNode.joystick.containsTouch(at: touchInCam) || isBottomLeftZone) && activeJoystickTouch == nil {
                activeJoystickTouch = touch
                hudNode.joystick.beginTracking(touch: touch, touchLocationInParent: touchInCam)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isGamePaused else { return }
        for touch in touches {
            if touch == activeJoystickTouch {
                hudNode.joystick.updateTracking(touch: touch)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch == activeJoystickTouch {
                hudNode.joystick.endTracking(touch: touch)
                activeJoystickTouch = nil
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch == activeJoystickTouch {
                hudNode.joystick.cancelTracking()
                activeJoystickTouch = nil
            }
        }
    }
    
    // MARK: - Keyboard Input (Simulator Support)
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for press in presses {
            if let key = press.key {
                let char = key.charactersIgnoringModifiers.lowercased()
                pressedKeyDirections.insert(char)
            }
        }
        updateKeyboardVelocity()
    }
    
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for press in presses {
            if let key = press.key {
                let char = key.charactersIgnoringModifiers.lowercased()
                pressedKeyDirections.remove(char)
            }
        }
        updateKeyboardVelocity()
    }
    
    override func pressesCancelled(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        pressedKeyDirections.removeAll()
        updateKeyboardVelocity()
    }
    
    private func updateKeyboardVelocity() {
        var dx: CGFloat = 0.0
        var dy: CGFloat = 0.0
        
        if pressedKeyDirections.contains("w") || pressedKeyDirections.contains(UIKeyCommand.inputUpArrow.lowercased()) {
            dy += 1.0
        }
        if pressedKeyDirections.contains("s") || pressedKeyDirections.contains(UIKeyCommand.inputDownArrow.lowercased()) {
            dy -= 1.0
        }
        if pressedKeyDirections.contains("a") || pressedKeyDirections.contains(UIKeyCommand.inputLeftArrow.lowercased()) {
            dx -= 1.0
        }
        if pressedKeyDirections.contains("d") || pressedKeyDirections.contains(UIKeyCommand.inputRightArrow.lowercased()) {
            dx += 1.0
        }
        
        if dx == 0 && dy == 0 {
            keyboardVelocity = .zero
        } else {
            let len = hypot(dx, dy)
            keyboardVelocity = CGVector(dx: dx / len, dy: dy / len)
        }
    }
    
    // MARK: - Camera Movement
    
    private func updateCamera() {
        guard let cam = cameraNode, let ply = player else { return }
        
        // Smooth linear interpolation (lerp) towards player position
        let targetX = ply.position.x
        let targetY = ply.position.y
        
        let newX = cam.position.x + (targetX - cam.position.x) * cameraLerpFactor
        let newY = cam.position.y + (targetY - cam.position.y) * cameraLerpFactor
        
        // Clamp camera to map boundaries so viewport stays within the city
        let halfViewW = size.width / 2.0
        let halfViewH = size.height / 2.0
        let halfMapW = worldNode.mapSize.width / 2.0
        let halfMapH = worldNode.mapSize.height / 2.0
        
        let minX = -halfMapW + halfViewW
        let maxX = halfMapW - halfViewW
        let minY = -halfMapH + halfViewH
        let maxY = halfMapH - halfViewH
        
        let clampedX = (minX < maxX) ? min(max(newX, minX), maxX) : newX
        let clampedY = (minY < maxY) ? min(max(newY, minY), maxY) : newY
        
        cam.position = CGPoint(x: clampedX, y: clampedY)
    }
}
