//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Ди Di on 31/05/25.
//

import UIKit


final class ScheduleViewController: UIViewController {
    

    private let scheduleTitle: UILabel = {
        let title = UILabel()
        title.textColor = .ypBlack
        title.font = .sfProDisplayMedium16
        title.text = Constants.Schedule.scheduleTitle
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    private let daysOfWeek = [
        "Понедельник", "Вторник", "Среда",
        "Четверг", "Пятница", "Суббота", "Воскресенье"
    ]
    
    var initialSelectedDays: [String] = []
    private var togglesState: [Bool] = Array(repeating: false, count: 7)
    private var onScheduleSelected: ((String) -> Void)?
    
    private let weekContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypDoubleLightGray
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.tableFooterView = UIView()
        table.separatorStyle = .none
        table.isScrollEnabled = false
        table.backgroundColor = .ypDoubleLightGray
        return table
    }()
    
    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = .sfProDisplayMedium16
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = UIColor.ypBlack
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var onSave: (([String]) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        for (index, dayName) in daysOfWeek.enumerated() {
            togglesState[index] = initialSelectedDays.contains(dayName)
        }
        tableView.register(ChooseDayCell.self, forCellReuseIdentifier: ChooseDayCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(weekContainerView)
        weekContainerView.addSubview(tableView)
        view.addSubview(scheduleTitle)
        view.addSubview(doneButton)
        
        setupConstraints()
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            scheduleTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            scheduleTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            weekContainerView.topAnchor.constraint(equalTo: scheduleTitle.bottomAnchor, constant: 38),
            weekContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            weekContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            weekContainerView.heightAnchor.constraint(equalToConstant: 525),
            
            tableView.topAnchor.constraint(equalTo: weekContainerView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: weekContainerView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: weekContainerView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: weekContainerView.bottomAnchor),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant:  60)
            
        ])
    }
    
    @objc private func didSelectSchedule(_ schedule: String) {
        onScheduleSelected?(schedule)
        dismiss(animated: true)
    }
    
    @objc private func doneButtonTapped() {
        let selectedDays = daysOfWeek.enumerated()
            .compactMap { togglesState[$0.offset] ? $0.element : nil }
        
        onSave?(selectedDays)
        dismiss(animated: true, completion: nil)
    }
}

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        daysOfWeek.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChooseDayCell.reuseIdentifier, for: indexPath) as? ChooseDayCell else {
            return UITableViewCell()
        }
        
        let dayName = daysOfWeek[indexPath.row]
        let isOn = togglesState[indexPath.row]
        cell.configure(dayName: dayName, isOn: isOn)
        let isLast = (indexPath.row == daysOfWeek.count - 1)
        cell.hideSeparator(isLast)
        cell.toggleSwitch.tag = indexPath.row
        cell.toggleSwitch.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
        return cell
    }
    
    @objc private func switchValueChanged(_ sender: UISwitch) {
        let index = sender.tag
        togglesState[index] = sender.isOn
    }
}

extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  75
    }
}
