//
//  CardCell.swift
//  Tracker
//
//  Created by Ди Di on 28/05/25.
//

import UIKit


final class CardCell: UICollectionViewCell {
    static let reuseIdentifier = "CardCell"
    
    let colorContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .sfProDisplayMedium12
        label.textColor = .ypWhite
        label.numberOfLines = 2
        return label
    }()
    
    private let emojiBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.ypWhite.withAlphaComponent(0.2)
        view.layer.cornerRadius = 24 / 2
        view.clipsToBounds = true
        return view
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = .sfProDisplayMedium12
        label.textColor = UIColor { trait in
            trait.userInterfaceStyle == .dark ? .ypWhite: .ypBlack
        }
        return label
    }()
    
    private let plusButtonSize: CGFloat = 34
    
    private lazy var plusButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 20)
        button.tintColor = UIColor { trait in
            trait.userInterfaceStyle == .dark ? .ypBlack : .ypWhite
        }
        button.layer.cornerRadius = plusButtonSize / 2
        button.layer.masksToBounds = true
        return button
    }()
    
    private var isCompleted: Bool = false
    private var daysCount: Int = 0
    var onToggleComplete: ((IndexPath, Bool, Card, Date) -> Void)?
    private var currentCard: Card?
    private var currentPickedDay: Date?
    private var trackerId: UUID?
    private var isCompletedToday: Bool = false
    private var daysCountTotal: Int = 0
    var indexPath: IndexPath?
    
    private let pinImageView: UIImageView = {
        let image = UIImageView(image: UIImage(resource: .pin))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.isHidden = true
        return image
    }()
    
    private var isPinned: Bool = false {
        didSet {
            pinImageView.isHidden = !isPinned
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupConstraints()
    }
    
    private func setupSubviews() {
        contentView.addSubview(colorContainer)
        colorContainer.addSubview(pinImageView)
        colorContainer.addSubview(emojiBackgroundView)
        emojiBackgroundView.addSubview(emojiLabel)
        colorContainer.addSubview(descriptionLabel)
        contentView.backgroundColor = .clear
        contentView.addSubview(dayLabel)
        contentView.addSubview(plusButton)
        plusButton.addTarget(self, action: #selector(didTapPlusButton), for: .touchUpInside)
    }
    
    private func setupUI() {
        [colorContainer, pinImageView, emojiBackgroundView, emojiLabel, descriptionLabel, dayLabel, plusButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        contentView.addSubview(colorContainer)
        colorContainer.addSubviews(pinImageView, emojiBackgroundView, descriptionLabel)
        emojiBackgroundView.addSubviews(emojiLabel)
        contentView.addSubviews(dayLabel, plusButton)
        
        plusButton.addTarget(self, action: #selector(didTapPlusButton), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            colorContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            colorContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorContainer.heightAnchor.constraint(equalToConstant: 90),
            
            emojiBackgroundView.topAnchor.constraint(equalTo: colorContainer.topAnchor, constant: 12),
            emojiBackgroundView.leadingAnchor.constraint(equalTo: colorContainer.leadingAnchor, constant: 12),
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: 24),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: 24),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: colorContainer.leadingAnchor, constant: 12),
            descriptionLabel.trailingAnchor.constraint(equalTo: colorContainer.trailingAnchor, constant: -12),
            descriptionLabel.bottomAnchor.constraint(equalTo: colorContainer.bottomAnchor, constant: -12),
            
            plusButton.topAnchor.constraint(equalTo: colorContainer.bottomAnchor, constant: 8),
            plusButton.trailingAnchor.constraint(equalTo: colorContainer.trailingAnchor, constant: -12),
            plusButton.widthAnchor.constraint(equalToConstant: plusButtonSize),
            plusButton.heightAnchor.constraint(equalToConstant: plusButtonSize),
            plusButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            dayLabel.leadingAnchor.constraint(equalTo: colorContainer.leadingAnchor, constant: 12),
            dayLabel.centerYAnchor.constraint(equalTo: plusButton.centerYAnchor),
            
            pinImageView.topAnchor.constraint(equalTo: colorContainer.topAnchor, constant: 12),
            pinImageView.trailingAnchor.constraint(equalTo: colorContainer.trailingAnchor, constant: -4),
            pinImageView.widthAnchor.constraint(equalToConstant: 24),
            pinImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func configure(with card: Card, dayKey: String, completedRecords: Set<TrackerRecord>, currentDate: Date) {
        self.trackerId = card.id
        emojiLabel.text = card.emoji
        descriptionLabel.text = card.description
        colorContainer.backgroundColor = card.color
        plusButton.backgroundColor = card.color
        
        self.currentCard = card
        self.currentPickedDay = currentDate
        
        let allRecordsForCard = completedRecords.filter { $0.trackerId == card.id }
        self.daysCountTotal = allRecordsForCard.count
        
        self.isCompletedToday = completedRecords.contains { rec in
            rec.trackerId == card.id && Calendar.current.isDate(rec.date, inSameDayAs: currentDate)
        }
        dayLabel.text = dayText(for: daysCountTotal)
        updatePlusButtonAppearance()
        self.isPinned = card.isPinned
    }
    
    private func dayText(for count: Int) -> String {
        let daysString = String.localizedStringWithFormat(
            NSLocalizedString("numberOfDays", comment: "Number of remaining days"),
            count
        )
        return daysString
    }
    
    @objc private func didTapPlusButton() {
        guard let indexPath = self.indexPath,
              let card = self.currentCard,
              let pickedDay = self.currentPickedDay
        else { return }
        
        onToggleComplete?(indexPath, !isCompletedToday, card, pickedDay)
    }
    
    private func updatePlusButtonAppearance() {
        plusButton.setTitle(nil, for: .normal)
        plusButton.setImage(nil, for: .normal)
        if isCompletedToday {
            plusButton.setImage(UIImage(resource: .done), for: .normal)
            plusButton.backgroundColor = colorContainer.backgroundColor?.withAlphaComponent(0.3)
        } else {
            plusButton.setTitle("+", for: .normal)
            plusButton.backgroundColor = colorContainer.backgroundColor
        }
    }
}

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
    }
}
