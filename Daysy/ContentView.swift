

//
//  ContentView.swift
//  Daysy
//
//  Created by Alexander Eischeid on 10/19/23.
//

import SwiftUI
import StoreKit
import Pow

struct ContentView: View {
    
    @StateObject private var speechDelegate = SpeechSynthesizerDelegate()
    @Environment(\.presentationMode) var presentation
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @AppStorage("communicationDefaultMode") private var showCommunication: Bool = false
    @AppStorage("buttonsOn") private var lockButtonsOn: Bool = false
    @AppStorage("speakOn") private var speakIcons: Bool = true
    @AppStorage("showCurrSlot") private var showCurrentSlot: Bool = false
    @AppStorage("currSheetIndex") private var currSheetIndex: Int = 0
    
    @State var currSheet = loadSheetArray()[defaults.integer(forKey: "currSheetIndex")]
    
    //for contentview
    @State var editMode = false
    @State var wasEditing = false
    @State var showIcons = false
    @State var showTime = false
    @State var showLabels = false
    @State var showMod = false
    @State var showSettings = false
    @State var showRemoved = false
    @State var removedSelected: [IconObject] = getAllRemoved()
    @State var removedSelectedLabel = "All Sheets"
    @State var showAllSheets = false
    @State var animate = false
    @State var unlockButtons = false
    @State var currGreenSlot = loadSheetArray()[defaults.integer(forKey: "currSheetIndex")].getCurrSlot()
    @State var renameSheet = false
    @State var currListIndex = 0
    @State var currSlotIndex = 0
    @State var pickIcon = false
    @State var addSheetIcon = false
    @State var showDetailsIcons = false
    @State var tempDetails: [String] = []
    @State var checkDetails: [String] = []
    @State var detailIconIndex = -1
    @State var showMore = false
    @State var isTextFieldActive = false
    @State var isTitleTextFieldActive = false
    @State var customIconPreviews: [String : UIImage] = [:]
    
    @State var showCustomPassword = false
    
    //custom labels and times
    @State var currText = ""
    @State var currTitleText = ""
    @State var searchText = ""
    @State private var selectedDate = Date()
    
    //allsheetsview
    @State var newSheetSelection = 0 //0 for newSheetTime and 1 for newSheetLabel
    @State var createNewSheet = false
    @State var sheetArray = loadSheetArray()
    @State var sheetAnimate = false
    @State var currSheetText = ""
    @State var presentAlert = false
    
    @State var deleteAnimationFix = false
    @State private var suggestedWords: [String] = []
    @State var currCommunicationBoard: [[String]] = loadCommunicationBoard()
    
