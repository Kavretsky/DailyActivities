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
                    yEnd: .value("Finish", Int(data.startDateTime.formatted(.dateTime.minute(.twoDigits)))! + Int(data.duration))
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
    let chartModelMock = [
        ActivityChartModel(typeID: UUID().uuidString, startDateTime: .now.addingTimeInterval(-1000), duration: 500, color: .randomBackgroundRGBA(), typeDescription: "Foo", activityID: "31902i49012")
    ]
    return ActivityChart(chartData: chartModelMock)
        .frame(width: 320, height: 240)
}
