
import SwiftUI
import SceneKit
import Foundation


struct Simulation: View {
    
    @State var solarscene = SolarScene(
        focusOnBody: false,
        focusIndex: 0,
        trails: false,
        velocityArrows: false,
        gravitationalConstant: 1,
        inputBodies: [],
        allowCameraControl: true,
        showTexture: true
    )
    
    @State private var sideButtonsX: CGFloat = 100
    @State private var sideButtonsOpacity: CGFloat = 0
    @State private var sideButtonsExpanded: Bool = false
    @State private var isEditPresented: Bool = false
    @State private var isAddPresented: Bool = false
    @State private var isSettingsPresented: Bool = false
    @State private var isDeletePresented: Bool = false
    @State private var isRestartPresent: Bool = false
    @State private var isHelpActive: Bool = false
    @State private var isGameActive: Bool = false
    @State private var isAvailable: Bool = false
    @State var showSheet: Bool = false
    
    @State private var selectedBody: String = ""
    @State private var selectedBodyName: String = ""
    @State private var selectedBodyMass: String = ""
    @State private var selectedBodyColour: Color = .accentColor
    
    @State private var selectedBodyVelocityX: String = ""
    @State private var selectedBodyVelocityY: String = ""
    @State private var selectedBodyVelocityZ: String = ""
    
    @State private var selectedBodyPositionX: String = ""
    @State private var selectedBodyPositionY: String = ""
    @State private var selectedBodyPositionZ: String = ""
    
   
    
    
    
