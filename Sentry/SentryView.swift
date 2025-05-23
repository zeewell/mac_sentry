//
//  SentryView.swift
//  Sentry
//
//  Created by 秋星桥 on 5/24/25.
//

import SwiftUI

struct SentryView: View {
    @State var globalOpacity: Double = 0
    @State var showEye = false

    var body: some View {
        HStack {
            texts
            Spacer()
            Divider().hidden()
            eye
        }
        .frame(width: 700, height: 400, alignment: .center)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                globalOpacity = 1
                showEye = true
            }
        }
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 32))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .opacity(globalOpacity)
        .animation(.easeInOut(duration: 1), value: globalOpacity)
    }

    var texts: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Date(), style: .time)
                .bold()
                .font(.largeTitle)
                .opacity(0.2)
            Spacer()
            Text("Sentry Mode")
                .bold()
                .font(.largeTitle)
            Text("This Mac is connected to the internet and is monitoring your behavior.")
                .bold()
        }
        .padding(32)
    }

    var eye: some View {
        ZStack {
            Rectangle()
                .frame(width: 10, height: 888)
            if showEye {
                EyeView()
                    .contentTransition(.opacity)
            }
        }
        .animation(.spring(duration: 2), value: showEye)
        .frame(width: 200)
        .padding(32)
    }
}

#Preview {
    SentryView()
        .frame(width: 700, height: 400)
}
