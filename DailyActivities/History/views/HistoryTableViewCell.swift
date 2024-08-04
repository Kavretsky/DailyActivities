//
//  HistoryTableViewCell.swift
//  DailyActivities
//
//  Created by Nikolay Kavretsky on 03.08.2024.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 17)
        label.numberOfLines = 1
        return label
    }()
    
    private var chartViewHC: ActivityChartHostingController?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell(date: Date, chartData: [ActivityChartModel]) {
        dateLabel.text = date.formatted(.dateTime.month(.wide).day())
        if let chartViewHC {
            chartViewHC.rootView = ActivityChart(chartData: chartData)
        } else {
            chartViewHC = ActivityChartHostingController(chartData: chartData)
            addChartToView(chartViewHC!.view)
        }
        
    }
    
    private func addChartToView(_ chart: UIView) {
        contentView.addSubview(chart)
        chart.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chart.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            chart.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            chart.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10),
            contentView.bottomAnchor.constraint(equalTo: chart.bottomAnchor, constant: 10)
        ])
    }

}
