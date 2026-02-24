import SwiftUI

extension View {
    func dismissKeyboardOnTapOrDrag() -> some View {
        self
            .contentShape(Rectangle())
            .onTapGesture {
                hideKeyboard()
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 12)
                    .onEnded { value in
                        if value.translation.height > 20 {
                            hideKeyboard()
                        }
                    }
            )
    }

    private func hideKeyboard() {
        #if canImport(UIKit)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        #endif
    }
}
