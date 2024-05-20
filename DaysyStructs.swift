//
//  DaysyStructs.swift
//  Daysy
//
//  Created by Alexander Eischeid on 11/13/23.
//

import Foundation
import SwiftUI
import AVFoundation
import PhotosUI
import NaturalLanguage



struct SheetObject: Codable {
    var currGrid: [GridSlot]
    var gridType: String
    var removedIcons: [IconObject]
    var completedIcons: [IconObject]
    var label: String
    var currLabelIcon: String?
    
    init(currGrid: [GridSlot] = [GridSlot()], gridType: String = "label", removedIcons: [IconObject] = [], completedIcons: [IconObject] = [], label: String = "Label") {
        self.currGrid = currGrid
        self.gridType = gridType
        self.removedIcons = removedIcons
        self.completedIcons = completedIcons
        self.label = label
        self.currLabelIcon = ""
    }
    
    func getCurrSlot() -> Int {
        if gridType != "time" {
            return -1
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let now = Date()
        var currSlotIndex = 0
        
        // Get the time components of the current date
        let currentComponents = calendar.dateComponents([.hour, .minute], from: now)
        
        // Filter dates that have the same time of day or earlier
        let filteredDates = updateCurrTimeToNow(currGrid)
            .filter {
                let objectComponents = calendar.dateComponents([.hour, .minute], from: $0.currTime)
                return (objectComponents.hour! < currentComponents.hour!) ||
                (objectComponents.hour! == currentComponents.hour! && objectComponents.minute! <= currentComponents.minute!)
            }
            .compactMap { formatter.string(from: $0.currTime) }
            .compactMap { formatter.date(from: $0) }
        
        if filteredDates.count < 1 {
            return 0
        }
        // Find the latest date from the filtered dates
        let latestDate = filteredDates.max()!
        
        for (index, object) in currGrid.enumerated() {
            //check if the date == latestDate
            if getTime(date: object.currTime) == getTime(date: latestDate) {
                currSlotIndex = index
            }
        }
        return currSlotIndex
        
    }
}


struct GridSlot: Codable, Hashable {
    var currTime: Date
    var currLabel: String
    var currIcons: [IconObject]
    
    init(currLabel: String = "First", currTime: Date = getCurrentTimeRoundedToHalfHour(), currIcons: [IconObject] = [IconObject(), IconObject(), IconObject(), IconObject()]){
        self.currLabel = currLabel
        self.currTime = currTime
        self.currIcons = currIcons
    }
    
    func hash(into hasher: inout Hasher) {
            hasher.combine(currTime)
            hasher.combine(currLabel)
            hasher.combine(currIcons)
        }
    func isEmpty() -> Bool {
        let icons = currIcons
        for (_, icon) in icons.enumerated() {
            if icon.currIcon != "plus.viewfinder" {
                return false
            }
        }
        return true
    }
}

struct IconObject: Codable, Hashable {
    var currLabel: String
    var currIcon: String
    var currDetails: [String]?
    
    init(currLabel: String = "icon", currIcon: String = "plus.viewfinder") {
        self.currLabel = currLabel
        self.currIcon = currIcon
        self.currDetails = []
    }
    
    func hash(into hasher: inout Hasher) {
            hasher.combine(currLabel)
            hasher.combine(currIcon)
        }
}

struct AppGridList: Codable {
    var currLabel: String
    var currIcons: [String]
    
    init(currLabel: String = "App Category", currIcons: [String] = allPECS) {
        self.currLabel = currLabel
        self.currIcons = currIcons
    }
}


class CustomSpeechSynthesizer {
    let synthesizer = AVSpeechSynthesizer()
    
    func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            currSessionLog.append("Failed to configure audio session: \(error.localizedDescription)")
        }
    }
    
    func speak(_ text: String) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers/*, .duckOthers*/])
        } catch let error {
            currSessionLog.append("This error message from SpeechSynthesizer \(error.localizedDescription)")
        }
        
        let speechUtterance: AVSpeechUtterance = AVSpeechUtterance(string: String(text.prefix(250)))
        speechUtterance.rate = AVSpeechUtteranceMaximumSpeechRate / 2.3
        
        // Determine language and set voice
        let language = detectLanguage(for: text)
        speechUtterance.voice = AVSpeechSynthesisVoice(language: language)
        
        synthesizer.speak(speechUtterance)
    }
    
    private func detectLanguage(for text: String) -> String {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        if let languageCode = recognizer.dominantLanguage?.rawValue {
            return languageCode
        } else {
            // Default to English if language cannot be determined
            return "en"
        }
    }
}

struct ViewBoundsKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
    
    typealias Value = CGRect
}

struct UsageData: Codable, Identifiable {
    var id = UUID() // Unique identifier
    var date: Date //the day for which the usage data occured
    var data: [String] //the list of icons (or maybe actions in the future) that counted as usage
    
    init(date: Date = Date(), data: [String] = []) {
        self.date = date
        self.data = data
    }
}



//viewcontrollers and representables below

struct UIImagePicker: View {
    @Binding var selectedImage: UIImage?

    var body: some View {
        UIImagePickerRepresentable(selectedImage: $selectedImage)
            .edgesIgnoringSafeArea(.all)
    }
}

struct UIImagePickerRepresentable: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: UIImagePickerRepresentable

        init(parent: UIImagePickerRepresentable) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            if let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
                // Show the placeholder image while the selected image is being fetched
                self.parent.selectedImage = UIImage(systemName: "square.fill")

                itemProvider.loadObject(ofClass: UIImage.self) { (selectedImage, error) in
                    if let image = selectedImage as? UIImage {
                        // Update the selected image once it's fetched
                        self.parent.selectedImage = image
                    }
                    currSessionLog.append(String("Image Picker Error \(error)"))
                }
            }
            picker.dismiss(animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        // Nothing to update here
    }
}




struct CameraPickerView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: CameraPickerView

        init(parent: CameraPickerView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }

            picker.dismiss(animated: true, completion: nil)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = context.coordinator
        imagePicker.sourceType = .camera
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // Not needed for this example
    }
}

struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

// A View wrapper to make the modifier easier to use
extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}

extension Collection {
    // Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension UIImage {
    func resize(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        self.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    func toBuffer() -> CVPixelBuffer? {
        guard let image = self.cgImage else { return nil }
        
        let frameSize = CGSize(width: image.width, height: image.height)
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         Int(frameSize.width),
                                         Int(frameSize.height),
                                         kCVPixelFormatType_32ARGB,
                                         nil,
                                         &pixelBuffer)
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else { return nil }
        
        CVPixelBufferLockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(buffer)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: pixelData,
                                      width: Int(frameSize.width),
                                      height: Int(frameSize.height),
                                      bitsPerComponent: 8,
                                      bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                                      space: rgbColorSpace,
                                      bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else {
            CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
            return nil
        }
        
        context.translateBy(x: 0, y: frameSize.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        context.draw(image, in: CGRect(origin: .zero, size: frameSize))
        
        CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return buffer
    }
}

