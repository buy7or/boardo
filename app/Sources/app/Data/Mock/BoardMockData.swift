import Foundation

enum BoardMockData {
    static func sampleTasks(referenceDate: Date = Date()) -> [BoardTask] {
        return [
            BoardTask(
                title: "Comprar leche y pan para la cena",
                notes: "",
                category: .personal,
                dueDate: referenceDate
            ),
            BoardTask(
                title: "Gimnasio 6pm - Leg day!",
                notes: "",
                category: .routine,
                dueDate: referenceDate
            ),
            BoardTask(
                title: "Llamar a mama - Feliz cumpleanos",
                notes: "",
                category: .family,
                dueDate: referenceDate
            ),
            BoardTask(
                title: "Proyecto UI - Finalizar prototipo",
                notes: "",
                category: .work,
                dueDate: referenceDate
            ),
            BoardTask(
                title: "Idea sin fecha",
                notes: "Tarea en inbox para programar luego.",
                category: .personal,
                dueDate: nil
            )
        ]
    }
}
