//
//  DayActivityChart.swift
//  Day Activities
//
//  Created by Nikolay Kavretsky on 31.07.2023.
//

import SwiftUI
import Charts



struct DayActivityChart: View {
    @ObservedObject private var activityStore: ActivityStore
    @ObservedObject private var typeStore: TypeStore
    
    init(activityStore: ActivityStore, typeStore: TypeStore) {
        self.activityStore = activityStore
        self.typeStore = typeStore
    }
    
    private var usedTypes: [String] {
        return activityStore.chartData.map( { $0.typeID}).uniqued()
    }
    
    private func colorForTypeID(_ typeID: String) -> Color {
        Color(rgbaColor: typeStore.type(withID: typeID).backgroundRGBA)
    }
    
    var body: some View {
        barChart
            .aspectRatio(2.5, contentMode: .fill)
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
        .chartYScale(domain: [0, 60])
        .chartXScale(domain: [Date.startOfDay(), Date.endOfDay()])
        .chartForegroundStyleScale { typeID in
            colorForTypeID(typeID)
        }
        .chartLegend(position: .bottom, alignment: .leading) {
            ScrollView(.horizontal, showsIndicators: false) {
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
        DayActivityChart(activityStore: ActivityStore(), typeStore: TypeStore())
            .scaledToFit()
    }
}
