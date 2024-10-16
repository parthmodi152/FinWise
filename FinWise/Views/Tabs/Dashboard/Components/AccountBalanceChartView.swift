//
//  AccountBalanceChartView.swift
//  FinWise
//
//  Created by Parth Modi on 2024-10-10.
//

import SwiftUI
import SwiftData
import Charts

struct AccountBalanceChartView: View {
    let accountId: String
    let frequency: Frequency
    
    @Query private var transactions: [Transaction]
    @State private var chartSelection: Date?
    
    private var areaBackground: Gradient {
        return Gradient(colors: [Color("Color2"), Color("Color2").opacity(0.4), .clear])
    }
    
    enum Frequency {
        case monthly, yearly
    }
    
    init(accountId: String, frequency: Frequency) {
        self.accountId = accountId
        self.frequency = frequency
        let filterPredicate = #Predicate { (transaction: Transaction) in
            transaction.account?.id == accountId
        }
        _transactions = Query(filter: filterPredicate, sort: \.date, order: .forward)
    }
    
    var body: some View {
        VStack {
            if transactions.isEmpty {
                Text("No transactions available for this account.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                Chart(transactions) { transaction in
                    LineMark(
                        x: .value(frequency == .yearly ? "Year" : "Month", transaction.date ?? Date(), unit: getUnit()),
                        y: .value("Amount", transaction.amount ?? 0.0)
                    )
                    .symbol(.circle)
                    .foregroundStyle(Color("Color3"))
                    .interpolationMethod(.catmullRom)

                    // Updated AreaMark with yStart as the minimum domain value
                    AreaMark(
                        x: .value(frequency == .yearly ? "Year" : "Month", transaction.date ?? Date(), unit: getUnit()),
                        yStart: .value("Start", calculateYDomain().lowerBound), // Start at min domain value
                        yEnd: .value("Amount", transaction.amount ?? 0.0)
                    )
                    .foregroundStyle(areaBackground)
                    .interpolationMethod(.catmullRom)
                    
                    if let chartSelection {
                        RuleMark(x: .value(frequency == .yearly ? "Year" : "Month", chartSelection, unit: getUnit()))
                            .foregroundStyle(.gray.opacity(0.5))
                            .annotation(position: .top) {
                                Text("$\(getBalance(for: chartSelection), specifier: "%.2f")")
                                    .padding(6)
                                    .background {
                                        RoundedRectangle(cornerRadius: 4)
                                            .foregroundStyle(Color("Color5").opacity(0.2))
                                    }
                            }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading, values: .automatic(desiredCount: 5)) { value in
                        AxisValueLabel()
                        AxisTick()
                        AxisGridLine()
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: getStride())) { _ in
                        AxisValueLabel(format: .dateTime.month(.abbreviated).year(.twoDigits), centered: true)
                    }
                }
                .chartYScale(domain: calculateYDomain()) // Use calculated Y-domain
                .frame(height: 300)
                .padding()
                .chartXSelection(value: $chartSelection)
            }
        }
    }

    // Determine the date unit for the chart axis
    private func getUnit() -> Calendar.Component {
        return frequency == .yearly ? .year : .month
    }
    
    // Determine the axis stride for the date intervals
    private func getStride() -> Calendar.Component {
        return frequency == .yearly ? .year : .month
    }
    
    // Calculate the Y-axis domain dynamically based on transaction amounts
    private func calculateYDomain() -> ClosedRange<Double> {
        let minAmount = transactions.map { $0.amount ?? 0.0 }.min() ?? 0.0
        let maxAmount = transactions.map { $0.amount ?? 0.0 }.max() ?? 100.0
        return (minAmount - 10)...(maxAmount + 10) // Add buffer around min/max
    }
    
    // Get the balance for the selected date in the chart
    private func getBalance(for date: Date) -> Double {
        let calendar = Calendar.current
        let selectedTransactions = transactions.filter {
            calendar.isDate($0.date ?? Date(), equalTo: date, toGranularity: frequency == .yearly ? .year : .month)
        }
        return selectedTransactions.reduce(0) { $0 + ($1.amount ?? 0.0) }
    }
}

#Preview {
    let schema = Schema([
        Transaction.self,
        Account.self,
        Category.self
    ])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: config)
    
    let sampleCashAccount = Account(name: "Cash", balance: 1000.0, type: .cash, currencyCode: Locale.current.currency?.identifier ?? "USD")
    let sampleCreditAccount = Account(name: "Credit Card", balance: 500.0, type: .credit, currencyCode: Locale.current.currency?.identifier ?? "USD")
    let sampleTransaction1 = Transaction(id: "1", name: "Rent", category: nil, date: Date(), amount: 1020.60, currencyCode: "USD", account: sampleCashAccount)
    let sampleTransaction2 = Transaction(id: "2", name: "Groceries", category: nil, date: Date().addingTimeInterval(-60*60*24*30), amount: 600.00, currencyCode: "CAD", account: sampleCashAccount)
    
    container.mainContext.insert(sampleCashAccount)
    container.mainContext.insert(sampleCreditAccount)
    container.mainContext.insert(sampleTransaction1)
    container.mainContext.insert(sampleTransaction2)
    
    return AccountBalanceChartView(accountId: sampleCashAccount.id ?? "", frequency: .monthly)
        .modelContainer(container)
}
