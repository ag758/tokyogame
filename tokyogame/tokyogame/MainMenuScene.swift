//
//  MainMenuScene.swift
//  tokyogame
//
//  Created by Antigravity on 10/11/26.
//

import SpriteKit

/// Main entry menu screen featuring Tokyo anime styling,
/// New Game, Load Game, and multi-slot save selection.
class MainMenuScene: SKScene {
    
    private enum MenuState {
        case titleScreen
        case slotSelection(mode: SlotMode)
    }
    
    enum SlotMode {
        case newGame
        case loadGame
    }
    
    private var currentState: MenuState = .titleScreen
    
    // UI Containers
    private let titleContainer = SKNode()
    private let slotsContainer = SKNode()
    
    // Buttons (stored for touch hit-testing)
    private var newGameBtn: SKShapeNode!
    private var loadGameBtn: SKShapeNode!
    private var backBtn: SKShapeNode!
    private var slotCards: [(box: SKShapeNode, slotId: Int)] = []
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.10, green: 0.12, blue: 0.16, alpha: 1.0)
        
        setupAtmosphericBackground()
        
        if titleContainer.parent == nil {
            addChild(titleContainer)
        }
        if slotsContainer.parent == nil {
            addChild(slotsContainer)
        }
        
        // Ensure at least one saved slot for demonstration
        if !SaveDataManager.shared.hasAnySave {
            _ = SaveDataManager.shared.saveGame(
                slotId: 1,
                playerPosition: CGPoint(x: -1250, y: -450),
                districtName: "Shibuya Crossing"
            )
        }
        
        setupTitleScreen()
        showState(.titleScreen)
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        relayoutUI()
    }
    
    // MARK: - Atmospheric Background (Falling Sakura Petals)
    
    private func setupAtmosphericBackground() {
        // Grid lines for Tokyo blueprint vibe
        let gridStep: CGFloat = 40.0
        let cols = Int(size.width / gridStep) + 2
        let rows = Int(size.height / gridStep) + 2
        
        for c in 0..<cols {
            let x = CGFloat(c) * gridStep
            let line = SKShapeNode(rectOf: CGSize(width: 1, height: size.height * 2))
            line.fillColor = SKColor(white: 1.0, alpha: 0.04)
            line.strokeColor = .clear
            line.position = CGPoint(x: x, y: size.height / 2.0)
            line.zPosition = -10
            addChild(line)
        }
        for r in 0..<rows {
            let y = CGFloat(r) * gridStep
            let line = SKShapeNode(rectOf: CGSize(width: size.width * 2, height: 1))
            line.fillColor = SKColor(white: 1.0, alpha: 0.04)
            line.strokeColor = .clear
            line.position = CGPoint(x: size.width / 2.0, y: y)
            line.zPosition = -10
            addChild(line)
        }
        
        // Sakura petal drift
        let spawnAction = SKAction.run { [weak self] in
            guard let self = self else { return }
            let petal = SKShapeNode(ellipseOf: CGSize(width: 7, height: 5))
            petal.fillColor = SKColor(red: 1.0, green: 0.75, blue: 0.85, alpha: 0.75)
            petal.strokeColor = .clear
            petal.position = CGPoint(x: CGFloat.random(in: 0...self.size.width), y: self.size.height + 20)
            petal.zPosition = -5
            self.addChild(petal)
            
            let travelTime = Double.random(in: 4.0...6.5)
            let move = SKAction.moveBy(x: CGFloat.random(in: -100...(-40)), y: -(self.size.height + 50), duration: travelTime)
            let rotate = SKAction.rotate(byAngle: CGFloat.pi * 3, duration: travelTime)
            let fade = SKAction.fadeOut(withDuration: 1.0)
            
            petal.run(SKAction.group([move, rotate, SKAction.sequence([SKAction.wait(forDuration: travelTime - 1.0), fade])])) {
                petal.removeFromParent()
            }
        }
        run(SKAction.repeatForever(SKAction.sequence([spawnAction, SKAction.wait(forDuration: 0.35)])))
    }
    
    // MARK: - Title Screen Setup
    
    private func setupTitleScreen() {
        titleContainer.removeAllChildren()
        
        let cx = size.width / 2.0
        let cy = size.height / 2.0
        
        // 1. Logo Card Box
        let logoBox = SKShapeNode(rectOf: CGSize(width: min(size.width - 60, 320), height: 110), cornerRadius: 10)
        logoBox.fillColor = SKColor(red: 0.14, green: 0.17, blue: 0.24, alpha: 0.9)
        logoBox.strokeColor = SKColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 0.8)
        logoBox.lineWidth = 2.0
        logoBox.position = CGPoint(x: cx, y: cy + 130)
        titleContainer.addChild(logoBox)
        
        let mainTitle = SKLabelNode(text: "[ TOKYO GAME ]")
        mainTitle.fontName = "HelveticaNeue-Bold"
        mainTitle.fontSize = 24.0
        mainTitle.fontColor = .white
        mainTitle.verticalAlignmentMode = .center
        mainTitle.position = CGPoint(x: 0, y: 16)
        logoBox.addChild(mainTitle)
        
        let subTitle = SKLabelNode(text: "2.5D TOP-DOWN RPG ・ 東京")
        subTitle.fontName = "HelveticaNeue-Medium"
        subTitle.fontSize = 13.0
        subTitle.fontColor = SKColor(red: 0.4, green: 0.85, blue: 1.0, alpha: 0.9)
        subTitle.verticalAlignmentMode = .center
        subTitle.position = CGPoint(x: 0, y: -18)
        logoBox.addChild(subTitle)
        
        // 2. [ NEW GAME ] Button Box
        let btnW: CGFloat = min(size.width - 80, 260)
        let btnH: CGFloat = 52.0
        
        newGameBtn = SKShapeNode(rectOf: CGSize(width: btnW, height: btnH), cornerRadius: 8)
        newGameBtn.fillColor = SKColor(red: 0.18, green: 0.65, blue: 0.95, alpha: 0.9) // Bright Blue
        newGameBtn.strokeColor = SKColor(white: 1.0, alpha: 0.8)
        newGameBtn.lineWidth = 1.5
        newGameBtn.position = CGPoint(x: cx, y: cy - 20)
        
        let newGameLabel = SKLabelNode(text: "[ NEW GAME ]")
        newGameLabel.fontName = "HelveticaNeue-Bold"
        newGameLabel.fontSize = 16.0
        newGameLabel.fontColor = .white
        newGameLabel.verticalAlignmentMode = .center
        newGameBtn.addChild(newGameLabel)
        titleContainer.addChild(newGameBtn)
        
        // 3. [ LOAD GAME ] Button Box
        loadGameBtn = SKShapeNode(rectOf: CGSize(width: btnW, height: btnH), cornerRadius: 8)
        loadGameBtn.fillColor = SKColor(red: 0.16, green: 0.22, blue: 0.32, alpha: 0.9)
        loadGameBtn.strokeColor = SKColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 0.6)
        loadGameBtn.lineWidth = 1.5
        loadGameBtn.position = CGPoint(x: cx, y: cy - 90)
        
        let loadGameLabel = SKLabelNode(text: "[ LOAD GAME ]")
        loadGameLabel.fontName = "HelveticaNeue-Bold"
        loadGameLabel.fontSize = 16.0
        loadGameLabel.fontColor = SKColor(white: 0.95, alpha: 1.0)
        loadGameLabel.verticalAlignmentMode = .center
        loadGameBtn.addChild(loadGameLabel)
        titleContainer.addChild(loadGameBtn)
    }
    
    // MARK: - Save Slots Screen Setup
    
    private func setupSlotsScreen() {
        slotsContainer.isHidden = true
    }
    
    private func refreshSlotCards(mode: SlotMode) {
        slotsContainer.removeAllChildren()
        slotCards.removeAll()
        
        let cx = size.width / 2.0
        let cy = size.height / 2.0
        
        // Header Box
        let headerBox = SKShapeNode(rectOf: CGSize(width: min(size.width - 60, 300), height: 44), cornerRadius: 8)
        headerBox.fillColor = SKColor(red: 0.15, green: 0.18, blue: 0.26, alpha: 0.9)
        headerBox.strokeColor = SKColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 0.6)
        headerBox.lineWidth = 1.5
        headerBox.position = CGPoint(x: cx, y: cy + 190)
        slotsContainer.addChild(headerBox)
        
        let headerTitle = (mode == .newGame) ? "SELECT SAVE SLOT FOR NEW GAME" : "CHOOSE SAVE SLOT TO LOAD"
        let headerLabel = SKLabelNode(text: headerTitle)
        headerLabel.fontName = "HelveticaNeue-Bold"
        headerLabel.fontSize = 12.0
        headerLabel.fontColor = SKColor(red: 0.4, green: 0.85, blue: 1.0, alpha: 1.0)
        headerLabel.verticalAlignmentMode = .center
        headerBox.addChild(headerLabel)
        
        // Build 3 slot cards
        let allSlots = SaveDataManager.shared.getAllSlots()
        let cardW: CGFloat = min(size.width - 60, 310)
        let cardH: CGFloat = 84.0
        let startY = cy + 90.0
        let gap: CGFloat = 98.0
        
        for i in 1...3 {
            let slotData = allSlots[i - 1]
            let y = startY - CGFloat(i - 1) * gap
            
            let cardBox = SKShapeNode(rectOf: CGSize(width: cardW, height: cardH), cornerRadius: 8)
            cardBox.fillColor = (slotData != nil) ?
                SKColor(red: 0.16, green: 0.22, blue: 0.32, alpha: 0.95) :
                SKColor(red: 0.12, green: 0.14, blue: 0.18, alpha: 0.8)
            
            cardBox.strokeColor = (slotData != nil) ?
                SKColor(red: 0.25, green: 0.75, blue: 1.0, alpha: 0.8) :
                SKColor(white: 0.4, alpha: 0.5)
            cardBox.lineWidth = 1.5
            cardBox.position = CGPoint(x: cx, y: y)
            
            // Slot Tag Label
            let tagText = "[ SAVE SLOT \(i) ]"
            let tagLabel = SKLabelNode(text: tagText)
            tagLabel.fontName = "HelveticaNeue-Bold"
            tagLabel.fontSize = 14.0
            tagLabel.fontColor = .white
            tagLabel.horizontalAlignmentMode = .left
            tagLabel.position = CGPoint(x: -cardW / 2.0 + 16, y: 16)
            cardBox.addChild(tagLabel)
            
            if let data = slotData {
                // Details
                let locLabel = SKLabelNode(text: "Location: \(data.districtName) (X: \(Int(data.playerX)), Y: \(Int(data.playerY)))")
                locLabel.fontName = "HelveticaNeue-Medium"
                locLabel.fontSize = 11.5
                locLabel.fontColor = SKColor(red: 0.35, green: 0.85, blue: 0.55, alpha: 1.0)
                locLabel.horizontalAlignmentMode = .left
                locLabel.position = CGPoint(x: -cardW / 2.0 + 16, y: -4)
                cardBox.addChild(locLabel)
                
                let dateLabel = SKLabelNode(text: "Saved: \(data.formattedDate)")
                dateLabel.fontName = "HelveticaNeue"
                dateLabel.fontSize = 10.5
                dateLabel.fontColor = SKColor(white: 0.7, alpha: 0.9)
                dateLabel.horizontalAlignmentMode = .left
                dateLabel.position = CGPoint(x: -cardW / 2.0 + 16, y: -24)
                cardBox.addChild(dateLabel)
            } else {
                let emptyLabel = SKLabelNode(text: "- EMPTY SLOT (TAP TO START) -")
                emptyLabel.fontName = "HelveticaNeue-Medium"
                emptyLabel.fontSize = 12.0
                emptyLabel.fontColor = SKColor(white: 0.5, alpha: 0.8)
                emptyLabel.horizontalAlignmentMode = .left
                emptyLabel.position = CGPoint(x: -cardW / 2.0 + 16, y: -12)
                cardBox.addChild(emptyLabel)
            }
            
            slotsContainer.addChild(cardBox)
            slotCards.append((box: cardBox, slotId: i))
        }
        
        // Back Button
        backBtn = SKShapeNode(rectOf: CGSize(width: min(size.width - 80, 220), height: 44), cornerRadius: 8)
        backBtn.fillColor = SKColor(red: 0.28, green: 0.16, blue: 0.20, alpha: 0.85)
        backBtn.strokeColor = SKColor(red: 0.9, green: 0.3, blue: 0.4, alpha: 0.7)
        backBtn.lineWidth = 1.5
        backBtn.position = CGPoint(x: cx, y: cy - 220)
        
        let backLabel = SKLabelNode(text: "[ BACK TO MENU ]")
        backLabel.fontName = "HelveticaNeue-Bold"
        backLabel.fontSize = 13.0
        backLabel.fontColor = .white
        backLabel.verticalAlignmentMode = .center
        backBtn.addChild(backLabel)
        slotsContainer.addChild(backBtn)
    }
    
    private func relayoutUI() {
        titleContainer.removeAllChildren()
        setupTitleScreen()
        if case .slotSelection(let mode) = currentState {
            refreshSlotCards(mode: mode)
        }
    }
    
    private func showState(_ state: MenuState) {
        currentState = state
        switch state {
        case .titleScreen:
            titleContainer.isHidden = false
            slotsContainer.isHidden = true
        case .slotSelection(let mode):
            titleContainer.isHidden = true
            slotsContainer.isHidden = false
            refreshSlotCards(mode: mode)
        }
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)
        
        switch currentState {
        case .titleScreen:
            if newGameBtn.contains(touch.location(in: titleContainer)) {
                animateButton(newGameBtn) {
                    self.showState(.slotSelection(mode: .newGame))
                }
            } else if loadGameBtn.contains(touch.location(in: titleContainer)) {
                animateButton(loadGameBtn) {
                    self.showState(.slotSelection(mode: .loadGame))
                }
            }
            
        case .slotSelection(let mode):
            if let back = backBtn, back.contains(touch.location(in: slotsContainer)) {
                animateButton(back) {
                    self.showState(.titleScreen)
                }
                return
            }
            
            for card in slotCards {
                if card.box.contains(touch.location(in: slotsContainer)) {
                    animateButton(card.box) {
                        self.handleSlotSelection(slotId: card.slotId, mode: mode)
                    }
                    break
                }
            }
        }
    }
    
    private func handleSlotSelection(slotId: Int, mode: SlotMode) {
        let existingSave = SaveDataManager.shared.loadGame(slotId: slotId)
        
        let startPosition: CGPoint
        if mode == .loadGame, let save = existingSave {
            // Restore saved position
            startPosition = save.playerPosition
        } else {
            // New game: initial spawn at Shibuya crossing
            startPosition = CGPoint(x: -1250, y: -450)
            // Initialize save slot immediately
            _ = SaveDataManager.shared.saveGame(slotId: slotId, playerPosition: startPosition, districtName: "Shibuya Crossing")
        }
        
        launchGame(activeSlotId: slotId, startPosition: startPosition)
    }
    
    private func launchGame(activeSlotId: Int, startPosition: CGPoint) {
        guard let view = self.view else { return }
        
        let gameScene = GameScene(size: view.bounds.size)
        gameScene.scaleMode = .resizeFill
        gameScene.activeSlotId = activeSlotId
        gameScene.initialPlayerPosition = startPosition
        
        let transition = SKTransition.fade(withDuration: 0.4)
        view.presentScene(gameScene, transition: transition)
    }
    
    private func animateButton(_ node: SKNode, completion: @escaping () -> Void) {
        let pressDown = SKAction.scale(to: 0.94, duration: 0.05)
        let popUp = SKAction.scale(to: 1.0, duration: 0.06)
        node.run(SKAction.sequence([pressDown, popUp])) {
            completion()
        }
    }
}
