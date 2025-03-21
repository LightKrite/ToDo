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
        
        // Настройка метки с количеством задач
        countLabel.textColor = .white
        countLabel.font = Constants.taskCountFont
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(countLabel)
        
        // Настройка кнопки добавления
        let pencilConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
        addButton.setImage(UIImage(systemName: "square.and.pencil", withConfiguration: pencilConfig), for: .normal)
        addButton.tintColor = Constants.buttonTintColor
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(addButton)
        
        // Установка ограничений AutoLayout
        NSLayoutConstraint.activate([
            countLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            countLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            addButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            addButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 36),
            addButton.heightAnchor.constraint(equalToConstant: 36)
        ])
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