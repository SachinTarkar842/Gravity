//
//  File.swift
//  Gravity
//
//  Created by IOS on 18/02/25.
//


import Foundation
import SwiftUI

struct ExploreView: View {
    var body: some View {
        ScrollView {
            Spacer()
                .frame(height: 20)
            
            Text("Explore Solar System")
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
                    
                    
                    
                }
                .padding(20)
                
                
                
            }
            
        }
    }
}

