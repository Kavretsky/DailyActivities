//
//  DayActivityChart.swift
//  Day Activities
//
//  Created by Nikolay Kavretsky on 31.07.2023.
//

import SwiftUI
import Charts

struct ChartData: Identifiable {
    let id = UUID()
    let typeID: String
    let startTime: Date
    let duration: Double
    let activityID: String
}

struct DayActivityChart: View {
    @ObservedObject var typeStore: TypeStore
    
    init(activities: [Activity], typeStore: TypeStore) {
        self.activities = activities
        self.typeStore = typeStore
    }
    
    private var activities: [Activity]
    
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
    
    private var usedTypes: [String] {
        print(activities.map( { $0.typeID}).uniqued())
        return activities.map( { $0.typeID}).uniqued()
    }
    
    @State private var chartData: [ChartData] = []
    
    private func colorForTypeID(_ typeID: String) -> Color {
        Color(rgbaColor: typeStore.type(withID: typeID).backgroundRGBA)
    }
    
    var body: some View {
        barChart
            .task {
                chartData = activities.flatMap({activityToChartData($0)})
            }
    }
    
    private var barChart: some View {
        Chart(chartData) { chartData in
            BarMark(
                x: .value("Hour", chartData.startTime, unit: .hour),
                y: .value("Duration", chartData.duration)
            )
            .foregroundStyle(by: .value("Duration", chartData.typeID))
            .cornerRadius(3)
        }
        .chartYScale(domain: [0, 60])
        .chartXScale(domain: [Date.startOfDay(), Date.endOfDay()])
        .chartForegroundStyleScale { typeID in
            colorForTypeID(typeID)
        }
        .chartLegend(position: .bottom, alignment: .leading) {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(usedTypes, id: \.self) { typeID in
                        HStack {
                            BasicChartSymbolShape.circle
                                .foregroundColor(colorForTypeID(typeID))
                                .frame(width: 8, height: 8)
                            Text(typeStore.type(withID: typeID).description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
    }
}

struct DayActivityChart_Previews: PreviewProvider {
    static var previews: some View {
        let sample = [
            Activity(description: "Test", typeID: "C286CACB-51A6-4FD8-87E1-6900C8ECC1A9", startDateTime: .now, finishDateTime: .now.addingTimeInterval(TimeInterval(300))),
            Activity(description: "Test2", typeID: "C286CACB-51A6-4FD8-87E1-6900C8ECC1A9", startDateTime: .now.addingTimeInterval(3600), finishDateTime: .now.addingTimeInterval(8650)),
            Activity(description: "Test3", typeID: "4300197B-201F-42CC-AB52-67186E41F668", startDateTime: .now.addingTimeInterval(8650), finishDateTime: .now.addingTimeInterval(15650))
        ]
        DayActivityChart(activities: sample, typeStore: TypeStore())
            .scaledToFit()
    }
}
