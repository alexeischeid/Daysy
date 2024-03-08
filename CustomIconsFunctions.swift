//
//  CustomIconsFunctions.swift
//  Daysy
//
//  Created by Alexander Eischeid on 11/9/23.
//

import Foundation
import SwiftUI
import PhotosUI
import CoreGraphics

let fileManager = FileManager.default
let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]


// [String: String]  name of the icon: the image it references
func getCustomPECSAddresses() -> [String: String] {
    
    if defaults.bool(forKey: "newIcons") {
        if let storedData = UserDefaults.standard.data(forKey: "newCustomIconAddresses"),
           let customPECSAddresses = try? decoder.decode([String: String].self, from: storedData) {
            return customPECSAddresses
        } else {
            return [:] // Return an empty dictionary if not found or decoding fails
        }
    } else {
        
        if let storedData = UserDefaults.standard.data(forKey: "customPECSAddresses"),
           let customPECSAddresses = try? decoder.decode([String: String].self, from: storedData) {
            return customPECSAddresses
        } else {
            return [:] // Return an empty dictionary if not found or decoding fails
        }
    }
}

func saveNoImageIcons(_ noImageIcon: String) {
    var noImageIcons = getNoImageIcons()
    noImageIcons.append(noImageIcon)
    if let encoded = try? encoder.encode(noImageIcons) {
        defaults.set(encoded, forKey: "noImageIcons")
    }
}

func getNoImageIcons() -> [String] {
    if let savedData = defaults.data(forKey: "noImageIcons") {
        if let loadedObjects = try? decoder.decode([String].self, from: savedData) {
            return loadedObjects
        }
    }
    return []
}

func getCustomIconToSave(_ keyString: String) -> UIImage {
    let customIconName = extractKey(from: keyString)
    let customIconObjects = getCustomPECSAddresses()
    let customImage = loadImageFromLocalURL(customIconObjects[removeCustomIconObjectPrefix(keyString)]!)!.asImage
    let noImage = getNoImageIcons().contains(customIconObjects[removeCustomIconObjectPrefix(keyString)]!)
    
    return CustomIconSaveView(selectedCustomImage: customImage, currCustomIconText: customIconName, noImage: noImage).asImage()
}

func getCustomIcon(_ keyString: String) -> some View {
    let customIconName = extractKey(from: keyString)
    let customIconObjects = getCustomPECSAddresses()
    let customImage = loadImageFromLocalURL(customIconObjects[removeCustomIconObjectPrefix(keyString)] ?? "")?.asImage ?? Image(systemName: "exclamationmark.triangle.fill")
    let noImage = getNoImageIcons().contains(customIconObjects[removeCustomIconObjectPrefix(keyString)] ?? "")
    
    return CustomIconView(selectedCustomImage: customImage, currCustomIconText: customIconName, noImage: noImage)
}


func getCustomIconLarge(_ keyString: String) -> some View {
    let customIconName = extractKey(from: keyString)
    let customIconObjects = getCustomPECSAddresses()
    let customImage = loadImageFromLocalURL(customIconObjects[removeCustomIconObjectPrefix(keyString)] ?? "")?.asImage ?? Image(systemName: "exclamationmark.triangle.fill")
    let noImage = getNoImageIcons().contains(customIconObjects[removeCustomIconObjectPrefix(keyString)] ?? "")
    
    return CustomIconViewLarge(selectedCustomImage: customImage, currCustomIconText: customIconName, noImage: noImage)
}

func getCustomIconSmall(_ keyString: String) -> some View {
    let customIconName = extractKey(from: keyString)
    let customIconObjects = getCustomPECSAddresses()
    let customImage = loadImageFromLocalURL(customIconObjects[removeCustomIconObjectPrefix(keyString)] ?? "")?.asImage ?? Image(systemName: "exclamationmark.triangle.fill")
    let noImage = getNoImageIcons().contains(customIconObjects[removeCustomIconObjectPrefix(keyString)] ?? "")
    
    return CustomIconViewSmall(selectedCustomImage: customImage, currCustomIconText: customIconName, noImage: noImage)
}

