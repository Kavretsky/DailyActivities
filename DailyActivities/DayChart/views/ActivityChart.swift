//
//  ActivityChart.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 04.08.2024.
//

import SwiftUI
import Charts

struct ActivityChart: View {
    private let chartData: [ActivityChartModel]
    private var chartDataWithUniqueTypes: [ActivityChartModel]
    private let showLegend: Bool
    
    init(chartData: [ActivityChartModel], showLegend: Bool = true) {
        self.chartData = chartData
        var result = [ActivityChartModel]()
        var usedTypes = Set<String>()
        for data in chartData where !usedTypes.contains(data.typeID) {
            result.append(data)
            usedTypes.insert(data.typeID)
        }
        self.showLegend = showLegend
        chartDataWithUniqueTypes = result
    }
    
    var body: some View {
        if showLegend {
            chart
        } else {
            chart
                .chartLegend(.hidden)
        }
    }
    
    var chart: some View {
        Chart(chartData) { data in
            BarMark(x: .value("Hour", data.startDateTime, unit: .hour),
                    yStart: .value("Start", Int(data.startDateTime.formatted(.dateTime.minute(.twoDigits)))!),
                    yEnd: .value("Finish", Int(data.startDateTime.formatted(.dateTime.minute(.twoDigits)))! + Int(data.duration))
                    )
            .foregroundStyle(by: .value("color", data.color))
        }
        .chartForegroundStyleScale { plottableColor in
            Color(rgbaColor: RGBAColor(primitivePlottable: plottableColor) ?? .init(red: 1, green: 1, blue: 1, alpha: 1))
        }
        .chartYScale(domain: [0, 60])
        .chartXScale(domain: [Calendar.current.startOfDay(for: chartData.first?.startDateTime ?? .now), Date.endOfDay(for: chartData.first?.startDateTime ?? .now)])
        .chartYAxis {
            AxisMarks(
                format: ActivityChartFormatter(),
                values: [0, 30, 60],
                stroke: StrokeStyle(lineWidth: 0.5)
            )
        }
        .chartLegend(position: .bottom, alignment: .leading, spacing: 10) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(chartDataWithUniqueTypes) { data in
                        HStack(spacing: 4) {
                            BasicChartSymbolShape.circle
                                .foregroundColor(Color(rgbaColor: data.color))
                                .frame(width: 8, height: 8)
                            Text(data.typeDescription)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        } 
    }
    
    struct ActivityChartFormatter: FormatStyle {
        func format(_ value: Int) -> String {
            guard value > 0 else { return value.description }
            return "\(value)m"
        }
    }
}

#Preview {
    let chartModelMock = [
        ActivityChartModel(typeID: UUID().uuidString, startDateTime: .now.addingTimeInterval(-1000), duration: 5, color: .randomBackgroundRGBA(), typeDescription: "Foo", activityID: "31902i49012")
    ]
    return ActivityChart(chartData: chartModelMock)
        .frame(width: 320, height: 240)
}
