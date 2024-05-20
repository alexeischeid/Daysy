

//
//  ContentView.swift
//  Daysy
//
//  Created by Alexander Eischeid on 10/19/23.
//

import SwiftUI
import AVFoundation
import LocalAuthentication
import PhotosUI
//import OpenAIKit

struct ContentView: View {
    
    @Environment(\.presentationMode) var presentation
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State var currSheet = loadSheetArray()[getCurrSheetIndex()]
    
    //for contentview
    @State var editMode = false
    @State var wasEditing = false
    @State var showIcons = false
    @State var showTime = false
    @State var showLabels = false
    @State var showMod = false
    @State var showSettings = false
    @State var showCompleted = false
    @State var showRemoved = false
    @State var showCommunication = false
    @State var showAllSheets = false
    @State var showTutorial = false
    @State var animate = false
    @State var unlockButtons = false
    @State var lockButtonsOn = defaults.bool(forKey: "buttonsOn")
    @State var currGreenSlot = loadSheetArray()[getCurrSheetIndex()].getCurrSlot()
    @State var renameSheet = false
    @State var speakIcons = defaults.bool(forKey: "speakOn")
    @State var showCurrentSlot = defaults.bool(forKey: "showCurrSlot")
    @State var currListIndex = 0
    @State var currSlotIndex = 0
    @State var currSheetIndex = 0
    @State var pickIcon = false
    @State var addSheetIcon = false
    @State var showDetailsIcons = false
    @State var tempDetails: [String] = []
    @State var checkDetails: [String] = []
    @State var detailIconIndex = -1
    @State var showMore = false
    @State var isTextFieldActive = false
    @State var isTitleTextFieldActive = false
    
    //custom password variables
    @State var showCustomPassword = false
    @State var password = ""
    @State var mismatch = false
    @State var wasShowingMod = false
    
    //custom labels and times
    @State var currText = ""
    @State var currTitleText = ""
    @State var searchText = ""
    @State private var selectedDate = Date()
    @State var removedIcons = loadSheetArray()[getCurrSheetIndex()].removedIcons
    @State var completedIcons = loadSheetArray()[getCurrSheetIndex()].completedIcons
    @State var allRemovedIcons = getAllRemoved()
    @State var allCompletedIcons = getAllCompleted()
    @State var iconsSelection = 0
    
    //allsheetsview
    @State var createNewSheet = false
    @State var sheetArray = loadSheetArray()
    @State var index = getCurrSheetIndex()
    @State var newSheetTime = false
    @State var newSheetLabel = false
    @State var sheetAnimate = false
    @State var currSheetText = ""
    @State var presentAlert = false
    
    @State var deleteAnimationFix = false
    
    @State var sanitizedPrompt = ""
    
    @State private var suggestedWords: [String] = []
    
