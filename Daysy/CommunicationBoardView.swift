//
//  CommunicationBoardView.swift
//  Daysy
//
//  Created by Alexander Eischeid on 4/24/24.
//

import SwiftUI
import UniformTypeIdentifiers
import AVFoundation
import Pow


struct CommunicationBoardView: View {
    
    var onDismiss: () -> Void
    
    @Namespace private var animation
    
    @State private var orientation = UIDeviceOrientation.unknown
    @State private var lastOrientation = UIDeviceOrientation.unknown
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @StateObject private var volObserver = VolumeObserver()
    @StateObject private var speechDelegate = SpeechSynthesizerDelegate()
    
    @AppStorage("buttonsOn") private var lockButtonsOn: Bool = false
    @AppStorage("speakOn") private var speakIcons: Bool = true
    
    @FocusState var focusSearch: Bool
    @FocusState var focusType: Bool
    @FocusState var focusFolder: Bool
    @State var showCustomPassword = false
    @State var showSearch = false
    @State var showType = false
    @State var showCanvas = false
    @State var tappedIcons = loadTappedIcons()
    @State var hiddenIcons = loadHiddenIcons()
    @State var animate = false
    @State var searchText = ""
    @State var typeText = ""
    @State var unlockButtons = false
    @State var openFolder = false
    @State var currFolder: [String] = []
    @State var currFolderIndex = 0
    @State var currFolderName = ""
    @State var newFolder = false
    @State var addFolderIcons = false
    @State var showCustom = false
    @State var editCustom = false
    @State var showSettings = false
    @State var openMenu = false
    @State var renameFolder = false
    
    @State var blurOverlay = false
    
    @State var isCustomTextFieldActive = false
    @State var selectedCustomImage: UIImage? = nil
    @State var showImageMenu = false
    @State var isImagePickerPresented = false
    @State var currCustomIconText = ""
    @State var customPECSAddresses = getCustomPECSAddresses()
    @State var customIconPreviews: [String : UIImage] = [:]
    @State var customAnimate = false
    @State var showCamera = false
    @State var oldEditingIcon = ""
    @State var mostIcons = mostUsedIcons()
    
    @State var suggestedLanguages = getSuggestedLanguages()
    @State var otherLanguages = getOtherLanguages()
    @AppStorage("currVoice") private var currVoice: String = "com.apple.ttsbundle.Daniel-compact"
    @AppStorage("currVoiceRatio") private var currVoiceRatio: Double = 1.0
    @State var voiceRatioOptions: [String: Float] = ["Slowest" : 0.1, "Slow" : 0.4, "Normal" : 1.0, "Fast" : 1.1, "Fastest" : 1.3]
    @State var timer: Timer?
    
    @State var currCommunicationBoard: [[String]] = loadCommunicationBoard()
    @State var commBoardIndices: [String] = getCommBoardIndices()
    @State var draggedItem: String?
    
