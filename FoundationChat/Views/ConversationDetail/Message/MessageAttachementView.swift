import SwiftUI

struct MessageAttachementView: View {
    let message: Message

  var body: some View {
    if message.attachementTitle != nil || message.attachementThumbnail != nil
      || message.attachementDescription != nil
    {
      VStack {
        if let attachementThumbnail = message.attachementThumbnail {
          AsyncImage(url: URL(string: attachementThumbnail)) { state in
            if let image = state.image {
              image
                .resizable()
                .scaledToFill()
                .frame(height: 100)
                .clipped()
            } else {
              Color.secondary
            }
          }
        }
        if let attachementTitle = message.attachementTitle {
          Text(attachementTitle)
            .foregroundStyle(.white)
            .font(.title3)
            .contentTransition(.interpolate)
            .padding(.top)
            .padding(.horizontal)
            .fixedSize(horizontal: false, vertical: true)
        }
        if let attachementDescription = message.attachementDescription {
          Text(attachementDescription)
            .foregroundStyle(.white)
            .font(.subheadline)
            .contentTransition(.interpolate)
            .padding(.horizontal)
            .padding(.bottom)
            .fixedSize(horizontal: false, vertical: true)
        }
      }
      .background(.secondary)
      .cornerRadius(16)
    }
  }
}

#Preview {
  VStack(spacing: 20) {
    // Preview with full attachment data
    MessageAttachementView(message: Message(
      id: 1,
      content: "Check out this link!",
      role: .assistant,
      timestamp: Date(),
      conversationId: 1,
      attachementTitle: "SwiftUI Tutorial",
      attachementDescription: "Learn how to build beautiful iOS apps with SwiftUI. This comprehensive guide covers everything from basic views to advanced animations.",
      attachementThumbnail: "https://developer.apple.com/assets/elements/icons/swiftui/swiftui-96x96_2x.png"
    ))
    
    // Preview with title only
    MessageAttachementView(message: Message(
      id: 2,
      content: "Another link",
      role: .assistant,
      timestamp: Date(),
      conversationId: 1,
      attachementTitle: "Apple Developer Documentation"
    ))
    
    // Preview with no attachment (should show nothing)
    MessageAttachementView(message: Message(
      id: 3,
      content: "Plain message",
      role: .user,
      timestamp: Date(),
      conversationId: 1
    ))
  }
  .padding()
}
