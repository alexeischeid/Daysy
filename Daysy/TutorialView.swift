//
//  TutorialView.swift
//  Daysy
//
//  Created by Alexander Eischeid on 10/21/23.
//

//theres some navigation destinations and stuff commented out because this was originally built with NavigationStack, but had to fall back to NavigationView for compatability, lower deployment target

import SwiftUI
import Foundation

var progress = 0
var totalSheets: CGFloat = 6


struct TutorialView: View { //main welcome page
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State var presentNext = false
    @State var beginSetup = false
    
    var body: some View {
        NavigationView {
            VStack {
                GeometryReader { geometry in
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: geometry.size.width * (0/totalSheets), height: 5)
                        .foregroundColor(.purple)
                }
                .frame(height: 5)
                Spacer()
                Text("Welcome to Daysy!")
                    .lineLimit(1)
                    .minimumScaleFactor(0.01)
                    .font(.system(size: horizontalSizeClass == .compact ? 35 : 100, weight: .bold, design: .rounded))
                    .padding(.leading)
                    .padding(.trailing)
                
                Text("Let's Get Started.")
                    .lineLimit(1)
                    .minimumScaleFactor(0.01)
                    .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                    .padding(.leading)
                    .padding(.trailing)
                
                NavigationLink(destination: TimeslotView()) {
                    Text("\(Image(systemName: "book")) View Tutorial")
                        .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding()
                        .padding()
                        .background(Color.blue)
                        .font(.system(size: horizontalSizeClass == .compact ? 15 : 25, weight: .bold, design: .rounded))
                        .cornerRadius(horizontalSizeClass == .compact ? 15 : 30)
                }
                .padding()
                /*
                .navigationDestination(isPresented: $presentNext) {
                    TimeslotView()
                } */
                .navigationBarTitle("", displayMode: .inline)
                
                Text("or")
                    .lineLimit(1)
                    .minimumScaleFactor(0.01)
                    .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                    .foregroundColor(Color(.systemGray))
                
                NavigationLink(destination: ContentView()) {
                    Text("\(Image(systemName: "square.grid.3x3.square")) Begin Setup")
                        .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .bold, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .padding()
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(horizontalSizeClass == .compact ? 15 : 30)
                }
                .padding()
                Spacer()
            } /*
            .navigationDestination(isPresented: $beginSetup) {
                ContentView()
            } */
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarHidden(true)
    }
}

struct TimeslotView: View { //timeslot tutorial view
    @State var presentNext = false
    @Environment(\.presentationMode) var presentation
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: geometry.size.width * (1/totalSheets), height: 5)
                    .foregroundColor(.purple)
            }
            .frame(height: 5)
            Text("\(Image(systemName: "timer")) Timeslots")
                .lineLimit(1)
                .minimumScaleFactor(0.01)
                .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                .padding(horizontalSizeClass == .compact ? 5 : 15)
            Text("You can set up a Sheet using Timeslots. Daysy will automatically sort these to be in order, can show you the current Timeslot, and send you notifications.")
                .minimumScaleFactor(0.01)
                .multilineTextAlignment(.center)
                .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
            Spacer()
            //Divider()
            if horizontalSizeClass != .compact {
                LazyVGrid(columns: Array(repeating: GridItem(), count: 5)) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemGray5))
                            .scaledToFit()
                        Text("12:00 PM")
                            .lineLimit(1)
                            .minimumScaleFactor(0.01)
                            .font(.system(size: 300,  weight: .bold, design: .rounded))
                            .padding()
                            .foregroundColor(.primary)
                    }
                    
                    Image("eatlunch")
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.black, lineWidth: 6)
                        )
                    
                    Image("brownie")
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.black, lineWidth: 6)
                        )
                    
                    Image("playground")
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.black, lineWidth: 6)
                        )
                    
                    Image("school")
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.black, lineWidth: 6)
                        )
                }
            } else {
                //iPhone grid here
                VStack {
                    Text("12:00 PM")
                        .lineLimit(1)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .padding(.top)
                    LazyVGrid(columns: Array(repeating: GridItem(), count: 2)) {
                        Image("eatlunch")
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(.black, lineWidth: 6)
                            )
                            .padding()
                        
                        Image("brownie")
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(.black, lineWidth: 6)
                            )
                            .padding()
                        
                        Image("playground")
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(.black, lineWidth: 6)
                            )
                            .padding()
                        
                        Image("school")
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(.black, lineWidth: 6)
                            )
                            .padding()
                    }
                }
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding([.leading, .trailing])
                .padding([.leading, .trailing])
            }
            //Divider()
            Spacer()
            HStack {
                Button(action: {
                    self.presentation.wrappedValue.dismiss()
                }) {
                    Text("\(Image(systemName: "arrow.backward")) Back")
                        .lineLimit(1)
                        .minimumScaleFactor(0.1)
                        .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .padding(horizontalSizeClass == .compact ? 20 : 30)
                        .background(Color(.systemGray5))
                        .cornerRadius(horizontalSizeClass == .compact ? 15 : 25)
                }
                .padding(horizontalSizeClass == .compact ? [.leading, .trailing] : [.top, .bottom, .leading, .trailing], 10)
                
                NavigationLink(destination: AsyncView()) {
                    Text("Next \(Image(systemName: "arrow.forward"))")
                        .lineLimit(1)
                        .minimumScaleFactor(0.1)
                        .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .padding(horizontalSizeClass == .compact ? 20 : 30)
                        .background(Color(.systemGray5))
                        .cornerRadius(horizontalSizeClass == .compact ? 15 : 25)
                }
                .padding(horizontalSizeClass == .compact ? [.leading, .trailing] : [.top, .bottom, .leading, .trailing], 10)
            } /*
               .navigationDestination(isPresented: $presentNext) {
               AsyncView()
               } */
            .navigationBarTitle("", displayMode: .inline)
        }
        .navigationBarHidden(true)
    }
}

