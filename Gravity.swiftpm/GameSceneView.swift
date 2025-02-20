import SceneKit

class GravityScene: SCNScene, SCNSceneRendererDelegate, SCNPhysicsContactDelegate {
    var ballNode: SCNNode!
    var floorNode: SCNNode!
    var startTime: TimeInterval?
    var fallTimeCallback: ((Double) -> Void)?
    
    override init() {
        super.init()
        setupSkybox()
        setupScene(planet: "Earth", mass: 1.0, height: 5.0, gravity: 9.8)
        
        // Set physics contact delegate
        physicsWorld.contactDelegate = self
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Set skybox background
    private func setupSkybox() {
        let skyboxImages = ["front", "front", "front", "front", "front", "front"]
        self.background.contents = skyboxImages.map { UIImage(named: $0) }
    }
    
    // Setup scene
    func setupScene(planet: String, mass: Double, height: Double, gravity: CGFloat) {
        rootNode.childNodes.forEach { $0.removeFromParentNode() }
        
        // Create planet surface
        let planetTexture = UIImage(named: planet)
        floorNode = SCNNode(geometry: SCNSphere(radius: 2.0))
        floorNode.geometry?.firstMaterial?.diffuse.contents = planetTexture
        floorNode.position = SCNVector3(0, -3, 0)
        
        // Add physics to floor
        let floorPhysics = SCNPhysicsBody(type: .static, shape: nil)
        floorPhysics.categoryBitMask = 2
        floorPhysics.contactTestBitMask = 1
        floorNode.physicsBody = floorPhysics
        
        rootNode.addChildNode(floorNode)
        
        // Create falling object
        ballNode = SCNNode(geometry: SCNSphere(radius: 0.5))
        ballNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Ball")
        ballNode.position = SCNVector3(0, Float(height), 0)
        
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        physicsBody.mass = CGFloat(mass)
        physicsBody.isAffectedByGravity = false
        physicsBody.categoryBitMask = 1
        physicsBody.contactTestBitMask = 2
        physicsBody.collisionBitMask = 2
        ballNode.physicsBody = physicsBody
        
        rootNode.addChildNode(ballNode)
        
        physicsWorld.gravity = SCNVector3(0, -gravity, 0)
    }
    
    /// Drop object and measure time
    func dropObject(gravity: CGFloat, completion: @escaping (Double) -> Void) {
        physicsWorld.gravity = SCNVector3(0, -gravity, 0)
        ballNode.physicsBody?.isAffectedByGravity = true
        startTime = nil
        fallTimeCallback = completion  // ✅ Store the callback correctly
    }


    
    // Detect when ball hits the surface
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        if (contact.nodeA == ballNode && contact.nodeB == floorNode) || (contact.nodeA == floorNode && contact.nodeB == ballNode) {
            
            // Stop the ball on impact
            ballNode.physicsBody?.velocity = SCNVector3(0, 0, 0)
            ballNode.physicsBody?.angularVelocity = SCNVector4(0, 0, 0, 0)
            ballNode.physicsBody?.isAffectedByGravity = false
            
            // Create impact effect
            if let explosion = SCNParticleSystem(named: "Explosion.scnp", inDirectory: nil) {
                let explosionNode = SCNNode()
                explosionNode.position = contact.contactPoint
                explosionNode.addParticleSystem(explosion)
                rootNode.addChildNode(explosionNode)
            } else {
                print("⚠️ Explosion particle system not found! Using fallback effect.")
                
                let fallbackEffect = SCNParticleSystem()
                fallbackEffect.loops = false
                fallbackEffect.birthRate = 200
                fallbackEffect.particleColor = .systemOrange
                fallbackEffect.particleSize = 0.2
                fallbackEffect.emissionDuration = 0.2
                let fallbackNode = SCNNode()
                fallbackNode.position = contact.contactPoint
                fallbackNode.addParticleSystem(fallbackEffect)
                rootNode.addChildNode(fallbackNode)
            }

        }
    }

    // Ball falling time calculation
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if let start = startTime {
            // Check if the ball has hit the surface
            if ballNode.presentation.position.y <= floorNode.presentation.position.y + 0.5 {
                let fallTime = time - start
                startTime = nil  // Reset startTime
                
                // Stop the ball
                ballNode.physicsBody?.velocity = SCNVector3(0, 0, 0)
                ballNode.physicsBody?.angularVelocity = SCNVector4(0, 0, 0, 0)
                ballNode.physicsBody = nil

                // Call the fall time callback **only after collision**
                DispatchQueue.main.async {
                    self.fallTimeCallback?(fallTime)  // ✅ Ensure callback is executed
                }
            }
        } else if ballNode.physicsBody?.isAffectedByGravity == true {
            startTime = time  // ✅ Start timing when the ball begins falling
        }
    }




}
