import UIKit

// MARK: - BaseView
/// Базовый протокол для всех View в архитектуре VIPER
protocol BaseViewInterface: AnyObject {
    var presenter: BasePresenterInterface? { get set }
    
    /// Отображение индикатора загрузки
    func showLoading()
    
    /// Скрытие индикатора загрузки
    func hideLoading()
    
    /// Отображение сообщения об ошибке
    func showError(_ message: String)
    
    /// Отображение всплывающего сообщения
    func showMessage(_ message: String)
}

// По умолчанию реализуем методы для UIViewController
extension BaseViewInterface where Self: UIViewController {
    func showLoading() {
        // Здесь можно добавить стандартный индикатор загрузки
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.tag = 999
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        view.isUserInteractionEnabled = false
    }
    
    func hideLoading() {
        // Удаление индикатора загрузки
        if let activityIndicator = view.viewWithTag(999) as? UIActivityIndicatorView {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
        }
        view.isUserInteractionEnabled = true
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func showMessage(_ message: String) {
        let alert = UIAlertController(title: "Сообщение", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - BasePresenter
/// Базовый протокол для всех Presenter в архитектуре VIPER
protocol BasePresenterInterface: AnyObject {
    /// Вызывается при загрузке view
    func viewDidLoad()
    
    /// Вызывается перед появлением view
    func viewWillAppear()
    
    /// Вызывается после появления view
    func viewDidAppear()
    
    /// Вызывается перед исчезновением view
    func viewWillDisappear()
    
    /// Вызывается при получении ошибки
    func didReceiveError(_ error: Error)
}

// Реализация по умолчанию
extension BasePresenterInterface {
    func viewDidLoad() {}
    func viewWillAppear() {}
    func viewDidAppear() {}
    func viewWillDisappear() {}
    func didReceiveError(_ error: Error) {}
}

// MARK: - BaseInteractor
/// Базовый протокол для всех Interactor в архитектуре VIPER
protocol BaseInteractorInterface: AnyObject {
    /// Вызывается при инициализации интерактора
    func initialize()
}

extension BaseInteractorInterface {
    func initialize() {}
}

// MARK: - BaseRouter
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

// MARK: - ModuleBuilder
/// Базовый протокол для создателей модулей
protocol ModuleBuilderInterface {
    /// Создает модуль и возвращает ViewController
    static func build() -> UIViewController
    
    /// Создает модуль и возвращает ViewController, принимая параметры
    static func build(with parameters: [String: Any]) -> UIViewController
}

extension ModuleBuilderInterface {
    static func build() -> UIViewController {
        return build(with: [:])
    }
} 