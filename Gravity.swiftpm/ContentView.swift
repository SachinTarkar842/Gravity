

import Foundation
import SwiftUI
import SceneKit


struct ContentView: View {
    @State var scale: CGFloat = 0.5
    @State var orbitOpacity: CGFloat = 0
    @State var continueOpacity: CGFloat = 1
    @State var showContinue: Bool = false
    @State var showLogo: CGFloat = 0
    @State var initialOpacity: CGFloat = 1
    @State var initialOffset: CGFloat = 0
    @State var showInitial: Bool = true
    @State var showInfo: Bool = false
    
    
    @State private var moveOnY: Bool = true
        
    let cursorColor = Color(#colorLiteral(red: 0, green: 0.368627451, blue: 1, alpha: 1))
    
    var body: some View {
        VStack {
            if showInitial {
                Group {
                    HStack(alignment: .center, spacing: 8) {
                        if showLogo == 1 {
                            Image("orbit-logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100) // adjust size as needed
                                .cornerRadius(25)
                                // Remove extra padding if spacing is set in HStack
                                .onAppear {
                                    withAnimation(.easeInOut.delay(1)) {
                                        showContinue = true
                                    }
                                }
                        }
                        
                        Text("Gravity")
                            .font(.system(size: 80))
                            .opacity(orbitOpacity)
                            .scaleEffect(scale)
                            .onAppear {
                                withAnimation(.easeOut(duration: 1.5).delay(1)) {
                                    scale = 1
                                    orbitOpacity = 1
                                }
                            }
                            .onAnimationCompleted(for: scale) {
                                withAnimation(.easeIn) {
                                    showLogo = 1
                                }
                            }
                    }
                    .padding(.bottom)

                    if showContinue {
                        Button("Continue") {
                            withAnimation(.easeInOut(duration: 1)) {
                                initialOffset = 100
                                initialOpacity = 0
                            }
                        }
                        .onAnimationCompleted(for: initialOpacity) {
                            showInitial = false
                            showInfo = true
                            
                        }
                        .opacity(continueOpacity)
                        .onAppear() {
                            withAnimation(.easeOut(duration: 1).repeatForever(autoreverses: true)) {
                                continueOpacity = 0.65
                            }
                        }
                    }
                }
                .offset(x: 0, y: -initialOffset)
                .opacity(initialOpacity)
            }


            if showInfo {
                withAnimation(.easeInOut) {
                    InfoView()
                        .transition(.opacity)
                }
            }
        }
    }
}

struct SimulationView: View {
    var body: some View {
        Simulation(
            startingFocusOnBody: true,
            startingShowTrails: true,
            startingShowVelocityArrows: false,
            startingGravitationalConstant: 1,
            startingFocusIndex: 0,
            startingBodies: [
                BodyDefiner(name: "Sun", mass: 20.0, velocity: SCNVector3(0, 0, 0), position: SCNVector3(0, 0, 0), color: UIColor.systemYellow),
                BodyDefiner(name: "Earth", mass: 6.0, velocity: SCNVector3(-0.65, 0, 0), position: SCNVector3(0, -70, 0), color: UIColor.systemGreen),
//                BodyDefiner(name: "Moon", mass: 1, velocity: SCNVector3(0, 0, 0.025), position: SCNVector3(0, -85, 0), color: UIColor.systemBlue),
//                BodyDefiner(name: "Mars", mass: 5.0, velocity: SCNVector3(0.4, 0, 0), position: SCNVector3(0, -150, 0), color: UIColor.systemRed),
            ],
            showUI: true,
            allowCameraControl: true,
            showTexture: true
        )
    }
}

struct InfoView: View {
    @State var showSimulation: Bool = false
    
    var body: some View {
        if showSimulation {
            withAnimation(.spring()) {
                SimulationView()
                    .transition(.slide)
            }
        } else {
            ScrollView {
                Spacer()
                    .frame(height: 50)
                
                
                Text("Newton's Universal Law of Gravitation")
                    .font(.title)
                    .multilineTextAlignment(.center)
                
                Image("equation")
                    .colorInvert()
                    .padding(30)
                
                Text("Newton's Universal Law of Gravitation explains how objects in the universe interact by stating that every object exerts a gravitational force on every other nearby object. This relationship is described by the equation above.")
                    .multilineTextAlignment(.center)
                    .padding(15)

                Text("But what does this really mean? Why does the Moon orbit the Earth instead of drifting off into space? Why do we stay on the ground rather than floating away? It's because both the Moon and we are within Earth's gravitational field, and the Earth's mass is large enough to keep us pulled toward it.")
                    .multilineTextAlignment(.center)
                    .padding(15)

                Text("So why doesn’t the Moon crash into the Earth? Imagine throwing a ball—it eventually falls to the ground. If you throw it farther, it lands farther. But if you throw it fast enough, it will keep moving forward without ever hitting the ground, essentially entering **orbit**. In the same way, the Moon is constantly falling toward Earth, but Earth's curvature ensures it never actually collides!")
                    .multilineTextAlignment(.center)
                    .padding(15)

                
                
                
                Button("Now Let's Play!") {
                    withAnimation(.spring()) {
                        showSimulation = true
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
