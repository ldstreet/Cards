//
//  TypeSelectionView.swift
//  CardsKit
//
//  Created by Luke Street on 4/1/19.
//

import UIKit

public typealias ParamterizedClosure<T> = (T) -> Void
public typealias VoidClosure = () -> Void

internal class TypePickerView: UIPickerView, UIPickerViewDelegate {
    
    private var onSelect: ParamterizedClosure<String> = { _ in }
    private var types: [String]
    internal var currentSelection: String?
    
    internal init(types: [String]) {
        self.types = types
        
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        self.delegate = self
        self.dataSource = self
    }
    
    internal func setOnSelect(_ onSelect: @escaping ParamterizedClosure<String>) {
        self.onSelect = onSelect
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    internal func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentSelection = types[row]
    }
}

extension TypePickerView: UIPickerViewDataSource {
    internal func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    internal func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return types.count
    }
    
    internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return types[row]
    }
}
