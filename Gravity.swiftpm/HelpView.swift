
import Foundation
import SwiftUI

struct HelpView: View {
    var body: some View {
        ScrollView {
            Spacer()
                .frame(height: 20)
            
            Text("Button Guide")
                .font(.title)
            
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "play").foregroundColor(.white)
                        .imageScale(.large)
                        .frame(width: 60, height: 60)
                        .background(Circle().fill(Color.accentColor))
                    
                    Spacer()
                        .frame(width: 30)
                    
                    Text("Play/pause button. It starts and stops the simulation and the movement of the bodies")
                }
                .padding(20)
                
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "gear").foregroundColor(.white)
                            .imageScale(.large)
                            .frame(width: 60, height: 60)
                            .background(Circle().fill(Color.accentColor))
                        
                        Spacer()
                            .frame(width: 30)
                        
                        VStack {
                            Text("Display a menu where you can select various settings about the scene. This includes:")
                        }
                    }
                    
                    HStack {
                        Spacer()
                            .frame(width: 30)
                        VStack(alignment: .leading) {
                            Spacer()
                                .frame(height: 40)
                            
                            Text("Focusing on a body, means shifting your coordinate system so that the selected body is at the origin. In practice, subtract the focus body's position (and optionally velocity) from every other body's data. This gives a geocentric view (if focusing on Earth) or heliocentric view (if focusing on the Sun).")
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Divider()
                            
                            Text("Showing the trails of bodies over time as they move through space")
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Divider()
                            
                            Text("Showing velocity arrows to indicate the current velocity of bodies")
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Divider()
                            
                            Text("We set G=1 to make gravity stronger and bodies smaller/closer for visualization. You can adjust it to see its effects or match reality.")
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Divider()
                            
                            Text("Restarting the scene to its initial state")
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer()
                            .frame(width: 30)
                    }
                    
                }
                .padding(20)
                
                
                HStack {
                    Image(systemName: "pencil").foregroundColor(.white)
                        .imageScale(.large)
                        .frame(width: 60, height: 60)
                        .background(Circle().fill(Color.accentColor))
                    
                    Spacer()
                        .frame(width: 30)
                    
                    Text("This is the edit scene button, which allows you to edit the properities of bodies as well as add/delete them. As such, you can edit the velocity, position, colour, name, etc of the bodies and modify the scene as you wish")
                }
                .padding(20)
                
                HStack {
                    Image(systemName: "trash").foregroundColor(.white)
                        .imageScale(.large)
                        .frame(width: 60, height: 60)
                        .background(Circle().fill(Color.accentColor))
                    
                    Spacer()
                        .frame(width: 30)
                    
                    Text("This is the delete all button, and clears all bodies from the current scene")
                }
                .padding(20)
            }
            
            Text("By Sachin Tarkar for Swift Student Challenge 2025")
                .multilineTextAlignment(.center)
        }
    }
}
