import UIKit

final class TaskListViewController: UIViewController, TaskListViewInterface {
    
    // MARK: - VIPER
    var taskListPresenter: TaskListPresenterInterface?
    
    // MARK: - UI Components
    private let titleLabel = UILabel()
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    private let footerView = TasksFooterView()
    private let homeIndicator = UIView()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let emptyStateView = UILabel()
    
    // MARK: - Properties
    private var tasks: [TaskViewModel] = []
    private var filteredTasks: [TaskViewModel] = []
    private var isSearchActive: Bool = false
    private var searchDebounceTimer: Timer?
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureTableView()
        configureSearchBar()
        configureEmptyStateView()
        
        taskListPresenter?.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        taskListPresenter?.viewWillAppear()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - TaskListViewInterface
    func displayTasks(_ tasks: [TaskViewModel]) {
        self.tasks = tasks
        tableView.reloadData()
        updateEmptyStateVisibility(taskCount: tasks.count)
    }
    
    func displayError(_ message: String) {
        showAlert(title: "Ошибка", message: message)
    }
    
    // Методы для обратной совместимости
    func showError(_ message: String) {
        displayError(message)
    }
    
    func showLoading() {
        loadingIndicator.startAnimating()
    }
    
    func hideLoading() {
        loadingIndicator.stopAnimating()
    }
    
    // Методы для работы с поиском
    func displaySearchResults(_ tasks: [TaskViewModel]) {
        self.filteredTasks = tasks
        isSearchActive = true
        tableView.reloadData()
        updateEmptyStateVisibility(taskCount: tasks.count)
    }
    
    func clearSearchResults() {
        isSearchActive = false
        filteredTasks = tasks
        tableView.reloadData()
        updateEmptyStateVisibility(taskCount: tasks.count)
    }
    
    // Методы для обновления отдельных задач
    func updateTask(at index: Int, with viewModel: TaskViewModel) {
        guard index < tasks.count else { return }
        
        tasks[index] = viewModel
        
        if isSearchActive {
            updateTaskInFilteredResults(viewModel)
        } else {
            updateTaskInMainList(at: index)
        }
    }
    
