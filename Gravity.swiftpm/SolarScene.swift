import SwiftUI
import SceneKit
import Foundation

class SolarScene {
    let scene: SCNScene
    let camera: SCNNode
    let viewOptions: SceneView.Options
    var bodies: [CelestialBody] = []
    var focusOnBody: Bool
    var focusIndex: Int
    var gameloop : Timer? = nil
    var counter: Double = 0
    var trails: Bool
    var velocityArrows: Bool
    var gravitationalConstant: CGFloat
    var inputBodies: [BodyDefiner]
    var allowCameraControl: Bool
    var cameraTransform: SCNVector3 = SCNVector3(0, 0, 0)
    var showTexture: Bool = true
    
    
    struct CelestialBody {
        var internalName: String
        var mass: CGFloat
        var radius: CGFloat
        var initialVelocity: SCNVector3
        var currentVelocity: SCNVector3?
        var initialPosition: SCNVector3
        var color: UIColor
        var planetBody: SCNNode?
        var internalScene: SCNScene
        let gravitationalConstant: CGFloat
        var velocityArrow: SCNNode? = nil
        let velocityArrows: Bool
        var nameLabel: SCNNode? // Add a label to display the name
        
        mutating func initial() {
            currentVelocity = initialVelocity
            let object = SCNSphere(radius: radius)
            let material = object.firstMaterial!
            
            if ["Earth", "Sun", "Moon", "Mars", "Mercury", "Venus", "Jupiter", "Saturn", "Uranus"].contains(internalName) {
                material.diffuse.contents = UIImage(named: internalName)
            } else {
                material.diffuse.contents = color
            }
            
            let body = SCNNode(geometry: object)
            body.name = "planet_" + internalName + "_" + "\(mass)"
            body.position = initialPosition
            
//            // Apply the bloom filter only to the Sun body (not the name)
//            if internalName == "Sun" {
//                body.filters = addBloom() // Keep the bloom filter on the Sun body
//            }
            
            planetBody = body
            
            // Add a name label above the planet
            let textGeometry = SCNText(string: internalName, extrusionDepth: 1)
            textGeometry.font = UIFont.systemFont(ofSize: 8)
            textGeometry.firstMaterial?.diffuse.contents = UIColor.white
            
            nameLabel = SCNNode(geometry: textGeometry)
            nameLabel?.position = SCNVector3(0, radius + 5, 0) // Position above the planet
            
            // Apply a billboard constraint to make the name label always face the camera
            let billboardConstraint = SCNBillboardConstraint()
            nameLabel?.constraints = [billboardConstraint]
            
            planetBody?.addChildNode(nameLabel!) // Add name label as a child of the planet node
            
            if self.velocityArrows {
                let normalised = currentVelocity?.normalized ?? SCNVector3(0, 0, 0)
                velocityArrow = lineBetweenNodes(positionA: (returnPosition(timeStep: 1) + currentVelocity! * 6) + (normalised * radius), positionB: returnPosition(timeStep: 1), inScene: internalScene, parentPosition: body.position)
                body.addChildNode(velocityArrow!)
            }
            
            internalScene.rootNode.addChildNode(body)
        }

        
        mutating func updateVelocity(timeStep: Double) {
            for otherBody in internalScene.rootNode.childNodes(passingTest: {
                (node, stop) -> Bool in
                return (node.name?.components(separatedBy: "_")[0] == "planet") && (node.name?.components(separatedBy: "_")[1] != internalName)
            }) {
                let sqrDst: CGFloat = sqrMagnitude(point: (otherBody.position - self.planetBody!.position))
                let forceDir: SCNVector3 = (otherBody.position - self.planetBody!.position).normalized
                let otherBodyMass = CGFloat(Double(otherBody.name?.components(separatedBy: "_")[2] ?? "0") ?? 0)
                let force: SCNVector3 = forceDir * gravitationalConstant * (self.mass * otherBodyMass) / sqrDst
                let acceleration: SCNVector3 = force / self.mass
                currentVelocity = currentVelocity! + (acceleration * timeStep)
            }
        }
        
        mutating func updatePosition(timeStep: Double, focusBody: CelestialBody? = nil) {
            self.planetBody!.position = self.planetBody!.position + (currentVelocity! * timeStep) - (focusBody?.returnPosition(timeStep: timeStep) ?? SCNVector3(0, 0, 0)) + (focusBody?.initialPosition ?? SCNVector3(0, 0, 0))
            
            // Keep the name label above the planet as it moves
            nameLabel?.position = SCNVector3(0, radius + 5, 0) // Maintain relative position above the planet
        }
        
        func returnPosition(timeStep: Double) -> SCNVector3 {
            return (self.planetBody!.position + (currentVelocity! * timeStep))
        }
    }
    
