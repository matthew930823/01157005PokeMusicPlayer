//
//  WinView.swift
//  01157005PokeMusicPlayer
//
//  Created by user11 on 2024/11/20.
//

import SwiftUI

struct WinView: View {
    var onRestart: () -> Void
    @EnvironmentObject var timerviewModel: TimerViewModel

    var body: some View {
        ZStack {
            // 背景
            LinearGradient(
                gradient: Gradient(colors: [Color.yellow, Color.orange]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                // 勝利標題
                Text("🎉 Victory! 🎉")
                    .font(.system(size: 50, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 2)
                    .padding(.top, 50)

                // 計時器
                TimerView()
                    .environmentObject(timerviewModel)
                    .frame(height: 100)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.8))
                            .shadow(color: .gray, radius: 10, x: 0, y: 4)
                    )
                
                Image(.win)
                    .resizable()
                    .scaledToFit()

                // 再玩一次按鈕
                Button(action: {
                    onRestart()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                            .font(.title)
                        Text("Play Again")
                            .font(.title2.bold())
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: 200)
                    .background(
                        Capsule()
                            .fill(Color.green)
                            .shadow(color: .gray.opacity(0.8), radius: 8, x: 0, y: 4)
                    )
                }
                .padding(.bottom, 50)
            }
        }
    }
}

struct LoseView: View {
    var onRestart: () -> Void
    @EnvironmentObject var timerviewModel: TimerViewModel

    var body: some View {
        ZStack {
            // 背景
            LinearGradient(
                gradient: Gradient(colors: [Color.gray, Color.black]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                // 標題
                Text("💀 Defeat... 💀")
                    .font(.system(size: 45, weight: .bold, design: .rounded))
                    .foregroundColor(.red)
                    .shadow(color: .black.opacity(0.7), radius: 5, x: 0, y: 2)
                    .padding(.top, 50)

                // 計時器
                TimerView()
                    .environmentObject(timerviewModel)
                    .frame(height: 100)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.7))
                            .shadow(color: .gray.opacity(0.8), radius: 10, x: 0, y: 5)
                    )
                
                Image(.lose)
                    .resizable()
                    .scaledToFit()
                
                // 再玩一次按鈕
                Button(action: {
                    onRestart()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                            .font(.title)
                        Text("Play Again")
                            .font(.title2.bold())
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: 200)
                    .background(
                        Capsule()
                            .fill(Color.red)
                            .shadow(color: .black.opacity(0.8), radius: 8, x: 0, y: 4)
                    )
                }
                .padding(.bottom, 50)
            }
        }
    }
}
