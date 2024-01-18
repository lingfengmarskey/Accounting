//
//  CustomTextField.swift
//
//
//  Created by Marcos Meng on 2024/01/08.
//

import Foundation
import UIKit
import SwiftUI
import Domain
import SnapKit

class CalculatorKeyboardView: UIView {

    var collectionView: UICollectionView!

    let reuseId = "InuptView"
    
    let inputItems: [[AccountInput]] = [
        [.one, .four, .seven, .zero],
        [.two, .five, .eight, .point],
        [.three, .six, .nine, .plus],
        [.delete, .equal],
    ]

    override init(frame: CGRect) {
        super.init(frame: frame)
        configSubViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configSubViews()
    }

    func configSubViews() {
        let collectionFlowlayout = UICollectionViewFlowLayout()
        collectionFlowlayout.scrollDirection = .horizontal
        collectionView = .init(frame: frame, collectionViewLayout: collectionFlowlayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.white
        addSubview(collectionView)

        collectionView.register(CalculatorInputView.self, forCellWithReuseIdentifier:  reuseId)
    }
}
extension CalculatorKeyboardView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let items = inputItems[section]
        return items.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return inputItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as! CalculatorInputView
        cell.label.text = "\(indexPath.section)"
        let items = inputItems[indexPath.section]
        let item = items[indexPath.row]
        
        if item == .delete {
            cell.imageView.image = UIImage(named: "delete", in: .module, compatibleWith: nil)
            cell.label.text = ""
            cell.imageView.isHidden = false
        } else {
            cell.label.text = item.text
            cell.imageView.isHidden = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch section {
        case 0:
            return .init(top: 10, left: 25, bottom: 10, right: 0)
        case 1, 2:
            return .init(top: 10, left: 10, bottom: 10, right: 0)
        default:
            return .init(top: 10, left: 10, bottom: 10, right: 25)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemLength = (collectionView.frame.size.width - 80) / 4.0
        let bigItemLength = itemLength * 3 + 20
        switch indexPath {
        case [3, 1]:
            return CGSize(width:itemLength, height: bigItemLength)
        default:
            return CGSize(width: itemLength, height: itemLength)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.contentView.backgroundColor = UIColor.flatGreenColor
        }
    }


    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.contentView.backgroundColor = UIColor.keyboardInputColor
        }
    }
}

class CalculatorInputView: UICollectionViewCell {
    
    var label: UILabel!
    
    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        label = UILabel.init(frame: frame)
        contentView.addSubview(label)
        layer.cornerRadius = 5
        clipsToBounds = true
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 32, weight: .medium)
        contentView.backgroundColor = UIColor.keyboardInputColor
        
        imageView = UIImageView(frame: frame)
        contentView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(22)
            make.bottom.equalToSuperview().offset(-22)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


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
        
        let itemLength = (UIScreen.main.bounds.size.width - 80) / 4.0
        let height = itemLength * 4 + 50
        customInputView = CalculatorKeyboardView.init(frame: .init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: height))
        inputView = customInputView
        let toolbar = UIToolbar(frame: .init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 40))
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([
            spacer,
            doneBarButton,
        ], animated: true)
        inputAccessoryView = toolbar
    }
    
    @objc func doneAction() {
        resignFirstResponder()
    }
}

public struct BoldTextField: UIViewRepresentable {
    
    @Binding var textValue: String

    var placeholderText: String?

    var fontSize: CGFloat

    public init(textValue: Binding<String>, placeholderText: String? = nil, fontSize: CGFloat = 17) {
        _textValue = textValue
        self.placeholderText = placeholderText
        self.fontSize = fontSize
    }

    public func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = textValue
    }

    public func makeUIView(context: Context) -> UITextField {
        let result = CustomTextField()
        result.placeholder = placeholderText
        result.font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        return result
    }
}
