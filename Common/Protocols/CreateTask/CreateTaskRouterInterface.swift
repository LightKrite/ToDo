import Foundation

/// Протокол для Router модуля CreateTask
protocol CreateTaskRouterInterface: BaseRouterInterface {
    /// Закрыть экран создания задачи
    func dismissCreateTask()
} 