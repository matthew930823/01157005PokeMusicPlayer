import SwiftUI

struct ExplosionEffect: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 1.0

    var body: some View {
        ZStack {
            // 爆炸核心
            Circle()
                .fill(Color.orange)
                .scaleEffect(scale)
                .opacity(opacity)
                .frame(width: 100, height: 100)
                .onAppear {
                    withAnimation(.easeOut(duration: 0.5)) {
                        scale = 3.5
                        opacity = 0.0
                    }
                }
                .offset(y:-100)
            
        }
    }
}


struct WaterEffect: View {
    @State private var ripples: [Ripple] = []
    @State private var isAnimating: Bool = false

    var body: some View {
        ZStack {
            ForEach(ripples) { ripple in
                Circle()
                    .stroke(Color.blue.opacity(ripple.opacity), lineWidth: ripple.lineWidth)
                    .scaleEffect(ripple.scale)
                    .frame(width: ripple.size, height: ripple.size)
                    .animation(.easeOut(duration: ripple.duration), value: ripple.scale)
                    .offset(y:-100)
            }
        }
        .onAppear {
            generateRipples()
        }
    }

    private func generateRipples() {
        for _ in 0..<5 {
            let delay = Double.random(in: 0...0.5)
            let ripple = Ripple(
                id: UUID(),
                size: CGFloat.random(in: 50...100),
                scale: 0.1,
                opacity: 1.0,
                lineWidth: CGFloat.random(in: 2...4),
                duration: Double.random(in: 1.0...1.5)
            )
            ripples.append(ripple)

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                if let index = ripples.firstIndex(where: { $0.id == ripple.id }) {
                    withAnimation {
                        ripples[index].scale = 3.5
                        ripples[index].opacity = 0.0
                    }
                }
            }
        }
    }
}

struct Ripple: Identifiable {
    let id: UUID
    var size: CGFloat
    var scale: CGFloat
    var opacity: Double
    var lineWidth: CGFloat
    var duration: Double
}
struct GrassEffectWithExplosion: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 1.0

    var body: some View {
        ZStack {
            // 爆炸核心
            Circle()
                .fill(Color.green)
                .scaleEffect(scale)
                .opacity(opacity)
                .frame(width: 100, height: 100)
                .onAppear {
                    withAnimation(.easeOut(duration: 0.5)) {
                        scale = 3.5
                        opacity = 0.0
                    }
                }
                .offset(y:-100)
            
        }
    }

}

#Preview {
    //ExplosionEffect()
    WaterEffect()
    //GrassEffectWithExplosion()
}
