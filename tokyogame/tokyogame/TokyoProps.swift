//
//  TokyoProps.swift
//  tokyogame
//
//  Created by Antigravity on 10/11/26.
//

import SpriteKit

// MARK: - Helper Labeled Box Generator for Tokyo Props

func makePropTagBox(
    text: String,
    width: CGFloat = 0,
    yOffset: CGFloat = 0,
    height: CGFloat = 14,
    color: SKColor = SKColor(white: 0.06, alpha: 0.90),
    borderColor: SKColor = SKColor(red: 0.3, green: 0.85, blue: 1.0, alpha: 0.85)
) -> SKNode {
    let charWidth = CGFloat(text.count) * 5.4 + 12
    let actualWidth = max(width, charWidth)
    let box = SKShapeNode(rectOf: CGSize(width: actualWidth, height: height), cornerRadius: 3)
    box.fillColor = color
    box.strokeColor = borderColor
    box.lineWidth = 1.0
    box.position = CGPoint(x: 0, y: yOffset)
    box.zPosition = 50.0
    
    let label = SKLabelNode(text: text)
    label.fontName = "HelveticaNeue-Bold"
    label.fontSize = 7.5
    label.fontColor = .white
    label.verticalAlignmentMode = .center
    box.addChild(label)
    return box
}

// MARK: - 1. Vending Machines (Jidōhanbikei)

/// Japanese drinks vending machine loaded from .imageset with explicit in-game label tag.
class VendingMachineNode: SKNode {
    
    enum MachineColor {
        case red    // Coca-Cola / Hot coffee style
        case blue   // Sports drink / Pocari style
        case hot    // Warm canned drinks style
        
        var assetName: String {
            switch self {
            case .red: return "prop_vending_red"
            case .blue: return "prop_vending_blue"
            case .hot: return "prop_vending_hot"
            }
        }
        
        var tagLabel: String {
            switch self {
            case .red: return "[ VENDING MACHINE (RED / COLA) ]"
            case .blue: return "[ VENDING MACHINE (BLUE / POCARI) ]"
            case .hot: return "[ VENDING MACHINE (HOT DRINKS) ]"
            }
        }
    }
    
    let sprite: SKSpriteNode
    
