import Foundation
import UIKit

final class TaskDetailPresenter: TaskDetailPresenterInterface {
    
    // MARK: - VIPER Properties
    weak var view: TaskDetailViewInterface?
    var interactor: TaskDetailInteractorInterface?
    var router: TaskDetailRouterInterface?
    
    // MARK: - Private Properties
    private var task: Task
    private var isInEditMode = false
    
    // MARK: - Initialization
    init(task: Task) {
        self.task = task
    }
    
    // MARK: - TaskDetailPresenterInterface
    func viewDidLoad() {
        displayTask()
    }
    
    func didTapSaveTask(title: String, description: String?, isCompleted: Bool) {
        // Обновляем значения свойств текущей задачи
        task.title = title
        task.taskDescription = description
        task.isCompleted = isCompleted
        
        // Отправляем задачу на обновление в интерактор
        interactor?.updateTask(title: title, description: description, isCompleted: isCompleted) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let updatedTask):
                // Обновляем локальную копию задачи
                self.task = updatedTask
                // Обновляем отображение
                self.displayTask()
                // Выходим из режима редактирования
                self.isInEditMode = false
                self.view?.exitEditMode()
            case .failure(let error):
                // Показываем ошибку
                self.view?.displayError(error.localizedDescription)
            }
        }
    }
    
    func didTapDeleteTask() {
        // Отправляем задачу на удаление в интерактор
        interactor?.deleteTask(task) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                // Переходим назад к списку задач
                self.router?.navigateBack()
            case .failure(let error):
                // Показываем ошибку
                self.view?.displayError(error.localizedDescription)
            }
        }
    }
    
    func didTapEditTask() {
        isInEditMode = true
        view?.enterEditMode()
    }
    
    func didTapCancelEdit() {
        isInEditMode = false
        view?.exitEditMode()
        // Сбрасываем изменения, показывая текущую задачу
        displayTask()
    }
    
    func didToggleTaskCompletion(isCompleted: Bool) {
        // Обновляем значение isCompleted для задачи
        task.isCompleted = isCompleted
        
        // Сохраняем изменения через интерактор
        interactor?.updateTask(
            title: task.title ?? "",
            description: task.taskDescription,
            isCompleted: isCompleted
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let updatedTask):
                // Обновляем локальную копию задачи
                self.task = updatedTask
                // Обновляем отображение
                self.displayTask()
            case .failure(let error):
                // В случае ошибки показываем сообщение и возвращаем исходное значение
                self.view?.displayError(error.localizedDescription)
                // Восстанавливаем предыдущее состояние и обновляем UI
                self.task.isCompleted = !isCompleted
                self.displayTask()
            }
        }
    }
    
    // MARK: - Private Methods
    private func displayTask() {
        // Создаем модель представления из текущей задачи
        let viewModel = TaskViewModel(task: task)
        // Отображаем модель
        view?.displayTask(viewModel)
    }
} 



