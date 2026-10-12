//
//  TokyoWorldNode.swift
//  tokyogame
//
//  Created by Antigravity on 10/11/26.
//

import SpriteKit

// MARK: - Tokyo District Model

struct TokyoDistrict {
    let id: String
    let name: String
    let japaneseName: String
    let saveName: String
    let bounds: CGRect
    let landmarkDescription: String
    
    var hudTitle: String {
        return "\(name) ・ \(japaneseName)"
    }
}

/// Constructs a rich, miniaturized, interconnected open-world map of Tokyo
/// featuring 11 iconic, intensely immersive districts densely filled with buildings,
/// authentic street furniture, mailboxes, sidewalks, streetlamps, cars, trees, and dense Tokyo scenery.
class TokyoWorldNode: SKNode {
    
    let mapSize: CGSize
    private let groundLayer = SKNode()
    private let entityLayer = SKNode() // Contains sorted objects (buildings, trees, landmarks, props, player)
    
    // Sortable entities for 2.5D dynamic Y-depth
    private(set) var sortableEntities: [SKNode] = []
    
    // Moving vehicles across Tokyo's avenues
    private(set) var movingVehicles: [TokyoVehicleNode] = []
    
    // 11 Iconic Tokyo Districts
    let districts: [TokyoDistrict] = [
        TokyoDistrict(
            id: "shibuya",
            name: "SHIBUYA",
            japaneseName: "渋谷区",
            saveName: "Shibuya Crossing",
            bounds: CGRect(x: -1900, y: -650, width: 1200, height: 950),
            landmarkDescription: "Scramble Crossing & 109"
        ),
        TokyoDistrict(
            id: "harajuku",
            name: "HARAJUKU",
            japaneseName: "原宿・明治神宮",
            saveName: "Harajuku Takeshita St",
            bounds: CGRect(x: -1900, y: 350, width: 1200, height: 1350),
            landmarkDescription: "Takeshita St & Crepe Stands"
        ),
        TokyoDistrict(
            id: "roppongi",
            name: "ROPPONGI HILLS",
            japaneseName: "六本木ヒルズ",
            saveName: "Roppongi Hills Mori Tower",
            bounds: CGRect(x: -1900, y: -1700, width: 1200, height: 1050),
            landmarkDescription: "Mori Tower & Maman Spider"
        ),
        TokyoDistrict(
            id: "tokyoTower",
            name: "TOKYO TOWER",
            japaneseName: "東京タワー・芝",
            saveName: "Tokyo Tower & Shiba",
            bounds: CGRect(x: -700, y: -1700, width: 800, height: 1100),
            landmarkDescription: "Red Lattice Tower & Zojoji"
        ),
        TokyoDistrict(
            id: "imperial",
            name: "IMPERIAL PALACE",
            japaneseName: "皇居・千代田",
            saveName: "Imperial Palace (Chiyoda)",
            bounds: CGRect(x: -700, y: -200, width: 850, height: 900),
            landmarkDescription: "Stone Moat & Nijubashi"
        ),
        TokyoDistrict(
            id: "ginza",
            name: "GINZA",
            japaneseName: "銀座・和光時計塔",
            saveName: "Ginza 4-Chome",
            bounds: CGRect(x: 150, y: -950, width: 800, height: 850),
            landmarkDescription: "Wako Clock & Luxury Avenue"
        ),
        TokyoDistrict(
            id: "tsukiji",
            name: "TSUKIJI MARKET",
            japaneseName: "築地場外市場",
            saveName: "Tsukiji Outer Market",
            bounds: CGRect(x: 950, y: -1700, width: 950, height: 1150),
            landmarkDescription: "Fish Market & Tuna Auction"
        ),
        TokyoDistrict(
            id: "akihabara",
            name: "AKIHABARA",
            japaneseName: "秋葉原電気街",
            saveName: "Akihabara Electric Town",
            bounds: CGRect(x: 150, y: -100, width: 750, height: 800),
            landmarkDescription: "Radio Kaikan & Club Sega"
        ),
        TokyoDistrict(
            id: "ueno",
            name: "UENO PARK",
            japaneseName: "上野恩賜公園",
            saveName: "Ueno Park & Pond",
            bounds: CGRect(x: -700, y: 700, width: 1500, height: 1000),
            landmarkDescription: "Lotus Pond & Natl Museum"
        ),
        TokyoDistrict(
            id: "asakusa",
            name: "ASAKUSA SENSO-JI",
            japaneseName: "浅草・雷門",
            saveName: "Senso-ji Temple Asakusa",
            bounds: CGRect(x: 800, y: 700, width: 1100, height: 1000),
            landmarkDescription: "Kaminarimon & 5-Story Pagoda"
        ),
        TokyoDistrict(
            id: "skytree",
            name: "TOKYO SKYTREE",
            japaneseName: "東京スカイツリー",
            saveName: "Tokyo Skytree & Sumida",
            bounds: CGRect(x: 950, y: -250, width: 950, height: 950),
            landmarkDescription: "Futuristic Spire & Waterfront"
        )
    ]
    
