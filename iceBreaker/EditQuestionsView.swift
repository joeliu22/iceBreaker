import SwiftUI

struct EditQuestionsView: View {
    @ObservedObject var viewModel: QuestionViewModel
    @Environment(\.dismiss) var dismiss
    @State private var questionsText: String = ""
    @State private var showingDiscardAlert = false
    @State private var hasChanges = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Edit categories and questions:")
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
                    .onChange(of: questionsText) { _ in
                        hasChanges = true
                    }
            }
            .padding()
            .navigationTitle("Edit Questions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if hasChanges {
                            showingDiscardAlert = true
                        } else {
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.updateFromText(questionsText)
                        dismiss()
                    }
                }
            }
            .onAppear {
                questionsText = formatExistingQuestions(from: viewModel.categories)
                hasChanges = false
            }
            .alert("Discard Changes?", isPresented: $showingDiscardAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Discard", role: .destructive) {
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to discard your changes?")
            }
        }
    }
    
    private func formatExistingQuestions(from categories: [QuestionCategory]) -> String {
        var formattedText = ""
        
        for (index, category) in categories.enumerated() {
            formattedText += "[\(category.name)]\n"
            for question in category.questions {
                formattedText += "\(question.question)\n"
            }
            if index < categories.count - 1 {
                formattedText += "\n"
            }
        }
        
        return formattedText
    }
} 