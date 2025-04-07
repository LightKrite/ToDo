import Foundation

// MARK: - Presenter
class TaskListPresenter: TaskListPresenterInterface {
    // MARK: - VIPER
    weak var view: TaskListViewInterface?
    var interactor: TaskListInteractorInterface?
    var router: TaskListRouterInterface?
    
    // MARK: - Private properties
    private var tasks: [Task] = []
    private var isInitialDataLoaded = false
    
    // MARK: - Initialization
    init() {
        print("DEBUG: Presenter - инициализация")
    }
    
    // MARK: - TaskListPresenterInterface
    func viewDidLoad() {
        // Загружаем задачи при первой загрузке экрана
        fetchTasks()
    }
    
    func viewWillAppear() {
        // Обновляем список задач при каждом появлении экрана
        fetchTasks()
    }
    
    func viewDidAppear() {
        // Реализация не требуется
    }
    
    func viewWillDisappear() {
        // Реализация не требуется
    }
    
    func didReceiveError(_ error: Error) {
        view?.showError(error.localizedDescription)
    }
    
    func fetchTasks() {
        view?.showLoading()
        
        interactor?.fetchAllTasks { [weak self] result in
            guard let self = self else { return }
            
            self.view?.hideLoading()
            
            switch result {
            case .success(let tasks):
                self.handleTasks(tasks)
                
            case .failure(let error):
                self.handleError(error)
            }
        }
    }
    
    func didTapAddTask() {
        router?.navigateToCreateTask()
    }
    
    func didTapTask(at index: Int) {
        guard index < tasks.count else { return }
        
        let task = tasks[index]
        router?.navigateToTaskDetail(with: task)
    }
    
    func didTapDeleteTask(at index: Int) {
        guard index < tasks.count else { return }
        
        let task = tasks[index]
        
        interactor?.deleteTask(task: task) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.fetchTasks()
                
            case .failure(let error):
                self.handleError(error)
            }
        }
    }
    
    func didToggleTaskCompletion(at index: Int) {
        guard index < tasks.count else { return }
        
        let task = tasks[index]
        task.isCompleted = !task.isCompleted
        
        interactor?.updateTask(task: task) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                // Обновляем UI только для текущей задачи
                self.fetchTasks()
                
            case .failure(let error):
                self.handleError(error)
                // Возвращаем предыдущее состояние задачи
                task.isCompleted = !task.isCompleted
                self.fetchTasks()
            }
        }
    }
    
    func searchTasks(with query: String) {
        if query.isEmpty {
            view?.clearSearchResults()
            return
        }
        
        interactor?.searchTasks(with: query) { [weak self] result in
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
    
    // MARK: - Private methods
    private func handleTasks(_ tasks: [Task]) {
        self.tasks = tasks
        
        // Преобразуем модели Domain в ViewModel
        let viewModels = mapToViewModels(tasks)
        
        // Передаем данные в View для отображения
        view?.displayTasks(viewModels)
    }
    
    private func handleError(_ error: Error) {
        view?.displayError(error.localizedDescription)
    }
} 