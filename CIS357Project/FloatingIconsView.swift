//
//  FloatingIconsView.swift
//  CIS357Project
//
//  Created by Caleb Taylor on 11/24/25.
//

import SwiftUI

struct FloatingIconsView: View {
    private let icons = ["heart.fill", "flame.fill", "bolt.fill", "star.fill"]
    private let colors: [Color] = [.pink, .yellow, .orange, .purple]

    @State private var positions: [CGSize] =
        Array(repeating: .zero, count: 12)

    var body: some View {
        GeometryReader { geo in
            ForEach(0..<positions.count, id: \.self) { i in
                let randomIcon = icons.randomElement()!
                let randomColor = colors.randomElement()!

                Image(systemName: randomIcon)
                    .foregroundColor(randomColor.opacity(0.35))
                    .font(.system(size: CGFloat.random(in: 25...50)))
                    .position(
                        x: CGFloat.random(in: 0...geo.size.width),
                        y: CGFloat.random(in: 0...geo.size.height)
                    )
                    .animation(
                        .easeInOut(duration: Double.random(in: 4...7))
                            .repeatForever(autoreverses: true)
                            .delay(Double.random(in: 0...2)),
                        value: positions[i]
                    )
                    .onAppear {
                        positions[i] =
                            CGSize(width: CGFloat.random(in: 0...geo.size.width),
                                   height: CGFloat.random(in: 0...geo.size.height))
                    }
            }
        }
        .ignoresSafeArea()
    }
}