func extractKey(from inputString: String) -> String {
    var result = inputString

        // Remove "customIconObject:"
        if let rangeOfColon = result.range(of: "customIconObject:") {
            result = String(result[rangeOfColon.upperBound...])
        }

        // Check if the resulting string contains "#id"
        if let rangeOfID = result.range(of: "#id") {
            // Case: "customIconObject:number#idvariable"
            return String(result[rangeOfID.upperBound...])
        }

        // Case: "customIconObject:variable"
        return result
}

func removeCustomIconObjectPrefix(_ inputString: String) -> String {
    return inputString.replacingOccurrences(of: "customIconObject:", with: "")
}


func clearDocumentsDirectory() {
    do {
        let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: [])

        for fileURL in fileURLs {
            try fileManager.removeItem(at: fileURL)
        }

        currSessionLog.append("Documents directory cleared successfully.")
    } catch {
        currSessionLog.append("Error clearing documents directory: \(error.localizedDescription)")
    }
}

func saveCustomPECSAddresses(_ addresses: [String: String]) {
    
    if defaults.bool(forKey: "newIcons") {
        do {
            let data = try encoder.encode(addresses)
            UserDefaults.standard.set(data, forKey: "newCustomIconAddresses")
        } catch {
            currSessionLog.append("Error encoding custom PECS addresses: \(error.localizedDescription)")
        }
    } else {
        do {
            let data = try encoder.encode(addresses)
            UserDefaults.standard.set(data, forKey: "customPECSAddresses")
        } catch {
            currSessionLog.append("Error encoding custom PECS addresses: \(error.localizedDescription)")
        }
    }
    
}

func saveImageToDocumentsDirectory(_ uiImage: UIImage) -> String {
    // Create a unique name for the image file
    let fileName = generateUniqueName() + ".jpg"
    let fileURL = documentsURL.appendingPathComponent(fileName)

    // Convert the UIImage to Data
    guard let imageData = uiImage.jpegData(compressionQuality: 1.0) else {
        currSessionLog.append("Failed to convert UIImage to Data.")
        return ""
    }

    do {
        // Write the data to the file
        try imageData.write(to: fileURL)
        currSessionLog.append("Image saved to documents directory: \(fileURL.absoluteString)")
        return fileName
    } catch {
        currSessionLog.append("Error writing image to documents directory: \(error.localizedDescription)")
    }
    return ""
}

func loadImageFromLocalURL(_ localImageName: String) -> UIImage? {
    
    guard let localURL = URL(string: String("\(documentsURL)") + localImageName) else {
        currSessionLog.append("Invalid local URL string.")
        return nil
    }

    do {
        let imageData = try Data(contentsOf: localURL)
        return UIImage(data: imageData)
    } catch {
        currSessionLog.append("Error loading image from local URL: \(error.localizedDescription)")
        return nil
    }
}

// Function to generate a unique name based on time interval since 1970
func generateUniqueName() -> String {
    return "\(Int(Date().timeIntervalSince1970))"
}

func countItemsInDocuments() -> Int {
    do {
        // Get contents of the folder
        let contents = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)

        // Return the count of items in the folder
        return contents.count
    } catch {
        // Handle any errors
        currSessionLog.append("Error counting items in folder: \(error)")
        return 0
    }
}


extension UIImage {
    var asImage: Image {
        Image(uiImage: self)
    }
}

extension View {
    func asImage() -> UIImage {
        let controller = UIHostingController(rootView: self)

        // locate far out of screen
        controller.view.frame = CGRect(x: CGFloat(Int.max), y: 0, width: 1024, height: 1024)
        UIApplication.shared.windows.first!.rootViewController?.view.addSubview(controller.view)

        let size = controller.sizeThatFits(in: UIScreen.main.bounds.size)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.backgroundColor = UIColor.white
        controller.view.sizeToFit()

        let image = UIImage(view: controller.view)
        controller.view.removeFromSuperview()
        return image
    }
}

extension UIImage {
    convenience init(view: UIView) {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            fatalError("Unable to get the context")
        }
        
        view.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else {
            fatalError("Unable to get the CGImage from context")
        }
        
        self.init(cgImage: cgImage)
    }
}

func deleteFile(at url: String) {
    let fileManager = FileManager.default
    let deleteURL = URL(string: String("\(documentsURL)") + url)

    do {
        try fileManager.removeItem(at: deleteURL!)
        print("File deleted successfully at \(deleteURL!.absoluteString)")
    } catch {
        print("Error deleting file: \(error.localizedDescription)")
    }
}

