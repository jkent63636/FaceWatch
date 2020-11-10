//
//  ViewController.swift
//  FaceWatch
//
//  Created by Joshua Kent on 11/9/20.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var facialMovementLabel: UILabel!
    
    //string of movements
    var facialMovementDescription = ""
    
    //face geometry. Global variable made to turn mesh on/off
    var faceGeo: ARSCNFaceGeometry?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        //sceneView.showsStatistics = true
        
        //curve label corners
        facialMovementLabel.layer.cornerRadius = 10
        
        guard ARFaceTrackingConfiguration.isSupported else {
            fatalError("Face tracking is not supported on this device")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARFaceTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let faceMesh = ARSCNFaceGeometry(device: sceneView.device!)
        let node = SCNNode(geometry: faceMesh)
        node.geometry?.firstMaterial?.fillMode = .lines

        return node
    }
    
    //This updates the AR
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let faceAnchor = anchor as? ARFaceAnchor, let faceGeometry = node.geometry as? ARSCNFaceGeometry {
            
            faceGeo = faceGeometry
            
            //updates face mesh
            faceGeometry.update(from: faceAnchor.geometry)
                
            //calls expression function to determine facial expressions
            expression(anchor: faceAnchor)
        
            DispatchQueue.main.async {
                self.facialMovementLabel.text = self.facialMovementDescription
            }
        }
    }

    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func expression(anchor: ARFaceAnchor) {
        let smileLeft = anchor.blendShapes[.mouthSmileLeft]
        let smileRight = anchor.blendShapes[.mouthSmileRight]
        let cheekPuff = anchor.blendShapes[.cheekPuff]
        let tongue = anchor.blendShapes[.tongueOut]
        let blinkLeft = anchor.blendShapes[.eyeBlinkLeft]
        let blinkRight = anchor.blendShapes[.eyeBlinkRight]
        
        facialMovementDescription = ""
     
        if ((smileLeft?.decimalValue ?? 0.0) + (smileRight?.decimalValue ?? 0.0)) > 0.9 {
            if !facialMovementDescription.isEmpty {
                facialMovementDescription += "\n"
            }
            facialMovementDescription += "Smiling"
        }
     
        if cheekPuff?.decimalValue ?? 0.0 > 0.1 {
            if !facialMovementDescription.isEmpty {
                facialMovementDescription += "\n"
            }
            facialMovementDescription += "Cheeks Puffed"
        }
     
        if tongue?.decimalValue ?? 0.0 > 0.1 {
            if !facialMovementDescription.isEmpty {
                facialMovementDescription += "\n"
            }
            facialMovementDescription += "Tongue Out"
        }
        
        //actually right eye
        if blinkLeft?.decimalValue ?? 0.0 > 0.6 {
            if !facialMovementDescription.isEmpty {
                facialMovementDescription += "\n"
            }
            facialMovementDescription += "Your Right Eye Blink"
        }

        //actually left eye
        if blinkRight?.decimalValue ?? 0.0 > 0.6 {
            if !facialMovementDescription.isEmpty {
                facialMovementDescription += "\n"
            }
            facialMovementDescription += "Your Left Eye Blink"
        }
    }
    
    //turns face mesh on and off based on switch
    @IBAction func faceMeshSwitch(_ sender: UISwitch) {
        if sender.isOn {
            faceGeo?.firstMaterial?.transparency = 100
        } else {
            faceGeo?.firstMaterial?.transparency = 0
        }
    }
    
}
