import Foundation

/// Протокол для View модуля TaskList
protocol TaskListViewInterface: AnyObject {
    func displayTasks(_ tasks: [TaskViewModel])
    func displayError(_ message: String)
    
    // Методы для обратной совместимости
    func showError(_ message: String)
    func showLoading()
    func hideLoading()
    
    // Методы для работы с поиском
    func displaySearchResults(_ tasks: [TaskViewModel])
    func clearSearchResults()
    
    // Методы для работы с отдельными задачами
    func updateTask(at index: Int, with viewModel: TaskViewModel)
    func removeTask(at index: Int)
    func insertTask(_ viewModel: TaskViewModel, at index: Int)
} 