struct AsyncView: View { //custom labels tutorial view
    @State var presentNext = false
    @Environment(\.presentationMode) var presentation
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: geometry.size.width * (2/totalSheets), height: 5)
                    .foregroundColor(.purple)
            }
            .frame(height: 5)
            Text("\(Image(systemName: "tag")) Custom Labels")
                .lineLimit(1)
                .minimumScaleFactor(0.01)
                .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                .padding(horizontalSizeClass == .compact ? 5 : 15)
            Text("You can also set up a Sheet that uses your own custom labels. These will not be sorted by Daysy.")
                .minimumScaleFactor(0.01)
                .multilineTextAlignment(.center)
                .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
            Spacer()
            //Divider()
            if horizontalSizeClass != .compact {
                LazyVGrid(columns: Array(repeating: GridItem(), count: 5)) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemGray5))
                            .scaledToFit()
                        Text("Jared")
                            .lineLimit(1)
                            .minimumScaleFactor(0.01)
                            .font(.system(size: 300,  weight: .bold, design: .rounded))
                            .padding()
                            .padding()
                            .foregroundColor(.primary)
                    }
                    Image("putsockson")
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.black, lineWidth: 6)
                        )
                    
                    Image("dog")
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.black, lineWidth: 6)
                        )
                    
                    Image("lunch")
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.black, lineWidth: 6)
                        )
                    
                    Image("cleanup")
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.black, lineWidth: 6)
                        )
                }
            } else {
                //iPhone grid here
                VStack {
                    Text("Jared")
                        .lineLimit(1)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .padding(.top)
                    LazyVGrid(columns: Array(repeating: GridItem(), count: 2)) {
                        Image("putsockson")
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(.black, lineWidth: 6)
                            )
                            .padding()
                        
                        Image("dog")
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(.black, lineWidth: 6)
                            )
                            .padding()
                        
                        Image("lunch")
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(.black, lineWidth: 6)
                            )
                            .padding()
                        
                        Image("cleanup")
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(.black, lineWidth: 6)
                            )
                            .padding()
                    }
                }
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding([.leading, .trailing])
                .padding([.leading, .trailing])
            }
            //Divider()
            Spacer()
            HStack {
                Button(action: {
                    self.presentation.wrappedValue.dismiss()
                }) {
                    Text("\(Image(systemName: "arrow.backward")) Back")
                        .lineLimit(1)
                        .minimumScaleFactor(0.1)
                        .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .padding(horizontalSizeClass == .compact ? 20 : 30)
                        .background(Color(.systemGray5))
                        .cornerRadius(horizontalSizeClass == .compact ? 15 : 25)
                }
                .padding(horizontalSizeClass == .compact ? [.leading, .trailing] : [.top, .bottom, .leading, .trailing], 10)
                
                NavigationLink(destination: TryItView()) {
                    Text("Next \(Image(systemName: "arrow.forward"))")
                        .lineLimit(1)
                        .minimumScaleFactor(0.1)
                        .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .padding(horizontalSizeClass == .compact ? 20 : 30)
                        .background(Color(.systemGray5))
                        .cornerRadius(horizontalSizeClass == .compact ? 15 : 25)
                }
                .padding(horizontalSizeClass == .compact ? [.leading, .trailing] : [.top, .bottom, .leading, .trailing], 10)
            } /*
            .navigationDestination(isPresented: $presentNext) {
                TryItView()
            } */
            .navigationBarTitle("", displayMode: .inline)
        }
        .navigationBarHidden(true)
    }
}

struct TryItView: View { //interactive little mini sheet to play with
    
    @Environment(\.presentationMode) var presentation
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    enum PickerOption: String, CaseIterable {
        case timeslots = "Timeslots"
        case customLabels = "Custom Labels"
    }
    @State var selectedOption = PickerOption.timeslots
    
