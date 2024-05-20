//
//  CommunicationBoardView.swift
//  Daysy
//
//  Created by Alexander Eischeid on 4/24/24.
//

import SwiftUI


struct CommunicationBoardView: View {
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.presentationMode) var presentation
    
    @State var tappedIcons: [String] = []
    @State var animate = false
    @State var isTextFieldActive = false
    @State var isCustomTextFieldActive = false
    @State var searchText = ""
    @State var typeText = ""
    @State var unlockButtons = false
    @State var lockButtonsOn = defaults.bool(forKey: "buttonsOn")
    
    @State var currCommunicationBoard = loadCommunicationBoard()
    
    var body: some View {
        
        var filteredData: [String] { //contains search results for default icons
            if searchText.isEmpty {
                return []
            } else {
                let matchingItems = allPECS.filter { $0.localizedCaseInsensitiveContains(searchText) }
                
                let sortedItems = matchingItems.sorted { (item1, item2) -> Bool in
                    let startsWithSearchText1 = item1.lowercased().hasPrefix(searchText.lowercased())
                    let startsWithSearchText2 = item2.lowercased().hasPrefix(searchText.lowercased())
                    
                    // Prioritize items that start with searchText
                    if startsWithSearchText1 && !startsWithSearchText2 {
                        return true
                    } else if !startsWithSearchText1 && startsWithSearchText2 {
                        return false
                    } else {
                        // For items starting with searchText or having searchText as prefix, sort them alphabetically
                        return item1.localizedCaseInsensitiveCompare(item2) == .orderedAscending
                    }
                }
                
                return sortedItems
            }
        }
        ZStack {
            VStack {
                HStack(alignment: .top) {
                    VStack(alignment: horizontalSizeClass == .compact ? .leading : .center) {
                        Text("\(Image(systemName: "message.badge.waveform.fill")) Communication")
                            .lineLimit(1)
                        //                            .minimumScaleFactor(0.01)
                            .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                            .padding(.top)
                            .padding(.bottom, horizontalSizeClass == .compact ? 5 : 0)
                        Text("Use this board to communicate and form sentences without affecting your Sheets")
                            .minimumScaleFactor(0.01)
                            .font(.system(size: horizontalSizeClass == .compact ? 17 : 25, weight: .bold, design: .rounded))
                            .foregroundColor(Color(.systemGray))
                            .multilineTextAlignment(horizontalSizeClass == .compact ? .leading : .center)
                            .padding(.bottom)
                    }
                    .padding(.leading, horizontalSizeClass == .compact ? 20 : 0)
                    if horizontalSizeClass == .compact {
                        Spacer()
                        Button(action: {
                            self.presentation.wrappedValue.dismiss()
                        }) {
                            Text("\(Image(systemName: "xmark.circle.fill"))")
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .foregroundColor(loadSheetArray().count > 1 ? Color(.systemGray3): Color(.systemGray6))
                                .padding([.top, .trailing])
                        }
                    }
                }
                
                HStack {
                    Button(action: {
                        for icon in tappedIcons {
                            if icon != "action:divider" {
                                speechSynthesizer.speak(icon)
                            }
                        }
                    }) {
                        if #available(iOS 15.0, *) {
                            Image(systemName: "play.square.fill")
                                .resizable()
                                .frame(width:100, height: 100)
                                .foregroundColor(.purple)
                                .symbolRenderingMode(.hierarchical)
                                .padding()
                        } else {
                            Image(systemName: "play.square.fill")
                                .resizable()
                                .frame(width:100, height: 100)
                                .foregroundColor(.purple)
                                .padding()
                        }
                        
                    }.padding(.trailing)
                    ScrollView(.horizontal) {
                        ScrollViewReader { value in
                            HStack {
                                ForEach(0..<tappedIcons.count, id: \.self) { icon in //next display default icon results
                                    if tappedIcons[icon] == "action:divider" {
                                        //Divider().padding()
                                        //                                        Image(systemName: "line.diagonal")
                                        //                                            .resizable()
                                        //                                            .rotationEffect(.degrees(315))
                                        //                                            .frame(width:125, height: 125)
                                        //                                            .foregroundColor(Color(.systemGray))
                                    } else if tappedIcons[icon].contains("customIconObject:") {
                                        getCustomIconSmall(tappedIcons[icon])
                                            .frame(width:125, height: 125)
                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(lineWidth: 3)
                                                    .foregroundColor(.black)
                                            )
                                            .padding(.trailing, 5)
                                    } else {
                                        loadImage(named: tappedIcons[icon])
                                            .resizable()
                                            .frame(width:125, height: 125)
                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(lineWidth: 3)
                                                    .foregroundColor(.black)
                                            )
                                            .padding(.trailing, 5)
                                    }
                                }
                                .onChange(of: tappedIcons.count) { _ in
                                    value.scrollTo(tappedIcons.count - 1)
                                    animate.toggle()
                                }
                                .onChange(of: isTextFieldActive) { _ in
                                    if !isTextFieldActive {
                                        searchText = ""
                                        animate.toggle()
                                    }
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    Button(action: {
                        tappedIcons.removeAll()
                        animate.toggle()
                    }) {
                        if #available(iOS 15.0, *) {
                            Image(systemName: "delete.backward.fill")
                                .resizable()
                                .frame(width:115, height: 100)
                                .foregroundColor(.red)
                                .symbolRenderingMode(.hierarchical)
                                .padding()
                        } else {
                            Image(systemName: "delete.backward.fill")
                                .resizable()
                                .frame(width:115, height: 100)
                                .foregroundColor(.red)
                                .padding()
                        }
                        
                    }
                }
                .padding()
                ScrollView {
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: horizontalSizeClass == .compact ? 100 : 175))], spacing: horizontalSizeClass == .compact ? 5 : 10) {
                        if isTextFieldActive {
                            ForEach(0..<filteredData.count, id: \.self) { icon in //next display default icon results
                                Button(action: {
                                    tappedIcons.append(filteredData[icon])
                                    speechSynthesizer.speak(filteredData[icon])
                                    animate.toggle()
                                }) {
                                    loadImage(named: filteredData[icon])
                                        .resizable()
                                        .scaledToFit()
                                        .clipShape(RoundedRectangle(cornerRadius: 30))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 30)
                                                .stroke(lineWidth: 5)
                                                .foregroundColor(.black)
                                        )
                                }
                            }
                        } else {
                            ForEach(currCommunicationBoard, id: \.self) { items in
                                if items.count == 1 {
                                    if items[0].contains("customIconObject:") {
                                        Button(action: {
                                            print("tapped \(items[0])")
                                            //                    tappedIcons.append(items[0])
                                            //                    speechSynthesizer.speak(item[0])
                                            //                    animate.toggle()
                                        }) {
                                            getCustomIcon(items[0])
                                                .scaledToFit()
                                                .clipShape(RoundedRectangle(cornerRadius: 30))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 30)
                                                        .stroke(lineWidth: 5)
                                                        .foregroundColor(.black)
                                                )
                                                .contextMenu {
                                                    if lockButtonsOn && !unlockButtons {
                                                        Button {
                //                                            if !canUseBiometrics() && !canUsePassword() {
                //                                                showCustomPassword = true
                //                                            } else {
                //                                                authenticateWithBiometrics()
                //                                            }
                                                        } label: {
                                                            Label("Unlock Buttons", systemImage: "lock.open")
                                                        }
                                                    } else {
                                                        Button {
                                                            
                                                        } label: {
                                                            Label("Custom Icon Test Button", systemImage: "square.and.pencil")
                                                        }
                                                        
                                                        Button {
                                                            
                                                        } label: {
                                                            Label("Custom Icon Test Button", systemImage: "square.and.pencil")
                                                        }
                                                    }
                                                }
                                        }
                                    } else {
                                        Button(action: {
                                            //                    tappedIcons.append(item[0])
                                            //                    speechSynthesizer.speak(item[0])
                                            //                    animate.toggle()
                                        }) {
                                            loadImage(named: items[0])
                                                .resizable()
                                                .scaledToFit()
                                                .clipShape(RoundedRectangle(cornerRadius: 30))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 30)
                                                        .stroke(lineWidth: 5)
                                                        .foregroundColor(.black)
                                                )
                                                .contextMenu {
                                                    if lockButtonsOn && !unlockButtons {
                                                        Button {
                //                                            if !canUseBiometrics() && !canUsePassword() {
                //                                                showCustomPassword = true
                //                                            } else {
                //                                                authenticateWithBiometrics()
                //                                            }
                                                        } label: {
                                                            Label("Unlock Buttons", systemImage: "lock.open")
                                                        }
                                                    } else {
                                                        Button {
                                                            
                                                        } label: {
                                                            Label("Icon Test Button", systemImage: "square.and.pencil")
                                                        }
                                                        
                                                        Button {
                                                            
                                                        } label: {
                                                            Label("Icon Test Button", systemImage: "square.and.pencil")
                                                        }
                                                    }
                                                }
                                        }
                                    }
                                } else {
                                    Button(action: {
                                        print("tapped folder named \(items[0])")
                                    }) {
                                        Image(systemName: "square.grid.3x3.square")
                                            .resizable()
                                            .scaledToFit()
                                    }
                                    .contextMenu {
                                        if lockButtonsOn && !unlockButtons {
                                            Button {
                                                //                                            if !canUseBiometrics() && !canUsePassword() {
                                                //                                                showCustomPassword = true
                                                //                                            } else {
                                                //                                                authenticateWithBiometrics()
                                                //                                            }
                                            } label: {
                                                Label("Unlock Buttons", systemImage: "lock.open")
                                            }
                                        } else {
                                            Button {
                                                
                                            } label: {
                                                Label("Folder Test Button", systemImage: "square.and.pencil")
                                            }
                                            
                                            Button {
                                                
                                            } label: {
                                                Label("Folder Test Button", systemImage: "square.and.pencil")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .padding(.bottom, 100)
                }
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    HStack {
                        if horizontalSizeClass != .compact && !isTextFieldActive && !isCustomTextFieldActive {
                            Button(action: {
                                self.presentation.wrappedValue.dismiss()
                            }) {
                                Image(systemName:"xmark.square.fill")
                                    .resizable()
                                    .frame(width:100, height: 100)
                                    .foregroundColor(Color(.systemGray))
                                    .padding()
                            }
                        }
                        
                        ZStack {
                            TextField(isTextFieldActive ? "\(Image(systemName: "magnifyingglass")) Search" : "", text: $searchText, onEditingChanged: { editing in
                                isTextFieldActive = editing
                                animate.toggle()
                            }, onCommit: {
                                
                            })
                            .minimumScaleFactor(0.1)
                            .font(.system(size: horizontalSizeClass == .compact ? 40 : 65, weight: .semibold,  design: .rounded))
                            .frame(width: isTextFieldActive ? (horizontalSizeClass == .compact ? 375 : 500) : (horizontalSizeClass == .compact ? 75 : 100), height: horizontalSizeClass == .compact ? 75 : 100)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(.systemGray6))
                            )
                            if !isTextFieldActive {
                                Image(systemName: "magnifyingglass")
                                    .resizable()
                                    .frame(width: horizontalSizeClass == .compact ? 40 : 70, height: horizontalSizeClass == .compact ? 40 : 70)
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding(isTextFieldActive ? 10 : 0)
                        
                        HStack {
                            ZStack {
                                TextField(isCustomTextFieldActive ? "\(Image(systemName: "magnifyingglass")) Search" : "", text: $typeText, onEditingChanged: { editing in
                                    isCustomTextFieldActive = editing
                                    animate.toggle()
                                }, onCommit: {
                                    
                                })
                                .minimumScaleFactor(0.1)
                                .font(.system(size: horizontalSizeClass == .compact ? 40 : 65, weight: .semibold,  design: .rounded))
                                .frame(width: isCustomTextFieldActive ? (horizontalSizeClass == .compact ? 375 : 500) : (horizontalSizeClass == .compact ? 75 : 100), height: horizontalSizeClass == .compact ? 75 : 100)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color(.systemGray6))
                                )
                                if !isCustomTextFieldActive {
                                    Image(systemName: "magnifyingglass")
                                        .resizable()
                                        .frame(width: horizontalSizeClass == .compact ? 40 : 70, height: horizontalSizeClass == .compact ? 40 : 70)
                                        .foregroundColor(.primary)
                                }
                            }
                            .padding(isCustomTextFieldActive ? 10 : 0)
                            if isCustomTextFieldActive && !typeText.isEmpty {
                                Button(action: {
                                    speechSynthesizer.speak(typeText)
                                }) {
                                    Image(systemName: "play.square.fill")
                                        .resizable()
                                        .frame(width:100, height: 100)
                                        .foregroundColor(.purple)
                                        .padding()
                                }
                            }
                        }
                        
                        if !isTextFieldActive && !isCustomTextFieldActive {
                            Button(action: {
                                tappedIcons.append("action:divider")
                                animate.toggle()
                            }) {
                                ZStack {
                                    Image(systemName: "square.fill")
                                        .resizable()
                                        .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                        .foregroundColor(Color(.systemGray6))
                                        .padding()
                                    Image(systemName: "keyboard")
                                        .resizable()
                                        .frame(width: horizontalSizeClass == .compact ? 50 : 75, height: horizontalSizeClass == .compact ? 30 : 55)
                                        .frame(width: horizontalSizeClass == .compact ? 50 : 75, height: horizontalSizeClass == .compact ? 30 : 55)
                                        .foregroundColor(.primary)
                                }
                            }
                            Button(action: {
                                
                            }) {
                                ZStack {
                                    Image(systemName: "square.fill")
                                        .resizable()
                                        .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                        .foregroundColor(Color(.systemGray6))
                                        .padding()
                                    Image(systemName: "plus.viewfinder")
                                        .resizable()
                                        .frame(width: horizontalSizeClass == .compact ? 40 : 70, height: horizontalSizeClass == .compact ? 40 : 70)
                                        .foregroundColor(.primary)
                                    
                                }
                            }
                            Button(action: {
                                
                            }) {
                                ZStack {
                                    Image(systemName: "square.fill")
                                        .resizable()
                                        .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                        .foregroundColor(Color(.systemGray6))
                                        .padding()
                                    Image(systemName: "folder.badge.plus")
                                        .resizable()
                                        .frame(width: horizontalSizeClass == .compact ? 45 : 75, height: horizontalSizeClass == .compact ? 30 : 55)
                                        .padding(.leading, 5)
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                    }
                    .padding()
                    Spacer()
                }
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color(.systemBackground).opacity(1), Color(.systemBackground).opacity(1),  Color.clear.opacity(0)]), startPoint: .bottom, endPoint: .top)
                        .ignoresSafeArea()
                )
            }
        }
        .animation(.spring, value: animate)
    }
}



#Preview {
    CommunicationBoardView()
}
