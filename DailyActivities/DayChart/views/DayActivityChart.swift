//
//  DayActivityChart.swift
//  Day Activities
//
//  Created by Nikolay Kavretsky on 31.07.2023.
//

import SwiftUI
import Charts

struct DayActivityChart: View {
    @ObservedObject private var activityStore: TodayActivityVM
    @ObservedObject private var typeStore: ActivityTypeStore
    
    init(activityStore: TodayActivityVM, typeStore: ActivityTypeStore) {
        self.activityStore = activityStore
        self.typeStore = typeStore
    }
    
    private var usedTypes: [String] {
        return activityStore.chartData.map( { $0.typeID}).uniqued()
    }
    
    private func colorForTypeID(_ typeID: String) -> Color {
        Color(rgbaColor: typeStore.type(withID: typeID)?.backgroundRGBA ?? RGBAColor(red: 0, green: 0, blue: 0, alpha: 1))
    }
    
    var body: some View {
        barChart
            .aspectRatio(2.5, contentMode: .fit)
    }
    
    private var barChart: some View {
        Chart(activityStore.chartData) { chartData in
            BarMark(
                x: .value("Hour", chartData.startTime, unit: .hour),
                y: .value("Duration", chartData.duration)
            )
            .foregroundStyle(by: .value("Duration", chartData.typeID))
            .cornerRadius(3)
        }
        .chartForegroundStyleScale { typeID in
            colorForTypeID(typeID)
        }
        .chartYScale(domain: [0, 60])
        .chartYAxis {
            AxisMarks(
                format: ActivityChartFormatter(),
                values: [0, 30, 60]
            )
        }
        .chartXScale(domain: [Date.startOfDay(), Date.endOfDay(for: .now)])
        .chartXAxis {
            AxisMarks(values: .stride(by: .hour, count: 3)) { value in
                if let date = value.as(Date.self) {
                    let hour = Calendar.current.component(.hour, from: date)
                    switch hour {
                    case 0, 12:
                        AxisValueLabel(format: .dateTime.hour())
                    default:
                        AxisValueLabel(format: .dateTime.hour(.defaultDigits(amPM: .omitted)))
                    }
                    
                    AxisGridLine()
                    AxisTick()
                }
            }
        }
        .chartLegend(position: .bottom, alignment: .leading) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(usedTypes, id: \.self) { typeID in
                        HStack(spacing: 4) {
                            BasicChartSymbolShape.circle
                                .foregroundColor(colorForTypeID(typeID))
                                .frame(width: 8, height: 8)
                            Text(typeStore.type(withID: typeID)?.description ?? "unknown type")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
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

struct DayActivityChart_Previews: PreviewProvider {
    static var previews: some View {
        DayActivityChart(activityStore: TodayActivityVM(activityRepository: ActivityRepositoryMock()), typeStore: ActivityTypeStore(activityTypeRepository: ActivityTypeRepositoryMock()))
            .frame(width: 300, height: 84)
//            .scaledToFit()
            
    }
}
