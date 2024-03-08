

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
    @State var showAllSheets = false
    @State var showTutorial = false
    @State var animate = false
    @State var unlockButtons = false
    @State var lockButtonsOn = defaults.bool(forKey: "buttonsOn")
    @State var currGreenSlot = loadSheetArray()[getCurrSheetIndex()].getCurrSlot()
    @State var showCustom = false
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
    
    //allsheetsview
    @State var createNewSheet = false
    @State var sheetArray = loadSheetArray()
    @State var index = getCurrSheetIndex()
    @State var newSheetTime = false
    @State var newSheetLabel = false
    @State var sheetAnimate = false
    @State var currSheetText = ""
    @State var presentAlert = false
    
    //custom icons
    @State var isImagePickerPresented = false
    @State var selectedCustomImage = UIImage(systemName: "plus.viewfinder")
    @State var currCustomIconText = ""
    @State var customPECSAddresses = getCustomPECSAddresses()
    @State var isTextFieldActive = false
    @State var isCustomTextFieldActive = false
    @State var customAnimate = false
    @State var oldEditingIcon = ""
    @State var editCustom = false
    @State var cameraPermission = false
    @State var showCamera = false
    @State var lastSelected = 0 //0 is library, 1 is camera
    @State var showImageMenu = false
    
    var body: some View {
        
        ScrollViewReader { proxy in
            VStack {
                ScrollView {
                    if currSheet.label != "Debug, ignore this page" { //always a sheet to render in the background, bug fix
                        HStack {
                            
                            if editMode {
                                
                                Button(action: {
                                    if editMode {
                                        pickIcon.toggle()
                                    }
                                }) {
                                    if currSheet.currLabelIcon != nil {
                                        if currSheet.currLabelIcon!.contains("customIconObject:") {
                                            getCustomIconSmall(currSheet.currLabelIcon ?? "")
                                                .scaledToFit()
                                                .frame(width: horizontalSizeClass == .compact ? 50 : 100, height: horizontalSizeClass == .compact ? 50 : 100)
                                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .stroke(.black, lineWidth: 3)
                                                )
                                                .padding()
                                        } else if currSheet.currLabelIcon!.isEmpty {
                                            if #available(iOS 15.0, *) {
                                                Image(systemName: "plus.square.dashed")
                                                    .resizable()
                                                    .frame(width: horizontalSizeClass == .compact ? 50 : 100, height: horizontalSizeClass == .compact ? 50 : 100)
                                                    .symbolRenderingMode(.hierarchical)
                                                    .foregroundColor(Color(.systemGray))
                                                    .padding()
                                            } else {
                                                Image(systemName: "plus.square.dashed")
                                                    .resizable()
                                                    .frame(width: horizontalSizeClass == .compact ? 50 : 100, height: horizontalSizeClass == .compact ? 50 : 100)
                                                    .foregroundColor(Color(.systemGray))
                                                    .padding()
                                            }
                                        } else {
                                            loadImage(named: currSheet.currLabelIcon!)
                                                .scaledToFit()
                                                .frame(width: horizontalSizeClass == .compact ? 50 : 100, height: horizontalSizeClass == .compact ? 50 : 100)
                                                .scaleEffect(0.25)
                                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .stroke(.black, lineWidth: 3)
                                                )
                                                .padding()
                                        }
                                    } else {
                                        if #available(iOS 15.0, *) {
                                            Image(systemName: "plus.square.dashed")
                                                .resizable()
                                                .frame(width: horizontalSizeClass == .compact ? 50 : 100, height: horizontalSizeClass == .compact ? 50 : 100)
                                                .symbolRenderingMode(.hierarchical)
                                                .foregroundColor(Color(.systemGray))
                                                .padding()
                                        } else {
                                            Image(systemName: "plus.square.dashed")
                                                .resizable()
                                                .frame(width: horizontalSizeClass == .compact ? 50 : 100, height: horizontalSizeClass == .compact ? 50 : 100)
                                                .foregroundColor(Color(.systemGray))
                                                .padding()
                                        }
                                    }
                                }
                                
                                TextField("Name Sheet", text: $currTitleText)
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: horizontalSizeClass == .compact ? 50 : 100, weight: .semibold, design: .rounded))
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color(.systemGray4))
                                    )
                                    .padding()
                            } else {
                                
                                if currSheet.currLabelIcon != nil {
                                    if currSheet.currLabelIcon!.contains("customIconObject:") {
                                        getCustomIconSmall(currSheet.currLabelIcon ?? "")
                                            .scaledToFit()
                                            .frame(width: horizontalSizeClass == .compact ? 50 : 100, height: horizontalSizeClass == .compact ? 50 : 100)
                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(.black, lineWidth: 3)
                                            )
                                            .padding()
                                    } else if !currSheet.currLabelIcon!.isEmpty {
                                        loadImage(named: currSheet.currLabelIcon!)
                                            .scaledToFit()
                                            .frame(width: horizontalSizeClass == .compact ? 50 : 100, height: horizontalSizeClass == .compact ? 50 : 100)
                                            .scaleEffect(0.25)
                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(.black, lineWidth: 3)
                                            )
                                            .padding()
                                    }
                                }
                                Text(currSheet.label)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.01)
                                    .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                                    .padding()
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
                                            if currSheet.currGrid.count > 1 {
                                                animate.toggle()
                                                currSheet.currGrid.remove(at: list)
                                            } else {
                                                currSheet.currGrid.removeAll()
                                                currSheet.currGrid.append(GridSlot(currLabel: currSheet.gridType))
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
                                                .padding(horizontalSizeClass == .compact ? 0 : 10)
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
                                                    if currSheet.currGrid.count > 1 {
                                                        animate.toggle()
                                                        currSheet.currGrid.remove(at: list)
                                                    } else {
                                                        currSheet.currGrid.removeAll()
                                                        currSheet.currGrid.append(GridSlot(currLabel: currSheet.gridType))
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
            }
            
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
                                                .frame(width: 50, height: 50)
                                                .foregroundColor(.purple)
                                            Image(systemName: "square.grid.2x2")
                                                .resizable()
                                                .frame(width: min(20, 60), height: min(20, 60))
                                                .foregroundColor(Color(.systemBackground))
                                        }
                                        Text("All Sheets")
                                            .font(.system(size: 15, weight: .semibold, design: .rounded))
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
                                                .frame(width: 50, height: 50)
                                                .foregroundColor(.blue)
                                            Image(systemName: "pencil")
                                                .resizable()
                                                .frame(width: min(20, 60), height: min(20, 60))
                                            //.fontWeight(.heavy)
                                                .foregroundColor(Color(.systemBackground))
                                        }
                                        Text("Edit")
                                            .font(.system(size: 15, weight: .semibold, design: .rounded))
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
                                                .frame(width: 50, height: 50)
                                            Image(systemName: "chevron.forward")
                                                .resizable()
                                                .frame(width: 15, height: 30)
                                                .rotationEffect(showMore ? .degrees(90) : .degrees(-90))
                                        }
                                        Text(showMore ? "Less" : "More")
                                            .font(.system(size: 15, weight: .semibold, design: .rounded))
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
                                                    .frame(width: 50, height: 50)
                                                    .foregroundColor(.red)
                                                Image(systemName: "square.slash")
                                                    .resizable()
                                                    .frame(width: min(15, 25), height: min(15, 25))
                                                    .padding(.top)
                                                    .foregroundColor(Color(.systemBackground))
                                            }
                                            Text("Removed")
                                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                                .foregroundColor(.red)
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .padding(.leading)
                                    .padding(.trailing)
                                    
                                    Button(action: {
                                        showCompleted.toggle()
                                        unlockButtons = false
                                    }) {
                                        VStack {
                                            ZStack {
                                                Image(systemName: "folder.fill")
                                                    .resizable()
                                                    .frame(width: 50, height: 50)
                                                    .foregroundColor(.green)
                                                Image(systemName: "checkmark")
                                                    .resizable()
                                                    .frame(width: min(15, 25), height: min(15, 25))
                                                    .padding(.top)
                                                    .foregroundColor(Color(.systemBackground))
                                            }
                                            Text("Completed")
                                                .font(.system(size: 15, weight: .semibold, design: .rounded))
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
                                                    .frame(width: 50, height: 50)
                                                    .foregroundColor(Color(.systemGray))
                                                Image(systemName: "gear")
                                                    .resizable()
                                                    .frame(width: min(20, 60), height: min(20, 60))
                                                    .foregroundColor(Color(.systemBackground))
                                            }
                                            Text("Settings")
                                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                                .foregroundColor(Color(.systemGray))
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .padding(.leading)
                                    .padding(.trailing)
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
                                        .font(.system(size: 20, weight: .semibold, design: .rounded))
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
                                        .font(.system(size: 20, weight: .semibold, design: .rounded))
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
                                        .font(.system(size: 20, weight: .semibold, design: .rounded))
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
                                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color(.systemGray))
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
                                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                                        .foregroundColor(.blue)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding()
                        }
                    }
                }
            } //end of the main grid
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarHidden(true)
        .sheet(isPresented: $pickIcon) {
            var filteredCustomData: [String] { //search results for custom icons
                if searchText.isEmpty {
                    return []
                } else {
                    let matchingKeys = getCustomPECSAddresses().keys.filter { $0.localizedCaseInsensitiveContains(searchText) }
                    
                    let sortedKeys = matchingKeys.sorted { (key1, key2) -> Bool in
                        let startsWithSearchText1 = key1.lowercased().hasPrefix(searchText.lowercased())
                        let startsWithSearchText2 = key2.lowercased().hasPrefix(searchText.lowercased())
                        
                        // Prioritize keys that start with searchText
                        if startsWithSearchText1 && !startsWithSearchText2 {
                            return true
                        } else if !startsWithSearchText1 && startsWithSearchText2 {
                            return false
                        } else {
                            // For keys starting with searchText or having searchText as prefix, sort them alphabetically
                            return key1.localizedCaseInsensitiveCompare(key2) == .orderedAscending
                        }
                    }
                    
                    return sortedKeys
                }
            }
            
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
            
            VStack { //main list of all the icons
                ScrollView {
                    TextField("\(Image(systemName: "magnifyingglass")) Search", text: $searchText)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 65, weight: .semibold, design: .rounded))
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemGray4))
                        )
                        .padding()
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) {
                        ForEach(0..<filteredCustomData.count, id: \.self) { key in //first display custom icon results
                            Button(action: {
                                currSheet.currLabelIcon = "customIconObject:\(filteredCustomData[key])"
                                updateUsage("customIconObject:\(filteredCustomData[key])")
                                searchText = ""
                                //save array aka "autosave"
                                var newSheetArray = loadSheetArray()
                                newSheetArray[getCurrSheetIndex()] = currSheet
                                currSheet = newSheetArray[getCurrSheetIndex()]
                                saveSheetArray(sheetObjects: newSheetArray)
                                animate.toggle()
                                pickIcon.toggle()
                            }) {
                                getCustomIconSmall(filteredCustomData[key])
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(lineWidth: 3)
                                    )
                                //}
                                
                            }
                            .foregroundColor(.primary)
                            .padding()
                        }
                        ForEach(0..<filteredData.count, id: \.self) { pecsIcon in //next display default icon results
                            Button(action: {
                                currSheet.currLabelIcon = filteredData[pecsIcon]
                                updateUsage(filteredData[pecsIcon])
                                searchText = ""
                                //save array aka "autosave"
                                var newSheetArray = loadSheetArray()
                                newSheetArray[getCurrSheetIndex()] = currSheet
                                currSheet = newSheetArray[getCurrSheetIndex()]
                                saveSheetArray(sheetObjects: newSheetArray)
                                animate.toggle()
                                pickIcon.toggle()
                            }) {
                                loadImage(named: filteredData[pecsIcon])
                                    .resizable()
                                    .scaledToFill()
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(.black, lineWidth: 3)
                                    )
                            }
                            .foregroundColor(.primary)
                            .padding()
                        }
                    }
                    
                    if filteredData.count + filteredCustomData.count > 0 {
                        Divider()
                            .padding()
                            .padding(.bottom, 50)
                    }
                    
                    if getCustomPECSAddresses().count > 0 {
                        Text("My Icons")
                            .lineLimit(1)
                            .minimumScaleFactor(0.01)
                            .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) { //grid of custom icons
                            ForEach(getCustomPECSAddresses().sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                                Button(action: {
                                    currSheet.currLabelIcon = "customIconObject:\(key)"
                                    updateUsage("customIconObject:\(key)")
                                    searchText = ""
                                    //save array aka "autosave"
                                    var newSheetArray = loadSheetArray()
                                    newSheetArray[getCurrSheetIndex()] = currSheet
                                    currSheet = newSheetArray[getCurrSheetIndex()]
                                    saveSheetArray(sheetObjects: newSheetArray)
                                    animate.toggle()
                                    pickIcon.toggle()
                                }) {
                                    getCustomIconSmall(key)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(lineWidth: 3)
                                        )
                                    //}
                                    
                                }
                                .foregroundColor(.black)
                                .padding()
                            }
                        }
                    }
                    ForEach(pecsCategories, id: \.self) { icon in //grid of default icons, also displays categories
                        VStack(alignment: .center) {
                            Text(icon[0])
                                .lineLimit(1)
                                .minimumScaleFactor(0.01)
                                .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) {
                                ForEach(1..<icon.count, id: \.self) { sheeticonobject in
                                    Button(action: {
                                        currSheet.currLabelIcon = String(icon[sheeticonobject])
                                        updateUsage(String(icon[sheeticonobject]))
                                        searchText = ""
                                        //save array aka "autosave"
                                        var newSheetArray = loadSheetArray()
                                        newSheetArray[getCurrSheetIndex()] = currSheet
                                        currSheet = newSheetArray[getCurrSheetIndex()]
                                        saveSheetArray(sheetObjects: newSheetArray)
                                        animate.toggle()
                                        pickIcon.toggle()
                                    }) {
                                        loadImage(named: String(icon[sheeticonobject]))
                                            .resizable()
                                            .scaledToFill()
                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(lineWidth: 3)
                                            )
                                    }
                                    .foregroundColor(.black)
                                    .padding()
                                }
                            }
                        }
                        .padding()
                    }
                    Text(verbatim: "Daysy Icons provided by www.mypecs.com")
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        .font(.system(size: 25, weight: .medium, design: .rounded))
                        .foregroundColor(Color(.systemGray2))
                }
                Button(action: {
                    currSheet.currLabelIcon = ""
                    searchText = ""
                    //save array aka "autosave"
                    var newSheetArray = loadSheetArray()
                    newSheetArray[getCurrSheetIndex()] = currSheet
                    currSheet = newSheetArray[getCurrSheetIndex()]
                    saveSheetArray(sheetObjects: newSheetArray)
                    animate.toggle()
                    pickIcon.toggle()
                }) {
                    Image(systemName: "trash.square.fill")
                        .resizable()
                        .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                        .padding()
                        .foregroundColor(.red)
                }
            }
            .ignoresSafeArea(.keyboard)
        }
        .sheet(isPresented: $showTime) { //fullscreencover for setting times on a sheet
            Spacer()
            DatePicker("", selection: $selectedDate, displayedComponents: .hourAndMinute)
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .frame(width: 400, height: 400)
                .scaleEffect(3)
            Spacer()
            HStack {
                Button(action: {
                    if !(getTime(date: selectedDate) == getTime(date: currSheet.currGrid[currListIndex].currTime)) {
                        currSheet.currGrid[currListIndex].currTime = selectedDate
                        currSheet.currGrid = sortSheet(currSheet.currGrid)
                        var newSheetArray = loadSheetArray()
                        newSheetArray[getCurrSheetIndex()] = currSheet
                        saveSheetArray(sheetObjects: newSheetArray)
                        manageNotifications()
                        updateUsage("action:time")
                    }
                    showTime.toggle()
                }) {
                    if getTime(date: selectedDate) == getTime(date: currSheet.currGrid[currListIndex].currTime) {
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
            }
        }
        .sheet(isPresented: $showLabels) { //fullscreencover for setting a custom label in a sheet
            VStack {
                Spacer()
                ZStack {
                    TextField("Your Label", text: $currText)
                    //.focused($isLabelFocused)
                        .font(.system(size: 100, weight: .semibold, design: .rounded))
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemGray5))
                        )
                }
                Spacer()
                Button(action: {
                    if currText.isEmpty || currText == currSheet.currGrid[currListIndex].currLabel {
                        showLabels.toggle()
                        currText = ""
                    } else {
                        updateUsage("action:label")
                        currSheet.currGrid[currListIndex].currLabel = currText
                        var newSheetArray = loadSheetArray()
                        newSheetArray[getCurrSheetIndex()] = currSheet
                        saveSheetArray(sheetObjects: newSheetArray)
                        showLabels.toggle()
                        currText = ""
                    }
                }) {
                    if currText.isEmpty || currText == currSheet.currGrid[currListIndex].currLabel {
                        Image(systemName:"xmark.square.fill")
                            .resizable()
                            .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                            .foregroundColor(Color(.systemGray))
                            .padding()
                    } else {
                        Image(systemName:"checkmark.square.fill")
                            .resizable()
                            .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                            .foregroundColor(.green)
                            .padding()
                    }
                }
            }
            .ignoresSafeArea(.keyboard)
            .padding()
        }
        .fullScreenCover(isPresented: $showIcons) { //fullscreencover that has all the icons in it, used to set icons on a sheet
            
            var filteredCustomData: [String] { //search results for custom icons
                if searchText.isEmpty {
                    return []
                } else {
                    let matchingKeys = customPECSAddresses.keys.filter { $0.localizedCaseInsensitiveContains(searchText) }
                    
                    let sortedKeys = matchingKeys.sorted { (key1, key2) -> Bool in
                        let startsWithSearchText1 = key1.lowercased().hasPrefix(searchText.lowercased())
                        let startsWithSearchText2 = key2.lowercased().hasPrefix(searchText.lowercased())
                        
                        // Prioritize keys that start with searchText
                        if startsWithSearchText1 && !startsWithSearchText2 {
                            return true
                        } else if !startsWithSearchText1 && startsWithSearchText2 {
                            return false
                        } else {
                            // For keys starting with searchText or having searchText as prefix, sort them alphabetically
                            return key1.localizedCaseInsensitiveCompare(key2) == .orderedAscending
                        }
                    }
                    
                    return sortedKeys
                }
            }
            
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
            
            VStack { //main list of all the icons
                ScrollView {
                    TextField("\(Image(systemName: "magnifyingglass")) Search", text: $searchText)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 65, weight: .semibold, design: .rounded))
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemGray4))
                        )
                        .padding()
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) {
                        ForEach(0..<filteredCustomData.count, id: \.self) { key in //first display custom icon results
                            Button(action: {
                                currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currIcon = "customIconObject:\(filteredCustomData[key])"
                                currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currDetails = []
                                updateUsage("customIconObject:\(filteredCustomData[key])")
                                animate.toggle()
                                showIcons.toggle()
                                
                                //save array aka "autosave"
                                var newSheetArray = loadSheetArray()
                                newSheetArray[getCurrSheetIndex()] = currSheet
                                currSheet = newSheetArray[getCurrSheetIndex()]
                                saveSheetArray(sheetObjects: newSheetArray)
                                
                            }) {
                                getCustomIconSmall(filteredCustomData[key])
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(lineWidth: 3)
                                    )
                            }
                            .foregroundColor(.primary)
                            .padding()
                            .overlay(
                                VStack {
                                    HStack {
                                        Menu {
                                            Button {
                                                oldEditingIcon = ""
                                                currCustomIconText = ""
                                                selectedCustomImage = UIImage(systemName: "square.fill")
                                                animate.toggle()
                                                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { timer in
                                                    oldEditingIcon = filteredCustomData[key]
                                                    currCustomIconText = extractKey(from: filteredCustomData[key])
                                                    if getNoImageIcons().contains(filteredCustomData[key]) {
                                                        selectedCustomImage = UIImage(systemName: "plus.viewfinder")
                                                    } else {
                                                        selectedCustomImage = loadImageFromLocalURL(filteredCustomData[key])
                                                    }
                                                }
                                                editCustom.toggle()
                                            } label: {
                                                Label("Edit", systemImage: "square.and.pencil")
                                            }
                                            
                                            Divider()
                                            
                                            if #available(iOS 15.0, *) {
                                                Button(role: .destructive) {
                                                    let newSheetArray = deleteCustomIcons(currIcon: filteredCustomData[key])
                                                    currSheet = newSheetArray[getCurrSheetIndex()]
                                                    saveSheetArray(sheetObjects: newSheetArray)
                                                    customPECSAddresses = getCustomPECSAddresses()
                                                    removedIcons = currSheet.removedIcons
                                                    completedIcons = currSheet.completedIcons
                                                    animate.toggle()
                                                    //then update custom pecs addresses and the current vgrid
                                                } label: {
                                                    Label("Delete", systemImage: "trash")
                                                }
                                            } else {
                                                Button {
                                                    let newSheetArray = deleteCustomIcons(currIcon: filteredCustomData[key])
                                                    currSheet = newSheetArray[getCurrSheetIndex()]
                                                    saveSheetArray(sheetObjects: newSheetArray)
                                                    customPECSAddresses = getCustomPECSAddresses()
                                                    removedIcons = currSheet.removedIcons
                                                    completedIcons = currSheet.completedIcons
                                                    animate.toggle()
                                                    //then update custom pecs addresses and the current vgrid
                                                } label: {
                                                    Label("Delete", systemImage: "trash")
                                                }
                                            }
                                        } label: {
                                            Image(systemName: "pencil.circle.fill")
                                                .resizable()
                                                .frame(width: 40, height: 40)
                                                .foregroundColor(Color(.systemGray))
                                        }
                                        Spacer()
                                    }
                                    Spacer()
                                }
                            )
                        }
                        ForEach(0..<filteredData.count, id: \.self) { pecsIcon in //next display default icon results
                            Button(action: {
                                currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currIcon = filteredData[pecsIcon]
                                currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currDetails = []
                                updateUsage(filteredData[pecsIcon])
                                showIcons.toggle()
                                
                                //save array aka "autosave"
                                var newSheetArray = loadSheetArray()
                                newSheetArray[getCurrSheetIndex()] = currSheet
                                currSheet = newSheetArray[getCurrSheetIndex()]
                                saveSheetArray(sheetObjects: newSheetArray)
                                animate.toggle()
                                
                            }) {
                                loadImage(named: filteredData[pecsIcon])
                                    .resizable()
                                    .scaledToFill()
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(.black, lineWidth: 3)
                                    )
                            }
                            .foregroundColor(.primary)
                            .padding()
                        }
                    }
                    
                    if filteredData.count + filteredCustomData.count > 0 {
                        Divider()
                            .padding()
                            .padding(.bottom, 50)
                    }
                    
                    Text("My Icons")
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) { //grid of custom icons
                        Button(action: {
                            showCustom.toggle()
                        }) {
                            if #available(iOS 15.0, *) {
                                Image(systemName: "plus.viewfinder")
                                    .resizable()
                                    .scaledToFill()
                                    .symbolRenderingMode(.hierarchical)
                            } else {
                                Image(systemName: "plus.viewfinder")
                                    .resizable()
                                    .scaledToFill()
                            }
                        }
                        .foregroundColor(Color(.systemGray))
                        .padding()
                        ForEach(customPECSAddresses.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                            Button(action: {
                                currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currIcon = "customIconObject:\(key)"
                                currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currDetails = []
                                updateUsage("customIconObject:\(key)")
                                animate.toggle()
                                showIcons.toggle()
                                
                                //save array aka "autosave"
                                var newSheetArray = loadSheetArray()
                                newSheetArray[getCurrSheetIndex()] = currSheet
                                currSheet = newSheetArray[getCurrSheetIndex()]
                                saveSheetArray(sheetObjects: newSheetArray)
                                
                            }) {
                                getCustomIconSmall(key)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(lineWidth: 3)
                                    )
                                //}
                                
                            }
                            .foregroundColor(.black)
                            .padding()
                            .overlay(
                                VStack {
                                    HStack {
                                        Menu {
                                            Button {
                                                //hacky fix instead of binding, fixes not updating
                                                oldEditingIcon = ""
                                                currCustomIconText = ""
                                                selectedCustomImage = UIImage(systemName: "square.fill")
                                                animate.toggle()
                                                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { timer in
                                                    oldEditingIcon = key
                                                    currCustomIconText = extractKey(from: key)
                                                    if getNoImageIcons().contains(customPECSAddresses[key]!) {
                                                        selectedCustomImage = UIImage(systemName: "plus.viewfinder")
                                                    } else {
                                                        selectedCustomImage = loadImageFromLocalURL(customPECSAddresses[key]!)
                                                    }
                                                }
                                                editCustom.toggle()
                                            } label: {
                                                Label("Edit", systemImage: "square.and.pencil")
                                            }
                                            
                                            Divider()
                                            
                                            if #available(iOS 15.0, *) {
                                                Button(role: .destructive) {
                                                    let newSheetArray = deleteCustomIcons(currIcon: key)
                                                    currSheet = newSheetArray[getCurrSheetIndex()]
                                                    saveSheetArray(sheetObjects: newSheetArray)
                                                    customPECSAddresses = getCustomPECSAddresses()
                                                    removedIcons = currSheet.removedIcons
                                                    completedIcons = currSheet.completedIcons
                                                    animate.toggle()
                                                    //then update custom pecs addresses and the current vgrid
                                                } label: {
                                                    Label("Delete", systemImage: "trash")
                                                }
                                            } else {
                                                Button {
                                                    let newSheetArray = deleteCustomIcons(currIcon: key)
                                                    currSheet = newSheetArray[getCurrSheetIndex()]
                                                    saveSheetArray(sheetObjects: newSheetArray)
                                                    customPECSAddresses = getCustomPECSAddresses()
                                                    removedIcons = currSheet.removedIcons
                                                    completedIcons = currSheet.completedIcons
                                                    animate.toggle()
                                                    //then update custom pecs addresses and the current vgrid
                                                } label: {
                                                    Label("Delete", systemImage: "trash")
                                                }
                                            }
                                        } label: {
                                            Image(systemName: "pencil.circle.fill")
                                                .resizable()
                                                .frame(width: 40, height: 40)
                                                .foregroundColor(Color(.systemGray))
                                        }
                                        Spacer()
                                    }
                                    Spacer()
                                }
                            )
                        }
                    }
                    ForEach(pecsCategories, id: \.self) { icon in //grid of default icons, also displays categories
                        VStack(alignment: .center) {
                            Text(icon[0])
                                .lineLimit(1)
                                .minimumScaleFactor(0.01)
                                .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) {
                                ForEach(1..<icon.count, id: \.self) { sheeticonobject in
                                    Button(action: {
                                        currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currIcon = icon[sheeticonobject]
                                        currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currDetails = []
                                        updateUsage(icon[sheeticonobject])
                                        showIcons.toggle()
                                        
                                        //save array aka "autosave"
                                        var newSheetArray = loadSheetArray()
                                        newSheetArray[getCurrSheetIndex()] = currSheet
                                        currSheet = newSheetArray[getCurrSheetIndex()]
                                        saveSheetArray(sheetObjects: newSheetArray)
                                        animate.toggle()
                                        
                                    }) {
                                        loadImage(named: String(icon[sheeticonobject]))
                                            .resizable()
                                            .scaledToFill()
                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(lineWidth: 3)
                                            )
                                    }
                                    .foregroundColor(.black)
                                    .padding()
                                }
                            }
                        }
                        .padding()
                    }
                    Text(verbatim: "Daysy Icons provided by www.mypecs.com")
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        .font(.system(size: 25, weight: .medium, design: .rounded))
                        .foregroundColor(Color(.systemGray2))
                }
                HStack { //bottom button row
                    Button(action: {
                        showIcons.toggle()
                    }) {
                        Image(systemName: "xmark.square.fill")
                            .resizable()
                            .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                        //.fontWeight(.bold)
                    }
                    .padding()
                    .foregroundColor(Color(.systemGray))
                    
                    Button(action: {
                        showIcons.toggle()
                        currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currIcon = "plus.viewfinder"
                        currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currDetails = []
                        
                        //save array aka "autosave"
                        var newSheetArray = loadSheetArray()
                        newSheetArray[getCurrSheetIndex()] = currSheet
                        newSheetArray[getCurrSheetIndex()] = autoRemoveSlots(newSheetArray[getCurrSheetIndex()])
                        currSheet = newSheetArray[getCurrSheetIndex()]
                        saveSheetArray(sheetObjects: newSheetArray)
                        animate.toggle()
                        
                    }) {
                        Image(systemName: "trash.square.fill")
                            .resizable()
                            .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                        //.fontWeight(.bold)
                    }
                    .padding()
                    .foregroundColor(.red)
                }
            }
            .ignoresSafeArea(.keyboard)
            .fullScreenCover(isPresented: $showCustom) { //fullscreencover for creating a custom icon
                VStack {
                    RoundedRectangle(cornerRadius: 50)
                        .stroke(Color.black, lineWidth: 25)
                        .background(
                            RoundedRectangle(cornerRadius: 50)
                                .fill(Color.white)
                        )
                        .aspectRatio(isTextFieldActive ? nil : 1, contentMode: .fill)
                        .clipShape(RoundedRectangle(cornerRadius: 50))
                        .overlay(
                            VStack {
                                Spacer()
                                if showImageMenu {
                                    HStack {
                                        Button(action: {
                                            isImagePickerPresented.toggle()
                                            showImageMenu.toggle()
                                            customAnimate.toggle()
                                        }) {
                                            Image(systemName:"photo.on.rectangle")
                                                .resizable()
                                                .aspectRatio(1.25, contentMode: .fit)
                                                .padding()
                                        }
                                        .padding()
                                        
                                        Button(action: {
                                            if hasCameraPermission() {
                                                showCamera.toggle()
                                            } else {
                                                if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                                                    UIApplication.shared.open(appSettings)
                                                }
                                            }
                                        }) {
                                            Image(systemName:"camera.on.rectangle")
                                                .resizable()
                                                .aspectRatio(1.25, contentMode: .fit)
                                                .padding()
                                        }
                                        .padding()
                                    }
                                    .padding()
                                    
                                    Divider()
                                    
                                    HStack {
                                        Button(action: {
                                            showImageMenu.toggle()
                                            customAnimate.toggle()
                                        }) {
                                            Image(systemName:"arrow.uturn.backward")
                                                .resizable()
                                                .aspectRatio(1, contentMode: .fit)
                                                .foregroundColor(Color(.systemGray))
                                                .padding()
                                        }
                                        .padding()
                                        
                                        Button(action: {
                                            showImageMenu.toggle()
                                            selectedCustomImage = UIImage(systemName: "plus.viewfinder")
                                            customAnimate.toggle()
                                        }) {
                                            Image(systemName:"trash.square.fill")
                                                .resizable()
                                                .aspectRatio(1, contentMode: .fit)
                                                .foregroundColor(.red)
                                                .padding()
                                        }
                                        .padding()
                                    }
                                    .padding()
                                    
                                    Spacer()
                                } else {
                                    HStack {
                                        Button(action: {
                                            if selectedCustomImage != UIImage(systemName: "plus.viewfinder") {
                                                showImageMenu.toggle()
                                                customAnimate.toggle()
                                            } else {
                                                isImagePickerPresented.toggle()
                                                lastSelected = 0
                                            }
                                        }) {
                                            if !isCustomTextFieldActive {
                                                if selectedCustomImage == UIImage(systemName: "square.fill") {
                                                    ZStack {
                                                        Image(systemName: "square.fill")
                                                            .resizable()
                                                            .aspectRatio(1, contentMode: .fit)
                                                            .foregroundColor(.gray)
                                                            .padding()
                                                        ProgressView()
                                                            .progressViewStyle(CircularProgressViewStyle())
                                                            .scaleEffect(2.0)
                                                            .foregroundColor(.black)
                                                            .padding(.bottom)
                                                    }
                                                } else {
                                                    if selectedCustomImage == UIImage(systemName: "plus.viewfinder") {
                                                        if #available(iOS 15.0, *) {
                                                            Image(systemName: "photo.on.rectangle")
                                                                .resizable()
                                                                .scaledToFit()
                                                                .symbolRenderingMode(.hierarchical)
                                                                .padding()
                                                        } else {
                                                            Image(systemName: "photo.on.rectangle")
                                                                .resizable()
                                                                .scaledToFit()
                                                                .padding()
                                                        }
                                                    } else {
                                                        selectedCustomImage?.asImage
                                                            .resizable()
                                                            .aspectRatio(1, contentMode: .fit)
                                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                                            .padding()
                                                    }
                                                }
                                            }
                                        }
                                        if selectedCustomImage == UIImage(systemName: "plus.viewfinder") {
                                            Divider().padding()
                                            Button(action: {
                                                if hasCameraPermission() {
                                                    showCamera.toggle()
                                                } else {
                                                    if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                                                        UIApplication.shared.open(appSettings)
                                                    }
                                                }
                                            }) {
                                                if #available(iOS 15.0, *) {
                                                    Image(systemName: "camera.on.rectangle")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .symbolRenderingMode(.hierarchical)
                                                        .padding()
                                                } else {
                                                    Image(systemName: "camera.on.rectangle")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .padding()
                                                }
                                            }
                                        }
                                    }
                                }
                                if !isCustomTextFieldActive {
                                    Spacer()
                                }
                                ZStack { //zstack with gray is to workaround low contrast on dark mode despite white background
                                    Text("Label")
                                        .minimumScaleFactor(0.1)
                                        .multilineTextAlignment(.center)
                                        .font(.system(size: 135,weight: .semibold,  design: .rounded))
                                        .foregroundColor(currCustomIconText.isEmpty ? Color(.systemGray) : .clear)
                                        .padding()
                                    //SuperTextField(placeholder: Text("Label"), text: $currCustomIconText, editingChanged: { editing in
                                    TextField("Label", text: $currCustomIconText, onEditingChanged: { editing in
                                        isCustomTextFieldActive = editing
                                        customAnimate.toggle()
                                    }, onCommit: {
                                        customAnimate.toggle()
                                    })
                                    .minimumScaleFactor(0.1)
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 135,weight: .semibold,  design: .rounded))
                                    .foregroundColor(.black)
                                    .padding()
                                    //Spacer()
                                }
                                if isCustomTextFieldActive {
                                    Spacer()
                                }
                            }
                        )
                        .scaledToFit()
                        .padding()
                    HStack { //bottom row of buttons
                        Button(action: {
                            showCustom.toggle()
                            currCustomIconText = ""
                            selectedCustomImage = UIImage(systemName: "plus.viewfinder")
                            showImageMenu = false
                            
                        }) {
                            Image(systemName:"xmark.square.fill")
                                .resizable()
                                .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                            //.fontWeight(.bold)
                                .foregroundColor(Color(.systemGray))
                                .padding()
                        }
                        if !(selectedCustomImage == UIImage(systemName: "plus.viewfinder") && currCustomIconText.isEmpty) {
                            Button(action: { //perform checks for no image, no label, or no either and possibly save the icon
                                if selectedCustomImage == UIImage(systemName: "plus.viewfinder") && currCustomIconText.isEmpty {
                                    showCustom.toggle()
                                    currCustomIconText = ""
                                    selectedCustomImage = UIImage(systemName: "plus.viewfinder")
                                    showImageMenu = false
                                } else {
                                    if customPECSAddresses[currCustomIconText] != nil {
                                        var i = 1
                                        while customPECSAddresses[String("\(i)#id\(currCustomIconText)")] != nil {
                                            i += 1
                                        }
                                        currCustomIconText = String("\(i)#id\(currCustomIconText)")
                                    }
                                    
                                    customPECSAddresses[currCustomIconText] = saveImageToDocumentsDirectory(selectedCustomImage!)
                                    saveCustomPECSAddresses(customPECSAddresses)
                                    
                                    if selectedCustomImage == UIImage(systemName: "plus.viewfinder") {
                                        saveNoImageIcons(customPECSAddresses[currCustomIconText]!)
                                    }
                                    
                                    showCustom.toggle()
                                    currCustomIconText = ""
                                    selectedCustomImage = UIImage(systemName: "plus.viewfinder")
                                }
                                updateUsage("action:createIcon")
                            }) {
                                Image(systemName:"checkmark.square.fill")
                                    .resizable()
                                    .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                    .foregroundColor(.green)
                                    .padding()
                            }
                        }
                    }
                }
                .animation(.spring, value: customAnimate)
                .sheet(isPresented: $isImagePickerPresented) {
                    UIImagePicker(selectedImage: $selectedCustomImage)
                }
                .fullScreenCover(isPresented: $showCamera, content: {
                    CameraPickerView(selectedImage: $selectedCustomImage)
                })
            }
            .fullScreenCover(isPresented: $editCustom) { //fullscreencover for editing a custom icon
                VStack {
                    RoundedRectangle(cornerRadius: 50)
                        .stroke(Color.black, lineWidth: 25)
                        .background(
                            RoundedRectangle(cornerRadius: 50)
                                .fill(Color.white)
                        )
                        .aspectRatio(isTextFieldActive ? nil : 1, contentMode: .fill)
                        .clipShape(RoundedRectangle(cornerRadius: 50))
                        .overlay(
                            VStack {
                                Spacer()
                                //new stuff start here
                                
                                if showImageMenu {
                                    HStack {
                                        Button(action: {
                                            isImagePickerPresented.toggle()
                                            showImageMenu.toggle()
                                            customAnimate.toggle()
                                        }) {
                                            Image(systemName:"photo.on.rectangle")
                                                .resizable()
                                                .aspectRatio(1.25, contentMode: .fit)
                                                .padding()
                                        }
                                        .padding()
                                        
                                        Button(action: {
                                            if hasCameraPermission() {
                                                showCamera.toggle()
                                            } else {
                                                if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                                                    UIApplication.shared.open(appSettings)
                                                }
                                            }
                                        }) {
                                            Image(systemName:"camera.on.rectangle")
                                                .resizable()
                                                .aspectRatio(1.25, contentMode: .fit)
                                                .padding()
                                        }
                                        .padding()
                                    }
                                    .padding()
                                    
                                    Divider()
                                    
                                    HStack {
                                        Button(action: {
                                            showImageMenu.toggle()
                                            customAnimate.toggle()
                                        }) {
                                            Image(systemName:"arrow.uturn.backward")
                                                .resizable()
                                                .aspectRatio(1, contentMode: .fit)
                                                .foregroundColor(Color(.systemGray))
                                                .padding()
                                        }
                                        .padding()
                                        
                                        Button(action: {
                                            showImageMenu.toggle()
                                            selectedCustomImage = UIImage(systemName: "plus.viewfinder")
                                            customAnimate.toggle()
                                        }) {
                                            Image(systemName:"trash.square.fill")
                                                .resizable()
                                                .aspectRatio(1, contentMode: .fit)
                                                .foregroundColor(.red)
                                                .padding()
                                        }
                                        .padding()
                                    }
                                    .padding()
                                    Spacer()
                                } else {
                                    HStack {
                                        Button(action: {
                                            if selectedCustomImage != UIImage(systemName: "plus.viewfinder") {
                                                //lastSelected == 0 ? isImagePickerPresented.toggle() : showCamera.toggle()
                                                showImageMenu.toggle()
                                                customAnimate.toggle()
                                            } else {
                                                isImagePickerPresented.toggle()
                                                lastSelected = 0
                                            }
                                        }) {
                                            if !isCustomTextFieldActive {
                                                if selectedCustomImage == UIImage(systemName: "square.fill") {
                                                    ZStack {
                                                        Image(systemName: "square.fill")
                                                            .resizable()
                                                            .aspectRatio(1, contentMode: .fit)
                                                            .foregroundColor(.gray)
                                                            .padding()
                                                        ProgressView()
                                                            .progressViewStyle(CircularProgressViewStyle())
                                                            .scaleEffect(2.0)
                                                            .foregroundColor(.black)
                                                            .padding(.bottom)
                                                    }
                                                } else {
                                                    if selectedCustomImage == UIImage(systemName: "plus.viewfinder") {
                                                        if #available(iOS 15.0, *) {
                                                            Image(systemName: "photo.on.rectangle")
                                                                .resizable()
                                                                .scaledToFit()
                                                                .symbolRenderingMode(.hierarchical)
                                                                .padding()
                                                        } else {
                                                            Image(systemName: "photo.on.rectangle")
                                                                .resizable()
                                                                .scaledToFit()
                                                                .padding()
                                                        }
                                                    } else {
                                                        selectedCustomImage?.asImage
                                                            .resizable()
                                                            .aspectRatio(1, contentMode: .fit)
                                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                                            .padding()
                                                    }
                                                }
                                            }
                                        }
                                        if selectedCustomImage == UIImage(systemName: "plus.viewfinder") {
                                            Divider().padding()
                                            Button(action: {
                                                if hasCameraPermission() {
                                                    showCamera.toggle()
                                                } else {
                                                    if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                                                        UIApplication.shared.open(appSettings)
                                                    }
                                                }
                                            }) {
                                                if #available(iOS 15.0, *) {
                                                    Image(systemName: "camera.on.rectangle")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .symbolRenderingMode(.hierarchical)
                                                        .padding()
                                                } else {
                                                    Image(systemName: "camera.on.rectangle")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .padding()
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                ZStack { //zstack with gray is to workaround low contrast on dark mode despite white background
                                    Text("Label")
                                        .minimumScaleFactor(0.1)
                                        .multilineTextAlignment(.center)
                                        .font(.system(size: 135,weight: .semibold,  design: .rounded))
                                        .foregroundColor(currCustomIconText.isEmpty ? Color(.systemGray) : .clear)
                                        .padding()
                                    //SuperTextField(placeholder: Text("Label"), text: $currCustomIconText, editingChanged: { editing in
                                    TextField("Label", text: $currCustomIconText, onEditingChanged: { editing in
                                        isCustomTextFieldActive = editing
                                        customAnimate.toggle()
                                    }, onCommit: {
                                        customAnimate.toggle()
                                    })
                                    .minimumScaleFactor(0.1)
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 135,weight: .semibold,  design: .rounded))
                                    .foregroundColor(.black)
                                    .padding()
                                    //Spacer()
                                }
                                if isCustomTextFieldActive {
                                    Spacer()
                                }
                            }
                        )
                        .scaledToFit()
                        .padding()
                    HStack { //bottom row of buttons
                        Button(action: {
                            editCustom.toggle()
                            currCustomIconText = ""
                            selectedCustomImage = UIImage(systemName: "plus.viewfinder")
                            showImageMenu = false
                        }) {
                            Image(systemName:"xmark.square.fill")
                                .resizable()
                                .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                            //.fontWeight(.bold)
                                .foregroundColor(Color(.systemGray))
                                .padding()
                        }
                        .ignoresSafeArea(.keyboard)
                        Button(action: { //perform checks for no image, no label, or no either and possibly save the icon
                            //update and save completed icon
                            //check to see if image and label are both blank, if so either delete or dont save?
                            //possible change the nesting of the code so that it performs all the check to do nothing first before proceeding to others
                            
                            if selectedCustomImage == UIImage(systemName: "plus.viewfinder") && currCustomIconText.isEmpty {
                                
                                let newSheetArray = deleteCustomIcons(currIcon: oldEditingIcon)
                                currSheet = newSheetArray[getCurrSheetIndex()]
                                saveSheetArray(sheetObjects: newSheetArray)
                                customPECSAddresses = getCustomPECSAddresses()
                                removedIcons = currSheet.removedIcons
                                completedIcons = currSheet.completedIcons
                                
                            } else {
                                if oldEditingIcon == currCustomIconText && selectedCustomImage == UIImage(systemName: "plus.viewfinder") && getNoImageIcons().contains(oldEditingIcon) {
                                    
                                    //it is an icon with no image that hasnt changed
                                    
                                } else if oldEditingIcon == currCustomIconText && selectedCustomImage == loadImageFromLocalURL(customPECSAddresses[oldEditingIcon]!) {
                                    
                                    //it is an image with an icon that hasnt changed
                                    
                                } else if oldEditingIcon == currCustomIconText && selectedCustomImage != loadImageFromLocalURL(customPECSAddresses[oldEditingIcon]!) {
                                    
                                    deleteFile(at: customPECSAddresses[oldEditingIcon]!)
                                    customPECSAddresses[oldEditingIcon] = saveImageToDocumentsDirectory(selectedCustomImage!)
                                    saveCustomPECSAddresses(customPECSAddresses)
                                    if selectedCustomImage == UIImage(systemName: "plus.viewfinder") {
                                        saveNoImageIcons(customPECSAddresses[currCustomIconText]!)
                                    }
                                    //icon with image, only the image changed
                                    
                                }
                                
                                if oldEditingIcon != currCustomIconText {
                                    
                                    currSessionLog.append("old editing icon: \(oldEditingIcon), curr custom icon: \(currCustomIconText)")
                                    
                                    //perform checks for no image, no label, or no either and possibly save the icon
                                    if selectedCustomImage == UIImage(systemName: "plus.viewfinder") && currCustomIconText.isEmpty {
                                        //nothing to do
                                    } else {
                                        if customPECSAddresses[currCustomIconText] != nil {
                                            var i = 1
                                            while customPECSAddresses[String("\(i)#id\(currCustomIconText)")] != nil {
                                                i += 1
                                            }
                                            currCustomIconText = String("\(i)#id\(currCustomIconText)")
                                        }
                                        
                                        deleteFile(at: customPECSAddresses[oldEditingIcon] ?? "")
                                        customPECSAddresses[currCustomIconText] = saveImageToDocumentsDirectory(selectedCustomImage!)
                                        customPECSAddresses.removeValue(forKey: oldEditingIcon)
                                        saveCustomPECSAddresses(customPECSAddresses)
                                        
                                        if selectedCustomImage == UIImage(systemName: "plus.viewfinder") {
                                            saveNoImageIcons(customPECSAddresses[currCustomIconText]!)
                                        }
                                        
                                        let newArray = updateCustomIcons(oldKey: oldEditingIcon, newKey: currCustomIconText)
                                        saveSheetArray(sheetObjects: newArray)
                                        currSheet = newArray[getCurrSheetIndex()]
                                        removedIcons = currSheet.removedIcons
                                        completedIcons = currSheet.completedIcons
                                        
                                        
                                        if selectedCustomImage == UIImage(systemName: "plus.viewfinder") {
                                            saveNoImageIcons(customPECSAddresses[currCustomIconText]!)
                                        }
                                    }
                                }
                            }
                                
                            currCustomIconText = ""
                            oldEditingIcon = ""
                            selectedCustomImage = UIImage(systemName: "plus.viewfinder")
                            editCustom.toggle()
                            updateUsage("action:editIcon")
                            showImageMenu = false
                            
                        }) {
                            if selectedCustomImage == UIImage(systemName: "plus.viewfinder") && currCustomIconText.isEmpty {
                                Image(systemName:"trash.square.fill")
                                    .resizable()
                                    .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                    .foregroundColor(.red)
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
                        .ignoresSafeArea(.keyboard)
                    }
                    .ignoresSafeArea(.keyboard)
                }
                .animation(.spring, value: customAnimate)
                .sheet(isPresented: $isImagePickerPresented) {
                    UIImagePicker(selectedImage: $selectedCustomImage)
                }
            }
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
                                                    .stroke(.black, lineWidth: 10)
                                            )
                                            .padding()
                                    }
                                }
                            }
                            if tempDetails.count < 5 {
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
                        var filteredCustomData: [String] { //search results for custom icons
                            if searchText.isEmpty {
                                return []
                            } else {
                                let matchingKeys = getCustomPECSAddresses().keys.filter { $0.localizedCaseInsensitiveContains(searchText) }
                                
                                let sortedKeys = matchingKeys.sorted { (key1, key2) -> Bool in
                                    let startsWithSearchText1 = key1.lowercased().hasPrefix(searchText.lowercased())
                                    let startsWithSearchText2 = key2.lowercased().hasPrefix(searchText.lowercased())
                                    
                                    // Prioritize keys that start with searchText
                                    if startsWithSearchText1 && !startsWithSearchText2 {
                                        return true
                                    } else if !startsWithSearchText1 && startsWithSearchText2 {
                                        return false
                                    } else {
                                        // For keys starting with searchText or having searchText as prefix, sort them alphabetically
                                        return key1.localizedCaseInsensitiveCompare(key2) == .orderedAscending
                                    }
                                }
                                
                                return sortedKeys
                            }
                        }
                        
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
                        
                        VStack { //main list of all the icons
                            ScrollView {
                                TextField("\(Image(systemName: "magnifyingglass")) Search", text: $searchText)
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 65, weight: .semibold, design: .rounded))
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color(.systemGray4))
                                    )
                                    .padding()
                                
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) {
                                    ForEach(0..<filteredCustomData.count, id: \.self) { key in //first display custom icon results
                                        Button(action: {
                                            //select the custom icon and close the popover
                                            if detailIconIndex != -1 {
                                                tempDetails[detailIconIndex] = "customIconObject:\(filteredCustomData[key])"
                                            } else {
                                                tempDetails.append("customIconObject:\(filteredCustomData[key])")
                                            }
                                            animate.toggle()
                                            searchText = ""
                                            showDetailsIcons.toggle()
                                            
                                            //"autosave"
                                            currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currDetails = tempDetails
                                            var newArray = loadSheetArray()
                                            newArray[getCurrSheetIndex()] = currSheet
                                            newArray[getCurrSheetIndex()] = autoRemoveSlots(newArray[getCurrSheetIndex()])
                                            currSheet = newArray[getCurrSheetIndex()]
                                            saveSheetArray(sheetObjects: newArray)
                                        }) {
                                            getCustomIconSmall(filteredCustomData[key])
                                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .stroke(lineWidth: 3)
                                                )
                                            //}
                                            
                                        }
                                        .foregroundColor(.primary)
                                        .padding()
                                    }
                                    ForEach(0..<filteredData.count, id: \.self) { pecsIcon in //next display default icon results
                                        Button(action: {
                                            //select the icon and close the popover
                                            if detailIconIndex != -1 {
                                                tempDetails[detailIconIndex] = filteredData[pecsIcon]
                                            } else {
                                                tempDetails.append(filteredData[pecsIcon])
                                            }
                                            animate.toggle()
                                            searchText = ""
                                            showDetailsIcons.toggle()
                                            
                                            //"autosave"
                                            currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currDetails = tempDetails
                                            var newArray = loadSheetArray()
                                            newArray[getCurrSheetIndex()] = currSheet
                                            newArray[getCurrSheetIndex()] = autoRemoveSlots(newArray[getCurrSheetIndex()])
                                            currSheet = newArray[getCurrSheetIndex()]
                                            saveSheetArray(sheetObjects: newArray)
                                        }) {
                                            loadImage(named: filteredData[pecsIcon])
                                                .resizable()
                                                .scaledToFill()
                                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .stroke(.black, lineWidth: 3)
                                                )
                                        }
                                        .foregroundColor(.primary)
                                        .padding()
                                    }
                                }
                                
                                if filteredData.count + filteredCustomData.count > 0 {
                                    Divider()
                                        .padding()
                                        .padding(.bottom, 50)
                                }
                                
                                if getCustomPECSAddresses().count > 0 {
                                    Text("My Icons")
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.01)
                                        .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) { //grid of custom icons
                                        ForEach(getCustomPECSAddresses().sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                                            Button(action: {
                                                //select the custom icon for the detail and close the popover
                                                if detailIconIndex != -1 {
                                                    tempDetails[detailIconIndex] = "customIconObject:\(key)"
                                                } else {
                                                    tempDetails.append("customIconObject:\(key)")
                                                }
                                                animate.toggle()
                                                searchText = ""
                                                showDetailsIcons.toggle()
                                                
                                                //"autosave"
                                                currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currDetails = tempDetails
                                                var newArray = loadSheetArray()
                                                newArray[getCurrSheetIndex()] = currSheet
                                                newArray[getCurrSheetIndex()] = autoRemoveSlots(newArray[getCurrSheetIndex()])
                                                currSheet = newArray[getCurrSheetIndex()]
                                                saveSheetArray(sheetObjects: newArray)
                                            }) {
                                                getCustomIconSmall(key)
                                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 16)
                                                            .stroke(lineWidth: 3)
                                                    )
                                                //}
                                                
                                            }
                                            .foregroundColor(.black)
                                            .padding()
                                        }
                                    }
                                }
                                ForEach(pecsCategories, id: \.self) { icon in //grid of default icons, also displays categories
                                    VStack(alignment: .center) {
                                        Text(icon[0])
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.01)
                                            .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) {
                                            ForEach(1..<icon.count, id: \.self) { sheeticonobject in
                                                Button(action: {
                                                    //assign the icon
                                                    if detailIconIndex != -1 {
                                                        tempDetails[detailIconIndex] = String(icon[sheeticonobject])
                                                    } else {
                                                        tempDetails.append(String(icon[sheeticonobject]))
                                                    }
                                                    animate.toggle()
                                                    searchText = ""
                                                    showDetailsIcons.toggle()
                                                    
                                                    //"autosave"
                                                    currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currDetails = tempDetails
                                                    var newArray = loadSheetArray()
                                                    newArray[getCurrSheetIndex()] = currSheet
                                                    newArray[getCurrSheetIndex()] = autoRemoveSlots(newArray[getCurrSheetIndex()])
                                                    currSheet = newArray[getCurrSheetIndex()]
                                                    saveSheetArray(sheetObjects: newArray)
                                                }) {
                                                    loadImage(named: String(icon[sheeticonobject]))
                                                        .resizable()
                                                        .scaledToFill()
                                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 16)
                                                                .stroke(lineWidth: 3)
                                                        )
                                                }
                                                .foregroundColor(.black)
                                                .padding()
                                            }
                                        }
                                    }
                                    .padding()
                                }
                                Text(verbatim: "Daysy Icons provided by www.mypecs.com")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.01)
                                    .font(.system(size: 25, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(.systemGray2))
                            }
                            Button(action: {
                                if tempDetails.count == 1 {
                                    tempDetails.removeAll()
                                } else {
                                    tempDetails.remove(at: detailIconIndex)
                                }
                                animate.toggle()
                                searchText = ""
                                showDetailsIcons.toggle()
                                
                                //"autosave"
                                currSheet.currGrid[currListIndex].currIcons[currSlotIndex].currDetails = tempDetails
                                var newArray = loadSheetArray()
                                newArray[getCurrSheetIndex()] = currSheet
                                newArray[getCurrSheetIndex()] = autoRemoveSlots(newArray[getCurrSheetIndex()])
                                currSheet = newArray[getCurrSheetIndex()]
                                saveSheetArray(sheetObjects: newArray)
                            }) {
                                Image(systemName: "trash.square.fill")
                                    .resizable()
                                    .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                    .padding()
                                    .foregroundColor(.red)
                            }
                        }
                        .ignoresSafeArea(.keyboard)
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
                                                .stroke(.black, lineWidth: 10)
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
                                                    .stroke(.black, lineWidth: 10)
                                            )
                                            .padding()
                                    }
                                }
                            }
                        }
                    }
                }
                
                HStack {
                    if !editMode {
                        Button(action: {
                            showMod.toggle()
                            unlockButtons = false
                        }) {
                            VStack {
                                Image(systemName:"xmark.square.fill")
                                    .resizable()
                                    .frame(width: min(150, 500), height: min(150, 500))
                                //.fontWeight(.bold)
                                Text("Cancel")
                                    .font(.system(size: 25, weight: .semibold, design: .rounded))
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
                                        .frame(width: min(150, 500), height: min(150, 500))
                                    Text("Buttons Locked")
                                        .font(.system(size: 25, weight: .semibold, design: .rounded))
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
                                            .frame(width: min(150, 500), height: min(150, 500))
                                        Image(systemName: "square.slash")
                                            .resizable()
                                            .frame(width: min(100, 250), height: min(100, 250))
                                            .foregroundColor(Color(.systemBackground))
                                    }
                                    Text(tempDetails.isEmpty ? "Remove Icon" : "Remove All")
                                        .font(.system(size: 25, weight: .semibold, design: .rounded))
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
                                        .frame(width: min(150, 500), height: min(150, 500))
                                    //.fontWeight(.bold)
                                    Text(tempDetails.isEmpty ? "Complete Icon" : "Complete All")
                                        .font(.system(size: 25, weight: .semibold, design: .rounded))
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
                                    .frame(width: min(150, 500), height: min(150, 500))
                                    .foregroundColor(Color(.systemGray))
                            } else {
                                Image(systemName:"checkmark.square.fill")
                                    .resizable()
                                    .frame(width: min(150, 500), height: min(150, 500))
                                    .foregroundColor(.green)
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showSettings) { //fullscreencover for the settings page
            NavigationView {
                SettingsView(onDismiss: {
                    lockButtonsOn = defaults.bool(forKey: "buttonsOn")
                    showCurrentSlot = defaults.bool(forKey: "showCurrSlot")
                    unlockButtons = false
                    speakIcons = defaults.bool(forKey: "speakOn")
                    currSheet = autoRemoveSlots(currSheet)
                })
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .navigationBarHidden(true)
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
            VStack {
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
                        }
                    }
                }
                LazyVGrid(columns: Array(repeating: GridItem(), count: 5)) {
                    ForEach(0..<completedIcons.count, id: \.self) { index in
                        ZStack {
                            if completedIcons[index].currIcon.contains("customIconObject:") {
                                getCustomIconSmall(completedIcons[index].currIcon)
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(.black, lineWidth: 6)
                                    )
                                    .padding(5)
                                //}
                                
                            } else {
                                loadImage(named: completedIcons[index].currIcon)
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(.black, lineWidth: 6)
                                    )
                                    .padding(5)
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
                }
                Spacer()
                if completedIcons.isEmpty {
                    Text("You don't have any completed icons yet. Once you complete an icon from \(currSheet.label.isEmpty ? "the current sheet" : currSheet.label), it will appear here.")
                        .minimumScaleFactor(0.01)
                        .multilineTextAlignment(.center)
                        .font(.system(size: horizontalSizeClass == .compact ? 15 : 30, weight: .bold, design: .rounded))
                        .foregroundColor(Color(.systemGray))
                        .padding()
                        .padding()
                    Spacer()
                }
                
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
            }
        }
        .fullScreenCover(isPresented: $showRemoved) { //fullscreencover for removed icons
            VStack {
                HStack {
                Text("\(Image(systemName: "square.slash")) Removed Icons")
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
                        }
                    }
                }
                LazyVGrid(columns: Array(repeating: GridItem(), count: 5)) {
                    ForEach(0..<removedIcons.count, id: \.self) { index in
                        ZStack {
                            if removedIcons[index].currIcon.contains("customIconObject:") {
                                getCustomIconSmall(removedIcons[index].currIcon)
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(.black, lineWidth: 6)
                                    )
                                    .padding(5)
                                //}
                                
                            } else {
                                loadImage(named: removedIcons[index].currIcon)
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(.black, lineWidth: 6)
                                    )
                                    .padding(5)
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
                }
                Spacer()
                if removedIcons.isEmpty {
                    Text("You don't have any removed icons yet. Once you remove an icon from \(currSheet.label.isEmpty ? "the current sheet" : currSheet.label), it will appear here.")
                        .minimumScaleFactor(0.01)
                        .multilineTextAlignment(.center)
                        .font(.system(size: horizontalSizeClass == .compact ? 15 : 30, weight: .bold, design: .rounded))
                        .foregroundColor(Color(.systemGray))
                        .padding()
                        .padding()
                    Spacer()
                }
                
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
            }
        }
        .fullScreenCover(isPresented: $showAllSheets) { //fullscreencover that shows all the sheets created
            VStack {
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
                            }
                        }
                    }
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: horizontalSizeClass == .compact ? 100 : 175))], spacing: horizontalSizeClass == .compact ? 1 : 10) {
                        ForEach(0..<sheetArray.count, id: \.self) { sheet in
                            if sheetArray[sheet].label != "Debug, ignore this page" {
                                Button(action: {
                                    defaults.set(sheet, forKey: "currSheetIndex")
                                    currSheet = loadSheetArray()[getCurrSheetIndex()]
                                    showAllSheets.toggle()
                                    completedIcons = currSheet.completedIcons
                                    removedIcons = currSheet.removedIcons
                                }) {
                                    ZStack {
                                        Image(systemName: "square.fill")
                                            .resizable()
                                            .foregroundColor(Color(.systemGray5))
                                            //.frame(width: horizontalSizeClass == .compact ? 125 : 200, height: horizontalSizeClass == .compact ? 125 : 200) this causes it to look strange on smaller iPads, not comapct screens but small enough to cause itemt to run un
                                            .scaledToFit()
                                        VStack {
                                            
                                            //check to see if there is a curc LabelIcon
                                            //if sheetArray[sheet].currLabelIcon.isEmpty {
                                            if sheetArray[sheet].currLabelIcon != nil {
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
                                                } else if !sheetArray[sheet].currLabelIcon!.isEmpty {
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
                                                            .foregroundColor(.primary)
                                                            .padding(.top, sheetArray[sheet].label.isEmpty ? 0 : 15)
                                                    } else {
                                                        Image(systemName: "tag")
                                                            .resizable()
                                                            .frame(width: horizontalSizeClass == .compact ? 65: 105, height: horizontalSizeClass == .compact ? 65: 105)
                                                            .foregroundColor(.primary)
                                                            .padding(.top, sheetArray[sheet].label.isEmpty ? 0 : 15)
                                                    }
                                                }
                                            } else {
                                                if sheetArray[sheet].gridType == "time" {
                                                    Image(systemName: "timer")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .foregroundColor(.primary)
                                                        .padding(sheetArray[sheet].label.isEmpty ? 5 : 0)
                                                } else {
                                                    Image(systemName: "tag")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .foregroundColor(.primary)
                                                        .padding(sheetArray[sheet].label.isEmpty ? 5 : 0)
                                                }
                                            }
                                            if sheetArray[sheet].label.isEmpty {
                                                if sheetArray[sheet].currLabelIcon != nil {
                                                    if !sheetArray[sheet].currLabelIcon!.isEmpty {
                                                        Spacer()
                                                    }
                                                } else {
                                                    Spacer()
                                                }
                                            }
                                            if !sheetArray[sheet].label.isEmpty {
                                                HStack {
                                                    if sheetArray[sheet].currLabelIcon != nil {
                                                        if !sheetArray[sheet].currLabelIcon!.isEmpty {
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
                                                if sheetArray[sheet].currLabelIcon != nil {
                                                    if !sheetArray[sheet].currLabelIcon!.isEmpty {
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
                                            addSheetIcon.toggle()
                                            currSheetIndex = sheet
                                        } label: {
                                            if sheetArray[sheet].currLabelIcon != nil {
                                                Label(sheetArray[sheet].currLabelIcon!.isEmpty ? "Add Icon" : "Change Icon", systemImage: sheetArray[sheet].currLabelIcon!.isEmpty ? "plus.square.dashed" : "arrow.2.squarepath")
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
                }
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
            }
            .fullScreenCover(isPresented: $createNewSheet) { //this is the fullscreencover to create a new sheet
                VStack {
                    Text("\(Image(systemName: "plus.square")) Create a New Sheet")
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        .font(.system(size: 40,  weight: .bold, design: .rounded))
                        .padding()
                    Spacer()
                    ZStack {
                        TextField("Name Sheet", text: $currSheetText, onEditingChanged: { editing in
                            isTextFieldActive = editing
                            sheetAnimate.toggle()
                        }, onCommit: {
                            sheetAnimate.toggle()
                        })
                        .font(.system(size: 65, weight: .semibold, design: .rounded))
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemGray6))
                        )
                    }
                    .minimumScaleFactor(0.01)
                    .padding()
                    Spacer()
                    if !isTextFieldActive { //just to handle the content getting pushed off screen by the keybpoard on smaller devices
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
                                        Image(systemName: "tag.fill")
                                            .resizable()
                                            .foregroundColor(newSheetLabel ? .white : Color(.systemBackground))
                                            .scaledToFit()
                                            .padding(newSheetLabel ? 0 : 85)
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
                        Spacer()
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
                .animation(.spring, value: sheetAnimate)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $renameSheet) {
                VStack {
                    Text("\(Image(systemName: "pencil")) Rename Sheet")
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        .font(.system(size: 40,  weight: .bold, design: .rounded))
                        .padding()
                    Spacer()
                    ZStack {
                        TextField("Name Sheet", text: $currSheetText, onEditingChanged: { editing in
                            isTextFieldActive = editing
                            sheetAnimate.toggle()
                        }, onCommit: {
                            sheetArray[currSheetIndex].label = currSheetText
                            saveSheetArray(sheetObjects: sheetArray)
                            renameSheet.toggle()
                            if currSheetIndex == getCurrSheetIndex() {
                                currSheet.label = currSheetText
                            }
                            currSheetText = ""
                        })
                        .font(.system(size: 65, weight: .semibold, design: .rounded))
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemGray5))
                        )
                    }
                    .minimumScaleFactor(0.01)
                    .padding()
                    Spacer()
                    if sheetArray[currSheetIndex].label == currSheetText {
                        Button(action: {
                            renameSheet.toggle()
                            currSheetText = ""
                        }) {
                            Image(systemName:"xmark.square.fill")
                                .resizable()
                                .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                            //.fontWeight(.bold)
                                .foregroundColor(Color(.systemGray))
                                .padding()
                        }
                    } else {
                        Button(action: {
                            sheetArray[currSheetIndex].label = currSheetText
                            saveSheetArray(sheetObjects: sheetArray)
                            renameSheet.toggle()
                            if currSheetIndex == getCurrSheetIndex() {
                                currSheet.label = currSheetText
                            }
                            currSheetText = ""
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
            }
            .sheet(isPresented: $addSheetIcon) {
                var filteredCustomData: [String] { //search results for custom icons
                    if searchText.isEmpty {
                        return []
                    } else {
                        let matchingKeys = getCustomPECSAddresses().keys.filter { $0.localizedCaseInsensitiveContains(searchText) }
                        
                        let sortedKeys = matchingKeys.sorted { (key1, key2) -> Bool in
                            let startsWithSearchText1 = key1.lowercased().hasPrefix(searchText.lowercased())
                            let startsWithSearchText2 = key2.lowercased().hasPrefix(searchText.lowercased())
                            
                            // Prioritize keys that start with searchText
                            if startsWithSearchText1 && !startsWithSearchText2 {
                                return true
                            } else if !startsWithSearchText1 && startsWithSearchText2 {
                                return false
                            } else {
                                // For keys starting with searchText or having searchText as prefix, sort them alphabetically
                                return key1.localizedCaseInsensitiveCompare(key2) == .orderedAscending
                            }
                        }
                        
                        return sortedKeys
                    }
                }
                
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
                
                VStack { //main list of all the icons
                    ScrollView {
                        TextField("\(Image(systemName: "magnifyingglass")) Search", text: $searchText)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 65, weight: .semibold, design: .rounded))
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(.systemGray4))
                            )
                            .padding()
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) {
                            ForEach(0..<filteredCustomData.count, id: \.self) { key in //first display custom icon results
                                Button(action: {
                                    sheetArray[currSheetIndex].currLabelIcon = "customIconObject:\(filteredCustomData[key])"
                                    updateUsage("customIconObject:\(filteredCustomData[key])")
                                    if currSheetIndex == getCurrSheetIndex() {
                                        currSheet.currLabelIcon = "customIconObject:\(filteredCustomData[key])"
                                    }
                                    addSheetIcon.toggle()
                                    animate.toggle()
                                    saveSheetArray(sheetObjects: sheetArray)
                                }) {
                                    getCustomIconSmall(filteredCustomData[key])
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(lineWidth: 3)
                                        )
                                    //}
                                    
                                }
                                .foregroundColor(.primary)
                                .padding()
                            }
                            ForEach(0..<filteredData.count, id: \.self) { pecsIcon in //next display default icon results
                                Button(action: {
                                    sheetArray[currSheetIndex].currLabelIcon = filteredData[pecsIcon]
                                    updateUsage(filteredData[pecsIcon])
                                    if currSheetIndex == getCurrSheetIndex() {
                                        currSheet.currLabelIcon = filteredData[pecsIcon]
                                    }
                                    addSheetIcon.toggle()
                                    animate.toggle()
                                    saveSheetArray(sheetObjects: sheetArray)
                                }) {
                                    loadImage(named: filteredData[pecsIcon])
                                        .resizable()
                                        .scaledToFill()
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(.black, lineWidth: 3)
                                        )
                                }
                                .foregroundColor(.primary)
                                .padding()
                            }
                        }
                        
                        if filteredData.count + filteredCustomData.count > 0 {
                            Divider()
                                .padding()
                                .padding(.bottom, 50)
                        }
                        
                        if getCustomPECSAddresses().count > 0 {
                            Text("My Icons")
                                .lineLimit(1)
                                .minimumScaleFactor(0.01)
                                .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) { //grid of custom icons
                                ForEach(getCustomPECSAddresses().sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                                    Button(action: {
                                        sheetArray[currSheetIndex].currLabelIcon = "customIconObject:\(key)"
                                        updateUsage("customIconObject:\(key)")
                                        if currSheetIndex == getCurrSheetIndex() {
                                            currSheet.currLabelIcon = "customIconObject:\(key)"
                                        }
                                        addSheetIcon.toggle()
                                        animate.toggle()
                                        saveSheetArray(sheetObjects: sheetArray)
                                    }) {
                                        getCustomIconSmall(key)
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(lineWidth: 3)
                                            )
                                        //}
                                        
                                    }
                                    .foregroundColor(.black)
                                    .padding()
                                }
                            }
                        }
                        ForEach(pecsCategories, id: \.self) { icon in //grid of default icons, also displays categories
                            VStack(alignment: .center) {
                                Text(icon[0])
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.01)
                                    .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) {
                                    ForEach(1..<icon.count, id: \.self) { sheeticonobject in
                                        Button(action: {
                                            sheetArray[currSheetIndex].currLabelIcon = String(icon[sheeticonobject])
                                            updateUsage(String(icon[sheeticonobject]))
                                            if currSheetIndex == getCurrSheetIndex() {
                                                currSheet.currLabelIcon = String(icon[sheeticonobject])
                                            }
                                            addSheetIcon.toggle()
                                            animate.toggle()
                                            saveSheetArray(sheetObjects: sheetArray)
                                        }) {
                                            loadImage(named: String(icon[sheeticonobject]))
                                                .resizable()
                                                .scaledToFill()
                                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .stroke(lineWidth: 3)
                                                )
                                        }
                                        .foregroundColor(.black)
                                        .padding()
                                    }
                                }
                            }
                            .padding()
                        }
                        Text(verbatim: "Daysy Icons provided by www.mypecs.com")
                            .lineLimit(1)
                            .minimumScaleFactor(0.01)
                            .font(.system(size: 25, weight: .medium, design: .rounded))
                            .foregroundColor(Color(.systemGray2))
                    }
                    Button(action: {
                        sheetArray[currSheetIndex].currLabelIcon = ""
                        if currSheetIndex == getCurrSheetIndex() {
                            currSheet.currLabelIcon = ""
                        }
                        animate.toggle()
                        addSheetIcon.toggle()
                        saveSheetArray(sheetObjects: sheetArray)
                    }) {
                        Image(systemName: "trash.square.fill")
                            .resizable()
                            .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                            .padding()
                            .foregroundColor(.red)
                    }
                }
                .ignoresSafeArea(.keyboard)
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
