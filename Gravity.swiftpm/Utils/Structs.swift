
import Foundation
import SceneKit
import SwiftUI


struct BodyDefiner {
    var name: String
    var mass: CGFloat
    var velocity: SCNVector3
    var position: SCNVector3
    var color: UIColor
}

extension Array {
    subscript( circular index: Int ) -> Element? {
        guard !isEmpty else { return nil }
        let modIndex = index % count
        return self[ modIndex < 0 ? modIndex + count : modIndex ]
    }
}

extension Color {
    static var random: Color {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}

extension View {
    func animate(using animation: Animation = .easeInOut(duration: 1), _ action: @escaping () -> Void) -> some View {
        onAppear {
            withAnimation(animation) {
                action()
            }
        }
    }
}

extension View {
    func animateForever(using animation: Animation = .easeInOut(duration: 1), autoreverses: Bool = false, _ action: @escaping () -> Void) -> some View {
        let repeated = animation.repeatForever(autoreverses: autoreverses)

        return onAppear {
            withAnimation(repeated) {
                action()
            }
        }
    }
}


struct AnimationCompletionObserverModifier<Value>: AnimatableModifier where Value: VectorArithmetic {

    nonisolated(unsafe) var animatableData: Value {
        didSet {
            notifyCompletionIfFinished()
        }
    }

    nonisolated(unsafe) private var targetValue: Value
    private var completion: () -> Void

    init(observedValue: Value, completion: @escaping () -> Void) {
        self.completion = completion
        self.animatableData = observedValue
        self.targetValue = observedValue
    }

    nonisolated(unsafe) private func notifyCompletionIfFinished() {
        if animatableData == targetValue {
            DispatchQueue.main.async {
                self.completion()
            }
        }
    }

    func body(content: Content) -> some View {
        content
    }
}


extension View {
    func onAnimationCompleted<Value: VectorArithmetic>(for value: Value, completion: @escaping () -> Void) -> ModifiedContent<Self, AnimationCompletionObserverModifier<Value>> {
        return modifier(AnimationCompletionObserverModifier(observedValue: value, completion: completion))
    }
}

extension String {
   func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
}


extension View {
    func navigate<NewView: View>(to view: NewView, when binding: Binding<Bool>) -> some View {
        NavigationView {
            ZStack {
                self
                    .navigationBarTitle("")
                    .navigationBarHidden(true)

                NavigationLink(
                    destination: view
                        .navigationBarTitle("")
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationBarHidden(false),
                    isActive: binding
                ) {
                    EmptyView()
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

extension View {
    
    func hasScrollEnabled(_ value: Bool) -> some View {
        self.onAppear {
            UITableView.appearance().isScrollEnabled = value
        }
    }
}

func addBloom() -> [CIFilter]? {
    let bloomFilter = CIFilter(name:"CIBloom")!
    bloomFilter.setValue(8.0, forKey: "inputIntensity")
    bloomFilter.setValue(18.0, forKey: "inputRadius")
    
    let blurFilter = CIFilter(name: "CIGaussianBlur")!
    blurFilter.setValue(0.6, forKey: kCIInputRadiusKey)

    return [bloomFilter, blurFilter]
}
