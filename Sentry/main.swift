//
//  main.swift
//  Sentry
//
//  Created by 秋星桥 on 5/24/25.
//

import Foundation

#if !DEBUG
    fclose(stdout)
    fclose(stderr)

    Security.removeDebugger()
    guard Security.validateAppSignature() else {
        Security.crashOut()
    }
#endif

do {
    // make sure sandbox is enabled otherwise panic the app
    let sandboxTestDir = URL(fileURLWithPath: "/tmp/sandbox.test.\(UUID().uuidString)")
    FileManager.default.createFile(atPath: sandboxTestDir.path, contents: nil, attributes: nil)
    if FileManager.default.fileExists(atPath: sandboxTestDir.path) {
        fatalError("This app should not run outside of sandbox which may cause trouble.")
    }
}

let documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
let videoClipDir = documentDir.appendingPathComponent("VideoClip")

App.main()
