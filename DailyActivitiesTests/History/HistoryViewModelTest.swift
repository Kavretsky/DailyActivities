//
//  HistoryViewModelTest.swift
//  DailyActivitiesTests
//
//  Created by Nikolay Kavretsky on 01.08.2024.
//

import XCTest
@testable import DailyActivities

@MainActor
final class HistoryViewModelTest: XCTestCase {
    
    var viewModel: HistoryViewModel!
    var mockActivityRepository: ActivityRepositoryMock!
    var chartDataService: ChartDataService!
    var delegate: MockHistoryVMDelegate!
    

    override func setUp() {
        super.setUp()
        mockActivityRepository = ActivityRepositoryMock()
        chartDataService = MockChartDataService()
        viewModel = HistoryViewModel(historyService: mockActivityRepository, chartDataService: chartDataService)
        delegate = MockHistoryVMDelegate()
        viewModel.delegate = delegate
    }

    override func tearDown()  {
        mockActivityRepository = nil
        viewModel = nil
        super.tearDown()
    }

    func testLoadDataSuccess() async {
        try? await viewModel.loadData()

        XCTAssertEqual(viewModel.headers.count, 1)
        XCTAssertEqual(viewModel.headers.first!, Calendar.current.dateComponents([.year], from: .now))
        let key = viewModel.dates.keys.first!
        XCTAssertEqual(viewModel.dates.keys.count, 1)
        XCTAssertEqual(key, Calendar.current.dateComponents([.year], from: .now))
        
        XCTAssertEqual(viewModel.dates[key]?.count, 1)
        XCTAssertEqual(viewModel.dates[key]!.first, .yesterday)
    }
    
    func testLoadDataFailure() async {
        mockActivityRepository.shouldThrowError = true
        
        do {
            try await viewModel.loadData()
            XCTFail("Expected an error to be thrown, but it wasn't.")
        } catch {
            XCTAssertTrue(error is NSError)
        }
    }
    
    func testDidSelectRowAt() async {
        try? await viewModel.loadData()
        
        await viewModel.didSelectRowAt(IndexPath(item: 0, section: 0))
        
        XCTAssertEqual(delegate.date, .yesterday)
        
    }

}
