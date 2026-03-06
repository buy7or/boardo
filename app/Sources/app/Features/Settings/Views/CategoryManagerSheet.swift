import SwiftUI

struct CategoryManagerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: BoardViewModel

    @State private var categoryName = ""
    @State private var selectedColor: PostItColorStyle = .yellow
    @State private var selectedIcon = "tag.fill"
    private let availableIcons = [
        "tag.fill",
        "briefcase.fill",
        "house.fill",
        "heart.fill",
        "star.fill",
        "book.fill",
        "cart.fill",
        "fork.knife",
        "dumbbell.fill",
        "car.fill",
        "gamecontroller.fill",
        "bolt.fill",
        "leaf.fill",
        "graduationcap.fill",
        "music.note",
        "pawprint.fill"
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    formCard
                    categoriesList
                }
                .padding(16)
            }
            .background(AppTheme.Colors.boardBackground.ignoresSafeArea())
            .navigationTitle(L10n.tr("settings.categories.navTitle"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.body.weight(.medium))
                            .foregroundStyle(AppTheme.Colors.subtitle)
                            .frame(width: 28, height: 28)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var formCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.tr("settings.categories.create"))
                .font(.headline.weight(.semibold))
                .foregroundStyle(AppTheme.Colors.title)

            TextField(L10n.tr("settings.categories.name"), text: $categoryName)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.words)

            Text(L10n.tr("settings.categories.color"))
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppTheme.Colors.subtitle)

            HStack(spacing: 10) {
                ForEach(PostItColorStyle.allCases) { colorStyle in
                    Button {
                        selectedColor = colorStyle
                    } label: {
                        Circle()
                            .fill(colorStyle.color)
                            .frame(width: 32, height: 32)
                            .overlay {
                                Circle()
                                    .stroke(AppTheme.Colors.accent, lineWidth: selectedColor == colorStyle ? 2 : 0)
                            }
                    }
                    .buttonStyle(.plain)
                }
            }

            Text(L10n.tr("settings.categories.icon"))
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppTheme.Colors.subtitle)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(availableIcons, id: \.self) { iconName in
                        Button {
                            selectedIcon = iconName
                        } label: {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 34, height: 34)
                                .overlay {
                                    Image(systemName: iconName)
                                        .foregroundStyle(AppTheme.Colors.title.opacity(0.82))
                                }
                                .overlay {
                                    Circle()
                                        .stroke(AppTheme.Colors.accent, lineWidth: selectedIcon == iconName ? 2 : 0)
                                }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 2)
            }

            Button(L10n.tr("settings.categories.add")) {
                viewModel.addCategory(name: categoryName, colorStyle: selectedColor, icon: selectedIcon)
                categoryName = ""
                selectedColor = .yellow
                selectedIcon = "tag.fill"
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(AppTheme.Colors.accent)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .disabled(categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.7 : 1)
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous))
    }

    private var categoriesList: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L10n.tr("settings.categories.available"))
                .font(.headline.weight(.semibold))
                .foregroundStyle(AppTheme.Colors.title)

            ForEach(viewModel.categories) { category in
                HStack(spacing: 12) {
                    Circle()
                        .fill(category.color)
                        .frame(width: 24, height: 24)
                        .overlay {
                            Image(systemName: category.icon)
                                .font(.caption2)
                                .foregroundStyle(AppTheme.Colors.title.opacity(0.8))
                        }

                    Text(category.label)
                        .foregroundStyle(AppTheme.Colors.title)

                    Spacer()

                    if viewModel.categories.count > 1 {
                        Button(role: .destructive) {
                            viewModel.deleteCategory(category)
                        } label: {
                            Image(systemName: "trash")
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(L10n.tr("common.delete"))
                    }
                }
                .padding(12)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }
}
