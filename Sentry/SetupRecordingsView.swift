//
//  SetupRecordingsView.swift
//  Sentry
//
//  Created by 秋星桥 on 5/24/25.
//

import SwiftUI

struct SetupRecordingsView: View {
    @StateObject var vm = SentryConfigurationManager.shared

    var body: some View {
        FormView(title: "Setup Recordings") {
            VStack(alignment: .leading, spacing: 8) {
                Text("You can enable camera recording when Sentry Mode is activated. Please remember to respect the privacy of others.")
                Divider()
                Toggle(isOn: $vm.cfg.sentryRecordingEnabled) {
                    Text("Enable Camera Recording")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Rectangle()
                .foregroundStyle(.black)
                .frame(height: 150)
        }
    }
}

#Preview {
    SetupRecordingsView()
}
