import SwiftUI

struct ShuffleEffect: ViewModifier {
    let isPresented: Bool
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                Angle(degrees: isPresented ? 0 : 30),
                axis: (x: 0, y: 1, z: 0)
            )
    }
}

extension AnyTransition {
    static var shuffle: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.7)
                .combined(with: .offset(x: 300, y: 0))
                .combined(with: .opacity)
                .animation(.spring(response: 0.5, dampingFraction: 0.8)),
            removal: .scale(scale: 0.7)
                .combined(with: .offset(x: -300, y: 0))
                .combined(with: .opacity)
                .animation(.spring(response: 0.5, dampingFraction: 0.8))
        )
    }
}

struct PlayModeView: View {
    @ObservedObject var viewModel: QuestionViewModel
    @Environment(\.dismiss) var dismiss
    @State private var currentQuestion: Question?
    @State private var usedQuestions: Set<UUID> = []
    @State private var isOutOfQuestions = false
    @State private var currentCardId = UUID()
    @State private var showingCategorySelection = true
    @State private var selectedCategories: Set<UUID> = []
    
    var body: some View {
        if showingCategorySelection {
            CategorySelectionView(
                categories: viewModel.categories,
                selectedCategories: $selectedCategories,
                onStart: {
                    showingCategorySelection = false
                }
            )
        } else {
            gameView
        }
    }
    
    private var gameView: some View {
        ZStack {
            Color(.systemBackground)
                .edgesIgnoringSafeArea(.all)
            
            if isOutOfQuestions {
                CoverCard(isOutOfQuestions: true)
                    .modifier(ShuffleEffect(isPresented: true))
                    .transition(.shuffle)
                    .id(currentCardId)
            } else if let question = currentQuestion {
                PlayQuestionCard(question: question)
                    .modifier(ShuffleEffect(isPresented: true))
                    .transition(.shuffle)
                    .id(currentCardId)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            currentCardId = UUID()
                            drawNextQuestion()
                        }
                    }
            } else {
                CoverCard(isOutOfQuestions: false)
                    .modifier(ShuffleEffect(isPresented: true))
                    .transition(.shuffle)
                    .id(currentCardId)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            currentCardId = UUID()
                            drawNextQuestion()
                        }
                    }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Change Categories") {
                    showingCategorySelection = true
                }
            }
        }
    }
    
    private func drawNextQuestion() {
        if let question = getRandomQuestion(excluding: usedQuestions) {
            currentQuestion = question
            usedQuestions.insert(question.id)
            isOutOfQuestions = false
        } else {
            isOutOfQuestions = true
        }
    }
    
    private func getRandomQuestion(excluding used: Set<UUID>) -> Question? {
        let relevantCategories = selectedCategories.isEmpty ? 
            viewModel.categories : 
            viewModel.categories.filter { selectedCategories.contains($0.id) }
        
        let allQuestions = relevantCategories.flatMap { $0.questions }
        let availableQuestions = allQuestions.filter { !used.contains($0.id) }
        return availableQuestions.randomElement()
    }
}

struct CoverCard: View {
    var isOutOfQuestions: Bool
    
    var body: some View {
        ZStack {
            // Card background
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.blue)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
            
            // Card content
            VStack(spacing: 20) {
                Image(systemName: isOutOfQuestions ? "exclamationmark.circle" : "hand.tap")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                
                Text(isOutOfQuestions ? "No more questions!" : "Tap to see question")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            .padding(30)
        }
        .frame(width: 300, height: 400)
        .padding()
    }
}

struct PlayQuestionCard: View {
    let question: Question
    
    var body: some View {
        ZStack {
            // Card background
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            
            // Card content
            VStack(spacing: 20) {
                // Top decoration
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                
                // Question text
                Text(question.question)
                    .font(.title3)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                Text("Tap to continue")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top)
            }
            .padding(30)
        }
        .frame(width: 300, height: 400)
        .padding()
    }
}

struct CategorySelectionView: View {
    let categories: [QuestionCategory]
    @Binding var selectedCategories: Set<UUID>
    let onStart: () -> Void
    
    var body: some View {
        NavigationView {
            List(selection: $selectedCategories) {
                Section {
                    Text("All Categories")
                        .onTapGesture {
                            selectedCategories.removeAll()
                        }
                        .listRowBackground(selectedCategories.isEmpty ? Color.blue.opacity(0.1) : nil)
                }
                
                Section("Select Categories") {
                    ForEach(categories) { category in
                        HStack {
                            Text(category.name)
                            Spacer()
                            if selectedCategories.contains(category.id) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedCategories.contains(category.id) {
                                selectedCategories.remove(category.id)
                            } else {
                                selectedCategories.insert(category.id)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Choose Categories")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Start") {
                        onStart()
                    }
                }
            }
        }
    }
} 
