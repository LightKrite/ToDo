import Foundation

protocol LoggerProtocol {
    func log(_ message: String, level: LogLevel)
    func log(_ error: Error, level: LogLevel)
    func dump(_ object: Any, message: String, level: LogLevel)
}

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

final class Logger: LoggerProtocol {
    static let shared = Logger()
    
    private init() {}
    
    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
    
    private func timestamp() -> String {
        return dateFormatter.string(from: Date())
    }
    
    func log(_ message: String, level: LogLevel) {
        #if DEBUG
        print("[\(timestamp())] [\(level.prefix)] \(message)")
        #endif
    }
    
    func log(_ error: Error, level: LogLevel) {
        #if DEBUG
        print("[\(timestamp())] [\(level.prefix)] \(error.localizedDescription)")
        if let nsError = error as NSError? {
            print("[\(timestamp())] [\(level.prefix)] Domain: \(nsError.domain), Code: \(nsError.code), UserInfo: \(nsError.userInfo)")
        }
        #endif
    }
    
    func dump(_ object: Any, message: String, level: LogLevel) {
        #if DEBUG
        print("[\(timestamp())] [\(level.prefix)] \(message)")
        Swift.dump(object)
        #endif
    }
} 