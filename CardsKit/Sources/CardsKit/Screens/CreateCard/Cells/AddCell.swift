//
//  AddCell.swift
//  CardsKit
//
//  Created by Luke Street on 4/2/19.
//

#if os(iOS)
import UIKit
import LDSiOSKit

internal class AddFieldCell: UITableViewCell, Reusable {
    
    private let addIcon = UIImageView(image: UIImage(fromCurrentBundleNamed: "add"))
    private let label = UILabel()
    
    private var stackView: UIStackView = {
        let sv = UIStackView(frame: .zero)
        sv.axis = .horizontal
        sv.alignment = .center
        return sv
    }()
    
    private var initialLayout = true
    
    override func layoutSubviews() {
        if initialLayout {
            stackView.addArrangedSubviews(
                [
                    addIcon,
                    label
                ]
            )
            
            addIcon.size(width: 22, height: 22)
            
            contentView.addSubview(stackView)
            stackView.pin(.all, to: contentView, offsetBy: 10)
            
            initialLayout = false
        }
    }
    
    func configure(sectionType: String) {
        label.text = sectionType
    }
}
#endif
