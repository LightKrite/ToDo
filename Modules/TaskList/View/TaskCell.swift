import UIKit

final class TaskCell: UITableViewCell {
    // MARK: - UI Components
    private let checkboxButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let dateLabel = UILabel()
    private let separatorView = UIView()
    
    // MARK: - Callback
    var checkboxAction: (() -> Void)?
    
    // MARK: - Constants
    private struct Constants {
        static let checkboxSize: CGFloat = 24
        static let contentInsets = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)
        static let titleFont = UIFont.systemFont(ofSize: 17, weight: .medium)
        static let descriptionFont = UIFont.systemFont(ofSize: 15)
        static let dateFont = UIFont.systemFont(ofSize: 14)
        static let completedTaskColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0) // Желтый
    }
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupCell() {
        backgroundColor = .black
        selectionStyle = .none
        
        // Настройка чекбокса
        checkboxButton.translatesAutoresizingMaskIntoConstraints = false
        checkboxButton.addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)
        contentView.addSubview(checkboxButton)
        
        // Настройка заголовка задачи
        titleLabel.textColor = .white
        titleLabel.font = Constants.titleFont
        titleLabel.numberOfLines = 1
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        // Настройка описания задачи
        descriptionLabel.textColor = UIColor(white: 0.6, alpha: 1.0)
        descriptionLabel.font = Constants.descriptionFont
        descriptionLabel.numberOfLines = 2
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLabel)
        
        // Настройка даты
        dateLabel.textColor = UIColor(white: 0.5, alpha: 1.0)
        dateLabel.font = Constants.dateFont
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dateLabel)
        
        // Настройка разделителя
        separatorView.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(separatorView)
        
        // Установка ограничений AutoLayout
        NSLayoutConstraint.activate([
            // Чекбокс
            checkboxButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.contentInsets.left),
            checkboxButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.contentInsets.top),
            checkboxButton.widthAnchor.constraint(equalToConstant: Constants.checkboxSize),
            checkboxButton.heightAnchor.constraint(equalToConstant: Constants.checkboxSize),
            
            // Заголовок
            titleLabel.leadingAnchor.constraint(equalTo: checkboxButton.trailingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.contentInsets.right),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.contentInsets.top),
            
            // Описание
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.contentInsets.right),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            
            // Дата
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.contentInsets.bottom),
            
            // Разделитель
            separatorView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
    
    // MARK: - Actions
    @objc private func checkboxTapped() {
        checkboxAction?()
    }
    
    // MARK: - Configuration
    func configure(title: String, description: String, date: String, isCompleted: Bool) {
        // Настройка состояния задачи (выполнена/не выполнена)
        configureCompletionState(isCompleted: isCompleted, title: title)
        
        // Установка текста
        descriptionLabel.text = description
        dateLabel.text = date
    }
    
    private func configureCompletionState(isCompleted: Bool, title: String) {
        if isCompleted {
            // Стиль для выполненной задачи
            checkboxButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            checkboxButton.tintColor = Constants.completedTaskColor
            
            // Зачеркнутый текст для выполненных задач
            let attributedString = NSAttributedString(
                string: title,
                attributes: [
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .strikethroughColor: UIColor.lightGray,
                    .foregroundColor: UIColor.gray
                ]
            )
            titleLabel.attributedText = attributedString
            descriptionLabel.alpha = 0.5 // Делаем описание полупрозрачным для выполненных задач
        } else {
            // Стиль для невыполненной задачи
            checkboxButton.setImage(UIImage(systemName: "circle"), for: .normal)
            checkboxButton.tintColor = .gray
            titleLabel.attributedText = nil
            titleLabel.text = title
            titleLabel.textColor = .white
            descriptionLabel.alpha = 1.0
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.attributedText = nil
        titleLabel.text = nil
        descriptionLabel.text = nil
        dateLabel.text = nil
        checkboxAction = nil
    }
} 