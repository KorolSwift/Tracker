//
//  FilterSelectionViewController.swift
//  Tracker
//
//  Created by Ди Di on 02/08/25.
//

import UIKit


protocol FilterSelectionDelegate: AnyObject {
    func didSelectFilter(_ filter: TrackerFilter)
}

enum TrackerFilter: Int {
    case all, today, completed, uncompleted
}

final class FilterSelectionViewController: UIViewController {
    weak var delegate: FilterSelectionDelegate?
    var selectedFilter: TrackerFilter = .all
    
    private let filtersBySection: [[(String, TrackerFilter)]] = [
        [("Все трекеры",       .all),
         ("Трекеры на сегодня",.today)],
        [("Завершённые",      .completed),
         ("Не завершённые",   .uncompleted)]
    ]
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("filters", comment: "") 
        label.font = .sfProDisplayMedium16
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let containerView: UIView = {
        let cview = UIView()
        cview.backgroundColor = .white
        cview.layer.cornerRadius = 16
        cview.layer.masksToBounds = true
        cview.translatesAutoresizingMaskIntoConstraints = false
        return cview
    }()
    
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.dataSource      = self
        tv.delegate        = self
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tv.tableFooterView = UIView()
        tv.backgroundColor = .ypDoubleLightGray
        tv.separatorColor  = .ypGray
        tv.separatorInset  = .init(top: 0, left: 16, bottom: 0, right: 16)
        tv.rowHeight       = 75
        tv.layer.cornerRadius = 0
        tv.layer.masksToBounds = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(titleLabel)
        view.addSubview(containerView)
        containerView.addSubview(tableView)
        tableView.isScrollEnabled = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            containerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,constant: 38),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: containerView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 4 * 75)
        ])
    }
}

extension FilterSelectionViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        filtersBySection.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filtersBySection[section].count
    }
    
    func tableView(_ tview: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let (title, filter) = filtersBySection[indexPath.section][indexPath.row]
        let cell = tview.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = title
        cell.backgroundColor = .clear
        cell.accessoryView = nil
        
        if indexPath.section == 1 && filter == selectedFilter {
            let checkmark = UIImageView(image: UIImage(named: "selected")) 
            checkmark.contentMode = .scaleAspectFit
            checkmark.frame = CGRect(x: 0, y: 0, width: 14, height: 14)
            cell.accessoryView = checkmark
        }
        
        return cell
    }
    
    func tableView(_ tview: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newFilter = filtersBySection[indexPath.section][indexPath.row].1
        selectedFilter = newFilter
        tview.reloadData()
        delegate?.didSelectFilter(newFilter)
        dismiss(animated: true)
    }
    
    func tableView(_ tview: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 24
    }
}
