//
//  MockHistoryVMDelegate.swift
//  DailyActivitiesTests
//
//  Created by Nikolay Kavretsky on 01.09.2024.
//

import Foundation
@testable import DailyActivities

class MockHistoryVMDelegate: HistoryViewModelDelegate {
    func openDayActivityVC(for date: Date) {
        self.date = date
    }
    var date: Date?
    
}

