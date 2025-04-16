import Foundation

/// Уровни логирования
enum LogLevel {
    case debug
    case info
    case warning
    case error
    
    var prefix: String {
        switch self {
        case .debug: return "DEBUG"
        case .info: return "INFO"
        case .warning: return "WARNING"
        case .error: return "ERROR"
        }
    }
}

/// Протокол для логирования сообщений
protocol LoggerProtocol {
    func log(_ message: String, level: LogLevel)
    func log(_ error: Error, level: LogLevel)
    func dump(_ object: Any, message: String, level: LogLevel)
}

/// Стандартная реализация логгера
final class Logger: LoggerProtocol {
    // Для обратной совместимости сохраняем shared, но это будет deprecated
    static let shared = Logger()
    
    /// Формат даты для логов
    private let dateFormatter: DateFormatter
    
    /// Создаёт экземпляр логгера с настраиваемым форматом даты
    /// - Parameter dateFormat: Формат вывода даты в логах
    init(dateFormat: String = "yyyy-MM-dd HH:mm:ss.SSS") {
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = dateFormat
    }
    
    /// Возвращает текущую временную метку
    private func timestamp() -> String {
        return dateFormatter.string(from: Date())
    }
    
    /// Логирует текстовое сообщение с указанным уровнем
    func log(_ message: String, level: LogLevel) {
        #if DEBUG
        print("[\(timestamp())] [\(level.prefix)] \(message)")
        #endif
    }
    
    /// Логирует ошибку с указанным уровнем
    func log(_ error: Error, level: LogLevel) {
        #if DEBUG
        print("[\(timestamp())] [\(level.prefix)] \(error.localizedDescription)")
        if let nsError = error as NSError? {
            print("[\(timestamp())] [\(level.prefix)] Domain: \(nsError.domain), Code: \(nsError.code), UserInfo: \(nsError.userInfo)")
        }
        #endif
    }
    
    /// Логирует объект с текстовым сообщением и указанным уровнем
    func dump(_ object: Any, message: String, level: LogLevel) {
        #if DEBUG
        print("[\(timestamp())] [\(level.prefix)] \(message)")
        Swift.dump(object)
        #endif
    }
} 