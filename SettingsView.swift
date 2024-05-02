//
//  SettingsView.swift
//  Daysy
//
//  Created by Alexander Eischeid on 10/25/23.
//

import SwiftUI
import LocalAuthentication
import Charts

struct SettingsView: View {
    
    var onDismiss: () -> Void
    
    @Environment(\.presentationMode) var presentation
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State var showAI = false
    @State var aiOn = defaults.bool(forKey: "aiOn")
    @State var showNotifs = false
    @State var notifsOn = defaults.bool(forKey: "notifsOn")
    @State var notifsAllowed = defaults.bool(forKey: "notificationsAllowed")
    @State var showAlert = false
    
    @State var showButtons = false
    @State var buttonsOn = defaults.bool(forKey: "buttonsOn")
    @State var exampleButtonsOn = defaults.bool(forKey: "buttonsOn")
    
    @State var showSpeak = false
    @State var speakOn = defaults.bool(forKey: "speakOn")
    
    @State var showStats = false
    @State var statsOn = defaults.bool(forKey: "statsOn")
    
    @State var showBlank = false
    @State var toggleOn = defaults.bool(forKey: "toggleOn")
    
    @State var showEmpty = false
    @State var emptyOn = defaults.bool(forKey: "emptyOn")
    @State var exampleEmptyOn = false
    
    @State var showCurrSlot = false
    @State var currSlotOn = defaults.bool(forKey: "showCurrSlot")
    @State var exampleSlotOn = false
    
    @State var showCustomPassword = false
    @State var password = ""
    @State var verifyPassword = ""
    @State var showVerify = false
    @State var mismatch = false
    
    @State var debugView = false
    
    @State var animate = false
    
