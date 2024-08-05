//
//  ActivityChartHostingController.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 04.08.2024.
//

import Foundation
import SwiftUI

class ActivityChartHostingController: UIHostingController<ActivityChart> {
    init(chartData: [ActivityChartModel]) {
        super.init(rootView: ActivityChart(chartData: chartData))
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
