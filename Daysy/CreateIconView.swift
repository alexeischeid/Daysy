//
//  CreateIconView.swift
//  Daysy
//
//  Created by Alexander Eischeid on 5/31/24.
//

import SwiftUI
import OpenAI
import Pow

struct CreateIconView: View {

    var modifyCustomIcon: () -> Void
    
    @State private var orientation = UIDeviceOrientation.unknown
    @State private var lastOrientation = UIDeviceOrientation.unknown
    @Environment(\.presentationMode) var presentation
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @AppStorage("checkedCameraPermission") private var checkedCameraPermission: Bool = false
    @AppStorage("aiOn") private var aiOn: Bool = false
    
    @Binding var selectedCustomImage: UIImage?
    @Binding var currCustomIconText: String
    @Binding var oldEditingIcon: String
    @Binding var editCustom: Bool
    
    @State var isImagePickerPresented = false
    @State var isDocumentPickerPresented = false
    @State var showCamera = false
    @State var customPECSAddresses = getCustomPECSAddresses()
    @State var isCustomTextFieldActive = false
    @State var customAnimate = false
    @State var cameraPermission = false
    @State var showImageMenu = false
    @State var isLoading = false
    
    @State var currCommunicationBoard = loadCommunicationBoard()
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: (lastOrientation.isLandscape && horizontalSizeClass != .compact) ? (isCustomTextFieldActive ? 25 : 50) : 50)
                .stroke(Color.black, lineWidth: (lastOrientation.isLandscape && horizontalSizeClass != .compact) ? (isCustomTextFieldActive ? 5 : 25) : 25)
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
                        if !isCustomTextFieldActive || horizontalSizeClass == .compact || lastOrientation.isPortrait {
                            if selectedCustomImage == nil {
                                VStack {
                                    HStack {
                                        Button(action: {
                                            isImagePickerPresented.toggle()
                                            isLoading.toggle()
                                        }) {
                                            Image(systemName: "photo.on.rectangle")
                                                .resizable()
                                                .scaledToFit()
                                                .symbolRenderingMode(.hierarchical)
                                                .padding()
                                        }
                                        
                                        Button(action: {
                                            if hasCameraPermission() {
                                                showCamera.toggle()
                                                checkedCameraPermission = true
                                            } else {
                                                if checkedCameraPermission {
                                                    if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                                                        UIApplication.shared.open(appSettings)
                                                    }
                                                }
                                            }
                                        }) {
                                            Image(systemName: "camera.on.rectangle")
                                                .resizable()
                                                .scaledToFit()
                                                .symbolRenderingMode(.hierarchical)
                                                .padding()
                                        }
                                    }
                                    HStack {
                                        if aiOn  && isConnectedToInternet(){
                                            Button(action: {
                                                withAnimation(.spring) {
                                                    selectedCustomImage = UIImage(systemName: "square.fill")
                                                    isLoading.toggle()
                                                }
                                                Task {
                                                    selectedCustomImage = await fetchCustomImage(queryText: currCustomIconText.isEmpty ? "a random, happy, realistic illustration" : currCustomIconText)
                                                    isLoading.toggle()
                                                    customAnimate.toggle()
                                                }
                                            }) {
                                                Image(systemName: "wand.and.stars")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .symbolRenderingMode(.hierarchical)
                                                    .padding()
                                            }
                                            .foregroundStyle(.purple)
                                        }
                                        Button(action: {
                                            isDocumentPickerPresented.toggle()
                                            isLoading.toggle()
                                        }) {
                                            Image(systemName: "doc.on.doc")
                                                .resizable()
                                                .scaledToFit()
                                                .symbolRenderingMode(.hierarchical)
                                                .padding()
                                        }
                                    }
                                }
                            } else {
                                Button(action: {
                                    if !isLoading {
                                        showImageMenu.toggle()
                                    }
                                }) {
                                    if isLoading {
                                        ZStack {
                                            Image(systemName: "square.fill")
                                                .resizable()
                                                .aspectRatio(1, contentMode: .fit)
                                                .foregroundStyle(.purple)
                                                .opacity(0.25)
                                                .padding()
                                            LoadingIndicator(color: .white, size: .extraLarge)
                                        }
                                    } else {
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.clear)
                                            .background (
                                                selectedCustomImage?.asImage
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                            )
                                            .transition(.movingParts.filmExposure)
                                            .aspectRatio(1, contentMode: .fit)
                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                            .padding()
                                            .popover(isPresented: $showImageMenu) {
                                                if horizontalSizeClass == .compact {
                                                    HStack {
                                                        Button(action: {
                                                            isImagePickerPresented.toggle()
                                                            showImageMenu.toggle()
                                                        }) {
                                                            VStack {
                                                                Image(systemName:"photo.on.rectangle")
                                                                    .resizable()
                                                                    .frame(width: horizontalSizeClass == .compact ? 125 : 62, height: horizontalSizeClass == .compact ? 100 : 50)
                                                                    .padding(horizontalSizeClass == .compact ? 5 : 15)
                                                                    .symbolRenderingMode(.hierarchical)
                                                                
                                                                Text("Camera Roll")
                                                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                                            }
                                                            .foregroundStyle(.blue)
                                                            .padding()
                                                        }
                                                        
                                                        Button(action: {
                                                            if hasCameraPermission() {
                                                                showCamera.toggle()
                                                                showImageMenu.toggle()
                                                                checkedCameraPermission = true
                                                            } else {
                                                                if checkedCameraPermission {
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
                                                                    .symbolRenderingMode(.hierarchical)
                                                                
                                                                
                                                                Text("Take Picture")
                                                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                                            }
                                                            .foregroundStyle(.blue)
                                                            .padding()
                                                        }
                                                    }
                                                    HStack {
                                                        
                                                        if aiOn  && isConnectedToInternet() {
                                                            Button(action: {
                                                                withAnimation(.spring) {
                                                                    isLoading.toggle()
                                                                }
                                                                
                                                                Task {
                                                                    selectedCustomImage = await fetchCustomImage(queryText: currCustomIconText.isEmpty ? "a random, happy, realistic illustration" : currCustomIconText)
                                                                    isLoading.toggle()
                                                                    customAnimate.toggle()
                                                                }
                                                                showImageMenu.toggle()
                                                            }) {
                                                                VStack {
                                                                    Image(systemName:"wand.and.stars")
                                                                        .resizable()
                                                                        .frame(width: horizontalSizeClass == .compact ? 100 : 50, height: horizontalSizeClass == .compact ? 100 : 50)
                                                                        .padding(horizontalSizeClass == .compact ? 5 : 15)
                                                                        .symbolRenderingMode(.hierarchical)
                                                                    
                                                                    Text(currCustomIconText.isEmpty ? "Random Image" : "Create Image")
                                                                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                                                                }
                                                                .foregroundStyle(.purple)
                                                                .padding()
                                                            }
                                                        }
                                                        
                                                        if !isConnectedToInternet() {
                                                            Button(action: {
                                                                showImageMenu.toggle()
                                                                withAnimation(.spring) {
                                                                    selectedCustomImage = nil
                                                                }
                                                            }) {
                                                                if selectedCustomImage != nil {
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
                                                                                .foregroundStyle(.red)
                                                                            Image(systemName: "trash.square.fill")
                                                                                .resizable()
                                                                                .frame(width: horizontalSizeClass == .compact ? 100 : 50, height: horizontalSizeClass == .compact ? 100 : 50)
                                                                                .padding()
                                                                                .symbolRenderingMode(.hierarchical)
                                                                            
                                                                        }
                                                                        Text("Delete Image")
                                                                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                                                                    }
                                                                    .foregroundStyle(.red)
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
                                                                    .foregroundStyle(.red)
                                                                    .padding()
                                                                }
                                                            }
                                                        } else {
                                                            Button(action: {
                                                                isDocumentPickerPresented.toggle()
                                                                showImageMenu.toggle()
                                                            }) {
                                                                VStack {
                                                                    Image(systemName:"doc.on.doc")
                                                                        .resizable()
                                                                        .frame(width: horizontalSizeClass == .compact ? 100 : 50, height: horizontalSizeClass == .compact ? 125 : 62)
                                                                        .padding(horizontalSizeClass == .compact ? 5 : 15)
                                                                        .symbolRenderingMode(.hierarchical)
                                                                    
                                                                    Text("Documents")
                                                                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                                                                }
                                                                .foregroundStyle(.blue)
                                                                .padding()
                                                            }
                                                        }
                                                    }
                                                    
                                                    if isConnectedToInternet() {
                                                        HStack {
                                                            Spacer()
                                                            Button(action: {
                                                                showImageMenu.toggle()
                                                                selectedCustomImage = nil
                                                                customAnimate.toggle()
                                                            }) {
                                                                if selectedCustomImage != nil {
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
                                                                                .foregroundStyle(.red)
                                                                            Image(systemName: "trash.square.fill")
                                                                                .resizable()
                                                                                .frame(width: horizontalSizeClass == .compact ? 100 : 50, height: horizontalSizeClass == .compact ? 100 : 50)
                                                                                .padding()
                                                                                .symbolRenderingMode(.hierarchical)
                                                                            
                                                                        }
                                                                        Text("Delete Image")
                                                                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                                                                    }
                                                                    .foregroundStyle(.red)
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
                                                                    .foregroundStyle(.red)
                                                                    .padding()
                                                                }
                                                            }
                                                            Spacer()
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
                                                                    .symbolRenderingMode(.hierarchical)
                                                                
                                                                Text("Camera Roll")
                                                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                                            }
                                                            .foregroundStyle(.blue)
                                                            .padding()
                                                        }
                                                        
                                                        Button(action: {
                                                            if hasCameraPermission() {
                                                                showCamera.toggle()
                                                                showImageMenu.toggle()
                                                                checkedCameraPermission = true
                                                            } else {
                                                                if checkedCameraPermission {
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
                                                                    .symbolRenderingMode(.hierarchical)
                                                                
                                                                
                                                                Text("Take Picture")
                                                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                                            }
                                                            .foregroundStyle(.blue)
                                                            .padding()
                                                        }
                                                        
                                                        if aiOn  && isConnectedToInternet() {
                                                            Button(action: {
                                                                if !isLoading {
                                                                    withAnimation(.spring) {
                                                                        isLoading.toggle()
                                                                    }
                                                                    Task {
                                                                        selectedCustomImage = await fetchCustomImage(queryText: currCustomIconText.isEmpty ? "a random, happy, realistic illustration" : currCustomIconText)
                                                                        isLoading.toggle()
                                                                        customAnimate.toggle()
                                                                    }
                                                                }
                                                                showImageMenu = false
                                                            }) {
                                                                VStack {
                                                                    Image(systemName:"wand.and.stars")
                                                                        .resizable()
                                                                        .frame(width: horizontalSizeClass == .compact ? 100 : 50, height: horizontalSizeClass == .compact ? 100 : 50)
                                                                        .padding(horizontalSizeClass == .compact ? 5 : 15)
                                                                        .symbolRenderingMode(.hierarchical)
                                                                    
                                                                    Text(currCustomIconText.isEmpty ? "Random Image" : "Create Image")
                                                                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                                                                }
                                                                .foregroundStyle(.purple)
                                                                .padding()
                                                            }
                                                        }
                                                        
                                                        Button(action: {
                                                            isDocumentPickerPresented.toggle()
                                                            isImagePickerPresented.toggle()
                                                            customAnimate.toggle()
                                                        }) {
                                                            VStack {
                                                                Image(systemName:"doc.on.doc")
                                                                    .resizable()
                                                                    .frame(width: horizontalSizeClass == .compact ? 100 : 50, height: horizontalSizeClass == .compact ? 125 : 62)
                                                                    .padding(horizontalSizeClass == .compact ? 5 : 15)
                                                                    .symbolRenderingMode(.hierarchical)
                                                                
                                                                Text("Documents")
                                                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                                            }
                                                            .foregroundStyle(.blue)
                                                            .padding()
                                                        }
                                                        //
                                                        Button(action: {
                                                            showImageMenu.toggle()
                                                            selectedCustomImage = nil
                                                            customAnimate.toggle()
                                                        }) {
                                                            if selectedCustomImage != nil {
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
                                                                            .foregroundStyle(.red)
                                                                        Image(systemName: "trash.square.fill")
                                                                            .resizable()
                                                                            .frame(width: horizontalSizeClass == .compact ? 100 : 50, height: horizontalSizeClass == .compact ? 100 : 50)
                                                                            .padding()
                                                                            .symbolRenderingMode(.hierarchical)
                                                                        
                                                                    }
                                                                    Text("Delete Image")
                                                                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                                                                }
                                                                .foregroundStyle(.red)
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
                                                                .foregroundStyle(.red)
                                                                .padding()
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                    }
                                }
                            }
                            //                                .dropDestination(for: Data.self) { items, location in
                            //                                    isLoading.toggle()
                            //                                    guard let item = items.first else {
                            //                                        selectedCustomImage = nil
                            //                                        return false
                            //                                    }
                            //                                    guard let uiImage = UIImage(data: item) else {
                            //                                        selectedCustomImage = nil
                            //                                        return false
                            //                                    }
                            //                                    selectedCustomImage = uiImage
                            //                                    if currCustomIconText.isEmpty {
                            //                                        currCustomIconText = labelImage(input: uiImage).components(separatedBy: ", ")[0]
                            //                                    }
                            //                                    return true
                            //                                }
                            Spacer()
                        }
                        ZStack { //zstack with gray is to workaround low contrast on dark mode despite white background
                            Text("Label")
                                .minimumScaleFactor(0.1)
                                .multilineTextAlignment(.center)
                                .font(.system(size: horizontalSizeClass == .compact ? ((lastOrientation.isLandscape && horizontalSizeClass != .compact) ? 30 : 50) : ((lastOrientation.isLandscape && horizontalSizeClass != .compact) ? 75 : 135), weight: .semibold,  design: .rounded))
                                .foregroundStyle(currCustomIconText.isEmpty ? Color(.systemGray) : .clear)
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
                            .foregroundStyle(.black)
                            .padding()
                            //Spacer()
                        }
                        if isCustomTextFieldActive && horizontalSizeClass != .compact || lastOrientation.isLandscape {
                            Spacer()
                        }
                    }
                )
                .scaledToFit()
                .padding()
            HStack { //bottom row of buttons
                Button(action: {
                    self.presentation.wrappedValue.dismiss()
                    currCustomIconText = ""
                    selectedCustomImage = nil
                    showImageMenu = false
                }) {
                    Image(systemName:"xmark.square.fill")
                        .resizable()
                        .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                        .foregroundStyle(Color(.systemGray))
                        .padding()
                }
                if !isLoading && (selectedCustomImage != nil || !currCustomIconText.isEmpty) {
                    Button(action: {
                        var customPECSAddresses = getCustomPECSAddresses()
                        
                        if editCustom {  //problem in here somewhere
                            if currCustomIconText != oldEditingIcon { //if the text has changed
                                
                                if currCustomIconText.isEmpty { //if its empty then give it something to go off of
                                    if customPECSAddresses["0#id"] == nil {
                                        currCustomIconText = "0#id"
                                    } else {
                                        var i = 1
                                        while customPECSAddresses["\(i)#id"] != nil {
                                            i += 1
                                        }
                                        currCustomIconText = "\(i)#id"
                                    }
                                }
                                if customPECSAddresses[currCustomIconText] != nil { //if there is already something named the same thing then change it
                                    var i = 1
                                    while customPECSAddresses["\(i)#id\(currCustomIconText)"] != nil {
                                        i += 1
                                    }
                                    currCustomIconText = "\(i)#id\(currCustomIconText)"
                                }
                                
                                if loadImageFromLocalURL(customPECSAddresses[oldEditingIcon] ?? "") != nil { //if the old icon had an image
                                    deleteFile(at: customPECSAddresses[oldEditingIcon]!) //then delete the old image
                                }
                                customPECSAddresses[oldEditingIcon] = nil //remove the old key
                                if selectedCustomImage == nil {
                                    customPECSAddresses[currCustomIconText] = "" //if there is no image now then set the new value to be empty
                                } else {
                                    customPECSAddresses[currCustomIconText] = saveImageToDocumentsDirectory(selectedCustomImage!) //else save the new image
                                }
                                saveSheetArray(sheetObjects: updateCustomIcons(oldKey: oldEditingIcon, newKey: currCustomIconText))
                            } else if loadImageFromLocalURL(customPECSAddresses[currCustomIconText]!) != selectedCustomImage { //same text new image
                                if selectedCustomImage == nil {
                                    customPECSAddresses[currCustomIconText] = "" //if there is no image now then set the new value to be empty
                                } else {
                                    customPECSAddresses[currCustomIconText] = saveImageToDocumentsDirectory(selectedCustomImage!) //else save the new image
                                }
                            }
                            
                        } else {
                            if currCustomIconText.isEmpty {
                                if customPECSAddresses["0#id"] == nil {
                                    currCustomIconText = "0#id"
                                } else {
                                    var i = 1
                                    while customPECSAddresses["\(i)#id"] != nil {
                                        i += 1
                                    }
                                    currCustomIconText = "\(i)#id"
                                }
                            }
                            if customPECSAddresses[currCustomIconText] != nil {
                                var i = 1
                                while customPECSAddresses["\(i)#id\(currCustomIconText)"] != nil {
                                    i += 1
                                }
                                currCustomIconText =  "\(i)#id\(currCustomIconText)"
                            }
                            if selectedCustomImage == nil {
                                customPECSAddresses[currCustomIconText] = ""
                            } else {
                                customPECSAddresses[currCustomIconText] = saveImageToDocumentsDirectory(selectedCustomImage!)
                            }
                            var currCommunicationBoard = loadCommunicationBoard()
                            currCommunicationBoard.insert([currCustomIconText], at: 0)
                            saveCommunicationBoard(currCommunicationBoard)
                        }
                        
                        saveCustomPECSAddresses(customPECSAddresses)
                        modifyCustomIcon()
                        self.presentation.wrappedValue.dismiss()
                        updateUsage("action:editIcon")
                        selectedCustomImage = nil
                        currCustomIconText = ""
                        oldEditingIcon = ""
                    }) {
                        if selectedCustomImage == nil && currCustomIconText.isEmpty && editCustom {
                            Image(systemName:"trash.square.fill")
                                .resizable()
                                .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                .foregroundStyle(.red)
                                .symbolRenderingMode(.hierarchical)
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
            }
            .ignoresSafeArea(.keyboard)
        }
        .animation(.spring, value: customAnimate)
        .onChange(of: isImagePickerPresented, perform: { _ in
            isLoading = isImagePickerPresented
        })
        .onChange(of: showCamera, perform: { _ in
            isLoading = showCamera
        })
        .onChange(of: isDocumentPickerPresented, perform: { _ in
            isLoading = isDocumentPickerPresented
        })
        .sheet(isPresented: $isDocumentPickerPresented) {
            DocumentImagePicker(selectedCustomImage: $selectedCustomImage)
                .ignoresSafeArea()
        }
        .sheet(isPresented: $isImagePickerPresented) {
            PHPickerView(selectedImage: $selectedCustomImage)
                .ignoresSafeArea()
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraPickerView(selectedImage: $selectedCustomImage)
        }
    }
}
