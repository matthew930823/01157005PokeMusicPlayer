//
//  MosterView.swift
//  01157005PokeMusicPlayer
//
//  Created by user11 on 2024/11/15.
//

import SwiftUI
class MonsterAttributes: ObservableObject {
    @Published var attributes: [String: Int] = [
        "monster1": 10,
        "monster2": 100
    ]
}

struct MonsterView: View {
    @EnvironmentObject var monsterAttributes: MonsterAttributes
    let head: String
    
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 1.0
    
    var body: some View {
        VStack {
            // 头部的怪物图像
            Image(head)
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .clipShape(Circle())
                .overlay(Circle().stroke(LinearGradient(gradient: Gradient(colors: [.yellow, .red]), startPoint: .top, endPoint: .bottom), lineWidth: 5))
                .shadow(color: .black, radius: 10, x: 5, y: 5)
                .scaleEffect(scale)  // 放大缩小动画
                .opacity(opacity)  // 透明度渐变动画
                .onAppear {
                    // 动画效果：头部图像放大，并且透明度渐变
                    withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                        scale = 1.2
                        opacity = 0.5
                    }
                }
            
            // 怪物的生命值（HP）
            let HP: Int = monsterAttributes.attributes[head]!
            Text("HP: \(HP)")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(HP > 50 ? .green : .red)
                .padding(.top, 20)
                .background(
                    Capsule()
                        .fill(LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .top, endPoint: .bottom))
                        .shadow(color: .black, radius: 5, x: 0, y: 5)
                )
                .padding(10)
                .scaleEffect(1.1)
                .animation(.spring(), value: HP)  // 添加弹性动画
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RadialGradient(gradient: Gradient(colors: [.purple, .black]), center: .center, startRadius: 5, endRadius: 500)
                .ignoresSafeArea()
        )
        .padding()
    }
}

#Preview {
    var monsterAttributes = MonsterAttributes()
    MoㄙsterView(head: "monster1").environmentObject(monsterAttributes)
}
