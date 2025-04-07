import UIKit

/// Аксессуар клавиатуры для редактирования задачи в соответствии с дизайном Figma
final class TaskInputAccessoryView: UIView {
    // MARK: - UI Components
    private let emojiButton = UIButton(type: .system)
    private let microphoneButton = UIButton(type: .system)
    private let spaceView = UIView()
    
    // MARK: - Properties
    weak var textView: UITextView?
    
    // MARK: - Initialization
    init(frame: CGRect, textView: UITextView? = nil) {
        self.textView = textView
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupView() {
        backgroundColor = UIColor(white: 0.22, alpha: 0.75)
        
        // Применяем blur эффект как в дизайне
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blurView)
        
        setupButtons()
        
        // Настраиваем констрейнты для blur эффекта
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func setupButtons() {
        // Emoji кнопка
        emojiButton.setImage(UIImage(systemName: "face.smiling"), for: .normal)
        emojiButton.tintColor = .white
        emojiButton.addTarget(self, action: #selector(emojiButtonTapped), for: .touchUpInside)
        emojiButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(emojiButton)
        
        // Пространство между кнопками
        spaceView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(spaceView)
        
        // Кнопка микрофона
        microphoneButton.setImage(UIImage(systemName: "mic.fill"), for: .normal)
        microphoneButton.tintColor = .white
        microphoneButton.addTarget(self, action: #selector(microphoneButtonTapped), for: .touchUpInside)
        microphoneButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(microphoneButton)
        
        // Настраиваем констрейнты
        NSLayoutConstraint.activate([
            emojiButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            emojiButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            emojiButton.widthAnchor.constraint(equalToConstant: 30),
            emojiButton.heightAnchor.constraint(equalToConstant: 30),
            
            spaceView.leadingAnchor.constraint(equalTo: emojiButton.trailingAnchor, constant: 10),
            spaceView.trailingAnchor.constraint(equalTo: microphoneButton.leadingAnchor, constant: -10),
            spaceView.centerYAnchor.constraint(equalTo: centerYAnchor),
            spaceView.heightAnchor.constraint(equalToConstant: 30),
            
            microphoneButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            microphoneButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            microphoneButton.widthAnchor.constraint(equalToConstant: 30),
            microphoneButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    // MARK: - Actions
    @objc private func emojiButtonTapped() {
        // В реальном приложении здесь можно было бы показать панель эмодзи
        print("Emoji button tapped")
    }
    
    @objc private func microphoneButtonTapped() {
        // В реальном приложении здесь можно было бы активировать диктовку
        print("Microphone button tapped")
    }
} 