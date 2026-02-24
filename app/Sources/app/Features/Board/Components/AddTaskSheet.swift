import SwiftUI

struct AddTaskSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var selectedCategory: TaskCategory = .personal

    let selectedDate: Date
    let onSave: (String, String, TaskCategory, Date?) -> Void
    private let stickerCategories: [TaskCategory] = [.personal, .work, .family, .urgent]
    private var handwrittenTitleFont: Font { .custom("MarkerFelt-Wide", size: 33) }
    private var handwrittenBodyFont: Font { .custom("MarkerFelt-Thin", size: 30) }
    private var stickyColor: Color { selectedCategory.color }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 22) {
                topBar
                stickyEditor
                stickerPicker
                pinButton
                Spacer(minLength: 10)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            BottomNavigationBar()
                .padding(.horizontal, 12)
                .padding(.bottom, 6)
        }
        .background(AppTheme.Colors.boardBackground.ignoresSafeArea())
    }

    private var topBar: some View {
        ZStack {
            Text("New Memory")
                .font(.title3.weight(.bold))
                .foregroundStyle(AppTheme.Colors.accent)

            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.body.weight(.medium))
                        .foregroundStyle(AppTheme.Colors.subtitle)
                        .frame(width: 28, height: 28)
                }
                Spacer()
            }
        }
    }

    private var stickyEditor: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Grocery List", text: $title)
                .font(handwrittenTitleFont)
                .foregroundStyle(AppTheme.Colors.title)
                .textInputAutocapitalization(.sentences)

            ZStack(alignment: .topLeading) {
                if notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text("Don't forget the organic honey and some fresh basil for the pasta tonight!")
                        .font(handwrittenBodyFont)
                        .foregroundStyle(AppTheme.Colors.title.opacity(0.52))
                        .padding(.top, 8)
                        .padding(.leading, 5)
                }

                TextEditor(text: $notes)
                    .font(handwrittenBodyFont)
                    .foregroundStyle(AppTheme.Colors.title.opacity(0.9))
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .frame(minHeight: 170)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, minHeight: 300, alignment: .topLeading)
        .background(stickyColor)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.white.opacity(0.42))
                .frame(width: 60, height: 14)
                .offset(y: -7)
        }
        .overlay(alignment: .bottomTrailing) {
            Circle()
                .fill(Color.white.opacity(0.15))
                .frame(width: 40, height: 40)
                .offset(x: 18, y: 18)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sticky, style: .continuous))
        .shadow(color: AppTheme.Shadow.card, radius: 10, x: 0, y: 6)
    }

    private var stickerPicker: some View {
        VStack(spacing: 10) {
            Text("Pick a Sticker")
                .font(.headline)
                .foregroundStyle(AppTheme.Colors.subtitle)

            HStack(spacing: 16) {
                ForEach(stickerCategories) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        VStack(spacing: 7) {
                            Circle()
                                .fill(category.color)
                                .frame(width: 42, height: 42)
                                .overlay {
                                    Image(systemName: category.icon)
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(AppTheme.Colors.title.opacity(0.7))
                                }
                                .overlay {
                                    Circle()
                                        .stroke(
                                            AppTheme.Colors.accent,
                                            style: StrokeStyle(
                                                lineWidth: selectedCategory == category ? 1.8 : 0,
                                                dash: [5]
                                            )
                                        )
                                        .padding(-4)
                                }

                            Text(category.label)
                                .font(.caption2)
                                .foregroundStyle(AppTheme.Colors.subtitle)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var pinButton: some View {
        Button {
            onSave(title, notes, selectedCategory, selectedDate)
            dismiss()
        } label: {
            Label("Pin to Board", systemImage: "pin.fill")
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.vertical, 14)
                .frame(maxWidth: 230)
                .background(AppTheme.Colors.accent)
                .clipShape(Capsule())
                .shadow(color: AppTheme.Shadow.card, radius: 8, x: 0, y: 4)
        }
        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        .opacity(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.75 : 1)
    }
}

#if DEBUG
struct AddTaskSheetPreview: View {
    var body: some View {
        AddTaskSheet(selectedDate: .now) { _, _, _, _ in
        }
    }
}
#endif
