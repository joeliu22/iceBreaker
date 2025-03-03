import Foundation

struct Question: Identifiable, Codable, Hashable {
    let id: UUID
    let question: String
    
    init(id: UUID = UUID(), question: String) {
        self.id = id
        self.question = question
    }
}