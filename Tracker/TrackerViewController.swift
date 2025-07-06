//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Ди Di on 22/05/25.
//

import UIKit
import CoreData


final class TrackerViewController: UIViewController {
    private let searchController = UISearchController(searchResultsController: nil)
    private var sections: [TrackerSection] = []
    private var allSections: [TrackerSection] = []
    private var completedRecords: Set<TrackerRecord> = []
    private var currentDate: Date = Date()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 9
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let pinnedSectionTitle = "Закрепленные"
    private let trackersKey = "trackersData"
    private let recordsKey = "trackerRecordsData"
    
    private lazy var cardStore: CardStore = {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return CardStore(context: appDelegate.persistentContainer.viewContext)
        } else {
            assertionFailure("AppDelegate не найден или не того типа")
            return CardStore(context: NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType))
        }
    }()
    
    private lazy var trackerRecordStore: TrackerRecordStore = {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return TrackerRecordStore(context: appDelegate.persistentContainer.viewContext)
        } else {
            assertionFailure("AppDelegate не найден или не того типа")
            return TrackerRecordStore(context: NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType))
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCardsFromCoreData()
        completedRecords = Set(trackerRecordStore.fetchAllRecords())
        view.backgroundColor = .ypWhite
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.title = "Трекеры"
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .ypWhite
        appearance.shadowColor = .clear
        appearance.largeTitleTextAttributes = [
            .font: UIFont.sfProDisplayBold34 ?? UIFont.systemFont(ofSize: 34, weight: .bold),
            .foregroundColor: UIColor.ypBlack
        ]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        showNavBarButton()
        showNavBarDate()
        navigationItem.searchController = searchController
        searchController.searchBar.placeholder = "Поиск"
        let searchTextField = searchController.searchBar.searchTextField
        searchTextField.font = .sfProDisplayRegular17
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        datePicker.locale = Locale(identifier: "ru_RU")
        
        view.addSubview(collectionView)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        NSLayoutConstraint.activate([
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        collectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.register(CardCell.self, forCellWithReuseIdentifier: "cell")
        filterSectionsForCurrentDate()
        updateEmptyState()
    }
    
    private func showNavBarButton() {
        let navBarButtonItem = UIImage(named: "nav_bar_button")
        let navBarButton = UIBarButtonItem(
            image: navBarButtonItem,
            style: .plain,
            target: self,
            action: #selector(didTapAddSection)
        )
        navBarButton.tintColor = .ypBlack
        navigationItem.leftBarButtonItem = navBarButton
    }
    
    private func showNavBarDate() {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    @objc private func didTapAddSection() {
        let trackerCreationViewController = TrackerCreationViewController()
        trackerCreationViewController.onHabitButtonTap = { [weak self] in
            guard let self else { return }
            trackerCreationViewController.dismiss(animated: true) {
                let cardCreationViewController = CardCreationViewController(mode: .habit, cardStore: self.cardStore)
                cardCreationViewController.onSave = { [weak self] card, sectionTitle in
                    guard let self else { return }
                    self.addCard(toSectionWithTitle: sectionTitle, card: card)
                }
                cardCreationViewController.modalPresentationStyle = .pageSheet
                self.present(cardCreationViewController, animated: true)
            }
        }
        trackerCreationViewController.onIrregularEventTap = { [weak self] in
            guard let self else { return }
            trackerCreationViewController.dismiss(animated: true) {
                let cardCreationViewController = CardCreationViewController(mode: .irregularEvent, cardStore: self.cardStore)
                cardCreationViewController.onSave = { [weak self] card, sectionTitle in
                    guard let self else { return }
                    self.addCard(toSectionWithTitle: sectionTitle, card: card)
                }
                cardCreationViewController.modalPresentationStyle = .pageSheet
                self.present(cardCreationViewController, animated: true)
            }
        }
        trackerCreationViewController.modalPresentationStyle = .pageSheet
        present(trackerCreationViewController, animated: true)
    }
    
    private func showError(size: CGSize = CGSize(width: 80, height: 80)) {
        let imageView = UIImageView(image: UIImage(named: "Error"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.textColor = .ypBlack
        label.font = .sfProDisplayMedium12
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8)
        ])
    }
    
    private func removeError() {
        for subview in view.subviews {
            if let imageView = subview as? UIImageView,
               imageView.image == UIImage(named: "Error") {
                imageView.removeFromSuperview()
            }
            if let label = subview as? UILabel,
               label.text?.contains("Что будем отслеживать?") == true {
                label.removeFromSuperview()
            }
        }
    }
    
    private func updateEmptyState() {
        guard !sections.isEmpty else {
            showError()
            return
        }
        removeError()
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        self.currentDate = sender.date
        filterSectionsForCurrentDate()
    }
    
    private func filterSectionsForCurrentDate() {
        let calendar = Calendar.current
        let weekdayIndex = calendar.component(.weekday, from: currentDate)
        
        func weekdayName(for index: Int) -> String {
            switch index {
            case 2: return "Понедельник"
            case 3: return "Вторник"
            case 4: return "Среда"
            case 5: return "Четверг"
            case 6: return "Пятница"
            case 7: return "Суббота"
            case 1: return "Воскресенье"
            default: return ""
            }
        }
        let todayName = weekdayName(for: weekdayIndex)
        
        var pinnedCards: [Card] = []
        for section in allSections {
            for card in section.cards where card.isPinned {
                pinnedCards.append(card)
            }
        }
        var filtered: [TrackerSection] = []
        if !pinnedCards.isEmpty {
            filtered.append(TrackerSection(title: pinnedSectionTitle, cards: pinnedCards))
        }
        for section in allSections {
            let visibleCards = section.cards.filter { card in
                guard card.isPinned == false else {
                    return false
                }
                if card.selectedDays.isEmpty {
                    return true
                }
                return card.selectedDays.contains(todayName)
            }
            if !visibleCards.isEmpty {
                filtered.append(TrackerSection(title: section.title, cards: visibleCards))
            }
        }
        self.sections = filtered
        collectionView.reloadData()
        updateEmptyState()
    }
    
    private func addSection(title: String) {
        let newSection = TrackerSection(title: title, cards: [])
        allSections.append(newSection)
        filterSectionsForCurrentDate()
    }
    
    private func addCard(toSectionWithTitle sectionTitle: String, card: Card) {
        cardStore.addCard(card)
        self.allSections = []
        loadCardsFromCoreData()
        filterSectionsForCurrentDate()
        updateEmptyState()
    }
    
    @objc private func onHabitButtonTap() {
        let creationViewController = CardCreationViewController(mode: .habit, cardStore: cardStore)
        creationViewController.onSave = { [weak self] card, sectionTitle in
            guard let self else { return }
            self.addCard(toSectionWithTitle: sectionTitle, card: card)
        }
        let navigation = UINavigationController(rootViewController: creationViewController)
        navigation.modalPresentationStyle = .pageSheet
        present(navigation, animated: true)
    }
    
    private func pinTracker(at indexPath: IndexPath) {
        let cardToPin = sections[indexPath.section].cards[indexPath.item]
        if let oldSectionIndex = allSections.firstIndex(where: { $0.title == sections[indexPath.section].title }) {
            allSections[oldSectionIndex].cards.removeAll { $0.id == cardToPin.id }
            if allSections[oldSectionIndex].cards.isEmpty {
                allSections.remove(at: oldSectionIndex)
            }
        }
        var newCard = cardToPin
        newCard.isPinned = true
        cardStore.update(newCard)
        
        if let pinnedIdx = allSections.firstIndex(where: { $0.title == pinnedSectionTitle }) {
            allSections[pinnedIdx].cards.append(newCard)
        } else {
            allSections.insert(TrackerSection(title: pinnedSectionTitle, cards: [newCard]), at: 0)
        }
        filterSectionsForCurrentDate()
    }
    
    private func unpinTracker(at indexPath: IndexPath) {
        let cardToUnpin = sections[indexPath.section].cards[indexPath.item]
        
        if let pinnedSectionIndex = allSections.firstIndex(where: { $0.title == pinnedSectionTitle }) {
            allSections[pinnedSectionIndex].cards.removeAll { $0.id == cardToUnpin.id }
            if allSections[pinnedSectionIndex].cards.isEmpty {
                allSections.remove(at: pinnedSectionIndex)
            }
        }
        var newCard = cardToUnpin
        newCard.isPinned = false
        cardStore.update(newCard)
        
        let originalTitle = cardToUnpin.originalSectionTitle
        if let targetIdx = allSections.firstIndex(where: { $0.title == originalTitle }) {
            allSections[targetIdx].cards.append(newCard)
        } else {
            allSections.append(TrackerSection(title: originalTitle, cards: [newCard]))
        }
        filterSectionsForCurrentDate()
        collectionView.reloadData()
    }
    
    private func editTracker(indexPath: IndexPath) {
        let oldCard = sections[indexPath.section].cards[indexPath.item]
        let editingMode: CardCreationViewController.Mode = oldCard.selectedDays.isEmpty
        ? .irregularEvent : .habit
        let emojiIndex = IndexPath(item: CardCreationViewController.emojies.firstIndex(of: oldCard.emoji) ?? 0, section: 0)
        let colorIndex = IndexPath(item: oldCard.colorIndex, section: 0)
        
        let cardCreationViewController = CardCreationViewController(
            mode: editingMode,
            existingCardId: oldCard.id,
            initialSelectedEmojiIndex: emojiIndex,
            initialSelectedColorIndex: colorIndex,
            initialDescription: oldCard.description,
            initialSelectedDays: oldCard.selectedDays,
            initialSelectedCategory: oldCard.category,
            cardStore: cardStore
        )
        cardCreationViewController.onSave = { [weak self] (updatedCard: Card, updatedTitle: String) in
            guard let self else { return }
            var newCard = updatedCard
            newCard.isPinned = oldCard.isPinned
            self.cardStore.update(newCard)
            
            for i in 0..<self.allSections.count {
                self.allSections[i].cards.removeAll { $0.id == oldCard.id }
            }
            self.allSections.removeAll { $0.cards.isEmpty }
            
            if let index = self.allSections.firstIndex(where: { $0.title == updatedTitle }) {
                self.allSections[index].cards.append(newCard)
            } else {
                self.allSections.append(TrackerSection(title: updatedTitle, cards: [newCard]))
            }
            self.filterSectionsForCurrentDate()
            self.collectionView.reloadItems(at: [indexPath])
        }
        cardCreationViewController.modalPresentationStyle = UIModalPresentationStyle.pageSheet
        present(cardCreationViewController, animated: true)
    }
    
    private func deleteTracker(indexPath: IndexPath) {
        let cardToDelete = sections[indexPath.section].cards[indexPath.row]
        cardStore.delete(cardToDelete)
        loadCardsFromCoreData()
        filterSectionsForCurrentDate()
        collectionView.reloadData()
        updateEmptyState()
    }
    
    private func showDeleteConfirmation(for indexPath: IndexPath) {
        let alert = UIAlertController(
            title: nil,
            message: "Уверены, что хотите удалить трекер?",
            preferredStyle: .actionSheet
        )
        let delete = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            guard let self else { return }
            self.deleteTracker(indexPath: indexPath)
        }
        let cancel = UIAlertAction(title: "Отменить", style: .cancel, handler: nil)
        alert.addAction(delete)
        alert.addAction(cancel)
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = view.bounds
            popover.permittedArrowDirections = []
        }
        present(alert, animated: true, completion: nil)
    }
    
    private func loadCardsFromCoreData() {
        let cards = cardStore.fetchCards()
        self.allSections = groupCardsBySection(cards)
        collectionView.reloadData()
    }
    
    private func groupCardsBySection(_ cards: [Card]) -> [TrackerSection] {
        var sectionDict: [String: [Card]] = [:]
        for card in cards {
            sectionDict[card.originalSectionTitle, default: []].append(card)
        }
        return sectionDict.map { TrackerSection(title: $0.key, cards: $0.value) }
    }
}

