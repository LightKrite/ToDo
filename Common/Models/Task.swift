import Foundation
import CoreData

// Модель представления задачи для UI
struct TaskViewModel: Equatable {
    var id: String
    var title: String
    var taskDescription: String?
    var isCompleted: Bool
    var createdAt: Date
    
    init(task: Task) {
        self.id = task.id ?? UUID().uuidString
        
        // Проверяем если task.id имеет числовой формат (что характерно для API)
        let isFromAPI = (task.id?.range(of: "^\\d+$", options: .regularExpression) != nil)
        
        if let taskTitle = task.title, !taskTitle.isEmpty {
            self.title = taskTitle
        } else if let description = task.taskDescription, description.contains("DummyJSON API") && isFromAPI {
            // Если это задача из API, но заголовок пустой - попробуем восстановить
            self.title = "Задача #\(task.id ?? "")"
        } else {
            self.title = "Без названия"
        }
        
        self.taskDescription = task.taskDescription
        self.isCompleted = task.isCompleted
        self.createdAt = task.createdAt ?? Date()
    }
    
    // Добавляем второй инициализатор с отдельными параметрами
    init(id: String, title: String, taskDescription: String?, isCompleted: Bool, createdAt: Date) {
        self.id = id
        self.title = title.isEmpty ? "Без названия" : title
        self.taskDescription = taskDescription
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
    
    /// Форматированная дата создания
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }
    
    static func == (lhs: TaskViewModel, rhs: TaskViewModel) -> Bool {
        return lhs.id == rhs.id &&
               lhs.title == rhs.title &&
               lhs.taskDescription == rhs.taskDescription &&
               lhs.isCompleted == rhs.isCompleted
    }
} 