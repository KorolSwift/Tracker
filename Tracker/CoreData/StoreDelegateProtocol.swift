//
//  StoreDelegateProtocol.swift
//  Tracker
//
//  Created by Ди Di on 15/06/25.
//


protocol StoreDelegateProtocol: AnyObject {
    func didUpdate()
    func didUpdateRecords(_ records: [TrackerRecord])
    func didUpdateCategories(_ categories: [TrackerCategory])
}
