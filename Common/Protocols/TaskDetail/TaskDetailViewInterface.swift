import Foundation

/// Протокол для View модуля TaskDetail
protocol TaskDetailViewInterface: AnyObject {
    func displayTask(_ viewModel: TaskViewModel)
    func displayError(_ message: String)
    func enterEditMode()
    func exitEditMode()
} 