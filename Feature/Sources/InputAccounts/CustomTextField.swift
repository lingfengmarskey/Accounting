//
//  File.swift
//  
//
//  Created by Marcos Meng on 2024/01/08.
//

import Foundation
import UIKit
import SwiftUI

class CustomTextField: UITextField {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configKeyboard()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configKeyboard()
    }

    var customInputView: UIView?
    
    private func configKeyboard() {
        customInputView = UIView.init(frame: .init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100))
        customInputView?.backgroundColor = .red
        inputView = customInputView
        inputAccessoryView = UIButton.systemButton(with: .add, target: self, action: #selector(doneAction))
    }
    
    @objc func doneAction() {
        resignFirstResponder()
    }
}

struct BoldTextField: UIViewRepresentable {
    @Binding var textValue: String

    var placeholderText: String?

    var fontSize: CGFloat = 17

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = textValue
    }

    func makeUIView(context: Context) -> UITextField {
        let result = CustomTextField()
        result.placeholder = placeholderText
        result.font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        return result
    }
}


#Preview(body: {
    BoldTextField(textValue: .constant(""), placeholderText: "0.00")
})

