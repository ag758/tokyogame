//
//  BuildingNode.swift
//  tokyogame
//
//  Created by Antigravity on 10/11/26.
//

import SpriteKit

/// Types of 2.5D Tokyo buildings loaded from .imageset assets.
enum BuildingType: String {
    case konbini = "building_konbini"              // Japanese convenience store
    case ramenShop = "building_ramen"              // Ramen / noodle restaurant
    case tokyoHighRise = "building_highrise"      // Modern tall city building
    case arcade = "building_arcade"                // Neon game arcade
    case cafe = "building_cafe"                    // Sidewalk cafe
    case shrinePavilion = "building_shrine_pavilion" // Traditional wooden temple hall
    case akibaShop = "building_akiba_shop"         // Anime / hobby megastore
    case ginzaBoutique = "building_ginza_boutique" // Luxury fashion boutique
    case sushiBar = "building_sushi_bar"           // Tsukiji sushi bar
    
    var displayName: String {
        switch self {
        case .konbini: return "KONBINI (CONVENIENCE STORE)"
        case .ramenShop: return "RAMEN SHOP (麺)"
        case .tokyoHighRise: return "TOKYO HIGHRISE TOWER"
        case .arcade: return "GAME CENTER ARCADE"
        case .cafe: return "TOKYO SIDEWALK CAFE"
        case .shrinePavilion: return "SHRINE HALL (神社)"
        case .akibaShop: return "AKIBA HOBBY MEGASTORE"
        case .ginzaBoutique: return "GINZA LUXURY BOUTIQUE"
        case .sushiBar: return "TSUKIJI SUSHI DAI"
        }
    }
}

/// A 2.5D Pokémon-style building node that renders using standard .imageset placeholder assets
/// with feet-level physics collision for 2.5D depth sorting and an explicit in-game label tag.
class BuildingNode: SKNode {
    
    let buildingType: BuildingType
    let sprite: SKSpriteNode
    let tagNode: SKNode
    
    init(type: BuildingType, size: CGSize = CGSize(width: 200, height: 150), facadeHeight: CGFloat = 100, roofHeight: CGFloat = 40) {
        self.buildingType = type
        self.sprite = SKSpriteNode(imageNamed: type.rawValue)
        self.sprite.size = size
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
        // Explicit in-game labeled badge
        let text = "[ \(type.displayName) ]"
        let font = "HelveticaNeue-Bold"
        let fontSize: CGFloat = 8.5
        let tempLabel = SKLabelNode(fontNamed: font)
        tempLabel.text = text
        let tagW = max(80, max(tempLabel.frame.width + 16, CGFloat(text.count) * 6.5 + 16))
        let tagH: CGFloat = 17.0
        
        let box = SKShapeNode(rectOf: CGSize(width: tagW, height: tagH), cornerRadius: 4)
        box.fillColor = SKColor(white: 0.08, alpha: 0.88)
        box.strokeColor = SKColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 0.85)
        box.lineWidth = 1.0
        box.position = CGPoint(x: 0, y: min(size.height - 10, 135))
        box.zPosition = 50.0
        
        let label = SKLabelNode(text: text)
        label.fontName = font
        label.fontSize = fontSize
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        box.addChild(label)
        self.tagNode = box
        
        super.init()
        
        addChild(sprite)
        addChild(tagNode)
        
        // In 2.5D top-down games, only the base of the building collides with the player's feet.
        let collisionHeight: CGFloat = 36.0
        let body = SKPhysicsBody(rectangleOf: CGSize(width: size.width * 0.9, height: collisionHeight),
                                 center: CGPoint(x: 0, y: collisionHeight / 2.0))
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.building
        body.collisionBitMask = PhysicsCategory.player
        self.physicsBody = body
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
