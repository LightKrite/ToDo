import UIKit

final class TaskListViewController: UIViewController {
    
    // MARK: - VIPER
    var taskListPresenter: TaskListPresenterInterface?
    
    // MARK: - UI Components
    private let titleLabel = UILabel()
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    private let footerView = TasksFooterView()
    private let homeIndicator = UIView()
    
    // MARK: - Properties
    private var tasks: [TaskViewModel] = []
    private var filteredTasks: [TaskViewModel] = []
    private var isSearchActive: Bool = false
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureTableView()
        configureSearchBar()
        
        // Запрос данных через presenter
        taskListPresenter?.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        taskListPresenter?.viewWillAppear()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Настройка основного вида
        view.backgroundColor = .black
        
        // Настройка заголовка "Задачи"
        titleLabel.text = "Задачи"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // Настройка поисковой строки
        searchBar.placeholder = "Search"
        searchBar.searchBarStyle = .minimal
        searchBar.barStyle = .black
        searchBar.tintColor = .white
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        // Настройка текстового поля и фона поисковой строки
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.textColor = .white
            textField.backgroundColor = UIColor(red: 0.17, green: 0.17, blue: 0.18, alpha: 1.0)
            
            // Настройка иконки микрофона
            let micButton = UIButton(type: .system)
            micButton.setImage(UIImage(systemName: "mic.fill"), for: .normal)
            micButton.tintColor = .gray
            textField.rightView = micButton
            textField.rightViewMode = .always
            
            // Настройка закругления
            textField.layer.cornerRadius = 10
            textField.clipsToBounds = true
        }
        view.addSubview(searchBar)
        
        // Настройка таблицы задач
        tableView.backgroundColor = .black
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // Настройка нижней панели
        footerView.translatesAutoresizingMaskIntoConstraints = false
        footerView.updateTaskCount(0)
        view.addSubview(footerView)
        
        // Настройка индикатора Home
        homeIndicator.backgroundColor = .white
        homeIndicator.layer.cornerRadius = 2.5
        homeIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(homeIndicator)
        
        // Установка ограничений AutoLayout
        NSLayoutConstraint.activate([
            // Заголовок
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Поисковая строка
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchBar.heightAnchor.constraint(equalToConstant: 36),
            
            // Таблица задач
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: footerView.topAnchor),
            
            // Нижняя панель
            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            footerView.heightAnchor.constraint(equalToConstant: 50),
            
            // Индикатор Home
            homeIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            homeIndicator.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            homeIndicator.widthAnchor.constraint(equalToConstant: 134),
            homeIndicator.heightAnchor.constraint(equalToConstant: 5)
        ])
        
        // Настройка обработчика для кнопки добавления
        footerView.addTaskAction = { [weak self] in
            self?.taskListPresenter?.didTapAddTask()
        }
    }
    
    // MARK: - TableView Configuration
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TaskCell.self, forCellReuseIdentifier: "TaskCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
    }
    
    // MARK: - SearchBar Configuration
    private func configureSearchBar() {
        searchBar.delegate = self
    }
    
    // MARK: - Helpers
    private func getCurrentTasks() -> [TaskViewModel] {
        return isSearchActive ? filteredTasks : tasks
    }
}

// MARK: - TaskListViewInterface Implementation
extension TaskListViewController: TaskListViewInterface {
    // Реализация свойства presenter из BaseViewInterface
    var presenter: BasePresenterInterface? {
        get { return taskListPresenter as? BasePresenterInterface }
        set { taskListPresenter = newValue as? TaskListPresenterInterface }
    }
    
    func displayTasks(_ tasks: [TaskViewModel]) {
        self.tasks = tasks
        tableView.reloadData()
        footerView.updateTaskCount(tasks.count)
    }
    
    func updateTask(at index: Int, with viewModel: TaskViewModel) {
        if index < tasks.count {
            tasks[index] = viewModel
            
            // Обновление отфильтрованного списка если необходимо
            if isSearchActive {
                if let filteredIndex = filteredTasks.firstIndex(where: { $0.id == viewModel.id }) {
                    filteredTasks[filteredIndex] = viewModel
                }
            }
            
            // Найти индекс в таблице и обновить строку
            let dataSource = isSearchActive ? filteredTasks : tasks
            if let visualIndex = dataSource.firstIndex(where: { $0.id == viewModel.id }) {
                let indexPath = IndexPath(row: visualIndex, section: 0)
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    func removeTask(at index: Int) {
        if index < tasks.count {
            let taskId = tasks[index].id
            tasks.remove(at: index)
            
            // Обновление отфильтрованного списка если необходимо
            if isSearchActive {
                if let filteredIndex = filteredTasks.firstIndex(where: { $0.id == taskId }) {
                    filteredTasks.remove(at: filteredIndex)
                    tableView.deleteRows(at: [IndexPath(row: filteredIndex, section: 0)], with: .automatic)
                }
            } else {
                tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
            
            footerView.updateTaskCount(tasks.count)
        }
    }
    
    func insertTask(_ viewModel: TaskViewModel, at index: Int) {
        tasks.insert(viewModel, at: index)
        
        if !isSearchActive {
            tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
        
        footerView.updateTaskCount(tasks.count)
    }
    
    func displaySearchResults(_ tasks: [TaskViewModel]) {
        self.filteredTasks = tasks
        isSearchActive = true
        tableView.reloadData()
    }
    
    func clearSearchResults() {
        filteredTasks.removeAll()
        isSearchActive = false
        tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension TaskListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getCurrentTasks().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
        
        let taskList = getCurrentTasks()
        if indexPath.row < taskList.count {
            let task = taskList[indexPath.row]
            cell.configure(
                title: task.title,
                description: task.description ?? "",
                date: task.formattedDate,
                isCompleted: task.isCompleted
            )
            
            // Настройка обработчика нажатия на чекбокс
            cell.checkboxAction = { [weak self] in
                guard let self = self else { return }
                let visualIndex = indexPath.row
                let taskId = taskList[visualIndex].id
                
                // Найти реальный индекс задачи в основном массиве
                if let actualIndex = self.tasks.firstIndex(where: { $0.id == taskId }) {
                    self.taskListPresenter?.didToggleTaskCompletion(at: actualIndex, isCompleted: !taskList[visualIndex].isCompleted)
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let tasks = getCurrentTasks()
        if indexPath.row < tasks.count {
            let taskId = tasks[indexPath.row].id
            
            // Найти реальный индекс задачи в основном массиве
            if let actualIndex = self.tasks.firstIndex(where: { $0.id == taskId }) {
                taskListPresenter?.didSelectTask(at: actualIndex)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] (_, _, completion) in
            guard let self = self else { return }
            
            let tasks = self.getCurrentTasks()
            if indexPath.row < tasks.count {
                let taskId = tasks[indexPath.row].id
                
                // Найти реальный индекс задачи в основном массиве
                if let actualIndex = self.tasks.firstIndex(where: { $0.id == taskId }) {
                    self.taskListPresenter?.didTapDeleteTask(at: actualIndex)
                    completion(true)
                } else {
                    completion(false)
                }
            } else {
                completion(false)
            }
        }
        
        deleteAction.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

// MARK: - UISearchBarDelegate
extension TaskListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            taskListPresenter?.clearSearch()
        } else {
            taskListPresenter?.searchTasks(with: searchText)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        taskListPresenter?.clearSearch()
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
} 