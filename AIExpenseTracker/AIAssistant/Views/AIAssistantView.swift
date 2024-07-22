//
//  AIAssistantView.swift
//  AIExpenseTracker
//
//  Created by Miguel Angel Gutierrez Maya on 12/07/24.
//

import ChatGPTUI
import SwiftUI

enum ChatType: String, Identifiable, CaseIterable {
    case text = "Text"
    case voice = "Voice"
    var id: Self { self }
}

struct AIAssistantView: View {
    @State private var textChatVM = AIAssistantTextChatViewModel(
        apiKey: Private.apiKey
    )
    @State private var voiceChatVM = AIAssistantVoiceChatViewModel(
        apiKey: Private.apiKey
    )
    @State private var chatType = ChatType.text
    
    var body: some View {
        VStack(spacing: 0) {
            Picker(
                selection: $chatType,
                label: Text("Chat Type")
                    .font(.system(
                        size: 12,
                        weight: .bold
                    ))
            ) {
                ForEach(ChatType.allCases) { type in
                    Text(type.rawValue)
                        .tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
#if !os(iOS)
            .padding(.vertical)
#endif
            
            Divider()
            
            ZStack {
                switch chatType {
                case .text:
                    TextChatView(
                        customContentVM: textChatVM
                    )
//                    TextChatView(
//                        senderImage: Constants.senderImage,
//                        botImage: Constants.botImage,
//                        apiKey: Constants.apiKey
//                    )
                case .voice:
//                    VoiceChatView(
//                        apiKey: Constants.apiKey
//                    )
                    VoiceChatView(
                        customContentVM: voiceChatVM
                    )
                }
            }.frame(maxWidth: 1024, alignment: .center)
        }
        
#if !os(macOS)
        .navigationBarTitle(
            "XCA AI Expense Assistant",
            displayMode: .inline
        )
#endif
    }
}

#Preview {
    AIAssistantView()
}
