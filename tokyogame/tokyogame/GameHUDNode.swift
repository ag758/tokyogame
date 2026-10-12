//
//  GameHUDNode.swift
//  tokyogame
//
//  Created by Antigravity on 10/11/26.
//

import SpriteKit

/// Delegate to handle menu actions from the HUD.
protocol GameMenuDelegate: AnyObject {
    func hudDidRequestSave()
    func hudDidRequestLoadSlot(slotId: Int)
    func hudDidRequestExitToMainMenu()
    func hudDidTogglePause(isPaused: Bool)
}

/// Camera-attached HUD containing the bottom-left virtual joystick,
/// Tokyo district banner, [MENU/SAVE] button, and in-game pause/save modal dialog.
class GameHUDNode: SKNode {
    
    weak var menuDelegate: GameMenuDelegate?
    
    let joystick: JoystickNode
    private let bannerContainer: SKNode
    private let bannerText: SKLabelNode
    private let menuButton: SKShapeNode
    
    // In-game Pause & Save Modal Dialog
    private let pauseModalContainer: SKNode
    private var saveBtn: SKShapeNode!
    private var resumeBtn: SKShapeNode!
    private var exitBtn: SKShapeNode!
    private var slotBtns: [(box: SKShapeNode, slotId: Int)] = []
    private var toastLabel: SKLabelNode!
    
    private(set) var isMenuOpen: Bool = false
    var activeSlotId: Int = 1
    
    init(viewSize: CGSize) {
        self.joystick = JoystickNode(baseRadius: 62.0, knobRadius: 28.0)
        
        // 1. Tokyo District Header Banner (Top Center, below Dynamic Island)
        self.bannerContainer = SKNode()
        let bannerBg = SKShapeNode(rectOf: CGSize(width: 210, height: 32), cornerRadius: 6)
        bannerBg.fillColor = SKColor(white: 0.1, alpha: 0.75)
        bannerBg.strokeColor = SKColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 0.6)
        bannerBg.lineWidth = 1.0
        
        self.bannerText = SKLabelNode(text: "SHIBUYA ・ 渋谷区")
        self.bannerText.fontName = "HelveticaNeue-Bold"
        self.bannerText.fontSize = 11.5
        self.bannerText.fontColor = SKColor(red: 0.95, green: 0.95, blue: 0.98, alpha: 1.0)
        self.bannerText.verticalAlignmentMode = .center
        bannerContainer.addChild(bannerBg)
        bannerContainer.addChild(self.bannerText)
        
