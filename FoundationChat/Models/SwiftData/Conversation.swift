import Foundation
import StructuredQueries

@Table
struct Conversation{
  let id: Int
  var summary: String = ""
}
