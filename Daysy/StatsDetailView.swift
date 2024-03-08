//
//  StatsDetailView.swift
//  Daysy
//
//  Created by Alexander Eischeid on 11/2/23.
//

import SwiftUI

struct StatsDetailView: View {
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @Binding var currSheetName: String
    @Binding var sheetCompletedIcons: Int
    @Binding var sheetRemovedIcons: Int
    @Binding var sheetCompletedRatio: Double
    var body: some View {
        VStack {
            if currSheetName.isEmpty {
                Text("Statistics")
                    .lineLimit(1)
                    .minimumScaleFactor(0.01)
                    .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                    .padding()
            } else {
                Text("Statistics for \(currSheetName)")
                    .lineLimit(1)
                    .minimumScaleFactor(0.01)
                    .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                    .padding()
            }
            Spacer()
            if sheetCompletedIcons == 0 && sheetRemovedIcons == 0 {
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
                        Text("Completed: \(sheetCompletedIcons)")
                            .font(.system(size: 30, design: .rounded))
                            .fontWeight(.bold)
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
                        Text("Removed: \(sheetRemovedIcons)")
                            .font(.system(size: 30, design: .rounded))
                            .fontWeight(.bold)
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
                                .frame(width: 200, height: (500 * (sheetCompletedRatio) + 50))
                                .foregroundColor(.green)
                            Image(systemName: "checkmark")
                                .font(.system(size: 25, weight: .heavy, design: .rounded))
                                .foregroundColor(Color(.systemBackground))
                                .scaledToFit()
                        }
                        .padding()
                        Text("Completed: \(sheetCompletedIcons)")
                            .font(.system(size: 30, design: .rounded))
                            .fontWeight(.bold)
                            .padding()
                            .multilineTextAlignment(.center)
                    }
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .frame(width: 200, height: (500 * (1 - sheetCompletedRatio) + 50))
                                .foregroundColor(.red)
                            Image(systemName: "trash")
                                .minimumScaleFactor(0.1)
                                .font(.system(size: 25, weight: .heavy, design: .rounded))
                                .foregroundColor(Color(.systemBackground))
                                .scaledToFit()
                        }
                        .padding()
                        Text("Removed: \(sheetRemovedIcons)")
                            .font(.system(size: 30, design: .rounded))
                            .fontWeight(.bold)
                            .padding()
                            .multilineTextAlignment(.center)
                    }
                }
                .padding()
            }
        }
    }
}
/*
#Preview {
    StatsDetailView(currSheetName: "", sheetCompletedIcons: 0, sheetRemovedIcons: 0, sheetCompletedRatio: 0.00)
}
*/
