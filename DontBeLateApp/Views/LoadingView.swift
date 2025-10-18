//
//  LoadingView.swift
//  DontBeLate
//
//  Created on 2025
//

import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false
    @State private var rotation: Double = 0
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .hueRotation(.degrees(rotation))
            
            // Floating circles animation
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 200, height: 200)
                    .offset(x: CGFloat(index * 50 - 50), y: CGFloat(index * 50 - 50))
                    .scaleEffect(isAnimating ? 1.2 : 0.8)
                    .animation(
                        Animation.easeInOut(duration: 2.0 + Double(index) * 0.3)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.2),
                        value: isAnimating
                    )
            }
            
            VStack(spacing: 30) {
                // Animated icon
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 120, height: 120)
                        .scaleEffect(isAnimating ? 1.2 : 1.0)
                    
                    Image(systemName: "clock.badge.checkmark.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(rotation))
                }
                .animation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )
                
                Text("Don't Be Late")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                    .opacity(opacity)
                
                Text("Syncing your calendar...")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .opacity(opacity)
                
                // Animated loading indicator
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Color.white)
                            .frame(width: 10, height: 10)
                            .scaleEffect(isAnimating ? 1.0 : 0.5)
                            .animation(
                                Animation.easeInOut(duration: 0.6)
                                    .repeatForever()
                                    .delay(Double(index) * 0.2),
                                value: isAnimating
                            )
                    }
                }
                .padding(.top, 10)
            }
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.5)) {
                opacity = 1.0
            }
            isAnimating = true
            
            withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

#Preview {
    LoadingView()
}

