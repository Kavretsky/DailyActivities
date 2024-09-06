//
//  ChartDataServiceTest.swift
//  DailyActivitiesTests
//
//  Created by Nikolay Kavretsky on 06.09.2024.
//

import XCTest
@testable import DailyActivities

final class ChartDataServiceTest: XCTestCase {
    
    var chartDataService: ChartDataService!
    var typeRepository: ActivityTypeRepositoryMock = .init()

    override func setUpWithError() throws {
        chartDataService = ChartDataServiceIml(typeRepository: typeRepository)
    }

    override func tearDownWithError() throws {
        chartDataService = nil
    }

    func testChartDataForSingleActivityWithHourDuration() {
        let type = typeRepository.types.first!
        let activity = Activity(description: "foo", typeID: type.id, startDateTime: .startOfDay(), finishDateTime: .startOfDay().addingTimeInterval(3600))
        let chartData = chartDataService.chartData(for: [activity])
        XCTAssertEqual(chartData.count, 1, "ChartData count must be equal 1")
        let activityChartModel = chartData.first!
        XCTAssertEqual(activityChartModel.startDateTime, activity.startDateTime, "startDateTime must be equal activity statDateTime")
        XCTAssertEqual(activityChartModel.typeID, activity.typeID, "typeID must be equal activity typeID")
        XCTAssertEqual(activityChartModel.activityID, activity.id, "activityID must be equal activity id")
        XCTAssertEqual(activityChartModel.color, type.backgroundRGBA, "color must be equal type color")
        XCTAssertEqual(activityChartModel.duration, 60, "duration must be equal 60")
        
    }
    
    func testChartDataForSingleActivityWithMoreThanHourDuration() {
        let type = typeRepository.types.first!
        let activity = Activity(description: "foo", typeID: type.id, startDateTime: .startOfDay(), finishDateTime: .startOfDay().addingTimeInterval(4200))
        let chartData = chartDataService.chartData(for: [activity])
        XCTAssertEqual(chartData.count, 2, "ChartData count must be equal 2")
        let firstChartData = chartData.first!
        XCTAssertEqual(firstChartData.startDateTime, activity.startDateTime, "startDateTime must be equal activity statDateTime")
        XCTAssertEqual(firstChartData.typeID, activity.typeID, "typeID must be equal activity typeID")
        XCTAssertEqual(firstChartData.activityID, activity.id, "activityID must be equal activity id")
        XCTAssertEqual(firstChartData.color, type.backgroundRGBA, "color must be equal type color")
        XCTAssertEqual(firstChartData.duration, 60, "duration must be equal 60")
        
        let secondChartData = chartData[1]
        XCTAssertEqual(secondChartData.startDateTime, activity.startDateTime.addingTimeInterval(3600), "startDateTime must be equal 1 hour after activity statDateTime")
        XCTAssertEqual(secondChartData.typeID, activity.typeID, "typeID must be equal activity typeID")
        XCTAssertEqual(secondChartData.activityID, activity.id, "activityID must be equal activity id")
        XCTAssertEqual(secondChartData.color, type.backgroundRGBA, "color must be equal type color")
        XCTAssertEqual(secondChartData.duration, 10, "duration must be equal 10")
    }
    
    func testChartDataForEmptyActivity() {
        let chartData = chartDataService.chartData(for: [])
        XCTAssert(chartData.isEmpty, "chartData must be empty")
    }
    
    func testChartDataForContinuingActivity() {
        let type = typeRepository.types.first!
        let activity = Activity(description: "foo", typeID: type.id, startDateTime: .startOfDay())
        let hours: Int = Int(-Date.startOfDay().timeIntervalSinceNow / 3600)
        let chartData = chartDataService.chartData(for: [activity])
        XCTAssertEqual(chartData.count, hours + 1, "chartData count must be equal hours + 1")
    }
    
    func testChartDataForTwoActivities() {
        let type1 = typeRepository.types.first!
        let type2 = typeRepository.types.last!
        let activity1 = Activity(description: "foo", typeID: type1.id, startDateTime: .startOfDay(), finishDateTime: .startOfDay().addingTimeInterval(3600))
        let activity2 = Activity(description: "bar", typeID: type2.id, startDateTime: .startOfDay().addingTimeInterval(3600), finishDateTime: .startOfDay().addingTimeInterval(7200))
        let chartData = chartDataService.chartData(for: [activity1, activity2])
        XCTAssertEqual(chartData.count, 2, "ChartData count must be equal 2")
        let firstChartData = chartData.first!
        XCTAssertEqual(firstChartData.startDateTime, activity1.startDateTime, "startDateTime must be equal activity statDateTime")
        XCTAssertEqual(firstChartData.typeID, activity1.typeID, "typeID must be equal activity typeID")
        XCTAssertEqual(firstChartData.activityID, activity1.id, "activityID must be equal activity id")
        XCTAssertEqual(firstChartData.color, type1.backgroundRGBA, "color must be equal type color")
        XCTAssertEqual(firstChartData.duration, 60, "duration must be equal 60")
        
        let secondChartData = chartData[1]
        XCTAssertEqual(secondChartData.startDateTime, activity2.startDateTime, "startDateTime must be equal 1 hour after activity statDateTime")
        XCTAssertEqual(secondChartData.typeID, activity2.typeID, "typeID must be equal activity typeID")
        XCTAssertEqual(secondChartData.activityID, activity2.id, "activityID must be equal activity id")
        XCTAssertEqual(secondChartData.color, type2.backgroundRGBA, "color must be equal type color")
        XCTAssertEqual(secondChartData.duration, 60, "duration must be equal 10")
    }
}
