import SwiftUI
import SharingGRDB

@main
struct FoundationChatApp: App {
  init() {
    prepareDependencies {
      do {
        let dbPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let dbURL = URL(fileURLWithPath: dbPath).appendingPathComponent("FoundationChat.sqlite")
        
        var config = Configuration()
        config.foreignKeysEnabled = true
        config.prepareDatabase { db in
          #if DEBUG
          db.trace(options: .profile) { print($0.expandedDescription) }
          #endif
        }
        
        let db = try DatabaseQueue(path: dbURL.path, configuration: config)
        try setupDatabase(db)
        $0.defaultDatabase = db
      } catch {
        fatalError("Failed to setup database: \(error)")
      }
    }
  }
  
  var body: some Scene {
    WindowGroup {
      ConversationsListView()
    }
  }
}

private func setupDatabase(_ db: DatabaseQueue) throws {
  var migrator = DatabaseMigrator()
  
  #if DEBUG
  migrator.eraseDatabaseOnSchemaChange = true
  #endif
  
  migrator.registerMigration("Create tables") { db in
    try #sql(
      """
      CREATE TABLE IF NOT EXISTS "conversations" (
        "id" INTEGER PRIMARY KEY AUTOINCREMENT,
        "summary" TEXT NOT NULL DEFAULT ''
      ) STRICT
      """
    ).execute(db)
    
    try #sql(
      """
      CREATE TABLE IF NOT EXISTS "messages" (
        "id" INTEGER PRIMARY KEY AUTOINCREMENT,
        "content" TEXT NOT NULL,
        "role" TEXT NOT NULL,
        "timestamp" TEXT NOT NULL,
        "conversationId" INTEGER NOT NULL REFERENCES "conversations"("id") ON DELETE CASCADE,
        "attachementTitle" TEXT,
        "attachementDescription" TEXT,
        "attachementThumbnail" TEXT,
        "attachementSummary" TEXT
      ) STRICT
      """
    ).execute(db)
  }
  
  try migrator.migrate(db)
}
