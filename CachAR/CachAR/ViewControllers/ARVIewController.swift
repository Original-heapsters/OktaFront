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
import OktaAuth
import CoreLocation
import SwiftyJSON

class ARViewController: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate, oktaDelegate, backendDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var textViewStatus: UILabel!
    @IBOutlet weak var buttonSignIn: UIButton!
    @IBOutlet weak var assetMarker: AssetMarker!

    let locationManager = CLLocationManager()
    var userLocation: Geolocation = Geolocation(lat: 0, long: 0)
    var objectLocation: Geolocation = Geolocation(lat: 0, long: 0)
    let cacheBack = CacheBack()

    var selectedPlane: VirtualPlane?
    var trackingState: ARCamera.TrackingState!
    var mainObjectScene: SCNScene!
    var mainObjectNode: SCNNode!
    var currentUser: User?
    var currentAsset: Asset?

    var centerScreenPosition: CGPoint!

    @IBAction func startRedirect(_ sender: Any) {
        triggerLogin()
    }

    @IBAction func getUser(_ sender: Any) {
        self.cacheBack.checkLogin {

            OktaAuth.userinfo {
                response, error in

                if error != nil { print("Error: \(error!)") }

                if let userinfo = response {
                    let info = JSON(userinfo)

                    let fullName = info["name"].stringValue
                    var fullNameArr = fullName.components(separatedBy: " ")
                    let firstName = fullNameArr[0]
                    let lastName = fullNameArr[1]
                    let userId = firstName + "-" + lastName
                    self.cacheBack.getUser(userId, notify: { message in
                        let alert = UIAlertController(title: "response", message: message, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    })
                }
            }
        }
    }

    @IBAction func placeAsset(_ sender: Any) {
        self.cacheBack.checkLogin {

            OktaAuth.userinfo {
                response, error in

                if error != nil { print("Error: \(error!)") }

                if let userinfo = response {
                    let info = JSON(userinfo)

                    let fullName = info["name"].stringValue
                    var fullNameArr = fullName.components(separatedBy: " ")
                    let firstName = fullNameArr[0]
                    let lastName = fullNameArr[1]
                    let userId = firstName + "-" + lastName
                    let assetURL = URL.init(fileURLWithPath: Bundle.main.path(forResource: "companion_cube", ofType: "scn", inDirectory: "art.scnassets", forLocalization: nil)!)
                    self.cacheBack.placeAsset(userId, assetURL, String(self.objectLocation.latitude), String(self.objectLocation.longitude), notify: { message in
                        let alert = UIAlertController(title: "response", message: message, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    })
                }
            }
        }
    }
    @IBAction func getNearby(_ sender: Any) {
        self.cacheBack.checkLogin {
            let radius = self.currentUser?.radiusSettings ?? "20"
            let latlon = "\(self.userLocation.latitude),\(self.userLocation.longitude)"
            self.cacheBack.getNearbyAssets(radius, latlon)
        }
    }
    @IBAction func foundAsset(_ sender: Any) {
        self.cacheBack.checkLogin {
            let assetId = self.currentAsset?.id ?? ""
            self.cacheBack.getAsset(assetId, notify: { message in
                let alert = UIAlertController(title: "response", message: message, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            })
        }
    }
    @IBAction func markAsset(_ sender: Any) {
        self.cacheBack.checkLogin {
            OktaAuth.userinfo {
                response, error in

                if error != nil { print("Error: \(error!)") }

                if let userinfo = response {
                    let info = JSON(userinfo)

                    let fullName = info["name"].stringValue
                    var fullNameArr = fullName.components(separatedBy: " ")
                    let firstName = fullNameArr[0]
                    let lastName = fullNameArr[1]
                    let userId = firstName + "-" + lastName
                    let assetId = self.currentAsset?.id ?? ""
                    self.cacheBack.markAsset(assetId, userId, "", notify: { message in
                        let alert = UIAlertController(title: "response", message: message, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    })
                }
            }

        }
    }

    func nearbyListFetched(list: [Asset]) {

    }

    func currentUserUpdated(user: User) {
        self.currentUser = user
    }

    func currentAssetUpdated(asset: Asset) {
        self.currentAsset = asset
    }

    func triggerLogin() {
        OktaAuth
            .login()
            .start(self) { response, error in
                if error != nil { print(error!) }

                // Success
                if let tokenResponse = response {
                    OktaAuth.tokens?.set(value: tokenResponse.accessToken!, forKey: "accessToken")
                    OktaAuth.tokens?.set(value: tokenResponse.idToken!, forKey: "idToken")
                    OktaAuth.tokens?.set(value: tokenResponse.refreshToken!, forKey: "refreshToken")
                    self.buttonSignIn.isHidden = true
                }
        }
    }
    @IBAction func postUser(_ sender: Any) {
        self.cacheBack.checkLogin {

            OktaAuth.userinfo {
                response, error in

                if error != nil { print("Error: \(error!)") }

                if let userinfo = response {
                    let info = JSON(userinfo)

                    let fullName = info["name"].stringValue
                    var fullNameArr = fullName.components(separatedBy: " ")
                    let firstName = fullNameArr[0]
                    let lastName = fullNameArr[1]
                    let userId = firstName + "-" + lastName
                    self.cacheBack.postUser(userId, firstName, lastName, notify: { message in
                        let alert = UIAlertController(title: "response", message: message, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    })
                }
            }
        }
    }

    var objectPlacedInWorld: Bool = false
    var planes = [UUID: VirtualPlane]() {
        didSet {
            if planes.count > 0 {
                currentARStatus = .ready
            } else {
                if currentARStatus == .ready { currentARStatus = .initialized }
            }
        }
    }

    var currentARStatus: ARState! {
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
        self.cacheBack.setup()
        self.cacheBack.backDelegate = self
        self.cacheBack.delegate = self
        textViewStatus.numberOfLines = 0
        currentARStatus = .initializing

        let screenSize = UIScreen.main.bounds.size
        centerScreenPosition = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)

        // Set the view's delegate
        sceneView.delegate = self

        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.debugOptions = [
            ARSCNDebugOptions.showFeaturePoints
//            ARSCNDebugOptions.showWorldOrigin
//            SCNDebugOptions.showConstraints
        ]
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true

        // Create a new scene
        let scene = SCNScene()

        // Set the scene to the view
        sceneView.scene = scene

        mainObjectScene = SCNScene(named: "art.scnassets/companion_cube.scn")
        mainObjectNode = mainObjectScene.rootNode.childNode(withName: "parent", recursively: true)
        sceneView.scene.rootNode.addChildNode(mainObjectNode)

        // This will add an object to the camera node and will stick there
//        sceneView.pointOfView?.addChildNode(mainObjectScene.rootNode)

        // This starts an infinite rotation animation on a node
        let action = SCNAction.rotateBy(x: 0, y: CGFloat(2 * Double.pi), z: 0, duration: 10)
        let repAction = SCNAction.repeatForever(action)
        mainObjectNode?.runAction(repAction, forKey: "myrotate")

        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()

        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }

//        assetMarker.tableView.register(UINib(nibName: "MarkedAssetTableViewCell", bundle: nil), forCellReuseIdentifier: MarkedAssetTableViewCell.identifier)
//        assetMarker.tableView.delegate = self
//        assetMarker.tableView.dataSource = self
        assetMarker.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        configuration.isLightEstimationEnabled = true
        configuration.worldAlignment = .gravityAndHeading

        // Run the view's session
        sceneView.session.run(configuration)
        if planes.count > 0 { self.currentARStatus = .ready }
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

    // MARK: - Location Delegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        userLocation.latitude = locValue.latitude
        userLocation.longitude = locValue.longitude
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
            if !objectPlacedInWorld {
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

    // MARK : Touch

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            print("Can't identify touch. Ignoring")
            return
        }

        switch currentARStatus {
        case .initializing, .initialized, .temporarilyUnavailable, .failed:
            print("AR unable to react...")

        case .ready:
            self.objectPlaced()

        case .objectPlaced:
            let viewTouchLocation: CGPoint = touch.location(in: sceneView)
            guard let result = sceneView.hitTest(viewTouchLocation, options: nil).first else {
                return
            }

            if (mainObjectNode?.contains(result.node))! {
                self.objectClicked(object: mainObjectNode)
            }

        default:
            break
        }

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

    func cleanupARSession() {
        sceneView.scene.rootNode.enumerateChildNodes { (node, _) -> Void in
            node.removeFromParentNode()
        }
    }

    // MARK : User Events

    func objectClicked(object: SCNNode) {

    }

    func objectPlaced() {
        currentARStatus = .objectPlaced

        let cameraPosition = getCameraPosition()
        let objectPosition = mainObjectNode.position
        print("Position of media:    \(String(describing: objectPosition))")
        print("Position of camera:   \(String(describing: cameraPosition))")
        print("Geolocation of user:  \(userLocation.description)")

        let xDifferenceMeters = Double(objectPosition.x - cameraPosition.x)
        let zDifferenceMeters = Double(objectPosition.z - cameraPosition.z)
        print("Distance between x:   \(xDifferenceMeters)m")
        print("Distance between y:   \(zDifferenceMeters)m")

        let distanceBetweenCameraAndObject = MathHelpers.CGPointDistance(from: CGPoint(x: CGFloat(objectPosition.x), y: CGFloat(objectPosition.z)), to: CGPoint(x: CGFloat(cameraPosition.x), y: CGFloat(cameraPosition.z)))
        print("Distance between:     \(distanceBetweenCameraAndObject)m")

        let objectGeolocation = Geolocation(geolocation: userLocation)
        objectGeolocation.applyOffset(x: xDifferenceMeters, y: zDifferenceMeters)

        objectPlacedInWorld = true
        print("**** END OF GRABBING INITIAL COORDS ****")

        self.placeAsset(0)

//        placeObjectInWorld(objectLocation: objectGeolocation)
    }

    func placeObjectInWorld(objectLocation: Geolocation) {
        print("**** START OF SETTING SERVER COORDS ****")
        let cameraPosition = getCameraPosition()

        let distance = MathHelpers.distance(lat1: userLocation.latitude, lon1: userLocation.longitude, lat2: objectLocation.latitude, lon2: objectLocation.longitude)
        print("Acquired distance:    \(distance)m")

        let differenceInLat = (userLocation.latitude - objectLocation.latitude) * 111000 * -1
        let differenceInLong = (userLocation.longitude - objectLocation.longitude) * 111321 * -1
        print("New X:                \(differenceInLat)m")
        print("New Y:                \(differenceInLong)m")

        mainObjectNode.position = SCNVector3.init(x: Float(differenceInLat), y: mainObjectNode.position.y, z: Float(differenceInLong))
    }

    func getCameraPosition() -> SCNVector3 {
        guard let pointOfView = sceneView.pointOfView else { return SCNVector3() }
        let transform = pointOfView.transform
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        return location
    }

    // MARK: Table view delegates

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: MarkedAssetTableViewCell.identifier, for: indexPath)

        return cell
    }
}