    @State private var availableBodies: [String] = []
    @State private var focusOnBody: Bool = false
    @State private var showTrails: Bool = false
    @State private var showVelocityArrows: Bool = false
    @State private var gravitationalConstant: CGFloat = 1
    @State private var playing: Bool = false
    @State private var allBodies = ["Sun", "Mercury", "Venus", "Earth", "Moon", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune"]
    
    
    var startingFocusOnBody: Bool
    var startingShowTrails: Bool
    var startingShowVelocityArrows: Bool
    var startingGravitationalConstant: CGFloat
    var startingFocusIndex: Int
    var startingBodies: [BodyDefiner]
    var showUI: Bool
    var allowCameraControl: Bool
    var showTexture: Bool = true
    var cameraTransform: SCNVector3 = SCNVector3(0, 0, 0)
    
    var notAvailableBodies: [String] {
        allBodies.filter { !availableBodies.contains($0) }
    }
    
    
    
    init(startingFocusOnBody: Bool, startingShowTrails: Bool, startingShowVelocityArrows: Bool, startingGravitationalConstant: CGFloat, startingFocusIndex: Int, startingBodies: [BodyDefiner], showUI: Bool, allowCameraControl: Bool, cameraTransform: SCNVector3 = SCNVector3(0, 0, 0), showTexture: Bool = true) {
        self.startingFocusOnBody = startingFocusOnBody
        self.startingShowTrails = startingShowTrails
        self.startingShowVelocityArrows = startingShowVelocityArrows
        self.startingGravitationalConstant = startingGravitationalConstant
        self.startingFocusIndex = startingFocusIndex
        self.startingBodies = startingBodies
        self.showUI = showUI
        self.allowCameraControl = allowCameraControl
        self.cameraTransform = cameraTransform
        self.showTexture = showTexture
        
        solarscene.focusOnBody = startingFocusOnBody
        solarscene.focusIndex = startingFocusIndex
        solarscene.trails = startingShowTrails
        solarscene.velocityArrows = startingShowVelocityArrows
        solarscene.gravitationalConstant = gravitationalConstant
        solarscene.inputBodies = startingBodies
        solarscene.loadNewBodies()
    }
    
    var body: some View {
        if showUI {
            VStack {
                
                SceneView(
                    scene: solarscene.scene,
                    pointOfView: solarscene.camera,
                    options: solarscene.viewOptions
                )
                
                // help button
                .floatingActionButton(color: .clear, image: Image(systemName: "questionmark.circle").foregroundColor(.white), align: ButtonAlign.right, customY: -20, customX: 15, top: true) {
                    isHelpActive.toggle()
                }.sheet(isPresented: $isHelpActive) {
                    HelpView()
                }
               
                
                // delete all button
                .floatingActionButton(color: .accentColor, image: Image(systemName: "trash").foregroundColor(.white), align: ButtonAlign.right) {
                    isDeletePresented.toggle()
                }
                
                // restart button
                .floatingActionButton(color: .accentColor, image: Image(systemName: "arrow.clockwise").foregroundColor(.white), align: ButtonAlign.center, customX: -160) {
                    isRestartPresent.toggle()
                }
                
                
                // play and pause button
                .floatingActionButton(color: .accentColor, image: Image(systemName: playing ? "pause.fill" : "play.fill").foregroundColor(.white), align: ButtonAlign.centre) {
                    if solarscene.bodies.count > 0 {
                        if solarscene.counter == 0 {
                            solarscene.startLoop()
                        } else {
                            solarscene.pauseLoop()
                        }
                    }
                    playing.toggle()
                }
                
                // settings button
                .floatingActionButton(color: .accentColor, image: Image(systemName: "gear").foregroundColor(.white), align: ButtonAlign.centre, customX: -80) {
                    availableBodies = solarscene.bodies.map({ (body) in
                        return body.internalName
                    })
                    
                    if availableBodies.count > 0 {
                        selectedBody = availableBodies[solarscene.focusIndex]
                    }
                    focusOnBody = solarscene.focusOnBody
                    showTrails = solarscene.trails
                    showVelocityArrows = solarscene.velocityArrows
                    gravitationalConstant = solarscene.gravitationalConstant
                    
                    isSettingsPresented.toggle()
                }
                
                // gravity game
                .floatingActionButton(color: .accentColor, image: Image(systemName: "scope").foregroundColor(.white), align: ButtonAlign.centre, customX: 160) {
                    isGameActive.toggle()
                }.fullScreenCover(isPresented: $isGameActive) {
                    GravityGameView()
                        
                }
                
                
                // edit button
                .floatingActionButton(color: .accentColor, image: Image(systemName: "pencil").foregroundColor(.white), align: ButtonAlign.centre, customX: 80) {
                    
                    availableBodies = solarscene.bodies.map({ (body) in
                        
                        return body.internalName
                    })
                    print(notAvailableBodies)
                    if availableBodies.count > 0 {
                        selectedBody = availableBodies[0]
                        selectedBodyName = selectedBody
                        selectedBodyMass = String(format: "%.2f", solarscene.bodies[0].mass)
                        selectedBodyColour = Color(solarscene.bodies[0].color)
                        
                        selectedBodyVelocityX = String(format: "%.2f", solarscene.bodies[0].initialVelocity.x)
                        selectedBodyVelocityY = String(format: "%.2f", solarscene.bodies[0].initialVelocity.y)
                        selectedBodyVelocityZ = String(format: "%.2f", solarscene.bodies[0].initialVelocity.z)
                        
                        selectedBodyPositionX = String(format: "%.2f", solarscene.bodies[0].initialPosition.x)
                        selectedBodyPositionY = String(format: "%.2f", solarscene.bodies[0].initialPosition.y)
                        selectedBodyPositionZ = String(format: "%.2f", solarscene.bodies[0].initialPosition.z)
                    }
                    
                    isEditPresented.toggle()
                }
                
                
                // Edit Button Slideover
                .slideOverCard(isPresented: $isEditPresented) {
                    VStack {
                        Group {
                            Text("Edit Bodies:")
                                .fontWeight(.bold)
                                .font(.title)
                            
                            Text("Please choose a body")
                                .font(.subheadline)
                                .padding(.top)
                            
                            Picker("Please choose a body", selection: $selectedBody) {
                                ForEach(availableBodies + ["New..."], id: \.self) {
                                    Text($0)
                                }
                            }
                            .onChange(of: selectedBody) { newValue in
                                if newValue == "New..." {
                                    showSheet = true 
                                } else {
                                    let index = availableBodies.firstIndex(of: selectedBody) ?? 0
                                    selectedBodyName = newValue
                                    selectedBodyMass = String(format: "%.2f", solarscene.bodies[index].mass)
                                    selectedBodyColour = Color(solarscene.bodies[index].color)
                                    
                                    selectedBodyVelocityX = String(format: "%.2f", solarscene.bodies[index].initialVelocity.x)
                                    selectedBodyVelocityY = String(format: "%.2f", solarscene.bodies[index].initialVelocity.y)
                                    selectedBodyVelocityZ = String(format: "%.2f", solarscene.bodies[index].initialVelocity.z)
                                    
                                    selectedBodyPositionX = String(format: "%.2f", solarscene.bodies[index].initialPosition.x)
                                    selectedBodyPositionY = String(format: "%.2f", solarscene.bodies[index].initialPosition.y)
                                    selectedBodyPositionZ = String(format: "%.2f", solarscene.bodies[index].initialPosition.z)
                                }
                            }
                            .sheet(isPresented: $showSheet) {
                                NavigationView {
                                    List(notAvailableBodies, id: \.self) { bodyName in
                                        Button(action: {
                                            selectedBodyName = bodyName
                                            
                                            switch selectedBodyName {
                                            case "Sun":
                                                selectedBodyMass = "20.0"
                                                selectedBodyColour = Color(UIColor.systemYellow)
                                                selectedBodyVelocityX = "0"
                                                selectedBodyVelocityY = "0"
                                                selectedBodyVelocityZ = "0"
                                                selectedBodyPositionX = "0"
                                                selectedBodyPositionY = "0"
                                                selectedBodyPositionZ = "0"
                                                
                                            case "Mercury":
                                                selectedBodyMass = "0.5"
                                                selectedBodyColour = Color(UIColor.systemGray)
                                                selectedBodyVelocityX = "-0.82"
                                                selectedBodyVelocityY = "0"
                                                selectedBodyVelocityZ = "0"
                                                selectedBodyPositionX = "3"
                                                selectedBodyPositionY = "-30"
                                                selectedBodyPositionZ = "0"
                                                
                                            case "Venus":
                                                selectedBodyMass = "0.8"
                                                selectedBodyColour = Color(UIColor.systemOrange)
                                                selectedBodyVelocityX = "-0.63"
                                                selectedBodyVelocityY = "0"
                                                selectedBodyVelocityZ = "0"
                                                selectedBodyPositionX = "-4"
                                                selectedBodyPositionY = "-50"
                                                selectedBodyPositionZ = "0"
                                                
                                            case "Earth":
                                                selectedBodyMass = "6.0"
                                                selectedBodyColour = Color(UIColor.systemGreen)
                                                selectedBodyVelocityX = "-0.65"
                                                selectedBodyVelocityY = "0"
                                                selectedBodyVelocityZ = "0"
                                                selectedBodyPositionX = "0"
                                                selectedBodyPositionY = "-70"
                                                selectedBodyPositionZ = "0"
                                                
                                            case "Moon":
                                                selectedBodyMass = "1.0"
                                                selectedBodyColour = Color(UIColor.systemBlue)
                                                selectedBodyVelocityX = "0"
                                                selectedBodyVelocityY = "0"
                                                selectedBodyVelocityZ = "0.025"
                                                selectedBodyPositionX = "0"
                                                selectedBodyPositionY = "-85"
                                                selectedBodyPositionZ = "0"
                                                
                                            case "Mars":
                                                selectedBodyMass = "5.0"
                                                selectedBodyColour = Color(UIColor.systemRed)
                                                selectedBodyVelocityX = "0.4"
                                                selectedBodyVelocityY = "0"
                                                selectedBodyVelocityZ = "0"
                                                selectedBodyPositionX = "0"
                                                selectedBodyPositionY = "-150"
                                                selectedBodyPositionZ = "0"
                                                
                                            case "Jupiter":
                                                selectedBodyMass = "10.0"
                                                selectedBodyColour = Color(UIColor.brown)
                                                selectedBodyVelocityX = "0.316"
                                                selectedBodyVelocityY = "0"
                                                selectedBodyVelocityZ = "0"
                                                selectedBodyPositionX = "8"
                                                selectedBodyPositionY = "-200"
                                                selectedBodyPositionZ = "0"
                                                
                                            case "Saturn":
                                                selectedBodyMass = "4.5"
                                                selectedBodyColour = Color(UIColor.systemTeal)
                                                selectedBodyVelocityX = "0.283"
                                                selectedBodyVelocityY = "0"
                                                selectedBodyVelocityZ = "0"
                                                selectedBodyPositionX = "-10"
                                                selectedBodyPositionY = "-250"
                                                selectedBodyPositionZ = "0"
                                                
                                            case "Uranus":
                                                selectedBodyMass = "3.0"
                                                selectedBodyColour = Color(UIColor.systemGreen)
                                                selectedBodyVelocityX = "0.26"
                                                selectedBodyVelocityY = "0"
                                                selectedBodyVelocityZ = "0"
                                                selectedBodyPositionX = "10"
                                                selectedBodyPositionY = "-300"
                                                selectedBodyPositionZ = "0"
                                                
                                            case "Neptune":
                                                selectedBodyMass = "3.0"
                                                selectedBodyColour = Color(UIColor.systemIndigo)
                                                selectedBodyVelocityX = "0.24"
                                                selectedBodyVelocityY = "0"
                                                selectedBodyVelocityZ = "0"
                                                selectedBodyPositionX = "-12"
                                                selectedBodyPositionY = "-350"
                                                selectedBodyPositionZ = "0"
                                                
                                            default:
                                                break
                                            }
                                            
                                            showSheet = false // Close sheet
                                        }) {
                                            Text(bodyName)
                                        }
                                    }
                                    .navigationTitle("Select Body")
                                    .navigationBarItems(trailing: Button("Cancel") {
                                        showSheet = false
                                    })
                                }
                            }
                            
                            
                            Divider()
                            
                            Group {
                                HStack {
                                    Text("Name:")
                                    
                                    TextField(selectedBodyName, text: $selectedBodyName)
                                        .textFieldStyle(.roundedBorder)
                                        .multilineTextAlignment(.center)
                                }
                                
                                
                                HStack {
                                    Text("Mass:")
                                    UIUnsignedInput(label: nil, binding: $selectedBodyMass, inputText: selectedBodyMass)
                                }
                                
                                ColorPicker("Body Colour:", selection: $selectedBodyColour, supportsOpacity: false)
                            }
                            
                            Group {
                                
                                Spacer()
                                    .frame(height: 20)
                                
                                HStack {
                                    Text("Velocity:")
                                    UISignedInput(label: "X", binding: $selectedBodyVelocityX, inputText: selectedBodyVelocityX)
                                    UISignedInput(label: "Y", binding: $selectedBodyVelocityY, inputText: selectedBodyVelocityY)
                                    UISignedInput(label: "Z", binding: $selectedBodyVelocityZ, inputText: selectedBodyVelocityZ)
                                }
                                
                                Spacer()
                                    .frame(height: 20)
                                
                                HStack {
                                    Text("Position:")
                                    UISignedInput(label: "X", binding: $selectedBodyPositionX, inputText: selectedBodyPositionX)
                                    UISignedInput(label: "Y", binding: $selectedBodyPositionY, inputText: selectedBodyPositionY)
                                    UISignedInput(label: "Z", binding: $selectedBodyPositionZ, inputText: selectedBodyPositionZ)
                                }
                                
                                Divider()
                                
                                Spacer()
                                    .frame(height: 20)
                            }
                        
                            HStack {
                                Button("Delete", action: {
                                    if selectedBody != "New..." {
                                        if solarscene.focusIndex == solarscene.bodies.count - 1 {
                                            solarscene.focusIndex -= 1
                                        }
                                        
                                        solarscene.scene.rootNode.childNode(withName: solarscene.bodies[availableBodies.firstIndex(of: selectedBody) ?? 0].planetBody?.name ?? "planet", recursively: false)?.removeFromParentNode()
                                        solarscene.bodies.remove(at: availableBodies.firstIndex(of: selectedBody) ?? 0)
                                        
                                        availableBodies.removeAll { (body) in
                                            body == selectedBody
                                        }
                                        if availableBodies.count > 0 {
                                            selectedBody = availableBodies[0]
                                        } else {
                                            
                                            selectedBodyName = ""
                                            selectedBodyMass = ""
                                            selectedBodyColour = Color.random
                                            
                                            selectedBodyVelocityX = ""
                                            selectedBodyVelocityY = ""
                                            selectedBodyVelocityZ = ""
                                            
                                            selectedBodyPositionX = ""
                                            selectedBodyPositionY = ""
                                            selectedBodyPositionZ = ""
                                        }
                                    }
                                    
                                    isEditPresented = false
                                })
                                .padding(.trailing)
                                
                                Divider()
                                    .frame(height: 20)
                                
                                Button("Confirm", action: {
                                    print(selectedBody)
                                    if selectedBody != "New..." {
                                        solarscene.inputBodies[availableBodies.firstIndex(of: selectedBody) ?? 0].name = selectedBodyName
                                        solarscene.inputBodies[availableBodies.firstIndex(of: selectedBody) ?? 0].mass = CGFloat(Double(selectedBodyMass) ?? 1)
                                        solarscene.inputBodies[availableBodies.firstIndex(of: selectedBody) ?? 0].velocity = SCNVector3(x: Float(selectedBodyVelocityX) ?? 1, y: Float(selectedBodyVelocityY) ?? 1, z: Float(selectedBodyVelocityZ) ?? 1)
                                        solarscene.inputBodies[availableBodies.firstIndex(of: selectedBody) ?? 0].position = SCNVector3(x: Float(selectedBodyPositionX) ?? 1, y: Float(selectedBodyPositionY) ?? 1, z: Float(selectedBodyPositionZ) ?? 1)
                                        solarscene.inputBodies[availableBodies.firstIndex(of: selectedBody) ?? 0].color = UIColor(selectedBodyColour)
                                    } else {
                                        solarscene.inputBodies.append(BodyDefiner(name: selectedBodyName, mass: CGFloat(Double(selectedBodyMass) ?? 1), velocity: SCNVector3(x: Float(selectedBodyVelocityX) ?? 1, y: Float(selectedBodyVelocityY) ?? 1, z: Float(selectedBodyVelocityZ) ?? 1), position: SCNVector3(x: Float(selectedBodyPositionX) ?? 1, y: Float(selectedBodyPositionY) ?? 1, z: Float(selectedBodyPositionZ) ?? 1), color: UIColor(selectedBodyColour)))
                                    }
                                    
                                    solarscene.pauseLoop()
                                    solarscene = SolarScene(
                                        focusOnBody: solarscene.focusOnBody, focusIndex: solarscene.focusIndex, trails: solarscene.trails, velocityArrows: solarscene.velocityArrows, gravitationalConstant: solarscene.gravitationalConstant, inputBodies: solarscene.inputBodies, allowCameraControl: true
                                    )
                                    
                                    playing = false
                                    
                                    isEditPresented = false
                                })
                                .padding(.leading)
                            }
                            .padding(.bottom)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            
                    
                    // Settings Button Slideover
                    .sheet(isPresented: $isSettingsPresented) {
                        VStack {
                            Text("Settings:")
                                .fontWeight(.bold)
                                .font(.title)
                                .padding(.bottom)
                            
                            if availableBodies.count > 0 {
                                Toggle(isOn: $focusOnBody) {
                                    Label("Focus On Body", systemImage: "scope")
                                }
                                .onChange(of: focusOnBody) { value in
                                    solarscene.focusOnBody = focusOnBody
                                }
                                .toggleStyle(.button)
                                
                                Text("Please choose a body")
                                    .font(.subheadline)
                                    .padding(.top)
                                
                                Picker("Please choose a body", selection: $selectedBody) {
                                    ForEach(availableBodies, id: \.self) {
                                        Text($0)
                                    }
                                }
                                .disabled(!focusOnBody)
                                
                                Text("You selected \"\(selectedBody)\", which has a mass of \(String(format: "%.2f", solarscene.bodies[availableBodies.firstIndex(of: selectedBody) ?? 0].mass)) and a colour of \(solarscene.bodies[availableBodies.firstIndex(of: selectedBody) ?? 0].color.accessibilityName)")
                                    .padding(10)
                                    .multilineTextAlignment(.center)
                                
                                Divider()
                                    .padding(.bottom)
                                
                                HStack {
                                    Toggle(isOn: $showTrails) {
                                        Label("Show Trails", systemImage: "moon.stars")
                                    }
                                    .onChange(of: showTrails) { value in
                                        if value {
                                            solarscene.showTrails()
                                        } else {
                                            solarscene.hideTrails()
                                        }
                                    }
                                    .toggleStyle(.button)
                                    .padding(.bottom)
                                    
                                    Spacer()
                                        .frame(width: 20)
                                    
                                    Toggle(isOn: $showVelocityArrows) {
                                        Label("Show Velocity", systemImage: "arrow.up.right")
                                    }
                                    .toggleStyle(.button)
                                    .padding(.bottom)
                                }
                                
                                Divider()
                                    .padding(.top)
                                
                                VStack {
                                            // Display Current Gravitational Constant
                                            Text("Gravitational Constant: \(gravitationalConstant, specifier: "%.2f")")
                                                .font(.headline)
                                                .padding()
                                            
                                            // Slider for Adjusting G
                                            Slider(value: $gravitationalConstant, in: 0.1...10.0, step: 0.1)
                                                .padding()
                                            
                                            
                                        }
                            
                                Divider()
                                    .padding(.bottom)
                                
                            } else {
                                Text("There are no bodies in the current scene")
                                    .padding(.bottom)
                                    .multilineTextAlignment(.center)
                            }
                            
                            HStack {
                                
                                Button(availableBodies.count > 0 ? "Confirm" : "Dismiss", action: {
                                    solarscene.pauseLoop()
                                    solarscene = SolarScene(
                                        focusOnBody: focusOnBody, focusIndex: availableBodies.firstIndex(of: selectedBody) ?? 0, trails: showTrails, velocityArrows: showVelocityArrows, gravitationalConstant: gravitationalConstant, inputBodies: solarscene.inputBodies, allowCameraControl: true
                                    )
                                    isSettingsPresented = false
                                    playing = false
                                })
                                .padding(.leading)
                            }
                            .padding(.bottom)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    
                    // Delete All Button Slideover
                    .slideOverCard(isPresented: $isDeletePresented) {
                        VStack {
                            Text("Delete All Bodies:")
                                .fontWeight(.bold)
                                .font(.title)
                            
                            Text("Are you sure you'd like to clear the scene?")
                                .padding(10)
                                .multilineTextAlignment(.center)
                            
                            Button("Yes", action: {
                                selectedBody = ""
                                solarscene.pauseLoop()
                                focusOnBody = false
                                availableBodies = []
                                solarscene = SolarScene(
                                    focusOnBody: false, focusIndex: 0, trails: showTrails, velocityArrows: showVelocityArrows, gravitationalConstant: gravitationalConstant, inputBodies: [], allowCameraControl: true
                                )
                                isDeletePresented = false
                                playing = false
                            })
                            .padding(.bottom)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                
                // restart button
                    .slideOverCard(isPresented: $isRestartPresent) {
                        VStack {
                            Text("Restart:")
                                .fontWeight(.bold)
                                .font(.title)
                            
                            Text("Are you sure you'd like to restart the scene?")
                                .padding(10)
                                .multilineTextAlignment(.center)
                            
                            Button("Yes", action: {
                                solarscene.pauseLoop()
                                solarscene = SolarScene(
                                    focusOnBody: startingFocusOnBody, focusIndex: startingFocusIndex, trails: startingShowTrails, velocityArrows: startingShowVelocityArrows, gravitationalConstant: startingGravitationalConstant, inputBodies: startingBodies, allowCameraControl: true
                                )
                                playing = false
                                isRestartPresent = false
                            })
                            .padding(.bottom)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
        }
    }

