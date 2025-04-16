import Foundation

/// Ошибки, связанные с работой Core Data
enum CoreDataError: LocalizedError {
    case taskNotFound
    case saveFailed(Error)
    case fetchFailed(Error)
    case deleteFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .taskNotFound:
            return "Задача не найдена"
        case .saveFailed(let error):
            return "Ошибка сохранения: \(error.localizedDescription)"
        case .fetchFailed(let error):
            return "Ошибка получения данных: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Ошибка удаления: \(error.localizedDescription)"
        }
    }
} 