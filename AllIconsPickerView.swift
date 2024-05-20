//
//  AllIconsPickerView.swift
//  Daysy
//
//  Created by Alexander Eischeid on 5/1/24.
//

import SwiftUI

struct AllIconsPickerView: View {
    @State var currSheet: SheetObject = SheetObject()
    @State var currImage: String = "plus.viewfinder"
    var modifyIcon: (String) -> Void
    var modifyDetails: ([String]) -> Void
    var modifySheet: (SheetObject) -> Void
    var showCreateCustom: Bool = true
    var tutorialMode: Bool = false
    
    @State private var orientation = UIDeviceOrientation.unknown
    @State private var lastOrientation = UIDeviceOrientation.unknown
    @Environment(\.presentationMode) var presentation
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State var searchText = ""
    @State var isImagePickerPresented = false
    @State var selectedCustomImage = UIImage(systemName: "plus.viewfinder")
    @State var currCustomIconText = ""
    @State var customPECSAddresses = getCustomPECSAddresses()
    @State var isCustomTextFieldActive = false
    @State var customAnimate = false
    @State var oldEditingIcon = ""
    @State var editCustom = false
    @State var cameraPermission = false
    @State var showCamera = false
    @State var showImageMenu = false
    @State var showCustom = false
    
    var body: some View { //fullscreencover that has all the icons in it, used to set icons on a sheet
        
        var filteredCustomData: [String] { //search results for custom icons
            if tutorialMode {
                return []
            } else {
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
        
        ZStack { //main list of all the icons
            ScrollView {
                if horizontalSizeClass == .compact {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Text("\(Image(systemName: "square.grid.3x3")) All Icons")
                                .lineLimit(1)
                                .minimumScaleFactor(0.01)
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .padding(.bottom, 5)
                                .padding(.top)
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
                }
                TextField("\(Image(systemName: "magnifyingglass")) Search", text: $searchText)
                    .multilineTextAlignment(.center)
                    .font(.system(size: horizontalSizeClass == .compact ? 35 : 65, weight: .bold, design: .rounded))
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemGray4))
                    )
                    .padding([.leading, .trailing])
                    .padding(.top, horizontalSizeClass == .compact ? 0 : 10)
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: horizontalSizeClass == .compact ? 100 : 150))], spacing: horizontalSizeClass == .compact ? 0 : 20) {
                        ForEach(0..<filteredCustomData.count, id: \.self) { key in //first display custom icon results
                            Button(action: {
                                modifyIcon("customIconObject:\(filteredCustomData[key])")
                                modifyDetails([])
                                updateUsage("customIconObject:\(filteredCustomData[key])")
                                
                                self.presentation.wrappedValue.dismiss()
                                
                                //save array aka "autosave"
                                if !tutorialMode {
                                    var newSheetArray = loadSheetArray()
                                    newSheetArray[getCurrSheetIndex()] = currSheet
                                    currSheet = newSheetArray[getCurrSheetIndex()]
                                    saveSheetArray(sheetObjects: newSheetArray)
                                }
                                
                            }) {
                                getCustomIconSmall(filteredCustomData[key])
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(lineWidth: 3)
                                    )
                                    .scaledToFit()
                            }
                            .foregroundColor(.primary)
                            //                            .padding(horizontalSizeClass == .compact ? 3 : 10)
                            .overlay(
                                VStack {
                                    HStack {
                                        Menu {
                                            Button {
                                                oldEditingIcon = ""
                                                currCustomIconText = ""
                                                selectedCustomImage = UIImage(systemName: "square.fill")
                                                
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
                                                    
                                                    //then update custom pecs addresses and the current vgrid
                                                } label: {
                                                    Label("Delete", systemImage: "trash")
                                                }
                                            }
                                        } label: {
                                            Image(systemName: "ellipsis.circle.fill")
                                                .resizable()
                                                .frame(width: horizontalSizeClass == .compact ? 30 : 40, height: horizontalSizeClass == .compact ? 30 : 40)
                                                .foregroundColor(.blue)
                                        }
                                        Spacer()
                                    }
                                    Spacer()
                                }
                            )
                        }
                        ForEach(0..<filteredData.count, id: \.self) { pecsIcon in //next display default icon results
                            Button(action: {
                                modifyIcon(filteredData[pecsIcon])
                                modifyDetails([])
                                updateUsage(filteredData[pecsIcon])
                                self.presentation.wrappedValue.dismiss()
                                
                                //save array aka "autosave"
                                if !tutorialMode {
                                    var newSheetArray = loadSheetArray()
                                    newSheetArray[getCurrSheetIndex()] = currSheet
                                    currSheet = newSheetArray[getCurrSheetIndex()]
                                    saveSheetArray(sheetObjects: newSheetArray)
                                }
                                
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
                            //                            .padding(horizontalSizeClass == .compact ? 3 : 10)
                        }
                    }
                    .padding()
                
                if filteredData.count + filteredCustomData.count > 0 {
                    Divider()
                        .padding()
                        .padding(.bottom, 50)
                }
                if !tutorialMode {
                    Text("My Icons")
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: horizontalSizeClass == .compact ? 100 : 150))], spacing: horizontalSizeClass == .compact ? 0 : 20) {
                        if showCreateCustom {
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
                            .padding(.leading, horizontalSizeClass == .compact ? 5 : 0)
                            .padding(horizontalSizeClass == .compact ? 3 : 10)
                        }
                        ForEach(customPECSAddresses.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                            Button(action: {
                                modifyIcon("customIconObject:\(key)")
                                modifyDetails([])
                                updateUsage("customIconObject:\(key)")
                                
                                self.presentation.wrappedValue.dismiss()
                                
                                //save array aka "autosave"
                                if !tutorialMode {
                                    var newSheetArray = loadSheetArray()
                                    newSheetArray[getCurrSheetIndex()] = currSheet
                                    currSheet = newSheetArray[getCurrSheetIndex()]
                                    saveSheetArray(sheetObjects: newSheetArray)
                                }
                                
                            }) {
                                getCustomIconSmall(key)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(lineWidth: 3)
                                    )
                                    .scaledToFit()
                            }
                            .foregroundColor(.black)
                            //                            .padding()
                            .overlay(
                                VStack {
                                    HStack {
                                        Menu {
                                            Button {
                                                //hacky fix instead of binding, fixes not updating
                                                oldEditingIcon = ""
                                                currCustomIconText = ""
                                                selectedCustomImage = UIImage(systemName: "square.fill")
                                                
                                                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { timer in
                                                    oldEditingIcon = key
                                                    currCustomIconText = extractKey(from: key)
                                                    customAnimate.toggle()
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
                                                    
                                                    //then update custom pecs addresses and the current vgrid
                                                } label: {
                                                    Label("Delete", systemImage: "trash")
                                                }
                                            }
                                        } label: {
                                            Image(systemName: "ellipsis.circle.fill")
                                                .resizable()
                                                .frame(width: horizontalSizeClass == .compact ? 30 : 40, height: horizontalSizeClass == .compact ? 30 : 40)
                                                .foregroundColor(.blue)
                                        }
                                        Spacer()
                                    }
                                    Spacer()
                                }
                            )
                        }
                    }
                    .padding()
                }
                ForEach(pecsCategories, id: \.self) { icon in //grid of default icons, also displays categories
                    VStack(alignment: .center) {
                        Text(icon[0])
                            .lineLimit(1)
                            .minimumScaleFactor(0.01)
                            .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: horizontalSizeClass == .compact ? 100 : 150))], spacing: horizontalSizeClass == .compact ? 0 : 20) {
                            ForEach(1..<icon.count, id: \.self) { sheeticonobject in
                                Button(action: {
                                    modifyIcon(icon[sheeticonobject])
                                    modifyDetails([])
                                    updateUsage(icon[sheeticonobject])
                                    self.presentation.wrappedValue.dismiss()
                                    
                                    //save array aka "autosave"
                                    if !tutorialMode {
                                        var newSheetArray = loadSheetArray()
                                        newSheetArray[getCurrSheetIndex()] = currSheet
                                        currSheet = newSheetArray[getCurrSheetIndex()]
                                        saveSheetArray(sheetObjects: newSheetArray)
                                    }
                                    
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
                                //                                    .padding(horizontalSizeClass == .compact ? 3 : 10)
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
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    HStack { //bottom button row
                        if horizontalSizeClass != .compact {
                            Button(action: {
                                self.presentation.wrappedValue.dismiss()
                            }) {
                                Image(systemName: "xmark.square.fill")
                                    .resizable()
                                    .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                //.fontWeight(.bold)
                            }
                            .padding()
                            .foregroundColor(Color(.systemGray))
                        }
                        
                        if currImage != "plus.viewfinder" && !currImage.isEmpty{
                            Button(action: {
                                self.presentation.wrappedValue.dismiss()
                                modifyIcon("plus.viewfinder")
                                modifyDetails([])
                                
                                //save array aka "autosave"
                                if !tutorialMode {
                                    var newSheetArray = loadSheetArray()
                                    newSheetArray[getCurrSheetIndex()] = currSheet
                                    newSheetArray[getCurrSheetIndex()] = autoRemoveSlots(newSheetArray[getCurrSheetIndex()])
                                    currSheet = newSheetArray[getCurrSheetIndex()]
                                    saveSheetArray(sheetObjects: newSheetArray)
                                }
                                
                            }) {
                                ZStack {
                                    if currImage.contains("customIconObject:") {
                                        getCustomIconSmall(currImage)
                                            .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                            .opacity(0.25)
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(lineWidth: 3)
                                            )
                                    } else {
                                        loadImage(named: currImage)
                                            .resizable()
                                            .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                            .opacity(0.25)
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(lineWidth: 3)
                                            )
                                    }
                                    
                                    if #available(iOS 15.0, *) {
                                        Image(systemName: "trash.square.fill")
                                            .resizable()
                                            .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                            .symbolRenderingMode(.hierarchical)
                                    } else {
                                        Image(systemName: "trash.square.fill")
                                            .resizable()
                                            .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                    }
                                    //.fontWeight(.bold)
                                }
                            }
                            .padding()
                            .foregroundColor(.red)
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
        .ignoresSafeArea(.keyboard)
        .onRotate { newOrientation in
            orientation = newOrientation
            if !newOrientation.isFlat {
                lastOrientation = newOrientation
            }
        }
        .onAppear {
            var oldImage = currImage
            currImage = "square.fill"
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { timer in
                currImage = oldImage
            }
        }
        .fullScreenCover(isPresented: $showCustom) { //fullscreencover for creating a custom icon
            VStack {
                RoundedRectangle(cornerRadius: (lastOrientation.isLandscape && horizontalSizeClass != .compact) ? (isCustomTextFieldActive ? 25 : 50) : 50)
                    .stroke(Color.black, lineWidth: (lastOrientation.isLandscape && horizontalSizeClass != .compact) ? (isCustomTextFieldActive ? 12 : 25) : 25)
                    .background(
                        RoundedRectangle(cornerRadius: (lastOrientation.isLandscape && horizontalSizeClass != .compact) ? (isCustomTextFieldActive ? 25 : 50) : 50)
                            .fill(Color.white)
                    )
                    .aspectRatio((lastOrientation.isLandscape && horizontalSizeClass != .compact) ? (isCustomTextFieldActive ? 4 : 1) : 1, contentMode: .fill)
                //                        .clipShape(RoundedRectangle(cornerRadius: (lastOrientation.isLandscape && horizontalSizeClass != .compact) ? (isCustomTextFieldActive ? 25 : 50) : 50))
                    .overlay(
                        VStack {
                            Spacer()
                            if !isCustomTextFieldActive {
                                HStack(alignment: .bottom) {
                                    Button(action: {
                                        if selectedCustomImage != UIImage(systemName: "plus.viewfinder") {
                                            showImageMenu.toggle()
                                            customAnimate.toggle()
                                        } else {
                                            isImagePickerPresented.toggle()
                                        }
                                    }) {
                                        if selectedCustomImage == UIImage(systemName: "square.fill") {
                                            ZStack {
                                                Image(systemName: "square.fill")
                                                    .resizable()
                                                    .aspectRatio(1, contentMode: .fit)
                                                    .foregroundColor(.purple)
                                                    .opacity(0.25)
                                                    .padding()
                                                LoadingIndicator(size: .extraLarge)
                                            }
                                        } else {
                                            if selectedCustomImage == UIImage(systemName: "plus.viewfinder") {
                                                VStack {
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
                                                    Text("Camera Roll")
                                                        .font(.system(size: 30, weight: .semibold, design: .rounded))
                                                        .padding(.top)
                                                }
                                                
                                                Divider().padding()
                                                
                                                Button(action: {
                                                    if hasCameraPermission() {
                                                        showCamera.toggle()
                                                        defaults.set(true, forKey: "checkedCameraPermission")
                                                    } else {
                                                        if defaults.bool(forKey: "checkedCameraPermission") {
                                                            if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                                                                UIApplication.shared.open(appSettings)
                                                            }
                                                        }
                                                    }
                                                }) {
                                                    VStack {
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
                                                        Text("Take Picture")
                                                            .font(.system(size: 30, weight: .semibold, design: .rounded))
                                                            .padding(.top)
                                                    }
                                                }
                                                
                                                if defaults.bool(forKey: "aiOn") {
                                                    Divider().padding()
                                                    Button(action: {
                                                        if selectedCustomImage != UIImage(systemName: "square.fill") && !currCustomIconText.isEmpty {
                                                            selectedCustomImage = UIImage(systemName: "square.fill")
                                                            
                                                            Task {
                                                                //await askGPT(prompt: currCustomIconText)
                                                            }
                                                        }
                                                    }) {
                                                        VStack {
                                                            if #available(iOS 15.0, *) {
                                                                Image(systemName: "wand.and.stars")
                                                                    .resizable()
                                                                    .scaledToFit()
                                                                    .symbolRenderingMode(.hierarchical)
                                                                    .padding()
                                                            } else {
                                                                Image(systemName: "wand.and.stars")
                                                                    .resizable()
                                                                    .scaledToFit()
                                                                    .padding()
                                                            }
                                                            Text("Create Image")
                                                                .font(.system(size: 30, weight: .semibold, design: .rounded))
                                                                .padding(.top)
                                                        }
                                                    }
                                                    .foregroundColor(.purple)
                                                }
                                            } else {
                                                selectedCustomImage?.asImage
                                                    .resizable()
                                                    .aspectRatio(1, contentMode: .fit)
                                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                                    .padding()
                                                    .popover(isPresented: $showImageMenu) {
                                                        if horizontalSizeClass == .compact {
                                                            HStack {
                                                                Button(action: {
                                                                    isImagePickerPresented.toggle()
                                                                    showImageMenu.toggle()
                                                                    customAnimate.toggle()
                                                                }) {
                                                                    VStack {
                                                                        Image(systemName:"photo.on.rectangle")
                                                                            .resizable()
                                                                            .frame(width: horizontalSizeClass == .compact ? 125 : 62, height: horizontalSizeClass == .compact ? 100 : 50)
                                                                            .padding(horizontalSizeClass == .compact ? 5 : 15)
                                                                        
                                                                        Text("Camera Roll")
                                                                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                                                                    }
                                                                    .foregroundColor(.blue)
                                                                    .padding()
                                                                }
                                                                
                                                                Button(action: {
                                                                    if hasCameraPermission() {
                                                                        showCamera.toggle()
                                                                        showImageMenu.toggle()
                                                                        defaults.set(true, forKey: "checkedCameraPermission")
                                                                    } else {
                                                                        if defaults.bool(forKey: "checkedCameraPermission") {
                                                                            if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                                                                                UIApplication.shared.open(appSettings)
                                                                            }
                                                                        }
                                                                    }
                                                                }) {
                                                                    VStack {
                                                                        Image(systemName:"camera.on.rectangle")
                                                                            .resizable()
                                                                            .frame(width: horizontalSizeClass == .compact ? 125 : 62, height: horizontalSizeClass == .compact ? 100 : 50)
                                                                            .padding(horizontalSizeClass == .compact ? 5 : 15)
                                                                        
                                                                        
                                                                        Text("Take Picture")
                                                                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                                                                    }
                                                                    .foregroundColor(.blue)
                                                                    .padding()
                                                                }
                                                            }
                                                            HStack {
                                                                
                                                                if defaults.bool(forKey: "aiOn") {
                                                                    Button(action: {
                                                                        if selectedCustomImage != UIImage(systemName: "square.fill") && !currCustomIconText.isEmpty {
                                                                            selectedCustomImage = UIImage(systemName: "square.fill")
                                                                            
                                                                            Task {
                                                                                //await askGPT(prompt: currCustomIconText)
                                                                            }
                                                                        }
                                                                        showImageMenu = false
                                                                    }) {
                                                                        VStack {
                                                                            Image(systemName:"wand.and.stars")
                                                                                .resizable()
                                                                                .frame(width: horizontalSizeClass == .compact ? 100 : 50, height: horizontalSizeClass == .compact ? 100 : 50)
                                                                                .padding(horizontalSizeClass == .compact ? 5 : 15)
                                                                            
                                                                            Text("Create Image")
                                                                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                                                        }
                                                                        .foregroundColor(.purple)
                                                                        .padding()
                                                                    }
                                                                }
                                                                
                                                                Button(action: {
                                                                    showImageMenu.toggle()
                                                                    selectedCustomImage = UIImage(systemName: "plus.viewfinder")
                                                                    customAnimate.toggle()
                                                                }) {
                                                                    if selectedCustomImage != UIImage(systemName: "plus.viewfinder") {
                                                                        VStack {
                                                                            ZStack {
                                                                                selectedCustomImage?.asImage
                                                                                    .resizable()
                                                                                    .frame(width: horizontalSizeClass == .compact ? 100 : 50, height: horizontalSizeClass == .compact ? 100 : 50)
                                                                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                                                                    .opacity(0.25)
                                                                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                                                                    .overlay(
                                                                                        RoundedRectangle(cornerRadius: 8)
                                                                                            .stroke(lineWidth: 3)
                                                                                    )
                                                                                    .padding(horizontalSizeClass == .compact ? 5 : 15)
                                                                                    .foregroundColor(.red)
                                                                                if #available(iOS 15.0, *) {
                                                                                    Image(systemName: "trash.square.fill")
                                                                                        .resizable()
                                                                                        .frame(width: horizontalSizeClass == .compact ? 100 : 50, height: horizontalSizeClass == .compact ? 100 : 50)                                                                                    .padding()
                                                                                        .symbolRenderingMode(.hierarchical)
                                                                                    
                                                                                } else {
                                                                                    Image(systemName:"trash.square.fill")
                                                                                        .resizable()
                                                                                        .frame(width: horizontalSizeClass == .compact ? 100 : 50, height: horizontalSizeClass == .compact ? 100 : 50)                                                                                    .foregroundColor(.red)
                                                                                        .padding(horizontalSizeClass == .compact ? 5 : 15)
                                                                                    
                                                                                }
                                                                            }
                                                                            Text("Delete Image")
                                                                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                                                        }
                                                                        .foregroundColor(.red)
                                                                        .padding()
                                                                    } else {
                                                                        VStack {
                                                                            Image(systemName:"trash.square.fill")
                                                                                .resizable()
                                                                                .frame(width: horizontalSizeClass == .compact ? 100 : 50, height: horizontalSizeClass == .compact ? 100 : 50)
                                                                                .padding(horizontalSizeClass == .compact ? 5 : 15)
                                                                            
                                                                            Text("Delete Image")
                                                                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                                                        }
                                                                        .foregroundColor(.red)
                                                                        .padding()
                                                                    }
                                                                }
                                                            }
                                                        } else {
                                                            HStack {
                                                                Button(action: {
                                                                    isImagePickerPresented.toggle()
                                                                    showImageMenu.toggle()
                                                                    customAnimate.toggle()
                                                                }) {
                                                                    VStack {
                                                                        Image(systemName:"photo.on.rectangle")
                                                                            .resizable()
                                                                            .frame(width: horizontalSizeClass == .compact ? 125 : 62, height: horizontalSizeClass == .compact ? 100 : 50)
                                                                            .padding(horizontalSizeClass == .compact ? 5 : 15)
                                                                        
                                                                        Text("Camera Roll")
                                                                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                                                                    }
                                                                    .foregroundColor(.blue)
                                                                    .padding()
                                                                }
                                                                
                                                                Button(action: {
                                                                    if hasCameraPermission() {
                                                                        showCamera.toggle()
                                                                        showImageMenu.toggle()
                                                                        defaults.set(true, forKey: "checkedCameraPermission")
                                                                    } else {
                                                                        if defaults.bool(forKey: "checkedCameraPermission") {
                                                                            if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                                                                                UIApplication.shared.open(appSettings)
                                                                            }
                                                                        }
                                                                    }
                                                                }) {
                                                                    VStack {
                                                                        Image(systemName:"camera.on.rectangle")
                                                                            .resizable()
                                                                            .frame(width: horizontalSizeClass == .compact ? 125 : 62, height: horizontalSizeClass == .compact ? 100 : 50)
                                                                            .padding(horizontalSizeClass == .compact ? 5 : 15)
                                                                        
                                                                        
                                                                        Text("Take Picture")
                                                                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                                                                    }
                                                                    .foregroundColor(.blue)
                                                                    .padding()
                                                                }
                                                                
                                                                if defaults.bool(forKey: "aiOn") {
                                                                    Button(action: {
                                                                        if selectedCustomImage != UIImage(systemName: "square.fill") && !currCustomIconText.isEmpty {
                                                                            selectedCustomImage = UIImage(systemName: "square.fill")
                                                                            
                                                                            Task {
                                                                                //await askGPT(prompt: currCustomIconText)
                                                                            }
                                                                        }
                                                                        showImageMenu = false
                                                                    }) {
                                                                        VStack {
                                                                            Image(systemName:"wand.and.stars")
                                                                                .resizable()
                                                                                .frame(width: horizontalSizeClass == .compact ? 100 : 50, height: horizontalSizeClass == .compact ? 100 : 50)
                                                                                .padding(horizontalSizeClass == .compact ? 5 : 15)
                                                                            
                                                                            Text("Create Image")
                                                                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                                                        }
                                                                        .foregroundColor(.purple)
                                                                        .padding()
                                                                    }
                                                                }
                                                                
                                                                Button(action: {
                                                                    showImageMenu.toggle()
                                                                    selectedCustomImage = UIImage(systemName: "plus.viewfinder")
                                                                    customAnimate.toggle()
                                                                }) {
                                                                    if selectedCustomImage != UIImage(systemName: "plus.viewfinder") {
                                                                        VStack {
                                                                            ZStack {
                                                                                selectedCustomImage?.asImage
                                                                                    .resizable()
                                                                                    .frame(width: horizontalSizeClass == .compact ? 100 : 50, height: horizontalSizeClass == .compact ? 100 : 50)
                                                                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                                                                    .opacity(0.25)
                                                                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                                                                    .overlay(
                                                                                        RoundedRectangle(cornerRadius: 8)
                                                                                            .stroke(lineWidth: 3)
                                                                                    )
                                                                                    .padding(horizontalSizeClass == .compact ? 5 : 15)
                                                                                    .foregroundColor(.red)
                                                                                if #available(iOS 15.0, *) {
                                                                                    Image(systemName: "trash.square.fill")
                                                                                        .resizable()
                                                                                        .frame(width: horizontalSizeClass == .compact ? 100 : 50, height: horizontalSizeClass == .compact ? 100 : 50)                                                                                    .padding()
                                                                                        .symbolRenderingMode(.hierarchical)
                                                                                    
                                                                                } else {
                                                                                    Image(systemName:"trash.square.fill")
                                                                                        .resizable()
                                                                                        .frame(width: horizontalSizeClass == .compact ? 100 : 50, height: horizontalSizeClass == .compact ? 100 : 50)                                                                                    .foregroundColor(.red)
                                                                                        .padding(horizontalSizeClass == .compact ? 5 : 15)
                                                                                    
                                                                                }
                                                                            }
                                                                            Text("Delete Image")
                                                                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                                                        }
                                                                        .foregroundColor(.red)
                                                                        .padding()
                                                                    } else {
                                                                        VStack {
                                                                            Image(systemName:"trash.square.fill")
                                                                                .resizable()
                                                                                .frame(width: horizontalSizeClass == .compact ? 100 : 50, height: horizontalSizeClass == .compact ? 100 : 50)
                                                                                .padding(horizontalSizeClass == .compact ? 5 : 15)
                                                                            
                                                                            Text("Delete Image")
                                                                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                                                        }
                                                                        .foregroundColor(.red)
                                                                        .padding()
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
                            ZStack { //zstack with gray is to workaround low contrast on dark mode despite white background
                                Text("Label")
                                    .minimumScaleFactor(0.1)
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: horizontalSizeClass == .compact ? ((lastOrientation.isLandscape && horizontalSizeClass != .compact) ? 30 : 50) : ((lastOrientation.isLandscape && horizontalSizeClass != .compact) ? 75 : 135), weight: .semibold,  design: .rounded))
                                    .foregroundColor(currCustomIconText.isEmpty ? Color(.systemGray) : .clear)
                                    .padding()
                                //SuperTextField(placeholder: Text("Label"), text: $currCustomIconText, editingChanged: { editing in
                                TextField("Label", text: $currCustomIconText, onEditingChanged: { editing in
                                    isCustomTextFieldActive = editing
                                    customAnimate.toggle()
                                }, onCommit: {
                                    customAnimate.toggle()
                                    showImageMenu = false
                                })
                                .minimumScaleFactor(0.1)
                                .multilineTextAlignment(.center)
                                .font(.system(size: horizontalSizeClass == .compact ? ((lastOrientation.isLandscape && horizontalSizeClass != .compact) ? 30 : 50) : ((lastOrientation.isLandscape && horizontalSizeClass != .compact) ? 75 : 135), weight: .semibold,  design: .rounded))
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
                    if selectedCustomImage != UIImage(systemName: "square.fill") {
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
                                if selectedCustomImage != UIImage(systemName: "square.fill") {
                                    Image(systemName:"checkmark.square.fill")
                                        .resizable()
                                        .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                        .foregroundColor(.green)
                                        .padding()
                                }
                            }
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
                RoundedRectangle(cornerRadius: (lastOrientation.isLandscape && horizontalSizeClass != .compact) ? (isCustomTextFieldActive ? 25 : 50) : 50)
                    .stroke(Color.black, lineWidth: (lastOrientation.isLandscape && horizontalSizeClass != .compact) ? (isCustomTextFieldActive ? 12 : 25) : 25)
                    .background(
                        RoundedRectangle(cornerRadius: (lastOrientation.isLandscape && horizontalSizeClass != .compact) ? (isCustomTextFieldActive ? 25 : 50) : 50)
                            .fill(Color.white)
                    )
                    .aspectRatio((lastOrientation.isLandscape && horizontalSizeClass != .compact) ? (isCustomTextFieldActive ? 4 : 1) : 1, contentMode: .fill)
                //                        .clipShape(RoundedRectangle(cornerRadius: (lastOrientation.isLandscape && horizontalSizeClass != .compact) ? (isCustomTextFieldActive ? 25 : 50) : 50))
                    .overlay(
                        VStack {
                            Spacer()
                            //new stuff start here
                            if !isCustomTextFieldActive {
                                HStack(alignment: .bottom) {
                                    Button(action: {
                                        if selectedCustomImage != UIImage(systemName: "plus.viewfinder") {
                                            showImageMenu.toggle()
                                            customAnimate.toggle()
                                        } else {
                                            isImagePickerPresented.toggle()
                                        }
                                    }) {
                                        if selectedCustomImage == UIImage(systemName: "square.fill") {
                                            ZStack {
                                                Image(systemName: "square.fill")
                                                    .resizable()
                                                    .aspectRatio(1, contentMode: .fit)
                                                    .foregroundColor(.purple)
                                                    .opacity(0.25)
                                                    .padding()
                                                LoadingIndicator(size: .extraLarge)
                                                    .scaledToFit()
                                            }
                                        } else {
                                            if selectedCustomImage == UIImage(systemName: "plus.viewfinder") {
                                                VStack {
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
                                                    Text("Camera Roll")
                                                        .font(.system(size: 30, weight: .semibold, design: .rounded))
                                                        .padding(.top)
                                                }
                                                
                                                Divider().padding()
                                                
                                                Button(action: {
                                                    if hasCameraPermission() {
                                                        showCamera.toggle()
                                                        defaults.set(true, forKey: "checkedCameraPermission")
                                                    } else {
                                                        if defaults.bool(forKey: "checkedCameraPermission") {
                                                            if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                                                                UIApplication.shared.open(appSettings)
                                                            }
                                                        }
                                                    }
                                                }) {
                                                    VStack {
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
                                                        Text("Take Picture")
                                                            .font(.system(size: 30, weight: .semibold, design: .rounded))
                                                            .padding(.top)
                                                    }
                                                }
                                                
                                                if defaults.bool(forKey: "aiOn") {
                                                    Divider().padding()
                                                    Button(action: {
                                                        if selectedCustomImage != UIImage(systemName: "square.fill") && !currCustomIconText.isEmpty {
                                                            selectedCustomImage = UIImage(systemName: "square.fill")
                                                            
                                                            Task {
                                                                //await askGPT(prompt: currCustomIconText)
                                                            }
                                                        }
                                                    }) {
                                                        VStack {
                                                            if #available(iOS 15.0, *) {
                                                                Image(systemName: "wand.and.stars")
                                                                    .resizable()
                                                                    .scaledToFit()
                                                                    .symbolRenderingMode(.hierarchical)
                                                                    .padding()
                                                            } else {
                                                                Image(systemName: "wand.and.stars")
                                                                    .resizable()
                                                                    .scaledToFit()
                                                                    .padding()
                                                            }
                                                            Text("Create Image")
                                                                .font(.system(size: 30, weight: .semibold, design: .rounded))
                                                                .padding(.top)
                                                        }
                                                    }
                                                    .foregroundColor(.purple)
                                                }
                                            } else {
                                                selectedCustomImage?.asImage
                                                    .resizable()
                                                    .aspectRatio(1, contentMode: .fit)
                                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                                    .padding()
                                                    .popover(isPresented: $showImageMenu) {
                                                        if horizontalSizeClass == .compact {
                                                            HStack {
                                                                Button(action: {
                                                                    isImagePickerPresented.toggle()
                                                                    showImageMenu.toggle()
                                                                    customAnimate.toggle()
                                                                }) {
                                                                    VStack {
                                                                        Image(systemName:"photo.on.rectangle")
                                                                            .resizable()
                                                                            .frame(width: horizontalSizeClass == .compact ? 125 : 62, height: horizontalSizeClass == .compact ? 100 : 50)
                                                                            .padding(horizontalSizeClass == .compact ? 5 : 15)
                                                                        
                                                                        Text("Camera Roll")
                                                                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                                                                    }
                                                                    .foregroundColor(.blue)
                                                                    .padding()
                                                                }
                                                                
                                                                Button(action: {
                                                                    if hasCameraPermission() {
                                                                        showCamera.toggle()
                                                                        showImageMenu.toggle()
                                                                        defaults.set(true, forKey: "checkedCameraPermission")
                                                                    } else {
                                                                        if defaults.bool(forKey: "checkedCameraPermission") {
                                                                            if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                                                                                UIApplication.shared.open(appSettings)
                                                                            }
                                                                        }
                                                                    }
                                                                }) {
                                                                    VStack {
                                                                        Image(systemName:"camera.on.rectangle")
                                                                            .resizable()
                                                                            .frame(width: horizontalSizeClass == .compact ? 125 : 62, height: horizontalSizeClass == .compact ? 100 : 50)
                                                                            .padding(horizontalSizeClass == .compact ? 5 : 15)
                                                                        
                                                                        
                                                                        Text("Take Picture")
                                                                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                                                                    }
                                                                    .foregroundColor(.blue)
                                                                    .padding()
                                                                }
                                                            }
                                                            HStack {
                                                                
                                                                if defaults.bool(forKey: "aiOn") {
                                                                    Button(action: {
                                                                        if selectedCustomImage != UIImage(systemName: "square.fill") && !currCustomIconText.isEmpty {
                                                                            selectedCustomImage = UIImage(systemName: "square.fill")
                                                                            
                                                                            Task {
                                                                                //await askGPT(prompt: currCustomIconText)
                                                                            }
                                                                        }
                                                                        showImageMenu = false
                                                                    }) {
                                                                        VStack {
                                                                            Image(systemName:"wand.and.stars")
                                                                                .resizable()
                                                                                .frame(width: horizontalSizeClass == .compact ? 100 : 50, height: horizontalSizeClass == .compact ? 100 : 50)
                                                                                .padding(horizontalSizeClass == .compact ? 5 : 15)
                                                                            
                                                                            Text("Create Image")
                                                                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                                                        }
                                                                        .foregroundColor(.purple)
                                                                        .padding()
                                                                    }
                                                                }
                                                                Button(action: {
                                                                    showImageMenu.toggle()
                                                                    selectedCustomImage = UIImage(systemName: "plus.viewfinder")
                                                                    customAnimate.toggle()
                                                                }) {
                                                                    if selectedCustomImage != UIImage(systemName: "plus.viewfinder") {
                                                                        VStack {
                                                                            ZStack {
                                                                                selectedCustomImage?.asImage
                                                                                    .resizable()
                                                                                    .frame(width: horizontalSizeClass == .compact ? 100 : 50, height: horizontalSizeClass == .compact ? 100 : 50)
                                                                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                                                                    .opacity(0.25)
                                                                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                                                                    .overlay(
                                                                                        RoundedRectangle(cornerRadius: 8)
                                                                                            .stroke(lineWidth: 3)
                                                                                    )
                                                                                    .padding(horizontalSizeClass == .compact ? 5 : 15)
                                                                                    .foregroundColor(.red)
                                                                                if #available(iOS 15.0, *) {
                                                                                    Image(systemName: "trash.square.fill")
                                                                                        .resizable()
                                                                                        .frame(width: horizontalSizeClass == .compact ? 100 : 50, height: horizontalSizeClass == .compact ? 100 : 50)                                                                                    .padding()
                                                                                        .symbolRenderingMode(.hierarchical)
                                                                                    
                                                                                } else {
                                                                                    Image(systemName:"trash.square.fill")
                                                                                        .resizable()
                                                                                        .frame(width: horizontalSizeClass == .compact ? 100 : 50, height: horizontalSizeClass == .compact ? 100 : 50)                                                                                    .foregroundColor(.red)
                                                                                        .padding(horizontalSizeClass == .compact ? 5 : 15)
                                                                                    
                                                                                }
                                                                            }
                                                                            Text("Delete Image")
                                                                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                                                        }
                                                                        .foregroundColor(.red)
                                                                        .padding()
                                                                    } else {
                                                                        VStack {
                                                                            Image(systemName:"trash.square.fill")
                                                                                .resizable()
                                                                                .frame(width: horizontalSizeClass == .compact ? 100 : 50, height: horizontalSizeClass == .compact ? 100 : 50)
                                                                                .padding(horizontalSizeClass == .compact ? 5 : 15)
                                                                            
                                                                            Text("Delete Image")
                                                                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                                                        }
                                                                        .foregroundColor(.red)
                                                                        .padding()
                                                                    }
                                                                }
                                                            }
                                                        } else {
                                                            HStack {
                                                                Button(action: {
                                                                    isImagePickerPresented.toggle()
                                                                    showImageMenu.toggle()
                                                                    customAnimate.toggle()
                                                                }) {
                                                                    VStack {
                                                                        Image(systemName:"photo.on.rectangle")
                                                                            .resizable()
                                                                            .frame(width: horizontalSizeClass == .compact ? 125 : 62, height: horizontalSizeClass == .compact ? 100 : 50)
                                                                            .padding(horizontalSizeClass == .compact ? 5 : 15)
                                                                        
                                                                        Text("Camera Roll")
                                                                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                                                                    }
                                                                    .foregroundColor(.blue)
                                                                    .padding()
                                                                }
                                                                
                                                                Button(action: {
                                                                    if hasCameraPermission() {
                                                                        showCamera.toggle()
                                                                        showImageMenu.toggle()
                                                                        defaults.set(true, forKey: "checkedCameraPermission")
                                                                    } else {
                                                                        if defaults.bool(forKey: "checkedCameraPermission") {
                                                                            if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                                                                                UIApplication.shared.open(appSettings)
                                                                            }
                                                                        }
                                                                    }
                                                                }) {
                                                                    VStack {
                                                                        Image(systemName:"camera.on.rectangle")
                                                                            .resizable()
                                                                            .frame(width: horizontalSizeClass == .compact ? 125 : 62, height: horizontalSizeClass == .compact ? 100 : 50)
                                                                            .padding(horizontalSizeClass == .compact ? 5 : 15)
                                                                        
                                                                        
                                                                        Text("Take Picture")
                                                                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                                                                    }
                                                                    .foregroundColor(.blue)
                                                                    .padding()
                                                                }
                                                                
                                                                if defaults.bool(forKey: "aiOn") {
                                                                    Button(action: {
                                                                        if selectedCustomImage != UIImage(systemName: "square.fill") && !currCustomIconText.isEmpty {
                                                                            selectedCustomImage = UIImage(systemName: "square.fill")
                                                                            
                                                                            Task {
                                                                                //await askGPT(prompt: currCustomIconText)
                                                                            }
                                                                        }
                                                                        showImageMenu = false
                                                                    }) {
                                                                        VStack {
                                                                            Image(systemName:"wand.and.stars")
                                                                                .resizable()
                                                                                .frame(width: horizontalSizeClass == .compact ? 100 : 50, height: horizontalSizeClass == .compact ? 100 : 50)
                                                                                .padding(horizontalSizeClass == .compact ? 5 : 15)
                                                                            
                                                                            Text("Create Image")
                                                                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                                                        }
                                                                        .foregroundColor(.purple)
                                                                        .padding()
                                                                    }
                                                                }
                                                                Button(action: {
                                                                    showImageMenu.toggle()
                                                                    selectedCustomImage = UIImage(systemName: "plus.viewfinder")
                                                                    customAnimate.toggle()
                                                                }) {
                                                                    if selectedCustomImage != UIImage(systemName: "plus.viewfinder") {
                                                                        VStack {
                                                                            ZStack {
                                                                                selectedCustomImage?.asImage
                                                                                    .resizable()
                                                                                    .frame(width: horizontalSizeClass == .compact ? 100 : 50, height: horizontalSizeClass == .compact ? 100 : 50)
                                                                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                                                                    .opacity(0.25)
                                                                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                                                                    .overlay(
                                                                                        RoundedRectangle(cornerRadius: 8)
                                                                                            .stroke(lineWidth: 3)
                                                                                    )
                                                                                    .padding(horizontalSizeClass == .compact ? 5 : 15)
                                                                                    .foregroundColor(.red)
                                                                                if #available(iOS 15.0, *) {
                                                                                    Image(systemName: "trash.square.fill")
                                                                                        .resizable()
                                                                                        .frame(width: horizontalSizeClass == .compact ? 100 : 50, height: horizontalSizeClass == .compact ? 100 : 50)                                                                                    .padding()
                                                                                        .symbolRenderingMode(.hierarchical)
                                                                                    
                                                                                } else {
                                                                                    Image(systemName:"trash.square.fill")
                                                                                        .resizable()
                                                                                        .frame(width: horizontalSizeClass == .compact ? 100 : 50, height: horizontalSizeClass == .compact ? 100 : 50)                                                                                    .foregroundColor(.red)
                                                                                        .padding(horizontalSizeClass == .compact ? 5 : 15)
                                                                                    
                                                                                }
                                                                            }
                                                                            Text("Delete Image")
                                                                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                                                        }
                                                                        .foregroundColor(.red)
                                                                        .padding()
                                                                    } else {
                                                                        VStack {
                                                                            Image(systemName:"trash.square.fill")
                                                                                .resizable()
                                                                                .frame(width: horizontalSizeClass == .compact ? 100 : 50, height: horizontalSizeClass == .compact ? 100 : 50)
                                                                                .padding(horizontalSizeClass == .compact ? 5 : 15)
                                                                            
                                                                            Text("Delete Image")
                                                                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                                                        }
                                                                        .foregroundColor(.red)
                                                                        .padding()
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
                            ZStack { //zstack with gray is to workaround low contrast on dark mode despite white background
                                Text("Label")
                                    .minimumScaleFactor(0.1)
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: horizontalSizeClass == .compact ? ((lastOrientation.isLandscape && horizontalSizeClass != .compact) ? 30 : 50) : ((lastOrientation.isLandscape && horizontalSizeClass != .compact) ? 75 : 135), weight: .semibold,  design: .rounded))
                                    .foregroundColor(currCustomIconText.isEmpty ? Color(.systemGray) : .clear)
                                    .padding()
                                //SuperTextField(placeholder: Text("Label"), text: $currCustomIconText, editingChanged: { editing in
                                TextField("Label", text: $currCustomIconText, onEditingChanged: { editing in
                                    isCustomTextFieldActive = editing
                                    customAnimate.toggle()
                                }, onCommit: {
                                    customAnimate.toggle()
                                    showImageMenu = false
                                })
                                .minimumScaleFactor(0.1)
                                .multilineTextAlignment(.center)
                                .font(.system(size: horizontalSizeClass == .compact ? ((lastOrientation.isLandscape && horizontalSizeClass != .compact) ? 30 : 50) : ((lastOrientation.isLandscape && horizontalSizeClass != .compact) ? 75 : 135), weight: .semibold,  design: .rounded))
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
                    if selectedCustomImage != UIImage(systemName: "square.fill") {
                        Button(action: { //perform checks for no image, no label, or no either and possibly save the icon
                            //update and save completed icon
                            //check to see if image and label are both blank, if so either delete or dont save?
                            //possible change the nesting of the code so that it performs all the check to do nothing first before proceeding to others
                            
                            if selectedCustomImage == UIImage(systemName: "plus.viewfinder") && currCustomIconText.isEmpty {
                                
                                let newSheetArray = deleteCustomIcons(currIcon: oldEditingIcon)
                                currSheet = newSheetArray[getCurrSheetIndex()]
                                saveSheetArray(sheetObjects: newSheetArray)
                                customPECSAddresses = getCustomPECSAddresses()
                                
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
                                        modifySheet(currSheet)
                                        
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
                }
                .ignoresSafeArea(.keyboard)
            }
            .animation(.spring, value: customAnimate)
            .sheet(isPresented: $isImagePickerPresented) {
                UIImagePicker(selectedImage: $selectedCustomImage)
            }
            .fullScreenCover(isPresented: $showCamera, content: {
                CameraPickerView(selectedImage: $selectedCustomImage)
            })
        }
    }
}


struct AllIconsPickerView_Previews: PreviewProvider {
    static var previews: some View {
        AllIconsPickerView(modifyIcon: { _ in },
                           modifyDetails: { _ in },
                           modifySheet: { _ in })
    }
}
