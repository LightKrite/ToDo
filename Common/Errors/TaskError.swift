import Foundation

/**
 * Общие ошибки приложения для задач
 */
enum TaskError: LocalizedError {
    case taskNotFound
    case databaseError(Error)
    case networkError(Error)
    case invalidData
    case saveFailed
    
    var errorDescription: String? {
        switch self {
        case .taskNotFound:
            return "Задача не найдена"
        case .databaseError(let error):
            return "Ошибка базы данных: \(error.localizedDescription)"
        case .networkError(let error):
            return "Ошибка сети: \(error.localizedDescription)"
        case .invalidData:
            return "Некорректные данные"
        case .saveFailed:
            return "Ошибка сохранения задачи"
        }
    }
}

 
