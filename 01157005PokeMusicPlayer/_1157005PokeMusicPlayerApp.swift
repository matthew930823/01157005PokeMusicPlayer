//
//  _1157005PokeMusicPlayerApp.swift
//  01157005PokeMusicPlayer
//
//  Created by user11 on 2024/11/11.
//

import SwiftUI
import AVFoundation
import MediaPlayer

@main
struct _1157005PokeMusicPlayerApp: App {
    
    var monsterAttributes = MonsterAttributes()
    var characterAttributes = CharacterAttributes()
    var body: some Scene {
        WindowGroup {
            pokeGame().environmentObject(characterAttributes).environmentObject(monsterAttributes)
        }
    }
}
