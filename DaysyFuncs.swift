//
//  DaysyFuncs.swift
//  Daysy
//
//  Created by Alexander Eischeid on 11/13/23.
//

import Foundation
import SwiftUI
import AVFoundation
import UserNotifications
import CoreData
import LocalAuthentication

var currSessionLog = [""]

func loadImage(named imageName: String) -> Image {
    let image = Image(imageName)
    return image
}

func loadSystemImage(named imageName: String) -> Image {
    let image = Image(systemName: imageName)
    return image
}

func saveSheetArray(sheetObjects: [SheetObject]) {
    if let encoded = try? encoder.encode(sheetObjects) {
        defaults.set(encoded, forKey: "sheetArray")
    }
}

func removeSheet(sheetIndex: Int) {
    var currArray = loadSheetArray()
    if sheetIndex < currArray.count {
        currArray.remove(at: sheetIndex)
        saveSheetArray(sheetObjects: currArray)
    }
}

func loadSheetArray() -> [SheetObject] {
    if let savedData = defaults.data(forKey: "sheetArray") {
        if let loadedObjects = try? decoder.decode([SheetObject].self, from: savedData) {
            return loadedObjects
        }
    }
    return [SheetObject(label: "Debug, ignore this page")]
}

func newSheet(gridType: String, label: String = "label") {
    var currArray = loadSheetArray()
    currArray.append(SheetObject(gridType: gridType, removedIcons: [], completedIcons: [], label: label))
    saveSheetArray(sheetObjects: currArray)
}

func getCurrSheetIndex() -> Int {
    if let savedIndex = defaults.integer(forKey: "currSheetIndex") as Int? {
        if savedIndex < loadSheetArray().count {
            return savedIndex
        }
    }
    currSessionLog.append("sheet index invalid, returning -1")
    return loadSheetArray().count - 1 //here instead of returning zero, handle if there is not an array, will produce fatal error
}


func sortSheet(_ gridSlots: [GridSlot]) -> [GridSlot] {
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    let sortedDates = gridSlots.sorted { (date1, date2) -> Bool in
        let timeString1 = dateFormatter.string(from: date1.currTime)
        let timeString2 = dateFormatter.string(from: date2.currTime)
        
        return timeString1 < timeString2
    }
    return sortedDates
}


func getTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
}

func getAllCompleted() -> [IconObject] {
    let sheetArray = loadSheetArray()
    var completedIcons: [IconObject] = []
    for sheet in sheetArray {
        for icon in sheet.completedIcons {
            completedIcons.append(icon)
        }
    }
    return completedIcons
}

func getAllRemoved() -> [IconObject] {
    let sheetArray = loadSheetArray()
    var removedIcons: [IconObject] = []
    for sheet in sheetArray {
        for icon in sheet.removedIcons {
            removedIcons.append(icon)
        }
    }
    return removedIcons
}

func getCompletedRatio() -> CGFloat {
    let allCompleted = CGFloat(getAllCompleted().count)
    let allRemoved = CGFloat(getAllRemoved().count)
    
    if allCompleted < 1 || allRemoved < 1 {
        if allCompleted < 1 && allRemoved < 1 {
            return 0.5
        }
        if allCompleted < 1 {
            return 0
        }
        if allRemoved < 1 {
            return 1
        }
    }
    return (allCompleted/(allCompleted + allRemoved))
}

func getRemovedRatio() -> CGFloat {
    return 1 - getCompletedRatio()
}

func getThisCompletedIcons(item: SheetObject) -> Int {
    return item.completedIcons.count
}

func getThisremovedIcons(item: SheetObject) -> Int {
    return item.removedIcons.count
}

func getCurrCompletedRatio(allCompleted: CGFloat, allRemoved: CGFloat) -> CGFloat {
    if allCompleted < 1 || allRemoved < 1 {
        if allCompleted < 1 && allRemoved < 1 {
            return -1
        }
        if allCompleted < 1 {
            return 0
        }
        if allRemoved < 1 {
            return 1
        }
    }
    let all = allCompleted + allRemoved
    return (allCompleted/all)
}
    
func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
        if granted {
            currSessionLog.append("Notification permission granted.")
            defaults.set(true, forKey : "notificationsAllowed")
        } else {
            currSessionLog.append("Notification permission denied.")
            defaults.set(false, forKey : "notificationsAllowed")
        }
    }
}

