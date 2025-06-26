import SwiftUI
import SharingGRDB

struct ConversationsListView: View {
  @FetchAll(
    Conversation
      .leftJoin(Message.all) { $0.id == $1.conversationId }
      .group(by: \.id)
      .order(Message.column("timestamp").max().desc())
      .select { $0 }
  )
  var conversations: [Conversation]
  
  @Dependency(\.defaultDatabase) var database
  
  private func deleteConversation(_ conversation: Conversation) {
    do {
      try database.write { db in
        try Message
          .filter(\.conversationId == conversation.id)
          .deleteAll(db)
        try Conversation
          .filter(\.id == conversation.id)
          .deleteAll(db)
      }
    } catch {
      print("Error deleting conversation: \(error)")
    }
  }

  var body: some View {
    NavigationStack {
      List {
        ForEach(conversations) { conversation in
          NavigationLink(value: conversation) {
            ConversationRowView(conversation: conversation)
              .swipeActions {
                Button(role: .destructive) {
                  deleteConversation(conversation)
                } label: {
                  Label("Delete", systemImage: "trash")
                }
              }
          }
        }
        .listSectionSeparator(.hidden, edges: .top)
      }
      .listStyle(.plain)
      .navigationDestination(for: Conversation.self) { conversation in
        ConversationDetailView(conversation: conversation)
          .environment(ChatEngine(conversation: conversation))
      }
      .navigationTitle("Conversations")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            do {
              try database.write { db in
                try Conversation.Draft(summary: "New conversation").insert(db)
              }
            } catch {
              print("Error creating conversation: \(error)")
            }
          } label: {
            Image(systemName: "plus")
          }
        }
      }
    }
  }
}
