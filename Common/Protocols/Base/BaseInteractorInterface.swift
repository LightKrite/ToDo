import Foundation

/// Базовый протокол для всех Interactor в архитектуре VIPER
protocol BaseInteractorInterface: AnyObject {
    /// Вызывается при инициализации интерактора
    func initialize()
}

// MARK: - Реализация по умолчанию

extension BaseInteractorInterface {
    func initialize() {}
} 