    init(mapSize: CGSize = CGSize(width: 3800, height: 3400)) {
        self.mapSize = mapSize
        super.init()
        
        groundLayer.zPosition = -1000.0
        entityLayer.zPosition = 0.0
        addChild(groundLayer)
        addChild(entityLayer)
        
        buildGroundAndWaterways()
        buildRoadsAndCrosswalks()
        buildSidewalksAndInfrastructure()
        buildDistrictEnsembles()
        buildTrafficSystem()
        buildWorldBoundaries()
        setupSakuraPetalAnimation()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addPlayerToWorld(_ player: PlayerNode) {
        entityLayer.addChild(player)
        sortableEntities.append(player)
    }
    
    // MARK: - Dynamic 2.5D Depth Sorting
    
    func updateDepthSorting() {
        for entity in sortableEntities {
            entity.zPosition = 5000.0 - entity.position.y
        }
    }
    
    // MARK: - Vehicle Simulation Update
    
    func updateVehicles(dt: TimeInterval) {
        for vehicle in movingVehicles {
            vehicle.update(dt: dt)
        }
    }
    
    // MARK: - District Detection
    
    func district(at point: CGPoint) -> TokyoDistrict {
        for d in districts {
            if d.bounds.contains(point) {
                return d
            }
        }
        return TokyoDistrict(
            id: "tokyo",
            name: "TOKYO METROPOLIS",
            japaneseName: "東京都",
            saveName: "Tokyo Metropolis",
            bounds: CGRect(x: -mapSize.width/2, y: -mapSize.height/2, width: mapSize.width, height: mapSize.height),
            landmarkDescription: "Metropolitan Area"
        )
    }
    
    // MARK: - 1. Ground, Waterways & Riverfronts
    
    private func buildGroundAndWaterways() {
        // Base Pavement Ground (Light gray urban concrete)
        let ground = SKShapeNode(rectOf: mapSize)
        ground.fillColor = SKColor(red: 0.82, green: 0.83, blue: 0.85, alpha: 1.0)
        ground.strokeColor = .clear
        ground.zPosition = -100.0
        groundLayer.addChild(ground)
        
        // Sumida River (East of Akihabara/Ginza, West of Skytree)
        let riverW: CGFloat = 170.0
        let river = SKShapeNode(rectOf: CGSize(width: riverW, height: mapSize.height))
        river.fillColor = SKColor(red: 0.20, green: 0.50, blue: 0.75, alpha: 1.0) // Sumida Blue
        river.strokeColor = SKColor(red: 0.15, green: 0.40, blue: 0.65, alpha: 1.0)
        river.lineWidth = 3.0
        river.position = CGPoint(x: 950, y: 0)
        river.zPosition = -95.0
        groundLayer.addChild(river)
        
        // River water ripples
        for i in -14...14 {
            let ripple = SKShapeNode(rectOf: CGSize(width: 80, height: 4), cornerRadius: 2)
            ripple.fillColor = SKColor(white: 1.0, alpha: 0.25)
            ripple.strokeColor = .clear
            ripple.position = CGPoint(x: 950 + CGFloat((i % 3) * 20 - 20), y: CGFloat(i) * 110)
            ripple.zPosition = -94.0
            groundLayer.addChild(ripple)
        }
        
        // Imperial Palace Moat (Water loop encircling Chiyoda palace grounds)
        let moatRect = CGRect(x: -650, y: -150, width: 750, height: 750)
        let moatWater = SKShapeNode(rect: moatRect, cornerRadius: 36)
        moatWater.fillColor = SKColor(red: 0.25, green: 0.55, blue: 0.65, alpha: 1.0)
        moatWater.strokeColor = SKColor(red: 0.35, green: 0.38, blue: 0.40, alpha: 1.0)
        moatWater.lineWidth = 14.0
        moatWater.zPosition = -95.0
        groundLayer.addChild(moatWater)
        
        // Imperial Palace Inner Island
        let islandRect = CGRect(x: -580, y: -80, width: 610, height: 610)
        let island = SKShapeNode(rect: islandRect, cornerRadius: 24)
        island.fillColor = SKColor(red: 0.72, green: 0.80, blue: 0.70, alpha: 1.0)
        island.strokeColor = SKColor(red: 0.38, green: 0.40, blue: 0.42, alpha: 1.0)
        island.lineWidth = 6.0
        island.zPosition = -94.0
        groundLayer.addChild(island)
        
        // Ueno Shinobazu Lotus Pond
        let pond = SKShapeNode(ellipseOf: CGSize(width: 320, height: 220))
        pond.fillColor = SKColor(red: 0.22, green: 0.58, blue: 0.62, alpha: 1.0)
        pond.strokeColor = SKColor(red: 0.40, green: 0.60, blue: 0.40, alpha: 1.0)
        pond.lineWidth = 4.0
        pond.position = CGPoint(x: -120, y: 1220)
        pond.zPosition = -95.0
        groundLayer.addChild(pond)
        
        // Lotus leaf pads
        for i in 0..<8 {
            let angle = CGFloat(i) * (CGFloat.pi * 2 / 8.0)
            let pad = SKShapeNode(circleOfRadius: 12)
            pad.fillColor = SKColor(red: 0.25, green: 0.68, blue: 0.35, alpha: 0.9)
            pad.strokeColor = .clear
            pad.position = CGPoint(x: -120 + cos(angle) * 80, y: 1220 + sin(angle) * 55)
            pad.zPosition = -94.0
            groundLayer.addChild(pad)
        }
    }
    
    // MARK: - 2. Connecting Roads, Avenues & Bridges
    
    private func buildRoadsAndCrosswalks() {
        let asphalt = SKColor(red: 0.20, green: 0.22, blue: 0.25, alpha: 1.0)
        
        // Main East-West Tokyo Boulevard
        let mainEWBoulevard = SKShapeNode(rectOf: CGSize(width: mapSize.width, height: 160))
        mainEWBoulevard.fillColor = asphalt
        mainEWBoulevard.strokeColor = .clear
        mainEWBoulevard.position = CGPoint(x: 0, y: -450)
        mainEWBoulevard.zPosition = -90.0
        groundLayer.addChild(mainEWBoulevard)
        
        // Northern East-West Avenue
        let northEWAvenue = SKShapeNode(rectOf: CGSize(width: mapSize.width, height: 150))
        northEWAvenue.fillColor = asphalt
        northEWAvenue.strokeColor = .clear
        northEWAvenue.position = CGPoint(x: 0, y: 550)
        northEWAvenue.zPosition = -90.0
        groundLayer.addChild(northEWAvenue)
        
        // Western North-South Avenue (Yamanote West corridor)
        let westNSAvenue = SKShapeNode(rectOf: CGSize(width: 160, height: mapSize.height))
        westNSAvenue.fillColor = asphalt
        westNSAvenue.strokeColor = .clear
        westNSAvenue.position = CGPoint(x: -1250, y: 0)
        westNSAvenue.zPosition = -90.0
        groundLayer.addChild(westNSAvenue)
        
        // Central North-South Avenue (Tokyo Tower -> Ginza -> Akihabara -> Ueno)
        let centralNSAvenue = SKShapeNode(rectOf: CGSize(width: 150, height: mapSize.height))
        centralNSAvenue.fillColor = asphalt
        centralNSAvenue.strokeColor = .clear
        centralNSAvenue.position = CGPoint(x: 450, y: 0)
        centralNSAvenue.zPosition = -90.0
        groundLayer.addChild(centralNSAvenue)
        
        // Sumida River Bridges: Azuma Bridge & Kiyosu Bridge
        let azumaBridge = SKShapeNode(rectOf: CGSize(width: 220, height: 90), cornerRadius: 4)
        azumaBridge.fillColor = SKColor(red: 0.85, green: 0.20, blue: 0.16, alpha: 1.0)
        azumaBridge.strokeColor = .white
        azumaBridge.lineWidth = 2.0
        azumaBridge.position = CGPoint(x: 950, y: 550)
        azumaBridge.zPosition = -88.0
        groundLayer.addChild(azumaBridge)
        
        let southBridge = SKShapeNode(rectOf: CGSize(width: 220, height: 90), cornerRadius: 4)
        southBridge.fillColor = SKColor(red: 0.25, green: 0.40, blue: 0.55, alpha: 1.0)
        southBridge.strokeColor = .white
        southBridge.lineWidth = 2.0
        southBridge.position = CGPoint(x: 950, y: -450)
        southBridge.zPosition = -88.0
        groundLayer.addChild(southBridge)
        
        // Nijubashi Double Stone Bridge
        let nijubashiBridge = SKShapeNode(rectOf: CGSize(width: 90, height: 120), cornerRadius: 6)
        nijubashiBridge.fillColor = SKColor(red: 0.55, green: 0.56, blue: 0.58, alpha: 1.0)
        nijubashiBridge.strokeColor = SKColor(white: 0.25, alpha: 1.0)
        nijubashiBridge.lineWidth = 3.0
        nijubashiBridge.position = CGPoint(x: -280, y: -150)
        nijubashiBridge.zPosition = -88.0
        groundLayer.addChild(nijubashiBridge)
        
        // Shibuya Scramble Crossing
        buildShibuyaScrambleStripes(center: CGPoint(x: -1250, y: -450))
    }
    
    private func buildShibuyaScrambleStripes(center: CGPoint) {
        let stripeW: CGFloat = 8.0
        let stripeH: CGFloat = 55.0
        let white = SKColor(white: 0.95, alpha: 1.0)
        
        for i in -5...5 {
            let sN = SKShapeNode(rectOf: CGSize(width: stripeW, height: stripeH), cornerRadius: 1)
            sN.fillColor = white
            sN.strokeColor = .clear
            sN.position = CGPoint(x: center.x + CGFloat(i) * 16, y: center.y + 110)
            sN.zPosition = -89.0
            groundLayer.addChild(sN)
            
            let sS = SKShapeNode(rectOf: CGSize(width: stripeW, height: stripeH), cornerRadius: 1)
            sS.fillColor = white
            sS.strokeColor = .clear
            sS.position = CGPoint(x: center.x + CGFloat(i) * 16, y: center.y - 110)
            sS.zPosition = -89.0
            groundLayer.addChild(sS)
        }
        
        for i in -4...4 {
            let sD1 = SKShapeNode(rectOf: CGSize(width: stripeW, height: 42), cornerRadius: 1)
            sD1.fillColor = white
            sD1.strokeColor = .clear
            sD1.position = CGPoint(x: center.x + CGFloat(i) * 18, y: center.y + CGFloat(i) * 18)
            sD1.zRotation = 0.78
            sD1.zPosition = -89.0
            groundLayer.addChild(sD1)
            
            let sD2 = SKShapeNode(rectOf: CGSize(width: stripeW, height: 42), cornerRadius: 1)
            sD2.fillColor = white
            sD2.strokeColor = .clear
            sD2.position = CGPoint(x: center.x + CGFloat(i) * 18, y: center.y - CGFloat(i) * 18)
            sD2.zRotation = -0.78
            sD2.zPosition = -89.0
            groundLayer.addChild(sD2)
        }
    }
    
    // MARK: - 3. Continuous Avenue Sidewalks & Thoroughfare Streetlamps
    
    private func buildSidewalksAndInfrastructure() {
        // Continuous streetlamps along Main East-West Boulevard (every 130 pt)
        var xLamp: CGFloat = -1800
        while xLamp <= 1800 {
            // Avoid river zone around x = 950
            if abs(xLamp - 950) > 130 {
                let lampNorth = TokyoStreetLampNode(style: (xLamp > 200 && xLamp < 800) ? .ginza : .modern)
                lampNorth.position = CGPoint(x: xLamp, y: -355)
                addEntity(lampNorth)
                
                let lampSouth = TokyoStreetLampNode(style: (xLamp > 200 && xLamp < 800) ? .ginza : .modern)
                lampSouth.position = CGPoint(x: xLamp, y: -545)
                addEntity(lampSouth)
            }
            xLamp += 130
        }
        
        // Continuous streetlamps along Northern East-West Avenue (every 140 pt)
        xLamp = -1800
        while xLamp <= 1800 {
            if abs(xLamp - 950) > 130 {
                let style: TokyoStreetLampNode.LampStyle = (xLamp > 200 && xLamp < 800) ? .akiba : ((xLamp > 800) ? .traditional : .modern)
                let lampNorth = TokyoStreetLampNode(style: style)
                lampNorth.position = CGPoint(x: xLamp, y: 640)
                addEntity(lampNorth)
                
                let lampSouth = TokyoStreetLampNode(style: style)
                lampSouth.position = CGPoint(x: xLamp, y: 460)
                addEntity(lampSouth)
            }
            xLamp += 140
        }
        
        // Continuous guard rails along boulevard sidewalks
        for xRail in stride(from: -1750, through: 1750, by: 70) {
            if abs(CGFloat(xRail) - 950) > 120 && abs(CGFloat(xRail) - (-1250)) > 90 && abs(CGFloat(xRail) - 450) > 80 {
                let rail = GuardRailNode()
                rail.position = CGPoint(x: CGFloat(xRail), y: -360)
                addEntity(rail)
            }
        }
        
        // Fire hydrants every 380 pt along main roads
        for xHydrant in stride(from: -1600, through: 1600, by: 380) {
            if abs(CGFloat(xHydrant) - 950) > 120 {
                let hydrant = FireHydrantNode()
                hydrant.position = CGPoint(x: CGFloat(xHydrant), y: -362)
                addEntity(hydrant)
            }
        }
        
        // Shibuya Sidewalk Paving Tiles with Yellow Tactile Paving
        let shibuyaSidewalk = SKSpriteNode(imageNamed: "scenery_sidewalk_shibuya")
        shibuyaSidewalk.size = CGSize(width: 380, height: 160)
        shibuyaSidewalk.position = CGPoint(x: -1250, y: -290)
        shibuyaSidewalk.zPosition = -92.0
        groundLayer.addChild(shibuyaSidewalk)
        
        // Tactile Tenji braille guide tiles at Shibuya Scramble
        for i in -3...3 {
            let tactile = SKSpriteNode(imageNamed: "scenery_tactile_paving")
            tactile.size = CGSize(width: 40, height: 40)
            tactile.position = CGPoint(x: -1250 + CGFloat(i) * 44, y: -345)
            tactile.zPosition = -91.0
            groundLayer.addChild(tactile)
        }
        
        // Ginza Polished Dark Granite Paving
        let ginzaSidewalk = SKSpriteNode(imageNamed: "scenery_sidewalk_ginza")
        ginzaSidewalk.size = CGSize(width: 460, height: 180)
        ginzaSidewalk.position = CGPoint(x: 520, y: -330)
        ginzaSidewalk.zPosition = -92.0
        groundLayer.addChild(ginzaSidewalk)
        
        // Asakusa Stone Flagstones
        let asakusaSidewalk = SKSpriteNode(imageNamed: "scenery_sidewalk_asakusa")
        asakusaSidewalk.size = CGSize(width: 420, height: 200)
        asakusaSidewalk.position = CGPoint(x: 1350, y: 920)
        asakusaSidewalk.zPosition = -92.0
        groundLayer.addChild(asakusaSidewalk)
    }
    
    // MARK: - 4. Dynamic Moving Traffic System
    
    private func buildTrafficSystem() {
        // Main East-West Boulevard Westbound Lane (y = -400)
        let speeds: [CGFloat] = [115, 95, 120, 100, 110, 105]
        let typesWB: [TokyoVehicleNode.VehicleType] = [.taxiGreen, .compactYellow, .taxiBlack, .keiTruck, .sedanSilver, .deliveryVan]
        for i in 0..<6 {
            let veh = TokyoVehicleNode(type: typesWB[i], isMoving: true, speed: speeds[i], direction: -1.0)
            veh.position = CGPoint(x: -1600 + CGFloat(i) * 600, y: -400)
            veh.moveBounds = (-1900, 1900)
            addVehicle(veh)
        }
        
        // Main East-West Boulevard Eastbound Lane (y = -500)
        let typesEB: [TokyoVehicleNode.VehicleType] = [.taxiBlack, .deliveryVan, .taxiGreen, .compactYellow, .keiTruck, .sedanSilver]
        for i in 0..<6 {
            let veh = TokyoVehicleNode(type: typesEB[i], isMoving: true, speed: speeds[i] * 0.95, direction: 1.0)
            veh.position = CGPoint(x: -1400 + CGFloat(i) * 580, y: -500)
            veh.moveBounds = (-1900, 1900)
            addVehicle(veh)
        }
        
        // Northern Avenue Eastbound Lane (y = 520)
        let vehNorth1 = TokyoVehicleNode(type: .taxiGreen, isMoving: true, speed: 105, direction: 1.0)
        vehNorth1.position = CGPoint(x: -1000, y: 520)
        vehNorth1.moveBounds = (-1900, 1900)
        addVehicle(vehNorth1)
        
        let vehNorth2 = TokyoVehicleNode(type: .keiTruck, isMoving: true, speed: 95, direction: 1.0)
        vehNorth2.position = CGPoint(x: 200, y: 520)
        vehNorth2.moveBounds = (-1900, 1900)
        addVehicle(vehNorth2)
    }
    
    private func addVehicle(_ vehicle: TokyoVehicleNode) {
        entityLayer.addChild(vehicle)
        sortableEntities.append(vehicle)
        if vehicle.isMoving {
            movingVehicles.append(vehicle)
        }
    }
    
    // MARK: - 5. 11 Dense, Distinct, Immersive Tokyo Districts
    
    private func buildDistrictEnsembles() {
        buildShibuyaDistrict()
        buildHarajukuDistrict()
        buildImperialPalaceDistrict()
        buildTokyoTowerDistrict()
        buildRoppongiHillsDistrict()
        buildGinzaDistrict()
        buildTsukijiDistrict()
        buildAkihabaraDistrict()
        buildUenoParkDistrict()
        buildAsakusaSensojiDistrict()
        buildTokyoSkytreeDistrict()
    }
    
    // 1. Shibuya District (Dense Neon Skyscraper Hub)
    private func buildShibuyaDistrict() {
        let center = CGPoint(x: -1250, y: -200)
        
        // Monumental Shibuya 109 (260x320)
        let s109 = Shibuya109LandmarkNode()
        s109.position = CGPoint(x: center.x - 160, y: center.y + 40)
        addEntity(s109)
        
        // Hachiko Bronze Dog Statue in station plaza
        let hachiko = HachikoStatueNode()
        hachiko.position = CGPoint(x: center.x + 90, y: center.y - 120)
        addEntity(hachiko)
        
        // Dense Highrise Skyline Blocks
        let highrises = [
            CGPoint(x: center.x - 440, y: center.y + 160),
            CGPoint(x: center.x - 160, y: center.y + 260),
            CGPoint(x: center.x + 180, y: center.y + 160),
            CGPoint(x: center.x + 440, y: center.y + 160),
            CGPoint(x: center.x + 440, y: center.y - 80)
        ]
        for pos in highrises {
            let hr = BuildingNode(type: .tokyoHighRise, size: CGSize(width: 240, height: 220))
            hr.position = pos
            addEntity(hr)
        }
        
        // Storefront Blocks (Konbini, Ramen, Cafes, Arcades)
        let stores: [(BuildingType, CGSize, CGPoint)] = [
            (.konbini, CGSize(width: 220, height: 160), CGPoint(x: center.x - 440, y: center.y - 80)),
            (.ramenShop, CGSize(width: 190, height: 140), CGPoint(x: center.x - 240, y: center.y - 80)),
            (.cafe, CGSize(width: 200, height: 150), CGPoint(x: center.x + 240, y: center.y - 80)),
            (.arcade, CGSize(width: 200, height: 170), CGPoint(x: center.x + 440, y: center.y + 280)),
            (.konbini, CGSize(width: 220, height: 160), CGPoint(x: center.x - 440, y: center.y + 280))
        ]
        for (bType, bSize, bPos) in stores {
            let bld = BuildingNode(type: bType, size: bSize)
            bld.position = bPos
            addEntity(bld)
        }
        
        // Tokyo Metro Entrance Stairwells
        let metro1 = MetroEntranceNode()
        metro1.position = CGPoint(x: center.x - 80, y: center.y - 140)
        addEntity(metro1)
        
        let metro2 = MetroEntranceNode()
        metro2.position = CGPoint(x: center.x + 280, y: center.y - 140)
        addEntity(metro2)
        
        // Vending Machine Pairs & Combini Bins
        let vendingSpots = [
            CGPoint(x: center.x - 340, y: center.y - 110),
            CGPoint(x: center.x - 120, y: center.y - 110),
            CGPoint(x: center.x + 180, y: center.y - 110),
            CGPoint(x: center.x + 360, y: center.y - 110)
        ]
        for pos in vendingSpots {
            let vmR = VendingMachineNode(type: .red)
            vmR.position = pos
            addEntity(vmR)
            
            let vmB = VendingMachineNode(type: .blue)
            vmB.position = CGPoint(x: pos.x + 36, y: pos.y)
            addEntity(vmB)
            
            let bins = CombiniBinsNode()
            bins.position = CGPoint(x: pos.x + 76, y: pos.y)
            addEntity(bins)
        }
        
        // Japanese Post Boxes
        let postBox1 = JapanesePostBoxNode(type: .standard)
        postBox1.position = CGPoint(x: center.x + 140, y: center.y - 120)
        addEntity(postBox1)
        
        let postBox2 = JapanesePostBoxNode(type: .retro)
        postBox2.position = CGPoint(x: center.x - 220, y: center.y - 120)
        addEntity(postBox2)
        
        // Traffic Lights at Scramble Crossing
        for xOffset in [-140, 140] {
            for yOffset in [-210, -340] {
                let tl = TrafficLightNode()
                tl.position = CGPoint(x: center.x + CGFloat(xOffset), y: CGFloat(yOffset))
                addEntity(tl)
            }
        }
        
        // Parked Bicycles & Delivery Scooters
        for i in 0..<5 {
            let bike = BicycleNode()
            bike.position = CGPoint(x: center.x - 500 + CGFloat(i) * 35, y: center.y - 160)
            addEntity(bike)
        }
        for i in 0..<3 {
            let sc = ScooterNode()
            sc.position = CGPoint(x: center.x + 130 + CGFloat(i) * 38, y: center.y - 160)
            addEntity(sc)
        }
        
        // Potted Bonsai Planters lining storefronts
        for xOffset in [-470, -380, -210, 210, 310, 420] {
            let bonsai = BonsaiPlanterNode()
            bonsai.position = CGPoint(x: center.x + CGFloat(xOffset), y: center.y - 65)
            addEntity(bonsai)
        }
        
        // Bus Stops & Phonebooths
        let busStop = BusStopNode()
        busStop.position = CGPoint(x: center.x + 320, y: center.y - 140)
        addEntity(busStop)
        
        let phone = PhoneBoothNode()
        phone.position = CGPoint(x: center.x - 30, y: center.y - 120)
        addEntity(phone)
        
        // Additional Dense Scenery & Street Furniture
        let vmHot = VendingMachineNode(type: .hot)
        vmHot.position = CGPoint(x: center.x + 40, y: center.y - 110)
        addEntity(vmHot)
        
        let gachaBank = GachaponRowNode()
        gachaBank.position = CGPoint(x: center.x - 170, y: center.y - 110)
        addEntity(gachaBank)
        
        let ramenYatai = RamenYataiNode()
        ramenYatai.position = CGPoint(x: center.x + 260, y: center.y - 110)
        addEntity(ramenYatai)
        
        let taxiGreen = TokyoVehicleNode(type: .taxiGreen, isMoving: false)
        taxiGreen.position = CGPoint(x: center.x - 350, y: center.y + 80)
        addEntity(taxiGreen)
        
        let yellowKei = TokyoVehicleNode(type: .compactYellow, isMoving: false)
        yellowKei.position = CGPoint(x: center.x - 350, y: center.y - 160)
        addEntity(yellowKei)
        
        // Pedestrian Guard Rails along Shibuya Scramble crossing corners
        for xOff in [-160, -80, 80, 160] {
            let rail = GuardRailNode()
            rail.position = CGPoint(x: center.x + CGFloat(xOff), y: center.y - 200)
            addEntity(rail)
        }
        
        // Red Chochin Lanterns outside Ramen Shop
        for xOff in [-260, -220] {
            let lantern = ChochinLanternNode()
            lantern.position = CGPoint(x: center.x + CGFloat(xOff), y: center.y - 45)
            addEntity(lantern)
        }
    }
    
    // 2. Harajuku District (Takeshita Street & Meiji Shrine Sacred Forest)
    private func buildHarajukuDistrict() {
        let center = CGPoint(x: -1250, y: 950)
        
        // Takeshita Street Grand Neon Entrance Arch (260x180)
        let arch = TakeshitaArchNode()
        arch.position = CGPoint(x: center.x, y: center.y - 160)
        addEntity(arch)
        
        // Marion Crepe Stand (150x130)
        let crepe = HarajukuCrepeStandNode()
        crepe.position = CGPoint(x: center.x - 140, y: center.y - 30)
        addEntity(crepe)
        
        // Dense Boutique & Fashion Storefronts flanking Takeshita Street
        let boutiqueSpots: [CGPoint] = [
            CGPoint(x: center.x + 140, y: center.y - 30),
            CGPoint(x: center.x - 140, y: center.y + 120),
            CGPoint(x: center.x + 140, y: center.y + 120),
            CGPoint(x: center.x - 140, y: center.y + 270),
            CGPoint(x: center.x + 140, y: center.y + 270)
        ]
        for (idx, pos) in boutiqueSpots.enumerated() {
            let bType: BuildingType = (idx % 2 == 0) ? .cafe : .akibaShop
            let bld = BuildingNode(type: bType, size: CGSize(width: 200, height: 150))
            bld.position = pos
            addEntity(bld)
        }
        
        // Cute Pink Rabbit Construction Barriers lining Takeshita Walkway
        for yOffset in [-120, 0, 120, 240] {
            let bunny = ConstructionBarrierNode(type: .rabbit)
            bunny.position = CGPoint(x: center.x - 45, y: center.y + CGFloat(yOffset))
            addEntity(bunny)
            
            let bonsai = BonsaiPlanterNode()
            bonsai.position = CGPoint(x: center.x + 45, y: center.y + CGFloat(yOffset))
            addEntity(bonsai)
        }
        
        // Meiji Jingu Sacred Precinct: Torii Gate (130x110)
        let torii = ToriiGateNode()
        torii.position = CGPoint(x: center.x - 360, y: center.y + 160)
        addEntity(torii)
        
        // Traditional Shrine Hall in Forest
        let shrineHall = BuildingNode(type: .shrinePavilion, size: CGSize(width: 220, height: 160))
        shrineHall.position = CGPoint(x: center.x - 500, y: center.y + 360)
        addEntity(shrineHall)
        
        // Stone Toro Lanterns lining shrine approach
        for i in 0..<5 {
            let toro = StoneLanternNode()
            toro.position = CGPoint(x: center.x - 400 + CGFloat(i) * 35, y: center.y + 260)
            addEntity(toro)
        }
        
        // Massive Dense Forest (Sakura, Ginkgo, Imperial Pine)
        let forest: [(TokyoTreeNode.TreeType, CGPoint)] = [
            (.sakuraBlossom, CGPoint(x: center.x - 550, y: center.y + 200)),
            (.pine, CGPoint(x: center.x - 480, y: center.y + 240)),
            (.sakuraBlossom, CGPoint(x: center.x - 380, y: center.y + 350)),
            (.pine, CGPoint(x: center.x - 280, y: center.y + 380)),
            (.ginkgo, CGPoint(x: center.x - 520, y: center.y + 480)),
            (.pine, CGPoint(x: center.x - 380, y: center.y + 500)),
            (.sakuraBlossom, CGPoint(x: center.x + 280, y: center.y + 120)),
            (.pine, CGPoint(x: center.x + 350, y: center.y + 220)),
            (.ginkgo, CGPoint(x: center.x + 260, y: center.y + 340)),
            (.sakuraBlossom, CGPoint(x: center.x + 360, y: center.y + 380)),
            (.pine, CGPoint(x: center.x + 450, y: center.y + 260))
        ]
        for (tType, pos) in forest {
            let tree = TokyoTreeNode(type: tType, radius: 36)
            tree.position = pos
            addEntity(tree)
        }
        
        // Street Furniture
        let post = JapanesePostBoxNode(type: .standard)
        post.position = CGPoint(x: center.x + 60, y: center.y - 120)
        addEntity(post)
        
        let vm = VendingMachineNode(type: .blue)
        vm.position = CGPoint(x: center.x - 220, y: center.y - 120)
        addEntity(vm)
        
        // Parked Scooters
        for i in 0..<3 {
            let sc = ScooterNode()
            sc.position = CGPoint(x: center.x + 140 + CGFloat(i) * 35, y: center.y - 110)
            addEntity(sc)
        }
        
        // Additional Dense Scenery (Food carts, benches, barriers, lanterns)
        let takoStall = TakoyakiStallNode()
        takoStall.position = CGPoint(x: center.x - 90, y: center.y - 60)
        addEntity(takoStall)
        
        let gacha = GachaponRowNode()
        gacha.position = CGPoint(x: center.x + 90, y: center.y - 60)
        addEntity(gacha)
        
        let vmHot = VendingMachineNode(type: .hot)
        vmHot.position = CGPoint(x: center.x - 360, y: center.y + 240)
        addEntity(vmHot)
        
        let retroPost = JapanesePostBoxNode(type: .retro)
        retroPost.position = CGPoint(x: center.x - 180, y: center.y - 120)
        addEntity(retroPost)
        
        let phone = PhoneBoothNode()
        phone.position = CGPoint(x: center.x + 180, y: center.y - 120)
        addEntity(phone)
        
        // Additional Meiji Forest Sacred Trees & Lanterns
        for xOff in [-440, -320] {
            let sakura = TokyoTreeNode(type: .sakuraBlossom, radius: 38)
            sakura.position = CGPoint(x: center.x + CGFloat(xOff), y: center.y + 100)
            addEntity(sakura)
            
            let toro = StoneLanternNode()
            toro.position = CGPoint(x: center.x + CGFloat(xOff), y: center.y + 50)
            addEntity(toro)
        }
        
        // Extra Bicycles parked near entrance
        for i in 0..<3 {
            let bike = BicycleNode()
            bike.position = CGPoint(x: center.x - 280 + CGFloat(i) * 35, y: center.y - 120)
            addEntity(bike)
        }
    }
    
    // 3. Roppongi Hills District (Cosmopolitan Highrise City)
    private func buildRoppongiHillsDistrict() {
        let center = CGPoint(x: -1250, y: -1100)
        
        // Mori Tower Skyscraper (300x420)
        let mori = MoriTowerLandmarkNode()
        mori.position = CGPoint(x: center.x - 100, y: center.y + 60)
        addEntity(mori)
        
        // Maman Giant Bronze Spider Sculpture (200x180)
        let spider = MamanSpiderSculptureNode()
        spider.position = CGPoint(x: center.x + 140, y: center.y - 50)
        addEntity(spider)
        
        // Highrise Towers & Luxury Complexes
        let towers: [CGPoint] = [
            CGPoint(x: center.x - 400, y: center.y + 80),
            CGPoint(x: center.x + 360, y: center.y + 80),
            CGPoint(x: center.x - 400, y: center.y - 100),
            CGPoint(x: center.x + 360, y: center.y - 100),
            CGPoint(x: center.x - 100, y: center.y + 360)
        ]
        for pos in towers {
            let hr = BuildingNode(type: .tokyoHighRise, size: CGSize(width: 240, height: 220))
            hr.position = pos
            addEntity(hr)
        }
        
        // Luxury Boutiques & Cafes
        let b1 = BuildingNode(type: .ginzaBoutique, size: CGSize(width: 210, height: 160))
        b1.position = CGPoint(x: center.x - 260, y: center.y - 120)
        addEntity(b1)
        
        let b2 = BuildingNode(type: .cafe, size: CGSize(width: 200, height: 150))
        b2.position = CGPoint(x: center.x + 220, y: center.y - 120)
        addEntity(b2)
        
        // Metro Entrance
        let metro = MetroEntranceNode()
        metro.position = CGPoint(x: center.x - 120, y: center.y - 120)
        addEntity(metro)
        
        // Modern streetlamps
        for xOffset in [-300, -180, 0, 180, 300] {
            let lamp = TokyoStreetLampNode(style: .modern)
            lamp.position = CGPoint(x: center.x + CGFloat(xOffset), y: center.y - 80)
            addEntity(lamp)
        }
        
        // Vending Machine & Phonebooth
        let vm = VendingMachineNode(type: .hot)
        vm.position = CGPoint(x: center.x + 40, y: center.y - 110)
        addEntity(vm)
        
        let phone = PhoneBoothNode()
        phone.position = CGPoint(x: center.x - 60, y: center.y - 110)
        addEntity(phone)
        
        // Parked Black Executive Taxis
        let parkedTaxi1 = TokyoVehicleNode(type: .taxiBlack, isMoving: false)
        parkedTaxi1.position = CGPoint(x: center.x - 200, y: center.y - 140)
        addEntity(parkedTaxi1)
        
        let parkedSedan = TokyoVehicleNode(type: .sedanSilver, isMoving: false)
        parkedSedan.position = CGPoint(x: center.x + 100, y: center.y - 140)
        addEntity(parkedSedan)
        
        // Additional Roppongi Plaza Scenery & Luxury Vehicles
        let vmBlue = VendingMachineNode(type: .blue)
        vmBlue.position = CGPoint(x: center.x + 60, y: center.y - 80)
        addEntity(vmBlue)
        
        let bins = CombiniBinsNode()
        bins.position = CGPoint(x: center.x + 100, y: center.y - 80)
        addEntity(bins)
        
        let deliveryVan = TokyoVehicleNode(type: .deliveryVan, isMoving: false)
        deliveryVan.position = CGPoint(x: center.x - 180, y: center.y - 80)
        addEntity(deliveryVan)
        
        let extraTaxi = TokyoVehicleNode(type: .taxiBlack, isMoving: false)
        extraTaxi.position = CGPoint(x: center.x + 240, y: center.y - 140)
        addEntity(extraTaxi)
        
        // Pedestrian Guard Rails along Roppongi Dori
        for xOff in [-240, -120, 120, 240] {
            let rail = GuardRailNode()
            rail.position = CGPoint(x: center.x + CGFloat(xOff), y: center.y - 180)
            addEntity(rail)
        }
        
        // Manicured Planters & Trees
        for xOff in [-320, 320] {
            let tree = TokyoTreeNode(type: .greenPark, radius: 34)
            tree.position = CGPoint(x: center.x + CGFloat(xOff), y: center.y - 40)
            addEntity(tree)
        }
    }
    
    // 4. Tokyo Tower & Shiba District (Iconic Steel Tower & Zojoji Temple)
    private func buildTokyoTowerDistrict() {
        let center = CGPoint(x: -300, y: -1100)
        
        // Colossal Tokyo Tower (320x520)
        let tower = TokyoTowerLandmarkNode()
        tower.position = CGPoint(x: center.x, y: center.y + 40)
        addEntity(tower)
        
        // Zojoji Temple Wooden Pavilion Halls
        let zojoji1 = BuildingNode(type: .shrinePavilion, size: CGSize(width: 220, height: 160))
        zojoji1.position = CGPoint(x: center.x - 280, y: center.y - 120)
        addEntity(zojoji1)
        
        let zojoji2 = BuildingNode(type: .shrinePavilion, size: CGSize(width: 220, height: 160))
        zojoji2.position = CGPoint(x: center.x - 280, y: center.y + 100)
        addEntity(zojoji2)
        
        // Traditional Ramen Shops & Cafes
        let ramen1 = BuildingNode(type: .ramenShop, size: CGSize(width: 190, height: 140))
        ramen1.position = CGPoint(x: center.x + 280, y: center.y - 120)
        addEntity(ramen1)
        
        let cafe1 = BuildingNode(type: .cafe, size: CGSize(width: 200, height: 150))
        cafe1.position = CGPoint(x: center.x + 280, y: center.y + 100)
        addEntity(cafe1)
        
        // Shiba Park Ginkgo & Sakura Avenue
        let trees: [(TokyoTreeNode.TreeType, CGPoint)] = [
            (.ginkgo, CGPoint(x: center.x - 180, y: center.y - 30)),
            (.ginkgo, CGPoint(x: center.x - 180, y: center.y + 180)),
            (.ginkgo, CGPoint(x: center.x + 180, y: center.y - 30)),
            (.ginkgo, CGPoint(x: center.x + 180, y: center.y + 180)),
            (.sakuraBlossom, CGPoint(x: center.x - 380, y: center.y - 20)),
            (.sakuraBlossom, CGPoint(x: center.x + 380, y: center.y - 20)),
            (.pine, CGPoint(x: center.x - 180, y: center.y + 290)),
            (.pine, CGPoint(x: center.x + 180, y: center.y + 290))
        ]
        for (tType, pos) in trees {
            let tree = TokyoTreeNode(type: tType, radius: 36)
            tree.position = pos
            addEntity(tree)
        }
        
        // Traditional streetlamps & lanterns
        for xOffset in [-200, -80, 80, 200] {
            let lamp = TokyoStreetLampNode(style: .traditional)
            lamp.position = CGPoint(x: center.x + CGFloat(xOffset), y: center.y - 120)
            addEntity(lamp)
        }
        
        // Retro round red post box
        let marupost = JapanesePostBoxNode(type: .retro)
        marupost.position = CGPoint(x: center.x - 120, y: center.y - 120)
        addEntity(marupost)
        
        // Street Ramen Yatai
        let yatai = RamenYataiNode()
        yatai.position = CGPoint(x: center.x + 120, y: center.y - 120)
        addEntity(yatai)
        
        // Vending Machine
        let vm = VendingMachineNode(type: .red)
        vm.position = CGPoint(x: center.x + 180, y: center.y - 120)
        addEntity(vm)
        
        // Additional Tokyo Tower & Zojoji Scenery
        let takoStall = TakoyakiStallNode()
        takoStall.position = CGPoint(x: center.x, y: center.y - 70)
        addEntity(takoStall)
        
        let vmBlue = VendingMachineNode(type: .blue)
        vmBlue.position = CGPoint(x: center.x + 140, y: center.y - 80)
        addEntity(vmBlue)
        
        let bins = CombiniBinsNode()
        bins.position = CGPoint(x: center.x + 180, y: center.y - 80)
        addEntity(bins)
        
        let phone = PhoneBoothNode()
        phone.position = CGPoint(x: center.x - 140, y: center.y - 80)
        addEntity(phone)
        
        // Hanging Red Lanterns near temple food stalls
        for xOff in [-40, 0, 40] {
            let ch = ChochinLanternNode()
            ch.position = CGPoint(x: center.x + CGFloat(xOff), y: center.y - 30)
            addEntity(ch)
        }
        
        // Stone Toro Lanterns around Zojoji
        for xOff in [-340, -220, 220, 340] {
            let toro = StoneLanternNode()
            toro.position = CGPoint(x: center.x + CGFloat(xOff), y: center.y - 80)
            addEntity(toro)
        }
        
        // Parked Bicycles & Delivery Scooter
        for i in 0..<3 {
            let bike = BicycleNode()
            bike.position = CGPoint(x: center.x - 220 + CGFloat(i) * 35, y: center.y - 140)
            addEntity(bike)
        }
        let sc = ScooterNode()
        sc.position = CGPoint(x: center.x + 240, y: center.y - 140)
        addEntity(sc)
    }
    
    // 5. Imperial Palace District (Ancient Castle Moat & Noble Pines)
    private func buildImperialPalaceDistrict() {
        let center = CGPoint(x: -280, y: 220)
        
        // Fujimi-yagura 3-Story Watchtower Keep (240x260)
        let watchtower = ImperialWatchtowerNode()
        watchtower.position = CGPoint(x: center.x, y: center.y + 90)
        addEntity(watchtower)
        
        // Traditional Palace Pavilion Halls
        let pav1 = BuildingNode(type: .shrinePavilion, size: CGSize(width: 220, height: 160))
        pav1.position = CGPoint(x: center.x - 200, y: center.y + 90)
        addEntity(pav1)
        
        let pav2 = BuildingNode(type: .shrinePavilion, size: CGSize(width: 220, height: 160))
        pav2.position = CGPoint(x: center.x + 200, y: center.y + 90)
        addEntity(pav2)
        
        // Stone Toro Lanterns along the approach
        let toroPositions = [
            CGPoint(x: center.x - 160, y: center.y - 40),
            CGPoint(x: center.x - 80, y: center.y - 40),
            CGPoint(x: center.x + 80, y: center.y - 40),
            CGPoint(x: center.x + 160, y: center.y - 40),
            CGPoint(x: center.x - 120, y: center.y + 40),
            CGPoint(x: center.x + 120, y: center.y + 40)
        ]
        for pos in toroPositions {
            let toro = StoneLanternNode()
            toro.position = pos
            addEntity(toro)
        }
        
        // Manicured Imperial Japanese Black Pines
        for xOffset in [-240, -160, -80, 80, 160, 240] {
            let pine = TokyoTreeNode(type: .pine, radius: 36)
            pine.position = CGPoint(x: center.x + CGFloat(xOffset), y: center.y + 220)
            addEntity(pine)
        }
        for xOffset in [-240, 240] {
            let pine = TokyoTreeNode(type: .pine, radius: 36)
            pine.position = CGPoint(x: center.x + CGFloat(xOffset), y: center.y - 30)
            addEntity(pine)
        }
        
        // Additional Imperial Grounds Traditional Scenery
        let torii = ToriiGateNode()
        torii.position = CGPoint(x: center.x, y: center.y - 40)
        addEntity(torii)
        
        let stoneToro1 = StoneLanternNode()
        stoneToro1.position = CGPoint(x: center.x + 70, y: center.y - 20)
        addEntity(stoneToro1)
        
        let stoneToro2 = StoneLanternNode()
        stoneToro2.position = CGPoint(x: center.x - 70, y: center.y - 20)
        addEntity(stoneToro2)
        
        // Extra Sacred Imperial Pines & Sakura Trees
        for xOff in [-320, -180, 180, 320] {
            let pine = TokyoTreeNode(type: .pine, radius: 38)
            pine.position = CGPoint(x: center.x + CGFloat(xOff), y: center.y + 140)
            addEntity(pine)
        }
        for xOff in [-280, 280] {
            let sakura = TokyoTreeNode(type: .sakuraBlossom, radius: 36)
            sakura.position = CGPoint(x: center.x + CGFloat(xOff), y: center.y - 80)
            addEntity(sakura)
        }
        
        // Potted Bonsai Planters along stone bridge
        for xOff in [-120, -40, 40, 120] {
            let bonsai = BonsaiPlanterNode()
            bonsai.position = CGPoint(x: center.x + CGFloat(xOff), y: center.y - 90)
            addEntity(bonsai)
        }
    }
    
    // 6. Ginza District (Ultra-Luxury Department Store Avenue)
    private func buildGinzaDistrict() {
        let center = CGPoint(x: 520, y: -550)
        
        // Wako Clock Tower (220x300)
        let wako = GinzaWakoClockNode()
        wako.position = CGPoint(x: center.x - 80, y: center.y + 90)
        addEntity(wako)
        
        // Mitsukoshi & Luxury Highrise Department Stores
        let deptStores: [(CGSize, CGPoint)] = [
            (CGSize(width: 240, height: 220), CGPoint(x: center.x + 180, y: center.y + 90)),
            (CGSize(width: 210, height: 160), CGPoint(x: center.x - 220, y: center.y - 120)),
            (CGSize(width: 210, height: 160), CGPoint(x: center.x + 40, y: center.y - 120)),
            (CGSize(width: 210, height: 160), CGPoint(x: center.x + 280, y: center.y - 120)),
            (CGSize(width: 240, height: 220), CGPoint(x: center.x - 300, y: center.y + 90))
        ]
        for (bSize, bPos) in deptStores {
            let bld = BuildingNode(type: .ginzaBoutique, size: bSize)
            bld.position = bPos
            addEntity(bld)
        }
        
        // Sidewalk Cafes
        let cafe = BuildingNode(type: .cafe, size: CGSize(width: 200, height: 150))
        cafe.position = CGPoint(x: center.x + 180, y: center.y + 260)
        addEntity(cafe)
        
        // Ornate European-Style Triple-Lantern Gas Lamps
        for xOffset in [-260, -140, -20, 100, 220, 320] {
            let lamp = TokyoStreetLampNode(style: .ginza)
            lamp.position = CGPoint(x: center.x + CGFloat(xOffset), y: center.y - 45)
            addEntity(lamp)
        }
        
        // Retro round red post boxes
        let post1 = JapanesePostBoxNode(type: .retro)
        post1.position = CGPoint(x: center.x - 70, y: center.y - 120)
        addEntity(post1)
        
        // Potted Bonsai Planters outside each boutique
        for xOffset in [-260, -180, 0, 80, 240, 320] {
            let pot = BonsaiPlanterNode()
            pot.position = CGPoint(x: center.x + CGFloat(xOffset), y: center.y - 70)
            addEntity(pot)
        }
        
        // Parked Black Executive Taxis & Silver Sedans
        let taxiBlack = TokyoVehicleNode(type: .taxiBlack, isMoving: false)
        taxiBlack.position = CGPoint(x: center.x - 120, y: center.y - 140)
        addEntity(taxiBlack)
        
        let sedanSilver = TokyoVehicleNode(type: .sedanSilver, isMoving: false)
        sedanSilver.position = CGPoint(x: center.x + 140, y: center.y - 140)
        addEntity(sedanSilver)
        
        // Additional Ginza Luxury Scenery & Street Furniture
        let metro = MetroEntranceNode()
        metro.position = CGPoint(x: center.x, y: center.y - 90)
        addEntity(metro)
        
        let phone = PhoneBoothNode()
        phone.position = CGPoint(x: center.x + 160, y: center.y - 90)
        addEntity(phone)
        
        let vmHot = VendingMachineNode(type: .hot)
        vmHot.position = CGPoint(x: center.x - 180, y: center.y - 90)
        addEntity(vmHot)
        
        let bins = CombiniBinsNode()
        bins.position = CGPoint(x: center.x - 140, y: center.y - 90)
        addEntity(bins)
        
        let busStop = BusStopNode()
        busStop.position = CGPoint(x: center.x + 220, y: center.y - 90)
        addEntity(busStop)
        
        // Additional Parked Luxury Vehicles
        let taxiGreen = TokyoVehicleNode(type: .taxiGreen, isMoving: false)
        taxiGreen.position = CGPoint(x: center.x - 240, y: center.y - 140)
        addEntity(taxiGreen)
        
        let blackTaxi2 = TokyoVehicleNode(type: .taxiBlack, isMoving: false)
        blackTaxi2.position = CGPoint(x: center.x + 260, y: center.y - 140)
        addEntity(blackTaxi2)
        
        // Pedestrian Guard Rails along 4-Chome
        for xOff in [-200, -80, 80, 200] {
            let rail = GuardRailNode()
            rail.position = CGPoint(x: center.x + CGFloat(xOff), y: center.y - 180)
            addEntity(rail)
        }
    }
    
    // 7. Tsukiji Outer Market District (Bustling Seafood Alleys)
    private func buildTsukijiDistrict() {
        let center = CGPoint(x: 1350, y: -1100)
        
        // Tsukiji Market Main Hall (320x220)
        let market = TsukijiMarketHallNode()
        market.position = CGPoint(x: center.x, y: center.y + 60)
        addEntity(market)
        
        // Multiple Sushi Bars & Ramen Eateries
        let seafoodStores: [(BuildingType, CGSize, CGPoint)] = [
            (.sushiBar, CGSize(width: 190, height: 140), CGPoint(x: center.x - 240, y: center.y - 110)),
            (.sushiBar, CGSize(width: 190, height: 140), CGPoint(x: center.x + 240, y: center.y - 110)),
            (.ramenShop, CGSize(width: 190, height: 140), CGPoint(x: center.x - 240, y: center.y + 100)),
            (.konbini, CGSize(width: 220, height: 160), CGPoint(x: center.x + 240, y: center.y + 100)),
            (.sushiBar, CGSize(width: 190, height: 140), CGPoint(x: center.x, y: center.y + 220))
        ]
        for (bType, bSize, bPos) in seafoodStores {
            let bld = BuildingNode(type: bType, size: bSize)
            bld.position = bPos
            addEntity(bld)
        }
        
        // Fleet of Tsukiji Motorized Turret Carts
        for i in 0..<4 {
            let turret = TokyoVehicleNode(type: .turretTruck, isMoving: false)
            turret.position = CGPoint(x: center.x - 90 + CGFloat(i) * 60, y: center.y - 90)
            addEntity(turret)
        }
        
        // Green Frog Construction Barricades
        for xOffset in [-180, 180] {
            let frog = ConstructionBarrierNode(type: .frog)
            frog.position = CGPoint(x: center.x + CGFloat(xOffset), y: center.y - 110)
            addEntity(frog)
        }
        
        // Vending Machines (Pocari Blue & Hot Coffee)
        let vmBlue = VendingMachineNode(type: .blue)
        vmBlue.position = CGPoint(x: center.x - 140, y: center.y - 110)
        addEntity(vmBlue)
        
        let vmHot = VendingMachineNode(type: .hot)
        vmHot.position = CGPoint(x: center.x + 140, y: center.y - 110)
        addEntity(vmHot)
        
        // Additional Tsukiji Seafood Market Scenery & Fleet of Turrets
        let crateCart1 = FishCrateNode()
        crateCart1.position = CGPoint(x: center.x - 120, y: center.y - 100)
        addEntity(crateCart1)
        
        let yatai = RamenYataiNode()
        yatai.position = CGPoint(x: center.x + 20, y: center.y - 100)
        addEntity(yatai)
        
        let crateCart2 = FishCrateNode()
        crateCart2.position = CGPoint(x: center.x + 120, y: center.y - 100)
        addEntity(crateCart2)
        
        let takoyaki = TakoyakiStallNode()
        takoyaki.position = CGPoint(x: center.x - 60, y: center.y - 100)
        addEntity(takoyaki)
        
        // Kei mini truck unloading seafood crates
        let keiTruck = TokyoVehicleNode(type: .keiTruck, isMoving: false)
        keiTruck.position = CGPoint(x: center.x - 300, y: center.y - 140)
        addEntity(keiTruck)
        
        let delVan = TokyoVehicleNode(type: .deliveryVan, isMoving: false)
        delVan.position = CGPoint(x: center.x + 300, y: center.y - 140)
        addEntity(delVan)
        
        // Red Chochin Lanterns over sushi alleys
        for xOff in [-200, -100, 100, 200] {
            let chochin = ChochinLanternNode()
            chochin.position = CGPoint(x: center.x + CGFloat(xOff), y: center.y - 60)
            addEntity(chochin)
        }
        
        // Delivery scooters parked
        for i in 0..<3 {
            let sc = ScooterNode()
            sc.position = CGPoint(x: center.x + 180 + CGFloat(i) * 35, y: center.y - 140)
            addEntity(sc)
        }
    }
    
    // 8. Akihabara Electric Town District (Neon Cyber Bazaar)
    private func buildAkihabaraDistrict() {
        let center = CGPoint(x: 520, y: 280)
        
        // Radio Kaikan Electronics Megastore (260x280)
        let radioKaikan = AkibaRadioKaikanNode()
        radioKaikan.position = CGPoint(x: center.x - 120, y: center.y + 90)
        addEntity(radioKaikan)
        
        // Club Sega 6-Story Arcade (250x290)
        let segaArcade = AkibaArcadeNode()
        segaArcade.position = CGPoint(x: center.x + 140, y: center.y + 90)
        addEntity(segaArcade)
        
        // Multi-Story Anime & Hobby Megastores
        let akibaShops: [CGPoint] = [
            CGPoint(x: center.x - 320, y: center.y - 100),
            CGPoint(x: center.x - 120, y: center.y - 100),
            CGPoint(x: center.x + 120, y: center.y - 100),
            CGPoint(x: center.x + 320, y: center.y - 100),
            CGPoint(x: center.x - 320, y: center.y + 120),
            CGPoint(x: center.x + 320, y: center.y + 120)
        ]
        for (idx, pos) in akibaShops.enumerated() {
            let bType: BuildingType = (idx % 2 == 0) ? .akibaShop : .arcade
            let bld = BuildingNode(type: bType, size: CGSize(width: 210, height: 170))
            bld.position = pos
            addEntity(bld)
        }
        
        // Akiba Cyber Street Poles with Anime Flyer Banners
        for xOffset in [-300, -180, -60, 60, 180, 300] {
            let lamp = TokyoStreetLampNode(style: .akiba)
            lamp.position = CGPoint(x: center.x + CGFloat(xOffset), y: center.y - 60)
            addEntity(lamp)
        }
        
        // Double-decker banks of Gachapon capsule dispensers
        for i in 0..<6 {
            let gacha = GachaponRowNode()
            gacha.position = CGPoint(x: center.x - 140 + CGFloat(i) * 55, y: center.y - 75)
            addEntity(gacha)
        }
        
        // Vending Machine Pairs & Combini Bins
        let vmB1 = VendingMachineNode(type: .blue)
        vmB1.position = CGPoint(x: center.x - 220, y: center.y - 75)
        addEntity(vmB1)
        
        let vmR1 = VendingMachineNode(type: .red)
        vmR1.position = CGPoint(x: center.x + 220, y: center.y - 75)
        addEntity(vmR1)
        
        // Parked Kei Mini Trucks & Delivery Vans
        let kei = TokyoVehicleNode(type: .keiTruck, isMoving: false)
        kei.position = CGPoint(x: center.x - 180, y: center.y - 130)
        addEntity(kei)
        
        let yellowKei = TokyoVehicleNode(type: .compactYellow, isMoving: false)
        yellowKei.position = CGPoint(x: center.x + 180, y: center.y - 130)
        addEntity(yellowKei)
        
        // Additional Akiba Cyber Scenery (Banks of Gachapon, Vending, Delivery Scooters)
        let vmHot = VendingMachineNode(type: .hot)
        vmHot.position = CGPoint(x: center.x - 80, y: center.y - 110)
        addEntity(vmHot)
        
        let bins = CombiniBinsNode()
        bins.position = CGPoint(x: center.x - 40, y: center.y - 110)
        addEntity(bins)
        
        let gachaBank1 = GachaponRowNode()
        gachaBank1.position = CGPoint(x: center.x + 40, y: center.y - 110)
        addEntity(gachaBank1)
        
        let gachaBank2 = GachaponRowNode()
        gachaBank2.position = CGPoint(x: center.x + 120, y: center.y - 110)
        addEntity(gachaBank2)
        
        let gachaBank3 = GachaponRowNode()
        gachaBank3.position = CGPoint(x: center.x, y: center.y + 40)
        addEntity(gachaBank3)
        
        let phone = PhoneBoothNode()
        phone.position = CGPoint(x: center.x - 120, y: center.y - 110)
        addEntity(phone)
        
        let busStop = BusStopNode()
        busStop.position = CGPoint(x: center.x + 260, y: center.y - 110)
        addEntity(busStop)
        
        // Fleet of delivery scooters outside hobby stores
        for i in 0..<4 {
            let sc = ScooterNode()
            sc.position = CGPoint(x: center.x - 260 + CGFloat(i) * 35, y: center.y - 160)
            addEntity(sc)
        }
        
        // Pedestrian Guard Rails along Chuo-dori
        for xOff in [-200, -80, 80, 200] {
            let rail = GuardRailNode()
            rail.position = CGPoint(x: center.x + CGFloat(xOff), y: center.y - 180)
            addEntity(rail)
        }
    }
    
    // 9. Ueno Park District (Museum & Dense Cherry Blossom Avenue)
    private func buildUenoParkDistrict() {
        let center = CGPoint(x: 280, y: 1150)
        
        // Tokyo National Museum Honkan (340x240)
        let museum = UenoMuseumNode()
        museum.position = CGPoint(x: center.x, y: center.y + 130)
        addEntity(museum)
        
        // Traditional Park Pavilion & Food Stalls
        let pav = BuildingNode(type: .shrinePavilion, size: CGSize(width: 220, height: 160))
        pav.position = CGPoint(x: center.x - 300, y: center.y + 130)
        addEntity(pav)
        
        let tako = TakoyakiStallNode()
        tako.position = CGPoint(x: center.x - 160, y: center.y - 80)
        addEntity(tako)
        
        let yatai = RamenYataiNode()
        yatai.position = CGPoint(x: center.x + 160, y: center.y - 80)
        addEntity(yatai)
        
        // Dense Sakura Cherry Blossom Avenue (20+ Trees)
        let sakuraForest: [CGPoint] = [
            CGPoint(x: center.x - 320, y: center.y + 20),
            CGPoint(x: center.x - 240, y: center.y - 40),
            CGPoint(x: center.x - 160, y: center.y - 120),
            CGPoint(x: center.x - 80, y: center.y - 160),
            CGPoint(x: center.x + 80, y: center.y - 160),
            CGPoint(x: center.x + 160, y: center.y - 120),
            CGPoint(x: center.x + 240, y: center.y - 40),
            CGPoint(x: center.x + 320, y: center.y + 20),
            CGPoint(x: center.x - 200, y: center.y + 240),
            CGPoint(x: center.x + 200, y: center.y + 240),
            CGPoint(x: center.x - 100, y: center.y + 280),
            CGPoint(x: center.x + 100, y: center.y + 280)
        ]
        for pos in sakuraForest {
            let sakura = TokyoTreeNode(type: .sakuraBlossom, radius: 36)
            sakura.position = pos
            addEntity(sakura)
        }
        
        // Stone Toro Lanterns along park paths
        for xOffset in [-180, -60, 60, 180] {
            let toro = StoneLanternNode()
            toro.position = CGPoint(x: center.x + CGFloat(xOffset), y: center.y - 40)
            addEntity(toro)
        }
        
        // Bus Stop
        let busStop = BusStopNode()
        busStop.position = CGPoint(x: center.x, y: center.y - 130)
        addEntity(busStop)
        
        // Additional Ueno Park Scenery (Vending machines, benches, lanterns, nature)
        let vmRed = VendingMachineNode(type: .red)
        vmRed.position = CGPoint(x: center.x - 80, y: center.y - 80)
        addEntity(vmRed)
        
        let vmBlue = VendingMachineNode(type: .blue)
        vmBlue.position = CGPoint(x: center.x + 80, y: center.y - 80)
        addEntity(vmBlue)
        
        let stoneToro = StoneLanternNode()
        stoneToro.position = CGPoint(x: center.x, y: center.y - 40)
        addEntity(stoneToro)
        
        let bins = CombiniBinsNode()
        bins.position = CGPoint(x: center.x + 120, y: center.y - 80)
        addEntity(bins)
        
        let retroPost = JapanesePostBoxNode(type: .retro)
        retroPost.position = CGPoint(x: center.x - 120, y: center.y - 80)
        addEntity(retroPost)
        
        let phone = PhoneBoothNode()
        phone.position = CGPoint(x: center.x - 40, y: center.y - 130)
        addEntity(phone)
        
        // Extra Sakura & Ginkgo Park Trees
        let extraTrees: [(TokyoTreeNode.TreeType, CGPoint)] = [
            (.sakuraBlossom, CGPoint(x: center.x - 260, y: center.y + 180)),
            (.sakuraBlossom, CGPoint(x: center.x + 260, y: center.y + 180)),
            (.ginkgo, CGPoint(x: center.x - 340, y: center.y - 80)),
            (.ginkgo, CGPoint(x: center.x + 340, y: center.y - 80)),
            (.pine, CGPoint(x: center.x - 180, y: center.y + 320)),
            (.pine, CGPoint(x: center.x + 180, y: center.y + 320))
        ]
        for (tType, pos) in extraTrees {
            let tree = TokyoTreeNode(type: tType, radius: 36)
            tree.position = pos
            addEntity(tree)
        }
        
        // Parked Mamachari bicycles
        for i in 0..<4 {
            let bike = BicycleNode()
            bike.position = CGPoint(x: center.x + 20 + CGFloat(i) * 35, y: center.y - 130)
            addEntity(bike)
        }
    }
    
    // 10. Asakusa Senso-ji District (Kaminarimon & 5-Story Pagoda)
    private func buildAsakusaSensojiDistrict() {
        let center = CGPoint(x: 1350, y: 1150)
        
        // Monumental Kaminarimon Thunder Gate with Walk-Through Arch (240x220)
        let kaminarimon = KaminarimonGateNode()
        kaminarimon.position = CGPoint(x: center.x, y: center.y - 140)
        addEntity(kaminarimon)
        
        // Majestic 5-Story Buddhist Pagoda (200x380)
        let pagoda = SensojiPagodaNode()
        pagoda.position = CGPoint(x: center.x - 180, y: center.y + 110)
        addEntity(pagoda)
        
        // Senso-ji Traditional Wooden Temple Pavilion
        let temple = BuildingNode(type: .shrinePavilion, size: CGSize(width: 220, height: 160))
        temple.position = CGPoint(x: center.x + 120, y: center.y + 110)
        addEntity(temple)
        
        // Nakamise Souvenir Stalls & Traditional Eateries
        let stalls: [(BuildingType, CGSize, CGPoint)] = [
            (.cafe, CGSize(width: 190, height: 140), CGPoint(x: center.x - 220, y: center.y - 30)),
            (.ramenShop, CGSize(width: 190, height: 140), CGPoint(x: center.x + 220, y: center.y - 30)),
            (.shrinePavilion, CGSize(width: 200, height: 150), CGPoint(x: center.x - 220, y: center.y + 260)),
            (.cafe, CGSize(width: 190, height: 140), CGPoint(x: center.x + 220, y: center.y + 260))
        ]
        for (bType, bSize, bPos) in stalls {
            let bld = BuildingNode(type: bType, size: bSize)
            bld.position = bPos
            addEntity(bld)
        }
        
        // Traditional Ramen Street Yatai Carts & Takoyaki Stalls
        let yatai1 = RamenYataiNode()
        yatai1.position = CGPoint(x: center.x + 140, y: center.y - 60)
        addEntity(yatai1)
        
        let tako1 = TakoyakiStallNode()
        tako1.position = CGPoint(x: center.x - 140, y: center.y - 60)
        addEntity(tako1)
        
        // Stone Toro Lanterns along the Nakamise approach
        for i in 0..<5 {
            let toro = StoneLanternNode()
            toro.position = CGPoint(x: center.x - 100 + CGFloat(i) * 50, y: center.y - 30)
            addEntity(toro)
        }
        
        // Evergreen Pines & Sakura Blossoms
        for xOffset in [-320, 320] {
            let pine = TokyoTreeNode(type: .pine, radius: 36)
            pine.position = CGPoint(x: center.x + CGFloat(xOffset), y: center.y + 80)
            addEntity(pine)
        }
        
        // Additional Asakusa Traditional Market Scenery
        let torii = ToriiGateNode()
        torii.position = CGPoint(x: center.x + 100, y: center.y - 50)
        addEntity(torii)
        
        let stoneToro1 = StoneLanternNode()
        stoneToro1.position = CGPoint(x: center.x - 60, y: center.y + 20)
        addEntity(stoneToro1)
        
        let stoneToro2 = StoneLanternNode()
        stoneToro2.position = CGPoint(x: center.x + 60, y: center.y + 20)
        addEntity(stoneToro2)
        
        let retroPost = JapanesePostBoxNode(type: .retro)
        retroPost.position = CGPoint(x: center.x - 180, y: center.y - 60)
        addEntity(retroPost)
        
        let vmRed = VendingMachineNode(type: .red)
        vmRed.position = CGPoint(x: center.x + 180, y: center.y - 60)
        addEntity(vmRed)
        
        // Red Chochin Lanterns along Nakamise Dori
        for xOff in [-160, -100, -40, 40, 100, 160] {
            let lantern = ChochinLanternNode()
            lantern.position = CGPoint(x: center.x + CGFloat(xOff), y: center.y + 10)
            addEntity(lantern)
        }
        
        // Potted Bonsai Planters
        for xOff in [-240, -140, 140, 240] {
            let pot = BonsaiPlanterNode()
            pot.position = CGPoint(x: center.x + CGFloat(xOff), y: center.y - 90)
            addEntity(pot)
        }
        
        // Extra Traditional Streetlamps
        for xOff in [-280, 280] {
            let lamp = TokyoStreetLampNode(style: .traditional)
            lamp.position = CGPoint(x: center.x + CGFloat(xOff), y: center.y - 40)
            addEntity(lamp)
        }
    }
    
    // 11. Tokyo Skytree District (Futuristic Waterfront Spire)
    private func buildTokyoSkytreeDistrict() {
        let center = CGPoint(x: 1450, y: 250)
        
        // Monumental Tokyo Skytree Spire (240x600)
        let skytree = TokyoSkytreeLandmarkNode()
        skytree.position = CGPoint(x: center.x, y: center.y + 70)
        addEntity(skytree)
        
        // Tokyo Solamachi Highrise Commercial Complexes
        let solamachi1 = BuildingNode(type: .tokyoHighRise, size: CGSize(width: 240, height: 220))
        solamachi1.position = CGPoint(x: center.x - 220, y: center.y - 110)
        addEntity(solamachi1)
        
        let solamachi2 = BuildingNode(type: .tokyoHighRise, size: CGSize(width: 240, height: 220))
        solamachi2.position = CGPoint(x: center.x + 220, y: center.y - 110)
        addEntity(solamachi2)
        
        let solamachi3 = BuildingNode(type: .tokyoHighRise, size: CGSize(width: 240, height: 220))
        solamachi3.position = CGPoint(x: center.x + 220, y: center.y + 110)
        addEntity(solamachi3)
        
        // Riverside Promenade Cafes & Convenience Stores
        let cafe1 = BuildingNode(type: .cafe, size: CGSize(width: 200, height: 150))
        cafe1.position = CGPoint(x: center.x - 220, y: center.y + 110)
        addEntity(cafe1)
        
        let konbini1 = BuildingNode(type: .konbini, size: CGSize(width: 220, height: 160))
        konbini1.position = CGPoint(x: center.x, y: center.y - 110)
        addEntity(konbini1)
        
        // Waterfront promenade streetlamps
        for yOffset in [-200, -100, 0, 100, 200] {
            let lamp = TokyoStreetLampNode(style: .modern)
            lamp.position = CGPoint(x: center.x - 340, y: center.y + CGFloat(yOffset))
            addEntity(lamp)
        }
        
        // Bus Stop sign pole & Phonebooth
        let busStop = BusStopNode()
        busStop.position = CGPoint(x: center.x - 120, y: center.y - 130)
        addEntity(busStop)
        
        let phone = PhoneBoothNode()
        phone.position = CGPoint(x: center.x + 120, y: center.y - 130)
        addEntity(phone)
        
        // Vending Machine Pairs
        let vmR = VendingMachineNode(type: .red)
        vmR.position = CGPoint(x: center.x - 60, y: center.y - 130)
        addEntity(vmR)
        
        let vmB = VendingMachineNode(type: .blue)
        vmB.position = CGPoint(x: center.x - 20, y: center.y - 130)
        addEntity(vmB)
        
        // Additional Waterfront Promenade Scenery & Modern Vehicles
        let metro = MetroEntranceNode()
        metro.position = CGPoint(x: center.x, y: center.y - 70)
        addEntity(metro)
        
        let bins = CombiniBinsNode()
        bins.position = CGPoint(x: center.x + 90, y: center.y - 90)
        addEntity(bins)
        
        let postBox = JapanesePostBoxNode(type: .standard)
        postBox.position = CGPoint(x: center.x + 50, y: center.y - 130)
        addEntity(postBox)
        
        let sedan = TokyoVehicleNode(type: .sedanSilver, isMoving: false)
        sedan.position = CGPoint(x: center.x - 180, y: center.y - 160)
        addEntity(sedan)
        
        let greenTaxi = TokyoVehicleNode(type: .taxiGreen, isMoving: false)
        greenTaxi.position = CGPoint(x: center.x + 180, y: center.y - 160)
        addEntity(greenTaxi)
        
        // Waterfront Pedestrian Guard Rails along Sumida River
        for yOff in [-160, -80, 0, 80, 160] {
            let rail = GuardRailNode()
            rail.position = CGPoint(x: center.x - 300, y: center.y + CGFloat(yOff))
            addEntity(rail)
        }
        
        // Potted Bonsai Planters along Solamachi promenade
        for xOff in [-180, -90, 0, 90, 180] {
            let pot = BonsaiPlanterNode()
            pot.position = CGPoint(x: center.x + CGFloat(xOff), y: center.y - 110)
            addEntity(pot)
        }
        
        // Parked Scooters & Bicycles
        for i in 0..<3 {
            let sc = ScooterNode()
            sc.position = CGPoint(x: center.x - 260 + CGFloat(i) * 35, y: center.y - 130)
            addEntity(sc)
        }
    }
    
    // MARK: - Helper Methods
    
    private func addEntity(_ node: SKNode) {
        entityLayer.addChild(node)
        sortableEntities.append(node)
    }
    
    // MARK: - Atmospheric Sakura Petal Drift
    
    private func setupSakuraPetalAnimation() {
        let petalContainer = SKNode()
        petalContainer.zPosition = 9000
        addChild(petalContainer)
        
        let spawnAction = SKAction.run { [weak self, weak petalContainer] in
            guard let self = self, let container = petalContainer else { return }
            
            let halfW = self.mapSize.width / 2.0
            let halfH = self.mapSize.height / 2.0
            
            let startX = CGFloat.random(in: -halfW...halfW)
            let startY = halfH + 20
            
            let petal = SKShapeNode(ellipseOf: CGSize(width: 6, height: 4))
            petal.fillColor = SKColor(red: 1.0, green: 0.78, blue: 0.88, alpha: 0.8)
            petal.strokeColor = .clear
            petal.position = CGPoint(x: startX, y: startY)
            petal.zRotation = CGFloat.random(in: 0...CGFloat.pi * 2)
            container.addChild(petal)
            
            let travelTime = Double.random(in: 4.5...7.5)
            let driftX = CGFloat.random(in: -160...(-80))
            let moveAction = SKAction.moveBy(x: driftX, y: -(self.mapSize.height + 60), duration: travelTime)
            let rotateAction = SKAction.rotate(byAngle: CGFloat.pi * 4, duration: travelTime)
            let fadeAction = SKAction.sequence([
                SKAction.wait(forDuration: travelTime - 1.0),
                SKAction.fadeOut(withDuration: 1.0)
            ])
            
            petal.run(SKAction.group([moveAction, rotateAction, fadeAction])) {
                petal.removeFromParent()
            }
        }
        
        let waitAction = SKAction.wait(forDuration: 0.25)
        run(SKAction.repeatForever(SKAction.sequence([spawnAction, waitAction])))
    }
    
    // MARK: - World Perimeter Boundaries
    
    private func buildWorldBoundaries() {
        let halfW = mapSize.width / 2.0
        let halfH = mapSize.height / 2.0
        
        let boundaryRect = CGRect(x: -halfW, y: -halfH, width: mapSize.width, height: mapSize.height)
        let boundaryBody = SKPhysicsBody(edgeLoopFrom: boundaryRect)
        boundaryBody.isDynamic = false
        boundaryBody.categoryBitMask = PhysicsCategory.worldBoundary
        boundaryBody.collisionBitMask = PhysicsCategory.player
        self.physicsBody = boundaryBody
        
        let border = SKShapeNode(rect: boundaryRect)
        border.fillColor = .clear
        border.strokeColor = SKColor(white: 0.3, alpha: 0.8)
        border.lineWidth = 10.0
        border.zPosition = -50.0
        groundLayer.addChild(border)
    }
}
