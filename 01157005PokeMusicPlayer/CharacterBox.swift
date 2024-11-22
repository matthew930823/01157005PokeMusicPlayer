//
//  CharacterBox.swift
//  01157005PokeMusicPlayer
//
//  Created by user11 on 2024/11/14.
//

import SwiftUI
class CharacterAttributes: ObservableObject {
    @Published var attributes: [String: Color] = [
        "head1": Color.green,
        "head2": Color.red,
        "head3": Color.blue
    ]
}
struct CharacterBox: View {
    @EnvironmentObject var characterAttributes: CharacterAttributes
    let head:String
    var body: some View {
        ZStack{
            let attribute:Color = characterAttributes.attributes[head]!
            Image(head)
                .resizable()
                .scaledToFit()
                .overlay(Rectangle().stroke(attribute, lineWidth: 5))
        }
    }
}

#Preview {
    CharacterBox(head:"head1")
}