    @State var presentNext = false
    
    @State var showIcons = false
    @State var showTime = false
    @State private var selectedDate = Date()
    @State var currTime = "0:00"
    @State var currLabel = "Label"
    @State var currText = ""
    @State var searchText = ""
    @State var showLabels = false
    @State var currSetIndex = 0
    @State var currGrid = [Image(systemName:"plus.viewfinder"), Image(systemName:"plus.viewfinder"), Image(systemName:"plus.viewfinder"), Image(systemName:"plus.viewfinder"), Image(systemName:"plus.viewfinder"), Image(systemName:"plus.viewfinder"), Image(systemName:"plus.viewfinder"), Image(systemName:"plus.viewfinder")]
    var body: some View {
        VStack {
            GeometryReader { geometry in
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: geometry.size.width * (3/totalSheets), height: 5)
                    .foregroundColor(.purple)
            }
            .frame(height: 5)
            Spacer()
            Text("Practice setting up! The example below is fully interactive. You can try setting a time, setting a custom label, as well as adding icons.")
                .minimumScaleFactor(0.01)
                .multilineTextAlignment(.center)
                .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                .padding()
            Spacer()
            //Divider()
            ZStack {
                if horizontalSizeClass != .compact {
                    LazyVGrid(columns: Array(repeating: GridItem(), count: 5)) {
                        Button(action: {showTime.toggle()}) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(.systemGray5))
                                    .scaledToFit()
                                HStack {
                                    Image(systemName: "square.and.pencil")
                                        .resizable()
                                        .minimumScaleFactor(0.01)
                                        .frame(width: 30, height: 30)
                                        .padding(.leading)
                                        .foregroundColor(Color(.systemGray))
                                    
                                    Text(currTime)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.01)
                                        .font(.system(size: 300,  weight: .bold, design: .rounded))
                                        .padding(.trailing)
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                        .foregroundColor(.primary)
                        ForEach(0..<4, id: \.self) { index in
                            Button(action:{
                                currSetIndex = index
                                searchText = ""
                                showIcons.toggle()}) {
                                    if currGrid[index] == Image(systemName:"plus.viewfinder") {
                                        if #available(iOS 15.0, *) {
                                            Image(systemName: "plus.viewfinder")
                                                .resizable()
                                                .scaledToFit()
                                                .symbolRenderingMode(.hierarchical)
                                                .foregroundColor(Color(.systemGray))
                                                .padding()
                                        } else {
                                            Image(systemName: "plus.viewfinder")
                                                .resizable()
                                                .scaledToFit()
                                                .foregroundColor(Color(.systemGray))
                                                .padding()
                                        }
                                    } else {
                                        currGrid[index]
                                            .resizable()
                                            .scaledToFit()
                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(.black, lineWidth: 6)
                                            )
                                            .padding(5)
                                    }
                                }
                                .foregroundColor(.primary)
                        }
                    }
                    Divider()
                    LazyVGrid(columns: Array(repeating: GridItem(), count: 5)) {
                        Button(action: {showLabels.toggle()}) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(.systemGray5))
                                    .scaledToFit()
                                HStack {
                                    Image(systemName: "square.and.pencil")
                                        .resizable()
                                        .minimumScaleFactor(0.01)
                                        .frame(width: 30, height: 30)
                                        .padding(.leading)
                                        .foregroundColor(Color(.systemGray))
                                    
                                    Text(currLabel)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.01)
                                        .font(.system(size: 300,  weight: .bold, design: .rounded))
                                        .padding(.trailing)
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                        .foregroundColor(.primary)
                        ForEach(4..<8, id: \.self) { index in
                            Button(action:{
                                currSetIndex = index
                                showIcons.toggle()}) {
                                    if currGrid[index] == Image(systemName:"plus.viewfinder") {
                                        if #available(iOS 15.0, *) {
                                            Image(systemName: "plus.viewfinder")
                                                .resizable()
                                                .scaledToFit()
                                                .symbolRenderingMode(.hierarchical)
                                                .foregroundColor(Color(.systemGray))
                                                .padding()
                                        } else {
                                            Image(systemName: "plus.viewfinder")
                                                .resizable()
                                                .scaledToFit()
                                                .foregroundColor(Color(.systemGray))
                                                .padding()
                                        }
                                    } else {
                                        currGrid[index]
                                            .resizable()
                                            .scaledToFit()
                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(.black, lineWidth: 6)
                                            )
                                            .padding(5)
                                    }
                                }
                                .foregroundColor(.primary)
                        }
                    }
                } else {
                    //iPhone grid here
                    //TODO: maybe just change the lazyvgrud and have all the sheets and fullscreencovers still work and scale
                    VStack {
                        Picker("Options", selection: $selectedOption) {
                            ForEach(PickerOption.allCases, id: \.self) { option in
                                Text(option.rawValue)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
                        if selectedOption == .timeslots {
                            VStack {
                                Button(action: {showTime.toggle()}) {
                                    HStack {
                                        Image(systemName: "square.and.pencil")
                                            .resizable()
                                            .minimumScaleFactor(0.01)
                                            .frame(width: 30, height: 30)
                                            .padding(.leading)
                                            .foregroundColor(Color(.systemGray))
                                        
                                        Text(currTime)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.01)
                                            .font(.system(size: 30,  weight: .bold, design: .rounded))
                                            .padding(.trailing)
                                            .foregroundColor(.primary)
                                    }
                                    .padding(.top)
                                }
                                LazyVGrid(columns: Array(repeating: GridItem(), count: 2)) {
                                    ForEach(0..<4, id: \.self) { index in
                                        Button(action:{
                                            currSetIndex = index
                                            searchText = ""
                                            showIcons.toggle()}) {
                                                if currGrid[index] == Image(systemName:"plus.viewfinder") {
                                                    if #available(iOS 15.0, *) {
                                                        Image(systemName: "plus.viewfinder")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .symbolRenderingMode(.hierarchical)
                                                            .foregroundColor(Color(.systemGray))
                                                            .padding()
                                                    } else {
                                                        Image(systemName: "plus.viewfinder")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .foregroundColor(Color(.systemGray))
                                                            .padding()
                                                    }
                                                } else {
                                                    currGrid[index]
                                                        .resizable()
                                                        .scaledToFit()
                                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 20)
                                                                .stroke(.black, lineWidth: 6)
                                                        )
                                                        .padding(5)
                                                }
                                            }
                                            .foregroundColor(.primary)
                                    }
                                }
                            }
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .padding([.leading, .trailing])
                            .padding([.leading, .trailing])
                        } else if selectedOption == .customLabels {
                            VStack {
                                Button(action: {showLabels.toggle()}) {
                                    HStack {
                                        Image(systemName: "square.and.pencil")
                                            .resizable()
                                            .minimumScaleFactor(0.01)
                                            .frame(width: 30, height: 30)
                                            .padding(.leading)
                                            .foregroundColor(Color(.systemGray))
                                        
                                        Text(currLabel)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.01)
                                            .font(.system(size: 30,  weight: .bold, design: .rounded))
                                            .padding(.trailing)
                                            .foregroundColor(.primary)
                                    }
                                    .padding(.top)
                                }
                                LazyVGrid(columns: Array(repeating: GridItem(), count: 2)) {
                                    ForEach(4..<8, id: \.self) { index in
                                        Button(action:{
                                            currSetIndex = index
                                            showIcons.toggle()}) {
                                                if currGrid[index] == Image(systemName:"plus.viewfinder") {
                                                    if #available(iOS 15.0, *) {
                                                        Image(systemName: "plus.viewfinder")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .symbolRenderingMode(.hierarchical)
                                                            .foregroundColor(Color(.systemGray))
                                                            .padding()
                                                    } else {
                                                        Image(systemName: "plus.viewfinder")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .foregroundColor(Color(.systemGray))
                                                            .padding()
                                                    }
                                                } else {
                                                    currGrid[index]
                                                        .resizable()
                                                        .scaledToFit()
                                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 20)
                                                                .stroke(.black, lineWidth: 6)
                                                        )
                                                        .padding(5)
                                                }
                                            }
                                            .foregroundColor(.primary)
                                    }
                                }
                            }
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .padding([.leading, .trailing])
                            .padding([.leading, .trailing])
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $showIcons) {
                
                AllIconsPickerView(currSheet: SheetObject(), //no sheet to provide tutorial,
                                   currImage: "plus.viewfinder",
                                   modifyIcon: { newIcon in
                    currGrid[currSetIndex] = loadImage(named: newIcon)
                }, modifyDetails: { newDetails in
                    //no need to modify details here
                }, modifySheet: {newSheet in
                    //no need to modify sheet in tutorial
                }, showCreateCustom: false,
                tutorialMode: true)

            }
            .sheet(isPresented: $showTime) {
                Spacer()
                DatePicker("", selection: $selectedDate, displayedComponents: .hourAndMinute)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .frame(width: 400, height: 400)
                    .scaleEffect(horizontalSizeClass == .compact ? 1.5 : 3)
                Spacer()
                HStack {
                    Button(action: {
                        showTime.toggle()
                    }) {
                        Image(systemName:"xmark.square.fill")
                            .resizable()
                            .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                            .foregroundColor(Color(.systemGray))
                        //.fontWeight(.bold)
                            .padding()
                    }
                    Button(action: {
                        showTime.toggle()
                        currTime = getTime(date: selectedDate)
                    }) {
                        Image(systemName:"checkmark.square.fill")
                            .resizable()
                            .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                        //.fontWeight(.bold)
                            .foregroundColor(.green)
                            .padding()
                    }
                }
            }
            .sheet(isPresented: $showLabels) {
                VStack {
                    Spacer()
                    ZStack {
                        TextField("Your Label", text: $currText)
                        //.textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.system(size: horizontalSizeClass == .compact ? 40 : 100, weight: .bold, design: .rounded))
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(.systemGray5))
                            )
                    }
                    .padding()
                    Spacer()
                    Button(action: {
                        showLabels.toggle()
                        if !currText.isEmpty {
                            currLabel = currText
                        }
                    }) {
                        if currText.isEmpty {
                            Image(systemName:"xmark.square.fill")
                                .resizable()
                                .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                            //.fontWeight(.bold)
                                .foregroundColor(Color(.systemGray))
                                .padding()
                        } else {
                            Image(systemName:"checkmark.square.fill")
                                .resizable()
                                .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                            //.fontWeight(.bold)
                                .foregroundColor(.green)
                                .padding()
                        }
                    }
                    .padding()
                }
            }
            Spacer()
            HStack {
                Button(action: {
                    self.presentation.wrappedValue.dismiss()
                }) {
                    Text("\(Image(systemName: "arrow.backward")) Back")
                        .lineLimit(1)
                        .minimumScaleFactor(0.1)
                        .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .padding(horizontalSizeClass == .compact ? 20 : 30)
                        .background(Color(.systemGray5))
                        .cornerRadius(horizontalSizeClass == .compact ? 15 : 25)
                }
                .padding(horizontalSizeClass == .compact ? [.leading, .trailing] : [.top, .bottom, .leading, .trailing], 10)
                
                NavigationLink(destination: ModIconView()) {
                    Text("Next \(Image(systemName: "arrow.forward"))")
                        .lineLimit(1)
                        .minimumScaleFactor(0.1)
                        .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .padding(horizontalSizeClass == .compact ? 20 : 30)
                        .background(Color(.systemGray5))
                        .cornerRadius(horizontalSizeClass == .compact ? 15 : 25)
                }
                .padding(horizontalSizeClass == .compact ? [.leading, .trailing] : [.top, .bottom, .leading, .trailing], 10)
            } /*
            .navigationDestination(isPresented: $presentNext) {
                ModIconView()
            } */
            .navigationBarTitle("", displayMode: .inline)
        }
        .navigationBarHidden(true)
    }
}

