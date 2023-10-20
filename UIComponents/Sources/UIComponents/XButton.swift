//
//  File.swift
//  
//
//  Created by Marcos Meng on 2023/10/20.
//

import SwiftUI
import UIKit
import Foundation

public struct XButton: View {

    @State private var detailMode = false

    public var onTap: () -> Void
    public var onPlus: (() -> Void)?
    public var onMinus: (() -> Void)?

    public init(onTap: @escaping () -> Void,
                onPlus: (() -> Void)? = nil,
                onMinus: (() -> Void)? = nil) {
        self.onTap = onTap
        self.onPlus = onPlus
        self.onMinus = onMinus
    }

    public var body: some View {
        VStack(spacing: 0) {
                HStack(spacing: 0){
                    Spacer()
                        .frame(width: 22, height: 22)
                        .padding()
                    if detailMode {
                        Button(action: {
                            detailMode = false
                            onPlus?()
                        }, label: {
                            Image(systemName: "plus")
                                .resizable()
                                .frame(width: 22, height: 22)
                                .foregroundStyle(Color.white)
                        })
                        .padding()
                        .background(Color.black)
                        .clipShape(Circle())
                    }
                }
                HStack(spacing: 0) {
                    if detailMode {
                        Button(action: {
                            detailMode = false
                            onMinus?()
                        }, label: {
                            Image(systemName: "minus")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                                .foregroundStyle(Color.white)
                        })
                        .padding()
                        .background(Color.black)
                        .clipShape(Circle())
                    } else {
                        Spacer()
                            .frame(width: 22, height: 22)
                            .padding()
                    }
                    if !detailMode {
                        LongPressButton {
                            onTap()
                        } onLongPressed: {
                            detailMode = true
                        } label: {
                            Image(systemName: "circle.fill")
                                .resizable()
                                .frame(width: 22, height: 22)
                                .foregroundStyle(Color.white)
                        }
                    }

                }
            }
    }
}


struct LongPressButton<Label>: View where Label: View {

    @State private var longPressed = false
    let onTap: () -> Void
    let onLongPressed: () -> Void
    let label: () -> Label

    init(longPressed: Bool = false, onTap: @escaping () -> Void, onLongPressed: @escaping () -> Void, label: @escaping () -> Label) {
        self.longPressed = longPressed
        self.onTap = onTap
        self.onLongPressed = onLongPressed
        self.label = label
    }
    
    
    var body: some View {
        Button(action: {
            if longPressed {
                longPressed = false
            } else {
                onTap()
            }
        }, label: {
            label()
        })
        .padding()
        .background(.black )
        .clipShape(Circle())
        // None of this ever fires on Mac Catalyst :(
        .simultaneousGesture(LongPressGesture().onEnded { _ in
            longPressed = true
            print("Secret Long Press Action!")
            onLongPressed()
        })
        .simultaneousGesture(TapGesture().onEnded {
            longPressed = false
            onTap()
        })
    }
}

#Preview {
    XButton {
        
    } onPlus: {
        
    } onMinus: {
        
    }
}