func manageNotifications() {
    currSessionLog.append("notifs on: \(defaults.bool(forKey: "notifsOn"))")
    if defaults.bool(forKey: "notifsOn") {
        let currSheetArray = loadSheetArray()
        for (index, sheet) in currSheetArray.enumerated() {
            if sheet.gridType == "time" {
                sheetNotifications(sheet: sheet, sheetIndex: index)
            }
        }
    } else {
        notificationCenter.removeAllPendingNotificationRequests()
    }
}

func sheetNotifications(sheet: SheetObject, sheetIndex: Int) {
    //let presentationOptions: UNNotificationPresentationOptions = [.alert, .sound, .badge]
    
    notificationCenter.getPendingNotificationRequests { requests in
            let requestsToRemove = requests.filter { $0.identifier == sheet.label }
            
            let identifiersToRemove = requestsToRemove.map { $0.identifier }
            
            notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
            
            currSessionLog.append("Removed notifications with identifier: \(sheet.label)")
        }
    
    for object in sheet.currGrid {
        let content = UNMutableNotificationContent()
        content.title = sheet.label
        content.body = "It's time for your \(getTime(date: object.currTime)) timeslot!"
        content.userInfo = ["currSheetIndex": sheetIndex]
        
        content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
        
        let components = calendar.dateComponents([.hour, .minute], from: object.currTime)

        let scheduledDate = calendar.date(bySettingHour: components.hour!, minute: components.minute!, second: 0, of: object.currTime)!

        let triggerDateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: scheduledDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: true)


        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        notificationCenter.add(request) { (error) in
            if let error = error {
                currSessionLog.append("Error scheduling \(sheet.label) notification: \(error.localizedDescription)")
            } else {
                currSessionLog.append("\(sheet.label) notification scheduled successfully for \(getTime(date: object.currTime))")
            }
        }
    }
}

func autoRemoveSlots(_ currSheet: SheetObject) -> SheetObject {
    var newSheet = currSheet
    if defaults.bool(forKey: "emptyOn") {
        for (index, _) in newSheet.currGrid.enumerated() {
            newSheet.currGrid[index].currIcons.sort { (object1, object2) -> Bool in
                if object1.currIcon == "plus.viewfinder" {
                    return false
                } else if object2.currIcon == "plus.viewfinder" {
                    return true
                } else {
                    return false // or false based on your sorting criteria for other icons
                }
            }
        }
        newSheet.currGrid = newSheet.currGrid.filter { !$0.isEmpty() }
        if newSheet.currGrid.count < 1 {
            newSheet.currGrid.append(GridSlot())
        }
    }
    return newSheet
}


func isBiometricAuthenticationAvailable() -> Bool {
    let context = LAContext()

    var error: NSError?

    if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
        return true
    } else {
        if let error = error {
            // Handle the error if needed
            currSessionLog.append("Biometric authentication is not available. Error: \(error.localizedDescription)")
        }
        return false
    }
}

func isPasswordAuthenticationAvailable() -> Bool {
    let context = LAContext()

    var error: NSError?

    if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
        return true
    } else {
        if let error = error {
            // Handle the error if needed
            currSessionLog.append("Password authentication is not available. Error: \(error.localizedDescription)")
        }
        return false
    }
}

func updateCurrTimeToNow(_ customObjects: [GridSlot]) -> [GridSlot] {
    let now = Date()
    var newGrid = customObjects

    for index in customObjects.indices {
        let currTimeComponents = calendar.dateComponents([.hour, .minute, .second, .nanosecond], from: customObjects[index].currTime)
        let updatedCurrTime = calendar.date(bySettingHour: currTimeComponents.hour!, minute: currTimeComponents.minute!, second: currTimeComponents.second!, of: now)!

        newGrid[index].currTime = updatedCurrTime
    }
    return newGrid
}

func canUseBiometrics() -> Bool {
    let context = LAContext()

    var error: NSError?

    if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
        // Biometrics are available on the device
        return true
    } else {
        // Biometrics are not available or are restricted on the device
        return false
    }
}

func canUsePassword() -> Bool {
    let context = LAContext()

    var error: NSError?

    if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
        // Device has a passcode set
        return true
    } else {
        // Device does not have a passcode set or is restricted
        return false
    }
}

func getCurrentTimeRoundedToHalfHour() -> Date {
    let testCalendar = Calendar.current
    
    let currentDate = Date()
    
    // Extract components from the current date
    let components = testCalendar.dateComponents([.hour, .minute], from: currentDate)
    
    // Check if components.hour and components.minute are not nil
    if let hour = components.hour, let minute = components.minute {
        // Calculate the rounded minute value to the nearest half-hour
        let roundedMinutes = (minute + 15) / 30 * 30 % 60
        
        // Create a new date with the rounded components
        if let roundedDate = testCalendar.date(bySettingHour: hour, minute: roundedMinutes, second: 0, of: currentDate) {
            return roundedDate
        } else {
            currSessionLog.append("Unable to create rounded date at \(getTime(date: Date()))")
        }
    } else {
        currSessionLog.append("Unable to extract date components at \(getTime(date: Date()))")
    }
    return Date()
}



