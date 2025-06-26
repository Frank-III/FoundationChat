import Foundation
import StructuredQueries

@Table
struct Conversation: @MainActor Identifiable {
  let id: Int
  var summary: String = ""
}
