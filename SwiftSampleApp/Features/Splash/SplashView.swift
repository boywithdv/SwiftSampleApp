//
//  SplashView.swift
//  SwiftSampleApp
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Color.appPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 120, height: 120)
                        Image(systemName: "location.north.fill")
                            .font(.system(size: 54, weight: .medium))
                            .foregroundStyle(.white)
                    }

                    Text("LocaSocial")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.white)

                    Text("近くの人とつながろう")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(.white.opacity(0.8))
                }

                Spacer()

                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.2)
                    .padding(.bottom, 48)
            }
        }
    }
}
