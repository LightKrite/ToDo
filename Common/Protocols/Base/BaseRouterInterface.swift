import UIKit

/// Базовый протокол для всех Router в архитектуре VIPER
protocol BaseRouterInterface: AnyObject {
    /// Корневой контроллер для навигации
    var viewController: UIViewController? { get set }
    
    /// Базовая навигация назад
    func popViewController(animated: Bool)
    
    /// Закрытие текущего модального контроллера
    func dismiss(animated: Bool)
    
    /// Переход к корневому контроллеру стека навигации
    func popToRoot(animated: Bool)
}

// MARK: - Реализация по умолчанию

extension BaseRouterInterface {
    func popViewController(animated: Bool = true) {
        if let navigationController = viewController?.navigationController {
            navigationController.popViewController(animated: animated)
        }
    }
    
    func dismiss(animated: Bool = true) {
        viewController?.dismiss(animated: animated)
    }
    
    func popToRoot(animated: Bool = true) {
        if let navigationController = viewController?.navigationController {
            navigationController.popToRootViewController(animated: animated)
        }
    }
} 