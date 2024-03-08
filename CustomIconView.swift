//
//  CustomIconView.swift
//  Daysy
//
//  Created by Alexander Eischeid on 11/16/23.
//

import SwiftUI

struct CustomIconView: View, Equatable {
    let selectedCustomImage: Image
    let currCustomIconText: String
    let noImage: Bool
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(Color.black, lineWidth: 3)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
            )
            .aspectRatio(1, contentMode: .fill)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                VStack {
                    if !currCustomIconText.isEmpty && !noImage {
                        Spacer()
                    }
                    if !noImage /* check to see if the image is not plus.viewfinder */ {
                        selectedCustomImage
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: currCustomIconText.isEmpty ? 0 : 10))
                    }
                    if !currCustomIconText.isEmpty {
                        if !noImage {
                            Spacer()
                        }
                        Text(currCustomIconText)
                            .lineLimit(1)
                            .multilineTextAlignment(.center)
                            .font(.system(size: noImage ? 200 : 45, weight: .medium, design: .rounded))
                            .minimumScaleFactor(0.1)
                            .foregroundColor(.black)
                            .padding(.leading)
                            .padding(.trailing)
                            .padding(.bottom, 3)
                    }
                }
            )
            .scaledToFit()
            .ignoresSafeArea()
    }
    
    static func == (lhs: CustomIconView, rhs: CustomIconView) -> Bool {
        // Compare only the relevant properties for equality
        return lhs.selectedCustomImage == rhs.selectedCustomImage && lhs.currCustomIconText == rhs.currCustomIconText
    }
    
}

struct CustomIconViewSmall: View, Equatable {
    let selectedCustomImage: Image
    let currCustomIconText: String
    let noImage: Bool
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(Color.black, lineWidth: 3)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
            )
            .aspectRatio(1, contentMode: .fill)
            .overlay(
                VStack {
                    if !currCustomIconText.isEmpty && !noImage {
                        Spacer()
                    }
                    if !noImage {
                        selectedCustomImage
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: currCustomIconText.isEmpty ? 0 : 7))
                    }
                    if !currCustomIconText.isEmpty {
                        if !noImage {
                            Spacer()
                        }
                        Text(currCustomIconText)
                            .lineLimit(1)
                            .multilineTextAlignment(.center)
                            .font(.system(size: noImage ? 100 : 20, weight: .medium, design: .rounded))
                            .minimumScaleFactor(0.1)
                            .foregroundColor(.black)
                            .padding(.leading)
                            .padding(.trailing)
                            .padding(.bottom, 3)
                    }
                }
            )
            .scaledToFit()
            .ignoresSafeArea()
    }
    
    static func == (lhs: CustomIconViewSmall, rhs: CustomIconViewSmall) -> Bool {
        // Compare only the relevant properties for equality
        return lhs.selectedCustomImage == rhs.selectedCustomImage && lhs.currCustomIconText == rhs.currCustomIconText
    }
    
}

struct CustomIconViewLarge: View, Equatable {
    let selectedCustomImage: Image
    let currCustomIconText: String
    let noImage: Bool
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(Color.black, lineWidth: 3)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
            )
            .aspectRatio(1, contentMode: .fill)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                VStack {
                    if !currCustomIconText.isEmpty && !noImage {
                        Spacer()
                    }
                    if !noImage {
                        Spacer()
                        selectedCustomImage
                            .resizable()
                            .aspectRatio(1, contentMode: currCustomIconText.isEmpty ? .fill : .fit)
                            .clipShape(RoundedRectangle(cornerRadius: currCustomIconText.isEmpty ? 0 : 25))
                    }
                    if !currCustomIconText.isEmpty {
                        if !noImage {
                            Spacer()
                        }
                        Text(currCustomIconText)
                            .lineLimit(1)
                            .multilineTextAlignment(.center)
                            .font(.system(size: noImage ? 1000 : 100, weight: .semibold, design: .rounded))
                            .minimumScaleFactor(0.1)
                            .foregroundColor(.black)
                            .padding(.leading)
                            .padding(.trailing)
                            .padding(.bottom)
                    }
                }
            )
            .scaledToFit()
            .ignoresSafeArea()
    }
    
    static func == (lhs: CustomIconViewLarge, rhs: CustomIconViewLarge) -> Bool {
        // Compare only the relevant properties for equality
        return lhs.selectedCustomImage == rhs.selectedCustomImage && lhs.currCustomIconText == rhs.currCustomIconText
    }
    
}

struct CustomIconSaveView: View {
    let selectedCustomImage: Image
    let currCustomIconText: String
    let noImage: Bool
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .aspectRatio(1, contentMode: .fill)
            .overlay(
                VStack {
                    if !currCustomIconText.isEmpty && !noImage {
                        Spacer()
                    }
                    if !noImage /* check to see if the image is not plus.viewfinder */ {
                        selectedCustomImage
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: currCustomIconText.isEmpty ? 0 : 10))
                    }
                    if !currCustomIconText.isEmpty {
                        if !noImage {
                            Spacer()
                        }
                        Text(currCustomIconText)
                            .lineLimit(1)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 200, weight: .medium, design: .rounded))
                            .minimumScaleFactor(0.1)
                            .foregroundColor(.black)
                            .padding(.leading)
                            .padding(.trailing)
                            .padding(.bottom, 3)
                    }
                }
            )
            .scaledToFit()
            .ignoresSafeArea()
    }
}
