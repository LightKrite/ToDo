import UIKit

/// Базовый протокол для создателей модулей
protocol ModuleBuilderInterface {
    /// Создает модуль и возвращает ViewController
    static func build() -> UIViewController
    
    /// Создает модуль и возвращает ViewController, принимая параметры
    static func build(with parameters: [String: Any]) -> UIViewController
}

// MARK: - Реализация по умолчанию

extension ModuleBuilderInterface {
    static func build() -> UIViewController {
        return build(with: [:])
    }
} 