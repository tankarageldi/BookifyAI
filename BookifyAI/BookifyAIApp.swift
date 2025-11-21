import SwiftUI
import SwiftData

@main
struct BookSimplifyApp: App {
    var body: some Scene {
        WindowGroup {
            SidebarView()
        }
        .modelContainer(for: [Book.self, Page.self])
    }
}
