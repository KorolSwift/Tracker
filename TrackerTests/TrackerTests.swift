//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Ди Di on 12/07/25.
//

import XCTest
import SnapshotTesting
@testable import Tracker


final class TrackerTests: XCTestCase {
    func testViewController() {
        let vc = TrackerViewController()
                assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)), named: "light")
                assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)), named: "dark")
    }
}
