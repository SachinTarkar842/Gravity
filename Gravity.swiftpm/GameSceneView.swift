import SceneKit

class GravityScene: SCNScene, SCNPhysicsContactDelegate {
    var ballNode: SCNNode!
    var floorNode: SCNNode!
    var fallTimeCallback: ((Double) -> Void)?
    
    override init() {
        super.init()
        setupSkybox()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Set skybox background
    private func setupSkybox() {
        let skyboxImages = ["front", "front", "front", "front", "front", "front"]
        self.background.contents = skyboxImages.map { UIImage(named: $0) }
    }
    
    // Setup scene with planet surface and object
    func setupScene(planet: String, mass: Double, height: Double, gravity: CGFloat) {
        rootNode.childNodes.forEach { $0.removeFromParentNode() }
        
        // Create planet surface
        let planetTexture = UIImage(named: planet)
        floorNode = SCNNode(geometry: SCNSphere(radius: 2.0))
        floorNode.geometry?.firstMaterial?.diffuse.contents = planetTexture
        floorNode.position = SCNVector3(0, -3, 0)

        // Add physics to floor
        let floorPhysics = SCNPhysicsBody(type: .static, shape: nil)
        floorNode.physicsBody = floorPhysics
        rootNode.addChildNode(floorNode)
        
        // Create falling object
        ballNode = SCNNode(geometry: SCNSphere(radius: 0.5))
        ballNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Ball")
        ballNode.position = SCNVector3(0, Float(height), 0)
        
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        physicsBody.mass = CGFloat(mass)
        physicsBody.isAffectedByGravity = false
        ballNode.physicsBody = physicsBody
        
        rootNode.addChildNode(ballNode)
    }
    
    /// Drop object and calculate fall time based on physics formula: t = sqrt(2h/g)
    func dropObject(height: Double, gravity: CGFloat, completion: @escaping (Double) -> Void) {
        let fallTime = sqrt((2 * height) / Double(gravity))  // Using physics formula
        fallTimeCallback = completion
        ballNode.physicsBody?.isAffectedByGravity = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + fallTime) {
            
            self.ballNode.physicsBody?.velocity = SCNVector3(0, 0, 0)
            self.ballNode.physicsBody?.angularVelocity = SCNVector4(0, 0, 0, 0)
            self.ballNode.physicsBody?.isAffectedByGravity = false
            self.fallTimeCallback?(fallTime)
        }
    }
}
