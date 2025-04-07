import Foundation

// MARK: - Extension for mapping models
extension TaskListPresenter {
    
    /// Вспомогательный метод для преобразования моделей Task в TaskViewModel
    func mapToViewModels(_ tasks: [Task]) -> [TaskViewModel] {
        return tasks.map { TaskViewModel(task: $0) }
    }
} 