    var body: some View {
        
        let offSet: CGFloat = horizontalSizeClass == .compact ? 18 : 36
        
        NavigationView {
            ZStack {
                ScrollView { //title
                    HStack {
                        Text("\(Image(systemName: "gear")) Settings")
                            .lineLimit(1)
                            .minimumScaleFactor(0.01)
                            .font(.system(size: horizontalSizeClass == .compact ? 30 : 50, weight: .bold, design: .rounded))
                        if horizontalSizeClass == .compact {
                            Spacer()
                            Button(action: {
                                self.presentation.wrappedValue.dismiss()
                                onDismiss()
                            }) {
                                Text("\(Image(systemName: "xmark.circle.fill"))")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                    .font(.system(size: 30, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(.systemGray3))
                            }
                        }
                    }
                     /*
                    HStack {
                        Button(action: {
                            showAI.toggle()
                        }) {
                            HStack {
                                if #available(iOS 15.0, *) {
                                    Image(systemName: "brain.filled.head.profile")
                                        .minimumScaleFactor(0.5)
                                        .font(.system(size: horizontalSizeClass == .compact ? 30 : 40, weight: .bold, design: .rounded))
                                        .foregroundColor(.purple)
                                        .symbolRenderingMode(.hierarchical)
                                } else {
                                    Image(systemName: "brain.filled.head.profile")
                                        .minimumScaleFactor(0.5)
                                        .font(.system(size: horizontalSizeClass == .compact ? 30 : 40, weight: .bold, design: .rounded))
                                        .foregroundColor(.purple)
                                }
                                Text(" OpenAI Features")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.01)
                                    .font(.system(size: horizontalSizeClass == .compact ? 30 : 40, weight: .bold, design: .rounded))
                            }
                        }
                        .foregroundColor(.primary)
                        .padding()
                        Spacer()
                        ZStack {
                            Capsule()
                                .frame(width: horizontalSizeClass == .compact ? 80 : 160,height: horizontalSizeClass == .compact ? 44 : 88)
                                .foregroundColor(aiOn ? .purple : Color(.systemGray3))
                            ZStack{
                                Circle()
                                    .frame(width: horizontalSizeClass == .compact ? 40 : 80, height: horizontalSizeClass == .compact ? 40 : 80)
                                    .foregroundColor(.white)
                                Image(systemName: aiOn ? "poweron" : "poweroff")
                                    .font( horizontalSizeClass == .compact ? Font.title3.weight(.black) : Font.largeTitle.weight(.black))
                                    .foregroundColor(Color(.systemGray))
                            }
                            .shadow(color: .black.opacity(0.14), radius: 4, x: 0, y: 2)
                            //.offset(x:exampleEmptyOn ? (horizontalSizeClass == .compact ? 18 : -18) : (horizontalSizeClass == .compact ? offSet : -offSet))
                            .offset(x:aiOn ? offSet : -offSet)
                            .padding(horizontalSizeClass == .compact ? 0 : 24)
                            .animation(.spring, value: animate)
                        }
                        .padding()
                        .onTapGesture {
                            aiOn.toggle()
                            defaults.set(aiOn, forKey: "aiOn")
                            animate.toggle()
                        }
                    }
                    .background(Color(.systemGray5))
                    .cornerRadius(horizontalSizeClass == .compact ? 20 : 30) */
                    
                    HStack { //speak icons setting, same format as the rest below here
                        Button(action: {
                            showSpeak.toggle()
                        }) {
                            HStack {
                                Image(systemName: "info.circle")
                                    .minimumScaleFactor(0.5)
                                    .font(.system(size: horizontalSizeClass == .compact ? 30 : 40, weight: .bold, design: .rounded))
                                    .foregroundColor(.blue)
                                Text(" Speak Icons")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.01)
                                    .font(.system(size: horizontalSizeClass == .compact ? 30 : 40, weight: .bold, design: .rounded))
                            }
                        }
                        .foregroundColor(.primary)
                        .padding()
                        Spacer()
                        ZStack {
                            Capsule()
                                .frame(width: horizontalSizeClass == .compact ? 80 : 160,height: horizontalSizeClass == .compact ? 44 : 88)
                                .foregroundColor(speakOn ? .green : Color(.systemGray3))
                            ZStack{
                                Circle()
                                    .frame(width: horizontalSizeClass == .compact ? 40 : 80, height: horizontalSizeClass == .compact ? 40 : 80)
                                    .foregroundColor(.white)
                                Image(systemName: speakOn ? "poweron" : "poweroff")
                                    .font( horizontalSizeClass == .compact ? Font.title3.weight(.black) : Font.largeTitle.weight(.black))
                                    .foregroundColor(Color(.systemGray))
                            }
                            .shadow(color: .black.opacity(0.14), radius: 4, x: 0, y: 2)
                            //.offset(x:exampleEmptyOn ? (horizontalSizeClass == .compact ? 18 : -18) : (horizontalSizeClass == .compact ? offSet : -offSet))
                            .offset(x:speakOn ? offSet : -offSet)
                            .padding(horizontalSizeClass == .compact ? 0 : 24)
                            .animation(.spring, value: animate)
                        }
                        .padding()
                        .onTapGesture {
                            speakOn.toggle()
                            defaults.set(speakOn, forKey: "speakOn")
                            animate.toggle()
                        }
                    }
                    .background(Color(.systemGray5))
                    .cornerRadius(horizontalSizeClass == .compact ? 20 : 30)
                    
                    
                    HStack { //curr timeslot setting, same format as the rest below here
                        Button(action: {
                            showCurrSlot.toggle()
                        }) {
                            HStack {
                                Image(systemName: "info.circle")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                    .font(.system(size: horizontalSizeClass == .compact ? 30 : 40, weight: .bold, design: .rounded))
                                    .foregroundColor(.blue)
                                Text(horizontalSizeClass == .compact ? "Highlight Time" : " Show Current Timeslot")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                    .font(.system(size: horizontalSizeClass == .compact ? 30 : 40, weight: .bold, design: .rounded))
                            }
                        }
                        .foregroundColor(.primary)
                        .padding()
                        Spacer()
                        ZStack {
                            Capsule()
                                .frame(width: horizontalSizeClass == .compact ? 80 : 160,height: horizontalSizeClass == .compact ? 44 : 88)
                                .foregroundColor(currSlotOn ? .green : Color(.systemGray3))
                            ZStack{
                                Circle()
                                    .frame(width: horizontalSizeClass == .compact ? 40 : 80, height: horizontalSizeClass == .compact ? 40 : 80)
                                    .foregroundColor(.white)
                                Image(systemName: currSlotOn ? "poweron" : "poweroff")
                                    .font( horizontalSizeClass == .compact ? Font.title3.weight(.black) : Font.largeTitle.weight(.black))
                                    .foregroundColor(Color(.systemGray))
                            }
                            .shadow(color: .black.opacity(0.14), radius: 4, x: 0, y: 2)
                            .offset(x:currSlotOn ? offSet : -offSet)
                            .padding(horizontalSizeClass == .compact ? 0 : 24)
                            .animation(.spring, value: animate)
                        }
                        .padding()
                        .onTapGesture {
                            currSlotOn.toggle()
                            defaults.set(currSlotOn, forKey: "showCurrSlot")
                            animate.toggle()
                        }
                    }
                    .background(Color(.systemGray5))
                    .cornerRadius(horizontalSizeClass == .compact ? 20 : 30)
                    
                    HStack { //lock buttons setting, same format as the rest below here
                        Button(action: {
                            showButtons.toggle()
                        }) {
                            HStack {
                                Image(systemName: "info.circle")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                    .font(.system(size: horizontalSizeClass == .compact ? 30 : 40, weight: .bold, design: .rounded))
                                    .foregroundColor(.blue)
                                Text(" Lock Buttons")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.01)
                                    .font(.system(size: horizontalSizeClass == .compact ? 30 : 40, weight: .bold, design: .rounded))
                            }
                        }
                        .foregroundColor(.primary)
                        .padding()
                        Spacer()
                        ZStack {
                            Capsule()
                                .frame(width: horizontalSizeClass == .compact ? 80 : 160,height: horizontalSizeClass == .compact ? 44 : 88)
                                .foregroundColor(buttonsOn ? .green : Color(.systemGray3))
                            ZStack{
                                Circle()
                                    .frame(width: horizontalSizeClass == .compact ? 40 : 80, height: horizontalSizeClass == .compact ? 40 : 80)
                                    .foregroundColor(.white)
                                Image(systemName: buttonsOn ? "poweron" : "poweroff")
                                    .font( horizontalSizeClass == .compact ? Font.title3.weight(.black) : Font.largeTitle.weight(.black))
                                    .foregroundColor(Color(.systemGray))
                            }
                            .shadow(color: .black.opacity(0.14), radius: 4, x: 0, y: 2)
                            .offset(x:buttonsOn ? offSet : -offSet)
                            .padding(horizontalSizeClass == .compact ? 0 : 24)
                            .animation(.spring, value: animate)
                        }
                        .padding()
                        .onTapGesture {
                            authenticateWithBiometrics()
                            if !canUseBiometrics() && !canUsePassword() {
                                showCustomPassword.toggle()
                                password = ""
                                verifyPassword = ""
                                mismatch = false
                            }
                        }
                    }
                    .background(Color(.systemGray5))
                    .cornerRadius(horizontalSizeClass == .compact ? 20 : 30)
                    
                    HStack { //notifs setting
                        Button(action: {
                            showNotifs.toggle()
                        }) {
                            HStack {
                                Image(systemName: "info.circle")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                    .font(.system(size: horizontalSizeClass == .compact ? 30 : 40, weight: .bold, design: .rounded))
                                    .foregroundColor(.blue)
                                Text(" Notifications")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                    .font(.system(size: horizontalSizeClass == .compact ? 30 : 40, weight: .bold, design: .rounded))
                            }
                        }
                        .foregroundColor(.primary)
                        .padding()
                        Spacer()
                        ZStack { //custom toggle
                            Capsule()
                                .frame(width: horizontalSizeClass == .compact ? 80 : 160,height: horizontalSizeClass == .compact ? 44 : 88)
                                .foregroundColor(notifsOn ? .green : Color(.systemGray3))
                            ZStack{
                                Circle()
                                    .frame(width: horizontalSizeClass == .compact ? 40 : 80, height: horizontalSizeClass == .compact ? 40 : 80)
                                    .foregroundColor(.white)
                                Image(systemName: notifsOn ? "poweron" : "poweroff")
                                    .font( horizontalSizeClass == .compact ? Font.title3.weight(.black) : Font.largeTitle.weight(.black))
                                    .foregroundColor(Color(.systemGray))
                            }
                            .shadow(color: .black.opacity(0.14), radius: 4, x: 0, y: 2)
                            .offset(x:notifsOn ? offSet : -offSet)
                            .padding(horizontalSizeClass == .compact ? 0 : 24)
                            .animation(.spring, value: animate)
                        }
                        .padding()
                        .onTapGesture { //actions for the custom toggle
                            requestNotificationPermission()
                            if defaults.bool(forKey: "notificationsAllowed") {
                                animate.toggle()
                                notifsOn.toggle()
                                defaults.set(notifsOn, forKey: "notifsOn")
                            } else {
                                notifsOn = false
                            }
                            showAlert = !defaults.bool(forKey: "notificationsAllowed")
                            manageNotifications()
                        }
                    }
                    .background(Color(.systemGray5))
                    .cornerRadius(horizontalSizeClass == .compact ? 20 : 30)
                    .onTapGesture(count: 8) {
                        debugView.toggle()
                    }
                    .alert(isPresented: $showAlert) { //cant turn on notifications if theyre not allowed
                        Alert(
                            title: Text("Notifications Disabled"),
                            message: Text("Daysy notifications have been disabled, please change this in your iPad Settings"),
                            primaryButton: .default(Text("Notification Settings").bold(), action: {
                                if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                                    UIApplication.shared.open(appSettings)
                                }
                                
                            }), secondaryButton: .cancel()
                        )
                    }
                    
                    HStack { //empty slots setting, same format as the rest below here
                        Button(action: {
                            showEmpty.toggle()
                        }) {
                            HStack {
                                Image(systemName: "info.circle")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                    .font(.system(size: horizontalSizeClass == .compact ? 30 : 40, weight: .bold, design: .rounded))
                                    .foregroundColor(.blue)
                                Text(" Organize Slots")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                    .font(.system(size: horizontalSizeClass == .compact ? 30 : 40, weight: .bold, design: .rounded))
                            }
                        }
                        .foregroundColor(.primary)
                        .padding()
                        Spacer()
                        ZStack {
                            Capsule()
                                .frame(width: horizontalSizeClass == .compact ? 80 : 160,height: horizontalSizeClass == .compact ? 44 : 88)
                                .foregroundColor(emptyOn ? .green : Color(.systemGray3))
                            ZStack{
                                Circle()
                                    .frame(width: horizontalSizeClass == .compact ? 40 : 80, height: horizontalSizeClass == .compact ? 40 : 80)
                                    .foregroundColor(.white)
                                Image(systemName: emptyOn ? "poweron" : "poweroff")
                                    .font( horizontalSizeClass == .compact ? Font.title3.weight(.black) : Font.largeTitle.weight(.black))
                                    .foregroundColor(Color(.systemGray))
                            }
                            .shadow(color: .black.opacity(0.14), radius: 4, x: 0, y: 2)
                            .offset(x:emptyOn ? offSet : -offSet)
                            .padding(horizontalSizeClass == .compact ? 0 : 24)
                            .animation(.spring, value: animate)
                        }
                        .padding()
                        .onTapGesture {
                            emptyOn.toggle()
                            defaults.set(emptyOn, forKey: "emptyOn")
                            animate.toggle()
                        }
                    }
                    .background(Color(.systemGray5))
                    .cornerRadius(horizontalSizeClass == .compact ? 20 : 30)
                    
                    .sheet(isPresented: $showNotifs) { //notifs details sheet
                        VStack {
                            HStack {
                                Image(systemName: "bell")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.01)
                                    .font(.system(size: horizontalSizeClass == .compact ? 30 : 40, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(.systemGray))
                                Text("Notifications")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.01)
                                    .font(.system(size: horizontalSizeClass == .compact ? 30 : 40, weight: .bold, design: .rounded))
                                    .padding()
                            }
                            Text("When using Timeslots, Daysy will send you a notification if you have uncompleted icons, when when your next timeslot starts.")
                                .minimumScaleFactor(0.01)
                                .multilineTextAlignment(.center)
                                .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                                .foregroundColor(Color(.systemGray))
                            Spacer()
                            Button(action: {
                                if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                                    UIApplication.shared.open(appSettings)
                                }
                            }) {
                                Text("\(Image(systemName: "gear")) Open Settings App")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.1)
                                    .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                    .padding()
                                    .padding()
                                    .background(Color(.systemGray5))
                                    .cornerRadius(horizontalSizeClass == .compact ? 20 : 30)
                            }
                            .padding()
                            Spacer()
                            if notifsAllowed {
                                Text("\(Image(systemName: "moon"))\nIf you are not seeing notifications, check Do Not Disturb or enable notifications in settings.")
                                    .minimumScaleFactor(0.01)
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .bold, design: .rounded))
                                    .foregroundColor(.orange)
                            } else {
                                Text("\(Image(systemName: "bell.slash"))\nDaysy notifications have been disabled, please change this in your iPad Settings")
                                    .minimumScaleFactor(0.01)
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .bold, design: .rounded))
                                    .foregroundColor(.pink)
                            }
                            Spacer()
                        }
                        .onAppear {
                            requestNotificationPermission()
                            if defaults.bool(forKey: "notificationsAllowed") {
                                notifsAllowed = true
                            }
                        }
                        .padding()
                    }
                    .sheet(isPresented: $showButtons) { //lock buttons details sheet
                        VStack {
                            HStack {
                                Image(systemName: "lock")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.01)
                                    .font(.system(size: horizontalSizeClass == .compact ? 30 : 40, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(.systemGray))
                                Text("Lock Buttons")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.01)
                                    .font(.system(size: horizontalSizeClass == .compact ? 30 : 40, weight: .bold, design: .rounded))
                                    .padding()
                            }
                            Text("The buttons to complete or remove an icon, and the bottom buttons on a Sheet will be locked.")
                                .minimumScaleFactor(0.01)
                                .multilineTextAlignment(.center)
                                .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                                .foregroundColor(Color(.systemGray))
                            Spacer()
                            HStack {
                                Text("Try it: ")
                                    .minimumScaleFactor(0.01)
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 40, weight: .bold, design: .rounded))
                                    .padding()
                                ZStack {
                                    Capsule()
                                        .frame(width: horizontalSizeClass == .compact ? 80 : 160,height: horizontalSizeClass == .compact ? 44 : 88)
                                        .foregroundColor(exampleButtonsOn ? .green : Color(.systemGray3))
                                    ZStack{
                                        Circle()
                                            .frame(width: horizontalSizeClass == .compact ? 40 : 80, height: horizontalSizeClass == .compact ? 40 : 80)
                                            .foregroundColor(.white)
                                        Image(systemName: exampleButtonsOn ? "poweron" : "poweroff")
                                            .font( horizontalSizeClass == .compact ? Font.title3.weight(.black) : Font.largeTitle.weight(.black))
                                            .foregroundColor(Color(.systemGray))
                                    }
                                    .shadow(color: .black.opacity(0.14), radius: 4, x: 0, y: 2)
                                    //.offset(x:exampleEmptyOn ? (horizontalSizeClass == .compact ? 18 : -18) : (horizontalSizeClass == .compact ? offSet : -offSet))
                                    .offset(x:exampleButtonsOn ? offSet : -offSet)
                                    .padding(horizontalSizeClass == .compact ? 0 : 24)
                                    .animation(.spring, value: animate)
                                }
                                .padding()
                                .onTapGesture {
                                    exampleButtonsOn.toggle()
                                    animate.toggle()
                                }                            }
                            Spacer()
                            VStack {
                                if horizontalSizeClass != .compact {
                                    Image("hello")
                                        .resizable()
                                        .scaledToFit()
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(lineWidth: 5)
                                        )
                                        .padding()
                                }
                                if exampleButtonsOn {
                                    HStack {
                                        Button(action: {}) {
                                            Image(systemName:"xmark.square.fill")
                                                .resizable()
                                                .frame(width: horizontalSizeClass == .compact ? min(100, 350) : min(150, 500), height: horizontalSizeClass == .compact ? min(100, 350) : min(150, 500))
                                                .foregroundColor(Color(.systemGray))
                                        }
                                        .padding()
                                        
                                        Button(action: {}) {
                                            Image(systemName: "lock.square")
                                                .resizable()
                                                .frame(width: horizontalSizeClass == .compact ? min(100, 350) : min(150, 500), height: horizontalSizeClass == .compact ? min(100, 350) : min(150, 500))
                                                .foregroundColor(Color(.systemGray))
                                        }
                                        .padding()
                                    }
                                } else {
                                    HStack {
                                        Button(action: {}) {
                                            Image(systemName:"xmark.square.fill")
                                                .resizable()
                                                .frame(width: horizontalSizeClass == .compact ? min(100, 350) : min(150, 500), height: horizontalSizeClass == .compact ? min(100, 350) : min(150, 500))
                                                .foregroundColor(Color(.systemGray))
                                        }
                                        .padding()
                                        
                                        Button(action: {}) {
                                            ZStack {
                                                Image(systemName: "square.fill")
                                                    .resizable()
                                                    .frame(width: horizontalSizeClass == .compact ? min(100, 350) : min(150, 500), height: horizontalSizeClass == .compact ? min(100, 350) : min(150, 500))
                                                Image(systemName: "square.slash")
                                                    .resizable()
                                                    .frame(width: horizontalSizeClass == .compact ? min(75, 125) : min(100, 250), height: horizontalSizeClass == .compact ? min(75, 125) : min(100, 250))
                                                    .foregroundColor(Color(.systemBackground))
                                            }
                                        }
                                        .padding()
                                        .foregroundColor(.red)
                                        
                                        Button(action: {}) {
                                            Image(systemName: "checkmark.square.fill")
                                                .resizable()
                                                .frame(width: horizontalSizeClass == .compact ? min(100, 350) : min(150, 500), height: horizontalSizeClass == .compact ? min(100, 350) : min(150, 500))
                                        }
                                        .padding()
                                        .foregroundColor(.green)
                                    }
                                }
                            }
                            .padding()
                            Spacer()
                            Divider()
                            if exampleButtonsOn {
                                Button(action: {}) {
                                    Image(systemName: "lock.square")
                                        .resizable()
                                        .padding()
                                        .frame(width: horizontalSizeClass == .compact ? 75 : 100, height: horizontalSizeClass == .compact ? 75 : 100)
                                        .foregroundColor(Color(.systemGray))
                                }
                                .padding()
                            } else {
                                if horizontalSizeClass == .compact {
                                    VStack {
                                        HStack {
                                            Button(action: {}) {
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
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            .padding(.leading)
                                            .padding(.trailing)
                                            
                                            Button(action: {}) {
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
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            .padding()
                                            
                                            Button(action: {}) {
                                                ZStack {
                                                    Image(systemName: "square")
                                                        .resizable()
                                                        .frame(width: 65, height: 65)
                                                    Image(systemName: "chevron.forward")
                                                        .resizable()
                                                        .frame(width: 20, height: 40)
                                                        .rotationEffect(.degrees(90))
                                                }
                                            }
                                            .foregroundColor(Color(.systemGray2))
                                            .buttonStyle(PlainButtonStyle())
                                            .padding(.leading)
                                            .padding(.trailing)
                                            
                                        }
                                        HStack {
                                            Button(action: {}) {
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
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            .padding([.leading, .trailing])
                                            
                                            Button(action: {}) {
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
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            .padding()
                                            
                                            Button(action: {}) {
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
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            .padding([.leading, .trailing])
                                        }
                                    }
                                } else {
                                    HStack {
                                        Button(action: {}) {
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
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .padding()
                                        
                                        Button(action: {}) {
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
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .padding()
                                        
                                        Button(action: {}) {
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
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .padding()
                                        
                                        Button(action: {}) {
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
                                         .font(.system(size: 20, weight: .semibold, design: .rounded))
                                         .foregroundColor(.orange)
                                         }
                                         }
                                         .buttonStyle(PlainButtonStyle())
                                         .padding()
                                         */
                                        Button(action: {}) {
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
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .padding()
                                    }
                                    .padding()
                                }
                            }
                        }
                        .padding()
                        .animation(.spring, value: animate)
                    }
                    .sheet(isPresented: $showSpeak) { //speak icons details sheet
                        VStack {
                            HStack {
                                Image(systemName: "waveform")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.01)
                                    .font(.system(size: horizontalSizeClass == .compact ? 30 : 40, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(.systemGray))
                                Text("Speak Icons")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.01)
                                    .font(.system(size: horizontalSizeClass == .compact ? 30 : 40, weight: .bold, design: .rounded))
                                    .padding()
                            }
                            Text("When you tap an icon that is on your Sheet, Daysy will speak the name of the icon out loud. Try it below!")
                                .minimumScaleFactor(0.01)
                                .multilineTextAlignment(.center)
                                .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                                .foregroundColor(Color(.systemGray))
                            Spacer()
                            Button(action:{
                                speechSynthesizer.speak("hello")
                            }) {
                                Image("hello")
                                    .resizable()
                                    .frame(width: 300, height: 300)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(lineWidth: 15)
                                            .foregroundColor(.primary)
                                    )
                            }
                            .padding()
                            Spacer()
                            Text("\(Image(systemName: "speaker.wave.3")) Make sure your volume is up!")
                                .minimumScaleFactor(0.01)
                                .multilineTextAlignment(.center)
                                .font(.system(size: horizontalSizeClass == .compact ? 20 : 30, weight: .bold, design: .rounded))
                                .foregroundColor(.orange)
                            Spacer()
                        }
                        .padding()
                    }
                    .sheet(isPresented: $showEmpty) { //empty slots detail view
                        VStack {
                            HStack {
                                Image(systemName: "rectangle.stack")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.01)
                                    .font(.system(size: horizontalSizeClass == .compact ? 30 : 40, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(.systemGray))
                                Text("Organize Slots")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.01)
                                    .font(.system(size: horizontalSizeClass == .compact ? 30 : 40, weight: .bold, design: .rounded))
                                    .padding()
                            }
                            if horizontalSizeClass == .compact {
                                Spacer()
                            }
                            Text("Daysy will automatically remove empty Slots from your Sheet, and organize the remaining icons.")
                                .minimumScaleFactor(0.01)
                                .multilineTextAlignment(.center)
                                .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                                .foregroundColor(Color(.systemGray))
                            Spacer()
                            if horizontalSizeClass != .compact {
                                HStack {
                                    Text("Try it: ")
                                        .minimumScaleFactor(0.01)
                                        .multilineTextAlignment(.center)
                                        .font(.system(size: 40, weight: .bold, design: .rounded))
                                        .padding()
                                    ZStack {
                                        Capsule()
                                            .frame(width: horizontalSizeClass == .compact ? 80 : 160,height: horizontalSizeClass == .compact ? 44 : 88)
                                            .foregroundColor(exampleEmptyOn ? .green : Color(.systemGray))
                                        ZStack{
                                            Circle()
                                                .frame(width: horizontalSizeClass == .compact ? 40 : 80, height: horizontalSizeClass == .compact ? 40 : 80)
                                                .foregroundColor(.white)
                                            Image(systemName: exampleEmptyOn ? "poweron" : "poweroff")
                                                .font( horizontalSizeClass == .compact ? Font.title3.weight(.black) : Font.largeTitle.weight(.black))
                                                .foregroundColor(Color(.systemGray))
                                        }
                                        .shadow(color: .black.opacity(0.14), radius: 4, x: 0, y: 2)
                                        .offset(x:exampleEmptyOn ? offSet : -offSet)
                                        .padding(horizontalSizeClass == .compact ? 0 : 24)
                                    }
                                    .onTapGesture {
                                        exampleEmptyOn.toggle()
                                        animate.toggle()
                                    }
                                }
                                Spacer()
                                if exampleEmptyOn {
                                    LazyVGrid(columns: Array(repeating: GridItem(), count: 5)) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color(.systemGray5))
                                                .scaledToFit()
                                            Text("Recess")
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.01)
                                                .font(.system(size: 300, weight: .bold, design: .rounded))
                                                .padding()
                                                .foregroundColor(.primary)
                                        }
                                        Image("putsockson")
                                            .resizable()
                                            .scaledToFit()
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(.black, lineWidth: 4)
                                            )
                                        Image("dog")
                                            .resizable()
                                            .scaledToFit()
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(.black, lineWidth: 4)
                                            )
                                        Image("cleanup")
                                            .resizable()
                                            .scaledToFit()
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(.black, lineWidth: 4)
                                            )
                                        Image(systemName: "square.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(Color(.clear))
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(exampleSlotOn ? .green : Color(.systemGray5))
                                                .scaledToFit()
                                            Text("Home")
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.01)
                                                .font(.system(size: 300, weight: .bold, design: .rounded))
                                                .padding()
                                                .foregroundColor(.primary)
                                        }
                                        Image("brownie")
                                            .resizable()
                                            .scaledToFit()
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(exampleSlotOn ? .green : .black, lineWidth: exampleSlotOn ? 7 : 4)
                                            )
                                        Image("eatlunch")
                                            .resizable()
                                            .scaledToFit()
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(exampleSlotOn ? .green : .black, lineWidth: exampleSlotOn ? 7 : 4)
                                            )
                                        Image(systemName: "square.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(Color(.clear))
                                        Image(systemName: "square.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(Color(.clear))
                                        ZStack {
                                            Text("")
                                        }
                                        Image(systemName: "square.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(Color(.clear))
                                        Image(systemName: "square.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(Color(.clear))
                                        Image(systemName: "square.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(Color(.clear))
                                        Image(systemName: "square.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(Color(.clear))
                                    }
                                } else {
                                    LazyVGrid(columns: Array(repeating: GridItem(), count: 5)) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color(.systemGray5))
                                                .scaledToFit()
                                            Text("Recess")
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.01)
                                                .font(.system(size: 300, weight: .bold, design: .rounded))
                                                .padding()
                                                .foregroundColor(.primary)
                                        }
                                        Image(systemName: "square.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(Color(.clear))
                                        Image("putsockson")
                                            .resizable()
                                            .scaledToFit()
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(.black, lineWidth: 4)
                                            )
                                        Image("dog")
                                            .resizable()
                                            .scaledToFit()
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(.black, lineWidth: 4)
                                            )
                                        Image("cleanup")
                                            .resizable()
                                            .scaledToFit()
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(.black, lineWidth: 4)
                                            )
                                        
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color(.systemGray5))
                                                .scaledToFit()
                                            Text("Afternoon")
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.01)
                                                .font(.system(size: 300, weight: .bold, design: .rounded))
                                                .padding()
                                                .foregroundColor(.primary)
                                        }
                                        Image(systemName: "square.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(Color(.clear))
                                        Image(systemName: "square.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(Color(.clear))
                                        Image(systemName: "square.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(Color(.clear))
                                        Image(systemName: "square.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(Color(.clear))
                                        
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(exampleSlotOn ? .green : Color(.systemGray5))
                                                .scaledToFit()
                                            Text("Home")
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.01)
                                                .font(.system(size: 300, weight: .bold, design: .rounded))
                                                .padding()
                                                .foregroundColor(.primary)
                                        }
                                        Image("brownie")
                                            .resizable()
                                            .scaledToFit()
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(exampleSlotOn ? .green : .black, lineWidth: exampleSlotOn ? 7 : 4)
                                            )
                                        Image(systemName: "square.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(Color(.clear))
                                        Image("eatlunch")
                                            .resizable()
                                            .scaledToFit()
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(exampleSlotOn ? .green : .black, lineWidth: exampleSlotOn ? 7 : 4)
                                            )
                                        Image(systemName: "square.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(Color(.clear))
                                    }
                                }
                                Spacer()
                            }
                        }
                        .padding()
                    }
                    .sheet(isPresented: $showCurrSlot) { //show curr timeslot detail view
                        VStack {
                            HStack {
                                Image(systemName: "rectangle.lefthalf.inset.filled.arrow.left")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.01)
                                    .font(.system(size: horizontalSizeClass == .compact ? 30 : 40, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(.systemGray))
                                Text("Show Current Timeslot")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.01)
                                    .font(.system(size: horizontalSizeClass == .compact ? 30 : 40, weight: .bold, design: .rounded))
                                    .padding()
                            }
                            Text("When viewing a sheet with Timeslots, Daysy will highlight the currently active Timeslot in green, making it easier to identify.")
                                .minimumScaleFactor(0.01)
                                .multilineTextAlignment(.center)
                                .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                                .foregroundColor(Color(.systemGray))
                            Spacer()
                            HStack {
                                Text("Try it: ")
                                    .minimumScaleFactor(0.01)
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 40, weight: .bold, design: .rounded))
                                    .padding()
                                ZStack {
                                    Capsule()
                                        .frame(width: horizontalSizeClass == .compact ? 80 : 160,height: horizontalSizeClass == .compact ? 44 : 88)
                                        .foregroundColor(exampleSlotOn ? .green : Color(.systemGray3))
                                    ZStack{
                                        Circle()
                                            .frame(width: horizontalSizeClass == .compact ? 40 : 80, height: horizontalSizeClass == .compact ? 40 : 80)
                                            .foregroundColor(.white)
                                        Image(systemName: exampleSlotOn ? "poweron" : "poweroff")
                                            .font( horizontalSizeClass == .compact ? Font.title3.weight(.black) : Font.largeTitle.weight(.black))
                                            .foregroundColor(Color(.systemGray))
                                    }
                                    .shadow(color: .black.opacity(0.14), radius: 4, x: 0, y: 2)
                                    //.offset(x:exampleEmptyOn ? (horizontalSizeClass == .compact ? 18 : -18) : (horizontalSizeClass == .compact ? offSet : -offSet))
                                    .offset(x:exampleSlotOn ? offSet : -offSet)
                                    .padding(horizontalSizeClass == .compact ? 0 : 24)
                                    .animation(.spring, value: animate)
                                }
                                .onTapGesture {
                                    exampleSlotOn.toggle()
                                    animate.toggle()
                                }
                            }
                            Spacer()
                            //Divider()
                            if horizontalSizeClass == .compact {
                                VStack {
                                    Text(getTime(date: getDateTwoHoursPrior(from: getCurrentTimeRoundedToHalfHour())))
                                        .lineLimit(1)
                                        .font(.system(size: 30, weight: .bold, design: .rounded))
                                        .padding(.top)
                                    LazyVGrid(columns: Array(repeating: GridItem(), count: 2)) {
                                        Image("eatlunch")
                                            .resizable()
                                            .scaledToFit()
                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(.black, lineWidth: 6)
                                            )
                                            .padding()
                                        
                                        Image("brownie")
                                            .resizable()
                                            .scaledToFit()
                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(.black, lineWidth: 6)
                                            )
                                            .padding()
                                        
                                        Image("playground")
                                            .resizable()
                                            .scaledToFit()
                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(.black, lineWidth: 6)
                                            )
                                            .padding()
                                        
                                        Image("school")
                                            .resizable()
                                            .scaledToFit()
                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(.black, lineWidth: 6)
                                            )
                                            .padding()
                                    }
                                }
                                .background(exampleSlotOn ? .green : Color(.systemGray5))
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .padding([.leading, .trailing])
                                .padding([.leading, .trailing])
                            } else {
                                LazyVGrid(columns: Array(repeating: GridItem(), count: 5)) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color(.systemGray5))
                                            .scaledToFit()
                                        Text(getTime(date: getDateTwoHoursPrior(from: getCurrentTimeRoundedToHalfHour())))
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.01)
                                            .font(.system(size: 300, weight: .bold, design: .rounded))
                                            .padding()
                                            .foregroundColor(.primary)
                                    }
                                    Image("putsockson")
                                        .resizable()
                                        .scaledToFit()
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(.black, lineWidth: 4)
                                        )
                                    Image("dog")
                                        .resizable()
                                        .scaledToFit()
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(.black, lineWidth: 4)
                                        )
                                    Image("lunch")
                                        .resizable()
                                        .scaledToFit()
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(.black, lineWidth: 4)
                                        )
                                    Image("cleanup")
                                        .resizable()
                                        .scaledToFit()
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(.black, lineWidth: 4)
                                        )
                                    
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(exampleSlotOn ? .green : Color(.systemGray5))
                                            .scaledToFit()
                                        Text(getTime(date: getCurrentTimeRoundedToHalfHour()))
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.01)
                                            .font(.system(size: 300, weight: .bold, design: .rounded))
                                            .padding()
                                            .foregroundColor(.primary)
                                            .shadow(color: exampleSlotOn ? Color(.systemBackground) : Color.clear, radius: 5)
                                    }
                                    Image("eatlunch")
                                        .resizable()
                                        .scaledToFit()
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(exampleSlotOn ? .green : .black, lineWidth: exampleSlotOn ? 7 : 4)
                                        )
                                    Image("brownie")
                                        .resizable()
                                        .scaledToFit()
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(exampleSlotOn ? .green : .black, lineWidth: exampleSlotOn ? 7 : 4)
                                        )
                                    Image("playground")
                                        .resizable()
                                        .scaledToFit()
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(exampleSlotOn ? .green : .black, lineWidth: exampleSlotOn ? 7 : 4)
                                        )
                                    Image("school")
                                        .resizable()
                                        .scaledToFit()
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(exampleSlotOn ? .green : .black, lineWidth: exampleSlotOn ? 7 : 4)
                                        )
                                }
                                //Divider()
                            }
                            Spacer()
                        }
                        .padding()
                    }
                }
                .padding([.leading, .trailing])
                //.scrollIndicators(.hidden)
                .ignoresSafeArea(.all)
                .animation(.default, value: animate)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        HStack { //bottom row of buttons for settings
                            if horizontalSizeClass != .compact {
                                Button(action: {
                                    self.presentation.wrappedValue.dismiss()
                                    onDismiss()
                                }) {
                                    Text("\(Image(systemName: "arrow.backward")) Back")
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.1)
                                        .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)
                                        .padding()
                                        .padding()
                                        .background(Color(.systemGray5))
                                        .cornerRadius(25)
                                }
                                .padding()
                            }
                            NavigationLink(destination: TimeslotView()) {
                                Text("\(Image(systemName: "book")) Tutorial")
                                    .lineLimit(1)
                                    .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                    .padding(horizontalSizeClass == .compact ? 20 : 30)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(horizontalSizeClass == .compact ? 15 : 25)
                            }
                            .padding(horizontalSizeClass == .compact ? [.leading, .trailing] : [.top, .bottom, .leading, .trailing], 10)
                            .navigationViewStyle(StackNavigationViewStyle())
                            .navigationBarHidden(true)
                            
                            if horizontalSizeClass != .compact {
                                NavigationLink(destination: StatisticsView()) {
                                    Text("\(Image(systemName: "chart.bar.xaxis")) Statistics")
                                        .lineLimit(1)
                                    //.minimumScaleFactor(0.1)
                                        .font(.system(size: horizontalSizeClass == .compact ? 20 : 25, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)
                                        .padding(horizontalSizeClass == .compact ? 20 : 30)
                                        .background(Color(.systemGray5))
                                        .cornerRadius(horizontalSizeClass == .compact ? 15 : 25)
                                }
                                .padding(horizontalSizeClass == .compact ? [.leading, .trailing] : [.top, .bottom, .leading, .trailing], 10)
                            }
                        }
                        .navigationViewStyle(StackNavigationViewStyle())
                        .navigationBarHidden(true)
                        Spacer()
                    }
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color(.systemBackground).opacity(1), Color(.systemBackground).opacity(1),  Color.clear.opacity(0)]), startPoint: .bottom, endPoint: .top)
                            .ignoresSafeArea()
                    )
                }
                .fullScreenCover(isPresented: $debugView) { //just for me ;)
                    DebugView()
                }
                .sheet(isPresented: $showCustomPassword) { //set and/or verify custom password if bioauth and password not set
                    if buttonsOn {
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
                                    .font(.title)
                                //.fontWeight(.semibold)
                                    .foregroundColor(password != "" ? .green : .clear)
                                    .onTapGesture {
                                        if password == customPassword {
                                            buttonsOn.toggle()
                                            defaults.set(buttonsOn, forKey: "buttonsOn")
                                            animate.toggle()
                                            showCustomPassword = false
                                            mismatch = false
                                            password = ""
                                        } else {
                                            mismatch = true
                                            password = ""
                                        }
                                    }
                                NumberButton(number: 0, password: $password)
                                    .foregroundColor(.primary)
                                    .padding()
                                Image(systemName: "delete.left")
                                    .font(.title)
                                //.fontWeight(.semibold)
                                    .foregroundColor(.red)
                                    .onTapGesture {
                                        if !password.isEmpty {
                                            password.removeLast()
                                        }
                                    }
                            }
                            .frame(width: 400)
                            Spacer()
                        }
                    } else {
                        if !showVerify {
                            VStack {
                                Spacer()
                                if mismatch {
                                    Text("Passwords Do Not Match")
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.01)
                                        .font(.system(size: 30, weight: .bold, design: .rounded))
                                        .foregroundColor(.red)
                                        .padding()
                                }
                                Text("Create A Password")
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
                                        .font(.title)
                                    //.fontWeight(.semibold)
                                        .foregroundColor(password != "" ? .green : .clear)
                                        .onTapGesture {
                                            showVerify = true
                                        }
                                    NumberButton(number: 0, password: $password)
                                        .foregroundColor(.primary)
                                        .padding()
                                    Image(systemName: "delete.left")
                                        .font(.title)
                                    //.fontWeight(.semibold)
                                        .foregroundColor(.red)
                                        .onTapGesture {
                                            if !password.isEmpty {
                                                password.removeLast()
                                            }
                                        }
                                }
                                .frame(width: 400)
                                Spacer()
                            }
                            .padding()
                            .animation(.spring, value: true)
                        } else {
                            VStack {
                                Spacer()
                                Text("Enter Your Password Again")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.01)
                                    .font(.system(size: 30, weight: .bold, design: .rounded))
                                    .padding()
                                
                                SecureField("Verify Password", text: $verifyPassword)
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
                                        NumberButton(number: number, password: $verifyPassword)
                                            .foregroundColor(.primary)
                                            .padding()
                                    }
                                    Image(systemName: "checkmark")
                                        .font(.title)
                                    //.fontWeight(.semibold)
                                        .foregroundColor(.green)
                                        .onTapGesture {
                                            if password == verifyPassword {
                                                defaults.set(password, forKey: "customPassword")
                                                currSessionLog.append("Custom Password Set: \(password)")
                                                showCustomPassword = false
                                                buttonsOn.toggle()
                                                defaults.set(buttonsOn, forKey: "buttonsOn")
                                                animate.toggle()
                                                
                                            } else {
                                                currSessionLog.append("Passwords do not match, resetting")
                                                mismatch = true
                                                password = ""
                                                verifyPassword = ""
                                                showVerify = false
                                            }
                                        }
                                    NumberButton(number: 0, password: $verifyPassword)
                                        .foregroundColor(.primary)
                                        .padding()
                                    Image(systemName: "delete.left")
                                        .font(.title)
                                    //.fontWeight(.semibold)
                                        .foregroundColor(.red)
                                        .onTapGesture {
                                            if !verifyPassword.isEmpty {
                                                verifyPassword.removeLast()
                                            }
                                        }
                                }
                                .frame(width: 400)
                                Spacer()
                            }
                            .padding()
                            .animation(.spring, value: true)
                        }
                    }
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .navigationBarHidden(true)
            .padding(.top)
            //put sheets here
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarHidden(true)
    }
    
    private func authenticateWithBiometrics() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let biometryType = context.biometryType
            let localizedReason: String
            
            switch biometryType {
            case .touchID:
                localizedReason = "Touch ID Required to change Lock Buttons"
            case .faceID:
                localizedReason = "Face ID Required to change Lock Buttons"
            default:
                localizedReason = "Biometrics Required to change Lock Buttons"
            }
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: localizedReason) { success, evaluateError in
                DispatchQueue.main.async {
                    if success {
                        buttonsOn.toggle()
                        defaults.set(buttonsOn, forKey: "buttonsOn")
                        animate.toggle()
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
    private func authenticateWithPasscode(){
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Password Required to change Lock Buttons") { success, evaluateError in
                DispatchQueue.main.async {
                    if success {
                        buttonsOn.toggle()
                        defaults.set(buttonsOn, forKey: "buttonsOn")
                        animate.toggle()
                    }
                }
            }
        } else {
            // Device authentication not available, handle the error accordingly
            currSessionLog.append("device password not available")
        }
    }
}

struct CustomToggleStyle: ToggleStyle { //for the custom toggle switches
    var size: CGSize = CGSize(width: 50, height: 30)
    
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            RoundedRectangle(cornerRadius: size.height / 2)
                .fill(configuration.isOn ? Color.green : Color(.systemGray))
                .frame(width: size.width, height: size.height)
                .overlay(
                    RoundedRectangle(cornerRadius: size.height / 2)
                        .stroke(Color.white, lineWidth: 4)
                )
        }
    }
}

#Preview {
    SettingsView(onDismiss: {})
}
