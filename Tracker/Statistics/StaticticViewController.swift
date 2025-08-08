//
//  StatisticViewController.swift
//  Tracker
//
//  Created by Ди Di on 23/05/25.
//

import UIKit


final class StatisticViewController: UIViewController {
    private var statistics: [(title: String, value: Int)] = []
    private let recordStore = TrackerRecordStore.shared
    
    private enum Layout {
        static let topPadding: CGFloat = 77
        static let sidePadding: CGFloat = 16
        static let stackSpacing: CGFloat = 12
        static let cardHeight: CGFloat = 90
        static let errorIconSize = CGSize(width: 80, height: 80)
        static let errorSpacing: CGFloat = 8
    }
    
    private let statisticsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Layout.stackSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var errorView: UIView = {
        let errorView = UIView()
        errorView.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView(image: UIImage(resource: .statisticError))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        errorView.addSubview(imageView)
        
        let label = UILabel()
        label.text = NSLocalizedString("empty_statistics_screen", comment: "")
        label.textColor = .label
        label.font = .sfProDisplayMedium12
        label.translatesAutoresizingMaskIntoConstraints = false
        errorView.addSubview(label)
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: Layout.errorIconSize.width),
            imageView.heightAnchor.constraint(equalToConstant: Layout.errorIconSize.height),
            imageView.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: errorView.topAnchor),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Layout.errorSpacing),
            label.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: errorView.bottomAnchor)
        ])
        return errorView
    }()
    
    private lazy var cardStore: CardStore = {
        let ctx = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return CardStore(context: ctx)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.title = NSLocalizedString("statistics_title", comment: "")
        
        view.addSubview(statisticsStackView)
        
        NSLayoutConstraint.activate([
            statisticsStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Layout.topPadding),
            statisticsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.sidePadding),
            statisticsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.sidePadding)
        ])
        updateStatistics()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStatistics()
    }
    
    private func updateStatistics() {
        DispatchQueue.global(qos: .userInitiated).async {
            let allRecords = self.recordStore.getAllRecords()
            let existingTrackerIDs = Set(
                self.cardStore.fetchCards().map { $0.id }
            )
            let validRecords = allRecords.filter { existingTrackerIDs.contains($0.trackerId) }
            let stats = StatisticsModel.compute(records: validRecords)
            
            DispatchQueue.main.async {
                self.statistics = stats
                self.applyStatistics()
            }
        }
    }
    
    private func applyStatistics() {
        statisticsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        errorView.removeFromSuperview()
        if cardStore.fetchCards().isEmpty {
            view.addSubview(errorView)
            NSLayoutConstraint.activate([
                errorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                errorView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
            return
        }
        guard !statistics.isEmpty else {
            view.addSubview(errorView)
            NSLayoutConstraint.activate([
                errorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                errorView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
            return
        }
        
        for statistic in statistics {
            let card = StatisticsCardView()
            card.configure(value: statistic.value, title: statistic.title, color: .systemBlue)
            card.heightAnchor.constraint(equalToConstant: Layout.cardHeight).isActive = true
            statisticsStackView.addArrangedSubview(card)
        }
    }
}