    var body: some View {
        
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
                                        if currSheet.currLabelIcon != nil && currSheet.currLabelIcon != "plus.viewfinder" {
                                            if currSheet.currLabelIcon!.contains("customIconObject:") {
                                                getCustomIconSmall(currSheet.currLabelIcon ?? "")
                                                    .scaledToFit()
                                                    .frame(width: horizontalSizeClass == .compact ? 50 : 100, height: horizontalSizeClass == .compact ? 50 : 100)
                                                    .clipShape(RoundedRectangle(cornerRadius: horizontalSizeClass == .compact ? 8 : 16))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: horizontalSizeClass == .compact ? 8 : 16)
                                                            .stroke(.black, lineWidth: horizontalSizeClass == .compact ? 1 : 3)
                                                    )
                                                    .padding(horizontalSizeClass == .compact ? 2 : 10)
                                            } else if !currSheet.currLabelIcon!.isEmpty {
                                                loadImage(named: currSheet.currLabelIcon!)
                                                    .scaledToFit()
                                                    .frame(width: horizontalSizeClass == .compact ? 50 : 100, height: horizontalSizeClass == .compact ? 50 : 100)
                                                    .scaleEffect(horizontalSizeClass == .compact ? 0.125 : 0.25)
                                                    .clipShape(RoundedRectangle(cornerRadius: horizontalSizeClass == .compact ? 8 : 16))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: horizontalSizeClass == .compact ? 8 : 16)
                                                            .stroke(.black, lineWidth: horizontalSizeClass == .compact ? 1 : 3)
                                                    )
                                                    .padding(horizontalSizeClass == .compact ? 2 : 10)
                                            } else {
                                                if #available(iOS 15.0, *) {
                                                    Image(systemName: "plus.square.dashed")
                                                        .resizable()
                                                        .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                                        .symbolRenderingMode(.hierarchical)
                                                        .foregroundColor(Color(.systemGray))
                                                        .padding(horizontalSizeClass == .compact ? 2 : 10)
                                                } else {
                                                    Image(systemName: "plus.square.dashed")
                                                        .resizable()
                                                        .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                                        .foregroundColor(Color(.systemGray))
                                                        .padding(horizontalSizeClass == .compact ? 2 : 10)
                                                }
                                            }
                                        } else {
                                            if #available(iOS 15.0, *) {
                                                Image(systemName: "plus.square.dashed")
                                                    .resizable()
                                                    .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                                    .symbolRenderingMode(.hierarchical)
                                                    .foregroundColor(Color(.systemGray))
                                                    .padding(horizontalSizeClass == .compact ? 2 : 10)
                                            } else {
                                                Image(systemName: "plus.square.dashed")
                                                    .resizable()
                                                    .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                                    .foregroundColor(Color(.systemGray))
                                                    .padding(horizontalSizeClass == .compact ? 2 : 10)
                                            }
                                        }
                                    }
                                    
                                    VStack {
                                        TextField("Name Sheet", text: $currTitleText, onEditingChanged: { editing in
                                            isTitleTextFieldActive = editing
                                            animate.toggle()
                                        }, onCommit: {
                                            currSheet.label = currTitleText
                                            var newSheetArray = loadSheetArray()
                                            newSheetArray[getCurrSheetIndex()] = currSheet
                                            newSheetArray[getCurrSheetIndex()] = autoRemoveSlots(newSheetArray[getCurrSheetIndex()])
                                            currSheet = newSheetArray[getCurrSheetIndex()]
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
                                                                .foregroundColor(.purple)
                                                        }
                                                    }
                                                }
                                                if suggestedWords.count == 0 {
                                                    Text("filler")
                                                        .font(.headline)
                                                        .padding(2)
                                                        .foregroundColor(.clear)
                                                }
                                            }
                                        }
                                    }
                                }
                            } else {
                                HStack {
                                    if currSheet.currLabelIcon != nil && currSheet.currLabelIcon != "plus.viewfinder" {
                                        if currSheet.currLabelIcon!.contains("customIconObject:") {
                                            getCustomIconSmall(currSheet.currLabelIcon ?? "")
                                                .scaledToFit()
                                                .frame(width: horizontalSizeClass == .compact ? 50 : 100, height: horizontalSizeClass == .compact ? 50 : 100)
                                                .clipShape(RoundedRectangle(cornerRadius: horizontalSizeClass == .compact ? 8 : 16))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: horizontalSizeClass == .compact ? 8 : 16)
                                                        .stroke(.black, lineWidth: horizontalSizeClass == .compact ? 1 : 3)
                                                )
                                                .padding(horizontalSizeClass == .compact ? 2 : 10)
                                        } else if !currSheet.currLabelIcon!.isEmpty {
                                            loadImage(named: currSheet.currLabelIcon!)
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
                                                        .foregroundColor(Color(.systemGray))
                                                        .padding(.trailing)
                                                }
                                                
                                                Text(getTime(date: currSheet.currGrid[list].currTime))
                                                    .lineLimit(1)
                                                    .minimumScaleFactor(0.01)
                                                    .font(.system(size: 30, weight: .bold, design: .rounded))
                                            }
                                            .foregroundColor(.primary)
                                            .shadow(color: currGreenSlot == list && !editMode && showCurrentSlot ? Color(.systemBackground) : Color.clear, radius: 5)
                                            .padding()
                                            .contextMenu {
                                                if lockButtonsOn && !unlockButtons {
                                                    Button {
                                                        if !canUseBiometrics() && !canUsePassword() {
                                                            showCustomPassword = true
                                                        } else {
                                                            authenticateWithBiometrics()
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
                                                        .foregroundColor(Color(.systemGray))
                                                }
                                                
                                                Text(currSheet.currGrid[list].currLabel)
                                                    .lineLimit(1)
                                                    .minimumScaleFactor(0.01)
                                                    .font(.system(size: 30, weight: .bold, design: .rounded))
                                            }
                                            .foregroundColor(.primary)
                                            .padding()
                                            .contextMenu {
                                                if lockButtonsOn && !unlockButtons {
                                                    Button {
                                                        if !canUseBiometrics() && !canUsePassword() {
                                                            showCustomPassword = true
                                                        } else {
                                                            authenticateWithBiometrics()
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
                                                    } else if currSheet.currGrid[list].currIcons[slot].currIcon != "plus.viewfinder" {
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
                                                        if speakIcons { //speak the icon, handle below
                                                            if currSheet.currGrid[list].currIcons[slot].currIcon.contains("customIconObject:") {
                                                                speechSynthesizer.speak(extractKey(from: currSheet.currGrid[list].currIcons[slot].currIcon))
                                                            } else {
                                                                speechSynthesizer.speak(currSheet.currGrid[list].currIcons[slot].currIcon)
                                                            }
                                                        }
                                                    }
                                                }) {
                                                    if currSheet.currGrid[list].currIcons[slot].currIcon == "plus.viewfinder" { //if there isnt an icon
                                                        if #available(iOS 15.0, *) {
                                                            Image(systemName: "plus.viewfinder")
                                                                .resizable()
                                                                .scaledToFit()
                                                                .symbolRenderingMode(.hierarchical)
                                                                .foregroundColor(editMode ? Color(.systemGray) : .clear)
                                                        } else {
                                                            Image(systemName: "plus.viewfinder")
                                                                .resizable()
                                                                .scaledToFit()
                                                                .foregroundColor(editMode ? Color(.systemGray) : .clear)
                                                        }
                                                    } else {
                                                        ZStack {
                                                            if currSheet.currGrid[list].currIcons[slot].currIcon.contains("customIconObject:") {
                                                                //check if default icon or custom icon and handle
                                                                getCustomIconSmall(currSheet.currGrid[list].currIcons[slot].currIcon)
                                                                    .scaledToFit()
                                                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                                                    .overlay(
                                                                        RoundedRectangle(cornerRadius: 16)
                                                                            .stroke(.black, lineWidth: 6)
                                                                    )
                                                            } else {
                                                                loadImage(named: currSheet.currGrid[list].currIcons[slot].currIcon)
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
                                                                            .foregroundColor(Color(.systemGray2))
                                                                            .padding(.trailing, horizontalSizeClass == .compact ? 5 : 10)
                                                                            .padding(.bottom, horizontalSizeClass == .compact ? 5 : 10)
                                                                    }
                                                                    Spacer()
                                                                }
                                                                Spacer()
                                                            }
                                                        }
                                                    }
                                                }
                                                .contextMenu {
                                                    if lockButtonsOn && !unlockButtons {
                                                        Button {
                                                            if !canUseBiometrics() && !canUsePassword() {
                                                                showCustomPassword = true
                                                            } else {
                                                                authenticateWithBiometrics()
                                                            }
                                                        } label: {
                                                            Label("Unlock Buttons", systemImage: "lock.open")
                                                        }
                                                    } else {
                                                        if currSheet.currGrid[list].currIcons[slot].currIcon == "plus.viewfinder" {
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
                                                                
                                                                if #available(iOS 15.0, *) {
                                                                    Button(role: .destructive) {
                                                                        currSheet.currGrid[list].currIcons[slot].currIcon = "plus.viewfinder"
                                                                        currSheet.currGrid[list].currIcons[slot].currDetails = []
                                                                        animate.toggle()
                                                                    } label: {
                                                                        Label("Delete Icon", systemImage: "trash")
                                                                    }
                                                                } else {
                                                                    Button {
                                                                        currSheet.currGrid[list].currIcons[slot].currIcon = "plus.viewfinder"
                                                                        currSheet.currGrid[list].currIcons[slot].currDetails = []
                                                                        animate.toggle()
                                                                    } label: {
                                                                        Label("Delete Icon", systemImage: "trash")
                                                                    }
                                                                }
                                                                
                                                            } else {
                                                                Button {
                                                                    unlockButtons = false
                                                                    animate.toggle()
                                                                    removedIcons.append(currSheet.currGrid[list].currIcons[slot])
                                                                    currSheet.currGrid[list].currIcons[slot].currIcon = "plus.viewfinder"
                                                                    currSheet.currGrid[list].currIcons[slot].currDetails = []
                                                                    currSheet.removedIcons = removedIcons
                                                                    var newArray = loadSheetArray()
                                                                    newArray[getCurrSheetIndex()] = currSheet
                                                                    newArray[getCurrSheetIndex()] = autoRemoveSlots(newArray[getCurrSheetIndex()])
                                                                    currSheet = newArray[getCurrSheetIndex()]
                                                                    saveSheetArray(sheetObjects: newArray)
                                                                } label: {
                                                                    Label("Remove Icon", systemImage: "square.slash")
                                                                }
                                                                
                                                                Button {
                                                                    unlockButtons = false
                                                                    animate.toggle()
                                                                    completedIcons.append(currSheet.currGrid[list].currIcons[slot])
                                                                    currSheet.currGrid[list].currIcons[slot].currIcon = "plus.viewfinder"
                                                                    currSheet.currGrid[list].currIcons[slot].currDetails = []
                                                                    currSheet.completedIcons = completedIcons
                                                                    var newArray = loadSheetArray()
                                                                    newArray[getCurrSheetIndex()] = currSheet
                                                                    newArray[getCurrSheetIndex()] = autoRemoveSlots(newArray[getCurrSheetIndex()])
                                                                    currSheet = newArray[getCurrSheetIndex()]
                                                                    saveSheetArray(sheetObjects: newArray)
                                                                } label: {
                                                                    Label("Complete Icon", systemImage: "checkmark")
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                                .padding()
                                            }
                                        }
                                        if editMode {
                                            Button(action: {
                                                if !deleteAnimationFix {
                                                    
                                                    deleteAnimationFix = true //if you spam click delete on the last row on iPad, it will try to delete through the animation which results in a crash from attempting to delete an index that doesnt exist. This is just a hacky fix that doesnt let you delete things less than one second apart (which shouldnt be an issue anyways)
                                                    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
                                                        deleteAnimationFix = false
                                                    }
                                                    
                                                    if currSheet.currGrid.count > 1 {
                                                        animate.toggle()
                                                        currSheet.currGrid.remove(at: list)
                                                    } else {
                                                        currSheet.currGrid.removeAll()
                                                        currSheet.currGrid.append(GridSlot(currLabel: currSheet.gridType))
                                                    }
                                                }
                                                
                                            }) {
                                                if #available(iOS 15.0, *) {
                                                    Image(systemName: "trash.square.fill")
                                                        .resizable()
                                                        .frame(width: 75, height: 75)
                                                        .padding()
                                                        .symbolRenderingMode(.hierarchical)
                                                        .foregroundColor(.red)
                                                } else {
                                                    Image(systemName: "trash.square.fill")
                                                        .resizable()
                                                        .frame(width: 75, height: 75)
                                                        .padding()
                                                        .foregroundColor(.red)
                                                }
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
                                            .foregroundColor(Color(.systemGray4))
                                    }
                                    VStack {
                                        LazyVGrid(columns: Array(repeating: GridItem(), count: editMode ? 6 : 5)) { //this is the main grid for the app
                                            ForEach(0..<currSheet.currGrid.count, id: \.self) { list in
                                                if currSheet.gridType == "time" {
                                                    ZStack {
                                                        RoundedRectangle(cornerRadius: 20)
                                                            .foregroundColor(currGreenSlot == list && !editMode && showCurrentSlot ? .green : .clear)
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
                                                                        .foregroundColor(Color(.systemGray))
                                                                }
                                                                
                                                                Text(getTime(date: currSheet.currGrid[list].currTime))
                                                                    .lineLimit(1)
                                                                    .minimumScaleFactor(0.01)
                                                                    .font(.system(size: 100, weight: .bold, design: .rounded))
                                                            }
                                                        }
                                                        .foregroundColor(.primary)
                                                        .shadow(color: currGreenSlot == list && !editMode && showCurrentSlot ? Color(.systemBackground) : Color.clear, radius: 5)
                                                        .padding()
                                                        .contextMenu {
                                                            if lockButtonsOn && !unlockButtons {
                                                                Button {
                                                                    if !canUseBiometrics() && !canUsePassword() {
                                                                        showCustomPassword = true
                                                                    } else {
                                                                        authenticateWithBiometrics()
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
                                                                    .foregroundColor(Color(.systemGray))
                                                            }
                                                            
                                                            Text(currSheet.currGrid[list].currLabel)
                                                                .lineLimit(1)
                                                                .minimumScaleFactor(0.01)
                                                                .font(.system(size: 100, weight: .bold, design: .rounded))
                                                        }
                                                    }
                                                    .foregroundColor(.primary)
                                                    .padding(horizontalSizeClass == .compact ? 3 : 10)
                                                    .contextMenu {
                                                        if lockButtonsOn && !unlockButtons {
                                                            Button {
                                                                if !canUseBiometrics() && !canUsePassword() {
                                                                    showCustomPassword = true
                                                                } else {
                                                                    authenticateWithBiometrics()
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
                                                ForEach(0..<currSheet.currGrid[list].currIcons.count, id: \.self) { slot in //this loop displays the slots/images
                                                    Button(action: {
                                                        if editMode {
                                                            currListIndex = list
                                                            currSlotIndex = slot
                                                            showIcons.toggle()
                                                            searchText = ""
                                                        } else if currSheet.currGrid[list].currIcons[slot].currIcon != "plus.viewfinder" {
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
                                                            if speakIcons { //speak the icon, handle below
                                                                if currSheet.currGrid[list].currIcons[slot].currIcon.contains("customIconObject:") {
                                                                    speechSynthesizer.speak(extractKey(from: currSheet.currGrid[list].currIcons[slot].currIcon))
                                                                } else {
                                                                    speechSynthesizer.speak(currSheet.currGrid[list].currIcons[slot].currIcon)
                                                                }
                                                            }
                                                        }
                                                    }) {
                                                        if currSheet.currGrid[list].currIcons[slot].currIcon == "plus.viewfinder" { //if there isnt an icon
                                                            if #available(iOS 15.0, *) {
                                                                Image(systemName: "plus.viewfinder")
                                                                    .resizable()
                                                                    .scaledToFit()
                                                                    .padding(10)
                                                                    .symbolRenderingMode(.hierarchical)
                                                                    .foregroundColor(editMode ? Color(.systemGray) : .clear)
                                                            } else {
                                                                Image(systemName: "plus.viewfinder")
                                                                    .resizable()
                                                                    .scaledToFit()
                                                                    .padding(10)
                                                                    .foregroundColor(editMode ? Color(.systemGray) : .clear)
                                                            }
                                                        } else {
                                                            ZStack {
                                                                if currSheet.currGrid[list].currIcons[slot].currIcon.contains("customIconObject:") {
                                                                    //check if default icon or custom icon and handle
                                                                    getCustomIconSmall(currSheet.currGrid[list].currIcons[slot].currIcon)
                                                                        .scaledToFit()
                                                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                                                        .overlay(
                                                                            RoundedRectangle(cornerRadius: 16)
                                                                                .stroke(currGreenSlot == list && !editMode && showCurrentSlot ? .green : .black, lineWidth: currGreenSlot == list && showCurrentSlot ? 10 : 6)
                                                                        )
                                                                        .padding(horizontalSizeClass == .compact ? 0 : 5)
                                                                } else {
                                                                    loadImage(named: currSheet.currGrid[list].currIcons[slot].currIcon)
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
                                                                                .foregroundColor(Color(.systemGray2))
                                                                                .padding(.trailing, horizontalSizeClass == .compact ? 5 : 10)
                                                                                .padding(.bottom, horizontalSizeClass == .compact ? 5 : 10)
                                                                        }
                                                                        Spacer()
                                                                    }
                                                                    Spacer()
                                                                }
                                                            }
                                                        }
                                                    }
                                                    .contextMenu {
                                                        if lockButtonsOn && !unlockButtons {
                                                            Button {
                                                                if !canUseBiometrics() && !canUsePassword() {
                                                                    showCustomPassword = true
                                                                } else {
                                                                    authenticateWithBiometrics()
                                                                }
                                                            } label: {
                                                                Label("Unlock Buttons", systemImage: "lock.open")
                                                            }
                                                        } else {
                                                            if currSheet.currGrid[list].currIcons[slot].currIcon == "plus.viewfinder" {
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
                                                                    
                                                                    if #available(iOS 15.0, *) {
                                                                        Button(role: .destructive) {
                                                                            currSheet.currGrid[list].currIcons[slot].currIcon = "plus.viewfinder"
                                                                            currSheet.currGrid[list].currIcons[slot].currDetails = []
                                                                            animate.toggle()
                                                                        } label: {
                                                                            Label("Delete Icon", systemImage: "trash")
                                                                        }
                                                                    } else {
                                                                        Button {
                                                                            currSheet.currGrid[list].currIcons[slot].currIcon = "plus.viewfinder"
                                                                            currSheet.currGrid[list].currIcons[slot].currDetails = []
                                                                            animate.toggle()
                                                                        } label: {
                                                                            Label("Delete Icon", systemImage: "trash")
                                                                        }
                                                                    }
                                                                    
                                                                } else {
                                                                    Button {
                                                                        unlockButtons = false
                                                                        animate.toggle()
                                                                        removedIcons.append(currSheet.currGrid[list].currIcons[slot])
                                                                        currSheet.currGrid[list].currIcons[slot].currIcon = "plus.viewfinder"
                                                                        currSheet.currGrid[list].currIcons[slot].currDetails = []
                                                                        currSheet.removedIcons = removedIcons
                                                                        var newArray = loadSheetArray()
                                                                        newArray[getCurrSheetIndex()] = currSheet
                                                                        newArray[getCurrSheetIndex()] = autoRemoveSlots(newArray[getCurrSheetIndex()])
                                                                        currSheet = newArray[getCurrSheetIndex()]
                                                                        saveSheetArray(sheetObjects: newArray)
                                                                    } label: {
                                                                        Label("Remove Icon", systemImage: "square.slash")
                                                                    }
                                                                    
                                                                    Button {
                                                                        unlockButtons = false
                                                                        animate.toggle()
                                                                        completedIcons.append(currSheet.currGrid[list].currIcons[slot])
                                                                        currSheet.currGrid[list].currIcons[slot].currIcon = "plus.viewfinder"
                                                                        currSheet.currGrid[list].currIcons[slot].currDetails = []
                                                                        currSheet.completedIcons = completedIcons
                                                                        var newArray = loadSheetArray()
                                                                        newArray[getCurrSheetIndex()] = currSheet
                                                                        newArray[getCurrSheetIndex()] = autoRemoveSlots(newArray[getCurrSheetIndex()])
                                                                        currSheet = newArray[getCurrSheetIndex()]
                                                                        saveSheetArray(sheetObjects: newArray)
                                                                    } label: {
                                                                        Label("Complete Icon", systemImage: "checkmark")
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                                if editMode {
                                                    Button(action: {
                                                        if !deleteAnimationFix {
                                                            
                                                            deleteAnimationFix = true //if you spam click delete on the last row on iPad, it will try to delete through the animation which results in a crash from attempting to delete an index that doesnt exist. This is just a hacky fix that doesnt let you delete things less than one second apart (which shouldnt be an issue anyways)
                                                            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
                                                                deleteAnimationFix = false
                                                            }
                                                            
                                                            if currSheet.currGrid.count > 1 {
                                                                animate.toggle()
                                                                currSheet.currGrid.remove(at: list)
                                                            } else {
                                                                currSheet.currGrid.removeAll()
                                                                currSheet.currGrid.append(GridSlot(currLabel: currSheet.gridType))
                                                            }
                                                        }
                                                    }) {
                                                        if #available(iOS 15.0, *) {
                                                            Image(systemName: "trash.square.fill")
                                                                .resizable()
                                                                .scaledToFit()
                                                                .padding()
                                                                .symbolRenderingMode(.hierarchical)
                                                                .foregroundColor(.red)
                                                        } else {
                                                            Image(systemName: "trash.square.fill")
                                                                .resizable()
                                                                .scaledToFit()
                                                                .padding()
                                                                .foregroundColor(.red)
                                                        }
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
                                currSheet.currGrid.append(GridSlot(currLabel: currSheet.currGrid.count < 1 ? "First" : "Then"))
                                animate.toggle()
                            }) {
                                Image(systemName:"plus.square.fill")
                                    .resizable()
                                    .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                //.fontWeight(.bold)
                                    .foregroundColor(.green)
                                    .padding()
                            }
                        }
                        Rectangle() //this was originally when plus and minus were in bottom row, you can id this rectangle and use it to scroll to button
                            .foregroundColor(.clear)
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
                            createNewSheet = true
                        }
                    }
                    updateUsage("action:open")
                    if showCurrentSlot {
                        let currentDate = Date()
                        let secondsUntilNextMinute = 60 - Calendar.current.component(.second, from: currentDate)
                        let delayInSeconds = TimeInterval(secondsUntilNextMinute)
                        
                        Timer.scheduledTimer(withTimeInterval: delayInSeconds, repeats: true) { _ in
                            currGreenSlot = loadSheetArray()[getCurrSheetIndex()].getCurrSlot()
                            animate.toggle()
                        }
                    }
                    defaults.set(false, forKey: "aiOn") //temporarily for now to make sure nobody can access prerelease features. removed the functions anyways but still
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
                                     //.fontWeight(.bold)
                                         .foregroundColor(.red)
                                         .padding()
                                 }
                                 
                                 Button(action: { //saves the array and disables edit mode
                                     if currSheet.gridType == "time" {
                                         currSheet.currGrid = sortSheet(currSheet.currGrid)
                                     }
                                     currSheet.label = currTitleText
                                     var newSheetArray = loadSheetArray()
                                     newSheetArray[getCurrSheetIndex()] = currSheet
                                     newSheetArray[getCurrSheetIndex()] = autoRemoveSlots(newSheetArray[getCurrSheetIndex()])
                                     currSheet = newSheetArray[getCurrSheetIndex()]
                                     saveSheetArray(sheetObjects: newSheetArray)
                                     animate.toggle()
                                     manageNotifications()
                                     editMode.toggle()
                                 }) {
                                     Image(systemName:"checkmark.square.fill")
                                         .resizable()
                                         .frame(width: 75, height: 75)
                                         .foregroundColor(.green)
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
                                         authenticateWithBiometrics()
                                     }
                                 }) {
                                     Image(systemName: "lock.square")
                                         .resizable()
                                         .padding()
                                         .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                         .foregroundColor(Color(.systemGray))
                                 }
                                 .padding()
                             } else {
                                 VStack {
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
                                                         .foregroundColor(.purple)
                                                     Image(systemName: "square.grid.2x2")
                                                         .resizable()
                                                         .frame(width: min(30, 75), height: min(30, 75))
                                                         .foregroundColor(Color(.systemBackground))
                                                 }
                                                 Text("All Sheets")
                                                     .font(.system(size: 18, weight: .semibold, design: .rounded))
                                                     .foregroundColor(.purple)
                                             }
                                         }
                                         .buttonStyle(PlainButtonStyle())
                                         .padding(.leading)
                                         .padding(.trailing)
                                         
                                         Button(action: {
                                             if sheetArray.count > 1 {
                                                 editMode.toggle()
                                                 currTitleText = currSheet.label
                                                 animate.toggle()
                                             }
                                             unlockButtons = false
                                         }) {
                                             VStack {
                                                 ZStack {
                                                     Image(systemName: "square.fill")
                                                         .resizable()
                                                         .frame(width: 65, height: 65)
                                                         .foregroundColor(.blue)
                                                     Image(systemName: "pencil")
                                                         .resizable()
                                                         .frame(width: min(30, 75), height: min(30, 75))
                                                     //.fontWeight(.heavy)
                                                         .foregroundColor(Color(.systemBackground))
                                                 }
                                                 Text("Edit")
                                                     .font(.system(size: 18, weight: .semibold, design: .rounded))
                                                     .foregroundColor(.blue)
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
                                         .foregroundColor(Color(.systemGray2))
                                         .buttonStyle(PlainButtonStyle())
                                         .padding(.leading)
                                         .padding(.trailing)
                                         
                                     }
                                     if showMore {
                                         HStack {
                                             Button(action: {
                                                 showRemoved.toggle()
                                                 unlockButtons = false
                                             }) {
                                                 VStack {
                                                     ZStack {
                                                         Image(systemName: "folder.fill")
                                                             .resizable()
                                                             .frame(width: 65, height: 65)
                                                             .foregroundColor(.red)
                                                         Image(systemName: "square.slash")
                                                             .resizable()
                                                             .frame(width: min(20, 30), height: min(20, 30))
                                                             .padding(.top)
                                                             .foregroundColor(Color(.systemBackground))
                                                     }
                                                     Text("Removed")
                                                         .font(.system(size: 18, weight: .semibold, design: .rounded))
                                                         .foregroundColor(.red)
                                                 }
                                             }
                                             .buttonStyle(PlainButtonStyle())
                                             .padding([.leading, .trailing])
                                             
                                             Button(action: {
                                                 showCompleted.toggle()
                                                 unlockButtons = false
                                             }) {
                                                 VStack {
                                                     ZStack {
                                                         Image(systemName: "folder.fill")
                                                             .resizable()
                                                             .frame(width: 65, height: 65)
                                                             .foregroundColor(.green)
                                                         Image(systemName: "checkmark")
                                                             .resizable()
                                                             .frame(width: min(20, 30), height: min(20, 30))
                                                             .padding(.top)
                                                             .foregroundColor(Color(.systemBackground))
                                                     }
                                                     Text("Completed")
                                                         .font(.system(size: 18, weight: .semibold, design: .rounded))
                                                         .foregroundColor(.green)
                                                 }
                                             }
                                             .buttonStyle(PlainButtonStyle())
                                             .padding()
                                             
                                             Button(action: {
                                                 showSettings.toggle()
                                             }) {
                                                 VStack {
                                                     ZStack {
                                                         Image(systemName: "square.fill")
                                                             .resizable()
                                                             .frame(width: 65, height: 65)
                                                             .foregroundColor(Color(.systemGray))
                                                         Image(systemName: "gear")
                                                             .resizable()
                                                             .frame(width: min(30, 75), height: min(30, 75))
                                                             .foregroundColor(Color(.systemBackground))
                                                     }
                                                     Text("Settings")
                                                         .font(.system(size: 18, weight: .semibold, design: .rounded))
                                                         .foregroundColor(Color(.systemGray))
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
                                     //.fontWeight(.bold)
                                         .foregroundColor(.red)
                                         .padding()
                                 }
                                 
                                 Button(action: { //saves the array and disables edit mode
                                     if currSheet.gridType == "time" {
                                         currSheet.currGrid = sortSheet(currSheet.currGrid)
                                     }
                                     currSheet.label = currTitleText
                                     var newSheetArray = loadSheetArray()
                                     newSheetArray[getCurrSheetIndex()] = currSheet
                                     newSheetArray[getCurrSheetIndex()] = autoRemoveSlots(newSheetArray[getCurrSheetIndex()])
                                     currSheet = newSheetArray[getCurrSheetIndex()]
                                     saveSheetArray(sheetObjects: newSheetArray)
                                     animate.toggle()
                                     manageNotifications()
                                     editMode.toggle()
                                     
                                 }) { //sheetobject isnt equatable rn, this is the desired behavior:
                                     /*
                                      if currSheet == loadSheetArray()[getCurrSheetIndex()] {
                                      Image(systemName:"xmark.square.fill")
                                      .resizable()
                                      .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                      .foregroundColor(Color(.systemGray))
                                      .padding()
                                      } else { */
                                     Image(systemName:"checkmark.square.fill")
                                         .resizable()
                                         .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                         .foregroundColor(.green)
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
                                         authenticateWithBiometrics()
                                     }
                                 }) {
                                     Image(systemName: "lock.square")
                                         .resizable()
                                         .padding()
                                         .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                         .foregroundColor(Color(.systemGray))
                                 }
                                 .padding()
                             } else {
                                 HStack {
                                     Button(action: {
                                         showRemoved.toggle()
                                         unlockButtons = false
                                     }) {
                                         VStack {
                                             ZStack {
                                                 Image(systemName: "folder.fill")
                                                     .resizable()
                                                     .frame(width: 75, height: 75)
                                                     .foregroundColor(.red)
                                                 Image(systemName: "square.slash")
                                                     .resizable()
                                                     .frame(width: min(25, 35), height: min(25, 35))
                                                     .padding(.top)
                                                     .foregroundColor(Color(.systemBackground))
                                             }
                                             Text("Removed")
                                                 .font(.system(size: 18, weight: .semibold, design: .rounded))
                                                 .foregroundColor(.red)
                                         }
                                     }
                                     .buttonStyle(PlainButtonStyle())
                                     .padding()
                                     
                                     Button(action: {
                                         showCompleted.toggle()
                                         unlockButtons = false
                                     }) {
                                         VStack {
                                             ZStack {
                                                 Image(systemName: "folder.fill")
                                                     .resizable()
                                                     .frame(width: 75, height: 75)
                                                     .foregroundColor(.green)
                                                 Image(systemName: "checkmark")
                                                     .resizable()
                                                     .frame(width: min(25, 35), height: min(25, 35))
                                                     .padding(.top)
                                                     .foregroundColor(Color(.systemBackground))
                                             }
                                             Text("Completed")
                                                 .font(.system(size: 18, weight: .semibold, design: .rounded))
                                                 .foregroundColor(.green)
                                         }
                                     }
                                     .buttonStyle(PlainButtonStyle())
                                     .padding()
                                     
                                     Button(action: {
                                         showAllSheets.toggle()
                                         sheetArray = loadSheetArray()
                                         unlockButtons = false
                                     }) {
                                         VStack {
                                             ZStack {
                                                 Image(systemName: "square.fill")
                                                     .resizable()
                                                     .frame(width: 75, height: 75)
                                                     .foregroundColor(.purple)
                                                 Image(systemName: "square.grid.2x2")
                                                     .resizable()
                                                     .frame(width: min(40, 100), height: min(40, 100))
                                                     .foregroundColor(Color(.systemBackground))
                                             }
                                             Text("All Sheets")
                                                 .font(.system(size: 18, weight: .semibold, design: .rounded))
                                                 .foregroundColor(.purple)
                                         }
                                     }
                                     .buttonStyle(PlainButtonStyle())
                                     .padding()
                                     
                                     Button(action: {
                                         showSettings.toggle()
                                     }) {
                                         VStack {
                                             ZStack {
                                                 Image(systemName: "square.fill")
                                                     .resizable()
                                                     .frame(width: 75, height: 75)
                                                     .foregroundColor(Color(.systemGray))
                                                 Image(systemName: "gear")
                                                     .resizable()
                                                     .frame(width: min(40, 100), height: min(40, 100))
                                                     .foregroundColor(Color(.systemBackground))
                                             }
                                             Text("Settings")
                                                 .font(.system(size: 18, weight: .semibold, design: .rounded))
                                                 .foregroundColor(Color(.systemGray))
                                         }
                                     }
                                     .buttonStyle(PlainButtonStyle())
                                     .padding()
                                     
                                     /*
                                     Button(action: {
                                         showCommunication.toggle()
                                         unlockButtons = false
                                     }) {
                                         VStack {
                                             ZStack {
                                                 Image(systemName: "square.fill")
                                                     .resizable()
                                                     .frame(width: 75, height: 75)
                                                     .foregroundColor(.orange)
                                                 Image(systemName: "message.badge.waveform.fill")
                                                     .resizable()
                                                     .frame(width: min(50, 100), height: min(40, 100))
                                                     .foregroundColor(Color(.systemBackground))
                                             }
                                             Text("Communicate")
                                                 .font(.system(size: 18, weight: .semibold, design: .rounded))
                                                 .foregroundColor(.orange)
                                         }
                                     }
                                     .buttonStyle(PlainButtonStyle())
                                     .padding()
                                     */
                                     Button(action: {
                                         if sheetArray.count > 1 {
                                             editMode.toggle()
                                             currTitleText = currSheet.label
                                             animate.toggle()
                                         }
                                         unlockButtons = false
                                     }) {
                                         VStack {
                                             ZStack {
                                                 Image(systemName: "square.fill")
                                                     .resizable()
                                                     .frame(width: 75, height: 75)
                                                     .foregroundColor(.blue)
                                                 Image(systemName: "pencil")
                                                     .resizable()
                                                     .frame(width: min(40, 100), height: min(40, 100))
                                                 //.fontWeight(.heavy)
                                                     .foregroundColor(Color(.systemBackground))
                                             }
                                             Text("Edit")
                                                 .font(.system(size: 18, weight: .semibold, design: .rounded))
                                                 .foregroundColor(.blue)
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
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarHidden(true)
        .sheet(isPresented: $pickIcon) {
            AllIconsPickerView(currSheet: currSheet,
                               currImage: currSheet.currLabelIcon ?? "plus.viewfinder",
                               modifyIcon: { newIcon in
                currSheet.currLabelIcon = newIcon
                
                //save array aka "autosave"
                var newSheetArray = loadSheetArray()
                newSheetArray[getCurrSheetIndex()] = currSheet
                currSheet = newSheetArray[getCurrSheetIndex()]
                saveSheetArray(sheetObjects: newSheetArray)
                
                animate.toggle()
            }, modifyDetails: { newDetails in
                //no need to modify details here
            }, modifySheet: {newSheet in
                currSheet = newSheet
            }, showCreateCustom: false)
        }
        .sheet(isPresented: $showTime) { //fullscreencover for setting times on a sheet
            TimeLabelPickerView(viewType: .time, saveItem: { item in
                if item is Date {
                    currSheet.currGrid[currListIndex].currTime = item as! Date
                    currSheet.currGrid = sortSheet(currSheet.currGrid)
                    var newSheetArray = loadSheetArray()
                    newSheetArray[getCurrSheetIndex()] = currSheet
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
                    newSheetArray[getCurrSheetIndex()] = currSheet
                    saveSheetArray(sheetObjects: newSheetArray)
                }
            }, oldLabel: $currText)
        }
        .fullScreenCover(isPresented: $showCommunication) {
            CommunicationBoardView()
        }
        .fullScreenCover(isPresented: $showIcons) {
            AllIconsPickerView(currSheet: currSheet,
                               currImage: currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currIcon,
                               modifyIcon: { newIcon in
                currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currIcon = newIcon
                animate.toggle()
            }, modifyDetails: { newDetails in
                currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currDetails = newDetails
            }, modifySheet: {newSheet in
                currSheet = newSheet
            })
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
                                    if tempDetails[detail].contains("customIconObject:") {
                                        if horizontalSizeClass == .compact {
                                            getCustomIconSmall(tempDetails[detail])
                                                .scaledToFit()
                                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .stroke(.black, lineWidth: 6)
                                                )
                                                .padding(3)
                                        } else {
                                            getCustomIcon(tempDetails[detail])
                                                .scaledToFit()
                                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .stroke(.black, lineWidth: 10)
                                                )
                                                .padding(7)
                                        }
                                    } else {
                                        loadImage(named: tempDetails[detail])
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
                                }
                            }
                        }
                    }
                    .sheet(isPresented: $showDetailsIcons) {
                        
                        AllIconsPickerView(currSheet: currSheet,
                                           currImage: detailIconIndex != -1 ? tempDetails[detailIconIndex] : "plus.viewfinder",
                                           modifyIcon: { newIcon in
                            if detailIconIndex != -1 {
                                tempDetails[detailIconIndex] = newIcon
                            } else {
                                tempDetails.append(newIcon)
                            }
                            //autosave
                            currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currDetails = tempDetails
                            var newArray = loadSheetArray()
                            newArray[getCurrSheetIndex()] = currSheet
                            newArray[getCurrSheetIndex()] = autoRemoveSlots(newArray[getCurrSheetIndex()])
                            currSheet = newArray[getCurrSheetIndex()]
                            saveSheetArray(sheetObjects: newArray)
                            
                            animate.toggle()
                        }, modifyDetails: { newDetails in
                            //no need to modify details here
                        }, modifySheet: {newSheet in
                            currSheet = newSheet
                        }, showCreateCustom: false)
                        
                    }
                } else {
                    if !tempDetails.isEmpty {
                        Divider()
                            .padding()
                    }
                    HStack {
                        ForEach(0..<tempDetails.count, id: \.self) { detail in
                            if lockButtonsOn && !unlockButtons {
                                if tempDetails[detail].contains("customIconObject:") {
                                    getCustomIcon(tempDetails[detail])
                                        .scaledToFit()
                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(.black, lineWidth: 10)
                                        )
                                        .padding()
                                } else {
                                    loadImage(named: tempDetails[detail])
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
                                    if #available(iOS 15.0, *) {
                                        Button(role: .destructive) {
                                            tempDetails.remove(at: detail)
                                            currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currDetails = tempDetails
                                            var newArray = loadSheetArray()
                                            newArray[getCurrSheetIndex()] = currSheet
                                            newArray[getCurrSheetIndex()] = autoRemoveSlots(newArray[getCurrSheetIndex()])
                                            currSheet = newArray[getCurrSheetIndex()]
                                            saveSheetArray(sheetObjects: newArray)
                                            animate.toggle()
                                        } label: {
                                            Label("Delete from Details", systemImage: "trash")
                                        }
                                    } else {
                                        Button {
                                            tempDetails.remove(at: detail)
                                            currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currDetails = tempDetails
                                            var newArray = loadSheetArray()
                                            newArray[getCurrSheetIndex()] = currSheet
                                            newArray[getCurrSheetIndex()] = autoRemoveSlots(newArray[getCurrSheetIndex()])
                                            currSheet = newArray[getCurrSheetIndex()]
                                            saveSheetArray(sheetObjects: newArray)
                                            animate.toggle()
                                        } label: {
                                            Label("Delete from Details", systemImage: "trash")
                                        }
                                    }
                                } label: {
                                    //loadImage() or getCustomIcon() depending
                                    if tempDetails[detail].contains("customIconObject:") {
                                        if horizontalSizeClass == .compact {
                                            getCustomIconSmall(tempDetails[detail])
                                                .scaledToFit()
                                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .stroke(.black, lineWidth: 6)
                                                )
                                                .padding()
                                        } else {
                                            getCustomIcon(tempDetails[detail])
                                                .scaledToFit()
                                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .stroke(.black, lineWidth: 10)
                                                )
                                                .padding()
                                        }
                                    } else {
                                        loadImage(named: tempDetails[detail])
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
                                //.fontWeight(.bold)
                                Text("Cancel")
                                    .font(.system(size: horizontalSizeClass == .compact ? 15 : 25, weight: .semibold, design: .rounded))
                            }
                        }
                        .padding()
                        .foregroundColor(Color(.systemGray))
                        if lockButtonsOn && !unlockButtons {
                            Button(action: {
                                if !canUseBiometrics() && !canUsePassword() {
                                    animate.toggle()
                                    showCustomPassword = true
                                    showMod = false
                                    wasShowingMod = true
                                } else {
                                    authenticateWithBiometrics()
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
                            .foregroundColor(Color(.systemGray))
                        } else {
                            Button(action: {
                                showMod.toggle()
                                unlockButtons = false
                                updateUsage(currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currIcon)
                                removedIcons.append(currSheet.currGrid[currListIndex].currIcons[currSlotIndex])
                                currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currIcon = "plus.viewfinder"
                                currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currDetails = []
                                currSheet.removedIcons = removedIcons
                                var newArray = loadSheetArray()
                                newArray[getCurrSheetIndex()] = currSheet
                                newArray[getCurrSheetIndex()] = autoRemoveSlots(newArray[getCurrSheetIndex()])
                                currSheet = newArray[getCurrSheetIndex()]
                                saveSheetArray(sheetObjects: newArray)
                                animate.toggle()
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
                                    Text(tempDetails.isEmpty ? "Remove Icon" : "Remove All")
                                        .font(.system(size: horizontalSizeClass == .compact ? 15 : 25, weight: .semibold, design: .rounded))
                                }
                            }
                            .padding()
                            .foregroundColor(.red)
                            
                            Button(action: {
                                showMod.toggle()
                                unlockButtons = false
                                updateUsage(currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currIcon)
                                completedIcons.append(currSheet.currGrid[currListIndex].currIcons[currSlotIndex])
                                currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currIcon = "plus.viewfinder"
                                currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currDetails = []
                                currSheet.completedIcons = completedIcons
                                var newArray = loadSheetArray()
                                newArray[getCurrSheetIndex()] = currSheet
                                newArray[getCurrSheetIndex()] = autoRemoveSlots(newArray[getCurrSheetIndex()])
                                currSheet = newArray[getCurrSheetIndex()]
                                saveSheetArray(sheetObjects: newArray)
                                animate.toggle()
                            }) {
                                VStack {
                                    Image(systemName: "checkmark.square.fill")
                                        .resizable()
                                        .frame(width: horizontalSizeClass == .compact ? min(100, 350) : min(150, 500), height: horizontalSizeClass == .compact ? min(100, 350) : min(150, 500))
                                    //.fontWeight(.bold)
                                    Text(tempDetails.isEmpty ? "Complete Icon" : "Complete All")
                                        .font(.system(size: horizontalSizeClass == .compact ? 15 : 25, weight: .semibold, design: .rounded))
                                }
                            }
                            .padding()
                            .foregroundColor(.green)
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
                                    .foregroundColor(Color(.systemGray))
                            } else {
                                Image(systemName:"checkmark.square.fill")
                                    .resizable()
                                    .frame(width: horizontalSizeClass == .compact ? min(100, 350) : min(150, 500), height: horizontalSizeClass == .compact ? min(100, 350) : min(150, 500))
                                    .foregroundColor(.green)
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showSettings) { //fullscreencover for the settings page
                SettingsView(onDismiss: {
                    lockButtonsOn = defaults.bool(forKey: "buttonsOn")
                    showCurrentSlot = defaults.bool(forKey: "showCurrSlot")
                    unlockButtons = false
                    speakIcons = defaults.bool(forKey: "speakOn")
                    currSheet = autoRemoveSlots(currSheet)
                    if showCurrentSlot {
                        currGreenSlot = loadSheetArray()[getCurrSheetIndex()].getCurrSlot()
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
        .fullScreenCover(isPresented: $showCompleted) { //fullscreencover that shows completed icons
            ZStack {
                ScrollView {
                    HStack {
                        Text("\(Image(systemName: "checkmark")) Completed Icons")
                            .lineLimit(1)
                            .minimumScaleFactor(0.01)
                            .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                            .padding()
                        if horizontalSizeClass == .compact {
                            Spacer()
                            Button(action: {
                                showCompleted.toggle()
                            }) {
                                Text("\(Image(systemName: "xmark.circle.fill"))")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                    .font(.system(size: 30, weight: .bold, design: .rounded))
                                    .foregroundColor(loadSheetArray().count > 1 ? Color(.systemGray3): Color(.systemGray6))
                                    .padding(.trailing)
                            }
                        }
                    }
                    Picker(selection: $iconsSelection, label: Text("")) {
                                Text("This Sheet").tag(0)
                                Text("All Sheets").tag(1)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding()
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: horizontalSizeClass == .compact ? 100 : 150))], spacing: horizontalSizeClass == .compact ? 0 : 20) {
                        if iconsSelection == 0 {
                            ForEach(0..<completedIcons.count, id: \.self) { index in
                                ZStack {
                                    if completedIcons[index].currIcon.contains("customIconObject:") {
                                        getCustomIconSmall(completedIcons[index].currIcon)
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(lineWidth: 3)
                                            )
                                            .scaledToFit()
                                    } else {
                                        loadImage(named: completedIcons[index].currIcon)
                                            .resizable()
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(lineWidth: 3)
                                            )
                                            .scaledToFit()
                                    }
                                }
                                .contextMenu {
                                    if #available(iOS 15.0, *) {
                                        Button(role: .destructive) {
                                            completedIcons = completedIcons.filter { $0.currIcon != completedIcons[index].currIcon }
                                            currSheet.completedIcons = completedIcons
                                            var newArray = loadSheetArray()
                                            newArray[getCurrSheetIndex()] = currSheet
                                            currSheet = newArray[getCurrSheetIndex()]
                                            saveSheetArray(sheetObjects: newArray)
                                            animate.toggle()
                                        } label: {
                                            Label("Delete from 'Completed Icons'", systemImage: "trash")
                                        }
                                    } else {
                                        Button {
                                            completedIcons = completedIcons.filter { $0.currIcon != completedIcons[index].currIcon }
                                            currSheet.completedIcons = completedIcons
                                            var newArray = loadSheetArray()
                                            newArray[getCurrSheetIndex()] = currSheet
                                            currSheet = newArray[getCurrSheetIndex()]
                                            saveSheetArray(sheetObjects: newArray)
                                            animate.toggle()
                                        } label: {
                                            Label("Delete from 'Completed Icons'", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        } else if iconsSelection == 1 {
                            ForEach(0..<allCompletedIcons.count, id: \.self) { index in
                                ZStack {
                                    if allCompletedIcons[index].currIcon.contains("customIconObject:") {
                                        getCustomIconSmall(allCompletedIcons[index].currIcon)
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(lineWidth: 3)
                                            )
                                            .scaledToFit()
                                    } else {
                                        loadImage(named: allCompletedIcons[index].currIcon)
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
                    }
                    .padding(.bottom, 150)
                    Spacer()
                    if iconsSelection == 0 && completedIcons.isEmpty {
                        Text("You don't have any completed icons yet. Once you complete an icon from \(currSheet.label.isEmpty ? "the current sheet" : currSheet.label), it will appear here.")
                            .minimumScaleFactor(0.01)
                            .multilineTextAlignment(.center)
                            .font(.system(size: horizontalSizeClass == .compact ? 15 : 30, weight: .bold, design: .rounded))
                            .foregroundColor(Color(.systemGray))
                            .padding()
                            .padding()
                        Spacer()
                    } else if iconsSelection == 1 && allCompletedIcons.isEmpty {
                        Text("You don't have any completed icons yet. Once you complete an icon from any of your Sheets, it will appear here.")
                            .minimumScaleFactor(0.01)
                            .multilineTextAlignment(.center)
                            .font(.system(size: horizontalSizeClass == .compact ? 15 : 30, weight: .bold, design: .rounded))
                            .foregroundColor(Color(.systemGray))
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
                                showCompleted.toggle()
                            }) {
                                Image(systemName:"xmark.square.fill")
                                    .resizable()
                                    .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                    .foregroundColor(Color(.systemGray))
                                //.fontWeight(.bold)
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
            .animation(.spring)
            .onAppear {
                allCompletedIcons = getAllCompleted()
            }
        }
        .fullScreenCover(isPresented: $showRemoved) { //fullscreencover for removed icons
            ZStack {
                ScrollView {
                    HStack {
                        Text("\(Image(systemName: "checkmark")) Removed Icons")
                            .lineLimit(1)
                            .minimumScaleFactor(0.01)
                            .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                            .padding()
                        if horizontalSizeClass == .compact {
                            Spacer()
                            Button(action: {
                                showRemoved.toggle()
                            }) {
                                Text("\(Image(systemName: "xmark.circle.fill"))")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                    .font(.system(size: 30, weight: .bold, design: .rounded))
                                    .foregroundColor(loadSheetArray().count > 1 ? Color(.systemGray3): Color(.systemGray6))
                                    .padding(.trailing)
                            }
                        }
                    }
                    Picker(selection: $iconsSelection, label: Text("")) {
                                Text("This Sheet").tag(0)
                                Text("All Sheets").tag(1)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding()
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: horizontalSizeClass == .compact ? 100 : 150))], spacing: horizontalSizeClass == .compact ? 0 : 20) {
                        if iconsSelection == 0 {
                            ForEach(0..<removedIcons.count, id: \.self) { index in
                                ZStack {
                                    if removedIcons[index].currIcon.contains("customIconObject:") {
                                        getCustomIconSmall(removedIcons[index].currIcon)
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(lineWidth: 3)
                                            )
                                            .scaledToFit()
                                    } else {
                                        loadImage(named: removedIcons[index].currIcon)
                                            .resizable()
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(lineWidth: 3)
                                            )
                                            .scaledToFit()
                                    }
                                }
                                .contextMenu {
                                    if #available(iOS 15.0, *) {
                                        Button(role: .destructive) {
                                            removedIcons = removedIcons.filter { $0.currIcon != removedIcons[index].currIcon }
                                            currSheet.removedIcons = removedIcons
                                            var newArray = loadSheetArray()
                                            newArray[getCurrSheetIndex()] = currSheet
                                            currSheet = newArray[getCurrSheetIndex()]
                                            saveSheetArray(sheetObjects: newArray)
                                            animate.toggle()
                                        } label: {
                                            Label("Delete from 'Removed Icons'", systemImage: "trash")
                                        }
                                    } else {
                                        Button {
                                            removedIcons = removedIcons.filter { $0.currIcon != removedIcons[index].currIcon }
                                            currSheet.removedIcons = removedIcons
                                            var newArray = loadSheetArray()
                                            newArray[getCurrSheetIndex()] = currSheet
                                            currSheet = newArray[getCurrSheetIndex()]
                                            saveSheetArray(sheetObjects: newArray)
                                            animate.toggle()
                                        } label: {
                                            Label("Delete from 'Removed Icons'", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        } else if iconsSelection == 1 {
                            ForEach(0..<allRemovedIcons.count, id: \.self) { index in
                                ZStack {
                                    if allRemovedIcons[index].currIcon.contains("customIconObject:") {
                                        getCustomIconSmall(allRemovedIcons[index].currIcon)
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(lineWidth: 3)
                                            )
                                            .scaledToFit()
                                    } else {
                                        loadImage(named: allRemovedIcons[index].currIcon)
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
                    }
                    .padding(.bottom, 150)
                    Spacer()
                    if iconsSelection == 0 && removedIcons.isEmpty {
                        Text("You don't have any removed icons yet. Once you remove an icon from \(currSheet.label.isEmpty ? "the current sheet" : currSheet.label), it will appear here.")
                            .minimumScaleFactor(0.01)
                            .multilineTextAlignment(.center)
                            .font(.system(size: horizontalSizeClass == .compact ? 15 : 30, weight: .bold, design: .rounded))
                            .foregroundColor(Color(.systemGray))
                            .padding()
                            .padding()
                        Spacer()
                    } else if iconsSelection == 1 && allRemovedIcons.isEmpty {
                        Text("You don't have any removed icons yet. Once you remove an icon from any of your Sheets, it will appear here.")
                            .minimumScaleFactor(0.01)
                            .multilineTextAlignment(.center)
                            .font(.system(size: horizontalSizeClass == .compact ? 15 : 30, weight: .bold, design: .rounded))
                            .foregroundColor(Color(.systemGray))
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
                                    .foregroundColor(Color(.systemGray))
                                //.fontWeight(.bold)
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
            .animation(.spring)
            .onAppear {
                allRemovedIcons = getAllRemoved()
            }
        }
        
        
        .fullScreenCover(isPresented: $showAllSheets) { //fullscreencover that shows all the sheets created
            ZStack {
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
                                .foregroundColor(Color(.systemGray))
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
                                    .foregroundColor(loadSheetArray().count > 1 ? Color(.systemGray3): Color(.systemGray6))
                                    .padding([.top, .trailing])
                            }
                        }
                    }
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: horizontalSizeClass == .compact ? 100 : 175))], spacing: horizontalSizeClass == .compact ? 5 : 10) {
                        ForEach(0..<sheetArray.count, id: \.self) { sheet in
                            if sheetArray[sheet].label != "Debug, ignore this page" {
                                Button(action: {
                                    defaults.set(sheet, forKey: "currSheetIndex")
                                    currSheet = loadSheetArray()[getCurrSheetIndex()]
                                    showAllSheets.toggle()
                                    completedIcons = currSheet.completedIcons
                                    removedIcons = currSheet.removedIcons
                                    if showCurrentSlot {
                                        currGreenSlot = loadSheetArray()[getCurrSheetIndex()].getCurrSlot()
                                        animate.toggle()
                                    }
                                }) {
                                    ZStack {
                                        Image(systemName: "square.fill")
                                            .resizable()
                                            .foregroundColor(Color(.systemGray5))
                                            //.frame(width: horizontalSizeClass == .compact ? 125 : 200, height: horizontalSizeClass == .compact ? 125 : 200) this causes it to look strange on smaller iPads, not comapct screens but small enough to cause itemt to run un
                                            .scaledToFit()
                                        Image(systemName: "square.fill")
                                            .resizable()
                                            .foregroundColor(getCurrSheetIndex() == sheet ? .purple : Color(.systemGray5))
                                            .scaledToFit()
                                            .opacity(0.5)
                                        VStack {
                                            
                                            //check to see if there is a curc LabelIcon
                                            //if sheetArray[sheet].currLabelIcon.isEmpty {
                                            if sheetArray[sheet].currLabelIcon != nil && sheetArray[sheet].currLabelIcon != "plus.viewfinder" {
                                                if sheetArray[sheet].currLabelIcon!.contains("customIconObject:") {
                                                    getCustomIconSmall(sheetArray[sheet].currLabelIcon!)
                                                        .scaledToFit()
                                                        .frame(width: horizontalSizeClass == .compact ? 65: 105, height: horizontalSizeClass == .compact ? 65: 105)
                                                        .clipShape(RoundedRectangle(cornerRadius: horizontalSizeClass == .compact ? 10 : 20))
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: horizontalSizeClass == .compact ? 10 : 20)
                                                                .stroke(.black, lineWidth: horizontalSizeClass == .compact ? 1 : 3)
                                                        )
                                                        .padding(.top)
                                                } else if !sheetArray[sheet].currLabelIcon!.isEmpty && sheetArray[sheet].currLabelIcon! != "plus.viewfinder" {
                                                    loadImage(named: sheetArray[sheet].currLabelIcon!)
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
                                                            .foregroundColor(Color(.systemGray))
                                                            .padding(.top, sheetArray[sheet].label.isEmpty ? 0 : 15)
                                                    } else {
                                                        Image(systemName: "tag")
                                                            .resizable()
                                                            .frame(width: horizontalSizeClass == .compact ? 65: 105, height: horizontalSizeClass == .compact ? 65: 105)
                                                            .foregroundColor(Color(.systemGray))
                                                            .padding(.top, sheetArray[sheet].label.isEmpty ? 0 : 15)
                                                    }
                                                }
                                            } else {
                                                if sheetArray[sheet].gridType == "time" {
                                                    Image(systemName: "timer")
                                                        .resizable()
                                                        .frame(width: horizontalSizeClass == .compact ? 65: 105, height: horizontalSizeClass == .compact ? 65: 105)
                                                        .foregroundColor(Color(.systemGray))
                                                        .padding(.top, sheetArray[sheet].label.isEmpty ? 0 : 15)
                                                } else {
                                                    Image(systemName: "tag")
                                                        .resizable()
                                                        .frame(width: horizontalSizeClass == .compact ? 65: 105, height: horizontalSizeClass == .compact ? 65: 105)
                                                        .foregroundColor(Color(.systemGray))
                                                        .padding(.top, sheetArray[sheet].label.isEmpty ? 0 : 15)
                                                }
                                            }
                                            if sheetArray[sheet].label.isEmpty {
                                                if sheetArray[sheet].currLabelIcon != nil && sheetArray[sheet].currLabelIcon != "plus.viewfinder" {
                                                    if !sheetArray[sheet].currLabelIcon!.isEmpty && sheetArray[sheet].currLabelIcon! != "plus.viewfinder" {
                                                        Spacer()
                                                    }
                                                } else {
                                                    Spacer()
                                                }
                                            }
                                            if !sheetArray[sheet].label.isEmpty {
                                                HStack {
                                                    if sheetArray[sheet].currLabelIcon != nil && sheetArray[sheet].currLabelIcon != "plus.viewfinder" {
                                                        if !sheetArray[sheet].currLabelIcon!.isEmpty && sheetArray[sheet].currLabelIcon! != "plus.viewfinder" {
                                                            Text("\(Image(systemName: sheetArray[sheet].gridType == "time" ? "timer" : "tag" )) \(sheetArray[sheet].label)")
                                                                .lineLimit(1)
                                                                .font(.system(size: horizontalSizeClass == .compact ? 17 : 30, weight: .semibold, design: .rounded))
                                                                .foregroundColor(.primary)
                                                                .padding(.bottom)
                                                                .padding(.leading, 2)
                                                                .padding(.trailing, 2)
                                                        } else {
                                                            Text(sheetArray[sheet].label)
                                                                .lineLimit(1)
                                                                .font(.system(size: horizontalSizeClass == .compact ? 17 : 30, weight: .semibold, design: .rounded))
                                                                .foregroundColor(.primary)
                                                                .padding(.bottom)
                                                        }
                                                    } else {
                                                        Text(sheetArray[sheet].label)
                                                            .lineLimit(1)
                                                            .font(.system(size: horizontalSizeClass == .compact ? 17 : 30, weight: .semibold, design: .rounded))
                                                            .foregroundColor(.primary)
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
                                                            .foregroundColor(.primary)
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
                                        
                                        if #available(iOS 15.0, *) {
                                            Button(role: .destructive) {
                                                defaults.set(sheet, forKey: "currSheetIndex")
                                                currSheet = loadSheetArray()[getCurrSheetIndex()]
                                                showAllSheets.toggle()
                                                completedIcons = currSheet.completedIcons
                                                removedIcons = currSheet.removedIcons
                                                
                                                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { timer in
                                                    if sheetArray.count > 1 {
                                                        presentAlert.toggle()
                                                    }
                                                }
                                            } label: {
                                                Label("Delete this Sheet", systemImage: "trash")
                                            }
                                        } else {
                                            Button {
                                                animate.toggle()
                                                var newSheetArray = loadSheetArray()
                                                newSheetArray.remove(at: currSheetIndex)
                                                sheetArray = newSheetArray
                                                saveSheetArray(sheetObjects: newSheetArray)
                                                if newSheetArray.count > 1 {
                                                    currSheet = sheetArray[1]
                                                } else {
                                                    currSheet = sheetArray[0]
                                                    showAllSheets.toggle()
                                                    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { timer in
                                                        createNewSheet.toggle()
                                                    }
                                                }
                                            } label: {
                                                Label("Delete this Sheet", systemImage: "trash")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding()
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
                                    //.fontWeight(.bold)
                                        .foregroundColor(loadSheetArray().count > 1 ? Color(.systemGray): Color(.systemGray6))
                                        .padding()
                                }
                            }
                            Button(action: {
                                createNewSheet.toggle()
                            }) {
                                Image(systemName: "plus.square.fill.on.square.fill")
                                    .resizable()
                                    .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                //.fontWeight(.bold)
                                    .foregroundColor(.green)
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
            .fullScreenCover(isPresented: $createNewSheet) { //this is the fullscreencover to create a new sheet
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
                                        createNewSheet.toggle()
                                        if !showAllSheets {
                                            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { timer in
                                                if loadSheetArray().count < 2 {
                                                    showAllSheets.toggle()
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { timer in
                                        createNewSheet.toggle()
                                        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { timer in
                                            showAllSheets.toggle()
                                            Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { timer in
                                                self.presentation.wrappedValue.dismiss()
                                            }
                                        }
                                    }
                                }
                            }) {
                                if defaults.bool(forKey: "completedTutorial") {
                                    Text("\(Image(systemName: "xmark.circle.fill"))")
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                        .font(.system(size: 30, weight: .bold, design: .rounded))
                                        .foregroundColor(loadSheetArray().count > 1 ? Color(.systemGray3): Color(.systemGray6))
                                        .padding([.top, .trailing])
                                } else {
                                    Text("\(Image(systemName: "xmark.circle.fill"))")
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                        .font(.system(size: 30, weight: .bold, design: .rounded))
                                        .foregroundColor(Color(.systemGray3))
                                        .padding([.top, .trailing])
                                }
                            }
                        }
                    }
                    Spacer()
                    TextField("Name Sheet", text: $currSheetText, onEditingChanged: { editing in
                        isTextFieldActive = editing
                        sheetAnimate.toggle()
                    }, onCommit: {
                        sheetAnimate.toggle()
                    })
                    .font(.system(size: horizontalSizeClass == .compact ? 40 : 65, weight: .bold, design: .rounded))
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemGray6))
                    )
                    .minimumScaleFactor(0.01)
                    .padding()
                    Spacer()
                    if !isTextFieldActive { //just to handle the content getting pushed off screen by the keybpoard on smaller devices
                        if horizontalSizeClass == .compact { //TODO: Go in and make this work, strange animation right now because of multiple different checks for size class
                            VStack {
                                VStack {
                                    Button(action: {
                                        newSheetTime = true
                                        newSheetLabel = false
                                        sheetAnimate.toggle()
                                        
                                        defaults.set(true, forKey: "completedTutorial")
                                        if newSheetTime {
                                            newSheet(gridType: "time", label: currSheetText)
                                        } else if newSheetLabel {
                                            newSheet(gridType: "label", label: currSheetText)
                                        }
                                        currTitleText = currSheetText
                                        defaults.set(loadSheetArray().count - 1, forKey: "currSheetIndex")
                                        sheetArray = loadSheetArray()
                                        currSheetText = ""
                                        currSheet = loadSheetArray()[getCurrSheetIndex()]
                                        removedIcons = currSheet.removedIcons
                                        completedIcons = currSheet.completedIcons
                                        Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { timer in
                                            editMode.toggle()
                                            createNewSheet.toggle()
                                            newSheetTime.toggle()
                                            showAllSheets.toggle()
                                        }
                                        updateUsage("action:create")
                                    }) {
                                        if horizontalSizeClass == .compact {
                                            ZStack {
                                                Image(systemName: "square.fill")
                                                    .resizable()
                                                    .padding()
                                                    .foregroundColor(newSheetTime ? .blue : Color(.systemGray))
                                                    .scaledToFill()
                                                Image(systemName: "timer")
                                                    .resizable()
                                                    .foregroundColor(newSheetTime ? .white : Color(.systemBackground))
                                                    .scaledToFit()
                                                    .padding(newSheetTime ? 0 : 45)
                                            }
                                            .scaledToFit()
                                        } else {
                                            ZStack {
                                                Image(systemName: "square.fill")
                                                    .resizable()
                                                    .padding()
                                                    .foregroundColor(newSheetTime ? .blue : Color(.systemGray))
                                                    .scaledToFill()
                                                    .padding(newSheetTime ? 0 : 10)
                                                    .padding(newSheetTime ? 0 : 10)
                                                    .padding(newSheetTime ? 0 : 10)
                                                Image(systemName: "timer")
                                                    .resizable()
                                                    .foregroundColor(newSheetTime ? .white : Color(.systemBackground))
                                                    .scaledToFit()
                                                    .padding(newSheetTime ? 0 : 85)
                                            }
                                            .scaledToFit()
                                        }
                                    }
                                    Text("Timeslot Sheet")
                                        .minimumScaleFactor(0.01)
                                        .multilineTextAlignment(.center)
                                        .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .semibold, design: .rounded))
                                }
                                .padding()
                                VStack {
                                    Button(action: {
                                        newSheetTime = false
                                        newSheetLabel = true
                                        sheetAnimate.toggle()
                                        
                                        defaults.set(true, forKey: "completedTutorial")
                                        if newSheetTime {
                                            newSheet(gridType: "time", label: currSheetText)
                                        } else {
                                            newSheet(gridType: "label", label: currSheetText)
                                        }
                                        currTitleText = currSheetText
                                        defaults.set(loadSheetArray().count - 1, forKey: "currSheetIndex")
                                        sheetArray = loadSheetArray()
                                        currSheetText = ""
                                        currSheet = loadSheetArray()[getCurrSheetIndex()]
                                        removedIcons = currSheet.removedIcons
                                        completedIcons = currSheet.completedIcons
                                        Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { timer in
                                            editMode.toggle()
                                            createNewSheet.toggle()
                                            newSheetLabel.toggle()
                                            showAllSheets.toggle()
                                        }
                                        updateUsage("action:create")
                                    }) {
                                        if horizontalSizeClass == .compact {
                                            ZStack {
                                                Image(systemName: "square.fill")
                                                    .resizable()
                                                    .padding()
                                                    .foregroundColor(newSheetLabel ? .blue : Color(.systemGray))
                                                    .scaledToFill()
                                                Image(systemName: "tag")
                                                    .resizable()
                                                    .foregroundColor(newSheetLabel ? .white : Color(.systemBackground))
                                                    .scaledToFit()
                                                    .padding(newSheetTime ? 0 : 45)
                                            }
                                            .scaledToFit()
                                        } else {
                                            ZStack {
                                                Image(systemName: "square.fill")
                                                    .resizable()
                                                    .padding()
                                                    .foregroundColor(newSheetLabel ? .blue : Color(.systemGray))
                                                    .scaledToFill()
                                                    .padding(newSheetLabel ? 0 : 10)
                                                    .padding(newSheetLabel ? 0 : 10)
                                                    .padding(newSheetLabel ? 0 : 10)
                                                Image(systemName: "tag")
                                                    .resizable()
                                                    .foregroundColor(newSheetLabel ? .white : Color(.systemBackground))
                                                    .scaledToFit()
                                                    .padding(newSheetLabel ? 0 : 85)
                                            }
                                            .scaledToFit()
                                        }
                                    }
                                    Text("Custom Labels Sheet")
                                        .minimumScaleFactor(0.01)
                                        .multilineTextAlignment(.center)
                                        .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .semibold, design: .rounded))
                                }
                                .padding()
                            }
                            .scaledToFit()
                        } else {
                            HStack {
                                VStack {
                                    Button(action: {
                                        newSheetTime = true
                                        newSheetLabel = false
                                        sheetAnimate.toggle()
                                        
                                        defaults.set(true, forKey: "completedTutorial")
                                        if newSheetTime {
                                            newSheet(gridType: "time", label: currSheetText)
                                        } else if newSheetLabel {
                                            newSheet(gridType: "label", label: currSheetText)
                                        }
                                        currTitleText = currSheetText
                                        defaults.set(loadSheetArray().count - 1, forKey: "currSheetIndex")
                                        sheetArray = loadSheetArray()
                                        currSheetText = ""
                                        currSheet = loadSheetArray()[getCurrSheetIndex()]
                                        removedIcons = currSheet.removedIcons
                                        completedIcons = currSheet.completedIcons
                                        Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { timer in
                                            editMode.toggle()
                                            createNewSheet.toggle()
                                            newSheetTime.toggle()
                                            showAllSheets.toggle()
                                        }
                                        updateUsage("action:create")
                                    }) {
                                        if horizontalSizeClass == .compact {
                                            ZStack {
                                                Image(systemName: "square.fill")
                                                    .resizable()
                                                    .padding()
                                                    .foregroundColor(newSheetTime ? .blue : Color(.systemGray))
                                                    .scaledToFill()
                                                Image(systemName: "timer")
                                                    .resizable()
                                                    .foregroundColor(newSheetTime ? .white : Color(.systemBackground))
                                                    .scaledToFit()
                                                    .padding(newSheetTime ? 0 : 85)
                                            }
                                            .scaledToFit()
                                        } else {
                                            ZStack {
                                                Image(systemName: "square.fill")
                                                    .resizable()
                                                    .padding()
                                                    .foregroundColor(newSheetTime ? .blue : Color(.systemGray))
                                                    .scaledToFill()
                                                    .padding(newSheetTime ? 0 : 10)
                                                    .padding(newSheetTime ? 0 : 10)
                                                    .padding(newSheetTime ? 0 : 10)
                                                Image(systemName: "timer")
                                                    .resizable()
                                                    .foregroundColor(newSheetTime ? .white : Color(.systemBackground))
                                                    .scaledToFit()
                                                    .padding(newSheetTime ? 0 : 85)
                                            }
                                            .scaledToFit()
                                        }
                                    }
                                    Text("Timeslot Sheet")
                                        .minimumScaleFactor(0.01)
                                        .multilineTextAlignment(.center)
                                        .font(.system(size: 30, weight: .semibold, design: .rounded))
                                }
                                .padding()
                                VStack {
                                    Button(action: {
                                        newSheetTime = false
                                        newSheetLabel = true
                                        sheetAnimate.toggle()
                                        
                                        defaults.set(true, forKey: "completedTutorial")
                                        if newSheetTime {
                                            newSheet(gridType: "time", label: currSheetText)
                                        } else {
                                            newSheet(gridType: "label", label: currSheetText)
                                        }
                                        currTitleText = currSheetText
                                        defaults.set(loadSheetArray().count - 1, forKey: "currSheetIndex")
                                        sheetArray = loadSheetArray()
                                        currSheetText = ""
                                        currSheet = loadSheetArray()[getCurrSheetIndex()]
                                        removedIcons = currSheet.removedIcons
                                        completedIcons = currSheet.completedIcons
                                        Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { timer in
                                            editMode.toggle()
                                            createNewSheet.toggle()
                                            newSheetLabel.toggle()
                                            showAllSheets.toggle()
                                        }
                                        updateUsage("action:create")
                                    }) {
                                        ZStack {
                                            Image(systemName: "square.fill")
                                                .resizable()
                                                .padding()
                                                .foregroundColor(newSheetLabel ? .blue : Color(.systemGray))
                                                .scaledToFill()
                                                .padding(newSheetLabel ? 0 : 10)
                                                .padding(newSheetLabel ? 0 : 10)
                                                .padding(newSheetLabel ? 0 : 10)
                                            Image(systemName: "tag")
                                                .resizable()
                                                .foregroundColor(newSheetLabel ? .white : Color(.systemBackground))
                                                .scaledToFit()
                                                .padding(newSheetTime ? 0 : 85)
                                        }
                                        .scaledToFit()
                                    }
                                    Text("Custom Labels Sheet")
                                        .minimumScaleFactor(0.01)
                                        .multilineTextAlignment(.center)
                                        .font(.system(size: 30, weight: .semibold, design: .rounded))
                                }
                                .padding()
                            }
                            .scaledToFit()
                        }
                        Spacer()
                        if horizontalSizeClass != .compact {
                            HStack {
                                if defaults.bool(forKey: "completedTutorial") { //if they havent actually done anything take them back to the welcome screen
                                    Button(action: {
                                        if loadSheetArray().count > 1 { //cant go back to a sheet if there is none
                                            createNewSheet.toggle()
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
                                        //.fontWeight(.bold)
                                            .foregroundColor(loadSheetArray().count > 1 ? Color(.systemGray): Color(.systemGray6))
                                            .padding()
                                    }
                                } else {
                                    Button(action: {
                                        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { timer in
                                            createNewSheet.toggle()
                                            Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { timer in
                                                showAllSheets.toggle()
                                                Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { timer in
                                                    self.presentation.wrappedValue.dismiss()
                                                }
                                            }
                                        }
                                    }) {
                                        Image(systemName:"xmark.square.fill")
                                            .resizable()
                                            .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                            .foregroundColor(Color(.systemGray))
                                            .padding()
                                    }
                                }
                            }
                        }
                    }
                }
                .animation(.spring, value: sheetAnimate)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $renameSheet) {
                TimeLabelPickerView(viewType: .label, saveItem: { item in
                    if item is String {
                        sheetArray[currSheetIndex].label = item as! String
                        saveSheetArray(sheetObjects: sheetArray)
                        renameSheet.toggle()
                        if currSheetIndex == getCurrSheetIndex() {
                            currSheet.label = item as! String
                        }
                        currSheetText = ""
                    }
                }, oldLabel: $currSheetText)
            }
            .sheet(isPresented: $addSheetIcon) {
                
                AllIconsPickerView(currSheet: currSheet,
                                   currImage: sheetArray[currSheetIndex].currLabelIcon ?? "plus.viewfinder",
                                   modifyIcon: { newIcon in
                    sheetArray[currSheetIndex].currLabelIcon = newIcon
                    animate.toggle()
                    
                    //save array aka "autosave"
                    var newSheetArray = loadSheetArray()
                    newSheetArray[currSheetIndex] = sheetArray[currSheetIndex]
                    currSheet = newSheetArray[getCurrSheetIndex()]
                    saveSheetArray(sheetObjects: newSheetArray)
                }, modifyDetails: { newDetails in
                    //no need to modify details here
                }, modifySheet: {newSheet in
                    currSheet = newSheet
                }, showCreateCustom: false)
            }
        }
        .animation(.spring, value: animate)
        .navigationBarHidden(true)
        .sheet(isPresented: $showCustomPassword) { //the sheet for verifying with a custom password, in the event the ipad doesnt have one set
            
            let customPassword = defaults.string(forKey: "customPassword")
            
            VStack {
                Spacer()
                if mismatch {
                    Text("Incorrect Password")
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(.red)
                        .padding()
                }
                Text("Enter Your Password")
                    .lineLimit(1)
                    .minimumScaleFactor(0.01)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .padding()
                
                SecureField("Password", text: $password)
                    .keyboardType(.numberPad)
                    .font(.system(size: 40, weight: .semibold, design: .rounded))
                    .frame(width: 400)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemGray4))
                    )
                    .padding()
                    .padding(.bottom)
                
                LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                    ForEach(1...9, id: \.self) { number in
                        NumberButton(number: number, password: $password)
                            .foregroundColor(.primary)
                            .padding()
                    }
                    Image(systemName: "checkmark")
                        .font(Font.title.weight(.semibold))
                        .foregroundColor(password != "" ? .green : .clear)
                        .onTapGesture {
                            if password == customPassword {
                                unlockButtons = true
                                animate.toggle()
                                showCustomPassword = false
                                mismatch = false
                                password = ""
                                Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { timer in
                                    unlockButtons = false
                                }
                                if wasShowingMod {
                                    animate.toggle()
                                    showMod = true
                                    wasShowingMod = false
                                }
                            } else {
                                mismatch = true
                                password = ""
                            }
                        }
                    NumberButton(number: 0, password: $password)
                        .foregroundColor(.primary)
                        .padding()
                    Image(systemName: "delete.left")
                        .font(Font.title.weight(.semibold))
                        .foregroundColor(.red)
                        .onTapGesture {
                            if !password.isEmpty {
                                password.removeLast()
                            }
                        }
                }
                .frame(width: 400)
                Spacer()
                if wasShowingMod {
                    Button(action: {
                        animate.toggle()
                        showCustomPassword = false
                        showMod = true
                        wasShowingMod = false
                        mismatch = false
                        password = ""
                    }) {
                        Image(systemName:"xmark.circle.fill")
                            .resizable()
                            .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                        //.fontWeight(.bold)
                            .foregroundColor(Color(.systemGray))
                            .padding()
                    }
                    .padding()
                }
            }
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
                    removeSheet(sheetIndex: getCurrSheetIndex())
                    if loadSheetArray().count < 2 {
                        showAllSheets = true
                        createNewSheet = true
                        defaults.set(0, forKey: "currSheetIndex")
                        currSheet = SheetObject()
                    } else {
                        defaults.set(loadSheetArray().count - 1, forKey: "currSheetIndex")
                        currSheet = loadSheetArray()[getCurrSheetIndex()]
                    }
                    sheetArray = loadSheetArray()
                    currTitleText = currSheet.label
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func authenticateWithBiometrics() { //handle bioauth, this is only called after its verified the device has bioauth set
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "You can disable Lock Buttons in Daysy Settings") { success, evaluateError in
                DispatchQueue.main.async {
                    if success {
                        unlockButtons = true
                        animate.toggle()
                        Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { timer in
                            unlockButtons = false
                        }
                    } else {
                        // Check if the error is related to passcode fallback
                        if let evaluateError = evaluateError as? LAError, evaluateError.code == .userFallback {
                            // Fallback to passcode authentication
                            authenticateWithPasscode()
                        }
                    }
                }
            }
        } else {
            // Biometric authentication not available, handle the error accordingly
            currSessionLog.append("biometrics not available")
            authenticateWithPasscode()
        }
    }
    
    private func authenticateWithPasscode() { //fall back in case of no bioauth or incorrect bioauth
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "You can disable Lock Buttons in Daysy Settings") { success, evaluateError in
                DispatchQueue.main.async {
                    if success {
                        unlockButtons = true
                        animate.toggle()
                        Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { timer in
                            unlockButtons = false
                        }
                    }
                }
            }
        } else {
            // Device authentication not available, handle the error accordingly
            currSessionLog.append("device password not available")
            //use function for creating custom password? this should never be reached unless a code error though
        }
    }
}

#Preview {
    ContentView()
}
