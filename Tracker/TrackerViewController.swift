//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Ди Di on 22/05/25.
//

import UIKit
import CoreData


final class TrackerViewController: UIViewController {
    private var sections: [TrackerSection] = []
    private var allSections: [TrackerSection] = []
    private var visibleSections: [TrackerSection] = []
    private var completedRecords: Set<TrackerRecord> = []
    private var currentDate: Date = Date()
    private let colors = Colors()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 9
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    private let pinnedSectionTitle = NSLocalizedString("pinned_title", comment: "")
    private let trackersKey = "trackersData"
    private let recordsKey = "trackerRecordsData"
    let analyticsService = AnalyticsService()
    
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
    
    private let weekdayKeys = ["sunday","monday","tuesday","wednesday","thursday","friday","saturday"]
    
    private var currentFilter: TrackerFilter = .all
    private var filteredTrackers: [Card] = []
    private var selectedDate: Date = Date()
    private let filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("filters", comment: ""), for: .normal)
        button.backgroundColor = .ypBlue
        button.tintColor = .ypWhite
        button.titleLabel?.font = .sfProDisplayRegular17
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let trackerStore = TrackerStore.shared
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.locale = Locale.current
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.backgroundColor = .ypLightGray
        picker.layer.cornerRadius = 8
        picker.layer.masksToBounds = true
        picker.overrideUserInterfaceStyle = .light
        return picker
    }()
    private var filterErrorView: UIView?
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = NSLocalizedString("search_ph", comment: "")
        searchBar.showsCancelButton = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchTextField.backgroundColor = .ypDoubleLightGray
        searchBar.searchTextField.font = .sfProDisplayRegular17
        return searchBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCardsFromCoreData()
        completedRecords = Set(trackerRecordStore.fetchAllRecords())
        collectionView.backgroundColor = colors.collectionViewBackgroundColor
        collectionView.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = NSLocalizedString("trackers_title", comment: "")
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        appearance.shadowColor = .clear
        appearance.largeTitleTextAttributes = [
            .font: UIFont.sfProDisplayBold34 ?? UIFont.systemFont(ofSize: 34, weight: .bold),
            .foregroundColor: UIColor.label
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        showNavBarButton()
        showNavBarDate()
        
        view.addSubview(searchBar)
        searchBar.delegate = self
        searchBar.searchTextField.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissSearch))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.register(CardCell.self, forCellWithReuseIdentifier: "cell")
        filterSectionsForCurrentDate()
        updateEmptyState()
        
        view.addSubview(filterButton)
        filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        
        allSections = groupCardsBySection(cardStore.fetchCards())
        visibleSections = allSections
        collectionView.reloadData()
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchBar.heightAnchor.constraint(equalToConstant: 36),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(50 + 16)),
            
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.widthAnchor.constraint(equalToConstant: 114)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analyticsService.report(
            event: "open",
            params: ["screen": "Main"]
        )
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        analyticsService.report(
            event: "close",
            params: ["screen": "Main"]
        )
    }
    
    private func showNavBarButton() {
        let navBarButtonItem = UIImage(resource: .navBarButton)
        let navBarButton = UIBarButtonItem(
            image: navBarButtonItem,
            style: .plain,
            target: self,
            action: #selector(didTapAddSection)
        )
        navBarButton.tintColor =  UIColor.label
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
        analyticsService.report(
            event: "click",
            params: ["screen": "Main","item": "add_track"]
        )
        
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
        let imageView = UIImageView(image: UIImage(resource: .error))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        let label = UILabel()
        label.text = NSLocalizedString("empty_main_screen", comment: "")
        label.textColor = UIColor.label
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
               imageView.image == UIImage(resource: .error) {
                imageView.removeFromSuperview()
            }
            if let label = subview as? UILabel,
               label.text?.contains(NSLocalizedString("empty_main_screen", comment: "")) == true {
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
        let selected = sender.date
        currentDate = selected
        analyticsService.report(
            event: "click",
            params: ["selected_date": DateFormatter.localizedString(from: selected, dateStyle: .short, timeStyle: .none),
                     "screen": "Main", "item": "date_changed"
                    ])
        filterSectionsForCurrentDate()
        if let text = searchBar.text, !text.trimmingCharacters(in: .whitespaces).isEmpty {
            textDidChange(searchBar.searchTextField)
            removeError()
        }
    }
    
    private func filterSectionsForCurrentDate() {
        let baseCards: [Card]
        switch currentFilter {
        case .all, .today:
            baseCards = allCardsForDate(currentDate)
        case .completed:
            baseCards = completedCardsForDate(currentDate)
        case .uncompleted:
            baseCards = uncompletedCardsForDate(currentDate)
        }
        
        let query = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
        let cards: [Card] = query.isEmpty ? baseCards : filteredTrackers
        
        let pinned   = cards.filter { $0.isPinned }
        let unpinned = cards.filter { !$0.isPinned }
        
        var newSections: [TrackerSection] = []
        if !pinned.isEmpty {
            newSections.append(TrackerSection(title: pinnedSectionTitle, cards: pinned))
        }
        let grouped = Dictionary(grouping: unpinned, by: { (card: Card) in
            card.originalSectionTitle
        })
        for (sectionTitle, cardsInSection) in grouped {
            newSections.append(TrackerSection(title: sectionTitle, cards: cardsInSection))
        }
        self.sections = newSections
        
        self.visibleSections = self.sections
        collectionView.reloadData()
        filterButton.isHidden = sections.isEmpty
        
        switch currentFilter {
        case .completed, .uncompleted:
            if sections.isEmpty {
                showFilterError()
                collectionView.isHidden = true
            } else {
                removeFilterError()
                collectionView.isHidden = false
            }
        default:
            removeFilterError()
            collectionView.isHidden = false
            updateEmptyState()
        }
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
            message: NSLocalizedString("delete_tracker_confirmation", comment: ""),
            preferredStyle: .actionSheet
        )
        let delete = UIAlertAction(title: NSLocalizedString("delete_button", comment: ""), style: .destructive) { [weak self] _ in
            guard let self else { return }
            self.deleteTracker(indexPath: indexPath)
        }
        let cancel = UIAlertAction(title: NSLocalizedString("cancel_button", comment: ""), style: .cancel, handler: nil)
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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            let placeholderText = NSLocalizedString("search_ph", comment: "")
            let placeholderColor: UIColor = (traitCollection.userInterfaceStyle == .dark)
            ? .ypMiddleGray
            : .ypGray
            searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
                string: placeholderText,
                attributes: [.foregroundColor: placeholderColor]
            )
        }
    }
    
    @objc private func filterButtonTapped() {
        analyticsService.report(
            event: "click",
            params: ["screen": "Main","item": "filter"]
        )
        let viewController = FilterSelectionViewController()
        viewController.delegate = self
        viewController.selectedFilter = currentFilter
        present(viewController, animated: true)
    }
    
    private func dayKey(for date: Date) -> String {
        let idx = Calendar.current.component(.weekday, from: date) - 1
        return weekdayKeys[idx]
    }
    
    private func allCardsForDate(_ date: Date) -> [Card] {
        let todayKey = dayKey(for: date)
        let all = cardStore.fetchCards()
        return all.filter { card in
            card.selectedDays.isEmpty || card.selectedDays.contains(todayKey)
        }
    }
    
    private func completedCardsForDate(_ date: Date) -> [Card] {
        let completedIds = Set(
            trackerRecordStore
                .getAllRecords()
                .filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
                .map { $0.trackerId }
        )
        return allCardsForDate(date).filter { completedIds.contains($0.id) }
    }
    
    private func uncompletedCardsForDate(_ date: Date) -> [Card] {
        let completedIds = Set(
            trackerRecordStore
                .getAllRecords()
                .filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
                .map { $0.trackerId }
        )
        return allCardsForDate(date).filter { !completedIds.contains($0.id) }
    }
    
    private func showFilterError() {
        guard filterErrorView == nil else { return }
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView(image: UIImage(resource: .filterError))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(imageView)
        
        let label = UILabel()
        label.text = NSLocalizedString("nothing_found", comment: "")
        label.textColor = .label
        label.font = .sfProDisplayMedium12
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        
        view.addSubview(container)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: container.topAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            
            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            
            container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40)
        ])
        filterErrorView = container
    }
    
    private func removeFilterError() {
        filterErrorView?.removeFromSuperview()
        filterErrorView = nil
    }
    
    @objc private func textDidChange(_ textField: UISearchTextField) {
        let query = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
        let todayCards = allCardsForDate(currentDate)
        
        if query.isEmpty {
            visibleSections = groupCardsBySection(todayCards)
        } else {
            var filteredSections: [TrackerSection] = []
            let grouped = Dictionary(grouping: todayCards, by: { $0.category?.name ?? "" })
            for (categoryTitle, cardsInCategory) in grouped {
                if categoryTitle.lowercased().contains(query) {
                    filteredSections.append(TrackerSection(title: categoryTitle, cards: cardsInCategory))
                } else {
                    let matching = cardsInCategory.filter {
                        $0.description.lowercased().contains(query)
                    }
                    if !matching.isEmpty {
                        filteredSections.append(TrackerSection(title: categoryTitle, cards: matching))
                    }
                }
            }
            visibleSections = filteredSections
        }
        collectionView.reloadData()
    }
    
    private func rebuildSections(from cards: [Card]) {
        let pinned   = cards.filter { $0.isPinned }
        let unpinned = cards.filter { !$0.isPinned }
        
        var newSections: [TrackerSection] = []
        if !pinned.isEmpty {
            newSections.append(TrackerSection(title: pinnedSectionTitle, cards: pinned))
        }
        let grouped = Dictionary(grouping: unpinned, by: \.originalSectionTitle)
        for (title, list) in grouped {
            newSections.append(TrackerSection(title: title, cards: list))
        }
        self.visibleSections = newSections
        collectionView.reloadData()
        
        if visibleSections.isEmpty {
            showFilterError()
            collectionView.isHidden = true
        } else {
            removeFilterError()
            collectionView.isHidden = false
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filterSectionsForCurrentDate()
    }
    
    @objc private func dismissSearch() {
        filterSectionsForCurrentDate()
        searchBarCancelButtonClicked(searchBar)
    }
}