struct ModIconView: View { //tutorial view on completing or removing icon
    @State var presentNext = false
    @Environment(\.presentationMode) var presentation
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State var showMod = false
    @State var currSetIndex = 0
    @State var isModded = false
    @State var isComplete = false
    @State var imageArray = [Image("zipup"), Image("trumpet"), Image("sitcrisscross"), Image("playkeyboard")]
    var body: some View {
        VStack {
            GeometryReader { geometry in
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: geometry.size.width * (4/totalSheets), height: 5)
                    .foregroundColor(.purple)
            }
            .frame(height: 5)
            if isModded {
                if isComplete {
                    Text("You have completed an icon!")
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                        .padding(horizontalSizeClass == .compact ? 5 : 15)
                    Text("Good job. You will be able to view all your completed icons for a individual Sheet after setup. You can try it again, or move on.")
                        .minimumScaleFactor(0.01)
                        .multilineTextAlignment(.center)
                        .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                } else {
                    Text("You have removed an icon!")
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                        .padding(horizontalSizeClass == .compact ? 5 : 15)
                    Text("Good job. You will be able to view all your removed icons for a individual Sheet after setup. You can try it again, or move on.")
                        .minimumScaleFactor(0.01)
                        .multilineTextAlignment(.center)
                        .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                }
            } else {
                Text("Complete/Remove Your Icons")
                    .lineLimit(1)
                    .minimumScaleFactor(0.01)
                    .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                    .padding(horizontalSizeClass == .compact ? 5 : 15)
                Text("After you’re done setting up, you can tap any icon to complete it, or remove it from the Sheet. Try it!")
                    .minimumScaleFactor(0.01)
                    .multilineTextAlignment(.center)
                    .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
            }
            Spacer()
            //Divider()
            ZStack {
                if horizontalSizeClass != .compact {
                    LazyVGrid(columns: Array(repeating: GridItem(), count: 5)) {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemGray5))
                            .scaledToFit()
                        ForEach(0..<imageArray.count, id: \.self) { index in
                            Button(action:{
                                showMod.toggle()
                                currSetIndex = index}) {
                                    if imageArray[index] != Image(systemName:"plus.viewfinder") {
                                        imageArray[index]
                                            .resizable()
                                            .scaledToFit()
                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(.black, lineWidth: 6)
                                            )
                                            .padding(5)
                                    }
                                }
                                .foregroundColor(.primary)
                        }
                    }
                } else {
                    VStack {
                        Text("12:00 PM")
                            .lineLimit(1)
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .padding(.top)
                        LazyVGrid(columns: Array(repeating: GridItem(), count: 2)) {
                            ForEach(0..<imageArray.count, id: \.self) { index in
                                Button(action:{
                                    showMod.toggle()
                                    currSetIndex = index}) {
                                        if imageArray[index] != Image(systemName:"plus.viewfinder") {
                                            imageArray[index]
                                                .resizable()
                                                .scaledToFit()
                                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .stroke(.black, lineWidth: 6)
                                                )
                                                .padding()
                                        }
                                    }
                                    .foregroundColor(.primary)
                            }
                            if imageArray.count < 3 {
                                HStack {
                                    Image(systemName: "square.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.clear)
                                        .padding()
                                }
                            }
                        }
                    }
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding([.leading, .trailing])
                    .padding([.leading, .trailing])
                }
            }
            .fullScreenCover(isPresented: $showMod) {
                VStack {
                    TutorialModView(currImageArray: $imageArray, currIndex: $currSetIndex)
                    HStack(alignment: .top) {
                        Button(action: {
                            showMod.toggle()
                        }) {
                            VStack {
                                Image(systemName:"xmark.square.fill")
                                    .resizable()
                                    .frame(width: horizontalSizeClass == .compact ? min(100, 350) : min(150, 500), height: horizontalSizeClass == .compact ? min(100, 350) : min(150, 500))
                                //.fontWeight(.bold)
                                Text("Cancel")
                                    .font(.system(size: horizontalSizeClass == .compact ? 15 : 25, weight: .semibold, design: .rounded))
                            }
                        }
                        .padding()
                        .foregroundColor(Color(.systemGray))
                        
                        Button(action: {
                            showMod.toggle()
                            isModded = true
                            isComplete = false
                            imageArray.remove(at: currSetIndex)
                        }) {
                            VStack {
                                ZStack {
                                    Image(systemName: "square.fill")
                                        .resizable()
                                        .frame(width: horizontalSizeClass == .compact ? min(100, 350) : min(150, 500), height: horizontalSizeClass == .compact ? min(100, 350) : min(150, 500))
                                    Image(systemName: "square.slash")
                                        .resizable()
                                        .frame(width: horizontalSizeClass == .compact ? min(75, 125) : min(100, 250), height: horizontalSizeClass == .compact ? min(75, 125) : min(100, 250))
                                        .foregroundColor(Color(.systemBackground))
                                }
                                Text("Remove Icon")
                                    .font(.system(size: horizontalSizeClass == .compact ? 15 : 25, weight: .semibold, design: .rounded))
                            }
                        }
                        .padding()
                        .foregroundColor(.red)
                        
                        Button(action: {
                            showMod.toggle()
                            isModded = true
                            isComplete = true
                            imageArray.remove(at: currSetIndex)
                        }) {
                            VStack {
                                Image(systemName: "checkmark.square.fill")
                                    .resizable()
                                    .frame(width: horizontalSizeClass == .compact ? min(100, 350) : min(150, 500), height: horizontalSizeClass == .compact ? min(100, 350) : min(150, 500))
                                //.fontWeight(.bold)
                                Text("Complete Icon")
                                    .font(.system(size: horizontalSizeClass == .compact ? 15 : 25, weight: .semibold, design: .rounded))
                            }
                        }
                        .padding()
                        .foregroundColor(.green)
                    }
                }
            }
            
            Spacer()
            HStack {
                Button(action: {
                    self.presentation.wrappedValue.dismiss()
                }) {
                    Text("\(Image(systemName: "arrow.backward")) Back")
                        .lineLimit(1)
                        .minimumScaleFactor(0.1)
                        .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .padding(horizontalSizeClass == .compact ? 20 : 30)
                        .background(Color(.systemGray5))
                        .cornerRadius(horizontalSizeClass == .compact ? 15 : 25)
                }
                .padding(horizontalSizeClass == .compact ? [.leading, .trailing] : [.top, .bottom, .leading, .trailing], 10)
                
                NavigationLink(destination: ButtonsView()) {
                    Text("Next \(Image(systemName: "arrow.forward"))")
                        .lineLimit(1)
                        .minimumScaleFactor(0.1)
                        .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .padding(horizontalSizeClass == .compact ? 20 : 30)
                        .background(Color(.systemGray5))
                        .cornerRadius(horizontalSizeClass == .compact ? 15 : 25)
                }
                .padding(horizontalSizeClass == .compact ? [.leading, .trailing] : [.top, .bottom, .leading, .trailing], 10)
            } /*
               .navigationDestination(isPresented: $presentNext) {
               ButtonsView()
               } */
            .navigationBarTitle("", displayMode: .inline)
        }
        .navigationBarHidden(true)
    }
}

