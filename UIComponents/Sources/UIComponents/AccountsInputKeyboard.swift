//
//  AccountsInputKeyboard.swift
//
//
//  Created by Marcos Meng on 2023/10/21.
//

import Foundation
import SwiftUI
import Domain

public struct AccountsInputKeyboard: View {

    var onTap: (AccountInput) -> Void
    
    public init(onTap: @escaping (AccountInput) -> ()) {
        self.onTap = onTap
    }
    
    public var body: some View {
        HStack(spacing: 5) {
            VStack(spacing: 5) {
                InputButton(type: .one, onTap: onTap)
                InputButton(type: .four, onTap: onTap)
                InputButton(type: .seven, onTap: onTap)
                InputButton(type: .zero, onTap: onTap)
            }
            
            VStack(spacing: 5) {
                InputButton(type: .two, onTap: onTap)
                InputButton(type: .five, onTap: onTap)
                InputButton(type: .eight, onTap: onTap)
                InputButton(type: .point, onTap: onTap)
            }
            VStack(spacing: 5) {
                InputButton(type: .three, onTap: onTap)
                InputButton(type: .six, onTap: onTap)
                InputButton(type: .nine, onTap: onTap)
                InputButton(type: .plus, onTap: onTap)
            }
            VStack(spacing: 5) {
                    InputButton(type: .delete, onTap: onTap)
                        .relativeProposed(height: 0.5)
                    InputButton(type: .equal, onTap: onTap)
            }
        }
        .frame(height: 300)
    }
    
    struct InputButton: View {
        var type: AccountInput
        var onTap: (AccountInput) -> ()
        var body: some View {
            Button(action: {
                onTap(type)
            }, label: {
                Text(type.text)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: .infinity)
                    .foregroundStyle(Color.white)
                    .background {
                        Color.submitColor
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.white, lineWidth: 2)
                    }
            })
        }
    }
}

#Preview {
    VStack {
        Spacer()
        AccountsInputKeyboard { _ in
            
        }
    }
    .padding()
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
    /// Proposes a percentage of its received proposed size to `self`.
    ///
    /// This modifier multiplies the proposed size it receives from its parent
    /// with the given factors for width and height.
    ///
    /// If the parent proposes `nil` or `.infinity` to us in any dimension,
    /// we’ll forward these values to our child view unchanged.
    ///
    /// - Note: The size we propose to `self` will not necessarily be a percentage
    ///   of the parent view’s actual size or of the available space as not all
    ///   views propose the full available space to their children. For example,
    ///   VStack and HStack divide the available space among their subviews and
    ///   only propose a fraction to each subview.
    public func relativeProposed(width: Double = 1, height: Double = 1) -> some View {
        RelativeSizeLayout(relativeWidth: width, relativeHeight: height) {
            // Wrap content view in a container to make sure the layout only
            // receives a single subview.
            // See Chris Eidhof, SwiftUI Views are Lists (2023-01-25)
            // <https://chris.eidhof.nl/post/swiftui-views-are-lists/>
            VStack { // alternatively: `_UnaryViewAdaptor(self)`
                self
            }
        }
    }
}

/// A custom layout that proposes a percentage of its
/// received proposed size to its subview.
///
/// - Precondition: must contain exactly one subview.
fileprivate struct RelativeSizeLayout: Layout {
    var relativeWidth: Double
    var relativeHeight: Double

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        assert(subviews.count == 1, "RelativeSizeLayout expects a single subview")
        let resizedProposal = ProposedViewSize(
            width: proposal.width.map { $0 * relativeWidth },
            height: proposal.height.map { $0 * relativeHeight }
        )
        return subviews[0].sizeThatFits(resizedProposal)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        assert(subviews.count == 1, "RelativeSizeLayout expects a single subview")
        let resizedProposal = ProposedViewSize(
            width: proposal.width.map { $0 * relativeWidth },
            height: proposal.height.map { $0 * relativeHeight }
        )
        subviews[0].place(at: CGPoint(x: bounds.midX, y: bounds.midY), anchor: .center, proposal: resizedProposal)
    }
}