        // 2. [ MENU / SAVE ] Button Box in Top-Right
        self.menuButton = SKShapeNode(rectOf: CGSize(width: 82, height: 32), cornerRadius: 6)
        self.menuButton.fillColor = SKColor(red: 0.18, green: 0.22, blue: 0.32, alpha: 0.85)
        self.menuButton.strokeColor = SKColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 0.7)
        self.menuButton.lineWidth = 1.2
        
        let menuLabel = SKLabelNode(text: "[ SAVE ]")
        menuLabel.fontName = "HelveticaNeue-Bold"
        menuLabel.fontSize = 11.5
        menuLabel.fontColor = .white
        menuLabel.verticalAlignmentMode = .center
        self.menuButton.addChild(menuLabel)
        
        // 3. Pause & Save Modal Container
        self.pauseModalContainer = SKNode()
        self.pauseModalContainer.zPosition = 2000
        self.pauseModalContainer.isHidden = true
        
        super.init()
        
        self.zPosition = 1000
        
        addChild(joystick)
        addChild(bannerContainer)
        addChild(menuButton)
        addChild(pauseModalContainer)
        
        buildPauseModal(size: viewSize)
        layoutForSize(viewSize)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - In-Game Pause / Save Modal Dialog
    
    private func buildPauseModal(size: CGSize) {
        pauseModalContainer.removeAllChildren()
        slotBtns.removeAll()
        
        // Dimmed backdrop
        let dimBg = SKShapeNode(rectOf: CGSize(width: size.width * 2, height: size.height * 2))
        dimBg.fillColor = SKColor(white: 0.0, alpha: 0.65)
        dimBg.strokeColor = .clear
        pauseModalContainer.addChild(dimBg)
        
        let modalW: CGFloat = min(size.width - 40, 310)
        let modalH: CGFloat = 340.0
        
        let card = SKShapeNode(rectOf: CGSize(width: modalW, height: modalH), cornerRadius: 10)
        card.fillColor = SKColor(red: 0.12, green: 0.15, blue: 0.20, alpha: 0.98)
        card.strokeColor = SKColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 0.85)
        card.lineWidth = 2.0
        pauseModalContainer.addChild(card)
        
        // Modal Header
        let headerLabel = SKLabelNode(text: "[ GAME MENU & SAVE ]")
        headerLabel.fontName = "HelveticaNeue-Bold"
        headerLabel.fontSize = 15.0
        headerLabel.fontColor = .white
        headerLabel.position = CGPoint(x: 0, y: modalH / 2.0 - 28)
        card.addChild(headerLabel)
        
        let subLabel = SKLabelNode(text: "CURRENT ACTIVE SLOT: [ SLOT \(activeSlotId) ]")
        subLabel.fontName = "HelveticaNeue-Medium"
        subLabel.fontSize = 11.0
        subLabel.fontColor = SKColor(red: 0.35, green: 0.85, blue: 1.0, alpha: 1.0)
        subLabel.position = CGPoint(x: 0, y: modalH / 2.0 - 48)
        card.addChild(subLabel)
        
        // Save Slot Buttons (Slots 1, 2, 3)
        let btnW: CGFloat = modalW - 40
        let slotH: CGFloat = 42.0
        let allSlots = SaveDataManager.shared.getAllSlots()
        
        for i in 1...3 {
            let y = modalH / 2.0 - 78.0 - CGFloat(i - 1) * 48.0
            let slotBox = SKShapeNode(rectOf: CGSize(width: btnW, height: slotH), cornerRadius: 6)
            slotBox.fillColor = (i == activeSlotId) ?
                SKColor(red: 0.16, green: 0.30, blue: 0.45, alpha: 0.9) :
                SKColor(red: 0.14, green: 0.18, blue: 0.24, alpha: 0.8)
            slotBox.strokeColor = (i == activeSlotId) ?
                SKColor(red: 0.3, green: 0.85, blue: 1.0, alpha: 0.9) :
                SKColor(white: 0.4, alpha: 0.6)
            slotBox.lineWidth = (i == activeSlotId) ? 1.5 : 1.0
            slotBox.position = CGPoint(x: 0, y: y)
            
            let slotData = allSlots[i - 1]
            let desc = (slotData != nil) ?
                "[ SLOT \(i) ] (X: \(Int(slotData!.playerX)), Y: \(Int(slotData!.playerY)))" :
                "[ SLOT \(i) ] - EMPTY -"
            
            let label = SKLabelNode(text: desc)
            label.fontName = "HelveticaNeue-Bold"
            label.fontSize = 11.5
            label.fontColor = (i == activeSlotId) ? .white : SKColor(white: 0.85, alpha: 1.0)
            label.verticalAlignmentMode = .center
            slotBox.addChild(label)
            
            card.addChild(slotBox)
            slotBtns.append((box: slotBox, slotId: i))
        }
        
        // 1. [ SAVE CURRENT POSITION ] Button
        saveBtn = SKShapeNode(rectOf: CGSize(width: btnW, height: 38), cornerRadius: 6)
        saveBtn.fillColor = SKColor(red: 0.18, green: 0.68, blue: 0.38, alpha: 0.9) // Green
        saveBtn.strokeColor = SKColor(white: 1.0, alpha: 0.8)
        saveBtn.lineWidth = 1.2
        saveBtn.position = CGPoint(x: 0, y: -modalH / 2.0 + 105)
        
        let saveLabel = SKLabelNode(text: "[ SAVE POSITION TO ACTIVE SLOT ]")
        saveLabel.fontName = "HelveticaNeue-Bold"
        saveLabel.fontSize = 12.0
        saveLabel.fontColor = .white
        saveLabel.verticalAlignmentMode = .center
        saveBtn.addChild(saveLabel)
        card.addChild(saveBtn)
        
        // 2. [ RESUME ] Button
        resumeBtn = SKShapeNode(rectOf: CGSize(width: btnW / 2.0 - 5, height: 36), cornerRadius: 6)
        resumeBtn.fillColor = SKColor(red: 0.20, green: 0.25, blue: 0.35, alpha: 0.9)
        resumeBtn.strokeColor = SKColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 0.7)
        resumeBtn.lineWidth = 1.0
        resumeBtn.position = CGPoint(x: -btnW / 4.0 - 2, y: -modalH / 2.0 + 58)
        
        let resumeLabel = SKLabelNode(text: "[ RESUME ]")
        resumeLabel.fontName = "HelveticaNeue-Bold"
        resumeLabel.fontSize = 12.0
        resumeLabel.fontColor = .white
        resumeLabel.verticalAlignmentMode = .center
        resumeBtn.addChild(resumeLabel)
        card.addChild(resumeBtn)
        
        // 3. [ TITLE / QUIT ] Button
        exitBtn = SKShapeNode(rectOf: CGSize(width: btnW / 2.0 - 5, height: 36), cornerRadius: 6)
        exitBtn.fillColor = SKColor(red: 0.32, green: 0.15, blue: 0.18, alpha: 0.9) // Deep red
        exitBtn.strokeColor = SKColor(red: 0.9, green: 0.3, blue: 0.4, alpha: 0.8)
        exitBtn.lineWidth = 1.0
        exitBtn.position = CGPoint(x: btnW / 4.0 + 2, y: -modalH / 2.0 + 58)
        
        let exitLabel = SKLabelNode(text: "[ TITLE MENU ]")
        exitLabel.fontName = "HelveticaNeue-Bold"
        exitLabel.fontSize = 11.5
        exitLabel.fontColor = .white
        exitLabel.verticalAlignmentMode = .center
        exitBtn.addChild(exitLabel)
        card.addChild(exitBtn)
        
        // Toast message banner
        toastLabel = SKLabelNode(text: "")
        toastLabel.fontName = "HelveticaNeue-Bold"
        toastLabel.fontSize = 11.0
        toastLabel.fontColor = SKColor(red: 0.3, green: 0.9, blue: 0.5, alpha: 1.0)
        toastLabel.position = CGPoint(x: 0, y: -modalH / 2.0 + 16)
        card.addChild(toastLabel)
    }
    
    /// Repositions HUD elements when view dimensions or safe areas change.
    func layoutForSize(_ size: CGSize) {
        let halfW = size.width / 2.0
        let halfH = size.height / 2.0
        
        // Safe margins
        let bottomSafeMargin: CGFloat = 110.0
        let sideSafeMargin: CGFloat = 88.0
        let topSafeMargin: CGFloat = 72.0
        
        // Joystick in bottom-left corner
        let joyPos = CGPoint(x: -halfW + sideSafeMargin, y: -halfH + bottomSafeMargin)
        joystick.position = joyPos
        joystick.homePosition = joyPos
        
        // Banner at top center
        bannerContainer.position = CGPoint(x: -25, y: halfH - topSafeMargin)
        
        // Save / Menu button at top right
        menuButton.position = CGPoint(x: halfW - 55, y: halfH - topSafeMargin)
    }
    
    // MARK: - Menu Modal Controls
    
    func openMenu(currentSize: CGSize) {
        isMenuOpen = true
        buildPauseModal(size: currentSize)
        pauseModalContainer.isHidden = false
        menuDelegate?.hudDidTogglePause(isPaused: true)
    }
    
    func closeMenu() {
        isMenuOpen = false
        pauseModalContainer.isHidden = true
        menuDelegate?.hudDidTogglePause(isPaused: false)
    }
    
    func showSaveConfirmation(message: String) {
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.run(SKAction.sequence([
            SKAction.wait(forDuration: 2.0),
            SKAction.fadeOut(withDuration: 0.5)
        ]))
    }
    
    func updateDistrictBanner(title: String) {
        guard bannerText.text != title else { return }
        bannerText.text = title
        bannerContainer.removeAllActions()
        let popUp = SKAction.scale(to: 1.08, duration: 0.12)
        let popDown = SKAction.scale(to: 1.0, duration: 0.12)
        bannerContainer.run(SKAction.sequence([popUp, popDown]))
    }
    
    // MARK: - Touch Interaction
    
    func handleTouchBegan(at location: CGPoint, in scene: SKScene) -> Bool {
        if isMenuOpen {
            let locInModal = pauseModalContainer.convert(location, from: self)
            
            // Check Save Button
            if saveBtn.contains(locInModal) {
                menuDelegate?.hudDidRequestSave()
                return true
            }
            
            // Check Resume Button
            if resumeBtn.contains(locInModal) {
                closeMenu()
                return true
            }
            
            // Check Exit Button
            if exitBtn.contains(locInModal) {
                menuDelegate?.hudDidRequestExitToMainMenu()
                return true
            }
            
            // Check Slot Selection
            for slot in slotBtns {
                if slot.box.contains(locInModal) {
                    activeSlotId = slot.slotId
                    menuDelegate?.hudDidRequestLoadSlot(slotId: slot.slotId)
                    return true
                }
            }
            return true // Consume all touches while modal is open
        }
        
        // Check Menu Button in top right
        let locInHUD = location
        if hypot(locInHUD.x - menuButton.position.x, locInHUD.y - menuButton.position.y) <= 45.0 {
            openMenu(currentSize: scene.size)
            return true
        }
        
        return false
    }
}