    private func updateTaskInFilteredResults(_ viewModel: TaskViewModel) {
        if let filteredIndex = filteredTasks.firstIndex(where: { $0.id == viewModel.id }) {
            filteredTasks[filteredIndex] = viewModel
            let indexPath = IndexPath(row: filteredIndex, section: 0)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    private func updateTaskInMainList(at index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func removeTask(at index: Int) {
        guard index < tasks.count else { return }
        
        let taskId = tasks[index].id
        tasks.remove(at: index)
        
        if isSearchActive {
            removeTaskFromFilteredResults(with: taskId)
        } else {
            removeTaskFromMainList(at: index)
        }
        
        updateTaskCountUI()
    }
    
    private func removeTaskFromFilteredResults(with taskId: String) {
        if let filteredIndex = filteredTasks.firstIndex(where: { $0.id == taskId }) {
            filteredTasks.remove(at: filteredIndex)
            tableView.deleteRows(at: [IndexPath(row: filteredIndex, section: 0)], with: .automatic)
        }
    }
    
    private func removeTaskFromMainList(at index: Int) {
        tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    private func updateTaskCountUI() {
        footerView.updateTaskCount(tasks.count)
        updateEmptyStateVisibility(taskCount: tasks.count)
    }
    
    func insertTask(_ viewModel: TaskViewModel, at index: Int) {
        tasks.insert(viewModel, at: index)
        
        if !isSearchActive {
            tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
        
        updateTaskCountUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupViewBackground()
        setupTitle()
        setupSearchBar()
        setupTableView()
        setupFooter()
        setupHomeIndicator()
        setupLoadingIndicator()
        setupConstraints()
    }
    
    private func setupViewBackground() {
        view.backgroundColor = .black
    }
    
    private func setupTitle() {
        titleLabel.text = "Задачи"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
    }
    
    private func setupSearchBar() {
        searchBar.placeholder = "Search"
        searchBar.searchBarStyle = .minimal
        searchBar.barStyle = .black
        searchBar.tintColor = .white
        searchBar.setImage(UIImage(), for: .search, state: .normal)
        searchBar.showsCancelButton = true
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        configureSearchBarTextField()
        configureSearchBarCancelButton()
        
        view.addSubview(searchBar)
    }
    
    private func configureSearchBarTextField() {
        guard let textField = searchBar.value(forKey: "searchField") as? UITextField else { return }
        
        textField.textColor = .white
        textField.backgroundColor = UIColor(red: 0.17, green: 0.17, blue: 0.18, alpha: 1.0)
        textField.layer.cornerRadius = 10
        textField.clipsToBounds = true
    }
    
    private func configureSearchBarCancelButton() {
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = .white
    }
    
    private func setupTableView() {
        tableView.backgroundColor = .black
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
    }
    
    private func setupFooter() {
        footerView.translatesAutoresizingMaskIntoConstraints = false
        footerView.updateTaskCount(0)
        footerView.addTaskAction = { [weak self] in
            self?.taskListPresenter?.didTapAddTask()
        }
        view.addSubview(footerView)
    }
    
    private func setupHomeIndicator() {
        homeIndicator.backgroundColor = .white
        homeIndicator.layer.cornerRadius = 2.5
        homeIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(homeIndicator)
    }
    
    private func setupLoadingIndicator() {
        loadingIndicator.color = .white
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Заголовок
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Поисковая строка
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            // Таблица
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: footerView.topAnchor),
            
            // Нижняя панель
            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            footerView.heightAnchor.constraint(equalToConstant: 60),
            
            // Индикатор Home
            homeIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            homeIndicator.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            homeIndicator.widthAnchor.constraint(equalToConstant: 134),
            homeIndicator.heightAnchor.constraint(equalToConstant: 5),
            
            // Индикатор загрузки
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - TableView Configuration
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TaskCell.self, forCellReuseIdentifier: "TaskCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        
        configureTableViewAppearance()
    }
    
    private func configureTableViewAppearance() {
        tableView.backgroundColor = .black
        
        // Отключаем стандартные эффекты выделения
        if #available(iOS 15.0, *) {
            tableView.selectionFollowsFocus = false
        }
        
        // Другие настройки внешнего вида
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.allowsSelection = true
        
        // Настройка отступов и скроллинга
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
    }
    
    // MARK: - SearchBar Configuration
    private func configureSearchBar() {
        searchBar.delegate = self
    }
    
    // MARK: - Empty State Configuration
    private func configureEmptyStateView() {
        emptyStateView.text = "Нет задач"
        emptyStateView.textColor = .gray
        emptyStateView.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        emptyStateView.textAlignment = .center
        emptyStateView.isHidden = true
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateView)
        
        setupEmptyStateConstraints()
    }
    
    private func setupEmptyStateConstraints() {
        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor, constant: 20),
            emptyStateView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor, constant: -20)
        ])
    }
    
    private func updateEmptyStateVisibility(taskCount: Int) {
        emptyStateView.isHidden = taskCount > 0
        tableView.isHidden = false
        footerView.updateTaskCount(taskCount)
    }
    
    // MARK: - Helpers
    private func getCurrentTasks() -> [TaskViewModel] {
        return isSearchActive ? filteredTasks : tasks
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showConfirmationAlert(title: String, message: String, confirmAction: @escaping () -> Void) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { _ in
            confirmAction()
        })
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension TaskListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getCurrentTasks().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as? TaskCell else {
            return UITableViewCell()
        }
        
        let taskList = getCurrentTasks()
        guard indexPath.row < taskList.count else {
            return cell
        }
        
        let task = taskList[indexPath.row]
        configureCell(cell, with: task, at: indexPath)
        
        return cell
    }
    
    private func configureCell(_ cell: TaskCell, with task: TaskViewModel, at indexPath: IndexPath) {
        cell.configure(
            with: task.title,
            description: task.taskDescription,
            date: task.createdAt,
            isCompleted: task.isCompleted
        )
        
        cell.checkboxAction = { [weak self] in
            guard let self = self else { return }
            let visualIndex = indexPath.row
            self.taskListPresenter?.didToggleTaskCompletion(at: visualIndex)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        provideTactileFeedback()
        
        let actualIndex = indexPath.row
        
        // Имитируем визуальный эффект нажатия с помощью задержки
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.taskListPresenter?.didTapTask(at: actualIndex)
        }
    }
    
    private func provideTactileFeedback() {
        if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = createDeleteAction(for: indexPath)
        
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        config.performsFirstActionWithFullSwipe = false
        return config
    }
    
    private func createDeleteAction(for indexPath: IndexPath) -> UIContextualAction {
        return UIContextualAction(style: .destructive, title: "Удалить") { [weak self] (_, _, completion) in
            guard let self = self else { 
                completion(false)
                return 
            }
            
            let actualIndex = indexPath.row
            
            // Показываем диалог подтверждения
            self.showConfirmationAlert(
                title: "Удаление задачи",
                message: "Вы действительно хотите удалить эту задачу?"
            ) {
                self.taskListPresenter?.didTapDeleteTask(at: actualIndex)
                completion(true)
            }
        }
    }
    
    // Добавляем метод для создания контекстного меню при долгом нажатии
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let tasks = getCurrentTasks()
        guard indexPath.row < tasks.count else { return nil }
        
        let task = tasks[indexPath.row]
        let actualIndex = indexPath.row
        
        // Создаем кастомный предпросмотр для контекстного меню
        let previewProvider: UIContextMenuContentPreviewProvider = {
            return self.createTaskPreviewController(for: task)
        }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: previewProvider) { _ in
            let editAction = self.createEditAction(for: actualIndex)
            let shareAction = self.createShareAction(for: task, indexPath: indexPath)
            let deleteAction = self.createDeleteContextMenuAction(for: actualIndex)
            
            return UIMenu(title: "", children: [editAction, shareAction, deleteAction])
        }
    }
    
    private func createTaskPreviewController(for task: TaskViewModel) -> UIViewController {
        let previewController = UIViewController()
        previewController.view.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
        
        let containerView = createPreviewContainerView()
        let titleLabel = createPreviewTitleLabel(with: task.title)
        let descriptionLabel = createPreviewDescriptionLabel(with: task.taskDescription)
        let dateLabel = createPreviewDateLabel(with: task.formattedDate)
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(dateLabel)
        
        previewController.view.addSubview(containerView)
        
        setupPreviewConstraints(container: containerView, title: titleLabel, description: descriptionLabel, date: dateLabel)
        
        return previewController
    }
    
    private func createPreviewContainerView() -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = UIColor(red: 0.17, green: 0.17, blue: 0.18, alpha: 1.0)
        containerView.layer.cornerRadius = 12
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }
    
    private func createPreviewTitleLabel(with title: String) -> UILabel {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }
    
    private func createPreviewDescriptionLabel(with description: String?) -> UILabel {
        let descriptionLabel = UILabel()
        descriptionLabel.text = description ?? "Нет описания"
        descriptionLabel.textColor = .white
        descriptionLabel.font = UIFont.systemFont(ofSize: 12)
        descriptionLabel.numberOfLines = 3
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        return descriptionLabel
    }
    
    private func createPreviewDateLabel(with dateText: String) -> UILabel {
        let dateLabel = UILabel()
        dateLabel.text = dateText
        dateLabel.textColor = .white.withAlphaComponent(0.5)
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        return dateLabel
    }
    
    private func setupPreviewConstraints(container: UIView, title: UILabel, description: UILabel, date: UILabel) {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: container.superview!.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: container.superview!.trailingAnchor, constant: -16),
            container.topAnchor.constraint(equalTo: container.superview!.topAnchor, constant: 16),
            container.bottomAnchor.constraint(equalTo: container.superview!.bottomAnchor, constant: -16),
            
            title.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            title.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            title.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            
            description.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8),
            description.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            description.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            
            date.topAnchor.constraint(equalTo: description.bottomAnchor, constant: 8),
            date.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            date.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            date.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
    }
    
    private func createEditAction(for index: Int) -> UIAction {
        return UIAction(
            title: "Редактировать",
            image: UIImage(systemName: "pencil"),
            attributes: []
        ) { [weak self] _ in
            self?.taskListPresenter?.didTapTask(at: index)
        }
    }
    
    private func createShareAction(for task: TaskViewModel, indexPath: IndexPath) -> UIAction {
        return UIAction(
            title: "Поделиться",
            image: UIImage(systemName: "square.and.arrow.up"),
            attributes: []
        ) { [weak self] _ in
            guard let self = self else { return }
            
            let shareText = self.createShareText(from: task)
            let activityViewController = UIActivityViewController(
                activityItems: [shareText],
                applicationActivities: nil
            )
            
            // Для iPad - настройка popoverPresentationController
            if let popover = activityViewController.popoverPresentationController {
                if let cell = tableView.cellForRow(at: indexPath) {
                    popover.sourceView = cell
                    popover.sourceRect = cell.bounds
                }
            }
            
            // Показываем меню "Поделиться"
            self.present(activityViewController, animated: true)
        }
    }
    
    private func createShareText(from task: TaskViewModel) -> String {
        var shareText = "Задача: \(task.title)"
        if let description = task.taskDescription, !description.isEmpty {
            shareText += "\n\nОписание: \(description)"
        }
        shareText += "\n\nСтатус: \(task.isCompleted ? "Выполнено" : "Не выполнено")"
        shareText += "\nДата создания: \(task.formattedDate)"
        return shareText
    }
    
    private func createDeleteContextMenuAction(for index: Int) -> UIAction {
        return UIAction(
            title: "Удалить",
            image: UIImage(systemName: "trash"),
            attributes: .destructive
        ) { [weak self] _ in
            guard let self = self else { return }
            
            self.showConfirmationAlert(
                title: "Удаление задачи",
                message: "Вы уверены, что хотите удалить эту задачу?"
            ) {
                self.taskListPresenter?.didTapDeleteTask(at: index)
            }
        }
    }
}

// MARK: - UISearchBarDelegate
extension TaskListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Отменяем предыдущий отложенный поиск
        searchDebounceTimer?.invalidate()
        
        // Создаем новый таймер для задержки поиска, чтобы не запускать поиск на каждый символ
        searchDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            if searchText.isEmpty {
                self.taskListPresenter?.clearSearch()
            } else {
                self.taskListPresenter?.searchTasks(with: searchText)
            }
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