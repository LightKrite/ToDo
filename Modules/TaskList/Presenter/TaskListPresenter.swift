import Foundation

final class TaskListPresenter: TaskListPresenterInterface {
    // MARK: - VIPER Dependencies
    private weak var view: TaskListViewInterface?
    private let interactor: TaskListInteractorInterface
    private let router: TaskListRouterInterface
    
    // MARK: - Properties
    private var tasks: [Task] = []
    
    // MARK: - Initialization
    init(view: TaskListViewInterface, interactor: TaskListInteractorInterface, router: TaskListRouterInterface) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
    
    // MARK: - TaskListPresenterInterface
    func viewDidLoad() {
        // Загружаем задачи при открытии экрана
        fetchTasks()
    }
    
    func viewWillAppear() {
        // Обновляем задачи при возвращении на экран
        fetchTasks()
    }
    
    func viewDidAppear() {
        // Реализация не требуется
    }
    
    func viewWillDisappear() {
        // Реализация не требуется
    }
    
    func didReceiveError(_ error: Error) {
        view?.showError(AppError.from(error).localizedDescription)
    }
    
    func fetchTasks() {
        view?.showLoading()
        
        interactor.fetchAllTasks { [weak self] result in
            guard let self = self else { return }
            
            self.view?.hideLoading()
            
            switch result {
            case .success(let tasks):
                self.tasks = tasks
                let viewModels = self.mapToViewModels(tasks)
                self.view?.displayTasks(viewModels)
            case .failure(let error):
                self.handleError(error)
            }
        }
    }
    
    func didSelectTask(at index: Int) {
        if index < tasks.count {
            router.navigateToTaskDetail(with: tasks[index])
        }
    }
    
    func didTapAddTask() {
        router.navigateToCreateTask()
    }
    
    func didToggleTaskCompletion(at index: Int, isCompleted: Bool) {
        if index < tasks.count {
            let task = tasks[index]
            view?.showLoading()
            
            interactor.toggleTaskCompletion(task: task, isCompleted: isCompleted) { [weak self] result in
                guard let self = self else { return }
                self.view?.hideLoading()
                
                switch result {
                case .success(let updatedTask):
                    // Обновляем модель в локальном списке
                    self.tasks[index] = updatedTask
                    // Обновляем представление
                    let viewModel = TaskViewModel(task: updatedTask)
                    self.view?.updateTask(at: index, with: viewModel)
                case .failure(let error):
                    self.handleError(error)
                }
            }
        }
    }
    
    func didTapDeleteTask(at index: Int) {
        if index < tasks.count {
            let task = tasks[index]
            view?.showLoading()
            
            interactor.deleteTask(task: task) { [weak self] result in
                guard let self = self else { return }
                self.view?.hideLoading()
                
                switch result {
                case .success(_):
                    // Удаляем задачу из локального списка
                    self.tasks.remove(at: index)
                    // Обновляем представление
                    self.view?.removeTask(at: index)
                case .failure(let error):
                    self.handleError(error)
                }
            }
        }
    }
    
    func searchTasks(with query: String) {
        if query.isEmpty {
            view?.clearSearchResults()
            return
        }
        
        interactor.searchTasks(with: query) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let tasks):
                let viewModels = self.mapToViewModels(tasks)
                self.view?.displaySearchResults(viewModels)
            case .failure(let error):
                self.handleError(error)
            }
        }
    }
    
    func clearSearch() {
        view?.clearSearchResults()
    }
    
    // MARK: - Private Methods
    private func mapToViewModels(_ tasks: [Task]) -> [TaskViewModel] {
        return tasks.map { TaskViewModel(task: $0) }
    }
    
    private func handleError(_ error: Error) {
        view?.hideLoading()
        view?.showError(AppError.from(error).localizedDescription)
    }
} 