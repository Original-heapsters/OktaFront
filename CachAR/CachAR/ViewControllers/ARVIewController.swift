//
//  ARViewController.swift
//  CachAR
//
//  Created by Andrew Briare on 4/28/18.
//  Copyright © 2018 Andrew Briare. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ARViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var textViewStatus: UILabel!
    @IBOutlet weak var buttonSignIn: UIButton!

    var selectedPlane: VirtualPlane?
    var trackingState: ARCamera.TrackingState!
    var mainObjectScene: SCNScene!
    var mainObjectNode: SCNNode!

    var centerScreenPosition: CGPoint!
    var userPlacedObject: Bool = false

    var planes = [UUID: VirtualPlane]() {
        didSet {
            if planes.count > 0 {
                currentARStatus = .ready
            } else {
                if currentARStatus == .ready { currentARStatus = .initialized }
            }
        }
    }

    var currentARStatus = ARState.initializing {
        didSet {
            DispatchQueue.main.async {
                self.textViewStatus.text = self.currentARStatus.description
            }
            if currentARStatus == .failed {
                cleanupARSession()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        textViewStatus.numberOfLines = 0

        let screenSize = UIScreen.main.bounds.size
        centerScreenPosition = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)

        // Set the view's delegate
        sceneView.delegate = self

        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.debugOptions = [
            ARSCNDebugOptions.showFeaturePoints
//            ARSCNDebugOptions.showWorldOrigin,
//            SCNDebugOptions.showConstraints
        ]
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true

        // Create a new scene
        let scene = SCNScene()

        // Set the scene to the view
        sceneView.scene = scene

        mainObjectScene = SCNScene(named: "art.scnassets/ship.scn")
        mainObjectNode = mainObjectScene.rootNode.childNode(withName: "shipMesh", recursively: true)
        sceneView.scene.rootNode.addChildNode(mainObjectNode)

        // This will add an object to the camera node and will stick there
//        sceneView.pointOfView?.addChildNode(mainObjectScene.rootNode)

        // This starts an infinite rotation animation on a node
        let action = SCNAction.rotateBy(x: 0, y: CGFloat(2 * Double.pi), z: 0, duration: 10)
        let repAction = SCNAction.repeatForever(action)
        mainObjectNode?.runAction(repAction, forKey: "myrotate")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        configuration.isLightEstimationEnabled = true

        // Run the view's session
        sceneView.session.run(configuration)
        if planes.count > 0 { self.currentARStatus = .initialized }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Pause the view's session
        sceneView.session.pause()
        self.currentARStatus = .temporarilyUnavailable
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate

    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        return node
    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        let hits = sceneView.hitTest(centerScreenPosition, types: ARHitTestResult.ResultType.estimatedHorizontalPlane)
        if hits.count > 0, let firstHit = hits.first {
            self.currentARStatus = .ready
            if !userPlacedObject {
                mainObjectNode.position = SCNVector3Make(
                    firstHit.worldTransform.columns.3.x,
                    firstHit.worldTransform.columns.3.y,
                    firstHit.worldTransform.columns.3.z
                )
            }
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let arPlaneAnchor = anchor as? ARPlaneAnchor {
            let plane = VirtualPlane(anchor: arPlaneAnchor)
            self.planes[arPlaneAnchor.identifier] = plane

            // This adds the debug anchor node plane to the scene for visualization
//            node.addChildNode(plane)
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let arPlaneAnchor = anchor as? ARPlaneAnchor, let plane = planes[arPlaneAnchor.identifier] {
            plane.updateWithNewAnchor(arPlaneAnchor)
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        if let arPlaneAnchor = anchor as? ARPlaneAnchor, let index = planes.index(forKey: arPlaneAnchor.identifier) {
            planes.remove(at: index)
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {

    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        currentARStatus = .failed
    }

    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        trackingState = camera.trackingState
    }

    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        print("Session interupted!")
    }

    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        print("Session interupted ended!")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            print("Can't identify touch. Ignoring")
            return
        }

        if currentARStatus != .ready {
            print("AR is not ready yet...")
            return
        }

        self.placeObject()

        //This will place an object where you touch
        /*
        let touchPoint = touch.location(in: sceneView)
        let hits = sceneView.hitTest(touchPoint, types: ARHitTestResult.ResultType.estimatedHorizontalPlane)
        if hits.count > 0, let firstHit = hits.first {
            if let newObjectNode = mainObjectNode?.clone() {
                newObjectNode.position = SCNVector3Make(firstHit.worldTransform.columns.3.x, firstHit.worldTransform.columns.3.y, firstHit.worldTransform.columns.3.z)
                sceneView.scene.rootNode.addChildNode(newObjectNode)
            }
        }
        */
    }

    func placeObject() {
        userPlacedObject = true
    }

    func cleanupARSession() {
        sceneView.scene.rootNode.enumerateChildNodes { (node, _) -> Void in
            node.removeFromParentNode()
        }
    }
}