struct ButtonsView: View { //view describing the buttons on a sheet
    @State var presentNext = false
    @Environment(\.presentationMode) var presentation
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: geometry.size.width * (5/totalSheets), height: 5)
                    .foregroundColor(.purple)
            }
            .frame(height: 5)
            VStack(alignment: .leading) {
                Spacer()
                HStack {
                    ZStack {
                        Image(systemName: "square.fill")
                            .resizable()
                            .padding()
                            .frame(width: min(100, 200), height: min(100, 200))
                            .foregroundColor(.blue)
                        Image(systemName: "pencil")
                            .resizable()
                            .frame(width: min(40, 100), height: min(40, 100))
                            .padding()
                            //.fontWeight(.semibold)
                            .foregroundColor(Color(.systemBackground))
                    }
                    VStack(alignment: .leading) {
                        Text("Edit Sheet")
                            .font(.system(horizontalSizeClass == .compact ? .title3 : .largeTitle, design: .rounded))
                            .fontWeight(.bold)
                        Text("Tap to edit your current Sheet.")
                            .font(.system(horizontalSizeClass == .compact ? .body : .headline, design: .rounded))
                            .foregroundColor(horizontalSizeClass == .compact ? Color(.systemGray) : .primary)
                            .fontWeight(.medium)
                    }
                }
                .padding(horizontalSizeClass == .compact ? [.leading, .trailing] : [.top, .bottom, .leading, .trailing], 10)
                
                HStack {
                    ZStack {
                        Image(systemName: "square.fill")
                            .resizable()
                            .padding()
                            .frame(width: min(100, 200), height: min(100, 200))
                            .foregroundColor(Color(.systemGray))
                        Image(systemName: "gear")
                            .resizable()
                            .frame(width: min(40, 100), height: min(40, 100))
                            .padding()
                            //.fontWeight(.semibold)
                            .foregroundColor(Color(.systemBackground))
                    }
                    VStack(alignment: .leading) {
                        Text("Settings")
                            .font(.system(horizontalSizeClass == .compact ? .title3 : .largeTitle, design: .rounded))
                            .fontWeight(.bold)
                        Text("Customize Daysy to fit your personal needs and likes.")
                            .font(.system(horizontalSizeClass == .compact ? .body : .headline, design: .rounded))
                            .foregroundColor(horizontalSizeClass == .compact ? Color(.systemGray) : .primary)
                            .fontWeight(.medium)
                    }
                }
                .padding(horizontalSizeClass == .compact ? [.leading, .trailing] : [.top, .bottom, .leading, .trailing], 10)
                
                HStack {
                    ZStack {
                        Image(systemName: "square.fill")
                            .resizable()
                            .padding()
                            .frame(width: min(100, 200), height: min(100, 200))
                            .foregroundColor(.purple)
                        Image(systemName: "square.grid.2x2")
                            .resizable()
                            .frame(width: min(40, 100), height: min(40, 100))
                            .padding()
                            //.fontWeight(.semibold)
                            .foregroundColor(Color(.systemBackground))
                    }
                    VStack(alignment: .leading) {
                        Text("View All Sheets")
                            .font(.system(horizontalSizeClass == .compact ? .title3 : .largeTitle, design: .rounded))
                            .fontWeight(.bold)
                        Text("Tap to view all your Sheets, and switch between them.")
                            .font(.system(horizontalSizeClass == .compact ? .body : .headline, design: .rounded))
                            .foregroundColor(horizontalSizeClass == .compact ? Color(.systemGray) : .primary)
                            .fontWeight(.medium)
                    }
                }
                .padding(horizontalSizeClass == .compact ? [.leading, .trailing] : [.top, .bottom, .leading, .trailing], 10)
                
                HStack {
                    ZStack {
                        Image(systemName: "folder.fill")
                            .resizable()
                            .padding()
                            .frame(width: min(100, 200), height: min(100, 200))
                            .foregroundColor(.red)
                        Image(systemName: "square.slash")
                            .resizable()
                            .frame(width: min(25, 35), height: min(25, 35))
                            .padding()
                            .padding(.top)
                            //.fontWeight(.semibold)
                            .foregroundColor(Color(.systemBackground))
                    }
                    VStack(alignment: .leading) {
                        Text("View Removed")
                            .font(.system(horizontalSizeClass == .compact ? .title3 : .largeTitle, design: .rounded))
                            .fontWeight(.bold)
                        Text("Tap to view all icons that were deleted on the current Sheet.")
                            .font(.system(horizontalSizeClass == .compact ? .body : .headline, design: .rounded))
                            .foregroundColor(horizontalSizeClass == .compact ? Color(.systemGray) : .primary)
                            .fontWeight(.medium)
                    }
                }
                .padding(horizontalSizeClass == .compact ? [.leading, .trailing] : [.top, .bottom, .leading, .trailing], 10)
                
                HStack {
                    ZStack {
                        Image(systemName: "folder.fill")
                            .resizable()
                            .padding()
                            .frame(width: min(100, 200), height: min(100, 200))
                            .foregroundColor(.green)
                        Image(systemName: "checkmark")
                            .resizable()
                            .frame(width: min(25, 35), height: min(25, 35))
                            .padding()
                            .padding(.top)
                            //.fontWeight(.semibold)
                            .foregroundColor(Color(.systemBackground))
                    }
                    VStack(alignment: .leading) {
                        Text("View Completed")
                            .font(.system(horizontalSizeClass == .compact ? .title3 : .largeTitle, design: .rounded))
                            .fontWeight(.bold)
                        Text("Tap to view all icons that were completed on the current Sheet.")
                            .font(.system(horizontalSizeClass == .compact ? .body : .headline, design: .rounded))
                            .foregroundColor(horizontalSizeClass == .compact ? Color(.systemGray) : .primary)
                            .fontWeight(.medium)
                    }
                }
                .padding(horizontalSizeClass == .compact ? [.leading, .trailing] : [.top, .bottom, .leading, .trailing], 10)
                Spacer()
                }
            }
        .navigationBarHidden(true)
        HStack {
            Button(action: {
                self.presentation.wrappedValue.dismiss()
            }) {
                Text("\(Image(systemName: "arrow.backward")) Back")
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                    .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                    //.fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .padding(horizontalSizeClass == .compact ? 20 : 30)
                    .background(Color(.systemGray5))
                    .cornerRadius(horizontalSizeClass == .compact ? 15 : 25)
            }
            .padding(horizontalSizeClass == .compact ? [.leading, .trailing] : [.top, .bottom, .leading, .trailing], 10)
            
            NavigationLink(destination: GotItView()) {
                Text("Next \(Image(systemName: "arrow.forward"))")
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                    .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                //.fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .padding(horizontalSizeClass == .compact ? 20 : 30)
                    .background(Color(.systemGray5))
                    .cornerRadius(horizontalSizeClass == .compact ? 15 : 25)
            }
            .padding(horizontalSizeClass == .compact ? [.leading, .trailing] : [.top, .bottom, .leading, .trailing], 10)
        } /*
        .navigationDestination(isPresented: $presentNext) {
            GotItView()
        } */
        .navigationBarTitle("", displayMode: .inline)
    }
}

