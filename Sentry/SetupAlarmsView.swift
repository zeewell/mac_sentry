//
//  SetupAlarmsView.swift
//  Sentry
//
//  Created by 秋星桥 on 5/24/25.
//

import SwiftUI

struct SetupAlarmsView: View {
    @StateObject var vm = SentryConfigurationManager.shared

    var body: some View {
        FormView(title: "Setup Alarm Triggers") {
            VStack(alignment: .leading, spacing: 8) {
                Text("Alarm triggers are used to fire the alarm when certain conditions are met.")
                    .fixedSize(horizontal: false, vertical: true)
                Divider()
                Toggle(isOn: $vm.cfg.sentryTriggersLidEnabled) {
                    Text("Closing Lid")
                }
                Toggle(isOn: $vm.cfg.sentryTriggersInternetEnabled) {
                    Text("Disconnected from Internet")
                }
                Toggle(isOn: $vm.cfg.sentryTriggersPowerEnabled) {
                    Text("Disconnected from Power Adapter")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    SetupAlarmsView()
}
