//
//  ActivityChart.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 04.08.2024.
//

import SwiftUI
import Charts

struct ActivityChart: View {
    var chartData: [ActivityChartModel]
    
    init(chartData: [ActivityChartModel]) {
        self.chartData = chartData
    }
    
    var body: some View {
        chart
    }
    
    var chart: some View {
        Chart(chartData) { data in
            BarMark(x: .value("Hour", data.startDateTime, unit: .hour),
                    yStart: .value("Start", Int(data.startDateTime.formatted(.dateTime.minute(.twoDigits)))!),
                    yEnd: .value("Finish", Int(data.startDateTime.formatted(.dateTime.minute(.twoDigits)))! + Int(data.finishDateTime.timeIntervalSince(data.startDateTime)) / 60)
                    )
            .foregroundStyle(Color(rgbaColor: data.color))
        }
        
        .chartYScale(domain: [0, 60])
        .chartXScale(domain: [Calendar.current.startOfDay(for: chartData[0].startDateTime), Date.endOfDay(for: chartData[0].startDateTime)])
        .chartYAxis {
            AxisMarks(
                format: ActivityChartFormatter(),
                values: [0, 30, 60],
                stroke: StrokeStyle(lineWidth: 0.5)
            )
        }
    }
}

#Preview {
    ActivityChart(chartData: chartModelMock)
}

let chartModelMock = [
    ActivityChartModel(typeID: UUID().uuidString, startDateTime: .now, finishDateTime: .now.advanced(by: 300), color: .randomBackgroundRGBA())
]