    init(focusOnBody: Bool, focusIndex: Int, trails: Bool, velocityArrows: Bool, gravitationalConstant: CGFloat, inputBodies: [BodyDefiner], allowCameraControl: Bool, cameraTransform: SCNVector3 = SCNVector3(0, 0, 0), showTexture: Bool = true) {
        self.focusOnBody = focusOnBody
        self.focusIndex = focusIndex
        self.trails = trails
        self.velocityArrows = velocityArrows
        self.gravitationalConstant = gravitationalConstant
        self.inputBodies = inputBodies
        self.allowCameraControl = allowCameraControl
        self.cameraTransform = cameraTransform
        self.showTexture = showTexture
        
        //create the stuff for SceneView
        scene = SCNScene()
        
        camera = SCNNode()
        camera.camera = SCNCamera()
        camera.camera?.zFar = 1500
        camera.position = SCNVector3(x: 0, y: 0, z: 400)
        
        if allowCameraControl {
            viewOptions = [
                .allowsCameraControl,
                .autoenablesDefaultLighting,
                .temporalAntialiasingEnabled
            ]
        } else {
            viewOptions = [
                .autoenablesDefaultLighting,
                .temporalAntialiasingEnabled
            ]
        }
        
        //set up the scene object
        if showTexture {
            scene.background.contents = [UIImage(named: "right"),
                                         UIImage(named: "left"),
                                         UIImage(named: "top"),
                                         UIImage(named: "bottom"),
                                         UIImage(named: "front"),
                                         UIImage(named: "back")]
        } else {
            scene.background.contents = UIColor.black
        }
        
        for body in inputBodies {
            bodies.append(
                CelestialBody(internalName: body.name, mass: body.mass, radius: body.mass, initialVelocity: body.velocity, initialPosition: body.position, color: body.color, internalScene: scene, gravitationalConstant: gravitationalConstant, velocityArrows: velocityArrows)
            )
        }
        
        if bodies.count != 0 {
            for i in 0...bodies.count - 1 {
                bodies[i].initial()
            }
            
            camera.look(at: bodies[focusIndex].planetBody!.position)
        }
        
        if trails {
            showTrails()
        }
        
        camera.position = camera.position + cameraTransform
    }
    
    func startLoop() {
        gameloop = Timer.scheduledTimer(withTimeInterval: 0.015, repeats: true) { [self] (_) in
            for i in 0...self.bodies.count - 1 {
                self.bodies[i].updateVelocity(timeStep: self.counter)
            }
            
            for i in 0...self.bodies.count - 1 {
                if self.focusOnBody {
                    self.bodies[i].updatePosition(timeStep: self.counter, focusBody: self.bodies[self.focusIndex])
                } else {
                    self.bodies[i].updatePosition(timeStep: self.counter)
                }
                
                let internalBody: CelestialBody = self.bodies[i]
                
                self.bodies[i].planetBody?.childNode(withName: "velocityArrow", recursively: true)?.removeFromParentNode()
                
                if velocityArrows {
                    let internalBodyPosition = internalBody.planetBody?.position ?? SCNVector3(0, 0, 0)
                    let internalBodyCurrentVelocity = internalBody.currentVelocity ?? SCNVector3(0, 0, 0)
                    
                    self.bodies[i].planetBody?.addChildNode(
                        lineBetweenNodes(
                            positionA: internalBodyPosition,
                            positionB: (internalBodyPosition + internalBodyCurrentVelocity * 6) + (internalBodyCurrentVelocity.normalized * internalBody.radius),
                            inScene: self.scene,
                            parentPosition: internalBodyPosition
                        )
                    )
                }
            }
            
            self.counter = 1.25 * sqrt(self.counter) + 0.01
        }
    }
    
    func pauseLoop() {
        gameloop?.invalidate()
        gameloop = nil
        counter = 0
    }
    
    func hideTrails() {
        for body in scene.rootNode.childNodes(passingTest: {
            (node, stop) -> Bool in
            return (node.name?.components(separatedBy: "_")[0] == "planet")
        }) {
            body.removeAllParticleSystems()
        }
    }
    
    func showTrails() {
        for body in scene.rootNode.childNodes(passingTest: {
            (node, stop) -> Bool in
            return (node.name?.components(separatedBy: "_")[0] == "planet")
        }) {
            let bodyStruct = bodies.first(where: { (internalBody) in
                internalBody.internalName == body.name?.components(separatedBy: "_")[1]
            })
            
            let trail = SCNParticleSystem()
            trail.birthRate = 10000
            trail.particleSize = 0.1
            trail.particleColor = bodyStruct?.color.withAlphaComponent(0.1) ?? UIColor(.blue)
            trail.emitterShape = SCNSphere(radius: 0.2)
            trail.particleLifeSpan = 8
            trail.particleLifeSpanVariation = 1.0
            body.addParticleSystem(trail)
        }
    }
    
    func loadNewBodies() {
        let difference = inputBodies.count - bodies.count
        let initialAmount = bodies.count
        
        for body in inputBodies {
            bodies.append(
                CelestialBody(internalName: body.name, mass: body.mass, radius: body.mass, initialVelocity: body.velocity, initialPosition: body.position, color: body.color, internalScene: scene, gravitationalConstant: gravitationalConstant, velocityArrows: velocityArrows)
            )
        }
        
        if bodies.count != 0 {
            for i in initialAmount...difference - 1 {
                bodies[i].initial()
            }
            
            camera.look(at: bodies[focusIndex].planetBody!.position)
        }
        
        if trails {
            showTrails()
        }
    }
}