func updateCustomIcons(oldKey: String, newKey: String) -> [SheetObject] { //TODO: make this update labelicon and details as well
    let currKey = "customIconObject:" + newKey
    var currSheetArray = loadSheetArray()
    var currUsage = getUsage()
    
    for (sheetIndex, sheet) in currSheetArray.enumerated() {
        for (gridIndex, grid) in sheet.currGrid.enumerated() {
            for (iconIndex, icon) in grid.currIcons.enumerated() {
                if icon.currIcon.contains(oldKey) {
                    currSheetArray[sheetIndex].currGrid[gridIndex].currIcons[iconIndex].currIcon = currKey
                }
                for (detailIndex, detail) in (icon.currDetails ?? []).enumerated() {
                    if detail.contains(oldKey) {
                        currSheetArray[sheetIndex].currGrid[gridIndex].currIcons[iconIndex].currDetails![detailIndex] = currKey
                    }
                }
            }
        }

        for (removedIconIndex, removedIcon) in sheet.removedIcons.enumerated() {
            print(sheet.removedIcons[removedIconIndex])
            if removedIcon.currIcon.contains(oldKey) {
                currSheetArray[sheetIndex].removedIcons[removedIconIndex].currIcon = currKey
            }
        }

        for (completedIconIndex, completedIcon) in sheet.completedIcons.enumerated() {
            if completedIcon.currIcon.contains(oldKey) {
                currSheetArray[sheetIndex].completedIcons[completedIconIndex].currIcon = currKey
            }
        }
        
        if (sheet.currLabelIcon ?? "").contains(oldKey) {
            currSheetArray[sheetIndex].currLabelIcon = currKey
        }
        
    }
    
    for (dataIndex, data) in currUsage.enumerated() {
        for (itemIndex, item)  in data.data.enumerated() {
            if item.contains(oldKey) {
                currUsage[dataIndex].data[itemIndex] = currKey
            }
        }
    }
    saveUsage(currUsage)
    
    return currSheetArray
}

func deleteCustomIcons(currIcon: String) -> [SheetObject] {
    let currKey = "customIconObject:" + currIcon
    var customPECSAddreses = getCustomPECSAddresses()
    var currUsage = getUsage()
    
    var currSheetArray = loadSheetArray()
    for (sheetIndex, sheet) in currSheetArray.enumerated() {
        for (gridIndex, grid) in sheet.currGrid.enumerated() {
            for (iconIndex, icon) in grid.currIcons.enumerated() {
                if icon.currIcon.contains(currKey) {
                    print("the icon \(icon.currIcon) contains \(currKey)")
                }
                if icon.currIcon == currKey {
                    currSheetArray[sheetIndex].currGrid[gridIndex].currIcons[iconIndex].currIcon = "plus.viewfinder"
                    print("found the icon \(currKey) in the main sheet")
                }
            }
        }

        for removedIcon in sheet.removedIcons {
            if removedIcon.currIcon == currKey {
                currSheetArray[sheetIndex].removedIcons = currSheetArray[sheetIndex].removedIcons.filter { $0.currIcon != currKey }
                print("found the icon \(currKey) in removed icons")
            }
        }

        for completedIcon in sheet.completedIcons {
            if completedIcon.currIcon == currKey {
                currSheetArray[sheetIndex].completedIcons = currSheetArray[sheetIndex].completedIcons.filter { $0.currIcon != currKey }
                print("found the icon \(currKey) in completed icons")
            }
        }
        
        if (sheet.currLabelIcon ?? "").contains(currKey) {
            currSheetArray[sheetIndex].currLabelIcon = ""
        }
        
    }
    
    for icon in customPECSAddreses {
        if icon.key == currIcon {
            customPECSAddreses.removeValue(forKey: icon.key)
        }
    }
    saveCustomPECSAddresses(customPECSAddreses)
    
    for (dataIndex, data) in currUsage.enumerated() {
        for (itemIndex, item)  in data.data.enumerated() {
            if item.contains(currKey) {
                currUsage[dataIndex].data.remove(at: itemIndex)
            }
            //check to see if item is or has one of the old custom icons, and remove if so
        }
    }
    saveUsage(currUsage)
    
    
    //now also do labelIcons
    
    return currSheetArray
    // on completion, delete image from documents then remove the key/value pair from addresses
}