func getDateTwoHoursPrior(from date: Date) -> Date {
    
    // Subtract two hours from the specified date
    if let newDate = calendar.date(byAdding: .hour, value: -2, to: date) {
        return newDate
    } else {
        // Return the original date in case of an error
        currSessionLog.append("Cannot get date two hours prior")
        return date
    }
}

extension String {

func toUppercaseAtSentenceBoundary() -> String {

 var result = ""
    self.uppercased().enumerateSubstrings(in: self.startIndex..<self.endIndex, options: .bySentences) { (sub, _, _, _)  in
        result += String(sub!.prefix(1))
        result += String(sub!.dropFirst(1)).lowercased()
    }

    return result as String
  }
}


//funcs for usage statistics below

func formatDateToString(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd"
    return dateFormatter.string(from: date)
}

func updateUsage(_ icon: String) -> Void {
    var currUsage = getUsage()
    if let index = currUsage.firstIndex(where: { $0.date == Date() }) {
        currUsage[index].data.append(icon)
    } else {
        currUsage.append(UsageData(data: [icon]))
    }
    
    saveUsage(currUsage)
}

// Function to save usage data to UserDefaults
func saveUsage(_ usageData: [UsageData]) {
    if let encodedData = try? encoder.encode(usageData) {
        UserDefaults.standard.set(encodedData, forKey: "usageData")
    }
}

// Function to retrieve usage data from UserDefaults
func getUsage() -> [UsageData] {
    if let data = UserDefaults.standard.data(forKey: "usageData"),
       var decodedData = try? decoder.decode([UsageData].self, from: data) {

        // Modify all dates in the array to be at 11:59:59 pm
        decodedData = decodedData.map { usageData in
            UsageData(date: Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: usageData.date) ?? usageData.date,
                      data: usageData.data)
        }
        
        return fillMissingDates(in: decodedData)
    }
    
    return []
}


//most used icons, ordered from most to least
func mostUsedIcons() -> [String] {
    let usageDataArray = getUsage()
    var frequencyDictionary: [String: Int] = [:]

    for usageData in usageDataArray {
        for string in usageData.data {
            frequencyDictionary[string, default: 0] += 1
        }
    }

    let sortedStrings = frequencyDictionary.keys.sorted {
        frequencyDictionary[$0]! > frequencyDictionary[$1]!
    }

    return sortedStrings
}

func howmany(in usageDataArray: [UsageData], for targetString: String) -> Int {
    return usageDataArray.reduce(0) { (result, usageData) in
        return result + usageData.data.filter { $0 == targetString }.count
    }
}

// Function to fill in missing dates in UsageData array
func fillMissingDates(in usageArray: [UsageData]) -> [UsageData] {
    let usageDataArray = usageArray.sorted { $0.date < $1.date }
    let lastDate = usageDataArray.map { $0.date }.max()
    guard (usageDataArray.first?.date) != nil else {
        return usageDataArray // No dates in the array
    }
    
    var dateIndex = 0
    var missingData: [UsageData] = []
    var currentDate = usageDataArray[0].date
    
    for _ in usageDataArray {
        if dateIndex != usageDataArray.count - 1 {
            if !Calendar.current.isDate(usageDataArray[dateIndex].date, inSameDayAs: currentDate) {
                if currentDate < lastDate ?? usageDataArray[usageDataArray.count - 1].date {
                    missingData.append(UsageData(date: currentDate))
                }
            }
            dateIndex += 1
            if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) {
                currentDate = nextDay
            } else {
             currentDate = Date()
                print("failed to reassign date")
            }
        }
    }
    
    //combibne the missing data and rthe current data and then return
    return (usageDataArray + missingData).sorted { $0.date < $1.date } //return the filled array
    
    
    func isNextDay(date: Date, from currentDate: Date) -> Bool {
        guard let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) else {
            return false
        }
        
        return Calendar.current.isDate(date, inSameDayAs: nextDay)
    }
}

func hasCameraPermission() -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        switch status {
        case .authorized:
            return true
        case .notDetermined:
            var isAuthorized = false
            AVCaptureDevice.requestAccess(for: .video) { granted in
                isAuthorized = granted
            }
            return isAuthorized
        default:
            return false
        }
    }
