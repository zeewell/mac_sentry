//
//  FormView.swift
//  Sentry
//
//  Created by 秋星桥 on 5/24/25.
//

import SwiftUI

struct FormView<Content: View>: View {
    let title: LocalizedStringKey
    @ViewBuilder let formBody: () -> Content
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text(title)
                    .bold()
                Spacer()
            }
            Divider().padding(.horizontal, -16)
            formBody()
            Divider().padding(.horizontal, -16)
            HStack {
                Spacer()
                Button("Close") {
                    dismiss()
                }
            }
        }
        .padding(16)
        .frame(width: 400)
        .background(.background)
    }
}
