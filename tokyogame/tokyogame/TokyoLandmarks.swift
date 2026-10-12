//
//  TokyoLandmarks.swift
//  tokyogame
//
//  Created by Antigravity on 10/11/26.
//

import SpriteKit

// MARK: - Helper Labeled Box Generator

private func makeLandmarkTagBox(text: String, width: CGFloat, height: CGFloat = 18, color: SKColor = SKColor(white: 0.08, alpha: 0.90), borderColor: SKColor = SKColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 0.9)) -> SKNode {
    let box = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 4)
    box.fillColor = color
    box.strokeColor = borderColor
    box.lineWidth = 1.2
    box.zPosition = 50.0
    
    let label = SKLabelNode(text: text)
    label.fontName = "HelveticaNeue-Bold"
    label.fontSize = 8.5
    label.fontColor = .white
    label.verticalAlignmentMode = .center
    box.addChild(label)
    return box
}

// MARK: - 1. Tokyo Tower (Shiba / Minato)
/// Monumental 320 × 520 pt Red & White Lattice Steel Tower with dual observation decks and glowing beacon.
class TokyoTowerLandmarkNode: SKNode {
    
    let sprite: SKSpriteNode
    
    override init() {
        self.sprite = SKSpriteNode(imageNamed: "landmark_tokyo_tower")
        self.sprite.size = CGSize(width: 320, height: 520)
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
        super.init()
        
        addChild(sprite)
        
        // Beacon flashing at spire tip
        let beacon = SKShapeNode(circleOfRadius: 6)
        beacon.fillColor = SKColor(red: 1.0, green: 0.25, blue: 0.2, alpha: 1.0)
        beacon.strokeColor = .white
        beacon.lineWidth = 1.5
        beacon.position = CGPoint(x: 0, y: 508)
        beacon.zPosition = 10.0
        addChild(beacon)
        
        let beaconPulse = SKAction.sequence([
            SKAction.scale(to: 1.5, duration: 0.4),
            SKAction.scale(to: 0.8, duration: 0.4)
        ])
        beacon.run(SKAction.repeatForever(beaconPulse))
        
        // In-game prominent landmark label tag
        let tag = makeLandmarkTagBox(text: "[ TOKYO TOWER 東京タワー 320x520 ]", width: 180)
        tag.position = CGPoint(x: 0, y: 55)
        addChild(tag)
        
        // Base obstacle physics collision (FootTown & 4 legs foundation)
        let body = SKPhysicsBody(rectangleOf: CGSize(width: 240, height: 50), center: CGPoint(x: 0, y: 25))
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.obstacle
        body.collisionBitMask = PhysicsCategory.player
        self.physicsBody = body
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 2. Tokyo Skytree (Sumida / Oshiage)
/// Monumental 240 × 600 pt Futuristic Lattice Spire, Tembo Deck, Tembo Galleria & Broadcast Mast.
class TokyoSkytreeLandmarkNode: SKNode {
    
    let sprite: SKSpriteNode
    
    override init() {
        self.sprite = SKSpriteNode(imageNamed: "landmark_skytree")
        self.sprite.size = CGSize(width: 240, height: 600)
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
        super.init()
        
        addChild(sprite)
        
        // Cyan LED beacon at spire apex
        let beacon = SKShapeNode(circleOfRadius: 6)
        beacon.fillColor = SKColor(red: 0.2, green: 0.8, blue: 1.0, alpha: 1.0)
        beacon.strokeColor = .white
        beacon.lineWidth = 1.5
        beacon.position = CGPoint(x: 0, y: 582)
        beacon.zPosition = 10.0
        addChild(beacon)
        
        let beaconPulse = SKAction.sequence([
            SKAction.scale(to: 1.6, duration: 0.6),
            SKAction.scale(to: 0.8, duration: 0.6)
        ])
        beacon.run(SKAction.repeatForever(beaconPulse))
        
        let tag = makeLandmarkTagBox(text: "[ TOKYO SKYTREE スカイツリー 240x600 ]", width: 190)
        tag.position = CGPoint(x: 0, y: 55)
        addChild(tag)
        
        // Solid physics obstacle at base
        let body = SKPhysicsBody(rectangleOf: CGSize(width: 170, height: 50), center: CGPoint(x: 0, y: 25))
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.obstacle
        body.collisionBitMask = PhysicsCategory.player
        self.physicsBody = body
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 3. Shibuya 109 Fashion Tower
/// Grand 260 × 320 pt Cylindrical Fashion Skyscraper with iconic red 109 cylinder drum.
class Shibuya109LandmarkNode: SKNode {
    
    let sprite: SKSpriteNode
    
    override init() {
        self.sprite = SKSpriteNode(imageNamed: "landmark_shibuya109")
        self.sprite.size = CGSize(width: 260, height: 320)
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
        super.init()
        
        addChild(sprite)
        
        let tag = makeLandmarkTagBox(text: "[ SHIBUYA 109 渋谷109 260x320 ]", width: 170)
        tag.position = CGPoint(x: 0, y: 50)
        addChild(tag)
        
        // Solid physics obstacle at base
        let body = SKPhysicsBody(rectangleOf: CGSize(width: 200, height: 46), center: CGPoint(x: 0, y: 23))
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.obstacle
        body.collisionBitMask = PhysicsCategory.player
        self.physicsBody = body
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 4. Hachiko Statue (Shibuya Crossing Plaza)
/// Iconic 110 × 120 pt Bronze Akita dog statue atop polished granite pedestal.
class HachikoStatueNode: SKNode {
    
    let sprite: SKSpriteNode
    
    override init() {
        self.sprite = SKSpriteNode(imageNamed: "landmark_hachiko")
        self.sprite.size = CGSize(width: 110, height: 120)
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
        super.init()
        
        addChild(sprite)
        
        let tag = makeLandmarkTagBox(text: "[ HACHIKO STATUE ハチ公像 ]", width: 140)
        tag.position = CGPoint(x: 0, y: 40)
        addChild(tag)
        
        // Base pedestal collision
        let body = SKPhysicsBody(rectangleOf: CGSize(width: 70, height: 36), center: CGPoint(x: 0, y: 18))
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.obstacle
        body.collisionBitMask = PhysicsCategory.player
        self.physicsBody = body
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 5. Kaminarimon Gate (Senso-ji Asakusa)
/// Grand 240 × 220 pt Vermilion Thunder Gate with massive hanging red Chōchin lantern.
class KaminarimonGateNode: SKNode {
    
    let sprite: SKSpriteNode
    
    override init() {
        self.sprite = SKSpriteNode(imageNamed: "landmark_kaminarimon")
        self.sprite.size = CGSize(width: 240, height: 220)
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
        super.init()
        
        addChild(sprite)
        
        let tag = makeLandmarkTagBox(text: "[ KAMINARIMON 雷門 GATE ]", width: 150)
        tag.position = CGPoint(x: 0, y: 120)
        addChild(tag)
        
        // Dual pillar collisions (Walk-through center arch!)
        let leftPillar = SKNode()
        leftPillar.position = CGPoint(x: -72, y: 30)
        let leftBody = SKPhysicsBody(rectangleOf: CGSize(width: 38, height: 46))
        leftBody.isDynamic = false
        leftBody.categoryBitMask = PhysicsCategory.obstacle
        leftBody.collisionBitMask = PhysicsCategory.player
        leftPillar.physicsBody = leftBody
        addChild(leftPillar)
        
        let rightPillar = SKNode()
        rightPillar.position = CGPoint(x: 72, y: 30)
        let rightBody = SKPhysicsBody(rectangleOf: CGSize(width: 38, height: 46))
        rightBody.isDynamic = false
        rightBody.categoryBitMask = PhysicsCategory.obstacle
        rightBody.collisionBitMask = PhysicsCategory.player
        rightPillar.physicsBody = rightBody
        addChild(rightPillar)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 6. Senso-ji 5-Story Pagoda (Asakusa)
/// Majestic 200 × 380 pt 5-tiered curved tiled roofs with golden sōrin spire finial.
class SensojiPagodaNode: SKNode {
    
    let sprite: SKSpriteNode
    
    override init() {
        self.sprite = SKSpriteNode(imageNamed: "landmark_sensoji_pagoda")
        self.sprite.size = CGSize(width: 200, height: 380)
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
        super.init()
        
        addChild(sprite)
        
        let tag = makeLandmarkTagBox(text: "[ SENSO-JI 5-STORY PAGODA 五重塔 ]", width: 190)
        tag.position = CGPoint(x: 0, y: 55)
        addChild(tag)
        
        // Base foundation collision
        let body = SKPhysicsBody(rectangleOf: CGSize(width: 140, height: 44), center: CGPoint(x: 0, y: 22))
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.obstacle
        body.collisionBitMask = PhysicsCategory.player
        self.physicsBody = body
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 7. Takeshita Street Arch (Harajuku)
/// Vibrant 260 × 180 pt Harajuku Takeshita Street neon entrance arch with LED screen.
class TakeshitaArchNode: SKNode {
    
    let sprite: SKSpriteNode
    
    override init() {
        self.sprite = SKSpriteNode(imageNamed: "landmark_takeshita_arch")
        self.sprite.size = CGSize(width: 260, height: 180)
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
        super.init()
        
        addChild(sprite)
        
        let tag = makeLandmarkTagBox(text: "[ TAKESHITA ST. ARCH 竹下通り ]", width: 165)
        tag.position = CGPoint(x: 0, y: 115)
        addChild(tag)
        
        let leftPost = SKNode()
        leftPost.position = CGPoint(x: -88, y: 24)
        let leftBody = SKPhysicsBody(rectangleOf: CGSize(width: 32, height: 44))
        leftBody.isDynamic = false
        leftBody.categoryBitMask = PhysicsCategory.obstacle
        leftBody.collisionBitMask = PhysicsCategory.player
        leftPost.physicsBody = leftBody
        addChild(leftPost)
        
        let rightPost = SKNode()
        rightPost.position = CGPoint(x: 88, y: 24)
        let rightBody = SKPhysicsBody(rectangleOf: CGSize(width: 32, height: 44))
        rightBody.isDynamic = false
        rightBody.categoryBitMask = PhysicsCategory.obstacle
        rightBody.collisionBitMask = PhysicsCategory.player
        rightPost.physicsBody = rightBody
        addChild(rightPost)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 8. Marion Crepe Stand (Harajuku)
/// Cute 150 × 130 pt Harajuku Marion Crepe stand with pink striped awning and display case.
class HarajukuCrepeStandNode: SKNode {
    
    let sprite: SKSpriteNode
    
    override init() {
        self.sprite = SKSpriteNode(imageNamed: "landmark_crepe_stand")
        self.sprite.size = CGSize(width: 150, height: 130)
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
        super.init()
        
        addChild(sprite)
        
        let tag = makeLandmarkTagBox(text: "[ MARION CREPE STAND クレープ ]", width: 160)
        tag.position = CGPoint(x: 0, y: 40)
        addChild(tag)
        
        let body = SKPhysicsBody(rectangleOf: CGSize(width: 120, height: 38), center: CGPoint(x: 0, y: 19))
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.obstacle
        body.collisionBitMask = PhysicsCategory.player
        self.physicsBody = body
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 9. Imperial Fujimi-yagura Watchtower (Chiyoda)
/// Imposing 240 × 260 pt White 3-story castle keep on sloped stone rampart (ishigaki).
class ImperialWatchtowerNode: SKNode {
    
    let sprite: SKSpriteNode
    
    override init() {
        self.sprite = SKSpriteNode(imageNamed: "landmark_imperial_watchtower")
        self.sprite.size = CGSize(width: 240, height: 260)
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
        super.init()
        
        addChild(sprite)
        
        let tag = makeLandmarkTagBox(text: "[ FUJIMI YAGURA 富士見櫓 ]", width: 150)
        tag.position = CGPoint(x: 0, y: 55)
        addChild(tag)
        
        let body = SKPhysicsBody(rectangleOf: CGSize(width: 200, height: 50), center: CGPoint(x: 0, y: 25))
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.obstacle
        body.collisionBitMask = PhysicsCategory.player
        self.physicsBody = body
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 10. Mori Tower (Roppongi Hills)
/// Towering 300 × 420 pt Curved Glass Skyscraper with Tokyo City View rooftop observation deck.
class MoriTowerLandmarkNode: SKNode {
    
    let sprite: SKSpriteNode
    
    override init() {
        self.sprite = SKSpriteNode(imageNamed: "landmark_mori_tower")
        self.sprite.size = CGSize(width: 300, height: 420)
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
        super.init()
        
        addChild(sprite)
        
        let tag = makeLandmarkTagBox(text: "[ MORI TOWER 六本木ヒルズ ]", width: 160)
        tag.position = CGPoint(x: 0, y: 50)
        addChild(tag)
        
        let body = SKPhysicsBody(rectangleOf: CGSize(width: 230, height: 48), center: CGPoint(x: 0, y: 24))
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.obstacle
        body.collisionBitMask = PhysicsCategory.player
        self.physicsBody = body
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 11. Maman Spider Bronze Sculpture (Roppongi Hills)
/// Dramatic 200 × 180 pt Bronze Giant Spider Sculpture standing on long slender arching legs.
class MamanSpiderSculptureNode: SKNode {
    
    let sprite: SKSpriteNode
    
    override init() {
        self.sprite = SKSpriteNode(imageNamed: "landmark_maman_spider")
        self.sprite.size = CGSize(width: 200, height: 180)
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
        super.init()
        
        addChild(sprite)
        
        let tag = makeLandmarkTagBox(text: "[ MAMAN SPIDER 巨大蜘蛛 ]", width: 145)
        tag.position = CGPoint(x: 0, y: 40)
        addChild(tag)
        
        let body = SKPhysicsBody(circleOfRadius: 26, center: CGPoint(x: 0, y: 24))
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.obstacle
        body.collisionBitMask = PhysicsCategory.player
        self.physicsBody = body
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 12. Ginza Wako Clock Tower
/// Grand 220 × 300 pt Curved Neoclassical Department Store with Hattori Clock Tower.
class GinzaWakoClockNode: SKNode {
    
    let sprite: SKSpriteNode
    
    override init() {
        self.sprite = SKSpriteNode(imageNamed: "landmark_wako_clock")
        self.sprite.size = CGSize(width: 220, height: 300)
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
        super.init()
        
        addChild(sprite)
        
        let tag = makeLandmarkTagBox(text: "[ GINZA WAKO CLOCK 銀座和光 ]", width: 165)
        tag.position = CGPoint(x: 0, y: 50)
        addChild(tag)
        
        let body = SKPhysicsBody(rectangleOf: CGSize(width: 170, height: 44), center: CGPoint(x: 0, y: 22))
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.obstacle
        body.collisionBitMask = PhysicsCategory.player
        self.physicsBody = body
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 13. Akihabara Radio Kaikan
/// Monumental 260 × 280 pt 10-story electronics and hobby bazaar with giant yellow/red signage.
class AkibaRadioKaikanNode: SKNode {
    
    let sprite: SKSpriteNode
    
    override init() {
        self.sprite = SKSpriteNode(imageNamed: "landmark_radio_kaikan")
        self.sprite.size = CGSize(width: 260, height: 280)
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
        super.init()
        
        addChild(sprite)
        
        let tag = makeLandmarkTagBox(text: "[ RADIO KAIKAN ラジオ会館 ]", width: 160)
        tag.position = CGPoint(x: 0, y: 50)
        addChild(tag)
        
        let body = SKPhysicsBody(rectangleOf: CGSize(width: 200, height: 46), center: CGPoint(x: 0, y: 23))
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.obstacle
        body.collisionBitMask = PhysicsCategory.player
        self.physicsBody = body
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 14. Akihabara Club Sega Arcade
/// Towering 250 × 290 pt Bright Red Multi-Floor Video Game Center with glowing arcade marquee.
class AkibaArcadeNode: SKNode {
    
    let sprite: SKSpriteNode
    
    override init() {
        self.sprite = SKSpriteNode(imageNamed: "landmark_akiba_arcade")
        self.sprite.size = CGSize(width: 250, height: 290)
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
        super.init()
        
        addChild(sprite)
        
        let tag = makeLandmarkTagBox(text: "[ CLUB SEGA ARCADE セガ ]", width: 155)
        tag.position = CGPoint(x: 0, y: 50)
        addChild(tag)
        
        let body = SKPhysicsBody(rectangleOf: CGSize(width: 195, height: 46), center: CGPoint(x: 0, y: 23))
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.obstacle
        body.collisionBitMask = PhysicsCategory.player
        self.physicsBody = body
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 15. Tsukiji Outer Market Hall
/// Sprawling 320 × 220 pt Wholesale fish and seafood market hall with blue awnings.
class TsukijiMarketHallNode: SKNode {
    
    let sprite: SKSpriteNode
    
    override init() {
        self.sprite = SKSpriteNode(imageNamed: "landmark_tsukiji_market")
        self.sprite.size = CGSize(width: 320, height: 220)
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
        super.init()
        
        addChild(sprite)
        
        let tag = makeLandmarkTagBox(text: "[ TSUKIJI MARKET 築地市場 ]", width: 155)
        tag.position = CGPoint(x: 0, y: 50)
        addChild(tag)
        
        let body = SKPhysicsBody(rectangleOf: CGSize(width: 260, height: 46), center: CGPoint(x: 0, y: 23))
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.obstacle
        body.collisionBitMask = PhysicsCategory.player
        self.physicsBody = body
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 16. Tokyo National Museum (Ueno Park)
/// Grand 340 × 240 pt Neoclassical Teikan-style imperial palace facade with copper tile roof.
class UenoMuseumNode: SKNode {
    
    let sprite: SKSpriteNode
    
    override init() {
        self.sprite = SKSpriteNode(imageNamed: "landmark_ueno_museum")
        self.sprite.size = CGSize(width: 340, height: 240)
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
        super.init()
        
        addChild(sprite)
        
        let tag = makeLandmarkTagBox(text: "[ TOKYO NATL MUSEUM 東京国立博物館 ]", width: 195)
        tag.position = CGPoint(x: 0, y: 50)
        addChild(tag)
        
        let body = SKPhysicsBody(rectangleOf: CGSize(width: 280, height: 48), center: CGPoint(x: 0, y: 24))
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.obstacle
        body.collisionBitMask = PhysicsCategory.player
        self.physicsBody = body
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
