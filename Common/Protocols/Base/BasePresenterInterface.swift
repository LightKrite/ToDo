import Foundation

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

// MARK: - Реализация по умолчанию

extension BasePresenterInterface {
    func viewDidLoad() {}
    func viewWillAppear() {}
    func viewDidAppear() {}
    func viewWillDisappear() {}
    func didReceiveError(_ error: Error) {}
} 