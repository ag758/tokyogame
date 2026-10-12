# Tokyo Game Asset Reference & Target Resolution Guide

This document lists all image asset placeholders created in [`Assets.xcassets`](file:///Users/austingao/Documents/code/tokyogame/tokyogame/tokyogame/Assets.xcassets), their target point sizes, exact retina pixel resolutions (`@1x`, `@2x`, `@3x`), anchor points, and in-game roles.

When you are ready to replace them with your hand-drawn anime artwork, simply replace the PNG files inside each `.imageset` folder in Xcode (or drag-and-drop into `Assets.xcassets` in Xcode).

---

## 1. Character Sprites (Anime Protagonist)

| Asset Name | View Angle | Base Size (pt) | @1x (Standard) | @2x (Retina) | @3x (Super Retina) | Anchor Point |
|---|---|---|---|---|---|---|
| `player_down` | Facing South (Camera) | 64 × 64 pt | 64 × 64 px | 128 × 128 px | 192 × 192 px | `(0.5, 0.2)` Feet base |
| `player_up` | Facing North (Away) | 64 × 64 pt | 64 × 64 px | 128 × 128 px | 192 × 192 px | `(0.5, 0.2)` Feet base |
| `player_left` | Facing West (Left) | 64 × 64 pt | 64 × 64 px | 128 × 128 px | 192 × 192 px | `(0.5, 0.2)` Feet base |
| `player_right` | Facing East (Right) | 64 × 64 pt | 64 × 64 px | 128 × 128 px | 192 × 192 px | `(0.5, 0.2)` Feet base |

> **Art Tip**: Keep characters in a consistent 2.5D top-down / slightly tilted angle (like Pokémon Gen 4/5 or Octopath Traveler). Ensure the bottom ~15-20% of the frame is where the character's feet touch the ground for proper dynamic Y-depth sorting (`zPosition = 5000 - position.y`).

---

## 2. Monumental Tokyo Landmarks (Scaled Up & True to Scale)

All landmarks have been enlarged to monumental proportions relative to normal buildings and player characters, reflecting their true towering majesty in Tokyo.

| Asset Name | Landmark & District | Base Size (pt) | @1x (Standard) | @2x (Retina) | @3x (Super Retina) | Base Collision |
|---|---|---|---|---|---|---|
| `landmark_tokyo_tower` | Tokyo Tower (Minato/Shiba) | 320 × 520 pt | 320 × 520 px | 640 × 1040 px | 960 × 1560 px | Bottom 50 pt |
| `landmark_skytree` | Tokyo Skytree (Sumida) | 240 × 600 pt | 240 × 600 px | 480 × 1200 px | 720 × 1800 px | Bottom 50 pt |
| `landmark_mori_tower` | Roppongi Hills Mori Tower | 300 × 420 pt | 300 × 420 px | 600 × 840 px | 900 × 1260 px | Bottom 48 pt |
| `landmark_shibuya109` | Shibuya 109 Fashion Tower | 260 × 320 pt | 260 × 320 px | 520 × 640 px | 780 × 960 px | Bottom 46 pt |
| `landmark_sensoji_pagoda` | Senso-ji 5-Story Pagoda | 200 × 380 pt | 200 × 380 px | 400 × 760 px | 600 × 1140 px | Bottom 44 pt |
| `landmark_wako_clock` | Ginza Wako Clock Tower | 220 × 300 pt | 220 × 300 px | 440 × 600 px | 660 × 900 px | Bottom 44 pt |
| `landmark_akiba_arcade` | Club Sega Akihabara | 250 × 290 pt | 250 × 290 px | 500 × 580 px | 750 × 870 px | Bottom 46 pt |
| `landmark_radio_kaikan` | Akiba Radio Kaikan | 260 × 280 pt | 260 × 280 px | 520 × 560 px | 780 × 840 px | Bottom 46 pt |
| `landmark_imperial_watchtower` | Fujimi-yagura Keep (Chiyoda) | 240 × 260 pt | 240 × 260 px | 480 × 520 px | 720 × 780 px | Bottom 50 pt |
| `landmark_ueno_museum` | Tokyo National Museum (Ueno) | 340 × 240 pt | 340 × 240 px | 680 × 480 px | 1020 × 720 px | Bottom 48 pt |
| `landmark_tsukiji_market` | Tsukiji Fish Market Hall | 320 × 220 pt | 320 × 220 px | 640 × 440 px | 960 × 660 px | Bottom 46 pt |
| `landmark_kaminarimon` | Kaminarimon Thunder Gate | 240 × 220 pt | 240 × 220 px | 480 × 440 px | 720 × 660 px | Left/Right Pillars |
| `landmark_takeshita_arch` | Takeshita St Entrance Arch | 260 × 180 pt | 260 × 180 px | 520 × 360 px | 780 × 540 px | Left/Right Posts |
| `landmark_maman_spider` | Roppongi Maman Spider | 200 × 180 pt | 200 × 180 px | 400 × 360 px | 600 × 540 px | Center Body |
| `landmark_crepe_stand` | Harajuku Marion Crepe Stand | 150 × 130 pt | 150 × 130 px | 300 × 260 px | 450 × 390 px | Bottom 38 pt |
| `landmark_hachiko` | Shibuya Hachiko Bronze Dog | 110 × 120 pt | 110 × 120 px | 220 × 240 px | 330 × 360 px | Pedestal 36 pt |

---

## 3. Tokyo 2.5D Buildings

| Asset Name | Description | Base Size (pt) | @1x (Standard) | @2x (Retina) | @3x (Super Retina) | Base Collision |
|---|---|---|---|---|---|---|
| `building_konbini` | Japanese Convenience Store | 220 × 160 pt | 220 × 160 px | 440 × 320 px | 660 × 480 px | Bottom 36 pt |
| `building_ramen` | Traditional Ramen / Izakaya | 190 × 140 pt | 190 × 140 px | 380 × 280 px | 570 × 420 px | Bottom 36 pt |
| `building_arcade` | Akihabara Neon Game Center | 200 × 170 pt | 200 × 170 px | 400 × 340 px | 600 × 510 px | Bottom 36 pt |
| `building_highrise` | Tokyo Tower High-Rise Apts | 240 × 220 pt | 240 × 220 px | 480 × 440 px | 720 × 660 px | Bottom 36 pt |
| `building_cafe` | Tokyo Sidewalk Cafe | 200 × 150 pt | 200 × 150 px | 400 × 300 px | 600 × 450 px | Bottom 36 pt |
| `building_shrine_pavilion` | Traditional Shrine Hall | 220 × 160 pt | 220 × 160 px | 440 × 320 px | 660 × 480 px | Bottom 36 pt |
| `building_akiba_shop` | Akihabara Hobby Megastore | 210 × 170 pt | 210 × 170 px | 420 × 340 px | 630 × 510 px | Bottom 36 pt |
| `building_ginza_boutique` | Ginza Luxury Boutique | 210 × 160 pt | 210 × 160 px | 420 × 320 px | 630 × 480 px | Bottom 36 pt |
| `building_sushi_bar` | Tsukiji Sushi Dai Restaurant | 190 × 140 pt | 190 × 140 px | 380 × 280 px | 570 × 420 px | Bottom 36 pt |

---

## 4. Tokyo Vehicles & Traffic

| Asset Name | Description | Base Size (pt) | @1x (Standard) | @2x (Retina) | @3x (Super Retina) |
|---|---|---|---|---|---|
| `vehicle_taxi_green` | Tokyo Green Crown Taxi | 84 × 44 pt | 84 × 44 px | 168 × 88 px | 252 × 132 px |
| `vehicle_taxi_black` | Tokyo Black Executive Taxi | 84 × 44 pt | 84 × 44 px | 168 × 88 px | 252 × 132 px |
| `vehicle_kei_truck` | Japanese White Mini Kei Truck | 76 × 44 pt | 76 × 44 px | 152 × 88 px | 228 × 132 px |
| `vehicle_compact_yellow` | Tokyo Yellow City Kei Hatchback | 72 × 42 pt | 72 × 42 px | 144 × 84 px | 216 × 126 px |
| `vehicle_sedan_silver` | Executive Silver Sedan | 84 × 44 pt | 84 × 44 px | 168 × 88 px | 252 × 132 px |
| `vehicle_delivery_van` | Japanese Courier Delivery Van | 88 × 48 pt | 88 × 48 px | 176 × 96 px | 264 × 144 px |
| `vehicle_turret_truck` | Tsukiji Market Turret Cart | 64 × 40 pt | 64 × 40 px | 128 × 80 px | 192 × 120 px |

---

## 5. Authentic Tokyo Street Furniture, Scenery & Props

| Asset Name | Description | Base Size (pt) | @1x (Standard) | @2x (Retina) | @3x (Super Retina) | Notes |
|---|---|---|---|---|---|---|
| `prop_mailbox_jp` | Japanese Red Post Box (〒) | 32 × 44 pt | 32 × 44 px | 64 × 88 px | 96 × 132 px | Standard double-slot |
| `prop_mailbox_retro` | Vintage Cylindrical Marupost | 30 × 52 pt | 30 × 52 px | 60 × 104 px | 90 × 156 px | Round dome cap |
| `prop_streetlamp_modern` | Tokyo Modern LED Streetlamp | 26 × 72 pt | 26 × 72 px | 52 × 144 px | 78 × 216 px | Standard city pole |
| `prop_streetlamp_ginza` | Ginza Triple-Lantern Gas Lamp | 32 × 80 pt | 32 × 80 px | 64 × 160 px | 96 × 240 px | Ornate black & gold |
| `prop_streetlamp_akiba` | Akiba Cyber Neon Street Pole | 28 × 76 pt | 28 × 76 px | 56 × 152 px | 84 × 228 px | With flyer banners |
| `prop_streetlamp_traditional` | Temple Pagoda Lantern Lamp | 30 × 74 pt | 30 × 74 px | 60 × 148 px | 90 × 222 px | Wood & cast iron |
| `prop_lantern_stone` | Japanese Toro Stone Lantern | 34 × 54 pt | 34 × 54 px | 68 × 108 px | 102 × 162 px | Garden lantern |
| `prop_lantern_red` | Chōchin Red Festival Lantern | 26 × 42 pt | 26 × 42 px | 52 × 84 px | 78 × 126 px | Hanging paper lantern |
| `prop_phonebooth_green` | NTT Green Telephone Booth | 36 × 62 pt | 36 × 62 px | 72 × 124 px | 108 × 186 px | Classic aluminum/glass |
| `prop_combini_bins` | Combini 3-Part Recycling Bins | 44 × 34 pt | 44 × 34 px | 88 × 68 px | 132 × 102 px | Cans / PET / Burnables |
| `prop_gachapon_bank` | Double-Tier Gachapon Row | 54 × 48 pt | 54 × 48 px | 108 × 96 px | 162 × 144 px | Capsule dispensers |
| `prop_bicycle_mamachari` | Japanese Shopping Bicycle | 46 × 38 pt | 46 × 38 px | 92 × 76 px | 138 × 114 px | With front wire basket |
| `prop_scooter_delivery` | Tokyo Delivery Scooter | 48 × 40 pt | 48 × 40 px | 96 × 80 px | 144 × 120 px | With warming cargo box |
| `prop_barrier_rabbit` | Pink Bunny Construction Barrier | 42 × 34 pt | 42 × 34 px | 84 × 68 px | 126 × 102 px | Authentic Japanese kawaii |
| `prop_barrier_frog` | Green Frog Construction Barrier | 42 × 34 pt | 42 × 34 px | 84 × 68 px | 126 × 102 px | Roadworks barrier |
| `prop_potted_bonsai` | Sidewalk Bonsai / Bamboo Pot | 32 × 32 pt | 32 × 32 px | 64 × 64 px | 96 × 96 px | Ceramic planter |
| `prop_guard_rail` | White Wavy Pedestrian Guard Rail | 64 × 26 pt | 64 × 26 px | 128 × 52 px | 192 × 78 px | Roadside safety rail |
| `prop_fire_hydrant` | Standpipe Fire Hydrant | 24 × 36 pt | 24 × 36 px | 48 × 72 px | 72 × 108 px | Red sidewalk valve |
| `prop_bus_stop` | Tokyo City Bus Stop Sign | 24 × 64 pt | 24 × 64 px | 48 × 128 px | 72 × 192 px | With timetable |
| `prop_stall_ramen_yatai` | Ramen Street Food Cart | 84 × 70 pt | 84 × 70 px | 168 × 140 px | 252 × 210 px | Wooden wheels & noren |
| `prop_stall_takoyaki` | Takoyaki Street Food Stall | 76 × 64 pt | 76 × 64 px | 152 × 128 px | 228 × 192 px | Sizzling griddle |
| `scenery_metro_entrance` | Tokyo Metro Subway Entrance | 110 × 74 pt | 110 × 74 px | 220 × 148 px | 330 × 222 px | Descending stairwell |
| `scenery_tactile_paving` | Yellow Tactile Tenji Blocks | 60 × 60 pt | 60 × 60 px | 120 × 120 px | 180 × 180 px | Braille guide tiles |
| `scenery_sidewalk_shibuya` | Shibuya Urban Paving Grid | 120 × 120 pt | 120 × 120 px | 240 × 240 px | 360 × 360 px | Concrete sidewalk block |
| `scenery_sidewalk_ginza` | Ginza Dark Granite Paving | 120 × 120 pt | 120 × 120 px | 240 × 240 px | 360 × 360 px | Polished granite stone |
| `scenery_sidewalk_asakusa` | Asakusa Flagstone Paving | 120 × 120 pt | 120 × 120 px | 240 × 240 px | 360 × 360 px | Historic stone slabs |
| `prop_vending_red` | Red Drink Vending Machine | 38 × 54 pt | 38 × 54 px | 76 × 108 px | 114 × 162 px | Coffee & soda |
| `prop_vending_blue` | Blue Drink Vending Machine | 38 × 54 pt | 38 × 54 px | 76 × 108 px | 114 × 162 px | Sports & water |
| `prop_vending_hot` | Orange Warm Drinks Vending | 38 × 54 pt | 38 × 54 px | 76 × 108 px | 114 × 162 px | Heated canned beverages |
| `prop_torii_gate` | Shinto Shrine Torii Gate | 130 × 110 pt | 130 × 110 px | 260 × 220 px | 390 × 330 px | Walk-through gate |
| `prop_traffic_light` | Shibuya Signal Pole | 20 × 70 pt | 20 × 70 px | 40 × 140 px | 60 × 210 px | Crosswalk light |
| `prop_tree_sakura` | Blooming Sakura Cherry Tree | 80 × 96 pt | 80 × 96 px | 160 × 192 px | 240 × 288 px | Pink blossom canopy |
| `prop_tree_ginkgo` | Tokyo Golden Ginkgo Tree | 80 × 96 pt | 80 × 96 px | 160 × 192 px | 240 × 288 px | Golden fan-leaf canopy |
| `prop_tree_pine` | Imperial Black Pine | 84 × 92 pt | 84 × 92 px | 168 × 184 px | 252 × 276 px | Manicured evergreen |
| `prop_tree_green` | Urban Sidewalk Park Tree | 64 × 76 pt | 64 × 76 px | 128 × 152 px | 192 × 228 px | Green round canopy |

---

## 6. Neighborhood Scenery & In-Game Asset Labels

In accordance with game design, collectible pickup items have been retired in favor of hyper-dense, living physical Tokyo scenery across all 11 districts.

Every single asset in the game features an explicit in-game label badge (e.g., `[ VENDING MACHINE (RED / COLA) ]`, `[ TOKYO CROWN TAXI ]`, `[ SAKURA CHERRY TREE ]`, `[ POST BOX (〒) ]`, `[ NTT PHONE BOOTH ]`, `[ PEDESTRIAN GUARD RAIL ]`, `[ COMBINI RECYCLE BINS ]`, `[ TOKYO HIGHRISE TOWER ]`, etc.) rendered above each object so that all assets are immediately identifiable in-game and during development.


---

## 7. UI Controls

| Asset Name | Description | Base Size (pt) | @1x (Standard) | @2x (Retina) | @3x (Super Retina) |
|---|---|---|---|---|---|
| `ui_joystick_base` | Virtual Joystick Outer Ring | 124 × 124 pt | 124 × 124 px | 248 × 248 px | 372 × 372 px |
| `ui_joystick_knob` | Virtual Joystick Thumb Handle | 56 × 56 pt | 56 × 56 px | 112 × 112 px | 168 × 168 px |

---

## 8. Technical Specifications for Artwork

- **File Format**: Transparent PNG (`.png`) with 8-bit or 16-bit alpha channel.
- **Color Space**: sRGB or Display P3.
- **Physics & Depth Alignment**:
  - In SpriteKit, all entities sort dynamically using `zPosition = 5000.0 - position.y`.
  - The ground contact line should always be near the bottom of the sprite so that characters overlap buildings/trees naturally when standing in front of them.