    var body: some View {
        
        var searchResults = searchIcons(searchText)
        
        ZStack {
            VStack {
                if !showType && !showCanvas {
                    ScrollView {
                        if searchResults.isEmpty && showSearch {
                            Text(searchText.isEmpty ? "Search something to get started." : "There are no matches for \(searchText), create your own icon or search for something else.")
                                .minimumScaleFactor(0.01)
                                .multilineTextAlignment(.center)
                                .font(.system(size: horizontalSizeClass == .compact ? 15 : 30, weight: .bold, design: .rounded))
                                .foregroundStyle(.gray)
                                .padding()
                                .padding()
                                .padding(.top, tappedIcons.count > 0 && showSearch ? 100 : 0)
                        } else {
                            VStack {
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: horizontalSizeClass == .compact ? 100 : 150))], spacing: horizontalSizeClass == .compact ? 0 : 20) {
                                    ForEach(0..<searchResults.count, id: \.self) { key in //search results grid
                                        if searchResults[key] != "All Icons" {
                                            if UIImage(named: searchResults[key]) != nil {
                                                Button(action: {
                                                    if !blurOverlay {
                                                        withAnimation(.spring) {
                                                            tappedIcons.append(searchResults[key])
                                                        }
                                                        speechDelegate.stopSpeaking()
                                                        speechDelegate.speak(searchResults[key])
                                                        updateUsage(searchResults[key])
                                                        saveTappedIcons(tappedIcons)
                                                        hapticFeedback()
                                                    } else {
                                                        if currFolderName != "\(Image(systemName: "star.fill")) Most Used" {
                                                            if currFolder.count == 1 {
                                                                withAnimation(.spring) {
                                                                    currCommunicationBoard.remove(at: currFolderIndex)
                                                                    commBoardIndices.remove(at: currFolderIndex)
                                                                }
                                                                saveCommunicationBoard(currCommunicationBoard)
                                                            }
                                                        }
                                                        withAnimation(.spring) {
                                                            blurOverlay = false
                                                        }
                                                    }
                                                }) {
                                                    Image(searchResults[key])
                                                        .resizable()
                                                        .scaledToFill()
                                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 16)
                                                                .stroke(.black, lineWidth: 3)
                                                        )
                                                        .foregroundStyle(.primary)
                                                    //                                                .draggable(Image(searchResults[key]))
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
                                                                //                                                                Button(role: .destructive) {
                                                                //                                                                    hiddenIcons.append(searchResults[key])
                                                                //                                                                    saveHiddenIcons(hiddenIcons)
                                                                //                                                                    withAnimation(.spring) {
                                                                //                                                                        currCommunicationBoard.remove(at: index)
                                                                //                                                                        commBoardIndices.remove(at: index)
                                                                //                                                                    }
                                                                //                                                                    saveCommunicationBoard(currCommunicationBoard)
                                                                //                                                                } label: {
                                                                //                                                                    Label("Hide Icon", systemImage: "eye.slash")
                                                                //                                                                }
                                                            }
                                                        }
                                                    
                                                }
                                            } else {
                                                Button(action: {
                                                    if !blurOverlay {
                                                        withAnimation(.spring) {
                                                            tappedIcons.append(searchResults[key])
                                                        }
                                                        speechDelegate.stopSpeaking()
                                                        speechDelegate.speak(searchResults[key])
                                                        updateUsage(searchResults[key])
                                                        saveTappedIcons(tappedIcons)
                                                    } else {
                                                        if currFolderName != "\(Image(systemName: "star.fill")) Most Used" {
                                                            if currFolder.count == 1 {
                                                                withAnimation(.spring) {
                                                                    currCommunicationBoard.remove(at: currFolderIndex)
                                                                    commBoardIndices.remove(at: currFolderIndex)
                                                                }
                                                                saveCommunicationBoard(currCommunicationBoard)
                                                            }
                                                        }
                                                        withAnimation(.spring) {
                                                            blurOverlay = false
                                                        }
                                                    }
                                                }) {
                                                    Image(uiImage: customIconPreviews[searchResults[key]] ?? UIImage(systemName: "square.fill")!)
                                                        .resizable()
                                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                                        .scaledToFit()
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 16)
                                                                .stroke(lineWidth: 3)
                                                        )
                                                        .foregroundStyle(.primary)
                                                        .accessibilityLabel(extractKey(from: searchResults[key]))
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
                                                                    oldEditingIcon = searchResults[key]
                                                                    currCustomIconText = extractKey(from: searchResults[key])
                                                                    selectedCustomImage = loadImageFromLocalURL(customPECSAddresses[removeCustomIconObjectPrefix(searchResults[key])] ?? "")
                                                                    editCustom.toggle()
                                                                    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { timer in
                                                                        showCustom.toggle()
                                                                    }
                                                                } label: {
                                                                    Label("Edit", systemImage: "square.and.pencil")
                                                                }
                                                                Divider()
                                                                Button(role: .destructive) {
                                                                    let newSheetArray = deleteCustomIcons(currIcon: searchResults[key])
                                                                    saveSheetArray(sheetObjects: newSheetArray)
                                                                    withAnimation(.spring) {
                                                                        tappedIcons = loadTappedIcons()
                                                                        currCommunicationBoard = loadCommunicationBoard()
                                                                        commBoardIndices = getCommBoardIndices()
                                                                        searchResults = searchIcons(searchText)
                                                                    }
                                                                    customPECSAddresses = getCustomPECSAddresses()
                                                                    Task {
                                                                        do {
                                                                            customIconPreviews = await getCustomIconPreviews()
                                                                        }
                                                                    }
                                                                    hapticFeedback(type: 1)
                                                                } label: {
                                                                    Label("Delete Icon", systemImage: "trash")
                                                                }
                                                            }
                                                        }
                                                    
                                                }
                                                .foregroundStyle(.primary)
                                            }
                                        }
                                    }
                                }
                                .padding()
                                if showSearch {
                                    Divider().padding()
                                }
                            }
                            .padding(.top, tappedIcons.count > 0 && !searchResults.isEmpty && showSearch ? 100 : 0)
                        }
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: horizontalSizeClass == .compact ? 100 : 150))], spacing: horizontalSizeClass == .compact ? 0 : 20) { //main grid for comm board
                            if mostIcons.count > 0 {
                                Button(action: {
                                    if !blurOverlay {
                                        withAnimation(.spring) {
                                            openFolder = true
                                            blurOverlay = true
                                        }
                                        speechDelegate.stopSpeaking()
                                        speechDelegate.speak("Most Used")
                                        currFolderIndex = 0
                                        currFolder = Array(mostUsedIcons().prefix(18))
                                        currFolderName = "\(Image(systemName: "star.fill")) Most Used"
                                    } else {
                                        if currFolderName != "\(Image(systemName: "star.fill")) Most Used" {
                                            if currFolder.count == 1 {
                                                withAnimation(.spring) {
                                                    currCommunicationBoard.remove(at: currFolderIndex)
                                                    commBoardIndices.remove(at: currFolderIndex)
                                                }
                                                saveCommunicationBoard(currCommunicationBoard)
                                            }
                                        }
                                        withAnimation(.spring) {
                                            blurOverlay = false
                                        }
                                    }
                                }) {
                                    FavoritesFolderPreviewView(icons: $mostIcons)
                                        .frame(width: horizontalSizeClass == .compact ? 100 : 150, height: horizontalSizeClass == .compact ? 100 : 150)
                                        .padding(.bottom)
                                }
                            }
                            ForEach(0..<commBoardIndices.count, id: \.self) { index in
                                Button(action: {
                                    if currCommunicationBoard[index].count == 1 { //fix the myicons thing when the syncing folder gets fixed
                                        if !blurOverlay {
                                            withAnimation(.spring) {
                                                tappedIcons.append(currCommunicationBoard[index][0])
                                            }
                                            speechDelegate.stopSpeaking()
                                            speechDelegate.speak(currCommunicationBoard[index][0])
                                            updateUsage(currCommunicationBoard[index][0])
                                            saveTappedIcons(tappedIcons)
                                            hapticFeedback()
                                        } else {
                                            if currFolderName != "\(Image(systemName: "star.fill")) Most Used" {
                                                if currFolder.count == 1 {
                                                    withAnimation(.spring) {
                                                        currCommunicationBoard.remove(at: currFolderIndex)
                                                        commBoardIndices.remove(at: currFolderIndex)
                                                    }
                                                    saveCommunicationBoard(currCommunicationBoard)
                                                }
                                            }
                                            withAnimation(.spring) {
                                                blurOverlay = false
                                            }
                                        }
                                    } else {
                                        if !blurOverlay {
                                            withAnimation(.spring) {
                                                openFolder = true
                                                blurOverlay = true
                                            }
                                            speechDelegate.stopSpeaking()
                                            speechDelegate.speak(currCommunicationBoard[index][0])
                                            currFolderIndex = index
                                            currFolder = currCommunicationBoard[index]
                                            currFolderName = currCommunicationBoard[index][0]
                                            
                                        } else {
                                            if currFolderName != "\(Image(systemName: "star.fill")) Most Used" {
                                                if currFolder.count == 1 {
                                                    withAnimation(.spring) {
                                                        currCommunicationBoard.remove(at: currFolderIndex)
                                                        commBoardIndices.remove(at: currFolderIndex)
                                                    }
                                                    saveCommunicationBoard(currCommunicationBoard)
                                                }
                                            }
                                            withAnimation(.spring) {
                                                blurOverlay = false
                                            }
                                        }
                                    }
                                }) {
                                    if currCommunicationBoard[index].count == 1 {
                                        if UIImage(named: currCommunicationBoard[index][0]) != nil {
                                            Image(currCommunicationBoard[index][0])
                                                .resizable()
                                                .scaledToFill()
                                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .stroke(.black, lineWidth: 3)
                                                )
                                                .foregroundStyle(.primary)
                                        } else {
                                            Image(uiImage: customIconPreviews[currCommunicationBoard[index][0]] ?? UIImage(systemName: "square.fill")!)
                                                .resizable()
                                                .scaledToFill()
                                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .stroke(.black, lineWidth: 3)
                                                )
                                                .foregroundStyle(.primary)
                                                .accessibilityLabel(extractKey(from: currCommunicationBoard[index][0]))
                                        }
                                    } else {
                                        FolderPreviewView(currCommunicationBoard: currCommunicationBoard, index: index)
                                            .frame(width: horizontalSizeClass == .compact ? 100 : 150, height: horizontalSizeClass == .compact ? 100 : 150)
                                            .padding(.bottom)
                                    }
                                }
                                .transition(.asymmetric(insertion: .movingParts.iris(blurRadius: 50), removal: .movingParts.vanish(.purple)))
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
                                    } else if currCommunicationBoard[index].count == 1 {
                                        if UIImage(named: currCommunicationBoard[index][0]) == nil {
                                            Button {
                                                oldEditingIcon = currCommunicationBoard[index][0]
                                                currCustomIconText = extractKey(from: currCommunicationBoard[index][0])
                                                selectedCustomImage = loadImageFromLocalURL(customPECSAddresses[removeCustomIconObjectPrefix(currCommunicationBoard[index][0])] ?? "")
                                                editCustom.toggle()
                                                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { timer in
                                                    showCustom.toggle()
                                                }
                                            } label: {
                                                Label("Edit", systemImage: "square.and.pencil")
                                            }
                                            Divider()
                                            Button(role: .destructive) {
                                                let newSheetArray = deleteCustomIcons(currIcon: currCommunicationBoard[index][0])
                                                saveSheetArray(sheetObjects: newSheetArray)
                                                withAnimation(.spring) {
                                                    tappedIcons = loadTappedIcons()
                                                    currCommunicationBoard = loadCommunicationBoard()
                                                    commBoardIndices = getCommBoardIndices()
                                                    searchResults = searchIcons(searchText)
                                                }
                                                customPECSAddresses = getCustomPECSAddresses()
                                                Task {
                                                    do {
                                                        customIconPreviews = await getCustomIconPreviews()
                                                    }
                                                }
                                                hapticFeedback(type: 1)
                                            } label: {
                                                Label("Delete Icon", systemImage: "trash")
                                            }
                                        } else {
                                            Button(role: .destructive) {
                                                hiddenIcons.append(currCommunicationBoard[index][0])
                                                saveHiddenIcons(hiddenIcons)
                                                withAnimation(.spring) {
                                                    currCommunicationBoard.remove(at: index)
                                                    commBoardIndices.remove(at: index)
                                                }
                                                saveCommunicationBoard(currCommunicationBoard)
                                                hapticFeedback(type: 1)
                                            } label: {
                                                Label("Hide Icon", systemImage: "eye.slash")
                                            }
                                        }
                                        Button {
                                            newFolder = true
                                            currFolder = ["New Folder"]
                                            currCommunicationBoard.insert(currFolder, at: 0)
                                            withAnimation(.spring) {
                                                commBoardIndices.insert("0", at: 0)
                                                newFolder = true
                                                blurOverlay = true
                                            }
                                            currFolderIndex = 0
                                            currFolderName = ""
                                            focusFolder = true
                                            currFolder.append(currCommunicationBoard[index+1][0])
                                        } label: {
                                            Label("Create Folder", systemImage: "folder")
                                        }
                                    } else {
                                        Button(role: .destructive) {
                                            withAnimation(.spring) {
                                                currCommunicationBoard.remove(at: index)
                                                saveCommunicationBoard(currCommunicationBoard)
                                                commBoardIndices.remove(at: index)
                                            }
                                        } label: {
                                            Label("Delete Folder", systemImage: "trash")
                                        }
                                        Divider()
                                        Button {
                                            currFolder = currCommunicationBoard[index]
                                            currFolderName = currCommunicationBoard[index][0]
                                            currFolderIndex = index
                                            renameFolder.toggle()
                                        } label: {
                                            Label("Rename Folder", systemImage: "square.and.pencil")
                                        }
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                .onDrag {
                                    self.draggedItem = commBoardIndices[index]
                                    return NSItemProvider(object: commBoardIndices[index] as NSString)
                                }
                                .onDrop(of: [UTType.text], delegate: TextArrayDropDelegate(item: commBoardIndices[index], items: $commBoardIndices, backgroundItems: $currCommunicationBoard, draggedItem: $draggedItem, unlockButtons: $unlockButtons))
                            }
                        }
                        .padding()
                        .padding(.top, horizontalSizeClass == .compact && tappedIcons.count > 0 ? 5 : 15)
                    }
                    .opacity(blurOverlay ? 0.5 : 1.0)
                    .blur(radius: blurOverlay ? 5 : 0)
                } else if showType {
                    VStack {
                        ProgressIndicatorView(isVisible: $showType, type: .bar(progress: Binding(
                            get: { CGFloat(speechDelegate.progress) },
                            set: { speechDelegate.progress = Double($0) }
                        ), backgroundColor: .purple.opacity(0.2)))
                        .padding()
                        .foregroundStyle(.purple)
                        .frame(height: horizontalSizeClass == .compact ? 50 : 75)
                        HStack {
                            Text("Daysy will speak")
                                .minimumScaleFactor(0.01)
                                .lineLimit(1)
                                .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                            Menu {
                                ForEach(voiceRatioOptions.sorted(by: { $0.value < $1.value }), id: \.value) { option in
                                    Button(action: {
                                        currVoiceRatio = Double(option.value)
                                        speechDelegate.stopSpeaking()
                                        if option.key == "Slowest" || option.key == "Fastest" {
                                            speechDelegate.speak("This is the \(option.key) I can speak")
                                        } else {
                                            speechDelegate.speak("I am speaking \(option.key)")
                                        }
                                    }) {
                                        if option.key == "Slowest" {
                                            Text("Very Slow")
                                        } else if option.key == "Fastest" {
                                            Text("Very Fast")
                                        } else {
                                            Text(option.key)
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    if (round(currVoiceRatio * 10) / 10.0) == 0.1 {
                                        Text("Very Slow\(Image(systemName: "chevron.up.chevron.down"))")
                                            .lineLimit(1)
                                            .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                                            .foregroundStyle(.purple)
                                    } else if (round(currVoiceRatio * 10) / 10.0) == 0.4 {
                                        Text("Slow\(Image(systemName: "chevron.up.chevron.down"))")
                                            .lineLimit(1)
                                            .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                                            .foregroundStyle(.purple)
                                    } else if (round(currVoiceRatio * 10) / 10.0) == 1.0 {
                                        Text("Normal\(Image(systemName: "chevron.up.chevron.down"))")
                                            .lineLimit(1)
                                            .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                                            .foregroundStyle(.purple)
                                    } else if (round(currVoiceRatio * 10) / 10.0) == 1.1 {
                                        Text("Fast\(Image(systemName: "chevron.up.chevron.down"))")
                                            .lineLimit(1)
                                            .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                                            .foregroundStyle(.purple)
                                    } else if (round(currVoiceRatio * 10) / 10.0) == 1.3 {
                                        Text("Very Fast\(Image(systemName: "chevron.up.chevron.down"))")
                                            .lineLimit(1)
                                            .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                                            .foregroundStyle(.purple)
                                    }
                                }
                            }
                        }
                        .padding(.top)
                        if horizontalSizeClass != .compact {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: horizontalSizeClass == .compact ? 100 : 150))], spacing: horizontalSizeClass == .compact ? 10 : 20) {
                                ForEach(suggestedLanguages, id: \.self) { item in
                                    Button(action: {
                                        currVoice = item[2]
                                        suggestedLanguages = getSuggestedLanguages()
                                        otherLanguages = getOtherLanguages()
                                        
                                        speechDelegate.stopSpeaking()
                                        speechDelegate.speak("Hello, I'm \(item[1])")
                                    }) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(currVoice == item[2] ? .purple : Color(.systemGray5))
                                                .aspectRatio(2, contentMode: .fit)
                                            HStack {
                                                if currVoice == item[2] {
                                                    Text("\(Image(systemName: "checkmark.circle.fill"))")
                                                        .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .bold, design: .rounded))
                                                        .foregroundStyle(.white)
                                                } else {
                                                    Text("\(Image(systemName: "circle"))")
                                                        .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .bold, design: .rounded))
                                                        .foregroundStyle(.gray)
                                                }
                                                VStack(alignment: .leading) {
                                                    Text(item[1])
                                                        .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .bold, design: .rounded))
                                                        .foregroundStyle(currVoice == item[2] ? .white : .primary)
                                                        .lineLimit(1)
                                                        .minimumScaleFactor(0.1)
                                                    Text(languageNames[item[0]]!)
                                                        .font(.system(size: horizontalSizeClass == .compact ? 15 : 25, weight: .bold, design: .rounded))
                                                        .foregroundStyle(currVoice == item[2] ? .white : .gray)
                                                        .lineLimit(1)
                                                        .minimumScaleFactor(0.1)
                                                        .opacity(currVoice == item[2] ? 0.8 : 1.0)
                                                }
                                            }
                                            .padding(horizontalSizeClass == .compact ? 5 : 10)
                                        }
                                    }
                                }
                            }
                            .padding()
                        }
                        Spacer()
                    }
                } else if showCanvas {
                    CanvasView(onDismiss: {
                        withAnimation(.spring) {
                            showCanvas.toggle()
                        }
                    })
                }
            }
            if openFolder {
                VStack {
                    HStack {
                        if (lockButtonsOn && !unlockButtons) || currFolderName == "\(Image(systemName: "star.fill")) Most Used" {
                            if currFolderName == "\(Image(systemName: "star.fill")) Most Used" {
                                Text("\(Image(systemName: "star.fill")) Most Used")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.01)
                                    .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                            } else {
                                Text(currFolderName)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.01)
                                    .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                            }
                        } else {
                            TextField("New Folder", text: $currFolderName, onEditingChanged: { editing in
                                
                            }, onCommit: {
                                if openFolder {
                                    if currFolderName.isEmpty {
                                        currFolder[0] = "New Folder"
                                    } else {
                                        currFolder[0] = currFolderName
                                    }
                                    currCommunicationBoard[currFolderIndex] = currFolder
                                    saveCommunicationBoard(currCommunicationBoard)
                                }
                            })
                            .lineLimit(1)
                            .minimumScaleFactor(0.01)
                            .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                            .focused($focusFolder)
                        }
                        Spacer()
                        Button(action: {
                            focusFolder = false
                            if currFolderName != "\(Image(systemName: "star.fill")) Most Used" {
                                if currFolder.count <= 1 {
                                    withAnimation(.spring) {
                                        currCommunicationBoard.remove(at: currFolderIndex)
                                        commBoardIndices.remove(at: currFolderIndex)
                                    }
                                    saveCommunicationBoard(currCommunicationBoard)
                                } else {
                                    currFolder[0] = currFolderName
                                    currCommunicationBoard[currFolderIndex] = currFolder
                                    saveCommunicationBoard(currCommunicationBoard)
                                }
                            }
                            withAnimation(.spring) {
                                blurOverlay = false
                            }
                            currFolder = []
                            currFolderIndex = 0
                            currFolderName = ""
                        }) {
                            Text("\(Image(systemName: "xmark.circle.fill"))")
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                                .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                                .foregroundStyle(.gray)
                                .padding()
                        }
                        
                    }
                    ScrollView(showsIndicators: false) {
                        if currFolderName == "\(Image(systemName: "star.fill")) Most Used" {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: horizontalSizeClass == .compact ? 75 : 130))], spacing: 0) {
                                ForEach(0..<currFolder.count, id: \.self) { key in //first display custom icon results
                                    ZStack {
                                        Button(action: {
                                            withAnimation(.spring) {
                                                tappedIcons.append(currFolder[key])
                                            }
                                            speechDelegate.stopSpeaking()
                                            speechDelegate.speak(currFolder[key])
                                            updateUsage(currFolder[key])
                                            saveTappedIcons(tappedIcons)
                                            
                                        }) {
                                            if UIImage(named: currFolder[key]) != nil {
                                                Image(currFolder[key])
                                                    .resizable()
                                                    .scaledToFill()
                                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 16)
                                                            .stroke(.black, lineWidth: 3)
                                                    )
                                                    .foregroundStyle(.primary)
                                            } else {
                                                Image(uiImage: customIconPreviews[currFolder[key]] ?? UIImage(systemName: "square.fill")!)
                                                    .resizable()
                                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                                    .scaledToFit()
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 16)
                                                            .stroke(lineWidth: 3)
                                                    )
                                                    .foregroundStyle(.primary)
                                                    .accessibilityLabel(extractKey(from: currFolder[key]))
                                            }
                                        }
                                    }
                                    .transition(.asymmetric(insertion: .movingParts.iris(blurRadius: 50), removal: .movingParts.vanish(.purple)))
                                }
                            }
                        } else {
                            if currFolder.count <= 1 {
                                Text("Your folder is empty. Add an icon below to get started.")
                                    .minimumScaleFactor(0.01)
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: horizontalSizeClass == .compact ? 15 : 30, weight: .bold, design: .rounded))
                                    .foregroundStyle(.gray)
                            } else {
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: horizontalSizeClass == .compact ? 75 : 130))], spacing: 0) {
                                    ForEach(1..<currFolder.count, id: \.self) { key in //first display custom icon results
                                        ZStack {
                                            if UIImage(named: currFolder[key]) != nil {
                                                Button(action: {
                                                    withAnimation(.spring) {
                                                        tappedIcons.append(currFolder[key])
                                                    }
                                                    speechDelegate.stopSpeaking()
                                                    speechDelegate.speak(currFolder[key])
                                                    updateUsage(currFolder[key])
                                                    saveTappedIcons(tappedIcons)
                                                }) {
                                                    Image(currFolder[key])
                                                        .resizable()
                                                        .scaledToFill()
                                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 16)
                                                                .stroke(.black, lineWidth: 3)
                                                        )
                                                    //                                        .draggable(Image(currFolder[key]))
                                                        .foregroundStyle(.primary)
                                                        .contextMenu {
                                                            Button(role: .destructive) {
                                                                withAnimation(.spring) {
                                                                    currFolder.remove(at: key)
                                                                }
                                                                if currFolder.count > 1 {
                                                                    currCommunicationBoard[currFolderIndex] = currFolder
                                                                    saveCommunicationBoard(currCommunicationBoard)
                                                                }
                                                            } label: {
                                                                Label("Remove from Folder", systemImage: "folder.badge.minus")
                                                            }
                                                        }
                                                        .padding(.bottom)
                                                }
                                            } else {
                                                Button(action: {
                                                    withAnimation(.spring) {
                                                        tappedIcons.append(currFolder[key])
                                                    }
                                                    speechDelegate.stopSpeaking()
                                                    speechDelegate.speak(currFolder[key])
                                                    updateUsage(currFolder[key])
                                                    saveTappedIcons(tappedIcons)
                                                }) {
                                                    Image(uiImage: customIconPreviews[currFolder[key]] ?? UIImage(systemName: "square.fill")!)
                                                        .resizable()
                                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                                        .scaledToFit()
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 16)
                                                                .stroke(lineWidth: 3)
                                                        )
                                                        .foregroundStyle(.primary)
                                                        .accessibilityLabel(extractKey(from: currFolder[key]))
                                                        .contextMenu {
                                                            Button(role: .destructive) {
                                                                currFolder.remove(at: key)
                                                                if currFolder.count > 1 {
                                                                    currCommunicationBoard[currFolderIndex] = currFolder
                                                                    saveCommunicationBoard(currCommunicationBoard)
                                                                }
                                                                animate.toggle()
                                                            } label: {
                                                                Label("Remove from Folder", systemImage: "folder.badge.minus")
                                                            }
                                                        }
                                                        .padding(.bottom)
                                                }
                                                .foregroundStyle(.primary)
                                            }
                                        }
                                        .onDrag({
                                            self.draggedItem = currFolder[key]
                                            return NSItemProvider(item: nil, typeIdentifier: currFolder[key])
                                        })
                                        .onDrop(of: [UTType.text], delegate: TextDropDelegate(item: currFolder[key], items: $currFolder, draggedItem: $draggedItem))
                                    }
                                }
                            }
                            if !unlockButtons {
                                Button(action: {
                                    withAnimation(.spring) {
                                        addFolderIcons.toggle()
                                    }
                                }) {
                                    Text("Add Icons \(Image(systemName: addFolderIcons ? "chevron.down" : "chevron.forward"))")
                                        .font(.system(size: horizontalSizeClass == .compact ? 17 : 25, weight: .bold, design: .rounded))
                                        .padding()
                                        .foregroundStyle(.purple)
                                }
                            }
                            if addFolderIcons {
                                Divider().padding() //maybe have a menu just expand this instead of being right here
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: horizontalSizeClass == .compact ? 75 : 130))], spacing: 0) {
                                    ForEach(0..<currCommunicationBoard.count, id: \.self) { index in
                                        if currCommunicationBoard[index].count == 1 && !currFolder.contains(currCommunicationBoard[index][0]) {
                                            Button(action: {
                                                withAnimation(.spring) {
                                                    currFolder.append(currCommunicationBoard[index][0])
                                                }
                                                currCommunicationBoard[currFolderIndex] = currFolder
                                                saveCommunicationBoard(currCommunicationBoard)
                                            }) {
                                                if UIImage(named: currCommunicationBoard[index][0]) != nil {
                                                    Image(currCommunicationBoard[index][0])
                                                        .resizable()
                                                        .scaledToFit()
                                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                                        .foregroundStyle(.primary)
                                                        .overlay(
                                                            ZStack {
                                                                RoundedRectangle(cornerRadius: 16)
                                                                    .stroke(.black, lineWidth: 3)
                                                                VStack {
                                                                    HStack {
                                                                        Image(systemName: "plus.circle.fill")
                                                                            .resizable()
                                                                            .frame(width: horizontalSizeClass == .compact ? 30 : 40, height: horizontalSizeClass == .compact ? 30 : 40)
                                                                            .foregroundStyle(.purple)
                                                                        Spacer()
                                                                    }
                                                                    Spacer()
                                                                }
                                                            }
                                                        )
                                                        .padding(.trailing, 5)
                                                } else {
                                                    Button(action: {
                                                        withAnimation(.spring) {
                                                            currFolder.append(currCommunicationBoard[index][0])
                                                        }
                                                        currCommunicationBoard[currFolderIndex] = currFolder
                                                        saveCommunicationBoard(currCommunicationBoard)
                                                    }) {
                                                        Image(uiImage: customIconPreviews[currCommunicationBoard[index][0]] ?? UIImage(systemName: "square.fill")!)
                                                            .resizable()
                                                            .scaledToFit()
                                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                                            .foregroundStyle(.primary)
                                                            .accessibilityLabel(extractKey(from: currCommunicationBoard[index][0]))
                                                            .overlay(
                                                                ZStack {
                                                                    RoundedRectangle(cornerRadius: 16)
                                                                        .stroke(.black, lineWidth: 3)
                                                                    VStack {
                                                                        HStack {
                                                                            Image(systemName: "plus.circle.fill")
                                                                                .resizable()
                                                                                .frame(width: horizontalSizeClass == .compact ? 30 : 40, height: horizontalSizeClass == .compact ? 30 : 40)
                                                                                .foregroundStyle(.purple)
                                                                            Spacer()
                                                                        }
                                                                        Spacer()
                                                                    }
                                                                }
                                                            )
                                                            .padding(.trailing, 5)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .transition(.move(edge: .bottom))
                .padding()
                .background(
                    .thinMaterial,
                    in: RoundedRectangle(cornerRadius: 20)
                )
                .padding(25)
                .padding(.top, tappedIcons.count > 0 ? 100 : 0)
            }
//
            if newFolder {
                VStack {
                    HStack {
                        if lockButtonsOn && !unlockButtons {
                            Text(currFolderName)
                                .lineLimit(1)
                                .minimumScaleFactor(0.01)
                                .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                        } else {
                            TextField("Folder Name", text: $currFolderName, onEditingChanged: { editing in
                                
                            }, onCommit: {
                                if newFolder {
                                    if currFolderName.isEmpty {
                                        currFolder[0] = "New Folder"
                                    } else {
                                        currFolder[0] = currFolderName
                                    }
                                    currCommunicationBoard[currFolderIndex] = currFolder
                                    saveCommunicationBoard(currCommunicationBoard)
                                }
                            })
                            .focused($focusFolder)
                            .lineLimit(1)
                            .minimumScaleFactor(0.01)
                            .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                        }
                        Spacer()
                        Button(action: {
                            focusFolder = false
                            if currFolderName != "\(Image(systemName: "star.fill")) Most Used" {
                                if currFolder.count <= 1 {
                                    withAnimation(.spring) {
                                        currCommunicationBoard.remove(at: currFolderIndex)
                                    }
                                    saveCommunicationBoard(currCommunicationBoard)
                                } else {
                                    currFolder[0] = currFolderName
                                    currCommunicationBoard[currFolderIndex] = currFolder
                                    saveCommunicationBoard(currCommunicationBoard)
                                }
                            }
                            withAnimation(.spring) {
                                blurOverlay = false
                            }
                            currFolder = []
                            currFolderIndex = 0
                            currFolderName = ""
                            animate.toggle()
                        }) {
                            Text("\(Image(systemName: "xmark.circle.fill"))")
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                                .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                                .foregroundStyle(.gray)
                                .padding()
                        }
                        
                    }
                    ScrollView(showsIndicators: false) {
                        if currFolder.count <= 1 {
                            Text("Your folder is empty. Add an icon below to get started.")
                                .minimumScaleFactor(0.01)
                                .multilineTextAlignment(.center)
                                .font(.system(size: horizontalSizeClass == .compact ? 15 : 30, weight: .bold, design: .rounded))
                                .foregroundStyle(.gray)
                        } else {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: horizontalSizeClass == .compact ? 75 : 130))], spacing: 0) {
                                ForEach(1..<currFolder.count, id: \.self) { key in
                                    ZStack {
                                        if UIImage(named: currFolder[key]) != nil {
                                            Button(action: {
                                                withAnimation(.spring) {
                                                    tappedIcons.append(currFolder[key])
                                                }
                                                speechDelegate.stopSpeaking()
                                                speechDelegate.speak(currFolder[key])
                                                updateUsage(currFolder[key])
                                                saveTappedIcons(tappedIcons)
                                            }) {
                                                Image(currFolder[key])
                                                    .resizable()
                                                    .scaledToFill()
                                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 16)
                                                            .stroke(.black, lineWidth: 3)
                                                    )
                                                //                                        .draggable(Image(currFolder[key]))
                                                    .foregroundStyle(.primary)
                                                    .contextMenu {
                                                        Button(role: .destructive) {
                                                            currFolder.remove(at: key)
                                                            if currFolder.count > 1 {
                                                                currCommunicationBoard[currFolderIndex] = currFolder
                                                                saveCommunicationBoard(currCommunicationBoard)
                                                            }
                                                            animate.toggle()
                                                        } label: {
                                                            Label("Remove from Folder", systemImage: "folder.badge.minus")
                                                        }
                                                    }
                                                    .padding(.bottom)
                                            }
                                        } else {
                                            Button(action: {
                                                withAnimation(.spring) {
                                                    tappedIcons.append(currFolder[key])
                                                }
                                                speechDelegate.stopSpeaking()
                                                speechDelegate.speak(currFolder[key])
                                                updateUsage(currFolder[key])
                                                saveTappedIcons(tappedIcons)
                                            }) {
                                                Image(uiImage: customIconPreviews[currFolder[key]] ?? UIImage(systemName: "square.fill")!)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 16)
                                                            .stroke(lineWidth: 3)
                                                    )
                                                    .foregroundStyle(.primary)
                                                    .accessibilityLabel(extractKey(from: currFolder[key]))
                                                    .contextMenu {
                                                        Button(role: .destructive) {
                                                            currFolder.remove(at: key)
                                                            if currFolder.count > 1 {
                                                                currCommunicationBoard[currFolderIndex] = currFolder
                                                                saveCommunicationBoard(currCommunicationBoard)
                                                            }
                                                            animate.toggle()
                                                        } label: {
                                                            Label("Remove from Folder", systemImage: "folder.badge.minus")
                                                        }
                                                    }
                                                    .padding(.bottom)
                                            }
                                            .foregroundStyle(.primary)
                                        }
                                    }
                                    .onDrag({
                                        self.draggedItem = currFolder[key]
                                        return NSItemProvider(item: nil, typeIdentifier: currFolder[key])
                                    })
                                    .onDrop(of: [UTType.text], delegate: TextDropDelegate(item: currFolder[key], items: $currFolder, draggedItem: $draggedItem))
                                    .transition(.asymmetric(insertion: .movingParts.iris(blurRadius: 50), removal: .movingParts.vanish(.purple)))
                                }
                            }
                        }
                        Divider().padding()
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: horizontalSizeClass == .compact ? 75 : 130))], spacing: 0) {
                            ForEach(1..<currCommunicationBoard.count, id: \.self) { index in
                                if currCommunicationBoard[index].count == 1 && !currFolder.contains(currCommunicationBoard[index][0]) {
                                    Button(action: {
                                        withAnimation(.spring) {
                                            currFolder.append(currCommunicationBoard[index][0])
                                        }
                                        currCommunicationBoard[currFolderIndex] = currFolder
                                        saveCommunicationBoard(currCommunicationBoard)
                                    }) {
                                        if UIImage(named: currCommunicationBoard[index][0]) != nil {
                                            Image(currCommunicationBoard[index][0])
                                                .resizable()
                                                .scaledToFit()
                                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                                .foregroundStyle(.primary)
                                                .overlay(
                                                    ZStack {
                                                        RoundedRectangle(cornerRadius: 16)
                                                            .stroke(.black, lineWidth: 3)
                                                        VStack {
                                                            HStack {
                                                                Image(systemName: "plus.circle.fill")
                                                                    .resizable()
                                                                    .frame(width: horizontalSizeClass == .compact ? 30 : 40, height: horizontalSizeClass == .compact ? 30 : 40)
                                                                    .foregroundStyle(.purple)
                                                                Spacer()
                                                            }
                                                            Spacer()
                                                        }
                                                    }
                                                )
                                                .padding(.trailing, 5)
                                        } else {
                                            Button(action: {
                                                withAnimation(.spring) {
                                                    currFolder.append(currCommunicationBoard[index][0])
                                                }
                                                currCommunicationBoard[currFolderIndex] = currFolder
                                                saveCommunicationBoard(currCommunicationBoard)
                                            }) {
                                                Image(uiImage: customIconPreviews[currCommunicationBoard[index][0]] ?? UIImage(systemName: "square.fill")!)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                                    .foregroundStyle(.primary)
                                                    .accessibilityLabel(extractKey(from: currCommunicationBoard[index][0]))
                                                    .overlay(
                                                        ZStack {
                                                            RoundedRectangle(cornerRadius: 16)
                                                                .stroke(.black, lineWidth: 3)
                                                            VStack {
                                                                HStack {
                                                                    Image(systemName: "plus.circle.fill")
                                                                        .resizable()
                                                                        .frame(width: horizontalSizeClass == .compact ? 30 : 40, height: horizontalSizeClass == .compact ? 30 : 40)
                                                                        .foregroundStyle(.purple)
                                                                    Spacer()
                                                                }
                                                                Spacer()
                                                            }
                                                        }
                                                    )
                                                    .padding(.trailing, 5)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .transition(.move(edge: .bottom))
                .padding()
                .background(
                    .thinMaterial,
                    in: RoundedRectangle(cornerRadius: 20)
                )
                .padding(25)
                .padding(.top, tappedIcons.count > 0 ? 100 : 0)
            }
            VStack {
                if !showType && tappedIcons.count > 0 && !showCanvas {
                    HStack {
                        Button(action: {
                            speechDelegate.stopSpeaking()
                            speechDelegate.speak(formIntelligentSentence(from: tappedIcons))
                            updateUsage("action:play")
                        }) {
                            Image(systemName: "play.square.fill")
                                .resizable()
                                .frame(width: horizontalSizeClass == .compact ? 50 : 100, height: horizontalSizeClass == .compact ? 50 : 100)
                                .foregroundStyle(.purple)
                                .symbolRenderingMode(.hierarchical)
                                .padding(.leading, 5)
                                .accessibilityHint(Text("Plays your tapped icons."))
                        }
                        ScrollView(.horizontal, showsIndicators: false) {
                            ScrollViewReader { value in
                                HStack {
                                    ForEach(0..<tappedIcons.count, id: \.self) { icon in //next display default icon results
                                        if UIImage(named: tappedIcons[icon]) != nil {
                                            Image(tappedIcons[icon])
                                                .resizable()
                                                .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .stroke(.black, lineWidth: 3)
                                                )
                                            //                                                .draggable(Image(tappedIcons[key]))
                                                .padding(.trailing, 5)
                                                .foregroundStyle(.primary)
                                                .transition(.identity.combined(with: .opacity))
                                        } else {
                                            Image(uiImage: customIconPreviews[tappedIcons[icon]] ?? UIImage(systemName: "square.fill")!)
                                                .resizable()
                                                .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .stroke(lineWidth: 3)
                                                )
                                                .padding(.trailing, 5)
                                                .foregroundStyle(.primary)
                                                .transition(.identity.combined(with: .opacity))
                                                .accessibilityLabel(extractKey(from: tappedIcons[icon]))
                                        }
                                    }
                                    .onChange(of: tappedIcons.count) { _ in
                                        value.scrollTo(tappedIcons.count - 1)
                                        animate.toggle()
                                    }
                                }
                                .padding(.trailing, horizontalSizeClass == .compact ? 75 : 100)
                            }
                        }
                        Button(action: {
                            tappedIcons.removeAll()
                            speechDelegate.stopSpeaking()
                            saveTappedIcons(tappedIcons)
                            animate.toggle()
                        }) {
                            Image(systemName: "delete.backward.fill")
                                .resizable()
                                .frame(width: horizontalSizeClass == .compact ? 57.5 : 115, height: horizontalSizeClass == .compact ? 50 : 100)
                                .foregroundStyle(.red)
                                .symbolRenderingMode(.hierarchical)
                                .padding(.trailing, 5)
                                .accessibilityHint(Text("Deletes your tapped icons."))
                        }
                    }
                    .transition(.opacity)
                    .padding(.bottom, openMenu && horizontalSizeClass == .compact ? 0 : 20)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color(.systemBackground), Color(.systemBackground), Color.clear]), startPoint: .top, endPoint: .bottom)
                            .ignoresSafeArea()
                    )
                }
                Spacer()
                if !blurOverlay {
                    VStack {
                        Spacer()
                        HStack {
                            if showSearch {
                                HStack {
                                    Button(action: {
                                        searchText = ""
                                        showSearch.toggle()
                                        focusSearch = false
                                        animate.toggle()
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .resizable()
                                            .frame(width: horizontalSizeClass == .compact ? 50 : 75, height: horizontalSizeClass == .compact ? 50 : 75)
                                            .foregroundStyle(.gray)
                                    }
                                    TextField("\(Image(systemName: "magnifyingglass")) Search", text: $searchText)
                                        .focused($focusSearch)
                                        .minimumScaleFactor(0.1)
                                        .font(.system(size: horizontalSizeClass == .compact ? 40 : 65, weight: .semibold,  design: .rounded))
                                        .padding()
                                        .background(
                                            Color(.systemGray6),
                                            in: RoundedRectangle(cornerRadius: 20)
                                        )
                                }
                                .shadow(color: Color(.systemBackground), radius: 10.0)
                                .padding(.bottom)
                            } else if showType {
                                HStack {
                                    Button(action: {
                                        typeText = ""
                                        showType.toggle()
                                        focusType = false
                                        speechDelegate.stopSpeaking()
                                        speechDelegate.progress = 0.0
                                        animate.toggle()
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .resizable()
                                            .frame(width: horizontalSizeClass == .compact ? 50 : 75, height: horizontalSizeClass == .compact ? 50 : 75)
                                            .foregroundStyle(.gray)
                                            .symbolRenderingMode(.hierarchical)
                                    }
                                    TextEditor(text: $typeText)
                                        .focused($focusType)
                                        .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .semibold, design: .rounded))
                                        .aspectRatio(horizontalSizeClass == .compact ? 2 : 4, contentMode: .fit)
                                        .clipShape(
                                            RoundedRectangle(cornerRadius: 20)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(.purple, lineWidth: horizontalSizeClass == .compact ? 3 : 6)
                                        )
                                        .padding(.bottom, 2)
                                    
                                }
                                .onAppear {
                                    speechDelegate.progress = 0.0
                                }
                                VStack {
                                    Button(action: {
                                        speechDelegate.stopSpeaking()
                                        if !speechDelegate.isSpeaking && !typeText.isEmpty {
                                            speechDelegate.speak(typeText)
                                            updateUsage("action:play")
                                        } else {
                                            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { timer in
                                                speechDelegate.progress = 0.0
                                            }
                                        }
                                    }) {
                                        Image(systemName: speechDelegate.isSpeaking ? "stop.circle.fill" : "play.square.fill")
                                            .resizable()
                                            .frame(width: horizontalSizeClass == .compact ? 50 : 75, height: horizontalSizeClass == .compact ? 50 : 75)
                                            .foregroundStyle(.purple)
                                            .symbolRenderingMode(.hierarchical)
                                    }
                                    if speechDelegate.progress < 1.0 && speechDelegate.progress > 0.0 {
                                        Button(action: {
                                            if speechDelegate.isPaused {
                                                speechDelegate.continueSpeaking()
                                            } else if speechDelegate.isSpeaking {
                                                speechDelegate.pauseSpeaking(at: AVSpeechBoundary.immediate)
                                            }
                                        }) {
                                            Image(systemName: speechDelegate.isPaused ? "play.circle" : "pause.circle")
                                                .resizable()
                                                .frame(width: horizontalSizeClass == .compact ? 50 : 75, height: horizontalSizeClass == .compact ? 50 : 75)
                                                .foregroundStyle(.purple)
                                                .symbolRenderingMode(.hierarchical)
                                        }
                                        .transition(.opacity)
                                    }
                                }
                            }
                            Spacer()
                            if openMenu && !(showSearch || showType) {
                                VStack {
                                    if lockButtonsOn && !unlockButtons {
                                        Button(action: {
                                            if !canUseBiometrics() && !canUsePassword() {
                                                showCustomPassword = true
                                            } else {
                                                Task {
                                                    unlockButtons = await authenticateWithBiometrics()
                                                    animate.toggle()
                                                }
                                                if unlockButtons {
                                                    withAnimation(.spring) {
                                                        unlockButtons = false
                                                    }
                                                }
                                            }
                                        }) {
                                            Image(systemName: "lock.square.fill")
                                                .resizable()
                                                .frame(width: horizontalSizeClass == .compact ? 65 : 75, height: horizontalSizeClass == .compact ? 65 : 75)
                                                .foregroundStyle(.gray)
                                        }
                                    }
                                    Button(action: {
                                        withAnimation(.spring) {
                                            showSearch.toggle()
                                            focusSearch = true
                                        }
                                    }) {
                                        VStack {
                                            ZStack {
                                                Image(systemName: "square.fill")
                                                    .resizable()
                                                    .frame(width: horizontalSizeClass == .compact ? 65 : 75, height: horizontalSizeClass == .compact ? 65 : 75)
                                                    .foregroundStyle(.gray)
                                                Image(systemName: "magnifyingglass")
                                                    .resizable()
                                                    .frame(width: horizontalSizeClass == .compact ? min(30, 75) : min(40, 100), height: horizontalSizeClass == .compact ? min(30, 75) : min(40, 100))
                                                    .foregroundStyle(Color(.systemGray6))
                                            }
                                        }
                                    }
                                    
                                    Button(action: {
                                        withAnimation(.spring) {
                                            showType.toggle()
                                            focusType = true
                                        }
                                    }) {
                                        VStack {
                                            ZStack {
                                                Image(systemName: "square.fill")
                                                    .resizable()
                                                    .frame(width: horizontalSizeClass == .compact ? 65 : 75, height: horizontalSizeClass == .compact ? 65 : 75)
                                                    .foregroundStyle(.gray)
                                                Image(systemName: "keyboard")
                                                    .resizable()
                                                    .frame(width: horizontalSizeClass == .compact ? min(39, 98) : min(40, 100), height: horizontalSizeClass == .compact ? min(30, 75) : min(40, 100))
                                                    .foregroundStyle(Color(.systemGray6))
                                            }
                                        }
                                    }
                                    
                                    Button(action: {
                                        withAnimation(.spring) {
                                            showCanvas.toggle()
                                            openMenu.toggle()
                                        }
                                    }) {
                                        VStack {
                                            ZStack {
                                                Image(systemName: "square.fill")
                                                    .resizable()
                                                    .frame(width: horizontalSizeClass == .compact ? 65 : 75, height: horizontalSizeClass == .compact ? 65 : 75)
                                                    .foregroundStyle(.cyan)
                                                Image(systemName: "pencil.and.outline")
                                                    .resizable()
                                                    .frame(width: horizontalSizeClass == .compact ? min(30, 75) : min(40, 100), height: horizontalSizeClass == .compact ? min(30, 75) : min(40, 100))
                                                    .foregroundStyle(Color(.systemGray6))
                                                    .symbolRenderingMode(.hierarchical)
                                            }
                                        }
                                    }
                                    if !lockButtonsOn || unlockButtons {
                                        Button(action: {
                                            showCustom = true
                                            //                                        blurOverlay = true
                                        }) {
                                            VStack {
                                                ZStack {
                                                    Image(systemName: "square.fill")
                                                        .resizable()
                                                        .frame(width: horizontalSizeClass == .compact ? 65 : 75, height: horizontalSizeClass == .compact ? 65 : 75)
                                                        .foregroundStyle(.green)
                                                    Image(systemName: "plus.viewfinder")
                                                        .resizable()
                                                        .frame(width: horizontalSizeClass == .compact ? min(30, 75) : min(40, 100), height: horizontalSizeClass == .compact ? min(30, 75) : min(40, 100))
                                                        .foregroundStyle(Color(.systemGray6))
                                                        .symbolRenderingMode(.hierarchical)
                                                }
                                            }
                                        }
                                        
                                        Button(action: {
                                            currFolder = ["New Folder"]
                                            currCommunicationBoard.insert(currFolder, at: 0)
                                            withAnimation(.spring) {
                                                commBoardIndices.insert("0", at: 0)
                                                newFolder = true
                                                blurOverlay = true
                                            }
                                            currFolderIndex = 0
                                            currFolderName = ""
                                            focusFolder = true
                                        }) {
                                            VStack {
                                                ZStack {
                                                    Image(systemName: "square.fill")
                                                        .resizable()
                                                        .frame(width: horizontalSizeClass == .compact ? 65 : 75, height: horizontalSizeClass == .compact ? 65 : 75)
                                                        .foregroundStyle(.blue)
                                                    Image(systemName: "folder.badge.plus")
                                                        .resizable()
                                                        .frame(width: horizontalSizeClass == .compact ? min(39, 98) : min(40, 100), height: horizontalSizeClass == .compact ? min(30, 75) : min(40, 100))
                                                        .foregroundStyle(Color(.systemGray6))
                                                        .padding(.leading, 5)
                                                        .padding(.bottom, 3)
                                                }
                                            }
                                        }
                                        
                                        Button(action: {
                                            showSettings.toggle()
                                        }) {
                                            VStack {
                                                ZStack {
                                                    Image(systemName: "square.fill")
                                                        .resizable()
                                                        .frame(width: horizontalSizeClass == .compact ? 65 : 75, height: horizontalSizeClass == .compact ? 65 : 75)
                                                        .foregroundStyle(.gray)
                                                    Image(systemName: "gear")
                                                        .resizable()
                                                        .frame(width: horizontalSizeClass == .compact ? min(30, 75) : min(40, 100), height: horizontalSizeClass == .compact ? min(30, 75) : min(40, 100))
                                                        .foregroundStyle(Color(.systemGray6))
                                                }
                                            }
                                        }
                                        
                                        Button(action: {
                                            onDismiss()
                                            speechDelegate.stopSpeaking()
                                        }) {
                                            VStack {
                                                ZStack {
                                                    Image(systemName: "square.fill")
                                                        .resizable()
                                                        .frame(width: horizontalSizeClass == .compact ? 65 : 75, height: horizontalSizeClass == .compact ? 65 : 75)
                                                        .foregroundStyle(.purple)
                                                    Image(systemName: "newspaper")
                                                        .resizable()
                                                        .frame(width: horizontalSizeClass == .compact ? min(35, 86) : min(40, 100), height: horizontalSizeClass == .compact ? min(30, 75) : min(40, 100))
                                                        .foregroundStyle(Color(.systemGray6))
                                                }
                                            }
                                        }
                                    }
                                }
                                .transition(.move(edge: .trailing))
                                .padding()
                                .background(
                                    .thinMaterial,
                                    in: RoundedRectangle(cornerRadius: 20)
                                )
                            }
                        }
                        if !showType && !showSearch && !showCanvas {
                            HStack {
                                Spacer()
                                Button(action: {
                                    withAnimation(.spring) {
                                        openMenu.toggle()
                                        unlockButtons = false
                                    }
                                }) {
                                    ZStack {
                                        Image(systemName: "square.fill")
                                            .resizable()
                                            .frame(width: horizontalSizeClass == .compact ? 65 : 75, height: horizontalSizeClass == .compact ? 65 : 75)
                                            .foregroundStyle(.thickMaterial)
                                            .shadow(color: Color(.systemBackground), radius: 15.0)
                                        Text("\(Image(systemName: openMenu ? "menucard.fill" : "menucard"))")
                                            .font(.system(size: horizontalSizeClass == .compact ? 30 : 40))
                                            .foregroundStyle(.gray)
                                            .symbolRenderingMode(openMenu ? .hierarchical : .monochrome)
                                    }
                                    .padding(.trailing)
                                    .padding(.bottom, horizontalSizeClass == .compact ? 0 : 5)
                                }
                            }
                            .ignoresSafeArea()
                        }
                    }
                }
            }
        }
        .task {
            customIconPreviews = await getCustomIconPreviews()
            animate.toggle()
        }
        .navigationBarHidden(true)
        .animation(.spring, value: animate)
        .onChange(of: searchText, perform: { _ in
            searchResults = searchIcons(searchText)
            if searchResults.isEmpty {
                searchResults = searchIcons(autoCorrectComplete(text: searchText))
            }
        })
        .sheet(isPresented: $showCustomPassword) { //set and/or verify custom password if bioauth and password not set
            CustomPasswordView(dismissSheet: { result in
                withAnimation(.spring) {
                    unlockButtons = result
                }
                showCustomPassword = false
            })
        }
        .fullScreenCover(isPresented: $showCustom) {
        CreateIconView(modifyCustomIcon: {
            customPECSAddresses = getCustomPECSAddresses()
            currCommunicationBoard = loadCommunicationBoard()
            commBoardIndices = getCommBoardIndices()
            blurOverlay = false
            Task {
                do {
                    customIconPreviews = await getCustomIconPreviews()
                }
            }
        }, selectedCustomImage: $selectedCustomImage, currCustomIconText: $currCustomIconText, oldEditingIcon: $oldEditingIcon, editCustom: $editCustom)
        .transition(.move(edge: .bottom))
    }
        .onChange(of: blurOverlay, perform: { _ in
            if !blurOverlay {
                withAnimation(.spring) {
                    openFolder = false
                    newFolder = false
                    showCustom = false
                }
            }
        })
        .sheet(isPresented: $renameFolder) {
            VStack {
                Spacer()
                FolderPreviewView(currCommunicationBoard: currCommunicationBoard, index: currFolderIndex, altText: "")
                    .frame(width: min(300, 960), height: min(240, 800))
                    .padding()
                TextField("New Folder", text: $currFolderName, onCommit: {
                    if currFolderName != currCommunicationBoard[currFolderIndex][0] {
                        currFolder[0] = currFolderName
                        currCommunicationBoard[currFolderIndex] = currFolder
                        saveCommunicationBoard(currCommunicationBoard)
                    }
                    renameFolder.toggle()
                    focusType = false
                })
                .focused($focusType)
                .font(.system(size: horizontalSizeClass == .compact ? 35 : 65, weight: .semibold, design: .rounded))
                .padding()
                .background(
                    .thinMaterial,
                    in: RoundedRectangle(cornerRadius: 20)
                )
                .padding([.leading, .trailing])
                Spacer()
                Button(action: {
                    if currFolderName != currCommunicationBoard[currFolderIndex][0] {
                        currFolder[0] = currFolderName
                        currCommunicationBoard[currFolderIndex] = currFolder
                        saveCommunicationBoard(currCommunicationBoard)
                    }
                    renameFolder.toggle()
                    focusType = false
                }) {
                    if currFolderName.isEmpty || currFolderName == currCommunicationBoard[currFolderIndex][0] {
                        Image(systemName:"xmark.square.fill")
                            .resizable()
                            .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                            .foregroundStyle(.gray)
                            .padding()
                    } else {
                        Image(systemName:"checkmark.square.fill")
                            .resizable()
                            .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                            .foregroundStyle(.green)
                            .padding()
                    }
                }
            }
            .onAppear{focusType = true}
        }
        .fullScreenCover(isPresented: $showSettings) { //fullscreencover for the settings page
            SettingsView(onDismiss: {
//                lockButtonsOn = defaults.bool(forKey: "buttonsOn")
                unlockButtons = false
            }, sheetMode: false)
        }
        .onRotate { newOrientation in
            orientation = newOrientation
            if !newOrientation.isFlat {
                lastOrientation = newOrientation
            }
        }
        .onAppear{ //re-check for notification permission when settings opened
            @State var notificationsAllowed: Bool?
            if notificationsAllowed != nil {
                currSessionLog.append("notification status has already been set")
            } else {
                defaults.set(true, forKey : "notificationsAllowed")
            }
        }
        .onChange(of: currFolder, perform: { _ in
            if !currFolder.isEmpty && currFolderName != "\(Image(systemName: "star.fill")) Most Used" {
                currCommunicationBoard[currFolderIndex] = currFolder
                saveCommunicationBoard(currCommunicationBoard)
            }
        })
        .onChange(of: commBoardIndices, perform: { _ in
            animate.toggle()
            if !commBoardIndices.isEmpty {
                saveCommunicationBoard(currCommunicationBoard)
            }
        })
        .onChange(of: typeText, perform: { _ in
            if !speechDelegate.isSpeaking {
                speechDelegate.progress = 0.0
            }
        })
    }
    private func cleanUp() {
        // Invalidate timer
        timer?.invalidate()
        timer = nil
        
        // Reset states
        focusSearch = false
        focusType = false
        focusFolder = false
        
        showCustomPassword = false
        showSearch = false
        showType = false
        showCanvas = false
        
        // If needed, save or reset loaded data
        tappedIcons = []
        hiddenIcons = []
        searchText = ""
        typeText = ""
        
        unlockButtons = false
        openFolder = false
        currFolder = []
        currFolderIndex = 0
        currFolderName = ""
        newFolder = false
        addFolderIcons = false
        showCustom = false
        editCustom = false
        showSettings = false
        openMenu = false
        renameFolder = false
        blurOverlay = false
        isCustomTextFieldActive = false
        selectedCustomImage = nil
        showImageMenu = false
        isImagePickerPresented = false
        currCustomIconText = ""
        customIconPreviews = [:]
        customAnimate = false
        showCamera = false
        oldEditingIcon = ""
        mostIcons = []
        suggestedLanguages = []
        otherLanguages = []
        
        currCommunicationBoard = []
        commBoardIndices = []
        draggedItem = nil
    }
}
