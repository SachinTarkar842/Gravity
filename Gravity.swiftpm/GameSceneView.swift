import SceneKit

class GravityScene: SCNScene, SCNSceneRendererDelegate {
    var ballNode: SCNNode!
    var floorNode: SCNNode!
    var startTime: TimeInterval?
    var fallTimeCallback: ((Double) -> Void)?
    
    override init() {
        super.init()
        setupSkybox()
        setupScene(planet: "Earth", mass: 1.0, height: 5.0, gravity: 9.8)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // set background of scene
    private func setupSkybox() {
        let skyboxImages = ["front", "front", "front", "front", "front", "front"]
        self.background.contents = skyboxImages.map { UIImage(named: $0) }
    }
    
    // setup scene
    func setupScene(planet: String, mass: Double, height: Double, gravity: CGFloat) {
        rootNode.childNodes.forEach { $0.removeFromParentNode() }
        
        // planet surface
        let planetTexture = UIImage(named: planet)
        floorNode = SCNNode(geometry: SCNSphere(radius: 2.0))
        floorNode.geometry?.firstMaterial?.diffuse.contents = planetTexture
        floorNode.position = SCNVector3(0, -3, 0)
        rootNode.addChildNode(floorNode)
        
        // fall object creation
        ballNode = SCNNode(geometry: SCNSphere(radius: 0.5))
        ballNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Ball")
        ballNode.position = SCNVector3(0, Float(height), 0)
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        physicsBody.mass = CGFloat(mass)
        physicsBody.isAffectedByGravity = false
        ballNode.physicsBody = physicsBody
        rootNode.addChildNode(ballNode)
        
        physicsWorld.gravity = SCNVector3(0, -gravity, 0)
    }
    
    /// Drop object and measure time
    func dropObject(gravity: CGFloat, completion: @escaping (Double) -> Void) {
        physicsWorld.gravity = SCNVector3(0, -gravity, 0)
        ballNode.physicsBody?.isAffectedByGravity = true
        startTime = nil
        fallTimeCallback = completion
    }
    
    // ball hit surface
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if let start = startTime {
            if ballNode.presentation.position.y <= floorNode.presentation.position.y + 0.5 {
                let fallTime = time - start
                fallTimeCallback?(fallTime)
                startTime = nil
                
                // stop ball
                ballNode.physicsBody?.velocity = SCNVector3(0, 0, 0)
                ballNode.physicsBody?.angularVelocity = SCNVector4(0, 0, 0, 0)
                ballNode.physicsBody = nil
            }
        } else if ballNode.physicsBody?.isAffectedByGravity == true {
            startTime = time
        }
    }

}
