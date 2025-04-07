import UIKit

// Импорт нашего кастомного компонента
import UIKit.UITextField // Для доступа к расширенным свойствам UITextField
import Foundation // Для работы с датами

// Импорт кастомных UI компонентов

final class TaskDetailViewController: UIViewController, TaskDetailViewInterface {
    // MARK: - Properties
    var taskDetailPresenter: TaskDetailPresenterInterface?
    
    // MARK: - UI Components
    private let titleTextField = UITextField()
    private let descriptionTextView = UITextView()
    private let dateLabel = UILabel()
    private let deleteButton = UIButton(type: .system)
    
    // Добавляем плейсхолдер для текстового поля
    private let descriptionPlaceholder = "Добавьте описание задачи..."
    
    private var currentViewModel: TaskViewModel?
    private var isNewTask = false // Флаг для определения новой задачи
    private var hasUnsavedChanges = false // Флаг для отслеживания изменений
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG: TaskDetailViewController - viewDidLoad вызван")
        setupViews()
        configureDarkTheme()
        
        // Проверяем наличие navigationController и активируем навигационную панель
        if let navigationController = self.navigationController {
            print("DEBUG: NavigationController существует")
            navigationController.isNavigationBarHidden = false
            navigationController.navigationBar.isHidden = false
            
            // Настраиваем отступ для навигационной панели, чтобы кнопка назад была видна
            if #available(iOS 15.0, *) {
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = .black
                appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
                
                navigationController.navigationBar.standardAppearance = appearance
                navigationController.navigationBar.scrollEdgeAppearance = appearance
                navigationController.navigationBar.compactAppearance = appearance
                
                // Принудительно обновляем внешний вид навигационной панели
                navigationController.navigationBar.layoutIfNeeded()
            } else {
                // Для версий iOS ниже 15.0
                navigationController.navigationBar.barTintColor = .black
                navigationController.navigationBar.tintColor = .white
                navigationController.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
                navigationController.navigationBar.isTranslucent = false
            }
        } else {
            print("DEBUG: NavigationController отсутствует!")
        }
        
        taskDetailPresenter?.viewDidLoad()
        
        // Определяем, новая это задача или существующая
        if let viewModel = currentViewModel, viewModel.title.isEmpty && viewModel.taskDescription == nil {
            isNewTask = true
            title = "Новая задача"
            print("DEBUG: TaskDetailViewController - определена новая задача")
            // Для новой задачи сразу устанавливаем фокус на заголовок
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.titleTextField.becomeFirstResponder()
            }
        } else {
            isNewTask = false
            title = "Задача"
            print("DEBUG: TaskDetailViewController - определена существующая задача")
        }
        
        // Добавляем наблюдатель за клавиатурой
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG: TaskDetailViewController - viewWillAppear вызван")
        
        // Дополнительная проверка навигационной панели при появлении экрана
        if let navigationController = self.navigationController {
            print("DEBUG: viewWillAppear - NavigationController существует")
            navigationController.setNavigationBarHidden(false, animated: animated)
            print("DEBUG: viewWillAppear - Цвет фона панели: \(String(describing: navigationController.navigationBar.backgroundColor))")
            print("DEBUG: viewWillAppear - isNavigationBarHidden: \(navigationController.isNavigationBarHidden)")
            print("DEBUG: viewWillAppear - navigationBar.isHidden: \(navigationController.navigationBar.isHidden)")
        } else {
            print("DEBUG: viewWillAppear - NavigationController отсутствует!")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Сохраняем изменения при выходе из контроллера (как в приложении "Заметки")
        saveChanges()
        NotificationCenter.default.removeObserver(self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Setup
    private func configureDarkTheme() {
        print("DEBUG: TaskDetailViewController - configureDarkTheme вызван")
        view.backgroundColor = UIColor.black
        
        titleTextField.textColor = .white
        titleTextField.backgroundColor = UIColor.black
        
        descriptionTextView.textColor = .white
        descriptionTextView.backgroundColor = UIColor.black
        
        dateLabel.textColor = .white.withAlphaComponent(0.5)
    }
    
    private func setupViews() {
        print("DEBUG: TaskDetailViewController - setupViews вызван")
        
        // Устанавливаем цвет фона
        view.backgroundColor = .black
        
        // Настройка навигационной панели
        navigationItem.hidesBackButton = true
        let backBarButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        backBarButton.tintColor = UIColor(hex: "#FED702") // Желтый цвет из дизайна
        
        let backTitleButton = UIBarButtonItem(
            title: "Назад",
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        backTitleButton.tintColor = UIColor(hex: "#FED702")
        backTitleButton.setTitleTextAttributes([.foregroundColor: UIColor(hex: "#FED702")], for: .normal)
        
        navigationItem.leftBarButtonItems = [backBarButton, backTitleButton]
        
        // Настройка заголовка навигационной панели
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17)
            ]
        }
        
        // Добавляем кнопку удаления в правую часть навигационной панели
        let deleteBarButton = UIBarButtonItem(
            image: UIImage(systemName: "trash"),
            style: .plain,
            target: self,
            action: #selector(deleteButtonTapped)
        )
        deleteBarButton.tintColor = .red
        navigationItem.rightBarButtonItem = deleteBarButton
        
        // Настройка UI компонентов
        // Заголовок (текстовое поле) - всегда доступный для редактирования
        titleTextField.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        titleTextField.textColor = .white
        titleTextField.isEnabled = true
        titleTextField.backgroundColor = .black
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        titleTextField.placeholder = "Название задачи"
        titleTextField.borderStyle = .none
        titleTextField.delegate = self
        titleTextField.clearButtonMode = .whileEditing // Добавляем кнопку очистки текста
        
        // Дата создания
        dateLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        dateLabel.textColor = .white.withAlphaComponent(0.6)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Описание (текстовое поле) - всегда доступное для редактирования
        descriptionTextView.font = UIFont.systemFont(ofSize: 17)
        descriptionTextView.textColor = .white
        descriptionTextView.isEditable = true
        descriptionTextView.backgroundColor = .black
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0) // Добавляем отступы для текста
        descriptionTextView.delegate = self
        
        // Убираем видимую границу у описания
        descriptionTextView.layer.borderWidth = 0
        
        // Добавление UI компонентов на view
        view.addSubview(titleTextField)
        view.addSubview(dateLabel)
        view.addSubview(descriptionTextView)
        
        // Настройка Auto Layout
        NSLayoutConstraint.activate([
            // Заголовок
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            titleTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Дата
            dateLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Описание - добавляем явную высоту и растягиваем до нижней границы экрана
            descriptionTextView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 24),
            descriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            descriptionTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 150), // Минимальная высота
            descriptionTextView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        // Создаем клавиатурную панель
        let keyboardAccessoryView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        keyboardAccessoryView.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        
        // Добавим кнопки эмодзи и микрофон на панель клавиатуры
        let emojiButton = UIButton(type: .system)
        emojiButton.setImage(UIImage(systemName: "face.smiling"), for: .normal)
        emojiButton.tintColor = .white
        emojiButton.translatesAutoresizingMaskIntoConstraints = false
        keyboardAccessoryView.addSubview(emojiButton)
        
        let microphoneButton = UIButton(type: .system)
        microphoneButton.setImage(UIImage(systemName: "mic.fill"), for: .normal)
        microphoneButton.tintColor = .white
        microphoneButton.translatesAutoresizingMaskIntoConstraints = false
        keyboardAccessoryView.addSubview(microphoneButton)
        
        // Настраиваем констрейнты для кнопок
        NSLayoutConstraint.activate([
            emojiButton.leadingAnchor.constraint(equalTo: keyboardAccessoryView.leadingAnchor, constant: 20),
            emojiButton.centerYAnchor.constraint(equalTo: keyboardAccessoryView.centerYAnchor),
            emojiButton.widthAnchor.constraint(equalToConstant: 30),
            emojiButton.heightAnchor.constraint(equalToConstant: 30),
            
            microphoneButton.trailingAnchor.constraint(equalTo: keyboardAccessoryView.trailingAnchor, constant: -20),
            microphoneButton.centerYAnchor.constraint(equalTo: keyboardAccessoryView.centerYAnchor),
            microphoneButton.widthAnchor.constraint(equalToConstant: 30),
            microphoneButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        descriptionTextView.inputAccessoryView = keyboardAccessoryView
    }
    
    // MARK: - Keyboard Handling
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let bottomInset = keyboardSize.height - view.safeAreaInsets.bottom
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
            descriptionTextView.contentInset = contentInsets
            descriptionTextView.scrollIndicatorInsets = contentInsets
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        descriptionTextView.contentInset = .zero
        descriptionTextView.scrollIndicatorInsets = .zero
    }
    
    // MARK: - Actions
    @objc private func backButtonTapped() {
        // При нажатии на кнопку "Назад" сохраняем изменения и возвращаемся
        saveChanges()
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func deleteButtonTapped() {
        let alert = UIAlertController(
            title: "Удаление задачи",
            message: "Вы уверены, что хотите удалить эту задачу?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.taskDetailPresenter?.didTapDeleteTask()
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - TaskDetailViewInterface
    func displayTask(_ viewModel: TaskViewModel) {
        print("DEBUG: TaskDetailViewController - displayTask вызван с данными: \(viewModel.title)")
        currentViewModel = viewModel
        
        // Определяем, новая это задача или существующая
        isNewTask = viewModel.title.isEmpty && viewModel.taskDescription == nil
        if isNewTask {
            title = "Новая задача"
            print("DEBUG: TaskDetailViewController - определена новая задача в displayTask")
            
            // Для новой задачи устанавливаем пустые значения с плейсхолдерами
            titleTextField.text = ""
            descriptionTextView.text = ""
            applyPlaceholderStyleToDescriptionTextView()
        } else {
            title = "Задача" 
            print("DEBUG: TaskDetailViewController - определена существующая задача в displayTask")
            
            // Для существующей задачи заполняем реальными значениями
            titleTextField.text = viewModel.title
            
            // Отображаем описание если оно есть
            if let description = viewModel.taskDescription, !description.isEmpty {
                descriptionTextView.text = description
                descriptionTextView.textColor = .white
            } else {
                descriptionTextView.text = ""
                applyPlaceholderStyleToDescriptionTextView()
            }
        }
        
        // Форматируем дату в стиле из дизайна (DD/MM/YY)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"  // Формат как на скриншоте Figma
        dateLabel.text = dateFormatter.string(from: viewModel.createdAt)
        
        // Сбрасываем флаг изменений после загрузки данных
        hasUnsavedChanges = false
    }
    
    // Вспомогательный метод для применения стиля плейсхолдера
    private func applyPlaceholderStyleToDescriptionTextView() {
        descriptionTextView.text = descriptionPlaceholder
        descriptionTextView.textColor = .gray
    }
    
    func displayError(_ message: String) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        
        present(alert, animated: true)
    }
    
    // Реализуем методы из протокола, которые остались от предыдущей версии
    func enterEditMode() {
        // Для новой задачи устанавливаем фокус на поле заголовка
        if isNewTask {
            // Убеждаемся, что текстовые поля пустые
            titleTextField.text = ""
            descriptionTextView.text = ""
            applyPlaceholderStyleToDescriptionTextView()
            
            // Перемещаем фокус на заголовок
            titleTextField.becomeFirstResponder()
        }
    }
    
    func exitEditMode() {
        // Теперь не нужен, так как мы всегда в режиме редактирования
        // Просто убираем фокус и сохраняем изменения
        titleTextField.resignFirstResponder()
        descriptionTextView.resignFirstResponder()
        saveChanges()
    }
    
    // MARK: - Helper Methods
    private func saveChanges() {
        // Проверяем, есть ли изменения для сохранения
        if hasUnsavedChanges || isNewTask {
            // Проверяем заголовок на пустоту
            guard let title = titleTextField.text, !title.isEmpty else {
                // Для новой задачи без заголовка - просто выходим без сохранения
                if isNewTask {
                    return
                }
                displayError("Название не может быть пустым")
                return
            }
            
            // Обрабатываем описание - не сохраняем placeholder как текст
            var description: String? = descriptionTextView.text
            if description == descriptionPlaceholder && descriptionTextView.textColor == .gray {
                description = nil
            }
            
            // Отправляем данные для сохранения
            taskDetailPresenter?.didTapSaveTask(
                title: title,
                description: description,
                isCompleted: currentViewModel?.isCompleted ?? false
            )
            
            print("DEBUG: Задача сохранена с заголовком: \(title), описанием: \(String(describing: description))")
            hasUnsavedChanges = false
        }
    }
}

// MARK: - UITextViewDelegate
extension TaskDetailViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        // Очищаем placeholder при начале редактирования
        if textView.text == descriptionPlaceholder && textView.textColor == .gray {
            textView.text = ""
            textView.textColor = .white
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        // Восстанавливаем placeholder, если текстовое поле пустое
        if textView.text.isEmpty {
            applyPlaceholderStyleToDescriptionTextView()
        } else {
            // Фиксируем изменения в модели
            currentViewModel?.taskDescription = textView.text
            hasUnsavedChanges = true
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        // Отмечаем, что есть изменения
        hasUnsavedChanges = true
    }
}

// MARK: - UITextFieldDelegate
extension TaskDetailViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == titleTextField {
            // Обновляем модель данных
            currentViewModel?.title = textField.text ?? ""
            hasUnsavedChanges = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleTextField {
            // При нажатии Return переключаемся на описание
            descriptionTextView.becomeFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Отмечаем, что есть изменения
        hasUnsavedChanges = true
        return true
    }
}

// MARK: - UIColor Extension
extension UIColor {
    convenience init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
} 
