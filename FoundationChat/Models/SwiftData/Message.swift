import Foundation
import StructuredQueries

struct Message: Identifiable {
  let id: Int
  var content: String
  var role: Role
    
  var timestamp: Date
  var conversationId: Int

  var attachementTitle: String?
  var attachementDescription: String?
  var attachementThumbnail: String?
  var attachementSummary: String?
}
