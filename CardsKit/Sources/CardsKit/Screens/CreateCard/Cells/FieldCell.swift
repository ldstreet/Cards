//
//  FieldCell.swift
//  CardsKit
//
//  Created by Luke Street on 4/2/19.
//

#if os(iOS)
import UIKit
import LDSiOSKit

class FirstResponderButton: UIButton {
    override var canBecomeFirstResponder: Bool { return true }
    
    private var _inputView: UIView?
    override var inputView: UIView? {
        get { return _inputView }
        set { _inputView = newValue }
    }
    
    private var _inputAccessoryView: UIView?
    override var inputAccessoryView: UIView? {
        get { return _inputAccessoryView }
        set { _inputAccessoryView = newValue }
    }
}

internal class FieldCell<Type: DataType>: UITableViewCell, Reusable where Type.RawValue == String {
    
    private let textField = UITextField()
    private let picker = TypePickerView(types: Type.types)
    private var typePair: TypePair<Type, String>?
    
    private var removeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(fromCurrentBundleNamed: "remove"), for: .normal)
        return button
    }()
    
    private lazy var typeButton: FirstResponderButton = {
        
        let toolBar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100))
        toolBar.barStyle = .default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        toolBar.items = [flexSpace, doneButton]
        toolBar.sizeToFit()
        
        let button = FirstResponderButton()
        button.inputView = picker
        button.inputAccessoryView = toolBar
        
        //button.setImage(#imageLiteral(resourceName: "right-caret"), for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.titleLabel?.font = button.titleLabel?.font.withSize(12)
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.addTarget(self, action: #selector(typeButtonTapped), for: .touchUpInside)
        return button
        
    }()
    
    private var stackView: UIStackView = {
        let sv = UIStackView(frame: .zero)
        sv.axis = .horizontal
        sv.alignment = .center
        sv.spacing = 10
        return sv
    }()
    
    @objc
    private func removeButtonTapped() { removeAction() }
    private var removeAction: VoidClosure = {}
    private var onUpdate: ParamterizedClosure<TypePair<Type, String>> = { _ in }
    
    @objc func doneButtonTapped() {
        typeButton.resignFirstResponder()
        if
            let selection = picker.currentSelection,
            let type = Type(rawValue: selection),
            let value = self.typePair?.value
        {
            let typePair = TypePair<Type, String>(type, value)
            self.typePair = typePair
            onUpdate(typePair)
        }
    }
    
    @objc
    private func typeButtonTapped() {
        typeButton.becomeFirstResponder()
    }
    
    private var initialLayout = true
    private var types = [String]()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if initialLayout {
            
            removeButton.addTarget(self, action: #selector(removeButtonTapped), for: .touchUpInside)
            
            
            stackView.addArrangedSubviews(
                [
                    removeButton,
                    typeButton,
                    textField
                ]
            )
            
            removeButton.size(width: 22, height: 22)
            
            contentView.addSubview(stackView)
            stackView.pin(.all, to: contentView, offsetBy: 10)
            
            initialLayout = false
            
        }
        
    }
    
    func configure(
        as fieldType: Card.FieldType,
        with valueType: Type,
        value: String,
        removeAction: @escaping VoidClosure,
        onUpdate: @escaping ParamterizedClosure<TypePair<Type, String>>
        )
    {
        self.typePair = TypePair(valueType, value)
        self.textField.text = value
        self.types = Type.types
        self.typeButton.setTitle(valueType.rawValue, for: .normal)
        self.textField.configure(as: fieldType)
        self.removeAction = removeAction
        self.onUpdate = onUpdate
    }
    
    func configureType(as type: Type) {
        self.typeButton.setTitle(type.rawValue, for: .normal)
    }
}
#endif
