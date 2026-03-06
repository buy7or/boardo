import SwiftUI

struct ExpandedTaskEditor: View {
    let task: BoardTask
    let categories: [TaskCategory]
    let onClose: () -> Void
    let onSave: (_ title: String, _ notes: String, _ category: TaskCategory) -> Void
    let onToggleDone: () -> Void
    let onDelete: () -> Void

    @State private var title: String
    @State private var notes: String
    @State private var category: TaskCategory

    init(
        task: BoardTask,
        categories: [TaskCategory],
        onClose: @escaping () -> Void,
        onSave: @escaping (_ title: String, _ notes: String, _ category: TaskCategory) -> Void,
        onToggleDone: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.task = task
        self.categories = categories
        self.onClose = onClose
        self.onSave = onSave
        self.onToggleDone = onToggleDone
        self.onDelete = onDelete
        _title = State(initialValue: task.title)
        _notes = State(initialValue: task.notes)
        _category = State(
            initialValue: categories.first(where: { $0.id == task.category.id }) ?? categories.first ?? task.category
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack {
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(AppTheme.Colors.subtitle)
                            .frame(width: 30, height: 30)
                            .background(Color.white.opacity(0.7))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }

                ZStack(alignment: .top) {
                    Circle()
                        .fill(AppTheme.Colors.accent)
                        .frame(width: 18, height: 18)
                        .offset(y: -10)

                    VStack(alignment: .leading, spacing: 18) {
                        Text(L10n.tr("task.edit.dueToday"))
                            .font(.caption.weight(.bold))
                            .foregroundStyle(AppTheme.Colors.accent)

                        TextField(L10n.tr("task.edit.placeholder.title"), text: $title, axis: .vertical)
                            .font(AppTheme.Typography.stickyTitle)
                            .foregroundStyle(Color.black.opacity(0.9))
                            .lineLimit(1...3)
                            .strikethrough(task.isCompleted, color: AppTheme.Colors.accent)
                            .animation(.easeInOut(duration: 0.2), value: task.isCompleted)

                        TextEditor(text: $notes)
                            .font(AppTheme.Typography.stickyCardBody)
                            .foregroundStyle(Color.black.opacity(0.72))
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .frame(minHeight: 130)

                        HStack(spacing: 6) {
                            Image(systemName: "paperclip")
                            Text(L10n.tr("task.edit.attachment"))
                                .italic()
                        }
                        .font(.caption)
                        .foregroundStyle(AppTheme.Colors.subtitle)
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .background(category.color)
                    .overlay(alignment: .bottomTrailing) {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 34, height: 34)
                            .offset(x: 14, y: 14)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    .shadow(color: AppTheme.Shadow.card, radius: 12, x: 0, y: 8)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(categories) { item in
                            Button {
                                category = item
                            } label: {
                                Circle()
                                    .fill(item.color)
                                    .frame(width: 26, height: 26)
                                    .overlay {
                                        Image(systemName: item.icon)
                                            .font(.caption2.weight(.bold))
                                            .foregroundStyle(AppTheme.Colors.title.opacity(0.75))
                                    }
                                    .overlay {
                                        Circle()
                                            .stroke(AppTheme.Colors.accent, lineWidth: category == item ? 2 : 0)
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Text(L10n.tr("task.edit.finishedQuestion"))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.Colors.subtitle)

                Button {
                    onToggleDone()
                } label: {
                    Label(task.isCompleted ? L10n.tr("task.edit.markPending") : L10n.tr("task.edit.complete"), systemImage: "checkmark.circle")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(AppTheme.Colors.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .shadow(color: AppTheme.Shadow.card, radius: 8, x: 0, y: 4)
                }

                HStack(spacing: 14) {
                    Button(L10n.tr("common.delete")) {
                        onDelete()
                    }
                    .font(.subheadline)
                    .foregroundStyle(.red)

                    Button(L10n.tr("common.saveChanges")) {
                        onSave(title, notes, category)
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.Colors.accent)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .padding(.bottom, 8)
        }
        .scrollDismissesKeyboard(.interactively)
        .dismissKeyboardOnTapOrDrag()
        .padding(18)
        .background(AppTheme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.large, style: .continuous))
        .shadow(color: AppTheme.Shadow.card, radius: 18, x: 0, y: 12)
    }
}
