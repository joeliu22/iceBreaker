import Foundation

struct QuestionCategory: Identifiable, Codable {
    let id: UUID
    var name: String
    var questions: [Question]
    
    init(id: UUID = UUID(), name: String, questions: [Question] = []) {
        self.id = id
        self.name = name
        self.questions = questions
    }
} 