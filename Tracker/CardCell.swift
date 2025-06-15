//
//  CardCell.swift
//  Tracker
//
//  Created by Ди Di on 28/05/25.
//

import UIKit


final class CardCell: UICollectionViewCell {
    
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
        label.textColor = .ypBlack
        return label
    }()
    
    private let plusButtonSize: CGFloat = 34
    
    private lazy var plusButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 20)
        button.tintColor = .ypWhite
        button.layer.cornerRadius = plusButtonSize / 2
        button.layer.masksToBounds = true
        return button
    }()
    
    private var isCompleted: Bool = false
    private var daysCount: Int = 0
    var onToggleComplete: ((IndexPath, Bool) -> Void)?
    private var trackerId: UUID?
    private var isCompletedToday: Bool = false
    private var daysCountTotal: Int = 0
    var indexPath: IndexPath?
    
    private let pinImageView: UIImageView = {
        let img = UIImageView(image: UIImage(named: "pin"))
        img.translatesAutoresizingMaskIntoConstraints = false
        img.isHidden = true
        return img
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
        fatalError("init(coder:) has not been implemented")
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
    
    func configure(with card: Card, completedRecords: Set<TrackerRecord>, currentDate: Date) {
        self.trackerId = card.id
        emojiLabel.text = card.emoji
        descriptionLabel.text = card.description
        colorContainer.backgroundColor = card.color
        plusButton.backgroundColor = card.color
        
        let allRecordsForCard = completedRecords.filter { $0.trackerId == card.id }
        self.daysCountTotal = allRecordsForCard.count
        
        self.isCompletedToday = completedRecords.contains { rec in
            rec.trackerId == card.id && Calendar.current.isDate(rec.date, inSameDayAs: currentDate)
        }
        let suffix = dayText(for: daysCountTotal)
        dayLabel.text = "\(daysCountTotal) \(suffix)"
        updatePlusButtonAppearance()
    }
    
    private func dayText(for count: Int) -> String {
        let remainder10 = count % 10
        let remainder100 = count % 100
        if remainder10 == 1 && remainder100 != 11 {
            return "день"
        } else if (2...4).contains(remainder10) && !(12...14).contains(remainder100) {
            return "дня"
        } else {
            return "дней"
        }
    }
    
    @objc private func didTapPlusButton() {
        guard let indexPath = self.indexPath else { return }
        onToggleComplete?(indexPath, !isCompletedToday)
    }
    
    private func updatePlusButtonAppearance() {
        plusButton.setTitle(nil, for: .normal)
        plusButton.setImage(nil, for: .normal)
        if isCompletedToday {
            plusButton.setImage(UIImage(named: "done"), for: .normal)
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