    var body: some View {
        ZStack {
            if showCommunication {
                CommunicationBoardView(onDismiss: {
                    //                    defaults.set(false, forKey: "communicationDefaultMode")
                    //                    lockButtonsOn = defaults.bool(forKey: "buttonsOn")
                    //                    showCurrentSlot = defaults.bool(forKey: "showCurrSlot")
                    //                    speakIcons = defaults.bool(forKey: "speakOn")
                    showCommunication.toggle()
                    animate.toggle()
                    if showCurrentSlot {
                        currGreenSlot = currSheet.getCurrSlot()
                    }
                    Task {
                        customIconPreviews = await getCustomIconPreviews()
                        animate.toggle()
                    }
                    
                }, customIconPreviews: customIconPreviews, currCommunicationBoard: currCommunicationBoard)
                .transition(
                    .asymmetric(
                        insertion: .movingParts.flip,
                        removal: .opacity
                    )
                )
            }
            if !showCommunication {
                ZStack {
                    ScrollViewReader { proxy in
                        VStack {
                            ScrollView {
                                if currSheet.label != "Debug, ignore this page" { //always a sheet to render in the background, bug fix
                                    if editMode {
                                        HStack {
                                            Button(action: {
                                                if editMode {
                                                    pickIcon.toggle()
                                                }
                                            }) {
                                                if currSheet.currLabelIcon != nil && !currSheet.currLabelIcon!.isEmpty {
                                                    if UIImage(named: currSheet.currLabelIcon!) == nil {
                                                        Image(uiImage: customIconPreviews[currSheet.currLabelIcon!] ?? UIImage(systemName: "square.fill")!)
                                                            .resizable()
                                                            .frame(width: horizontalSizeClass == .compact ? 50 : 100, height: horizontalSizeClass == .compact ? 50 : 100)
                                                            .clipShape(RoundedRectangle(cornerRadius: horizontalSizeClass == .compact ? 8 : 16))
                                                            .overlay(
                                                                RoundedRectangle(cornerRadius: horizontalSizeClass == .compact ? 8 : 16)
                                                                    .stroke(.black, lineWidth: horizontalSizeClass == .compact ? 1 : 3)
                                                            )
                                                            .padding(horizontalSizeClass == .compact ? 2 : 10)
                                                            .transition(.asymmetric(insertion: .movingParts.filmExposure, removal: .movingParts.vanish(.purple)))
                                                    } else if !currSheet.currLabelIcon!.isEmpty {
                                                        Image(currSheet.currLabelIcon!)
                                                            .scaledToFit()
                                                            .frame(width: horizontalSizeClass == .compact ? 50 : 100, height: horizontalSizeClass == .compact ? 50 : 100)
                                                            .scaleEffect(horizontalSizeClass == .compact ? 0.125 : 0.25)
                                                            .clipShape(RoundedRectangle(cornerRadius: horizontalSizeClass == .compact ? 8 : 16))
                                                            .overlay(
                                                                RoundedRectangle(cornerRadius: horizontalSizeClass == .compact ? 8 : 16)
                                                                    .stroke(.black, lineWidth: horizontalSizeClass == .compact ? 1 : 3)
                                                            )
                                                            .padding(horizontalSizeClass == .compact ? 2 : 10)
                                                            .transition(.asymmetric(insertion: .movingParts.filmExposure, removal: .movingParts.vanish(.purple)))
                                                    } else {
                                                        Image(systemName: "plus.square.dashed")
                                                            .resizable()
                                                            .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                                            .symbolRenderingMode(.hierarchical)
                                                            .foregroundStyle(Color(.systemGray))
                                                            .padding(horizontalSizeClass == .compact ? 2 : 10)
                                                    }
                                                } else {
                                                    Image(systemName: "plus.square.dashed")
                                                        .resizable()
                                                        .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                                        .symbolRenderingMode(.hierarchical)
                                                        .foregroundStyle(Color(.systemGray))
                                                        .padding(horizontalSizeClass == .compact ? 2 : 10)
                                                }
                                            }
                                            
                                            VStack {
                                                Spacer()
                                                TextField("Name Sheet", text: $currTitleText, onEditingChanged: { editing in
                                                    isTitleTextFieldActive = editing
                                                    animate.toggle()
                                                }, onCommit: {
                                                    currSheet.label = currTitleText
                                                    var newSheetArray = loadSheetArray()
                                                    newSheetArray[currSheetIndex] = currSheet
                                                    newSheetArray[currSheetIndex] = autoRemoveSlots(newSheetArray[currSheetIndex])
                                                    currSheet = newSheetArray[currSheetIndex]
                                                    saveSheetArray(sheetObjects: newSheetArray)
                                                })
                                                .multilineTextAlignment(.center)
                                                .font(.system(size: horizontalSizeClass == .compact ? 50 : 100, weight: .semibold, design: .rounded))
                                                .padding()
                                                .background(
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .fill(Color(.systemGray4))
                                                )
                                                .onChange(of: currTitleText, perform: { _ in
                                                    suggestedWords = updateSuggestedWords(currLabel: currTitleText)
                                                })
                                                .padding(horizontalSizeClass == .compact ? 2 : 10)
                                                
                                                if isTitleTextFieldActive {
                                                    ScrollView(.horizontal, showsIndicators: false) {
                                                        HStack {
                                                            ForEach(suggestedWords.prefix(horizontalSizeClass == .compact ? 10 : 20), id: \.self) { word in
                                                                Button(action: {
                                                                    currTitleText = word
                                                                    animate.toggle()
                                                                }) {
                                                                    Text(word)
                                                                        .font(.headline)
                                                                        .padding()
                                                                        .background(
                                                                            RoundedRectangle(cornerRadius: 10)
                                                                                .fill(Color(.systemGray5))
                                                                        )
                                                                        .foregroundStyle(.purple)
                                                                }
                                                            }
                                                        }
                                                        if suggestedWords.count == 0 {
                                                            Text("filler")
                                                                .font(.headline)
                                                                .padding(2)
                                                                .foregroundStyle(.clear)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    } else {
                                        HStack {
                                            if currSheet.currLabelIcon != nil && !currSheet.currLabelIcon!.isEmpty {
                                                if UIImage(named: currSheet.currLabelIcon!) == nil {
                                                    Image(uiImage: customIconPreviews[currSheet.currLabelIcon!] ?? UIImage(systemName: "square.fill")!)
                                                        .resizable()
                                                        .frame(width: horizontalSizeClass == .compact ? 50 : 100, height: horizontalSizeClass == .compact ? 50 : 100)
                                                        .clipShape(RoundedRectangle(cornerRadius: horizontalSizeClass == .compact ? 8 : 16))
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: horizontalSizeClass == .compact ? 8 : 16)
                                                                .stroke(.black, lineWidth: horizontalSizeClass == .compact ? 1 : 3)
                                                        )
                                                        .padding(horizontalSizeClass == .compact ? 2 : 10)
                                                } else if !currSheet.currLabelIcon!.isEmpty {
                                                    Image(currSheet.currLabelIcon!)
                                                        .scaledToFit()
                                                        .frame(width: horizontalSizeClass == .compact ? 50 : 100, height: horizontalSizeClass == .compact ? 50 : 100)
                                                        .scaleEffect(horizontalSizeClass == .compact ? 0.125 : 0.25)
                                                        .clipShape(RoundedRectangle(cornerRadius: horizontalSizeClass == .compact ? 8 : 16))
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: horizontalSizeClass == .compact ? 8 : 16)
                                                                .stroke(.black, lineWidth: horizontalSizeClass == .compact ? 1 : 3)
                                                        )
                                                        .padding(horizontalSizeClass == .compact ? 2 : 10)
                                                }
                                            }
                                            Text(currSheet.label)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.01)
                                                .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                                                .padding(horizontalSizeClass == .compact ? 2 : 10)
                                        }
                                    }
                                    if horizontalSizeClass == .compact { //this is the main grid for iPhone
                                        ForEach(0..<currSheet.currGrid.count, id: \.self) { list in
                                            VStack {
                                                //show the time or label
                                                if currSheet.gridType == "time" {
                                                    Button(action: {
                                                        if editMode {
                                                            currListIndex = list
                                                            selectedDate = currSheet.currGrid[list].currTime
                                                            showTime.toggle()
                                                        }
                                                    }) {
                                                        if editMode {
                                                            Image(systemName: "square.and.pencil")
                                                                .resizable()
                                                                .minimumScaleFactor(0.01)
                                                                .frame(width: 30, height: 30)
                                                                .foregroundStyle(Color(.systemGray))
                                                                .padding(.trailing)
                                                        }
                                                        
                                                        Text(getTime(date: currSheet.currGrid[list].currTime))
                                                            .lineLimit(1)
                                                            .minimumScaleFactor(0.01)
                                                            .font(.system(size: 30, weight: .bold, design: .rounded))
                                                    }
                                                    .foregroundStyle(.primary)
                                                    .shadow(color: currGreenSlot == list && !editMode && showCurrentSlot ? Color(.systemBackground) : Color.clear, radius: 5)
                                                    .padding()
                                                    .contextMenu {
                                                        if lockButtonsOn && !unlockButtons {
                                                            Button {
                                                                if !canUseBiometrics() && !canUsePassword() {
                                                                    showCustomPassword = true
                                                                } else {
                                                                    Task {
                                                                        unlockButtons = await authenticateWithBiometrics()
                                                                        animate.toggle()
                                                                    }
                                                                    if unlockButtons {
                                                                        Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { timer in
                                                                            unlockButtons = false
                                                                        }
                                                                    }
                                                                }
                                                            } label: {
                                                                Label("Unlock Buttons", systemImage: "lock.open")
                                                            }
                                                        } else {
                                                            Button {
                                                                currListIndex = list
                                                                selectedDate = currSheet.currGrid[list].currTime
                                                                showTime.toggle()
                                                            } label: {
                                                                Label("Edit Time", systemImage: "square.and.pencil")
                                                            }
                                                        }
                                                    }
                                                } else {
                                                    Button(action: {
                                                        if editMode {
                                                            currListIndex = list
                                                            showLabels.toggle()
                                                            currText = currSheet.currGrid[list].currLabel
                                                        }
                                                    }) {
                                                        if editMode {
                                                            Image(systemName: "square.and.pencil")
                                                                .resizable()
                                                                .minimumScaleFactor(0.01)
                                                                .frame(width: 30, height: 30)
                                                                .foregroundStyle(Color(.systemGray))
                                                        }
                                                        
                                                        Text(currSheet.currGrid[list].currLabel)
                                                            .lineLimit(1)
                                                            .minimumScaleFactor(0.01)
                                                            .font(.system(size: 30, weight: .bold, design: .rounded))
                                                    }
                                                    .foregroundStyle(.primary)
                                                    .padding()
                                                    .contextMenu {
                                                        if lockButtonsOn && !unlockButtons {
                                                            Button {
                                                                if !canUseBiometrics() && !canUsePassword() {
                                                                    showCustomPassword = true
                                                                } else {
                                                                    Task {
                                                                        unlockButtons = await authenticateWithBiometrics()
                                                                        animate.toggle()
                                                                    }
                                                                    if unlockButtons {
                                                                        Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { timer in
                                                                            withAnimation(.spring) {
                                                                                unlockButtons = false
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            } label: {
                                                                Label("Unlock Buttons", systemImage: "lock.open")
                                                            }
                                                        } else {
                                                            Button {
                                                                currListIndex = list
                                                                showLabels.toggle()
                                                                currText = currSheet.currGrid[list].currLabel
                                                            } label: {
                                                                Label("Edit Label", systemImage: "square.and.pencil")
                                                            }
                                                        }
                                                    }
                                                }
                                                LazyVGrid(columns: Array(repeating: GridItem(), count: 2)) {
                                                    ForEach(0..<currSheet.currGrid[list].currIcons.count, id: \.self) { slot in //this loop displays the slots/images
                                                        Button(action: {
                                                            if editMode {
                                                                currListIndex = list
                                                                currSlotIndex = slot
                                                                showIcons.toggle()
                                                                searchText = ""
                                                            } else if !currSheet.currGrid[list].currIcons[slot].currIcon.isEmpty {
                                                                currListIndex = list
                                                                currSlotIndex = slot
                                                                 showMod.toggle()
                                                                hapticFeedback()
                                                                tempDetails = []
                                                                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { timer in
                                                                    tempDetails = currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currDetails ?? []
                                                                    checkDetails = currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currDetails ?? []
                                                                    animate.toggle()
                                                                }
                                                                unlockButtons = false
                                                                speechDelegate.stopSpeaking()
                                                                speechDelegate.speak(currSheet.currGrid[list].currIcons[slot].currIcon)
                                                            }
                                                        }) {
                                                            if getCustomPECSAddresses()[currSheet.currGrid[list].currIcons[slot].currIcon] == nil && UIImage(named: currSheet.currGrid[list].currIcons[slot].currIcon) == nil { //if there isnt an icon
                                                                if editMode {
                                                                    Image(systemName: "plus.viewfinder")
                                                                        .resizable()
                                                                        .scaledToFit()
                                                                        .symbolRenderingMode(.hierarchical)
                                                                        .foregroundStyle(editMode ? Color(.systemGray) : .clear)
                                                                }
                                                            } else {
                                                                ZStack {
                                                                    if UIImage(named: currSheet.currGrid[list].currIcons[slot].currIcon) == nil {
                                                                        //check if default icon or custom icon and handle
                                                                        Image(uiImage: customIconPreviews[ currSheet.currGrid[list].currIcons[slot].currIcon] ?? UIImage(systemName: "square.fill")!)
                                                                            .resizable()
                                                                            .scaledToFit()
                                                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                                                            .overlay(
                                                                                RoundedRectangle(cornerRadius: 16)
                                                                                    .stroke(.black, lineWidth: 6)
                                                                            )
                                                                    } else {
                                                                        Image(currSheet.currGrid[list].currIcons[slot].currIcon)
                                                                            .resizable()
                                                                            .scaledToFit()
                                                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                                                            .overlay(
                                                                                RoundedRectangle(cornerRadius: 16)
                                                                                    .stroke(.black, lineWidth: 6)
                                                                            )
                                                                    }
                                                                    VStack {
                                                                        HStack {
                                                                            if (currSheet.currGrid[list].currIcons[slot].currDetails ?? []).count > 0 {
                                                                                Image(systemName: "\((currSheet.currGrid[list].currIcons[slot].currDetails ?? []).count).circle.fill")
                                                                                    .resizable()
                                                                                    .frame(width: horizontalSizeClass == .compact ? 20 : 40, height: horizontalSizeClass == .compact ? 20 : 40)
                                                                                    .foregroundStyle(Color(.systemGray2))
                                                                                    .padding(.trailing, horizontalSizeClass == .compact ? 5 : 10)
                                                                                    .padding(.bottom, horizontalSizeClass == .compact ? 5 : 10)
                                                                            }
                                                                            Spacer()
                                                                        }
                                                                        Spacer()
                                                                    }
                                                                }
                                                                .transition(.asymmetric(insertion: .movingParts.filmExposure, removal: .movingParts.vanish(.purple)))
                                                            }
                                                        }
                                                        .contextMenu {
                                                            if lockButtonsOn && !unlockButtons {
                                                                Button {
                                                                    if !canUseBiometrics() && !canUsePassword() {
                                                                        showCustomPassword = true
                                                                    } else {
                                                                        Task {
                                                                            unlockButtons = await authenticateWithBiometrics()
                                                                            animate.toggle()
                                                                        }
                                                                        if unlockButtons {
                                                                            Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { timer in
                                                                                withAnimation(.spring) {
                                                                                    unlockButtons = false
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                } label: {
                                                                    Label("Unlock Buttons", systemImage: "lock.open")
                                                                }
                                                            } else {
                                                                if currSheet.currGrid[list].currIcons[slot].currIcon.isEmpty {
                                                                    Button {
                                                                        currListIndex = list
                                                                        currSlotIndex = slot
                                                                        showIcons.toggle()
                                                                        searchText = ""
                                                                    } label: {
                                                                        Label("Add Icon", systemImage: "plus.viewfinder")
                                                                    }
                                                                } else {
                                                                    
                                                                    Button {
                                                                        currListIndex = list
                                                                        currSlotIndex = slot
                                                                        showIcons.toggle()
                                                                        searchText = ""
                                                                    } label: {
                                                                        Label("Change Icon", systemImage: "arrow.2.squarepath")
                                                                    }
                                                                    
                                                                    Button {
                                                                        tempDetails = [""] //hacky fix instead of binding, fixes not updating
                                                                        animate.toggle()
                                                                        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { timer in
                                                                            tempDetails = currSheet.currGrid[list].currIcons[slot].currDetails ?? []
                                                                            checkDetails = currSheet.currGrid[list].currIcons[slot].currDetails ?? []
                                                                        }
                                                                        currListIndex = list
                                                                        currSlotIndex = slot
                                                                        if !editMode {editMode.toggle()} else {wasEditing.toggle()}
                                                                        showMod.toggle()
                                                                    } label: {
                                                                        Label("Add Details", systemImage: "plus.square.on.square")
                                                                    }
                                                                    
                                                                    Divider()
                                                                    
                                                                    if editMode {
                                                                        Button(role: .destructive) {
                                                                            currSheet.currGrid[list].currIcons[slot].currIcon = ""
                                                                            currSheet.currGrid[list].currIcons[slot].currDetails = []
                                                                            animate.toggle()
                                                                        } label: {
                                                                            Label("Delete Icon", systemImage: "trash")
                                                                        }
                                                                    } else {
                                                                        Button {
                                                                            unlockButtons = false
                                                                            currSheet.removedIcons.append(currSheet.currGrid[list].currIcons[slot])
                                                                            currSheet.currGrid[list].currIcons[slot].currIcon = ""
                                                                            currSheet.currGrid[list].currIcons[slot].currDetails = []
                                                                            var newArray = loadSheetArray()
                                                                            newArray[currSheetIndex] = currSheet
                                                                            newArray[currSheetIndex] = autoRemoveSlots(newArray[currSheetIndex])
                                                                            currSheet = newArray[currSheetIndex]
                                                                            saveSheetArray(sheetObjects: newArray)
                                                                            animate.toggle()
                                                                            if removedSelectedLabel == "All Sheets" {
                                                                                removedSelected = getAllRemoved()
                                                                            } else {
                                                                                removedSelected = getAllRemoved()
                                                                                currSheet = loadSheetArray()[currSheetIndex]
                                                                                
                                                                                removedSelected = currSheet.removedIcons
                                                                            }
                                                                            hapticFeedback(type: 1)
                                                                        } label: {
                                                                            Label("Remove Icon", systemImage: "square.slash")
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                        .padding()
                                                        //                                                        .dropDestination(for: Data.self) { items, location in
                                                        //                                                            guard let item = items.first else {
                                                        //                                                                return false
                                                        //                                                            }
                                                        //
                                                        //                                                            guard let uiImage = UIImage(data: item) else {
                                                        //                                                                return false
                                                        //                                                            }
                                                        //
                                                        //                                                            // Extract text from the image
                                                        //                                                            let labelText = labelImage(input: uiImage)
                                                        //                                                            let labelTextComponents = labelText.components(separatedBy: ", ")
                                                        //                                                            guard let currCustomIconText = labelTextComponents.first else {
                                                        //                                                                return false
                                                        //                                                            }
                                                        //
                                                        //                                                            // Get custom addresses dictionary
                                                        //                                                            var customPECSAddresses = getCustomPECSAddresses()
                                                        //
                                                        //                                                            var iconText = currCustomIconText
                                                        //                                                            if customPECSAddresses[iconText] != nil || allPECS.contains(iconText) {
                                                        //                                                                var i = 1
                                                        //                                                                while customPECSAddresses["\(i)#id\(iconText)"] != nil || allPECS.contains("\(i)#id\(iconText)") {
                                                        //                                                                    i += 1
                                                        //                                                                }
                                                        //                                                                iconText = "\(i)#id\(iconText)"
                                                        //                                                            }
                                                        //
                                                        //                                                            // Save the image and update the dictionary
                                                        //                                                            let savedPath = saveImageToDocumentsDirectory(uiImage)
                                                        //                                                            customPECSAddresses[iconText] = savedPath
                                                        //                                                            saveCustomPECSAddresses(customPECSAddresses)
                                                        //
                                                        //                                                            currSheet.currGrid[list].currIcons[slot].currIcon = iconText
                                                        //                                                            var newSheetArray = loadSheetArray()
                                                        //                                                            newSheetArray[currSheetIndex] = currSheet
                                                        //                                                            currSheet = newSheetArray[currSheetIndex]
                                                        //                                                            saveSheetArray(sheetObjects: newSheetArray)
                                                        //                                                            Task {
                                                        //                                                                do {
                                                        //                                                                    customIconPreviews = await getCustomIconPreviews()
                                                        //                                                                }
                                                        //                                                            }
                                                        //                                                            animate.toggle()
                                                        //                                                            return true
                                                        //                                                        }
                                                    }
                                                }
                                                if editMode {
                                                    Button(action: {
                                                        //if you spam click delete on the last row on iPad, it will try to delete through the animation which results in a crash from attempting to delete an index that doesnt exist. This is just a hacky fix that doesnt let you delete things less than one second apart (which shouldnt be an issue anyways)
                                                        if !deleteAnimationFix {
                                                            deleteAnimationFix = true
                                                            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
                                                                deleteAnimationFix = false
                                                            }
                                                            
                                                            withAnimation(.spring) {
                                                                if currSheet.currGrid.count > 1 {
                                                                    animate.toggle()
                                                                    currSheet.currGrid.remove(at: list)
                                                                } else {
                                                                    currSheet.currGrid.removeAll()
                                                                    currSheet.currGrid.append(GridSlot(currLabel: currSheet.gridType))
                                                                }
                                                            }
                                                        }
                                                        //save array aka "autosave"
                                                        var newSheetArray = loadSheetArray()
                                                        newSheetArray[currSheetIndex] = currSheet
                                                        currSheet = newSheetArray[currSheetIndex]
                                                        saveSheetArray(sheetObjects: newSheetArray)
                                                        
                                                    }) {
                                                        Image(systemName: "trash.square.fill")
                                                            .resizable()
                                                            .frame(width: 75, height: 75)
                                                            .padding()
                                                            .symbolRenderingMode(.hierarchical)
                                                            .foregroundStyle(.red)
                                                    }
                                                    .padding(.leading)
                                                }
                                            }
                                            .background(currGreenSlot == list && !editMode && showCurrentSlot ? .green : Color(.systemGray6))
                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                            .padding()
                                            
                                        }
                                    } else { //this is the main grid for iPad
                                        ZStack { //this is the left hand rectangle behind the labels
                                            GeometryReader { geometry in
                                                RoundedRectangle(cornerRadius: 20)
                                                    .frame(width: editMode ? (geometry.size.width / 6) - 7 : (geometry.size.width / 5) - 7, height: geometry.size.height)
                                                    .foregroundStyle(Color(.systemGray4))
                                            }
                                            VStack {
                                                LazyVGrid(columns: Array(repeating: GridItem(), count: editMode ? 6 : 5)) { //this is the main grid for the app
                                                    ForEach(0..<currSheet.currGrid.count, id: \.self) { list in
                                                        if currSheet.gridType == "time" {
                                                            ZStack {
                                                                RoundedRectangle(cornerRadius: 20)
                                                                    .foregroundStyle(currGreenSlot == list && !editMode && showCurrentSlot ? .green : .clear)
                                                                    .scaledToFill()
                                                                Button(action: {
                                                                    if editMode {
                                                                        currListIndex = list
                                                                        selectedDate = currSheet.currGrid[list].currTime
                                                                        showTime.toggle()
                                                                    }
                                                                }) {
                                                                    HStack {
                                                                        if editMode {
                                                                            Image(systemName: "square.and.pencil")
                                                                                .resizable()
                                                                                .minimumScaleFactor(0.01)
                                                                                .frame(width: 30, height: 30)
                                                                                .foregroundStyle(Color(.systemGray))
                                                                        }
                                                                        
                                                                        Text(getTime(date: currSheet.currGrid[list].currTime))
                                                                            .lineLimit(1)
                                                                            .minimumScaleFactor(0.01)
                                                                            .font(.system(size: 100, weight: .bold, design: .rounded))
                                                                    }
                                                                }
                                                                .foregroundStyle(.primary)
                                                                .shadow(color: currGreenSlot == list && !editMode && showCurrentSlot ? Color(.systemBackground) : Color.clear, radius: 5)
                                                                .padding(horizontalSizeClass == .compact ? 3 : 10)
                                                                .contextMenu {
                                                                    if lockButtonsOn && !unlockButtons {
                                                                        Button {
                                                                            if !canUseBiometrics() && !canUsePassword() {
                                                                                showCustomPassword = true
                                                                            } else {
                                                                                Task {
                                                                                    unlockButtons = await authenticateWithBiometrics()
                                                                                    animate.toggle()
                                                                                }
                                                                                if unlockButtons {
                                                                                    Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { timer in
                                                                                        withAnimation(.spring) {
                                                                                            unlockButtons = false
                                                                                        }
                                                                                    }
                                                                                }
                                                                            }
                                                                        } label: {
                                                                            Label("Unlock Buttons", systemImage: "lock.open")
                                                                        }
                                                                    } else {
                                                                        Button {
                                                                            currListIndex = list
                                                                            selectedDate = currSheet.currGrid[list].currTime
                                                                            showTime.toggle()
                                                                        } label: {
                                                                            Label("Edit Time", systemImage: "square.and.pencil")
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        } else {
                                                            ZStack {
                                                                RoundedRectangle(cornerRadius: 20)
                                                                    .foregroundStyle(currGreenSlot == list && !editMode && showCurrentSlot ? .green : .clear)
                                                                    .scaledToFill()
                                                                Button(action: {
                                                                    if editMode {
                                                                        currListIndex = list
                                                                        showLabels.toggle()
                                                                        currText = currSheet.currGrid[list].currLabel
                                                                    }
                                                                }) {
                                                                    HStack {
                                                                        if editMode {
                                                                            Image(systemName: "square.and.pencil")
                                                                                .resizable()
                                                                                .minimumScaleFactor(0.01)
                                                                                .frame(width: 30, height: 30)
                                                                                .foregroundStyle(Color(.systemGray))
                                                                        }
                                                                        
                                                                        Text(currSheet.currGrid[list].currLabel)
                                                                            .lineLimit(1)
                                                                            .minimumScaleFactor(0.01)
                                                                            .font(.system(size: 100, weight: .bold, design: .rounded))
                                                                    }
                                                                }
                                                                .foregroundStyle(.primary)
                                                                .shadow(color: currGreenSlot == list && !editMode && showCurrentSlot ? Color(.systemBackground) : Color.clear, radius: 5)
                                                                .padding(horizontalSizeClass == .compact ? 3 : 10)
                                                                .contextMenu {
                                                                    if lockButtonsOn && !unlockButtons {
                                                                        Button {
                                                                            if !canUseBiometrics() && !canUsePassword() {
                                                                                showCustomPassword = true
                                                                            } else {
                                                                                Task {
                                                                                    unlockButtons = await authenticateWithBiometrics()
                                                                                    animate.toggle()
                                                                                }
                                                                                if unlockButtons {
                                                                                    Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { timer in
                                                                                        unlockButtons = false
                                                                                    }
                                                                                }
                                                                            }
                                                                        } label: {
                                                                            Label("Unlock Buttons", systemImage: "lock.open")
                                                                        }
                                                                    } else {
                                                                        Button {
                                                                            currListIndex = list
                                                                            showLabels.toggle()
                                                                            currText = currSheet.currGrid[list].currLabel
                                                                        } label: {
                                                                            Label("Edit Label", systemImage: "square.and.pencil")
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                        ForEach(0..<currSheet.currGrid[list].currIcons.count, id: \.self) { slot in //this loop displays the slots/images
                                                            Button(action: {
                                                                if editMode {
                                                                    currListIndex = list
                                                                    currSlotIndex = slot
                                                                    showIcons.toggle()
                                                                    searchText = ""
                                                                } else if !currSheet.currGrid[list].currIcons[slot].currIcon.isEmpty {
                                                                    currListIndex = list
                                                                    currSlotIndex = slot
                                                                    showMod.toggle()
                                                                    tempDetails = []
                                                                    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { timer in
                                                                        tempDetails = currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currDetails ?? []
                                                                        checkDetails = currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currDetails ?? []
                                                                        animate.toggle()
                                                                    }
                                                                    unlockButtons = false
                                                                    speechDelegate.stopSpeaking()
                                                                    speechDelegate.speak(currSheet.currGrid[list].currIcons[slot].currIcon)
                                                                }
                                                            }) {
                                                                if currSheet.currGrid[list].currIcons[slot].currIcon.isEmpty { //if there isnt an icon
                                                                    if editMode {
                                                                        Image(systemName: "plus.viewfinder")
                                                                            .resizable()
                                                                            .scaledToFit()
                                                                            .padding(10)
                                                                            .symbolRenderingMode(.hierarchical)
                                                                            .foregroundStyle(editMode ? Color(.systemGray) : .clear)
                                                                    }
                                                                } else {
                                                                    ZStack {
                                                                        if UIImage(named: currSheet.currGrid[list].currIcons[slot].currIcon) == nil {
                                                                            //check if default icon or custom icon and handle
                                                                            Image(uiImage: customIconPreviews[currSheet.currGrid[list].currIcons[slot].currIcon] ?? UIImage(systemName: "square.fill")!)
                                                                                .resizable()
                                                                                .scaledToFit()
                                                                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                                                                .overlay(
                                                                                    RoundedRectangle(cornerRadius: 16)
                                                                                        .stroke(currGreenSlot == list && !editMode && showCurrentSlot ? .green : .black, lineWidth: currGreenSlot == list && showCurrentSlot ? 10 : 6)
                                                                                )
                                                                                .padding(horizontalSizeClass == .compact ? 0 : 5)
                                                                        } else {
                                                                            Image(currSheet.currGrid[list].currIcons[slot].currIcon)
                                                                                .resizable()
                                                                                .scaledToFit()
                                                                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                                                                .overlay(
                                                                                    RoundedRectangle(cornerRadius: 16)
                                                                                        .stroke(currGreenSlot == list && !editMode && showCurrentSlot ? .green : .black, lineWidth: currGreenSlot == list && showCurrentSlot ? 10 : 6)
                                                                                )
                                                                                .padding(horizontalSizeClass == .compact ? 0 : 5)
                                                                        }
                                                                        VStack {
                                                                            HStack {
                                                                                if (currSheet.currGrid[list].currIcons[slot].currDetails ?? []).count > 0 {
                                                                                    Image(systemName: "\((currSheet.currGrid[list].currIcons[slot].currDetails ?? []).count).circle.fill")
                                                                                        .resizable()
                                                                                        .frame(width: horizontalSizeClass == .compact ? 20 : 40, height: horizontalSizeClass == .compact ? 20 : 40)
                                                                                        .foregroundStyle(Color(.systemGray2))
                                                                                        .padding(.trailing, horizontalSizeClass == .compact ? 5 : 10)
                                                                                        .padding(.bottom, horizontalSizeClass == .compact ? 5 : 10)
                                                                                }
                                                                                Spacer()
                                                                            }
                                                                            Spacer()
                                                                        }
                                                                    }
                                                                    .transition(.asymmetric(insertion: .movingParts.filmExposure, removal: .movingParts.vanish(.purple)))
                                                                }
                                                            }
                                                            //                                                        .draggable(account for custom icons too)
                                                            .contextMenu {
                                                                if lockButtonsOn && !unlockButtons {
                                                                    Button {
                                                                        if !canUseBiometrics() && !canUsePassword() {
                                                                            showCustomPassword = true
                                                                        } else {
                                                                            Task {
                                                                                unlockButtons = await authenticateWithBiometrics()
                                                                                animate.toggle()
                                                                            }
                                                                            if unlockButtons {
                                                                                Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { timer in
                                                                                    withAnimation(.spring) {
                                                                                        unlockButtons = false
                                                                                    }
                                                                                }
                                                                            }
                                                                        }
                                                                    } label: {
                                                                        Label("Unlock Buttons", systemImage: "lock.open")
                                                                    }
                                                                } else {
                                                                    if currSheet.currGrid[list].currIcons[slot].currIcon.isEmpty {
                                                                        Button {
                                                                            currListIndex = list
                                                                            currSlotIndex = slot
                                                                            showIcons.toggle()
                                                                            searchText = ""
                                                                        } label: {
                                                                            Label("Add Icon", systemImage: "plus.viewfinder")
                                                                        }
                                                                    } else {
                                                                        
                                                                        Button {
                                                                            currListIndex = list
                                                                            currSlotIndex = slot
                                                                            showIcons.toggle()
                                                                            searchText = ""
                                                                        } label: {
                                                                            Label("Change Icon", systemImage: "arrow.2.squarepath")
                                                                        }
                                                                        
                                                                        Button {
                                                                            tempDetails = [""] //hacky fix instead of binding, fixes not updating
                                                                            animate.toggle()
                                                                            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { timer in
                                                                                tempDetails = currSheet.currGrid[list].currIcons[slot].currDetails ?? []
                                                                                checkDetails = currSheet.currGrid[list].currIcons[slot].currDetails ?? []
                                                                            }
                                                                            currListIndex = list
                                                                            currSlotIndex = slot
                                                                            if !editMode {editMode.toggle()} else {wasEditing.toggle()}
                                                                            showMod.toggle()
                                                                        } label: {
                                                                            Label("Add Details", systemImage: "plus.square.on.square")
                                                                        }
                                                                        
                                                                        Divider()
                                                                        
                                                                        if editMode {
                                                                            Button(role: .destructive) {
                                                                                currSheet.currGrid[list].currIcons[slot].currIcon = ""
                                                                                currSheet.currGrid[list].currIcons[slot].currDetails = []
                                                                                animate.toggle()
                                                                            } label: {
                                                                                Label("Delete Icon", systemImage: "trash")
                                                                            }
                                                                        } else {
                                                                            Button {
                                                                                unlockButtons = false
                                                                                currSheet.removedIcons.append(currSheet.currGrid[list].currIcons[slot])
                                                                                currSheet.currGrid[list].currIcons[slot].currIcon = ""
                                                                                currSheet.currGrid[list].currIcons[slot].currDetails = []
                                                                                var newArray = loadSheetArray()
                                                                                newArray[currSheetIndex] = currSheet
                                                                                newArray[currSheetIndex] = autoRemoveSlots(newArray[currSheetIndex])
                                                                                currSheet = newArray[currSheetIndex]
                                                                                saveSheetArray(sheetObjects: newArray)
                                                                                animate.toggle()
                                                                                if removedSelectedLabel == "All Sheets" {
                                                                                    removedSelected = getAllRemoved()
                                                                                } else {
                                                                                    removedSelected = getAllRemoved()
                                                                                    currSheet = loadSheetArray()[currSheetIndex]
                                                                                    
                                                                                    removedSelected = currSheet.removedIcons
                                                                                }
                                                                                hapticFeedback(type: 1)
                                                                            } label: {
                                                                                Label("Remove Icon", systemImage: "square.slash")
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                            //                                                            .dropDestination(for: Data.self) { items, location in
                                                            //                                                                guard let item = items.first else {
                                                            //                                                                    return false
                                                            //                                                                }
                                                            //
                                                            //                                                                guard let uiImage = UIImage(data: item) else {
                                                            //                                                                    return false
                                                            //                                                                }
                                                            //
                                                            //                                                                // Extract text from the image
                                                            //                                                                let labelText = labelImage(input: uiImage)
                                                            //                                                                let labelTextComponents = labelText.components(separatedBy: ", ")
                                                            //                                                                guard let currCustomIconText = labelTextComponents.first else {
                                                            //                                                                    return false
                                                            //                                                                }
                                                            //
                                                            //                                                                // Get custom addresses dictionary
                                                            //                                                                var customPECSAddresses = getCustomPECSAddresses()
                                                            //
                                                            //                                                                var iconText = currCustomIconText
                                                            //                                                                if customPECSAddresses[iconText] != nil {
                                                            //                                                                    var i = 1
                                                            //                                                                    while customPECSAddresses["\(i)#id\(iconText)"] != nil {
                                                            //                                                                        i += 1
                                                            //                                                                    }
                                                            //                                                                    iconText = "\(i)#id\(iconText)"
                                                            //                                                                }
                                                            //
                                                            //                                                                // Save the image and update the dictionary
                                                            //                                                                let savedPath = saveImageToDocumentsDirectory(uiImage)
                                                            //                                                                customPECSAddresses[iconText] = savedPath
                                                            //                                                                saveCustomPECSAddresses(customPECSAddresses)
                                                            //
                                                            //                                                                currSheet.currGrid[list].currIcons[slot].currIcon = iconText
                                                            //                                                                var newSheetArray = loadSheetArray()
                                                            //                                                                newSheetArray[currSheetIndex] = currSheet
                                                            //                                                                currSheet = newSheetArray[currSheetIndex]
                                                            //                                                                saveSheetArray(sheetObjects: newSheetArray)
                                                            //                                                                Task {
                                                            //                                                                    do {
                                                            //                                                                        customIconPreviews = await getCustomIconPreviews()
                                                            //                                                                    }
                                                            //                                                                }
                                                            //                                                                animate.toggle()
                                                            //                                                                return true
                                                            //                                                            }
                                                            
                                                        }
                                                        if editMode {
                                                            Button(action: {
                                                                if !deleteAnimationFix {
                                                                    
                                                                    deleteAnimationFix = true //if you spam click delete on the last row on iPad, it will try to delete through the animation which results in a crash from attempting to delete an index that doesnt exist. This is just a hacky fix that doesnt let you delete things less than one second apart (which shouldnt be an issue anyways)
                                                                    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
                                                                        deleteAnimationFix = false
                                                                    }
                                                                    
                                                                    withAnimation(.spring) {
                                                                        if currSheet.currGrid.count > 1 {
                                                                            animate.toggle()
                                                                            currSheet.currGrid.remove(at: list)
                                                                        } else {
                                                                            currSheet.currGrid.removeAll()
                                                                            currSheet.currGrid.append(GridSlot(currLabel: currSheet.gridType))
                                                                        }
                                                                    }
                                                                    //save array aka "autosave"
                                                                    var newSheetArray = loadSheetArray()
                                                                    newSheetArray[currSheetIndex] = currSheet
                                                                    currSheet = newSheetArray[currSheetIndex]
                                                                    saveSheetArray(sheetObjects: newSheetArray)
                                                                }
                                                            }) {
                                                                Image(systemName: "trash.square.fill")
                                                                    .resizable()
                                                                    .scaledToFit()
                                                                    .padding()
                                                                    .symbolRenderingMode(.hierarchical)
                                                                    .foregroundStyle(.red)
                                                            }
                                                            .padding()
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                if editMode { //show the plus under the main grid while in edit mode
                                    Button(action: {
                                        withAnimation(.spring) {
                                            currSheet.currGrid.append(GridSlot(currLabel: currSheet.currGrid.count < 1 ? "First" : "Then"))
                                        }
                                        //save array aka "autosave"
                                        var newSheetArray = loadSheetArray()
                                        newSheetArray[currSheetIndex] = currSheet
                                        currSheet = newSheetArray[currSheetIndex]
                                        saveSheetArray(sheetObjects: newSheetArray)
                                    }) {
                                        Image(systemName:"plus.square.fill")
                                            .resizable()
                                            .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                        
                                            .foregroundStyle(.green)
                                            .padding()
                                    }
                                }
                                Rectangle() //this was originally when plus and minus were in bottom row, you can id this rectangle and use it to scroll to button
                                    .foregroundStyle(.clear)
                                    .navigationBarHidden(true)
                                    .frame(width: 1, height: 1)
                                    .padding(.bottom, 150)
                            }
                        }
                        .navigationViewStyle(StackNavigationViewStyle())
                        .navigationBarHidden(true)
                        .onAppear{ //have to use timer because of a bug in NavigationView on ios 15 and older, displays too fast
                            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { timer in
                                if currSheet.label == "Debug, ignore this page" || loadSheetArray().count < 2 {
                                    showAllSheets = true
                                    withAnimation(.spring) {
                                        createNewSheet = true
                                    }
                                }
                            }
                            updateUsage("action:open")
                            if showCurrentSlot {
                                let currentDate = Date()
                                let secondsUntilNextMinute = 60 - Calendar.current.component(.second, from: currentDate)
                                let delayInSeconds = TimeInterval(secondsUntilNextMinute)
                                
                                Timer.scheduledTimer(withTimeInterval: delayInSeconds, repeats: true) { _ in
                                    currGreenSlot = loadSheetArray()[currSheetIndex].getCurrSlot()
                                    animate.toggle()
                                }
                            }
                            if !defaults.bool(forKey: "communicationUpdate") { //something in here straight up deletes all the custom icons? not from usage or sheet label icon though
                                defaults.set(true, forKey: "speakOn")
                                defaults.set(true, forKey: "aiOn")
                                emptyIconFix()
                                currSheet = removePlusViewfinders()
                                currSheet = migrateRemoved()
                                removedSelected = getAllRemoved()
                                currCommunicationBoard = loadCommunicationBoard()
                                currSheet = removePrefixesFix()[currSheetIndex]
                                defaults.set(true, forKey: "communicationUpdate")
                            }
                        }
                        //end of the main grid
                    }
                    //bottom row here
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            if horizontalSizeClass == .compact { //bottom row of buttons for iPhone
                                if editMode { //show the bottom row of buttons for edit mode
                                    HStack {
                                        Button(action: {
                                            if sheetArray.count > 1 {
                                                presentAlert.toggle()
                                            }
                                        }) {
                                            Image(systemName:"trash.square.fill")
                                                .resizable()
                                                .frame(width: 75, height: 75)
                                            
                                                .foregroundStyle(.red)
                                                .padding()
                                        }
                                        
                                        Button(action: { //saves the array and disables edit mode
                                            if currSheet.gridType == "time" {
                                                currSheet.currGrid = sortSheet(currSheet.currGrid)
                                            }
                                            currSheet.label = currTitleText
                                            var newSheetArray = loadSheetArray()
                                            newSheetArray[currSheetIndex] = currSheet
                                            newSheetArray[currSheetIndex] = autoRemoveSlots(newSheetArray[currSheetIndex])
                                            currSheet = newSheetArray[currSheetIndex]
                                            saveSheetArray(sheetObjects: newSheetArray)
                                            animate.toggle()
                                            manageNotifications()
                                            editMode.toggle()
                                        }) {
                                            Image(systemName:"checkmark.square.fill")
                                                .resizable()
                                                .frame(width: 75, height: 75)
                                                .foregroundStyle(.green)
                                                .padding()
                                            //}
                                        }
                                    }
                                } else { //show the non edit mode buttons at the bottom
                                    if lockButtonsOn && !unlockButtons { //but dont show the buttons if lock buttons is on
                                        Button(action: {
                                            if !canUseBiometrics() && !canUsePassword() {
                                                showCustomPassword = true
                                            } else {
                                                Task {
                                                    unlockButtons = await authenticateWithBiometrics()
                                                    animate.toggle()
                                                }
                                                if unlockButtons {
                                                    Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { timer in
                                                        withAnimation(.spring) {
                                                            unlockButtons = false
                                                        }
                                                    }
                                                }
                                            }
                                        }) {
                                            Image(systemName: "lock.square")
                                                .resizable()
                                                .padding()
                                                .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                                .foregroundStyle(Color(.systemGray))
                                        }
                                        .padding()
                                    } else {
                                        VStack {
                                            HStack {
                                                Button(action: {
                                                    showCommunication.toggle()
                                                    animate.toggle()
                                                    unlockButtons = false
                                                    //                                                    defaults.set(true, forKey: "communicationDefaultMode")
                                                    speechDelegate.stopSpeaking()
                                                }) {
                                                    VStack {
                                                        ZStack {
                                                            Image(systemName: "square.fill")
                                                                .resizable()
                                                                .frame(width: 65, height: 65)
                                                                .foregroundStyle(.orange)
                                                            Image(systemName: "hand.tap")
                                                                .resizable()
                                                                .frame(width: min(30, 75), height: min(35, 85))
                                                                .foregroundStyle(Color(.systemBackground))
                                                                .symbolRenderingMode(.hierarchical)
                                                        }
                                                        Text("Board")
                                                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                                                            .foregroundStyle(.orange)
                                                    }
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                                .padding([.leading, .trailing])
                                                
                                                Button(action: {
                                                    if sheetArray.count > 1 {
                                                        editMode.toggle()
                                                        currTitleText = currSheet.label
                                                        animate.toggle()
                                                    }
                                                    unlockButtons = false
                                                    speechDelegate.stopSpeaking()
                                                }) {
                                                    VStack {
                                                        ZStack {
                                                            Image(systemName: "square.fill")
                                                                .resizable()
                                                                .frame(width: 65, height: 65)
                                                                .foregroundStyle(.blue)
                                                            Image(systemName: "pencil")
                                                                .resizable()
                                                                .frame(width: min(30, 75), height: min(30, 75))
                                                            //.fontWeight(.heavy)
                                                                .foregroundStyle(Color(.systemBackground))
                                                        }
                                                        Text("Edit")
                                                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                                                            .foregroundStyle(.blue)
                                                    }
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                                .padding()
                                                
                                                Button(action: {
                                                    showMore.toggle()
                                                    animate.toggle()
                                                }) {
                                                    VStack {
                                                        ZStack {
                                                            Image(systemName: "square")
                                                                .resizable()
                                                                .frame(width: 65, height: 65)
                                                            Image(systemName: "chevron.forward")
                                                                .resizable()
                                                            //                                                .frame(width: 25, height: 50)
                                                                .frame(width: 20, height: 40)
                                                                .rotationEffect(showMore ? .degrees(90) : .degrees(-90))
                                                        }
                                                        Text(showMore ? "Less" : "More")
                                                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                                                    }
                                                }
                                                .foregroundStyle(Color(.systemGray2))
                                                .buttonStyle(PlainButtonStyle())
                                                .padding(.leading)
                                                .padding(.trailing)
                                                
                                            }
                                            if showMore {
                                                HStack {
                                                    Button(action: {
                                                        showAllSheets.toggle()
                                                        sheetArray = loadSheetArray()
                                                        unlockButtons = false
                                                    }) {
                                                        VStack {
                                                            ZStack {
                                                                Image(systemName: "square.fill")
                                                                    .resizable()
                                                                    .frame(width: 65, height: 65)
                                                                    .foregroundStyle(.purple)
                                                                Image(systemName: "square.grid.2x2")
                                                                    .resizable()
                                                                    .frame(width: min(30, 75), height: min(30, 75))
                                                                    .foregroundStyle(Color(.systemBackground))
                                                            }
                                                            Text("All Sheets")
                                                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                                                .foregroundStyle(.purple)
                                                        }
                                                    }
                                                    .buttonStyle(PlainButtonStyle())
                                                    .padding(.leading)
                                                    
                                                    Button(action: {
                                                        showRemoved.toggle()
                                                        unlockButtons = false
                                                        speechDelegate.stopSpeaking()
                                                    }) {
                                                        VStack {
                                                            ZStack {
                                                                Image(systemName: "square.fill")
                                                                    .resizable()
                                                                    .frame(width: 65, height: 65)
                                                                    .foregroundStyle(.pink)
                                                                Image(systemName: "square.slash")
                                                                    .resizable()
                                                                    .frame(width: min(30, 75), height: min(30, 75))
                                                                    .foregroundStyle(Color(.systemBackground))
                                                                    .symbolRenderingMode(.hierarchical)
                                                            }
                                                            Text("Removed")
                                                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                                                .foregroundStyle(.pink)
                                                        }
                                                    }
                                                    .buttonStyle(PlainButtonStyle())
                                                    .padding([.leading, .trailing])
                                                    
                                                    Button(action: {
                                                        showSettings.toggle()
                                                        speechDelegate.stopSpeaking()
                                                    }) {
                                                        VStack {
                                                            ZStack {
                                                                Image(systemName: "square.fill")
                                                                    .resizable()
                                                                    .frame(width: 65, height: 65)
                                                                    .foregroundStyle(Color(.systemGray))
                                                                Image(systemName: "gear")
                                                                    .resizable()
                                                                    .frame(width: min(30, 75), height: min(30, 75))
                                                                    .foregroundStyle(Color(.systemBackground))
                                                            }
                                                            Text("Settings")
                                                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                                                .foregroundStyle(Color(.systemGray))
                                                        }
                                                    }
                                                    .buttonStyle(PlainButtonStyle())
                                                    .padding([.leading, .trailing])
                                                }
                                            }
                                        }
                                    }
                                }
                            } else { //bottom row o buttons for iPad
                                if editMode { //show the bottom row of buttons for edit mode
                                    HStack {
                                        Button(action: {
                                            if sheetArray.count > 1 {
                                                presentAlert.toggle()
                                            }
                                        }) {
                                            Image(systemName:"trash.square.fill")
                                                .resizable()
                                                .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                            
                                                .foregroundStyle(.red)
                                                .padding()
                                        }
                                        
                                        Button(action: { //saves the array and disables edit mode
                                            if currSheet.gridType == "time" {
                                                currSheet.currGrid = sortSheet(currSheet.currGrid)
                                            }
                                            currSheet.label = currTitleText
                                            var newSheetArray = loadSheetArray()
                                            newSheetArray[currSheetIndex] = currSheet
                                            newSheetArray[currSheetIndex] = autoRemoveSlots(newSheetArray[currSheetIndex])
                                            currSheet = newSheetArray[currSheetIndex]
                                            saveSheetArray(sheetObjects: newSheetArray)
                                            animate.toggle()
                                            manageNotifications()
                                            editMode.toggle()
                                            
                                        }) { //sheetobject isnt equatable rn, this is the desired behavior:
                                            /*
                                             if currSheet == loadSheetArray()[currSheetIndex] {
                                             Image(systemName:"xmark.square.fill")
                                             .resizable()
                                             .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                             .foregroundStyle(Color(.systemGray))
                                             .padding()
                                             } else { */
                                            Image(systemName:"checkmark.square.fill")
                                                .resizable()
                                                .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                                .foregroundStyle(.green)
                                                .padding()
                                            //}
                                        }
                                    }
                                } else { //show the non edit mode buttons at the bottom
                                    if lockButtonsOn && !unlockButtons { //but dont show the buttons if lock buttons is on
                                        Button(action: { //problem is in this button
                                            if !canUseBiometrics() && !canUsePassword() {
                                                showCustomPassword = true
                                            } else {
                                                Task {
                                                    unlockButtons = await authenticateWithBiometrics()
                                                    animate.toggle()
                                                }
                                                if unlockButtons {
                                                    Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { timer in
                                                        withAnimation(.spring) {
                                                            unlockButtons = false
                                                        }
                                                    }
                                                }
                                            }
                                        }) {
                                            Image(systemName: "lock.square")
                                                .resizable()
                                                .padding()
                                                .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                                .foregroundStyle(Color(.systemGray))
                                        }
                                        .padding()
                                    } else {
                                        HStack {
                                            
                                            Button(action: {
                                                showCommunication.toggle()
                                                animate.toggle()
                                                unlockButtons = false
                                                //                                                defaults.set(true, forKey: "communicationDefaultMode")
                                                speechDelegate.stopSpeaking()
                                            }) {
                                                VStack {
                                                    ZStack {
                                                        Image(systemName: "square.fill")
                                                            .resizable()
                                                            .frame(width: 75, height: 75)
                                                            .foregroundStyle(.orange)
                                                        Image(systemName: "hand.tap")
                                                            .resizable()
                                                            .frame(width: min(42, 104), height: min(48, 118))
                                                            .foregroundStyle(Color(.systemBackground))
                                                            .symbolRenderingMode(.hierarchical)
                                                    }
                                                    Text("Board")
                                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                                        .foregroundStyle(.orange)
                                                }
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            .padding()
                                            
                                            
                                            Button(action: {
                                                showRemoved.toggle()
                                                unlockButtons = false
                                                speechDelegate.stopSpeaking()
                                            }) {
                                                VStack {
                                                    ZStack {
                                                        Image(systemName: "square.fill")
                                                            .resizable()
                                                            .frame(width: 75, height: 75)
                                                            .foregroundStyle(.pink)
                                                        Image(systemName: "square.slash")
                                                            .resizable()
                                                            .frame(width: min(40, 100), height: min(40, 100))
                                                            .foregroundStyle(Color(.systemBackground))
                                                            .symbolRenderingMode(.hierarchical)
                                                    }
                                                    Text("Removed")
                                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                                        .foregroundStyle(.pink)
                                                }
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            .padding()
                                            
                                            Button(action: {
                                                showAllSheets.toggle()
                                                sheetArray = loadSheetArray()
                                                unlockButtons = false
                                                speechDelegate.stopSpeaking()
                                            }) {
                                                VStack {
                                                    ZStack {
                                                        Image(systemName: "square.fill")
                                                            .resizable()
                                                            .frame(width: 75, height: 75)
                                                            .foregroundStyle(.purple)
                                                        Image(systemName: "square.grid.2x2")
                                                            .resizable()
                                                            .frame(width: min(40, 100), height: min(40, 100))
                                                            .foregroundStyle(Color(.systemBackground))
                                                    }
                                                    Text("All Sheets")
                                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                                        .foregroundStyle(.purple)
                                                }
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            .padding()
                                            
                                            Button(action: {
                                                showSettings.toggle()
                                                speechDelegate.stopSpeaking()
                                            }) {
                                                VStack {
                                                    ZStack {
                                                        Image(systemName: "square.fill")
                                                            .resizable()
                                                            .frame(width: 75, height: 75)
                                                            .foregroundStyle(Color(.systemGray))
                                                        Image(systemName: "gear")
                                                            .resizable()
                                                            .frame(width: min(40, 100), height: min(40, 100))
                                                            .foregroundStyle(Color(.systemBackground))
                                                    }
                                                    Text("Settings")
                                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                                        .foregroundStyle(Color(.systemGray))
                                                }
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            .padding()
                                            
                                            Button(action: {
                                                if sheetArray.count > 1 {
                                                    editMode.toggle()
                                                    currTitleText = currSheet.label
                                                    animate.toggle()
                                                }
                                                unlockButtons = false
                                                speechDelegate.stopSpeaking()
                                            }) {
                                                VStack {
                                                    ZStack {
                                                        Image(systemName: "square.fill")
                                                            .resizable()
                                                            .frame(width: 75, height: 75)
                                                            .foregroundStyle(.blue)
                                                        Image(systemName: "pencil")
                                                            .resizable()
                                                            .frame(width: min(40, 100), height: min(40, 100))
                                                        //.fontWeight(.heavy)
                                                            .foregroundStyle(Color(.systemBackground))
                                                    }
                                                    Text("Edit")
                                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                                        .foregroundStyle(.blue)
                                                }
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            .padding()
                                        }
                                    }
                                }
                            }
                            Spacer()
                        }
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color(.systemBackground).opacity(1), Color(.systemBackground).opacity(1),  Color.clear.opacity(0)]), startPoint: .bottom, endPoint: .top)
                                .ignoresSafeArea()
                        )
                    }
                }
                .transition(
                    .asymmetric(
                        insertion: .movingParts.flip,
                        removal: .opacity
                    )
                )
                .navigationViewStyle(StackNavigationViewStyle())
                .navigationBarHidden(true)
                .sheet(isPresented: $pickIcon) {
                    AllIconsPickerView(currSheet: currSheet,
                                       currImage: currSheet.currLabelIcon ?? "plus.viewfinder",
                                       modifyIcon: { newIcon in
                        withAnimation(.spring) {
                            currSheet.currLabelIcon = newIcon
                        }
                        Task {
                            do {
                                customIconPreviews = await getCustomIconPreviews()
                            }
                        }
                        currCommunicationBoard = loadCommunicationBoard()
                    }, modifyCustomIcon: {
                        Task {
                            do {
                                customIconPreviews = await getCustomIconPreviews()
                            }
                        }
                        currCommunicationBoard = loadCommunicationBoard()
                        currSheet = loadSheetArray()[currSheetIndex]
                    }, modifyDetails: { newDetails in
                        //no need to modify details here
                    }, onDismiss: {
                        Task {
                            do {
                                customIconPreviews = await getCustomIconPreviews()
                            }
                        }
                        pickIcon.toggle()
                        //save array aka "autosave"
                        var newSheetArray = loadSheetArray()
                        newSheetArray[currSheetIndex] = currSheet
                        currSheet = newSheetArray[currSheetIndex]
                        saveSheetArray(sheetObjects: newSheetArray)
                        currCommunicationBoard = loadCommunicationBoard()
                    }, showCreateCustom: false, customIconPreviews: customIconPreviews)
                }
                .sheet(isPresented: $showTime) { //fullscreencover for setting times on a sheet
                    TimeLabelPickerView(viewType: .time, saveItem: { item in
                        if item is Date {
                            currSheet.currGrid[currListIndex].currTime = item as! Date
                            currSheet.currGrid = sortSheet(currSheet.currGrid)
                            var newSheetArray = loadSheetArray()
                            newSheetArray[currSheetIndex] = currSheet
                            saveSheetArray(sheetObjects: newSheetArray)
                            manageNotifications()
                            updateUsage("action:time")
                        }
                    }, oldDate: currSheet.currGrid[currListIndex].currTime, oldLabel: $currText)
                }
                .sheet(isPresented: $showLabels) { //fullscreencover for setting a custom label in a sheet
                    TimeLabelPickerView(viewType: .label, saveItem: { item in
                        if item is String {
                            updateUsage("action:label")
                            currSheet.currGrid[currListIndex].currLabel = item as! String
                            var newSheetArray = loadSheetArray()
                            newSheetArray[currSheetIndex] = currSheet
                            saveSheetArray(sheetObjects: newSheetArray)
                        }
                    }, oldLabel: $currText)
                }
                .fullScreenCover(isPresented: $showIcons) {
                    AllIconsPickerView(currSheet: currSheet,
                                       currImage: currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currIcon,
                                       modifyIcon: { newIcon in
                        withAnimation() {
                            currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currIcon = newIcon
                        }
                        Task {
                            do {
                                customIconPreviews = await getCustomIconPreviews()
                            }
                        }
                        currCommunicationBoard = loadCommunicationBoard()
                    }, modifyCustomIcon: {
                        Task {
                            do {
                                customIconPreviews = await getCustomIconPreviews()
                            }
                        }
                        currCommunicationBoard = loadCommunicationBoard()
                        currSheet = loadSheetArray()[currSheetIndex]
                    }, modifyDetails: { newDetails in
                        currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currDetails = newDetails
                    }, onDismiss: {
                        Task {
                            do {
                                customIconPreviews = await getCustomIconPreviews()
                            }
                        }
                        showIcons.toggle()
                        //save array aka "autosave"
                        var newSheetArray = loadSheetArray()
                        newSheetArray[currSheetIndex] = currSheet
                        currSheet = newSheetArray[currSheetIndex]
                        saveSheetArray(sheetObjects: newSheetArray)
                        currCommunicationBoard = loadCommunicationBoard()
                    }, customIconPreviews: customIconPreviews)
                }
                .fullScreenCover(isPresented: $showMod) { //the fullscreencover that enlarges the icon and lets you remove or complete it
                    
                    VStack {
                        if editMode {
                            Text("\(Image(systemName: "plus.square.on.square")) Add Details")
                                .lineLimit(1)
                                .minimumScaleFactor(0.01)
                                .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                                .padding(.top)
                        }
                        
                        ModImageView(currSheet: $currSheet, modListIndex: $currListIndex, modSlotIndex: $currSlotIndex, hasDetails: tempDetails.isEmpty)
                        
                        
                        if editMode {
                            
                            Divider()
                                .padding()
                            
                            ZStack {
                                HStack {
                                    ForEach(0..<tempDetails.count, id: \.self) { detail in
                                        Button(action: {
                                            detailIconIndex = detail
                                            searchText = ""
                                            showDetailsIcons.toggle()
                                        }) {
                                            //loadImage() or getCustomIcon() depending
                                            if UIImage(named: tempDetails[detail]) == nil {
                                                if horizontalSizeClass == .compact {
                                                    Image(uiImage: customIconPreviews[tempDetails[detail]] ?? UIImage(systemName: "square.fill")!)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 15)
                                                                .stroke(.black, lineWidth: 6)
                                                        )
                                                        .padding(3)
                                                } else {
                                                    Image(uiImage: customIconPreviews[tempDetails[detail]] ?? UIImage(systemName: "square.fill")!)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 15)
                                                                .stroke(.black, lineWidth: 10)
                                                        )
                                                        .padding(7)
                                                }
                                            } else {
                                                Image(tempDetails[detail])
                                                    .resizable()
                                                    .scaledToFit()
                                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 15)
                                                            .stroke(.black, lineWidth: (horizontalSizeClass == .compact ? 6 : 10))
                                                    )
                                                    .padding(horizontalSizeClass == .compact ? 3 : 7)
                                            }
                                        }
                                    }
                                    if tempDetails.count < (horizontalSizeClass == .compact ? 3 : 5) {
                                        Button(action: {
                                            detailIconIndex = -1
                                            searchText = ""
                                            showDetailsIcons.toggle()
                                        }) {
                                            Image(systemName: "plus.viewfinder")
                                                .resizable()
                                                .scaledToFit()
                                                .symbolRenderingMode(.hierarchical)
                                                .foregroundStyle(Color(.systemGray))
                                                .padding()
                                        }
                                    }
                                }
                            }
                            .sheet(isPresented: $showDetailsIcons) {
                                
                                AllIconsPickerView(currSheet: currSheet,
                                                   currImage: detailIconIndex != -1 ? tempDetails[detailIconIndex] : "plus.viewfinder",
                                                   modifyIcon: { newIcon in
                                    withAnimation(.spring) {
                                        if detailIconIndex != -1 {
                                            tempDetails[detailIconIndex] = newIcon
                                        } else {
                                            tempDetails.append(newIcon)
                                        }
                                        currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currDetails = tempDetails
                                    }
                                    Task {
                                        do {
                                            customIconPreviews = await getCustomIconPreviews()
                                        }
                                    }
                                    currCommunicationBoard = loadCommunicationBoard()
                                }, modifyCustomIcon: {
                                    Task {
                                        do {
                                            customIconPreviews = await getCustomIconPreviews()
                                        }
                                    }
                                    currCommunicationBoard = loadCommunicationBoard()
                                    currSheet = loadSheetArray()[currSheetIndex]
                                }, modifyDetails: { newDetails in
                                    //no need to modify details here
                                }, onDismiss: {
                                    Task {
                                        do {
                                            customIconPreviews = await getCustomIconPreviews()
                                        }
                                    }
                                    showDetailsIcons.toggle()
                                    //autosave
                                    var newArray = loadSheetArray()
                                    newArray[currSheetIndex] = autoRemoveSlots(currSheet)
                                    currSheet = newArray[currSheetIndex]
                                    saveSheetArray(sheetObjects: newArray)
                                    currCommunicationBoard = loadCommunicationBoard()
                                }, showCreateCustom: false, customIconPreviews: customIconPreviews)
                                
                            }
                        } else {
                            if !tempDetails.isEmpty {
                                Divider()
                                    .padding()
                            }
                            HStack {
                                ForEach(0..<tempDetails.count, id: \.self) { detail in
                                    if lockButtonsOn && !unlockButtons {
                                        if UIImage(named: tempDetails[detail]) == nil {
                                            Image(uiImage: customIconPreviews[tempDetails[detail]] ?? UIImage(systemName: "square.fill")!)
                                                .resizable()
                                                .scaledToFit()
                                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .stroke(.black, lineWidth: 10)
                                                )
                                                .padding()
                                        } else {
                                            Image(uiImage: customIconPreviews[tempDetails[detail]] ?? UIImage(systemName: "square.fill")!)
                                                .resizable()
                                                .scaledToFit()
                                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .stroke(.black, lineWidth: horizontalSizeClass == .compact ? 6 : 10)
                                                )
                                                .padding()
                                        }
                                    } else {
                                        Menu {
                                            Button(role: .destructive) {
                                                tempDetails.remove(at: detail)
                                                currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currDetails = tempDetails
                                                var newArray = loadSheetArray()
                                                newArray[currSheetIndex] = currSheet
                                                newArray[currSheetIndex] = autoRemoveSlots(newArray[currSheetIndex])
                                                currSheet = newArray[currSheetIndex]
                                                saveSheetArray(sheetObjects: newArray)
                                                animate.toggle()
                                            } label: {
                                                Label("Delete from Details", systemImage: "trash")
                                            }
                                        } label: {
                                            //loadImage() or getCustomIcon() depending
                                            if UIImage(named: tempDetails[detail]) == nil {
                                                if horizontalSizeClass == .compact {
                                                    Image(uiImage: customIconPreviews[tempDetails[detail]] ?? UIImage(systemName: "square.fill")!)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 15)
                                                                .stroke(.black, lineWidth: 6)
                                                        )
                                                        .padding()
                                                } else {
                                                    Image(uiImage: customIconPreviews[tempDetails[detail]] ?? UIImage(systemName: "square.fill")!)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 15)
                                                                .stroke(.black, lineWidth: 10)
                                                        )
                                                        .padding()
                                                }
                                            } else {
                                                Image(tempDetails[detail])
                                                    .resizable()
                                                    .scaledToFit()
                                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 15)
                                                            .stroke(.black, lineWidth: horizontalSizeClass == .compact ? 6 : 10)
                                                    )
                                                    .padding()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        HStack(alignment: .top) {
                            if !editMode {
                                Button(action: {
                                    showMod.toggle()
                                    unlockButtons = false
                                }) {
                                    VStack {
                                        Image(systemName:"xmark.square.fill")
                                            .resizable()
                                            .frame(width: horizontalSizeClass == .compact ? min(100, 350) : min(150, 500), height: horizontalSizeClass == .compact ? min(100, 350) : min(150, 500))
                                        
                                        Text("Cancel")
                                            .font(.system(size: horizontalSizeClass == .compact ? 15 : 25, weight: .semibold, design: .rounded))
                                    }
                                }
                                .padding()
                                .foregroundStyle(Color(.systemGray))
                                if lockButtonsOn && !unlockButtons {
                                    Button(action: {
                                        if !canUseBiometrics() && !canUsePassword() {
                                            animate.toggle()
                                            showCustomPassword = true
                                            showMod = false
                                        } else {
                                            Task {
                                                unlockButtons = await authenticateWithBiometrics()
                                                animate.toggle()
                                            }
                                            if unlockButtons {
                                                Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { timer in
                                                    withAnimation(.spring) {
                                                        unlockButtons = false
                                                    }
                                                }
                                            }
                                        }
                                    }) {
                                        VStack {
                                            Image(systemName: "lock.square")
                                                .resizable()
                                                .frame(width: horizontalSizeClass == .compact ? min(100, 350) : min(150, 500), height: horizontalSizeClass == .compact ? min(100, 350) : min(150, 500))
                                            Text("Buttons Locked")
                                                .font(.system(size: horizontalSizeClass == .compact ? 15 : 25, weight: .semibold, design: .rounded))
                                        }
                                    }
                                    .padding()
                                    .foregroundStyle(Color(.systemGray))
                                } else {
                                    Button(action: {
                                        showMod.toggle()
                                        unlockButtons = false
                                        updateUsage(currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currIcon)
                                        currSheet.removedIcons.append(currSheet.currGrid[currListIndex].currIcons[currSlotIndex])
                                        currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currIcon = ""
                                        currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currDetails = []
                                        var newArray = loadSheetArray()
                                        newArray[currSheetIndex] = currSheet
                                        newArray[currSheetIndex] = autoRemoveSlots(newArray[currSheetIndex])
                                        currSheet = newArray[currSheetIndex]
                                        saveSheetArray(sheetObjects: newArray)
                                        animate.toggle()
                                        if removedSelectedLabel == "All Sheets" {
                                            removedSelected = getAllRemoved()
                                        } else {
                                            removedSelected = getAllRemoved()
                                            currSheet = loadSheetArray()[currSheetIndex]
                                            
                                            removedSelected = currSheet.removedIcons
                                        }
                                        hapticFeedback(type: 1)
                                    }) {
                                        VStack {
                                            ZStack {
                                                Image(systemName: "square.fill")
                                                    .resizable()
                                                    .frame(width: horizontalSizeClass == .compact ? min(100, 350) : min(150, 500), height: horizontalSizeClass == .compact ? min(100, 350) : min(150, 500))
                                                Image(systemName: "square.slash")
                                                    .resizable()
                                                    .frame(width: horizontalSizeClass == .compact ? min(75, 125) : min(100, 250), height: horizontalSizeClass == .compact ? min(75, 125) : min(100, 250))
                                                    .foregroundStyle(Color(.systemBackground))
                                                    .symbolRenderingMode(.hierarchical)
                                            }
                                            Text(tempDetails.isEmpty ? "Remove Icon" : "Remove All")
                                                .font(.system(size: horizontalSizeClass == .compact ? 15 : 25, weight: .semibold, design: .rounded))
                                        }
                                    }
                                    .padding()
                                    .foregroundStyle(.pink)
                                }
                            } else {
                                Button(action: {
                                    showMod.toggle()
                                    checkDetails = []
                                    unlockButtons = false
                                    if !wasEditing {editMode.toggle(); wasEditing.toggle()}
                                }) {
                                    if checkDetails == currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currDetails ?? [] {
                                        Image(systemName:"xmark.square.fill")
                                            .resizable()
                                            .frame(width: horizontalSizeClass == .compact ? min(100, 350) : min(150, 500), height: horizontalSizeClass == .compact ? min(100, 350) : min(150, 500))
                                            .foregroundStyle(Color(.systemGray))
                                    } else {
                                        Image(systemName:"checkmark.square.fill")
                                            .resizable()
                                            .frame(width: horizontalSizeClass == .compact ? min(100, 350) : min(150, 500), height: horizontalSizeClass == .compact ? min(100, 350) : min(150, 500))
                                            .foregroundStyle(.green)
                                    }
                                }
                                .padding()
                            }
                        }
                    }
                }
                .fullScreenCover(isPresented: $showSettings) { //fullscreencover for the settings page
                    SettingsView(onDismiss: {
//                        lockButtonsOn = defaults.bool(forKey: "buttonsOn")
//                        showCurrentSlot = defaults.bool(forKey: "showCurrSlot")
//                        speakIcons = defaults.bool(forKey: "speakOn")
                        unlockButtons = false
                        currSheet = autoRemoveSlots(currSheet)
                        if showCurrentSlot {
                            currGreenSlot = loadSheetArray()[currSheetIndex].getCurrSlot()
                            animate.toggle()
                        }
                    })
                }
                .onAppear{ //re-check for notification permission when settings opened
                    @State var notificationsAllowed: Bool?
                    if notificationsAllowed != nil {
                        currSessionLog.append("notification status has already been set")
                    } else {
                        defaults.set(true, forKey : "notificationsAllowed")
                    }
                }
                .fullScreenCover(isPresented: $showRemoved) { //fullscreencover for removed icons
                    ZStack {
                        ScrollView {
                            HStack(alignment: .top) {
                                VStack(alignment: horizontalSizeClass == .compact ? .leading : .center) {
                                    Text("\(Image(systemName: "square.slash")) Removed Icons")
                                        .lineLimit(1)
                                    //.minimumScaleFactor(0.01)
                                        .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                                        .padding(.top)
                                        .padding(.bottom, horizontalSizeClass == .compact ? 5 : 0)
                                        .symbolRenderingMode(.hierarchical)
                                    HStack {
                                        Text("From") .foregroundStyle(Color(.systemGray))
                                            .minimumScaleFactor(0.01)
                                            .font(.system(size: horizontalSizeClass == .compact ? 17 : 25, weight: .bold, design: .rounded))
                                            .multilineTextAlignment(horizontalSizeClass == .compact ? .leading : .center)
                                            .padding(.bottom)
                                        Menu {
                                            Button {
                                                removedSelected = getAllRemoved()
                                                removedSelectedLabel = "All Sheets"
                                            } label: {
                                                Label("All Sheets", systemImage: "square.on.square")
                                            }
                                            
                                            Button {
                                                removedSelected = getAllRemoved()
                                                currSheet = loadSheetArray()[currSheetIndex]
                                                
                                                removedSelected = currSheet.removedIcons
                                                removedSelectedLabel = "This Sheet"
                                            } label: {
                                                Label("This Sheet", systemImage: "square")
                                            }
                                        } label: {
                                            Text("\(removedSelectedLabel)\(Image(systemName: "chevron.up.chevron.down"))").foregroundStyle(.purple)
                                                .font(.system(size: horizontalSizeClass == .compact ? 17 : 25, weight: .bold, design: .rounded))
                                                .multilineTextAlignment(horizontalSizeClass == .compact ? .leading : .center)
                                                .padding(.bottom)
                                        }
                                    }
                                }
                                .padding(.leading, horizontalSizeClass == .compact ? 20 : 0)
                                if horizontalSizeClass == .compact {
                                    Spacer()
                                    Button(action: {
                                        showRemoved.toggle()
                                    }) {
                                        Text("\(Image(systemName: "xmark.circle.fill"))")
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.5)
                                            .font(.system(size: 30, weight: .bold, design: .rounded))
                                            .foregroundStyle(loadSheetArray().count > 1 ? Color(.systemGray3): Color(.systemGray6))
                                            .padding(.trailing)
                                    }
                                }
                            }
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: horizontalSizeClass == .compact ? 100 : 150))], spacing: horizontalSizeClass == .compact ? 0 : 20) {
                                ForEach(0..<removedSelected.count, id: \.self) { index in
                                    ZStack {
                                        if UIImage(named: removedSelected[index].currIcon) == nil {
                                            Image(uiImage: customIconPreviews[removedSelected[index].currIcon] ?? UIImage(systemName: "square.fill")!)
                                                .resizable()
                                                .scaledToFit()
                                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .stroke(.black, lineWidth: 3)
                                                )
                                        } else {
                                            Image(removedSelected[index].currIcon)
                                                .resizable()
                                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .stroke(lineWidth: 3)
                                                )
                                                .scaledToFit()
                                        }
                                    }
                                }
                            }
                            .padding()
                            .padding(.bottom, 150)
                            Spacer()
                            if removedSelected.count == 0 {
                                Text("You don't have any removed icons yet. Once you remove an icon from \(removedSelectedLabel == "All Sheets" ? "any Sheet" : (currSheet.label.isEmpty ? "the current sheet" : currSheet.label)), it will appear here.")
                                    .minimumScaleFactor(0.01)
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: horizontalSizeClass == .compact ? 15 : 30, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color(.systemGray))
                                    .padding()
                                    .padding()
                                Spacer()
                            }
                        }
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                if horizontalSizeClass != .compact {
                                    Button(action: {
                                        showRemoved.toggle()
                                    }) {
                                        Image(systemName:"xmark.square.fill")
                                            .resizable()
                                            .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                            .foregroundStyle(Color(.systemGray))
                                        
                                            .padding()
                                    }
                                }
                                Spacer()
                            }
                            .background(
                                LinearGradient(gradient: Gradient(colors: [Color(.systemBackground).opacity(1), Color(.systemBackground).opacity(1),  Color.clear.opacity(0)]), startPoint: .bottom, endPoint: .top)
                                    .ignoresSafeArea()
                            )
                        }
                    }
                    .animation(.spring, value: sheetAnimate)
                    .onChange(of: removedSelectedLabel, perform: { _ in
                        sheetAnimate.toggle()
                    })
                }
                
                
                .fullScreenCover(isPresented: $showAllSheets) { //fullscreencover that shows all the sheets created
                    ZStack {
                        if createNewSheet {
                            VStack {
                                HStack(alignment: .top) {
                                    Text(horizontalSizeClass == .compact ? "\(Image(systemName: "plus.square")) New Sheet" : "\(Image(systemName: "plus.square")) Create New Sheet")
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.01)
                                        .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                                        .padding(.top)
                                        .padding(.bottom, horizontalSizeClass == .compact ? 5 : 0)
                                        .padding(.leading, horizontalSizeClass == .compact ? 20 : 0)
                                    
                                    if horizontalSizeClass == .compact {
                                        Spacer()
                                        Spacer()
                                        Button(action: {
                                            if defaults.bool(forKey: "completedTutorial") { //if they havent actually done anything take them back to the welcome screen
                                                if loadSheetArray().count > 1 { //cant go back to a sheet if there is none
                                                    withAnimation(.spring) {
                                                        createNewSheet.toggle()
                                                    }
                                                    if !showAllSheets {
                                                        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { timer in
                                                            if loadSheetArray().count < 2 {
                                                                showAllSheets.toggle()
                                                            }
                                                        }
                                                    }
                                                }
                                            } else {
                                                withAnimation(.spring) {
                                                    createNewSheet.toggle()
                                                }
                                                showAllSheets.toggle()
                                                Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { timer in
                                                    self.presentation.wrappedValue.dismiss()
                                                }
                                            }
                                        }) {
                                            if defaults.bool(forKey: "completedTutorial") {
                                                Text("\(Image(systemName: "xmark.circle.fill"))")
                                                    .lineLimit(1)
                                                    .minimumScaleFactor(0.5)
                                                    .font(.system(size: 30, weight: .bold, design: .rounded))
                                                    .foregroundStyle(loadSheetArray().count > 1 ? Color(.systemGray3): Color(.systemGray6))
                                                    .padding([.top, .trailing])
                                            } else {
                                                Text("\(Image(systemName: "xmark.circle.fill"))")
                                                    .lineLimit(1)
                                                    .minimumScaleFactor(0.5)
                                                    .font(.system(size: 30, weight: .bold, design: .rounded))
                                                    .foregroundStyle(Color(.systemGray3))
                                                    .padding([.top, .trailing])
                                            }
                                        }
                                    }
                                }
                                Spacer()
                                TextField("Name Sheet", text: $currSheetText, onEditingChanged: { editing in
                                    withAnimation(.spring) {
                                        isTextFieldActive = editing
                                    }
                                }, onCommit: {
                                })
                                .font(.system(size: horizontalSizeClass == .compact ? 40 : 65, weight: .bold, design: .rounded))
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color(.systemGray6))
                                )
                                .minimumScaleFactor(0.01)
                                .padding([.leading, .trailing])
                                if !isTextFieldActive { //just to handle the content getting pushed off screen by the keybpoard on smaller devices
                                    TabView(selection: $newSheetSelection) {
                                        Button(action: {
                                            newSheetSelection = 0
                                            sheetAnimate.toggle()
                                            editMode.toggle()
                                            withAnimation(.spring) {
                                                createNewSheet.toggle()
                                            }
                                            showAllSheets.toggle()
                                            
                                            defaults.set(true, forKey: "completedTutorial")
                                            newSheet(gridType: "time", label: currSheetText)
                                            currTitleText = currSheetText
                                            currSheetIndex = loadSheetArray().count - 1
                                            sheetArray = loadSheetArray()
                                            currSheetText = ""
                                            currSheet = loadSheetArray()[currSheetIndex]
                                            updateUsage("action:create")
                                        }) {
                                            VStack {
                                                Image(systemName: "timer")
                                                    .resizable()
                                                    .foregroundStyle(newSheetSelection == 0 ? .white : .purple)
                                                    .scaledToFit()
                                                    .padding(horizontalSizeClass == .compact ? 15 : 30)
                                                    .foregroundStyle(.white)
                                                    .background(newSheetSelection == 0 ? .purple : Color(.systemGray6))
                                                    .cornerRadius(horizontalSizeClass == .compact ? 40 : 65)
                                                    .padding(horizontalSizeClass == .compact ? 40 : 60)
                                                    .changeEffect(
                                                        .spray(origin: UnitPoint(x: 0.5, y: 0.1)) {
                                                            Image(systemName: newSheetSelection == 0 ? "timer" : "")
                                                                .foregroundStyle(.purple)
                                                        }, value: newSheetSelection)
                                                
                                                Text("Timeslot Sheet")
                                                    .minimumScaleFactor(0.01)
                                                    .multilineTextAlignment(.center)
                                                    .font(.system(size: newSheetSelection == 0 ? 20 : 10, weight: .semibold, design: .rounded))
                                                    .foregroundStyle(newSheetSelection == 0 ? .primary : Color(.systemGray6))
                                            }
                                        }
                                        .padding(.bottom)
                                        .tag(0)
                                        
                                        Button(action: {
                                            newSheetSelection = 1
                                            sheetAnimate.toggle()
                                            editMode.toggle()
                                            withAnimation(.spring) {
                                                createNewSheet.toggle()
                                            }
                                            showAllSheets.toggle()
                                            
                                            defaults.set(true, forKey: "completedTutorial")
                                            newSheet(gridType: "label", label: currSheetText)
                                            currTitleText = currSheetText
                                            currSheetIndex = loadSheetArray().count - 1
                                            sheetArray = loadSheetArray()
                                            currSheetText = ""
                                            currSheet = loadSheetArray()[currSheetIndex]
                                            updateUsage("action:create")
                                        }) {
                                            VStack {
                                                Image(systemName: "tag")
                                                    .resizable()
                                                    .foregroundStyle(newSheetSelection == 1 ? .white : .purple)
                                                    .scaledToFit()
                                                    .padding(horizontalSizeClass == .compact ? 15 : 30)
                                                    .foregroundStyle(.white)
                                                    .background(newSheetSelection == 1 ? .purple : Color(.systemGray6))
                                                    .cornerRadius(horizontalSizeClass == .compact ? 40 : 65)
                                                    .padding(horizontalSizeClass == .compact ? 40 : 60)
                                                    .changeEffect(
                                                        .spray(origin: UnitPoint(x: 0.5, y: 0.1)) {
                                                            Image(systemName: newSheetSelection == 1 ? "tag" : "")
                                                                .foregroundStyle(.purple)
                                                        }, value: newSheetSelection)
                                                
                                                Text("Custom Labels Sheet")
                                                    .minimumScaleFactor(0.01)
                                                    .multilineTextAlignment(.center)
                                                    .font(.system(size: newSheetSelection == 1 ? 20 : 10, weight: .semibold, design: .rounded))
                                                    .foregroundStyle(newSheetSelection == 1 ? .primary : Color(.systemGray6))
                                            }
                                        }
                                        .padding(.bottom)
                                        .tag(1)
                                    }
                                    .tabViewStyle(.page(indexDisplayMode: .always))
                                    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                                    .padding([.leading, .trailing], horizontalSizeClass == .compact ? 20 : 40)
                                    
                                    //Spacer()
                                    if horizontalSizeClass != .compact {
                                        HStack {
                                            if defaults.bool(forKey: "completedTutorial") { //if they havent actually done anything take them back to the welcome screen
                                                Button(action: {
                                                    if loadSheetArray().count > 1 { //cant go back to a sheet if there is none
                                                        withAnimation(.spring) {
                                                            createNewSheet.toggle()
                                                        }
                                                        if !showAllSheets {
                                                            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { timer in
                                                                if loadSheetArray().count < 2 {
                                                                    showAllSheets.toggle()
                                                                }
                                                            }
                                                        }
                                                    }
                                                }) {
                                                    Image(systemName:"xmark.square.fill")
                                                        .resizable()
                                                        .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                                    
                                                        .foregroundStyle(loadSheetArray().count > 1 ? Color(.systemGray): Color(.systemGray6))
                                                        .padding()
                                                }
                                            } else {
                                                Button(action: {
                                                    withAnimation(.spring) {
                                                        createNewSheet.toggle()
                                                    }
                                                    showAllSheets.toggle()
                                                    Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { timer in
                                                        self.presentation.wrappedValue.dismiss()
                                                    }
                                                }) {
                                                    Image(systemName:"xmark.square.fill")
                                                        .resizable()
                                                        .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                                        .foregroundStyle(Color(.systemGray))
                                                        .padding()
                                                }
                                            }
                                        }
                                    }
                                    Button(action: {
                                        sheetAnimate.toggle()
                                        editMode.toggle()
                                        withAnimation(.spring) {
                                            createNewSheet.toggle()
                                        }
                                        showAllSheets.toggle()
                                        
                                        defaults.set(true, forKey: "completedTutorial")
                                        newSheet(gridType: newSheetSelection == 0 ? "time" : "label", label: currSheetText)
                                        currTitleText = currSheetText
                                        currSheetIndex = loadSheetArray().count - 1
                                        sheetArray = loadSheetArray()
                                        currSheetText = ""
                                        currSheet = loadSheetArray()[currSheetIndex]
                                        updateUsage("action:create")
                                        print(newSheetSelection)
                                        print(newSheetSelection == 0 ? "time" : "label")
                                    }) {
                                        Text("Next \(Image(systemName: "arrow.forward"))")
                                            .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                                            .lineLimit(1)
                                            .padding([.top, .bottom, .trailing], horizontalSizeClass == .compact ? 5 : 10)
                                            .padding()
                                            .background(Color(.systemGray6))
                                            .cornerRadius(horizontalSizeClass == .compact ? 20 : 25)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .changeEffect(
                                        .wiggle(rate: .fast), value: newSheetSelection)
                                    Spacer()
                                }
                            }
                            .onChange(of: newSheetSelection, perform: { _ in
                                sheetAnimate.toggle()
                            })
                            .animation(.spring, value: sheetAnimate)
                            .transition(.movingParts.move(angle: .degrees(270)).combined(with: .opacity))
                        } else {
                            ScrollView {
                                HStack(alignment: .top) {
                                    VStack(alignment: horizontalSizeClass == .compact ? .leading : .center) {
                                        Text("\(Image(systemName: "square.grid.2x2")) All Sheets")
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.01)
                                            .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                                            .padding(.top)
                                            .padding(.bottom, horizontalSizeClass == .compact ? 5 : 0)
                                        Text("You have \(loadSheetArray().count - 1) Sheets. \(Image(systemName: "timer").resizable()) indicates Timeslots, and \(Image(systemName: "tag").resizable()) indicates Custom Labels.")
                                            .minimumScaleFactor(0.01)
                                            .font(.system(size: horizontalSizeClass == .compact ? 17 : 25, weight: .bold, design: .rounded))
                                            .foregroundStyle(Color(.systemGray))
                                            .multilineTextAlignment(horizontalSizeClass == .compact ? .leading : .center)
                                            .padding(.bottom)
                                    }
                                    .padding(.leading, horizontalSizeClass == .compact ? 20 : 0)
                                    if horizontalSizeClass == .compact {
                                        Spacer()
                                        Button(action: {
                                            if sheetArray.count > 1 {
                                                showAllSheets.toggle()
                                            }
                                        }) {
                                            Text("\(Image(systemName: "xmark.circle.fill"))")
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.5)
                                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                                .foregroundStyle(loadSheetArray().count > 1 ? Color(.systemGray3): Color(.systemGray6))
                                                .padding([.top, .trailing])
                                        }
                                    }
                                }
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: horizontalSizeClass == .compact ? 100 : 175))], spacing: horizontalSizeClass == .compact ? 5 : 10) {
                                    ForEach(0..<sheetArray.count, id: \.self) { sheet in
                                        if sheetArray[sheet].label != "Debug, ignore this page" {
                                            Button(action: {
                                                currSheetIndex = sheet
                                                currSheet = loadSheetArray()[currSheetIndex]
                                                showAllSheets.toggle()
                                                if showCurrentSlot {
                                                    currGreenSlot = loadSheetArray()[currSheetIndex].getCurrSlot()
                                                    animate.toggle()
                                                }
                                            }) {
                                                ZStack {
                                                    Image(systemName: "square.fill")
                                                        .resizable()
                                                        .foregroundStyle(Color(.systemGray5))
                                                    //.frame(width: horizontalSizeClass == .compact ? 125 : 200, height: horizontalSizeClass == .compact ? 125 : 200) this causes it to look strange on smaller iPads, not comapct screens but small enough to cause itemt to run un
                                                        .scaledToFit()
                                                    Image(systemName: "square.fill")
                                                        .resizable()
                                                        .foregroundStyle(currSheetIndex == sheet ? .purple : Color(.systemGray5))
                                                        .scaledToFit()
                                                        .opacity(0.5)
                                                    VStack {
                                                        
                                                        //check to see if there is a curc LabelIcon
                                                        //if sheetArray[sheet].currLabelIcon.isEmpty {
                                                        if sheetArray[sheet].currLabelIcon != nil && sheetArray[sheet].currLabelIcon != "" {
                                                            if UIImage(named: sheetArray[sheet].currLabelIcon!) == nil {
                                                                Image(uiImage: customIconPreviews[sheetArray[sheet].currLabelIcon!] ?? UIImage(systemName: "square.fill")!)
                                                                    .resizable()
                                                                    .resizable()
                                                                    .frame(width: horizontalSizeClass == .compact ? 65: 105, height: horizontalSizeClass == .compact ? 65: 105)
                                                                    .clipShape(RoundedRectangle(cornerRadius: horizontalSizeClass == .compact ? 10 : 20))
                                                                    .overlay(
                                                                        RoundedRectangle(cornerRadius: horizontalSizeClass == .compact ? 10 : 20)
                                                                            .stroke(.black, lineWidth: horizontalSizeClass == .compact ? 1 : 3)
                                                                    )
                                                                    .padding(.top)
                                                            } else if !sheetArray[sheet].currLabelIcon!.isEmpty && sheetArray[sheet].currLabelIcon! != "plus.viewfinder" {
                                                                Image(sheetArray[sheet].currLabelIcon!)
                                                                    .scaledToFit()
                                                                    .frame(width: horizontalSizeClass == .compact ? 65: 105, height: horizontalSizeClass == .compact ? 65: 105)
                                                                    .scaleEffect(horizontalSizeClass == .compact ? 0.17 : 0.25)
                                                                    .clipShape(RoundedRectangle(cornerRadius: horizontalSizeClass == .compact ? 10 : 20))
                                                                    .overlay(
                                                                        RoundedRectangle(cornerRadius: horizontalSizeClass == .compact ? 10 : 20)
                                                                            .stroke(.black, lineWidth: horizontalSizeClass == .compact ? 1 : 3)
                                                                    )
                                                                    .padding(.top)
                                                            } else {
                                                                if sheetArray[sheet].gridType == "time" {
                                                                    Image(systemName: "timer")
                                                                        .resizable()
                                                                        .frame(width: horizontalSizeClass == .compact ? 65: 105, height: horizontalSizeClass == .compact ? 65: 105)
                                                                        .foregroundStyle(Color(.systemGray))
                                                                        .padding(.top, sheetArray[sheet].label.isEmpty ? 0 : 15)
                                                                } else {
                                                                    Image(systemName: "tag")
                                                                        .resizable()
                                                                        .frame(width: horizontalSizeClass == .compact ? 65: 105, height: horizontalSizeClass == .compact ? 65: 105)
                                                                        .foregroundStyle(Color(.systemGray))
                                                                        .padding(.top, sheetArray[sheet].label.isEmpty ? 0 : 15)
                                                                }
                                                            }
                                                        } else {
                                                            if sheetArray[sheet].gridType == "time" {
                                                                Image(systemName: "timer")
                                                                    .resizable()
                                                                    .frame(width: horizontalSizeClass == .compact ? 65: 105, height: horizontalSizeClass == .compact ? 65: 105)
                                                                    .foregroundStyle(Color(.systemGray))
                                                                    .padding(.top, sheetArray[sheet].label.isEmpty ? 0 : 15)
                                                            } else {
                                                                Image(systemName: "tag")
                                                                    .resizable()
                                                                    .frame(width: horizontalSizeClass == .compact ? 65: 105, height: horizontalSizeClass == .compact ? 65: 105)
                                                                    .foregroundStyle(Color(.systemGray))
                                                                    .padding(.top, sheetArray[sheet].label.isEmpty ? 0 : 15)
                                                            }
                                                        }
                                                        //                                                if sheetArray[sheet].label.isEmpty {
                                                        //                                                    if sheetArray[sheet].currLabelIcon != nil && sheetArray[sheet].currLabelIcon != "plus.viewfinder" {
                                                        //                                                        if !sheetArray[sheet].currLabelIcon!.isEmpty && sheetArray[sheet].currLabelIcon! != "plus.viewfinder" {
                                                        //                                                            Spacer()
                                                        //                                                        }
                                                        //                                                    } else {
                                                        //                                                        Spacer()
                                                        //                                                    }
                                                        //                                                }
                                                        if !sheetArray[sheet].label.isEmpty {
                                                            HStack {
                                                                if sheetArray[sheet].currLabelIcon != nil && sheetArray[sheet].currLabelIcon != "plus.viewfinder" {
                                                                    if !sheetArray[sheet].currLabelIcon!.isEmpty && sheetArray[sheet].currLabelIcon! != "plus.viewfinder" {
                                                                        Text("\(Image(systemName: sheetArray[sheet].gridType == "time" ? "timer" : "tag" )) \(sheetArray[sheet].label)")
                                                                            .lineLimit(1)
                                                                            .font(.system(size: horizontalSizeClass == .compact ? 17 : 30, weight: .semibold, design: .rounded))
                                                                            .foregroundStyle(.primary)
                                                                            .padding(.bottom)
                                                                            .padding(.leading, 2)
                                                                            .padding(.trailing, 2)
                                                                    } else {
                                                                        Text(sheetArray[sheet].label)
                                                                            .lineLimit(1)
                                                                            .font(.system(size: horizontalSizeClass == .compact ? 17 : 30, weight: .semibold, design: .rounded))
                                                                            .foregroundStyle(.primary)
                                                                            .padding(.bottom)
                                                                    }
                                                                } else {
                                                                    Text(sheetArray[sheet].label)
                                                                        .lineLimit(1)
                                                                        .font(.system(size: horizontalSizeClass == .compact ? 17 : 30, weight: .semibold, design: .rounded))
                                                                        .foregroundStyle(.primary)
                                                                        .padding(.bottom)
                                                                        .padding(.leading, 2)
                                                                        .padding(.trailing, 2)
                                                                }
                                                            }
                                                            .padding(.leading, 2)
                                                            .padding(.trailing, 2)
                                                        } else {
                                                            if sheetArray[sheet].currLabelIcon != nil && sheetArray[sheet].currLabelIcon != "plus.viewfinder" {
                                                                if !sheetArray[sheet].currLabelIcon!.isEmpty && sheetArray[sheet].currLabelIcon! != "plus.viewfinder" {
                                                                    Text("\(Image(systemName: sheetArray[sheet].gridType == "time" ? "timer" : "tag" ))")
                                                                        .lineLimit(1)
                                                                        .font(.system(size: horizontalSizeClass == .compact ? 17 : 30, weight: .semibold, design: .rounded))
                                                                        .foregroundStyle(.primary)
                                                                        .padding(.bottom)
                                                                        .padding(.leading, 2)
                                                                        .padding(.trailing, 2)
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                                .contextMenu {
                                                    Button {
                                                        renameSheet.toggle()
                                                        currSheetIndex = sheet
                                                        currSheetText = sheetArray[sheet].label
                                                    } label: {
                                                        Label("Rename Sheet", systemImage: "pencil")
                                                    }
                                                    
                                                    Button {
                                                        currSheetIndex = sheet
                                                        addSheetIcon.toggle()
                                                    } label: {
                                                        if sheetArray[sheet].currLabelIcon != nil && sheetArray[sheet].currLabelIcon != "plus.viewfinder" {
                                                            Label(sheetArray[sheet].currLabelIcon!.isEmpty || sheetArray[sheet].currLabelIcon! == "plus.viewfinder" ? "Add Icon" : "Change Icon", systemImage: sheetArray[sheet].currLabelIcon!.isEmpty ? "plus.square.dashed" : "arrow.2.squarepath")
                                                        } else {
                                                            Label("Add Icon", systemImage: "plus.viewfinder")
                                                        }
                                                    }
                                                    
                                                    Divider()
                                                    Button(role: .destructive) {
                                                        currSheetIndex = sheet
                                                        currSheet = loadSheetArray()[currSheetIndex]
                                                        showAllSheets.toggle()
                                                        
                                                        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { timer in
                                                            if sheetArray.count > 1 {
                                                                presentAlert.toggle()
                                                            }
                                                        }
                                                    } label: {
                                                        Label("Delete this Sheet", systemImage: "trash")
                                                    }
                                                }
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                }
                                .padding()
                                .padding(.bottom, 150)
                            }
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    HStack {
                                        if horizontalSizeClass != .compact {
                                            Button(action: {
                                                if sheetArray.count > 1 {
                                                    showAllSheets.toggle()
                                                }
                                            }) {
                                                Image(systemName:"xmark.square.fill")
                                                    .resizable()
                                                    .frame(width:100, height: 100)
                                                
                                                    .foregroundStyle(loadSheetArray().count > 1 ? Color(.systemGray): Color(.systemGray6))
                                                    .padding()
                                            }
                                        }
                                        Button(action: {
                                            withAnimation(.spring) {
                                                createNewSheet.toggle()
                                            }
                                        }) {
                                            Image(systemName: "plus.square.fill.on.square.fill")
                                                .resizable()
                                                .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                            
                                                .foregroundStyle(.green)
                                                .padding()
                                        }
                                    }
                                    Spacer()
                                }
                                .background(
                                    LinearGradient(gradient: Gradient(colors: [Color(.systemBackground).opacity(1), Color(.systemBackground).opacity(1),  Color.clear.opacity(0)]), startPoint: .bottom, endPoint: .top)
                                        .ignoresSafeArea()
                                )
                            }
                        }
                    }
                    .sheet(isPresented: $renameSheet) {
                        TimeLabelPickerView(viewType: .label, saveItem: { item in
                            if item is String {
                                sheetArray[currSheetIndex].label = item as! String
                                saveSheetArray(sheetObjects: sheetArray)
                                renameSheet.toggle()
                                if currSheetIndex == currSheetIndex {
                                    currSheet.label = item as! String
                                }
                                currSheetText = ""
                            }
                        }, oldLabel: $currSheetText)
                    }
                    .sheet(isPresented: $addSheetIcon) {
                        
                        AllIconsPickerView(currSheet: currSheet,
                                           currImage: sheetArray[currSheetIndex].currLabelIcon ?? "",
                                           modifyIcon: { newIcon in
                            withAnimation(.spring) {
                                sheetArray[currSheetIndex].currLabelIcon = newIcon
                            }
                            Task {
                                do {
                                    customIconPreviews = await getCustomIconPreviews()
                                }
                            }
                            currCommunicationBoard = loadCommunicationBoard()
                        }, modifyCustomIcon: {
                            Task {
                                do {
                                    customIconPreviews = await getCustomIconPreviews()
                                }
                            }
                            currCommunicationBoard = loadCommunicationBoard()
                            currSheet = loadSheetArray()[currSheetIndex]
                        }, modifyDetails: { newDetails in
                            //no need to modify details here
                        }, onDismiss: {
                            Task {
                                do {
                                    customIconPreviews = await getCustomIconPreviews()
                                }
                            }
                            addSheetIcon.toggle()
                            //save array aka "autosave"
                            var newSheetArray = loadSheetArray()
                            newSheetArray[currSheetIndex] = sheetArray[currSheetIndex]
                            currSheet = newSheetArray[currSheetIndex]
                            saveSheetArray(sheetObjects: newSheetArray)
                            currCommunicationBoard = loadCommunicationBoard()
                        }, showCreateCustom: false, customIconPreviews: customIconPreviews)
                    }
                }
                .navigationBarHidden(true)
                .sheet(isPresented: $showCustomPassword) { //set and/or verify custom password if bioauth and password not set
                    CustomPasswordView(dismissSheet: { result in
                        withAnimation(.spring) {
                            unlockButtons = result
                        }
                        showCustomPassword = false
                    })
                }
                .animation(.spring, value: true)
                .navigationBarHidden(true)
                .alert(isPresented: $presentAlert) { //this is the alert to confirm deleting an entire sheet
                    Alert(
                        title: Text(currSheet.label.isEmpty ? "Delete this Sheet?" : "Delete \(currSheet.label)?"),
                        message: Text("This cannot be undone."),
                        primaryButton: .destructive(Text("Delete \(currSheet.label)")) {
                            editMode = false
                            animate.toggle()
                            removeSheet(sheetIndex: currSheetIndex)
                            if loadSheetArray().count < 2 {
                                showAllSheets = true
                                withAnimation(.spring) {
                                    createNewSheet = true
                                }
                                currSheetIndex = 0
                                currSheet = SheetObject()
                            } else {
                                currSheetIndex = loadSheetArray().count - 1
                                currSheet = loadSheetArray()[currSheetIndex]
                            }
                            sheetArray = loadSheetArray()
                            currTitleText = currSheet.label
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
        }
        .animation(.spring, value: animate)
        .task {
            customIconPreviews = await getCustomIconPreviews()
            animate.toggle()
        }
        .onAppear {
            if (countItemsInDocuments() >= 3 || loadSheetArray().count >= 3) && !defaults.bool(forKey: "askedReview") {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: windowScene)
                    defaults.setValue(true, forKey: "askedReview")
                }
            }
        }
        .onDisappear {
            cleanUp()
        }
    }
    private func cleanUp() {
        // Reset states
        editMode = false
        wasEditing = false
        showIcons = false
        showTime = false
        showLabels = false
        showMod = false
        showSettings = false
        showRemoved = false
        removedSelected = []
        removedSelectedLabel = "All Sheets"
        showAllSheets = false
        animate = false
        unlockButtons = false
        currGreenSlot = 0
        renameSheet = false
        currListIndex = 0
        currSlotIndex = 0
        pickIcon = false
        addSheetIcon = false
        showDetailsIcons = false
        tempDetails = []
        checkDetails = []
        detailIconIndex = -1
        showMore = false
        isTextFieldActive = false
        isTitleTextFieldActive = false
        customIconPreviews = [:]
        showCustomPassword = false
        currText = ""
        currTitleText = ""
        searchText = ""
        selectedDate = Date()
        newSheetSelection = 0
        createNewSheet = false
        sheetArray = []
        sheetAnimate = false
        currSheetText = ""
        presentAlert = false
        deleteAnimationFix = false
        suggestedWords = []
        currCommunicationBoard = []
        
        // Additional cleanup if necessary
        // For example, saving state, removing temporary files, etc.
    }
}
//#Preview {
//    ContentView()
//}
