import SwiftUI

struct QuestionsManagementView: View {
    @ObservedObject var viewModel: QuestionViewModel
    @State private var showingBulkAdd = false
    @State private var showingAddCategory = false
    @State private var showingPlayMode = false
    @State private var newCategoryName = ""
    @State private var selectedCategoryId: UUID?
    @State private var showingDeleteAlert = false
    @State private var categoryToDelete: QuestionCategory?
    @State private var showingEditView = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Category Tabs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(viewModel.categories) { category in
                        CategoryTab(
                            name: category.name,
                            isSelected: selectedCategoryId == category.id,
                            onDelete: {
                                categoryToDelete = category
                                showingDeleteAlert = true
                            }
                        )
                        .onTapGesture {
                            withAnimation {
                                selectedCategoryId = category.id
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top)
            
            // Questions List
            if let selectedId = selectedCategoryId,
               let category = viewModel.categories.first(where: { $0.id == selectedId }) {
                List {
                    ForEach(category.questions) { question in
                        QuestionCard(
                            question: question,
                            onDelete: {
                                if let index = category.questions.firstIndex(where: { $0.id == question.id }) {
                                    viewModel.deleteQuestion(at: IndexSet([index]), from: category.id)
                                }
                            }
                        )
                    }
                    .onDelete { indexSet in
                        viewModel.deleteQuestion(at: indexSet, from: category.id)
                    }
                }
            } else {
                Text("Select a category or add a new one")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle("Questions")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { showingPlayMode = true }) {
                    Label("Play", systemImage: "play.fill")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingEditView = true }) {
                    Label("Edit All", systemImage: "pencil")
                }
            }
        }
        .onAppear {
            // Select first category by default
            if selectedCategoryId == nil && !viewModel.categories.isEmpty {
                selectedCategoryId = viewModel.categories[0].id
            }
        }
        .sheet(isPresented: $showingEditView) {
            EditQuestionsView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingPlayMode) {
            PlayModeView(viewModel: viewModel)
        }
        .alert("Delete Category", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let category = categoryToDelete,
                   let index = viewModel.categories.firstIndex(where: { $0.id == category.id }) {
                    viewModel.deleteCategory(at: IndexSet([index]))
                    if selectedCategoryId == category.id {
                        selectedCategoryId = viewModel.categories.first?.id
                    }
                }
            }
        } message: {
            Text("Are you sure you want to delete this category and all its questions?")
        }
    }
}

struct CategoryTab: View {
    let name: String
    let isSelected: Bool
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Text(name)
                .fontWeight(isSelected ? .bold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red.opacity(0.8))
                    .font(.system(size: 16))
            }
            .padding(.trailing, 8)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
        )
        .padding(.vertical, 4)
        .padding(.horizontal, 4)
    }
}

struct QuestionCard: View {
    let question: Question
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(question.question)
                    .font(.body)
                    .padding(.trailing)
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
} 
