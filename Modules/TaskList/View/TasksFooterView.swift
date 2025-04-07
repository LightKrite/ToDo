import UIKit

final class TasksFooterView: UIView {
    // MARK: - UI Components
    private let countLabel = UILabel()
    private let addButton = UIButton(type: .system)
    
    // MARK: - Constants
    private struct Constants {
        static let backgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0)
        static let taskCountFont = UIFont.systemFont(ofSize: 17, weight: .regular)
        static let buttonTintColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0) // Желтый
    }
    
    // MARK: - Callback
    var addTaskAction: (() -> Void)?
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupView() {
        backgroundColor = Constants.backgroundColor
        
        // Добавляем верхнюю разделительную линию
        let topSeparator = UIView()
        topSeparator.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        topSeparator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(topSeparator)
        
        // Настройка метки с количеством задач
        countLabel.textColor = .white
        countLabel.font = Constants.taskCountFont
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(countLabel)
        
        // Настройка кнопки добавления
        // Используем желтый карандаш как на макете
        let pencilConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
        addButton.setImage(UIImage(systemName: "square.and.pencil", withConfiguration: pencilConfig), for: .normal)
        addButton.tintColor = Constants.buttonTintColor
        addButton.backgroundColor = .clear
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Создаем круглый фон для кнопки
        addButton.layer.cornerRadius = 24
        addButton.layer.masksToBounds = true
        
        // Добавляем эффект нажатия
        addButton.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        addButton.addTarget(self, action: #selector(buttonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        addSubview(addButton)
        
        // Установка ограничений AutoLayout
        NSLayoutConstraint.activate([
            // Верхний разделитель
            topSeparator.topAnchor.constraint(equalTo: topAnchor),
            topSeparator.leadingAnchor.constraint(equalTo: leadingAnchor),
            topSeparator.trailingAnchor.constraint(equalTo: trailingAnchor),
            topSeparator.heightAnchor.constraint(equalToConstant: 0.5),
            
            // Метка количества задач
            countLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            countLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            // Кнопка добавления
            addButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            addButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 48),
            addButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    // MARK: - Button Effects
    @objc private func buttonTouchDown() {
        UIView.animate(withDuration: 0.1) {
            self.addButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.addButton.alpha = 0.9
        }
    }
    
    @objc private func buttonTouchUp() {
        UIView.animate(withDuration: 0.1) {
            self.addButton.transform = .identity
            self.addButton.alpha = 1.0
        }
    }
    
    // MARK: - Actions
    @objc private func addButtonTapped() {
        addTaskAction?()
    }
    
    // MARK: - Public Methods
    func updateTaskCount(_ count: Int) {
        countLabel.text = "\(count) Задач"
    }
} 