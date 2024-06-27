//
//  FaceMeshView.swift
//  Daysy
//
//  Created by Alexander Eischeid on 6/27/24.
//

import SwiftUI
import UIKit
import SceneKit
import ARKit

enum ExpressionType: Equatable {
    case positive(String)
    case negative(String)
    case undetermined
    
    static func ==(lhs: ExpressionType, rhs: ExpressionType) -> Bool {
        switch (lhs, rhs) {
        case (.positive(let leftExpression), .positive(let rightExpression)):
            return leftExpression == rightExpression
        case (.negative(let leftExpression), .negative(let rightExpression)):
            return leftExpression == rightExpression
        case (.undetermined, .undetermined):
            return true
        default:
            return false
        }
    }
}

struct FaceMeshView: View {
    
    @State var analysis: String = " "
    @State var expressionType: ExpressionType = .undetermined
    @State var animate = false
    
    @State private var elapsedTime: TimeInterval = 0
    let maxTime: TimeInterval = 1
    @State private var timer = Timer.publish(every: 0.01, on: .main, in: .default).autoconnect()
    @State private var resetSignal = UUID()
    
    var body: some View {
        VStack {
            Text(analysis)
                .font(.headline)
                .foregroundStyle(expressionColor)
                .lineLimit(1)
            ProgressView(value: clampedProgress)
                .progressViewStyle(LinearProgressViewStyle())
                .tint(expressionColor)
            BridgeView(analysis: $analysis, expressionType: $expressionType)
        }
        .onReceive(timer) { _ in
            if self.elapsedTime < maxTime {
                self.elapsedTime += 0.01
            }
        }
        .onChange(of: expressionType, perform: { _ in
            animate.toggle()
            self.restartTimer()
        })
        .onChange(of: analysis, perform: { _ in
            animate.toggle()
        })
        .animation(.spring, value: animate)
    }
    private func resetTimer() {
        self.elapsedTime = 0
        self.resetSignal = UUID()
    }
    
    private func restartTimer() {
        self.timer.upstream.connect().cancel()
        self.timer = Timer.publish(every: 0.01, on: .main, in: .default).autoconnect()
        self.elapsedTime = 0
    }
    private var clampedProgress: Double {
        let progress = elapsedTime / maxTime
        if expressionType == .undetermined {
            return 0
        }
        return min(max(progress, 0), 1)
    }
    private var expressionColor: Color {
        switch expressionType {
        case .positive( _):
            return .green
        case .negative( _):
            return .red
        case .undetermined:
            return .primary
        }
    }
}

struct BridgeView: UIViewControllerRepresentable {
    @Binding var analysis: String
    @Binding var expressionType: ExpressionType
    
