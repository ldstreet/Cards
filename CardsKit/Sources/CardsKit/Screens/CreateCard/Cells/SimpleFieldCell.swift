//
//  SimpleFieldCell.swift
//  CardsKit
//
//  Created by Luke Street on 4/2/19.
//

#if os(iOS)
import UIKit
import LDSiOSKit

internal class SimpleFieldCell: UITableViewCell, Reusable {
    
    private var textField = UITextField()
    private var removeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(fromCurrentBundleNamed: "remove"), for: .normal)
        return button
    }()
    private var stackView: UIStackView = {
        let sv = UIStackView(frame: .zero)
        sv.axis = .horizontal
        sv.alignment = .center
        return sv
    }()
    
    private var initialLayout = true
    private var types = [String]()
    
    @objc
    private func removeButtonTapped() { removeAction() }
    private var removeAction: () -> () = {}
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if initialLayout {
            
            removeButton.addTarget(self, action: #selector(removeButtonTapped), for: .touchUpInside)
            
            stackView.addArrangedSubviews(
                [
                    removeButton,
                    textField
                ]
            )
            
            removeButton.size(width: 22, height: 22)
            
            contentView.addSubview(stackView)
            stackView.pin(.all, to: contentView, offsetBy: 10)
            
            initialLayout = false
        }
    }
    
    func configure(with value: String, as type: Card.FieldType, removeAction: @escaping () -> ()) {
        textField.text = value
        textField.configure(as: type)
        self.removeAction = removeAction
    }
}
#endif