extension TrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sections[section].cards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CardCell else {
            return UICollectionViewCell()
        }
        guard indexPath.section < sections.count else {
            print("\(indexPath.section) выходит за пределы sections.count = \(sections.count)")
            return UICollectionViewCell()
        }
        let cardsInThisSection = sections[indexPath.section].cards
        guard indexPath.item < cardsInThisSection.count else {
            print("indexPath.item = \(indexPath.item) выходит за пределы cardsInThisSection.count = \(cardsInThisSection.count)")
            return UICollectionViewCell()
        }
        let card = cardsInThisSection[indexPath.item]
        cell.configure(
            with: card,
            completedRecords: completedRecords,
            currentDate: self.currentDate
        )
        cell.indexPath = indexPath
        cell.onToggleComplete = { [weak self] cellIndexPath, newIsCompleted in
            guard let self else { return }
            let pickedDay = self.currentDate.stripTimeComponent()
            let today = Date().stripTimeComponent()
            if pickedDay > today {
                let alert = UIAlertController(
                    title: "Ошибка",
                    message: "Нельзя отметить карточку для будущей даты",
                    preferredStyle: .alert
                )
                alert.addAction(.init(title: "Ок", style: .default))
                self.present(alert, animated: true)
                return
            }
            let tappedCard = self.sections[cellIndexPath.section].cards[cellIndexPath.item]
            let trackerId   = tappedCard.id
            let recordForDate = TrackerRecord(trackerId: trackerId, date: self.currentDate)
            
            if newIsCompleted {
                self.completedRecords.insert(recordForDate)
                self.trackerRecordStore.add(recordForDate)
                
            } else {
                self.completedRecords.remove(recordForDate)
                self.trackerRecordStore.delete(recordForDate)
            }
            self.collectionView.reloadItems(at: [cellIndexPath])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? SupplementaryView else {
            return UICollectionReusableView()
        }
        view.titleLabel.text = sections[indexPath.section].title
        return view
    }
}

extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpacing: CGFloat = 16 + 16 + 9
        let availableWidth = collectionView.bounds.width - totalSpacing
        let cellWidth = availableWidth / 2
        return CGSize(width: cellWidth, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 46)
    }
}

extension TrackerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: nil) { _ in
            let isCurrentlyPinned = (self.sections[indexPath.section].title == self.pinnedSectionTitle)
            let pinTitle = isCurrentlyPinned ? "Открепить" : "Закрепить"
            let pinAction = UIAction(title: pinTitle) { _ in
                if isCurrentlyPinned {
                    self.unpinTracker(at: indexPath)
                } else {
                    self.pinTracker(at: indexPath)
                }
            }
            let editAction = UIAction(title: "Редактировать") { _ in
                self.editTracker(indexPath: indexPath)
            }
            let deleteAction = UIAction(
                title: "Удалить",
                attributes: .destructive
            ) { [weak self] _ in
                guard let self else { return }
                self.showDeleteConfirmation(for: indexPath)
            }
            return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard
            let nsIndex = configuration.identifier as? NSIndexPath
        else {
            return nil
        }
        let indexPath = nsIndex as IndexPath
        guard let cell = collectionView.cellForItem(at: indexPath) as? CardCell else {
            return nil
        }
        let parameters = UIPreviewParameters()
        parameters.visiblePath = UIBezierPath(
            roundedRect: cell.colorContainer.bounds,
            cornerRadius: 16
        )
        return UITargetedPreview(view: cell.colorContainer, parameters: parameters)
    }
    
    func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard
            let nsIndex = configuration.identifier as? NSIndexPath
        else {
            return nil
        }
        let indexPath = nsIndex as IndexPath
        guard let cell = collectionView.cellForItem(at: indexPath) as? CardCell else {
            return nil
        }
        let parameters = UIPreviewParameters()
        parameters.visiblePath = UIBezierPath(
            roundedRect: cell.colorContainer.bounds,
            cornerRadius: 16
        )
        return UITargetedPreview(view: cell.colorContainer, parameters: parameters)
    }
}