    func makeUIViewController(context: Context) -> some UIViewController {
        print("BridgeView makeUIViewController")
        
        let storyBoard: UIStoryboard = UIStoryboard(name:"Main", bundle:nil);
        let viewCtl = storyBoard.instantiateViewController(withIdentifier: "main") as! ViewController;
        
        print("BridgeView viewCtl", viewCtl)
        
        viewCtl.reportChange = {
            // print("reportChange")
            analysis = viewCtl.analysis
            expressionType = viewCtl.expressionType
        }
        return viewCtl
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        // print("BridgeView updateUIViewController")
    }
}

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var faceLabel: UILabel!
    @IBOutlet weak var labelView: UIView!
    var analysis = " "
    var expressionType: ExpressionType = .undetermined
    var reportChange: (() -> Void)!
    
    override func viewDidLoad() {
        print("ViewController viewDidLoad")
        super.viewDidLoad()
        
        labelView.layer.cornerRadius = 10
        
        sceneView.delegate = self
        sceneView.showsStatistics = true
        guard ARFaceTrackingConfiguration.isSupported else {
            print("Face tracking is not supported on this device")
            return
        }
        
        // Disable UIKit label in Main.storyboard
        labelView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("ViewController viewWillAppear")
        
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARFaceTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("ViewController viewWillDisappear")
        
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let faceMesh = ARSCNFaceGeometry(device: sceneView.device!)
        let node = SCNNode(geometry: faceMesh)
        node.geometry?.firstMaterial?.fillMode = .lines
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let faceAnchor = anchor as? ARFaceAnchor, let faceGeometry = node.geometry as? ARSCNFaceGeometry {
            faceGeometry.update(from: faceAnchor.geometry)
            expression(anchor: faceAnchor)
            
            switch expressionType {
            case .positive( _):
                withAnimation(.spring) { faceGeometry.firstMaterial?.diffuse.contents = UIColor.green }
            case .negative( _):
                withAnimation(.spring) { faceGeometry.firstMaterial?.diffuse.contents = UIColor.red }
            case .undetermined:
                withAnimation(.spring) { faceGeometry.firstMaterial?.diffuse.contents = UIColor.white }
            }
            
            DispatchQueue.main.async {
                // Disable UIKit label in Main.storyboard
                // self.faceLabel.text = self.analysis
                // Report changes to SwiftUI code
                self.reportChange()
            }
            
        }
    }
    
    func expression(anchor: ARFaceAnchor) {
        let blendShapes = anchor.blendShapes
        
        let smileLeft = blendShapes[.mouthSmileLeft]
        let smileRight = blendShapes[.mouthSmileRight]
        let cheekPuff = blendShapes[.cheekPuff]
        let tongue = blendShapes[.tongueOut]
        let browInnerUp = blendShapes[.browInnerUp]
        let browOuterUpLeft = blendShapes[.browOuterUpLeft]
        let browOuterUpRight = blendShapes[.browOuterUpRight]
        let eyeBlinkLeft = blendShapes[.eyeBlinkLeft]
        let eyeBlinkRight = blendShapes[.eyeBlinkRight]
        let jawOpen = blendShapes[.jawOpen]
        let mouthFunnel = blendShapes[.mouthFunnel]
        let mouthPucker = blendShapes[.mouthPucker]
        let mouthLeft = blendShapes[.mouthLeft]
        let mouthRight = blendShapes[.mouthRight]
        let noseSneerLeft = blendShapes[.noseSneerLeft]
        let noseSneerRight = blendShapes[.noseSneerRight]
        let eyeLookDownLeft = blendShapes[.eyeLookDownLeft]
        let eyeLookInLeft = blendShapes[.eyeLookInLeft]
        let eyeLookOutLeft = blendShapes[.eyeLookOutLeft]
        let eyeLookUpLeft = blendShapes[.eyeLookUpLeft]
        let eyeSquintLeft = blendShapes[.eyeSquintLeft]
        let eyeWideLeft = blendShapes[.eyeWideLeft]
        let eyeLookDownRight = blendShapes[.eyeLookDownRight]
        let eyeLookInRight = blendShapes[.eyeLookInRight]
        let eyeLookOutRight = blendShapes[.eyeLookOutRight]
        let eyeLookUpRight = blendShapes[.eyeLookUpRight]
        let eyeSquintRight = blendShapes[.eyeSquintRight]
        let eyeWideRight = blendShapes[.eyeWideRight]
        let jawForward = blendShapes[.jawForward]
        let jawLeft = blendShapes[.jawLeft]
        let jawRight = blendShapes[.jawRight]
        let mouthClose = blendShapes[.mouthClose]
        let mouthFrownLeft = blendShapes[.mouthFrownLeft]
        let mouthFrownRight = blendShapes[.mouthFrownRight]
        let mouthDimpleLeft = blendShapes[.mouthDimpleLeft]
        let mouthDimpleRight = blendShapes[.mouthDimpleRight]
        let mouthStretchLeft = blendShapes[.mouthStretchLeft]
        let mouthStretchRight = blendShapes[.mouthStretchRight]
        let mouthRollLower = blendShapes[.mouthRollLower]
        let mouthRollUpper = blendShapes[.mouthRollUpper]
        let mouthShrugLower = blendShapes[.mouthShrugLower]
        let mouthShrugUpper = blendShapes[.mouthShrugUpper]
        let mouthPressLeft = blendShapes[.mouthPressLeft]
        let mouthPressRight = blendShapes[.mouthPressRight]
        let mouthLowerDownLeft = blendShapes[.mouthLowerDownLeft]
        let mouthLowerDownRight = blendShapes[.mouthLowerDownRight]
        let mouthUpperUpLeft = blendShapes[.mouthUpperUpLeft]
        let mouthUpperUpRight = blendShapes[.mouthUpperUpRight]
        let browDownLeft = blendShapes[.browDownLeft]
        let browDownRight = blendShapes[.browDownRight]
        let cheekSquintLeft = blendShapes[.cheekSquintLeft]
        let cheekSquintRight = blendShapes[.cheekSquintRight]
        
        self.analysis = " "
        self.expressionType = .undetermined
        
        if ((smileLeft?.decimalValue ?? 0.0) + (smileRight?.decimalValue ?? 0.0)) > 0.5 {
            self.analysis += "You are smiling. "
            self.expressionType = .positive("smile")
        }
        
        if cheekPuff?.decimalValue ?? 0.0 > 0.25 {
            self.analysis += "Your cheeks are puffed. "
            self.expressionType = .undetermined
        }
        
        if tongue?.decimalValue ?? 0.0 > 0.5 {
            self.analysis += "Don't stick your tongue out! "
            self.expressionType = .undetermined
        }
        
        if (browOuterUpLeft?.decimalValue ?? 0.0 > 0.25) || (browOuterUpRight?.decimalValue ?? 0.0 > 0.25) || browInnerUp?.decimalValue ?? 0.0 > 0.5 {
            self.analysis += "Your brows are raised. "
            self.expressionType = .undetermined
        }
        
        if jawOpen?.decimalValue ?? 0.0 > 0.25 {
            self.analysis += "Your jaw is open. "
            self.expressionType = .undetermined
        }
//        
        if mouthFunnel?.decimalValue ?? 0.0 > 0.5 {
            self.analysis += "Your mouth is in a funnel shape. "
        self.expressionType = .undetermined
        }
        
        if mouthPucker?.decimalValue ?? 0.0 > 0.5 {
            self.analysis += "Your lips are puckered. "
            self.expressionType = .undetermined
        }
        
        if mouthLeft?.decimalValue ?? 0.0 > 0.15 {
            self.analysis += "Your mouth is moved to the left. "
            self.expressionType = .undetermined
        }
        
        if mouthRight?.decimalValue ?? 0.0 > 0.15 {
            self.analysis += "Your mouth is moved to the right. "
            self.expressionType = .undetermined
        }
        
        if (noseSneerLeft?.decimalValue ?? 0.0 > 0.15) || (noseSneerRight?.decimalValue ?? 0.0 > 0.15) {
            self.analysis += "You are sneering. "
            if case .positive = self.expressionType {
                //for now do nothing because we don't want to override smile
            } else {
                self.expressionType = .negative("sneer")
            }
        }
        
        if (eyeBlinkLeft?.decimalValue ?? 0.0 > 0.9) || (eyeBlinkRight?.decimalValue ?? 0.0 > 0.9) {
            self.analysis += "You are blinking. "
            self.expressionType = .undetermined
        }
        
        if (eyeLookDownLeft?.decimalValue ?? 0.0 > 0.5) || (eyeLookDownRight?.decimalValue ?? 0.0 > 0.5) {
            self.analysis += "You are looking down. "
            self.expressionType = .undetermined
        }
        
        if (eyeLookInLeft?.decimalValue ?? 0.0 > 0.5) || (eyeLookInRight?.decimalValue ?? 0.0 > 0.5) {
            self.analysis += "You are looking inward. "
            self.expressionType = .undetermined
        }
        
        if (eyeLookOutLeft?.decimalValue ?? 0.0 > 0.5) || (eyeLookOutRight?.decimalValue ?? 0.0 > 0.5) {
            self.analysis += "You are looking outward. "
            self.expressionType = .undetermined
        }
        
        if (eyeLookUpLeft?.decimalValue ?? 0.0 > 0.5) || (eyeLookUpRight?.decimalValue ?? 0.0 > 0.5) {
            self.analysis += "You are looking up. "
            self.expressionType = .undetermined
        }
        
        if (eyeSquintLeft?.decimalValue ?? 0.0 > 0.5) || (eyeSquintRight?.decimalValue ?? 0.0 > 0.5) {
            self.analysis += "You are squinting. "
            self.expressionType = .undetermined
        }
        
        if (eyeWideLeft?.decimalValue ?? 0.0 > 0.9) || (eyeWideRight?.decimalValue ?? 0.0 > 0.9) {
            self.analysis += "Your eyes are wide open. "
            self.expressionType = .undetermined
        }
        
        if jawForward?.decimalValue ?? 0.0 > 0.5 {
            self.analysis += "Your jaw is moved forward. "
            self.expressionType = .undetermined
        }
        
        if (jawLeft?.decimalValue ?? 0.0 > 0.9) || (jawRight?.decimalValue ?? 0.0 > 0.9) {
            self.analysis += "Your jaw is moving left or right. "
            self.expressionType = .undetermined
        }
        
        if mouthClose?.decimalValue ?? 0.0 > 0.15 {
            self.analysis += "Your mouth is closed. "
            self.expressionType = .undetermined
        }
        
        if (mouthFrownLeft?.decimalValue ?? 0.0 > 0.25) || (mouthFrownRight?.decimalValue ?? 0.0 > 0.25) {
            self.analysis += "Your mouth is frowning. "
            self.expressionType = .negative("frown")
        }
        
        if (mouthDimpleLeft?.decimalValue ?? 0.0 > 0.5) || (mouthDimpleRight?.decimalValue ?? 0.0 > 0.5) {
            self.analysis += "You have dimples on your mouth. "
            self.expressionType = .undetermined
        }
        
        if (mouthStretchLeft?.decimalValue ?? 0.0 > 0.5) || (mouthStretchRight?.decimalValue ?? 0.0 > 0.5) {
            self.analysis += "Your mouth is stretched. "
            self.expressionType = .undetermined
        }
        
        if (mouthRollLower?.decimalValue ?? 0.0 > 0.5) || (mouthRollUpper?.decimalValue ?? 0.0 > 0.5) {
            self.analysis += "Your mouth is rolling. "
            self.expressionType = .undetermined
        }
        
        if (mouthShrugLower?.decimalValue ?? 0.0 > 0.5) || (mouthShrugUpper?.decimalValue ?? 0.0 > 0.5) {
            self.analysis += "You are shrugging your mouth. "
            if case .positive = self.expressionType {
                //for now do nothing because we don't want to override smile
            } else {
                self.expressionType = .negative("shrug")
            }
        }
        
        if (mouthPressLeft?.decimalValue ?? 0.0 > 0.5) || (mouthPressRight?.decimalValue ?? 0.0 > 0.5) {
            self.analysis += "You are pressing your mouth to the left or right. "
        }
        
        if (mouthLowerDownLeft?.decimalValue ?? 0.0 > 0.5) || (mouthLowerDownRight?.decimalValue ?? 0.0 > 0.5) {
            self.analysis += "Your lower mouth is moving down. "
        }
        
        if (mouthUpperUpLeft?.decimalValue ?? 0.0 > 0.5) || (mouthUpperUpRight?.decimalValue ?? 0.0 > 0.5) {
            self.analysis += "Your upper mouth is moving up. "
        }
        
        if (browDownLeft?.decimalValue ?? 0.0 > 0.75) || (browDownRight?.decimalValue ?? 0.0 > 0.75) {
            self.analysis += "Your brows are moving down. "
            self.expressionType = .negative("brows down")
        }
        
        if (cheekSquintLeft?.decimalValue ?? 0.0 > 0.5) || (cheekSquintRight?.decimalValue ?? 0.0 > 0.5) {
            self.analysis += "Your cheeks are squinting. "
        }
    }
}
