//
//  ActivityChartHostingController.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 04.08.2024.
//

import Foundation
import SwiftUI

class ActivityChartHostingController: UIHostingController<ActivityChart> {
    init(chartData: [ActivityChartModel], showLegend: Bool = true) {
        super.init(rootView: ActivityChart(chartData: chartData, showLegend: showLegend))
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
