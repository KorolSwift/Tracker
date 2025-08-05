//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Ди Di on 30/06/25.
//

import UIKit


final class CategoryViewController: UIViewController {
    private let rowHeight: CGFloat = 75
    private var tableViewHeightConstraint: NSLayoutConstraint?
    private let viewModel: TrackerCategoryViewModel
    var initialSelectedCategory: TrackerCategory?
    private var emptyStateView: UIView?
    var onSelectCategory: ((TrackerCategory) -> Void)?
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .clear
        table.layer.cornerRadius = 16
        table.separatorStyle = .none
        table.register(TrackerCategoryCell.self, forCellReuseIdentifier: TrackerCategoryCell.reuseIdentifier)
        table.delegate = self
        table.dataSource = self
        return table
    }()
    
    private let categoryTitle: UILabel = {
        let title = UILabel()
        title.textColor = .ypBlack
        title.font = .sfProDisplayMedium16
        title.text = Constants.Category.categoryTitle
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.CardCreation.addCategoryButtonTitle, for: .normal)
        button.backgroundColor = .ypBlack
        button.titleLabel?.font = .sfProDisplayMedium16
        button.setTitleColor(.ypWhite, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(didTapAddCategory), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let categoryContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init(viewModel: TrackerCategoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        categoryContainerView.backgroundColor = .ypDoubleLightGray
        categoryContainerView.layer.cornerRadius = 16
        categoryContainerView.layer.masksToBounds = true
        
        tableView.backgroundColor = .clear
        tableView.layer.cornerRadius = 0
        
        setupLayout()
        bindViewModel()
        viewModel.fetchCategories()
        updateEmptyState()
    }
    
    private func setupLayout() {
        view.addSubview(categoryTitle)
        view.addSubview(categoryContainerView)
        view.addSubview(addCategoryButton)
        categoryContainerView.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            categoryTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            categoryTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            
            categoryContainerView.topAnchor.constraint(equalTo: categoryTitle.bottomAnchor, constant: 38),
            categoryContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: categoryContainerView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: categoryContainerView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: categoryContainerView.trailingAnchor),
        ])
        
        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
        tableViewHeightConstraint?.isActive = true
        
        categoryContainerView.heightAnchor.constraint(equalTo: tableView.heightAnchor).isActive = true
    }
    
    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.tableView.reloadData()
                self.updateTableHeight()
                self.updateEmptyState()
            }
        }
    }
    
    private func updateTableHeight() {
        let count = CGFloat(viewModel.categories.count)
        let newHeight = count * rowHeight
        tableViewHeightConstraint?.constant = newHeight
        view.layoutIfNeeded()
    }
    
    @objc private func didTapAddCategory() {
        let newCategoryViewController = NewCategoryViewController(viewModel: viewModel)
        newCategoryViewController.onSave = { [weak self] title in
            self?.viewModel.addCategory(title)
            newCategoryViewController.dismiss(animated: true)
        }
        let navigation = UINavigationController(rootViewController: newCategoryViewController)
        present(navigation, animated: true)
    }
    
    private func showError() {
        guard emptyStateView == nil else { return }
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView(image: UIImage(named: "Error"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = NSLocalizedString("empty_category", comment: "Описание при отсуствии категорий")
        label.textColor = .ypBlack
        label.font = .sfProDisplayMedium12
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(imageView)
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
            container.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            container.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            container.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
        ])
        emptyStateView = container
    }
    
    private func removeError() {
        emptyStateView?.removeFromSuperview()
        emptyStateView = nil
    }
    
    private func updateEmptyState() {
        if viewModel.categories.isEmpty {
            showError()
            categoryContainerView.isHidden = true
        } else {
            categoryContainerView.isHidden = false
            removeError()
        }
    }
    
    private func presentEditCategoryScreen(for category: TrackerCategory) {
        let editViewController = EditCategoryViewController(category: category)
        editViewController.onSave = { [weak self] newName in
            guard let self else { return }
            self.viewModel.deleteCategory(category.name)
            do {
                try self.viewModel.addCategory(newName)
            } catch {
                print("Ошибка при добавлении категории: \(error)")
            }
        }
        if presentedViewController == nil {
            present(editViewController, animated: true)
        }
    }
    
    private func showDeleteConfirmation(for category: TrackerCategory) {
        let alert = UIAlertController(
            title: nil,
            message: NSLocalizedString("delete_category_confirmation", comment: ""),
            preferredStyle: .actionSheet
        )
        let deleteAction = UIAlertAction(title: NSLocalizedString("ok_button", comment: ""), style: .destructive) { [weak self] _ in
            self?.viewModel.deleteCategory(category.name)
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel_button", comment: ""), style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = self.view.bounds
            popover.permittedArrowDirections = []
        }
        present(alert, animated: true)
    }
}

extension CategoryViewController: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        guard
            let button = interaction.view as? UIButton,
            let title = button.title(for: .normal),
            let category = viewModel.categories.first(where: { $0.name == title })
        else { return nil }
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil,
            actionProvider: { _ in
                UIMenu(title: "", children: [
                    UIAction(title: NSLocalizedString("edit_button", comment: "")) { [weak self] _ in
                        self?.presentEditCategoryScreen(for: category)
                    },
                    UIAction(title: NSLocalizedString("cancel_button", comment: ""), attributes: .destructive) { [weak self] _ in
                        self?.showDeleteConfirmation(for: category)
                    }
                ])
            }
        )
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, previewForHighlightingMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let button = interaction.view as? UIButton else { return nil }
        
        let parameters = UIPreviewParameters()
        parameters.visiblePath = UIBezierPath(roundedRect: button.bounds, cornerRadius: 16)
        
        let target = UIPreviewTarget(container: button, center: CGPoint(x: button.bounds.minX + 10, y: button.bounds.midY))
        return UITargetedPreview(view: button, parameters: parameters, target: target)
    }
}

extension CategoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TrackerCategoryCell.reuseIdentifier,
            for: indexPath
        ) as? TrackerCategoryCell else {
            print("Не удалось привести ячейку к TrackerCategoryCell")
            return UITableViewCell()
        }
        let sorted = viewModel.categories.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
        let category = sorted[indexPath.row]
        let isSelected = category.name == initialSelectedCategory?.name
        
        let isLast = indexPath.row == sorted.count - 1
        cell.configure(
            with: category.name,
            isSelected: isSelected,
            hideSeparator: isLast
        )
        cell.onEdit = { [weak self] in
            self?.presentEditCategoryScreen(for: category)
        }
        cell.onDelete = { [weak self] in
            self?.showDeleteConfirmation(for: category)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sorted = viewModel.categories.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
        let selected = sorted[indexPath.row]
        onSelectCategory?(selected)
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

