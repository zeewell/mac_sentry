//
//  ContentView.swift
//  Sentry
//
//  Created by 秋星桥 on 5/24/25.
//

import ColorfulX
import SwiftUI

struct ContentView: View {
    @State var openHint: Bool = false
    @AppStorage("isFirstVisit") var isFirstVisit: Bool = true

    var versionText: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        return String(localized: "Version \(version) (\(build))")
    }

    var body: some View {
        VStack(spacing: 32) {
            Divider().hidden()
            Image(.icon512)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 64, height: 64)
                .padding(-8)
            Text("Welcome to Sentry Mode")
                .font(.title)
                .bold()
            HStack(spacing: 16) {
                options
            }
            .padding(.horizontal, 16)
            Text(versionText)
                .font(.footnote)
                .opacity(0.5)
            Divider().hidden()
        }
        .frame(width: 600)
        .overlay {
            Image(systemName: "questionmark.circle")
                .font(.body)
                .opacity(0.5)
                .contentShape(Circle())
                .onTapGesture { openHint = true }
                .popover(isPresented: $openHint) { HelpPanelView() }
                .padding(8)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        }
        .onAppear {
            if isFirstVisit {
                openHint = true
                isFirstVisit = false
            }
        }
    }

    @State var openSetupAlarm: Bool = false
    @State var openSetupNotifications: Bool = false
    @State var openSetupRecordings: Bool = false

    @ViewBuilder
    var options: some View {
        SentryOption(
            icon: "light.beacon.max",
            text: "Setup Alarms",
            isActivated: false
        )
        .onTapGesture { openSetupAlarm = true }
        .sheet(isPresented: $openSetupAlarm) {
            SetupAlarmsView()
        }
        SentryOption(
            icon: "app.badge",
            text: "Setup Notifications",
            isActivated: false
        )
        .onTapGesture { openSetupNotifications = true }
        .sheet(isPresented: $openSetupNotifications) {
            SetupNotificationsView()
        }
        SentryOption(
            icon: "camera",
            text: "Setup Recordings",
            isActivated: false
        )
        .onTapGesture { openSetupRecordings = true }
        .sheet(isPresented: $openSetupRecordings) {
            SetupRecordingsView()
        }
    }
}

struct SentryOption: View {
    let icon: String
    let text: LocalizedStringKey
    let isActivated: Bool

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .bold()
            Text(text)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .padding(.horizontal, 8)
        .background(Color.gray.opacity(0.1))
        .contentShape(Rectangle())
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    ContentView()
}
