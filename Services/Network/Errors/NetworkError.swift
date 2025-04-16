import Foundation

/// Перечисление возможных ошибок при работе с сетью
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case noData
    case decodingError(Error)
    case encodingError(Error)
    case serverError(Int)
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Недействительный URL"
        case .networkError(let error):
            return "Ошибка сети: \(error.localizedDescription)"
        case .noData:
            return "Нет данных от сервера"
        case .decodingError(let error):
            return "Ошибка декодирования: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Ошибка кодирования: \(error.localizedDescription)"
        case .serverError(let code):
            return "Ошибка сервера: \(code)"
        case .unknownError:
            return "Неизвестная ошибка"
        }
    }
} 