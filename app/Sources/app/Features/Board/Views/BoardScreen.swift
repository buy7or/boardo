import SwiftUI

struct BoardScreen: View {
    @State var viewModel: BoardViewModel
    @State private var showAddTaskSheet = false
    private let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]

    var body: some View {
        BoardSurface {
            VStack(spacing: 12) {
                CompactMonthCalendar(selectedDate: $viewModel.selectedDate)
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(Array(viewModel.boardTasks.enumerated()), id: \.element.id) { index, task in
                            StickyTaskCard(task: task, angle: rotation(for: index)) {
                                viewModel.toggleCompletion(taskID: task.id)
                            }
                        }

                        newNoteCard
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 88)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .overlay(alignment: .bottom) {
                BottomNavigationBar()
                    .padding(.horizontal, 16)
                    .padding(.bottom, 10)
            }
        }
        .sheet(isPresented: $showAddTaskSheet) {
            AddTaskSheet(selectedDate: viewModel.selectedDate) { title, notes, category, date in
                viewModel.addTask(title: title, notes: notes, category: category, dueDate: date)
            }
        }
    }

    private var newNoteCard: some View {
        Button {
            showAddTaskSheet = true
        } label: {
            VStack(spacing: 10) {
                Image(systemName: "plus")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(AppTheme.Colors.accent)
                    .clipShape(Circle())
                    .shadow(color: AppTheme.Shadow.card, radius: 6, x: 0, y: 4)
                Text("NEW NOTE")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.Colors.subtitle)
            }
            .frame(maxWidth: .infinity, minHeight: 140, maxHeight: 140)
            .overlay {
                RoundedRectangle(cornerRadius: AppTheme.Radius.sticky, style: .continuous)
                    .stroke(Color.gray.opacity(0.45), style: StrokeStyle(lineWidth: 1.2, dash: [5]))
            }
        }
        .buttonStyle(.plain)
    }

    private func rotation(for index: Int) -> Double {
        index.isMultiple(of: 2) ? -1.4 : 1.1
    }
}
