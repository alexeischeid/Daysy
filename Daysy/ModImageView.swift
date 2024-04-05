//
//  ModImageView.swift
//  Daysy
//
//  Created by Alexander Eischeid on 11/2/23.
//

import SwiftUI

struct ModImageView: View {
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @Binding var currSheet: SheetObject
    @Binding var modListIndex: Int
    @Binding var modSlotIndex: Int
    @State var hasDetails = false
    
    var body: some View {
        
        if modListIndex >= currSheet.currGrid.count {
            loadSystemImage(named: "text.below.photo")
                .resizable()
                .scaledToFit()
                .padding()
        } else {
            if currSheet.currGrid[modListIndex].currIcons[modSlotIndex].currIcon.contains("customIconObject:") {
                if horizontalSizeClass == .compact {
                    getCustomIcon(currSheet.currGrid[modListIndex].currIcons[modSlotIndex].currIcon)
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: hasDetails ? 30 : 15))
                        .overlay(
                            RoundedRectangle(cornerRadius: hasDetails ? 30 : 15)
                                .stroke(.black, lineWidth: hasDetails ? 10 : 6)
                        )
                        .padding()
                } else {
                    getCustomIconLarge(currSheet.currGrid[modListIndex].currIcons[modSlotIndex].currIcon)
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: hasDetails ? 30 : 15))
                        .overlay(
                            RoundedRectangle(cornerRadius: hasDetails ? 30 : 15)
                                .stroke(.black, lineWidth: hasDetails ? 20 : 10)
                        )
                        .padding()
                }
            } else {
                loadImage(named: currSheet.currGrid[modListIndex].currIcons[modSlotIndex].currIcon)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: hasDetails ? 30 : 15))
                    .overlay(
                        RoundedRectangle(cornerRadius: hasDetails ? 30 : 15)
                            .stroke(.black, lineWidth: hasDetails ? (horizontalSizeClass == .compact ? 10 : 20) : (horizontalSizeClass == .compact ? 6 : 10))
                    )
                    .padding()
            }
        }
    }
}

/*
#Preview {
    ModImageView()
}
*/
