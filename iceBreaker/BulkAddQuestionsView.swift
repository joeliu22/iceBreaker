import SwiftUI

struct BulkAddQuestionsView: View {
    @ObservedObject var viewModel: QuestionViewModel
    @Environment(\.dismiss) var dismiss
    @State private var questionsText: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Enter questions in the following format:")
                    .font(.caption)
                Text("""
                [Category Name]
                Question 1
                Question 2
                
                [Another Category]
                Question 3
                Question 4
                """)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
                
                TextEditor(text: $questionsText)
                    .font(.body)
                    .padding(4)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
            }
            .padding()
            .navigationTitle("Bulk Add Questions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        // Parse text into categories and questions
                        let lines = questionsText.split(separator: "\n")
                        var currentCategory: String?
                        var questionsToAdd: [String: [String]] = [:]
                        
                        for line in lines {
                            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
                            if trimmedLine.isEmpty { continue }
                            
                            // Check if line is a category header
                            if trimmedLine.hasPrefix("[") && trimmedLine.hasSuffix("]") {
                                currentCategory = String(trimmedLine.dropFirst().dropLast())
                                if !currentCategory!.isEmpty {
                                    questionsToAdd[currentCategory!] = []
                                }
                            } else if let category = currentCategory {
                                questionsToAdd[category]?.append(trimmedLine)
                            }
                        }
                        
                        // Add questions to each category
                        for (categoryName, questions) in questionsToAdd {
                            // Find or create category
                            if let existingCategoryIndex = viewModel.categories.firstIndex(where: { $0.name == categoryName }) {
                                // Add questions to existing category
                                let newQuestions = questions.map { Question(question: $0) }
                                viewModel.categories[existingCategoryIndex].questions.append(contentsOf: newQuestions)
                            } else {
                                // Create new category with questions
                                let newQuestions = questions.map { Question(question: $0) }
                                let newCategory = QuestionCategory(name: categoryName, questions: newQuestions)
                                viewModel.categories.append(newCategory)
                            }
                        }
                        dismiss()
                    }
                }
            }
            .onAppear {
                // Format existing categories and questions
                questionsText = formatExistingQuestions(from: viewModel.categories)
            }
        }
    }
    
    private func formatExistingQuestions(from categories: [QuestionCategory]) -> String {
        var formattedText = ""
        
        for (index, category) in categories.enumerated() {
            // Add category header
            formattedText += "[\(category.name)]\n"
            
            // Add questions
            for question in category.questions {
                formattedText += "\(question.question)\n"
            }
            
            // Add extra newline between categories, but not after the last one
            if index < categories.count - 1 {
                formattedText += "\n"
            }
        }
        
        return formattedText
    }
}

// Add this extension to remove duplicates while preserving order
extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
} 
