import SwiftUI
import SceneKit

struct GravityGameView: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var scene = GravityScene()
    @State private var selectedPlanet = "Earth"
    @State private var objectMass: Double = 1.0
    @State private var objectHeight: Double = 5.0
    @State private var fallTime: String = "-- sec"
    
    let planets: [String: CGFloat] = [
        "Mercury": 3.7, "Venus": 8.87, "Earth": 9.8, "Mars": 3.71,
        "Jupiter": 24.79, "Saturn": 10.44, "Uranus": 8.69, "Neptune": 11.15
    ]
    
    var body: some View {
        VStack {
            // Back Button
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "arrow.left.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                        .padding()
                }
                Spacer()
            }
            
            // Scene View
            SceneView(scene: scene, options: [.allowsCameraControl])
                .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height * 0.66)
                .background(Color.black)

            Text("Fall Time: \(fallTime)")
                .font(.title2)
                .bold()
                .foregroundColor(.white)
                .padding()
            
            VStack(spacing: 10) {
                // Planet Picker
                Picker("Select Planet", selection: $selectedPlanet) {
                    ForEach(planets.keys.sorted(), id: \.self) { planet in
                        Text(planet).tag(planet)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(height: 100)
                

                
                // Height Slider
                HStack {
                    Text("Height:")
                    Slider(value: $objectHeight, in: 1...10, step: 0.5)
                    Text("\(objectHeight, specifier: "%.1f") m")
                }
                .padding()
                
                // Confirm button
                Button(action: {
                    if let gravity = planets[selectedPlanet] {
                        fallTime = "-- sec"  // Reset Fall Time
                        scene.setupScene(planet: selectedPlanet, mass: objectMass, height: objectHeight, gravity: gravity)
                    }
                }) {
                    Text("Confirm")
                        .font(.title2)
                        .bold()
                        .frame(width: 200, height: 50)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                
                // Drop button
                Button(action: {
                    if let gravity = planets[selectedPlanet] {
                        fallTime = "-- sec"  // Reset fall time before dropping

                        scene.dropObject(height: objectHeight, gravity: gravity) { time in
                            DispatchQueue.main.async {
                                fallTime = String(format: "%.2f", time) + " sec"  // Update UI after collision
                            }
                        }
                    }
                }) {
                    Text("Drop Object")
                        .font(.title2)
                        .bold()
                        .frame(width: 200, height: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .padding()
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}
