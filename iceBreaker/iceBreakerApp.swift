import SwiftUI

@main
struct iceBreakerApp: App {
    @StateObject private var viewModel = QuestionViewModel()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                QuestionsManagementView(viewModel: viewModel)
            }
        }
    }
}
