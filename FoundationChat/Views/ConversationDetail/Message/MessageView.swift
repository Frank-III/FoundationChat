import SwiftUI

struct MessageView: View {
    let message: Message

  var body: some View {
    HStack {
      if message.role == .user {
        Spacer()
      }
      VStack(alignment: .leading) {
        MessageContentView(message: message)
        MessageAttachementView(message: message)
      }
      .padding()
      .glassEffect(
        .regular.tint(message.role == .user ? .blue : .green), in: .rect(cornerRadius: 16)
      )
      .padding(.horizontal)
      .animation(.bouncy, value: message.content)
      if message.role == .assistant {
        Spacer()
      }
    }
  }
}

#Preview {
  LazyVStack {
    MessageView(message: Message(
      id: 1,
      content: "Hello! This is a user message. How are you doing today?",
      role: .user,
      timestamp: Date(),
      conversationId: 1
    ))
    
    MessageView(message: Message(
      id: 2,
      content: "I'm doing great, thank you for asking! This is an assistant response with a longer message that demonstrates how the view handles multi-line content.",
      role: .assistant,
      timestamp: Date(),
      conversationId: 1
    ))
    
    MessageView(message: Message(
      id: 3,
      content: "Here's a message with an attachment!",
      role: .assistant,
      timestamp: Date(),
      conversationId: 1,
      attachementTitle: "SwiftUI Documentation",
      attachementDescription: "Learn how to build amazing apps with SwiftUI",
      attachementThumbnail: "https://developer.apple.com/assets/elements/icons/swiftui/swiftui-96x96_2x.png"
    ))
  }
  .padding()
}
