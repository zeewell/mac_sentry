//
//  ContentView.swift
//  Sentry
//
//  Created by 秋星桥 on 5/24/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var vm: ViewModel = .shared
    @State var sentry: Sentry? = nil
    @State var hint: String = ""

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        switch vm.status {
        case .welcome:
            WelcomePanel()
                .onReceive(timer) { _ in
                    guard vm.status == .welcome else { return }
                    guard sentry == nil else { return }
                    guard let check = DeviceCheck.isMacLocked(), check else { return }
                    let sentry: Sentry = .init(
                        configuration: SentryConfigurationManager.shared.cfg
                    ) { alarmingReason in
                        print("[*] alarming reason: \(alarmingReason)")
                        vm.status = .activityDetected
                        hint = String(localized: "An alarm was triggered at: \(Date().formatted()). Reason: \(alarmingReason)")
                    }
                    self.sentry = sentry
                    sentry.run()
                    vm.status = .running
                }
        case .running:
            VStack(spacing: 32) {
                EyeView()
            }
            .padding(64)
            .onReceive(timer) { _ in
                guard vm.status == .running else { return }
                guard let sentry else { return }
                if DeviceCheck.isMacLocked() ?? true { return }
                vm.status = .completed
                sentry.stop()
            }
        case .activityDetected:
            VStack(spacing: 16) {
                Image(systemName: "light.beacon.max")
                    .font(.largeTitle)
                Text("Activity Detected")
                    .bold()
                Divider()
                Text(hint)
                Divider()
                Button("Exit") {
                    exit(0)
                }
            }
            .padding(64)
            .onReceive(timer) { _ in
                guard vm.status == .activityDetected else { return }
                guard let sentry else { return }
                // if the mac is locked, continue to run
                if DeviceCheck.isMacLocked() ?? true { return }
                // unlocked, stop the sentry
                sentry.stop()
            }
        case .completed:
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.green)
                Text("Sentry Mode Completed")
                    .bold()
                Divider()
                HStack {
                    if sentry?.configuration.sentryRecordingEnabled ?? false {
                        Button("Open Saved Clips") {
                            try? FileManager.default.createDirectory(
                                atPath: videoClipDir.path,
                                withIntermediateDirectories: true
                            )
                            // select the directory
                            NSWorkspace.shared.selectFile(
                                nil,
                                inFileViewerRootedAtPath: videoClipDir.path
                            )
                        }
                    }
                    Button("Exit") {
                        exit(0)
                    }
                }
            }
            .padding(64)
            .onAppear {
                sentry?.stop()
            }
        }
    }
}

class ViewModel: ObservableObject {
    static let shared = ViewModel()
    private init() {}

    enum PanelStatus {
        case welcome
        case running
        case activityDetected
        case completed
    }

    @Published var status: PanelStatus = .welcome
}

#Preview {
    ContentView()
}
