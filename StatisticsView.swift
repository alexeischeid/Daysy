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
    @State var completedIcons = getAllCompleted()
    @State var removedIcons = getAllRemoved()
    @State var completedratio = getCompletedRatio()
    @State var removedratio = getRemovedRatio()
    @State var showSheet = false
    @State var currSheetName = ""
    @State var animate = false
    
    @State var sheetCompletedIcons = 0
    @State var sheetRemovedIcons = 0
    @State var sheetCompletedRatio = 0.00
    
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
        ScrollView {
            
            Text("\(Image(systemName: "chart.bar.xaxis")) Statistics")
                .lineLimit(1)
                .minimumScaleFactor(0.01)
                .font(.system(size: 45, weight: .bold, design: .rounded))
                .padding()
            
            if #available(iOS 16.0, *) { //make the x axis label reflect the period of dates shown
                Text("\(Image(systemName: "chart.line.uptrend.xyaxis")) Your Daysy Usage")
                    .lineLimit(1)
                    .minimumScaleFactor(0.01)
                    .font(.system(size: 35, weight: .bold, design: .rounded))
                    .foregroundColor(Color(.systemGray))
                    .padding()
                
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
            Spacer()
            Spacer()
            Text("\(Image(systemName: "star.square.on.square")) Most Used Icons")
                .lineLimit(1)
                .minimumScaleFactor(0.01)
                .font(.system(size: 35, weight: .bold, design: .rounded))
                .foregroundColor(Color(.systemGray))
                .padding()
            ScrollView(.horizontal) {
                HStack {
                    ForEach(0..<mostIcons.prefix(10).count, id: \.self) { item in
                        if String(mostIcons[item].prefix(7)) != "action:" {
                            VStack {
                                if mostIcons[item].contains("customIconObject:") {
                                    //check if default icon or custom icon and handle
                                    getCustomIcon(mostIcons[item])
                                        .scaledToFit()
                                        .clipShape(RoundedRectangle(cornerRadius: 30))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 30)
                                                .stroke(.black, lineWidth: 10)
                                        )
                                        .padding()
                                } else {
                                    loadImage(named: mostIcons[item])
                                        .resizable()
                                        .scaledToFit()
                                        .clipShape(RoundedRectangle(cornerRadius: 30))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 30)
                                                .stroke(.black, lineWidth: 10)
                                        )
                                        .padding()
                                }
                                Text("Used \(howmany(in: usage, for:mostIcons[item])) times")
                                    .font(.title3)
                                    .foregroundColor(Color(.systemGray))
                            }
                        }
                    }
                }
            }
            
            Spacer()
            Divider()
                .padding()
                .padding()
                .padding()
            
            Text("\(Image(systemName: "checkmark.circle.badge.xmark")) Completed/Removed (Overall)")
                .lineLimit(1)
                .minimumScaleFactor(0.01)
                .font(.system(size: 35, weight: .bold, design: .rounded))
                .foregroundColor(Color(.systemGray))
                .padding()
            if getAllRemoved().count == 0 && getAllCompleted().count == 0 {
                HStack(alignment: .bottom) {
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .frame(width: 200, height: 100)
                                .foregroundColor(.green)
                            Image(systemName: "checkmark")
                                .font(.system(size: 50, weight: .heavy, design: .rounded))
                                .foregroundColor(Color(.systemBackground))
                                .scaledToFit()
                        }
                        .padding()
                        .padding(.top, 300)
                        Text("Completed: \(completedIcons.count)")
                            .minimumScaleFactor(0.01)
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .padding()
                            .multilineTextAlignment(.center)
                    }
                    
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .frame(width: 200, height: 100)
                                .foregroundColor(.red)
                            Image(systemName: "trash")
                                .minimumScaleFactor(0.1)
                                .font(.system(size: 50, weight: .heavy, design: .rounded))
                                .foregroundColor(Color(.systemBackground))
                                .scaledToFit()
                        }
                        .padding()
                        .padding(.top, 300)
                        Text("Removed: \(removedIcons.count)")
                            .minimumScaleFactor(0.01)
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .padding()
                            .multilineTextAlignment(.center)
                    }
                }
                .padding()
            } else {
                HStack(alignment: .bottom) {
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .frame(width: 200, height: (500 * (getCompletedRatio()) + 50))
                                .foregroundColor(.green)
                            Image(systemName: "checkmark")
                                .font(.system(size: 25, weight: .heavy, design: .rounded))
                                .foregroundColor(Color(.systemBackground))
                                .scaledToFit()
                        }
                        .padding()
                        Text("Completed: \(completedIcons.count)")
                            .minimumScaleFactor(0.01)
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .padding()
                            .multilineTextAlignment(.center)
                    }
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .frame(width: 200, height: (500 * (getRemovedRatio()) + 50))
                                .foregroundColor(.red)
                            Image(systemName: "trash")
                                .minimumScaleFactor(0.1)
                                .font(.system(size: 25, weight: .heavy, design: .rounded))
                                .foregroundColor(Color(.systemBackground))
                                .scaledToFit()
                        }
                        .padding()
                        Text("Removed: \(removedIcons.count)")
                            .minimumScaleFactor(0.01)
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .padding()
                            .multilineTextAlignment(.center)
                    }
                }
                .padding()
            }
            Text("\(Image(systemName: "checklist")) Completed/Removed Icons (Per Sheet)")
                .lineLimit(1)
                .minimumScaleFactor(0.01)
                .font(.system(size: 35, weight: .bold, design: .rounded))
                .foregroundColor(Color(.systemGray))
                .padding()
            ScrollView(.horizontal) {
                HStack {
                    ForEach(0..<sheetArray.count, id: \.self) { item in
                        if sheetArray[item].label != "Debug, ignore this page" {
                            if getCurrCompletedRatio(allCompleted: CGFloat(getThisCompletedIcons(item: sheetArray[item])), allRemoved: CGFloat(getThisremovedIcons(item: sheetArray[item]))) == -1 {
                                VStack {
                                    Spacer()
                                    HStack(alignment: .bottom) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .frame(width: 100, height: 50)
                                                .foregroundColor(.green)
                                            Text("0")
                                                .font(.system(size: 35, weight: .heavy, design: .rounded))
                                                .foregroundColor(Color(.systemBackground))
                                                .scaledToFit()
                                        }
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .frame(width: 100, height: 50)
                                                .foregroundColor(.red)
                                            Text("0")
                                                .minimumScaleFactor(0.1)
                                                .font(.system(size: 35, weight: .heavy, design: .rounded))
                                                .foregroundColor(Color(.systemBackground))
                                                .scaledToFit()
                                        }
                                    }
                                    .padding()
                                    Text("\(sheetArray[item].label)")
                                        .lineLimit(1)
                                        .font(.system(size: 40, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)
                                }
                                .padding()
                                //}
                            } else {
                                VStack {
                                    Spacer()
                                    HStack(alignment: .bottom) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .frame(width: 100, height: (200 * (getCurrCompletedRatio(allCompleted: CGFloat(getThisCompletedIcons(item: sheetArray[item])), allRemoved: CGFloat(getThisremovedIcons(item: sheetArray[item])))) + 50))
                                                .foregroundColor(.green)
                                            Text("\(sheetArray[item].completedIcons.count)")
                                                .font(.system(size: 35, weight: .heavy, design: .rounded))
                                                .foregroundColor(Color(.systemBackground))
                                                .scaledToFit()
                                        }
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .frame(width: 100, height: (200 * (1 - getCurrCompletedRatio(allCompleted: CGFloat(getThisCompletedIcons(item: sheetArray[item])), allRemoved: CGFloat(getThisremovedIcons(item: sheetArray[item])))) + 50))
                                                .foregroundColor(.red)
                                            Text("\(sheetArray[item].removedIcons.count)")
                                                .minimumScaleFactor(0.1)
                                                .font(.system(size: 35, weight: .heavy, design: .rounded))
                                                .foregroundColor(Color(.systemBackground))
                                                .scaledToFit()
                                        }
                                    }
                                    .padding()
                                    Text("\(sheetArray[item].label)")
                                        .lineLimit(1)
                                        .font(.system(size: 40, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)
                                }
                                .padding()
                            }
                        }
                    }
                    .frame(width: 250, height: 400)
                    .background(Color(.systemGray5))
                    .cornerRadius(30)
                }
            }
        }
        .navigationBarHidden(true)
        .animation(.spring)
        Button(action: {
            self.presentation.wrappedValue.dismiss()
        }) {
            Text("\(Image(systemName: "arrow.backward")) Back")
                .lineLimit(1)
                .minimumScaleFactor(0.1)
                .font(.system(size: horizontalSizeClass == .compact ? 10 : 25, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .padding()
                .padding()
                .background(Color(.systemGray5))
                .cornerRadius(30)
        }
        .padding()
        .navigationBarHidden(true)
    }
}

#Preview {
    StatisticsView()
}
