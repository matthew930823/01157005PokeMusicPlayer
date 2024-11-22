//
//  MainView.swift
//  01157005PokeMusicPlayer
//
//  Created by user11 on 2024/11/20.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView{
            Tab("遊戲", systemImage: "map.fill"){
                var monsterAttributes = MonsterAttributes()
                var characterAttributes = CharacterAttributes()
                pokeGame().environmentObject(characterAttributes).environmentObject(monsterAttributes)
            }
            Tab("音樂", systemImage: "music.note"){
                @StateObject var viewModel = MusicPlayerViewModel()
                SongsListView(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    MainView()
}
