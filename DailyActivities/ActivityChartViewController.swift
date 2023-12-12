//
//  ActivityChartViewController.swift
//  DailyActivities
//
//  Created by Anastasia Yunak on 12.12.2023.
//

import UIKit
import SwiftUI

class ActivityChartViewController: UIViewController {

//    private let chartViewHostingController: UIHostingController<DayActivityChart>
    private var activities = [Activity]()
    
    var chartData: [ChartData] = []
    
    init(activities: [Activity]) {
        self.activities = activities
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    private func activityToChartData(_ activity: Activity) -> [ChartData] {
        var result = [ChartData]()
        var chartDataStartTime = activity.startDateTime
        var activityStartMinute = Int(activity.startDateTime.formatted(.dateTime.minute()))!
        var activityDuration = DateInterval(start: activity.startDateTime, end: activity.finishDateTime ?? .now.advanced(by: 60)).duration / 60
        
        repeat {
            let chartDataDuration = min(60 - Double(activityStartMinute), activityDuration)
            let chartData = ChartData(typeID: activity.typeID, startTime: chartDataStartTime, duration: chartDataDuration, activityID: activity.id)
            result.append(chartData)
            activityDuration -= chartDataDuration
            chartDataStartTime = chartDataStartTime.addingTimeInterval(TimeInterval(chartDataDuration * 60))
            activityStartMinute = 0
        } while activityDuration > 0
        
        return result
    }

}
