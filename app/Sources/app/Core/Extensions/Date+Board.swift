import Foundation

extension Date {
    var boardMonthYearTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: self).capitalized
    }

    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }
}
