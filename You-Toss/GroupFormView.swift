//
//  GroupFormView.swift
//  You-Toss
//
//  Created by Tony Hunt on 12/31/25.
//

import SwiftUI

struct GroupFormView: View {

    enum Mode {
        case create
        case join
    }

    let mode: Mode

    @State private var groupName = ""
    @State private var passcode = ""

    var body: some View {
        VStack(spacing: 24) {

            // Title
            Text(mode == .create ? "Create Group" : "Join Group")
                .font(.largeTitle)
                .fontWeight(.bold)

            // Group name
            TextField("Group name", text: $groupName)
                .textInputAutocapitalization(.words)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

            // Password / Passcode
            SecureField(
                mode == .create ? "Password" : "Group passcode",
                text: $passcode
            )
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)

            // Primary button
            Button(action: {
                // Create / Join logic later
            }) {
                Text(mode == .create ? "Create" : "Join")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }

            Spacer()
        }
        .padding()
    }
}

// MARK: - Preview

#Preview {
    GroupFormView(mode: .create)
}
