//
//  MosterView.swift
//  01157005PokeMusicPlayer
//
//  Created by user11 on 2024/11/15.
//

import SwiftUI
class MonsterAttributes: ObservableObject {
    @Published var attributes: [String: [Int]] = [
        "monster1": [10,10,3],//maxHP,HP,power
        "monster2": [50,50,6]
    ]
    @Published var isShaking: Bool = false
    func applyDamage(to monster: String, damage: Int) {
        guard var stats = attributes[monster] else { return }
        stats[1] = max(0, stats[1] - damage)
        attributes[monster] = stats
    }
    func getMonsterPower(for monster: String) -> Int? {
        guard let stats = attributes[monster] else {
            return nil
        }
        return stats[2] // 返回該怪物的 power
    }
    func getMonsterHP(for monster: String) -> Int? {
        guard let stats = attributes[monster] else {
            return nil
        }
        return stats[1] // 返回該怪物的 HP
    }
    func reset(){
        var stats = attributes["monster1"]
        stats![1] = (stats?[0])!
        attributes["monster1"] = stats
        stats = attributes["monster2"]
        stats![1] = (stats?[0])!
        attributes["monster2"] = stats
    }
}
struct MonsterView: View {
    @EnvironmentObject var monsterAttributes: MonsterAttributes
    
    let head:String
    var body: some View {
        VStack{
            if let stats = monsterAttributes.attributes[head], stats.count == 3 {
                let maxHP = stats[0]
                let HP = stats[1]
                let healthPercentage = CGFloat(HP) / CGFloat(maxHP)
                
                Image(head)
                    .resizable()
                    .scaledToFit()
                
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 300, height: 25)
                        .foregroundColor(Color.gray.opacity(0.3)) // 背景色
                    
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 300 * healthPercentage, height: 25)
                        .foregroundColor(healthPercentage > 0.5 ? .green : (healthPercentage > 0.2 ? .yellow : .red))
                        .animation(.easeInOut(duration: 0.5), value: healthPercentage)
                    
                    Text("HP: \(HP) / \(maxHP)")
                        .font(.title2)
                }
                .padding(.top, -20)
            } else {
                Text("Monster data unavailable")
                    .font(.headline)
                    .foregroundColor(.red)
            }
        }
    }
}

#Preview {
    var monsterAttributes = MonsterAttributes()
    MonsterView(head: "monster2").environmentObject(monsterAttributes)
}
