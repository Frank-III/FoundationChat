import FoundationModels
import StructuredQueries

@Generable
enum Role: String, Codable, Hashable, CaseIterable, QueryBindable {
  case user = "User"
  case assistant = "Assistant"
  case system = "System"
}