struct GotItView: View { //confirmation to go back/create a sheet or to rewatch the tutorial
    @State var presentNext = false
    @Environment(\.presentationMode) var presentation
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State var beginSetup = false
    @State var returnToSheets = false
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Text("Got all that?")
                    .lineLimit(1)
                    .minimumScaleFactor(0.01)
                    .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                    .padding(.leading)
                    .padding(.trailing)
                
                if defaults.bool(forKey: "completedTutorial") {
                    NavigationLink(destination: ContentView()) {
                        Text("\(Image(systemName: "square.grid.3x3.square")) Return to Sheets")
                            .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .padding()
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(horizontalSizeClass == .compact ? 15 : 25)
                    }
                    .padding()
                    .navigationViewStyle(StackNavigationViewStyle())
                } else {
                    NavigationLink(destination: ContentView()) {
                        Text("\(Image(systemName: "square.grid.3x3.square")) Begin Setup")
                            .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .padding()
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(horizontalSizeClass == .compact ? 15 : 25)
                    }
                    .padding()
                }
                
                Text("or")
                    .lineLimit(1)
                    .minimumScaleFactor(0.01)
                    .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                    .foregroundColor(Color(.systemGray))
                
                NavigationLink(destination: TimeslotView()) {
                        Text("\(Image(systemName: "arrow.counterclockwise")) Restart Tutorial")
                        .font(.system(size: horizontalSizeClass == .compact ? 25 : 40, weight: .bold, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .padding()
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(horizontalSizeClass == .compact ? 15 : 25)
                }
                .padding()
                .padding()/*
                .navigationDestination(isPresented: $presentNext) {
                    TimeslotView()
                }
                .navigationBarTitle("", displayMode: .inline)
                .navigationDestination(isPresented: $beginSetup) {
                    ContentView()
                }
                .navigationDestination(isPresented: $returnToSheets) {
                    ContentView()
                } */
                Spacer()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarHidden(true)
    }
}

struct TutorialModView: View { //fix with binding variables to show the icon
    @Binding var currImageArray: [Image]
    @Binding var currIndex: Int
    var body: some View {
        if currIndex >= currImageArray.count {
            loadSystemImage(named: "text.below.photo")
                .resizable()
                .scaledToFit()
                .padding()
        } else {
            currImageArray[currIndex]
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 40))
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(.black, lineWidth: 20)
                )
                .padding()
        }
    }
}

#Preview {
    TutorialView()
}
