//
//  DebugView.swift
//  Daysy
//
//  Created by Alexander Eischeid on 10/28/23.
//

import SwiftUI

struct DebugView: View {
    
    @Environment(\.presentationMode) var presentation
    
    let currAppGrid = allPECS
    @State var tutorialView = false
    @State var password = ""
    @State var showAlert = false
    @State var showLog = false
    
    private let devPassword = "071321!"
    
    var body: some View {
        VStack {
            if password != devPassword {
                Spacer()
                Text("\(Image(systemName: "exclamationmark.triangle.fill")) Developer Access Only")
                    .minimumScaleFactor(0.01)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 30, weight: .semibold, design: .rounded))
                    .foregroundColor(.orange)
                    .padding()
                Button(action: {
                    self.presentation.wrappedValue.dismiss()
                }) {
                    Text("\(Image(systemName: "arrow.backward")) Back")
                        .lineLimit(1)
                        .minimumScaleFactor(0.1)
                        .font(.system(size: 30, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                        .padding()
                        .padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(25)
                }
                .padding()
                SecureField("", text: $password)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 30, weight: .semibold, design: .rounded))
                    .keyboardType(.numberPad)
                    .accentColor(Color(.systemBackground))
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(.systemBackground))
                    )
                    .padding()
                Spacer()
            } else {
                Text("\(Image(systemName: "lock.open")) Developer Access Granted")
                    .minimumScaleFactor(0.01)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 30, weight: .semibold, design: .rounded))
                    .foregroundColor(.green)
                    .padding()
            }
        }
        .navigationBarHidden(true)
        .navigationViewStyle(StackNavigationViewStyle())
        if password == devPassword {
            ScrollView {
                VStack {
                    Text("Total Sheets")
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .padding()
                    Text("\(loadSheetArray().count - 1)")
                        .minimumScaleFactor(0.01)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 30, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(.systemGray))
                }
                Divider()
                    .padding(20)
                VStack {
                    Text("Total Default Icons")
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .padding()
                    Text("\(allPECS.count)")
                        .minimumScaleFactor(0.01)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 30, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(.systemGray))
                }
                Divider()
                    .padding(20)
                VStack {
                    Text("Total Custom Icons")
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .padding()
                    Text("\(getCustomPECSAddresses().count)")
                        .minimumScaleFactor(0.01)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 30,weight: .semibold,  design: .rounded))
                        .foregroundColor(Color(.systemGray))
                }
                Divider()
                    .padding(20)
                VStack {
                    Text("Notification Permission")
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .padding()
                    Text("\(String(defaults.bool(forKey : "notificationsAllowed")))")
                        .minimumScaleFactor(0.01)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 30, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(.systemGray))
                }
                Divider()
                    .padding(20)
                VStack {
                    Text("Biometric Auth Available")
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .padding()
                    Text("\(String(isBiometricAuthenticationAvailable()))")
                        .minimumScaleFactor(0.01)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 30, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(.systemGray))
                }
                Divider()
                    .padding(20)
                VStack {
                    Text("Password Auth Available")
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .padding()
                    Text("\(String(isPasswordAuthenticationAvailable()))")
                        .minimumScaleFactor(0.01)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 30, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(.systemGray))
                }
                Divider()
                    .padding(20)
                VStack {
                    Text("Custom Password")
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .padding()
                    if let customPassword = defaults.string(forKey: "customPassword") {
                        Text("\(customPassword)")
                            .minimumScaleFactor(0.01)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 30, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(.systemGray))
                    } else {
                        Text("Password Not Set")
                            .minimumScaleFactor(0.01)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 30, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(.systemGray))
                    }
                }
                Divider()
                    .padding(20)
                VStack {
                    Text("Completed Tutorial")
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .padding()
                    Text("\(String(defaults.bool(forKey: "completedTutorial")))")
                        .minimumScaleFactor(0.01)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 30, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(.systemGray))
                }
                Divider()
                    .padding(20)
                VStack {
                    Text("Documents Folder Location")
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .padding()
                    Text("\(documentsURL)")
                        .minimumScaleFactor(0.01)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 30, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(.systemGray))
                }
                Divider()
                    .padding(20)
                VStack {
                    Text("Items in Documents")
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .padding()
                    Text("\(String(countItemsInDocuments()))")
                        .minimumScaleFactor(0.01)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 30, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(.systemGray))
                }
                Divider()
                    .padding(20)
                HStack {
                    Spacer()
                    Button(action: {
                        self.presentation.wrappedValue.dismiss()
                    }) {
                        Text("\(Image(systemName: "arrow.backward")) Back")
                            .lineLimit(1)
                            .minimumScaleFactor(0.1)
                            .font(.system(size: 30, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                            .padding()
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(30)
                    }
                    .padding()
                    Button(action: {
                        showLog.toggle()
                    }) {
                        Text("\(Image(systemName: "list.bullet.rectangle.portrait")) View Log")
                            .font(.system(size: 30, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                            .padding()
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(30)
                    }
                    .padding()
                    Button(action: {
                        showAlert.toggle()
                    }) {
                        Text("\(Image(systemName: "trash")) Reset Daysy")
                            .font(.system(size: 30, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                            .padding()
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(Color.red.opacity(0.3))
                            )
                            .cornerRadius(30)
                    }
                    .padding()
                    Spacer()
                }
                .padding()
                .sheet(isPresented: $showLog) {
                    ScrollView {
                        Text("Current Session Log")
                            .lineLimit(1)
                            .minimumScaleFactor(0.01)
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .padding()
                        VStack {
                            ForEach(0..<currSessionLog.count, id: \.self) { index in
                                VStack {
                                    Text("\(currSessionLog[index])")
                                        .minimumScaleFactor(0.01)
                                        .multilineTextAlignment(.center)
                                        .font(.system(size: 30, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color(.systemGray))
                                    Divider()
                                        .padding(.leading)
                                        .padding(.trailing)
                                }
                            }
                        }
                        Spacer()
                    }
                    .padding()
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Reset Daysy?"),
                    message: Text("This will reset Daysy UserDefaults and clear Documents. Please close Daysy afterwards."),
                    primaryButton: .cancel(),
                    secondaryButton: .destructive(Text("Reset")) {
                        defaults.removePersistentDomain(forName: domain)
                        clearDocumentsDirectory()
                    }
                )
            }
        }
    }
}

#Preview {
    DebugView()
}