extension TrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleSections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        visibleSections[section].cards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CardCell else {
            return UICollectionViewCell()
        }
        
        guard indexPath.section < visibleSections.count else {
            print("\(indexPath.section) выходит за пределы sections.count = \(visibleSections.count)")
            return UICollectionViewCell()
        }
        
        let cardsInThisSection = visibleSections[indexPath.section].cards
        guard indexPath.item < cardsInThisSection.count else {
            print("indexPath.item = \(indexPath.item) выходит за пределы cardsInThisSection.count = \(cardsInThisSection.count)")
            return UICollectionViewCell()
        }
        
        let card = cardsInThisSection[indexPath.item]
        
        cell.configure(
            with: card,
            dayKey: dayKey(for: currentDate),
            completedRecords: completedRecords,
            currentDate: currentDate
        )
        
        cell.indexPath = indexPath
        cell.onToggleComplete = { [weak self] cellIndexPath, newIsCompleted, card, pickedDay in
            guard let self else { return }
            
            let today = Date().stripTimeComponent()
            let pickedDayStripped = pickedDay.stripTimeComponent()
            
            if pickedDayStripped > today {
                let alert = UIAlertController(
                    title: NSLocalizedString("error", comment: ""),
                    message: NSLocalizedString("can't_mark_future_date", comment: ""),
                    preferredStyle: .alert
                )
                alert.addAction(.init(title: NSLocalizedString("ok_button", comment: ""), style: .default))
                self.present(alert, animated: true)
                return
            }
            
            self.analyticsService.report(
                event: "click",
                params: ["card_description": card.description, "screen": "Main", "item": "track"]
            )
            let trackerId = card.id
            let recordForDate = TrackerRecord(trackerId: trackerId, date: pickedDayStripped)
            
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
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? SupplementaryView else {
            return UICollectionReusableView()
        }
        header.titleLabel.text = visibleSections[indexPath.section].title
        return header
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
            let pinTitle = isCurrentlyPinned ? NSLocalizedString("unpin_button", comment: "") : NSLocalizedString("pin_button", comment: "")
            let pinAction = UIAction(title: pinTitle) { _ in
                if isCurrentlyPinned {
                    self.unpinTracker(at: indexPath)
                } else {
                    self.pinTracker(at: indexPath)
                }
                self.analyticsService.report(
                    event: "click",
                    params: ["screen": "Main", "item": "pin_unpin"]
                )
            }
            let editAction = UIAction(title: NSLocalizedString("edit_button", comment: "")) { _ in
                self.analyticsService.report(
                    event: "click",
                    params: ["screen": "Main", "item": "edit"]
                )
                self.editTracker(indexPath: indexPath)
            }
            let deleteAction = UIAction(
                title: NSLocalizedString("delete_button", comment: ""),
                attributes: .destructive
            ) { [weak self] _ in
                
                guard let self else { return }
                self.analyticsService.report(
                    event: "click",
                    params: ["screen": "Main","item": "delete"]
                )
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

extension TrackerViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        analyticsService.report(
            event: "click",
            params: ["screen": "Main", "item": "search"]
        )
    }
}

extension TrackerViewController: FilterSelectionDelegate {
    func didSelectFilter(_ filter: TrackerFilter) {
        currentFilter = filter
        if filter == .today {
            let today = Date()
            currentDate = today
            datePicker.setDate(today, animated: true)
        }
        filterSectionsForCurrentDate()
        updateFilterButtonAppearance()
    }
    
    private func updateFilterButtonAppearance() {
        let isDefault = currentFilter == .all || currentFilter == .today
        filterButton.setTitleColor(isDefault ? .white : .systemRed, for: .normal)
    }
}
