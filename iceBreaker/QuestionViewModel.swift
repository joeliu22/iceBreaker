import Foundation
import SwiftUI

@MainActor
class QuestionViewModel: ObservableObject {
    @Published var categories: [QuestionCategory] = []
    @Published var currentQuestion: Question?
    
    private let saveKey = "IceBreakerCategories"
    
    init() {
        loadCategories()
    }
    
    func loadCategories() {
        if let data = UserDefaults.standard.data(forKey: saveKey) {
            if let decoded = try? JSONDecoder().decode([QuestionCategory].self, from: data) {
                categories = decoded
                return
            }
        }
        // Default empty categories array if nothing is saved
        categories = []
    }
    
    func saveCategories() {
        if let encoded = try? JSONEncoder().encode(categories) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    func addCategory(_ name: String) {
        let category = QuestionCategory(name: name)
        categories.append(category)
        saveCategories()
    }
    
    func deleteCategory(at indexSet: IndexSet) {
        categories.remove(atOffsets: indexSet)
        saveCategories()
    }
    
    func addQuestion(_ question: String, to categoryId: UUID) {
        guard let categoryIndex = categories.firstIndex(where: { $0.id == categoryId }) else { return }
        let newQuestion = Question(question: question)
        categories[categoryIndex].questions.append(newQuestion)
        saveCategories()
    }
    
    func deleteQuestion(at indexSet: IndexSet, from categoryId: UUID) {
        guard let categoryIndex = categories.firstIndex(where: { $0.id == categoryId }) else { return }
        categories[categoryIndex].questions.remove(atOffsets: indexSet)
        saveCategories()
    }
    
    func getRandomQuestion(excluding used: Set<UUID>) -> Question? {
        let allQuestions = categories.flatMap { $0.questions }
        let availableQuestions = allQuestions.filter { !used.contains($0.id) }
        return availableQuestions.randomElement()
    }
    
    func updateFromText(_ text: String) {
        var newCategories: [QuestionCategory] = []
        var currentCategory: QuestionCategory?
        
        let lines = text.components(separatedBy: .newlines)
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            if trimmedLine.isEmpty { continue }
            
            if trimmedLine.hasPrefix("[") && trimmedLine.hasSuffix("]") {
                // If we have a previous category, add it to our list
                if let category = currentCategory {
                    newCategories.append(category)
                }
                
                // Start a new category
                let categoryName = String(trimmedLine.dropFirst().dropLast())
                currentCategory = QuestionCategory(name: categoryName)
                
            } else if let category = currentCategory {
                // Add question to current category
                let question = Question(question: trimmedLine)
                currentCategory?.questions.append(question)
            }
        }
        
        // Add the last category if it exists
        if let category = currentCategory {
            newCategories.append(category)
        }
        
        // Update and save the new categories
        categories = newCategories
        saveCategories()
    }
} 