    init(type: MachineColor = .red) {
        self.sprite = SKSpriteNode(imageNamed: type.assetName)
        self.sprite.size = CGSize(width: 38, height: 54)
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
        super.init()
        addChild(sprite)
        
        // Base collision
        let body = SKPhysicsBody(rectangleOf: CGSize(width: 36, height: 20), center: CGPoint(x: 0, y: 10))
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.obstacle
        body.collisionBitMask = PhysicsCategory.player
        self.physicsBody = body
        
        // In-game prominent asset label tag
        let tag = makePropTagBox(text: type.tagLabel, yOffset: 62)
        addChild(tag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 2. Tokyo Trees & Nature

/// 2.5D Sakura, Ginkgo, Pine, and Green trees loaded from .imageset with explicit in-game label tag.
class TokyoTreeNode: SKNode {
    
    enum TreeType {
        case sakuraBlossom
        case greenPark
        case ginkgo
        case pine
        
        var assetName: String {
            switch self {
            case .sakuraBlossom: return "prop_tree_sakura"
            case .greenPark: return "prop_tree_green"
            case .ginkgo: return "prop_tree_ginkgo"
            case .pine: return "prop_tree_pine"
            }
        }
        
        var tagLabel: String {
            switch self {
            case .sakuraBlossom: return "[ SAKURA CHERRY TREE (桜) ]"
            case .greenPark: return "[ PARK TREE (公園樹木) ]"
            case .ginkgo: return "[ GINKGO TREE (銀杏並木) ]"
            case .pine: return "[ PINE TREE (松の木) ]"
            }
        }
    }
    
    let sprite: SKSpriteNode
    
    init(type: TreeType = .sakuraBlossom, radius: CGFloat = 36.0) {
        self.sprite = SKSpriteNode(imageNamed: type.assetName)
        let w: CGFloat = radius * 2.3
        let h: CGFloat = radius * 2.6
        self.sprite.size = CGSize(width: w, height: h)
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
        super.init()
        addChild(sprite)
        
        // Trunk foot collision at bottom
        let body = SKPhysicsBody(circleOfRadius: 14, center: CGPoint(x: 0, y: 14))
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.obstacle
        body.collisionBitMask = PhysicsCategory.player
        self.physicsBody = body
        
        // In-game prominent asset label tag
        let tag = makePropTagBox(text: type.tagLabel, yOffset: h + 10)
        addChild(tag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 3. Japanese Post Boxes

/// Authentic Japanese red post box with (〒) loaded from .imageset with explicit in-game label tag.
class JapanesePostBoxNode: SKNode {
    
    enum BoxType {
        case standard   // Modern dual-slot post box
        case retro      // Vintage cylindrical dome post box
    }
    
    let sprite: SKSpriteNode
    
    init(type: BoxType = .standard) {
        let assetName = (type == .standard) ? "prop_mailbox_jp" : "prop_mailbox_retro"
        let size = (type == .standard) ? CGSize(width: 32, height: 44) : CGSize(width: 30, height: 52)
        self.sprite = SKSpriteNode(imageNamed: assetName)
        self.sprite.size = size
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
        super.init()
        addChild(sprite)
        
        let body = SKPhysicsBody(rectangleOf: CGSize(width: 26, height: 18), center: CGPoint(x: 0, y: 9))
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.obstacle
        body.collisionBitMask = PhysicsCategory.player
        self.physicsBody = body
        
        // In-game prominent asset label tag
        let tagText = (type == .standard) ? "[ POST BOX (〒 郵便ポスト) ]" : "[ RETRO POST BOX (〒 丸型ポスト) ]"
        let yOff: CGFloat = (type == .standard) ? 52 : 60
        let tag = makePropTagBox(text: tagText, yOffset: yOff)
        addChild(tag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 4. Streetlamps

/// Tokyo streetlamps (Modern LED, Ginza European, Akiba Cyber, Traditional) with explicit in-game label tag.
class TokyoStreetLampNode: SKNode {
    
    enum LampStyle {
        case modern
        case ginza
        case akiba
        case traditional
        
        var assetName: String {
            switch self {
            case .modern: return "prop_streetlamp_modern"
            case .ginza: return "prop_streetlamp_ginza"
            case .akiba: return "prop_streetlamp_akiba"
            case .traditional: return "prop_streetlamp_traditional"
            }
        }
        
        var size: CGSize {
            switch self {
            case .modern: return CGSize(width: 26, height: 72)
            case .ginza: return CGSize(width: 32, height: 80)
            case .akiba: return CGSize(width: 28, height: 76)
            case .traditional: return CGSize(width: 30, height: 74)
            }
        }
        
        var tagLabel: String {
            switch self {
            case .modern: return "[ STREET LAMP (LED街灯) ]"
            case .ginza: return "[ GINZA GAS LAMP (銀座街灯) ]"
            case .akiba: return "[ AKIBA CYBER LAMP (秋葉原街灯) ]"
            case .traditional: return "[ TRADITIONAL LAMP (和風街灯) ]"
            }
        }
    }
    
    let sprite: SKSpriteNode
    
    init(style: LampStyle = .modern) {
        self.sprite = SKSpriteNode(imageNamed: style.assetName)
        self.sprite.size = style.size
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
        super.init()
        addChild(sprite)
        
        // Base pole collision
        let body = SKPhysicsBody(circleOfRadius: 8, center: CGPoint(x: 0, y: 8))
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.obstacle
        body.collisionBitMask = PhysicsCategory.player
        self.physicsBody = body
        
        // In-game prominent asset label tag
        let tag = makePropTagBox(text: style.tagLabel, yOffset: style.size.height + 8)
        addChild(tag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 5. Torii Gate

/// Shinto Shrine vermilion Torii Gate with walk-through archway and explicit in-game label tag.
class ToriiGateNode: SKNode {
    
    let sprite: SKSpriteNode
    
    override init() {
        self.sprite = SKSpriteNode(imageNamed: "prop_torii_gate")
        self.sprite.size = CGSize(width: 130, height: 110)
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
        super.init()
        addChild(sprite)
        
        // Dual pillar collisions (Walk-through archway!)
        let leftPost = SKNode()
        leftPost.position = CGPoint(x: -44, y: 15)
        let leftBody = SKPhysicsBody(rectangleOf: CGSize(width: 18, height: 30))
        leftBody.isDynamic = false
        leftBody.categoryBitMask = PhysicsCategory.obstacle
        leftBody.collisionBitMask = PhysicsCategory.player
        leftPost.physicsBody = leftBody
        addChild(leftPost)
        
        let rightPost = SKNode()
        rightPost.position = CGPoint(x: 44, y: 15)
        let rightBody = SKPhysicsBody(rectangleOf: CGSize(width: 18, height: 30))
        rightBody.isDynamic = false
        rightBody.categoryBitMask = PhysicsCategory.obstacle
        rightBody.collisionBitMask = PhysicsCategory.player
        rightPost.physicsBody = rightBody
        addChild(rightPost)
        
        // In-game prominent asset label tag
        let tag = makePropTagBox(text: "[ SHINTO TORII GATE (鳥居) ]", yOffset: 120)
        addChild(tag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 6. Lanterns (Stone Toro & Red Chōchin)

/// Japanese Toro garden stone lantern with explicit in-game label tag.
class StoneLanternNode: SKNode {
    
    let sprite: SKSpriteNode
    
    override init() {
        self.sprite = SKSpriteNode(imageNamed: "prop_lantern_stone")
        self.sprite.size = CGSize(width: 34, height: 54)
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
        super.init()
        addChild(sprite)
        
        let body = SKPhysicsBody(circleOfRadius: 12, center: CGPoint(x: 0, y: 12))
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.obstacle
        body.collisionBitMask = PhysicsCategory.player
        self.physicsBody = body
        
        // In-game prominent asset label tag
        let tag = makePropTagBox(text: "[ STONE TORO LANTERN (石灯籠) ]", yOffset: 62)
        addChild(tag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// Hanging Chōchin red paper lantern with explicit in-game label tag.
class ChochinLanternNode: SKNode {
    
    let sprite: SKSpriteNode
    
    override init() {
        self.sprite = SKSpriteNode(imageNamed: "prop_lantern_red")
        self.sprite.size = CGSize(width: 26, height: 42)
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
        super.init()
        addChild(sprite)
        
        // In-game prominent asset label tag
        let tag = makePropTagBox(text: "[ RED CHOCHIN LANTERN (赤提灯) ]", yOffset: 48)
        addChild(tag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 7. Traffic Signals

/// Shibuya Crosswalk Traffic Signal Pole with explicit in-game label tag.
class TrafficLightNode: SKNode {
    
    let sprite: SKSpriteNode
    
    override init() {
        self.sprite = SKSpriteNode(imageNamed: "prop_traffic_light")
        self.sprite.size = CGSize(width: 20, height: 70)
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
        super.init()
        addChild(sprite)
        
        let body = SKPhysicsBody(circleOfRadius: 7, center: CGPoint(x: 0, y: 8))
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.obstacle
        body.collisionBitMask = PhysicsCategory.player
        self.physicsBody = body
        
        // In-game prominent asset label tag
        let tag = makePropTagBox(text: "[ TRAFFIC LIGHT (歩行者信号) ]", yOffset: 78)
        addChild(tag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 8. Public Utilities & Street Items

/// NTT Green Public Telephone Booth with explicit in-game label tag.
class PhoneBoothNode: SKNode {
    
    let sprite: SKSpriteNode
    
    override init() {
        self.sprite = SKSpriteNode(imageNamed: "prop_phonebooth_green")
        self.sprite.size = CGSize(width: 36, height: 62)
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
        super.init()
        addChild(sprite)
        
        let body = SKPhysicsBody(rectangleOf: CGSize(width: 30, height: 22), center: CGPoint(x: 0, y: 11))
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.obstacle
        body.collisionBitMask = PhysicsCategory.player
        self.physicsBody = body
        
        // In-game prominent asset label tag
        let tag = makePropTagBox(text: "[ NTT PHONE BOOTH (緑の公衆電話) ]", yOffset: 70)
        addChild(tag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// Convenience store 3-part recycling bin trio with explicit in-game label tag.
class CombiniBinsNode: SKNode {
    
    let sprite: SKSpriteNode
    
    override init() {
        self.sprite = SKSpriteNode(imageNamed: "prop_combini_bins")
        self.sprite.size = CGSize(width: 44, height: 34)
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
        super.init()
        addChild(sprite)
        
        let body = SKPhysicsBody(rectangleOf: CGSize(width: 40, height: 16), center: CGPoint(x: 0, y: 8))
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.obstacle
        body.collisionBitMask = PhysicsCategory.player
        self.physicsBody = body
        
        // In-game prominent asset label tag
        let tag = makePropTagBox(text: "[ COMBINI RECYCLE BINS (分別回収) ]", yOffset: 42)
        addChild(tag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// Akihabara double-deck Gachapon capsule bank with explicit in-game label tag.
class GachaponRowNode: SKNode {
    
    let sprite: SKSpriteNode
    
    override init() {
        self.sprite = SKSpriteNode(imageNamed: "prop_gachapon_bank")
        self.sprite.size = CGSize(width: 54, height: 48)
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
        super.init()
        addChild(sprite)
        
        let body = SKPhysicsBody(rectangleOf: CGSize(width: 48, height: 20), center: CGPoint(x: 0, y: 10))
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.obstacle
        body.collisionBitMask = PhysicsCategory.player
        self.physicsBody = body
        
        // In-game prominent asset label tag
        let tag = makePropTagBox(text: "[ GACHAPON BANK (ガチャガチャ) ]", yOffset: 56)
        addChild(tag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// Japanese Mamachari City Shopping Bicycle with explicit in-game label tag.
class BicycleNode: SKNode {
    
    let sprite: SKSpriteNode
    
    override init() {
        self.sprite = SKSpriteNode(imageNamed: "prop_bicycle_mamachari")
        self.sprite.size = CGSize(width: 46, height: 38)
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
        super.init()
        addChild(sprite)
        
        let body = SKPhysicsBody(rectangleOf: CGSize(width: 40, height: 16), center: CGPoint(x: 0, y: 8))
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.obstacle
        body.collisionBitMask = PhysicsCategory.player
        self.physicsBody = body
        
        // In-game prominent asset label tag
        let tag = makePropTagBox(text: "[ MAMACHARI BIKE (ママチャリ) ]", yOffset: 46)
        addChild(tag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// Japanese delivery scooter with explicit in-game label tag.
class ScooterNode: SKNode {
    
    let sprite: SKSpriteNode
    
    override init() {
        self.sprite = SKSpriteNode(imageNamed: "prop_scooter_delivery")
        self.sprite.size = CGSize(width: 48, height: 40)
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
        super.init()
        addChild(sprite)
        
        let body = SKPhysicsBody(rectangleOf: CGSize(width: 42, height: 16), center: CGPoint(x: 0, y: 8))
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.obstacle
        body.collisionBitMask = PhysicsCategory.player
        self.physicsBody = body
        
        // In-game prominent asset label tag
        let tag = makePropTagBox(text: "[ DELIVERY SCOOTER (出前バイク) ]", yOffset: 48)
        addChild(tag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// Cute Tokyo animal construction road barricade (Rabbit / Frog) with explicit in-game label tag.
class ConstructionBarrierNode: SKNode {
    
    enum BarrierType {
        case rabbit
        case frog
    }
    
    let sprite: SKSpriteNode
    
    init(type: BarrierType = .rabbit) {
        let assetName = (type == .rabbit) ? "prop_barrier_rabbit" : "prop_barrier_frog"
        self.sprite = SKSpriteNode(imageNamed: assetName)
        self.sprite.size = CGSize(width: 42, height: 34)
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
        super.init()
        addChild(sprite)
        
        let body = SKPhysicsBody(rectangleOf: CGSize(width: 38, height: 14), center: CGPoint(x: 0, y: 7))
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.obstacle
        body.collisionBitMask = PhysicsCategory.player
        self.physicsBody = body
        
        // In-game prominent asset label tag
        let tagText = (type == .rabbit) ? "[ RABBIT BARRIER (ウサギ防護柵) ]" : "[ FROG BARRIER (カエル防護柵) ]"
        let tag = makePropTagBox(text: tagText, yOffset: 42)
        addChild(tag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// Potted sidewalk bonsai or bamboo planter with explicit in-game label tag.
class BonsaiPlanterNode: SKNode {
    
    let sprite: SKSpriteNode
    
    override init() {
        self.sprite = SKSpriteNode(imageNamed: "prop_potted_bonsai")
        self.sprite.size = CGSize(width: 32, height: 32)
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
        super.init()
        addChild(sprite)
        
        let body = SKPhysicsBody(circleOfRadius: 10, center: CGPoint(x: 0, y: 10))
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.obstacle
        body.collisionBitMask = PhysicsCategory.player
        self.physicsBody = body
        
        // In-game prominent asset label tag
        let tag = makePropTagBox(text: "[ BONSAI PLANTER (盆栽) ]", yOffset: 40)
        addChild(tag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// Tokyo white steel wavy pedestrian guard rail with explicit in-game label tag.
class GuardRailNode: SKNode {
    
    let sprite: SKSpriteNode
    
    override init() {
        self.sprite = SKSpriteNode(imageNamed: "prop_guard_rail")
        self.sprite.size = CGSize(width: 64, height: 26)
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
        super.init()
        addChild(sprite)
        
        let body = SKPhysicsBody(rectangleOf: CGSize(width: 60, height: 14), center: CGPoint(x: 0, y: 7))
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.obstacle
        body.collisionBitMask = PhysicsCategory.player
        self.physicsBody = body
        
        // In-game prominent asset label tag
        let tag = makePropTagBox(text: "[ PEDESTRIAN GUARD RAIL (防護柵) ]", yOffset: 34)
        addChild(tag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// Red standpipe fire hydrant with explicit in-game label tag.
class FireHydrantNode: SKNode {
    
    let sprite: SKSpriteNode
    
    override init() {
        self.sprite = SKSpriteNode(imageNamed: "prop_fire_hydrant")
        self.sprite.size = CGSize(width: 24, height: 36)
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
        super.init()
        addChild(sprite)
        
        let body = SKPhysicsBody(circleOfRadius: 8, center: CGPoint(x: 0, y: 8))
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.obstacle
        body.collisionBitMask = PhysicsCategory.player
        self.physicsBody = body
        
        // In-game prominent asset label tag
        let tag = makePropTagBox(text: "[ FIRE HYDRANT (消火栓) ]", yOffset: 44)
        addChild(tag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// Toei Tokyo city bus stop sign pole with explicit in-game label tag.
class BusStopNode: SKNode {
    
    let sprite: SKSpriteNode
    
    override init() {
        self.sprite = SKSpriteNode(imageNamed: "prop_bus_stop")
        self.sprite.size = CGSize(width: 24, height: 64)
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
        super.init()
        addChild(sprite)
        
        let body = SKPhysicsBody(circleOfRadius: 7, center: CGPoint(x: 0, y: 7))
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.obstacle
        body.collisionBitMask = PhysicsCategory.player
        self.physicsBody = body
        
        // In-game prominent asset label tag
        let tag = makePropTagBox(text: "[ TOEI BUS STOP (都営バス) ]", yOffset: 72)
        addChild(tag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 9. Street Food Stalls (Yatai)

/// Traditional ramen street noodle cart with explicit in-game label tag.
class RamenYataiNode: SKNode {
    
    let sprite: SKSpriteNode
    
    override init() {
        self.sprite = SKSpriteNode(imageNamed: "prop_stall_ramen_yatai")
        self.sprite.size = CGSize(width: 84, height: 70)
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
        super.init()
        addChild(sprite)
        
        let body = SKPhysicsBody(rectangleOf: CGSize(width: 76, height: 26), center: CGPoint(x: 0, y: 13))
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.obstacle
        body.collisionBitMask = PhysicsCategory.player
        self.physicsBody = body
        
        // In-game prominent asset label tag
        let tag = makePropTagBox(text: "[ RAMEN YATAI CART (ラーメン屋台) ]", yOffset: 78)
        addChild(tag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// Takoyaki street food stall with explicit in-game label tag.
class TakoyakiStallNode: SKNode {
    
    let sprite: SKSpriteNode
    
    override init() {
        self.sprite = SKSpriteNode(imageNamed: "prop_stall_takoyaki")
        self.sprite.size = CGSize(width: 76, height: 64)
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
        super.init()
        addChild(sprite)
        
        let body = SKPhysicsBody(rectangleOf: CGSize(width: 68, height: 24), center: CGPoint(x: 0, y: 12))
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.obstacle
        body.collisionBitMask = PhysicsCategory.player
        self.physicsBody = body
        
        // In-game prominent asset label tag
        let tag = makePropTagBox(text: "[ TAKOYAKI STALL (たこ焼き屋台) ]", yOffset: 72)
        addChild(tag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 10. Underground Metro Station Entrance

/// Tokyo Metro underground subway entrance with explicit in-game label tag.
class MetroEntranceNode: SKNode {
    
    let sprite: SKSpriteNode
    
    override init() {
        self.sprite = SKSpriteNode(imageNamed: "scenery_metro_entrance")
        self.sprite.size = CGSize(width: 110, height: 74)
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
        super.init()
        addChild(sprite)
        
        // Base obstacle
        let body = SKPhysicsBody(rectangleOf: CGSize(width: 90, height: 30), center: CGPoint(x: 0, y: 15))
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.obstacle
        body.collisionBitMask = PhysicsCategory.player
        self.physicsBody = body
        
        // In-game prominent asset label tag
        let tag = makePropTagBox(text: "[ TOKYO METRO ENTRANCE (地下鉄入口) ]", yOffset: 82)
        addChild(tag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Fish crate / Turret truck node with explicit in-game label tag
class FishCrateNode: SKNode {
    let sprite: SKSpriteNode
    override init() {
        self.sprite = SKSpriteNode(imageNamed: "vehicle_turret_truck")
        self.sprite.size = CGSize(width: 64, height: 40)
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        super.init()
        addChild(sprite)
        let body = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 18), center: CGPoint(x: 0, y: 9))
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.obstacle
        body.collisionBitMask = PhysicsCategory.player
        self.physicsBody = body
        
        // In-game prominent asset label tag
        let tag = makePropTagBox(text: "[ TSUKIJI TURRET TRUCK (ターレット) ]", yOffset: 48)
        addChild(tag)
    }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - 11. Tokyo Vehicles & Traffic (with .imageset sets!)

/// Authentic Tokyo cars, taxis, trucks, and vans loaded from .imageset with explicit in-game label tags.
/// Supports both parked vehicles and moving traffic cruising along Tokyo avenues.
class TokyoVehicleNode: SKNode {
    
    enum VehicleType {
        case taxiGreen      // Tokyo Crown green taxi
        case taxiBlack      // Executive black taxi
        case keiTruck       // Japanese mini white flatbed truck
        case compactYellow  // Cute yellow kei hatchback
        case sedanSilver    // Modern silver sedan
        case deliveryVan    // Courier delivery van
        case turretTruck    // Tsukiji fish market cart
        
        var assetName: String {
            switch self {
            case .taxiGreen: return "vehicle_taxi_green"
            case .taxiBlack: return "vehicle_taxi_black"
            case .keiTruck: return "vehicle_kei_truck"
            case .compactYellow: return "vehicle_compact_yellow"
            case .sedanSilver: return "vehicle_sedan_silver"
            case .deliveryVan: return "vehicle_delivery_van"
            case .turretTruck: return "vehicle_turret_truck"
            }
        }
        
        var size: CGSize {
            switch self {
            case .taxiGreen, .taxiBlack: return CGSize(width: 84, height: 44)
            case .keiTruck: return CGSize(width: 76, height: 44)
            case .compactYellow: return CGSize(width: 72, height: 42)
            case .sedanSilver: return CGSize(width: 84, height: 44)
            case .deliveryVan: return CGSize(width: 88, height: 48)
            case .turretTruck: return CGSize(width: 64, height: 40)
            }
        }
        
        var tagLabel: String {
            switch self {
            case .taxiGreen: return "[ TOKYO CROWN TAXI (個人タクシー) ]"
            case .taxiBlack: return "[ BLACK TAXI (黒塗りハイヤー) ]"
            case .keiTruck: return "[ KEI MINI TRUCK (軽トラック) ]"
            case .compactYellow: return "[ KEI HATCHBACK (軽自動車) ]"
            case .sedanSilver: return "[ SILVER SEDAN (乗用車) ]"
            case .deliveryVan: return "[ DELIVERY VAN (宅急便バン) ]"
            case .turretTruck: return "[ TSUKIJI TURRET CART (ターレット) ]"
            }
        }
    }
    
    let sprite: SKSpriteNode
    let vehicleType: VehicleType
    var isMoving: Bool = false
    var moveSpeed: CGFloat = 80.0
    var moveBounds: (minX: CGFloat, maxX: CGFloat) = (-2000, 2000)
    var direction: CGFloat = 1.0 // 1.0 for right, -1.0 for left
    
    init(type: VehicleType = .taxiGreen, isMoving: Bool = false, speed: CGFloat = 80.0, direction: CGFloat = 1.0) {
        self.vehicleType = type
        self.isMoving = isMoving
        self.moveSpeed = speed
        self.direction = direction
        
        self.sprite = SKSpriteNode(imageNamed: type.assetName)
        self.sprite.size = type.size
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
        if direction < 0 {
            self.sprite.xScale = -1.0
        }
        
        super.init()
        addChild(sprite)
        
        // Physics obstacle
        let body = SKPhysicsBody(rectangleOf: CGSize(width: type.size.width * 0.9, height: 22), center: CGPoint(x: 0, y: 11))
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.vehicle | PhysicsCategory.obstacle
        body.collisionBitMask = PhysicsCategory.player
        self.physicsBody = body
        
        // In-game prominent asset label tag
        let tag = makePropTagBox(text: type.tagLabel, yOffset: type.size.height + 8)
        addChild(tag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(dt: TimeInterval) {
        guard isMoving else { return }
        position.x += CGFloat(dt) * moveSpeed * direction
        
        if direction > 0 && position.x > moveBounds.maxX {
            position.x = moveBounds.minX
        } else if direction < 0 && position.x < moveBounds.minX {
            position.x = moveBounds.maxX
        }
    }
}
