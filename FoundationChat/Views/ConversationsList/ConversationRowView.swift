import SwiftUI
import SharingGRDB

struct ConversationRowView: View {
  let conversation: Conversation
  
  @FetchAll var lastMessage: [Message]
  
  init(conversation: Conversation) {
    self.conversation = conversation
    self._lastMessage = FetchAll(
      Message
        .where(\.conversationId == conversation.id)
        .order(\.timestamp.desc())
        .limit(1)
    )
  }

  var body: some View {
    HStack(alignment: .center) {
      VStack(alignment: .leading) {
        Text(lastMessage.first?.role.rawValue ?? "New Chat")
          .font(.headline)
          .fontWeight(.bold)
        Text(conversation.summary)
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .contentTransition(.interpolate)
      }
      .animation(.bouncy, value: conversation.summary)
      Spacer()
      if let timestamp = lastMessage.first?.timestamp {
        Text(timestamp.formatted(date: .omitted, time: .shortened))
          .font(.caption)
          .foregroundStyle(.secondary)
      }
    }
  }
}
