import Foundation

/// Протокол для View модуля CreateTask
protocol CreateTaskViewInterface: BaseViewInterface {
    /// Ссылка на presenter с конкретным типом
    var createTaskPresenter: CreateTaskPresenterInterface? { get set }
    
    /// Закрытие экрана после создания задачи
    func closeScreen()
} 