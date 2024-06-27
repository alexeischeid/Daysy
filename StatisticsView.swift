//
//  StatisticsView.swift
//  Daysy
//
//  Created by Alexander Eischeid on 10/31/23.
//

import SwiftUI
import Charts

struct StatisticsView: View {
    
    @Environment(\.presentationMode) var presentation
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State var sheetArray = loadSheetArray()
    @State var removedIcons = getAllRemoved()
    @State var showSheet = false
    @State var currSheetName = ""
    @State var animate = false
    
    @State private var selectedOption = 2
    let options = ["Lifetime", "Month", "Week"]
    let dates: [Date] = [
        // Lifetime, replace with your desired date
        Date(timeIntervalSince1970: 0),
        
        // One month ago
        Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date(),
        
        // One week ago
        Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
    ]
    
    let usage = getUsage()
    let mostIcons = mostUsedIcons()
    
    
    var body: some View {
        ZStack {
            ScrollView {
                
                Text("\(Image(systemName: "chart.bar.xaxis")) Statistics")
                    .lineLimit(1)
                    .minimumScaleFactor(0.01)
                    .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                    .padding()
                
                if #available(iOS 16.0, *) { //make the x axis label reflect the period of dates shown
                    Text("\(Image(systemName: "chart.line.uptrend.xyaxis")) Your Daysy Usage")
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        .font(.system(size: horizontalSizeClass == .compact ? 20 : 35, weight: .bold, design: .rounded))
                        .foregroundStyle(.gray)
                        .padding()
                    
                    VStack {
                        Picker("Select Option", selection: $selectedOption) {
                            ForEach(0..<3) { index in
                                Text(options[index]).tag(index)
                                //find a way to make this animate changing the chart
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
                        
                        Chart(usage) {
                            if $0.date >= dates[selectedOption] {
                                BarMark( //wierd issues with areamark at the moment, maybe just keep it at barmark and remove this section
                                    x: .value("Date", formatDateToString($0.date)),
                                    y: .value("Usage", $0.data.count)
                                )
                                .cornerRadius(20)
                            }
                        }
                        .chartYAxis {
                            AxisMarks(values: .automatic(desiredCount: 0))
                        }
                        .foregroundStyle(.purple)
                        .frame(height: 400)
                        .padding()
                    }
                }
                Spacer()
                Spacer()
                if mostIcons.filter({ $0.starts(with: "action:") }).count != mostIcons.count {
                    Text("\(Image(systemName: "star.square.on.square")) Most Used Icons")
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        .font(.system(size: horizontalSizeClass == .compact ? 20 : 35, weight: .bold, design: .rounded))
                        .foregroundStyle(.gray)
                        .padding()
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(0..<mostIcons.prefix(10).count, id: \.self) { item in
                                if String(mostIcons[item].prefix(7)) != "action:" {
                                    VStack {
                                        if UIImage(named: mostIcons[item]) == nil { //TODO: check if the only item(s) in the list are custom icons and handle, currently a bug where it won't display
                                            //check if default icon or custom icon and handle
                                            if horizontalSizeClass == .compact {
                                                getCustomIcon(mostIcons[item])
                                                    .frame(width:min(250, 500), height: min(250, 500))
                                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 15)
                                                            .stroke(.black, lineWidth: 5)
                                                    )
                                                    .padding()
                                            } else {
                                                getCustomIcon(mostIcons[item])
                                                    .frame(width:min(350, 1000), height: min(350, 1000))
                                                    .clipShape(RoundedRectangle(cornerRadius: 30))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 30)
                                                            .stroke(.black, lineWidth: 10)
                                                    )
                                                    .padding()
                                            }
                                        } else {
                                            Image(mostIcons[item])
                                                .resizable()
                                                .frame(width: horizontalSizeClass == .compact ? min(250, 500) : min(350, 1000), height: horizontalSizeClass == .compact ? min(250, 500) : min(350, 1000))
                                                .clipShape(RoundedRectangle(cornerRadius: horizontalSizeClass == .compact ? 15 : 30))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: horizontalSizeClass == .compact ? 15 : 30)
                                                        .stroke(.black, lineWidth: horizontalSizeClass == .compact ? 5 : 10)
                                                )
                                                .padding()
                                        }
                                        Text("Used \(howmany(in: usage, for:mostIcons[item])) times")
                                            .font(.title3)
                                            .foregroundStyle(.gray)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
            .navigationBarHidden(true)
            .animation(.spring)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        self.presentation.wrappedValue.dismiss()
                    }) {
                        Text("\(Image(systemName: "arrow.backward")) Back")
                            .lineLimit(1)
                            .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                            .padding(horizontalSizeClass == .compact ? 20 : 30)
                            .background(Color(.systemGray5))
                            .cornerRadius(horizontalSizeClass == .compact ? 15 : 25)
                    }
                    .padding()
                    .navigationBarHidden(true)
                    Spacer()
                }
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color(.systemBackground), Color(.systemBackground), Color.clear]), startPoint: .bottom, endPoint: .top)
                        .ignoresSafeArea()
                )
            }
        }
    }
}

#Preview {
    StatisticsView()
}
