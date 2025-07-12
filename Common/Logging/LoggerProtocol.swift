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