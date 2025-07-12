import Foundation

/// Протокол для Presenter модуля CreateTask
protocol CreateTaskPresenterInterface: BasePresenterInterface {
    /// Обработка создания задачи
    func didTapCreateTask(title: String, description: String?, isCompleted: Bool)
    
    /// Обработка отмены создания
    func didTapCancel()
} 