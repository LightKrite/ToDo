import Foundation

/// Перечисление с возможными ошибками приложения
enum AppError: Error {
    case coreDataError(String)
    case networkError(String)
    case validationError(String)
    case unknown(String)
    
    /// Пользовательское описание ошибки
    var localizedDescription: String {
        switch self {
        case .coreDataError(let message):
            return "Ошибка базы данных: \(message)"
        case .networkError(let message):
            return "Ошибка сети: \(message)"
        case .validationError(let message):
            return "Ошибка валидации: \(message)"
        case .unknown(let message):
            return "Неизвестная ошибка: \(message)"
        }
    }
    
    /// Преобразование NetworkError в AppError
    static func from(_ networkError: NetworkError) -> AppError {
        return .networkError(networkError.localizedDescription)
    }
    
    /// Преобразование общей ошибки в AppError
    static func from(_ error: Error) -> AppError {
        if let networkError = error as? NetworkError {
            return from(networkError)
        }
        return .unknown(error.localizedDescription)
    }
} 