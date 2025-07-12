import Foundation
import CoreData

/// Протокол для Interactor модуля CreateTask
protocol CreateTaskInteractorInterface: BaseInteractorInterface {
    /// Создать новую задачу
    func createTask(title: String, description: String?, isCompleted: Bool, completion: @escaping (Result<Task, Error>) -> Void)
} 