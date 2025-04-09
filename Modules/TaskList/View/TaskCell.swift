import UIKit

final class TaskCell: UITableViewCell {
    
    // MARK: - UI Elements
    private(set) var titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let dateLabel = UILabel()
    private let checkboxButton = UIButton()
    private let containerView = UIView()
    
    // Блокирующий слой для предотвращения системного выделения
    private let highlightBlockingView = UIView()
    
    // MARK: - Properties
    var checkboxAction: (() -> Void)?
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupCellBackground()
        setupHighlightBlockingLayer()
        setupContainerView()
        setupLabelsAndButtons()
        setupConstraints()
    }
    
    private func setupCellBackground() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
    }
    
    private func setupHighlightBlockingLayer() {
        highlightBlockingView.backgroundColor = .black
        highlightBlockingView.isUserInteractionEnabled = false
        highlightBlockingView.alpha = 0.0
        highlightBlockingView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(highlightBlockingView)
    }
    
    private func setupContainerView() {
        containerView.backgroundColor = .black
        containerView.layer.cornerRadius = 12
        containerView.clipsToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
    }
    
    private func setupLabelsAndButtons() {
        setupTitleLabel()
        setupDescriptionLabel()
        setupDateLabel()
        setupCheckboxButton()
        
        containerView.addSubview(checkboxButton)
        containerView.addSubview(titleLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(dateLabel)
    }
    
    private func setupTitleLabel() {
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupDescriptionLabel() {
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textColor = .lightGray
        descriptionLabel.numberOfLines = 2
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupDateLabel() {
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        dateLabel.textColor = .gray
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupCheckboxButton() {
        checkboxButton.setImage(UIImage(systemName: "circle"), for: .normal)
        checkboxButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
        checkboxButton.tintColor = .white
        checkboxButton.addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)
        checkboxButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
        setupBlockingViewConstraints()
        setupContainerConstraints()
        setupContentConstraints()
        setupHeightConstraint()
    }
    
    private func setupBlockingViewConstraints() {
        NSLayoutConstraint.activate([
            highlightBlockingView.topAnchor.constraint(equalTo: contentView.topAnchor),
            highlightBlockingView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            highlightBlockingView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            highlightBlockingView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    private func setupContainerConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    private func setupContentConstraints() {
        NSLayoutConstraint.activate([
            checkboxButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            checkboxButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            checkboxButton.widthAnchor.constraint(equalToConstant: 24),
            checkboxButton.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: checkboxButton.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            dateLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupHeightConstraint() {
        let heightConstraint = containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 90)
        heightConstraint.priority = UILayoutPriority(999)
        heightConstraint.isActive = true
    }
    
    // MARK: - Configuration
    func configure(with title: String?, description: String?, date: Date?, isCompleted: Bool) {
        titleLabel.attributedText = nil
        titleLabel.text = nil
        
        configureCheckboxState(isCompleted)
        configureTitleWithCompletion(title, isCompleted)
        configureDescription(description)
        configureDate(date)
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func configureCheckboxState(_ isCompleted: Bool) {
        checkboxButton.isSelected = isCompleted
    }
    
    private func configureTitleWithCompletion(_ title: String?, _ isCompleted: Bool) {
        let finalTitle = title?.isEmpty ?? true ? "Без названия" : title!
        
        titleLabel.textColor = .white
        
        if isCompleted {
            applyStrikethroughStyle(to: finalTitle)
        } else {
            titleLabel.text = finalTitle
        }
    }
    
    private func applyStrikethroughStyle(to text: String) {
        let attributes: [NSAttributedString.Key: Any] = [
            .strikethroughStyle: NSUnderlineStyle.single.rawValue,
            .strikethroughColor: UIColor.white,
            .foregroundColor: UIColor.white
        ]
        titleLabel.attributedText = NSAttributedString(string: text, attributes: attributes)
    }
    
    private func configureDescription(_ description: String?) {
        descriptionLabel.text = description?.isEmpty ?? true ? "Без описания" : description
    }
    
    private func configureDate(_ date: Date?) {
        if let date = date {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            dateLabel.text = formatter.string(from: date)
        } else {
            dateLabel.text = ""
        }
    }
    
    // MARK: - Actions
    @objc private func checkboxTapped() {
        checkboxAction?()
    }
    
    // MARK: - Overrides for Cell States
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        // Не вызываем super, чтобы полностью исключить системные эффекты
        applyHighlightState(highlighted, animated: animated)
    }
    
    private func applyHighlightState(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            activateHighlightedState(animated: animated)
        } else {
            deactivateHighlightedState(animated: animated)
        }
    }
    
    private func activateHighlightedState(animated: Bool) {
        highlightBlockingView.alpha = 1.0
        highlightBlockingView.backgroundColor = .black
        
        UIView.animate(withDuration: animated ? 0.15 : 0) {
            self.containerView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
            self.containerView.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        }
    }
    
    private func deactivateHighlightedState(animated: Bool) {
        highlightBlockingView.alpha = 0.0
        
        UIView.animate(withDuration: animated ? 0.2 : 0) {
            self.containerView.backgroundColor = .black
            self.containerView.transform = .identity
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        // Не вызываем super, чтобы полностью исключить системные эффекты
        highlightBlockingView.alpha = selected ? 1.0 : 0.0
        
        if selected {
            highlightBlockingView.backgroundColor = .black
        }
    }
    
    // MARK: - Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
        resetContent()
    }
    
    private func resetContent() {
        titleLabel.attributedText = nil
        titleLabel.text = nil
        descriptionLabel.text = nil
        dateLabel.text = nil
        checkboxButton.isSelected = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        ensureCorrectZOrder()
    }
    
    private func ensureCorrectZOrder() {
        contentView.bringSubviewToFront(highlightBlockingView)
        contentView.bringSubviewToFront(containerView)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        enforceBlackBackground()
    }
    
    private func enforceBlackBackground() {
        backgroundColor = .black
        contentView.backgroundColor = .clear
        highlightBlockingView.backgroundColor = .black
    }
} 