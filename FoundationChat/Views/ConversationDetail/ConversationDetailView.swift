import FoundationModels
import SwiftUI
import SharingGRDB

struct ConversationDetailView: View {
  @Dependency(\.defaultDatabase) var database
  @Environment(ChatEngine.self) private var chatEngine

  @State var newMessage: String = ""
  let conversation: Conversation
  @FetchAll(
      Message
        .where(\.conversationId == conversation.id)
        .order(\.timestamp)
  )
  var messages: [Message]
  @State var scrollPosition: ScrollPosition = .init()
  @State var isGenerating: Bool = false
  @FocusState var isInputFocused: Bool
  
  init(conversation: Conversation) {
    self.conversation = conversation
  }
  

  var body: some View {
    ScrollView {
      LazyVStack {
        ForEach(messages) { message in
          MessageView(message: message)
            .id(message.id)
        }
      }
      .scrollTargetLayout()
      .padding(.bottom, 50)
    }
    .onAppear {
      isInputFocused = true
      withAnimation {
        scrollPosition.scrollTo(edge: .bottom)
      }
    }
    .scrollDismissesKeyboard(.interactively)
    .scrollPosition($scrollPosition, anchor: .bottom)
    .navigationTitle("Messages")
    .navigationBarTitleDisplayMode(.inline)
    .toolbarRole(.editor)
    .toolbar {
      ConversationDetailInputView(
        newMessage: $newMessage,
        isGenerating: $isGenerating,
        isInputFocused: $isInputFocused,
        onSend: {
          isGenerating = true
          await streamNewMessage()
          await updateConversationSummary()
          isGenerating = false
        }
      )
    }
  }
}

extension ConversationDetailView {
  private func streamNewMessage() async throws {
    do {
        try database.write { db in
          try Message.Draft(
            content: newMessage,
            role: .user,
            timestamp: Date(),
            conversationId: conversation.id
          ).insert(db)
        }
      newMessage = ""
      
      withAnimation {
        scrollPosition.scrollTo(edge: .bottom)
      }
      
      if let stream = await chatEngine.respondTo() {
        let assistantDraft = await MainActor.run {
          Message.Draft(
            content: "...",
            role: .assistant,
            timestamp: Date(),
            conversationId: conversation.id
          )
        }
        let assistantMessage = try database.write { db in
          try assistantDraft.inserted(db)
        }

        do {
          for try await part in stream {
            try database.write { db in
              try Message
                .find(assistantMessage.id)
                .update(db) {
                  $0.content = part.content ?? ""
                  $0.attachementTitle = part.metadata?.title
                  $0.attachementThumbnail = part.metadata?.thumbnail
                  $0.attachementDescription = part.metadata?.description
                }
            }
            
            await MainActor.run {
              scrollPosition.scrollTo(edge: .bottom)
            }
          }
        } catch {
          try database.write { db in
            try Message
              .find(assistantMessage.id)
              .update(db) {
                $0.content = "Error: \(error.localizedDescription)"
              }
          }
        }
      }
    } catch {
      print("Error saving message: \(error)")
    }
  }

  private func updateConversationSummary() async {
    if let stream = await chatEngine.summarize() {
      do {
        for try await part in stream {
          try database.write { db in
            try Conversation
              .find(conversation.id)
              .update(db) {
                $0.summary = part
              }
          }
        }
      } catch {
        try? database.write { db in
          try Conversation
            .find(conversation.id)
            .update(db) {
              $0.summary = "Error: \(error.localizedDescription)"
            }
        }
      }
    }
  }
}

#Preview {
  @Previewable var conversation: Conversation = .init(
    id: 1,
    summary: "A preview conversation")
  ConversationDetailView(conversation: conversation)
  .environment(ChatEngine(conversation: conversation))
}

