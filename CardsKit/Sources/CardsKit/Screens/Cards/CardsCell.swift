//
//  CardsCell.swift
//  CardsKit
//
//  Created by Luke Street on 2/9/19.
//

#if os(iOS)
import UIKit

class CardCell: UICollectionViewCell {
    
    let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fillProportionally
        sv.alignment = UIStackView.Alignment.center
        
        return sv
    }()
    
    lazy var nameLabels: [UILabel] = []
    lazy var titleLabels: [UILabel] = []
    lazy var emailLabels: [UILabel] = []
    lazy var phoneLabels: [UILabel] = []
    lazy var addressLabels: [UILabel] = []
    
    func makeFieldLabel(withText text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textAlignment = .center
        label.textColor = .gray
        label.backgroundColor = .white
        
        return label
    }
    
    private var initialLayout = true
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if initialLayout {
            
            print("Laying out...")
            
            initialLayout = false
            
            contentView.layer.borderColor = UIColor.black.cgColor
            contentView.layer.borderWidth = 2
            
            stackView.addArrangedSubviews([
                nameLabels,
                titleLabels,
                emailLabels,
                phoneLabels,
                addressLabels
                ].flatMap{ $0 })
            contentView.addSubview(stackView)
            stackView.pin(.all, to: contentView)
        }
    }
    
    func configure(with card: Card) {
        nameLabels = card
            .names
            .map(makeFieldLabel)
        titleLabels = card
            .titles
            .map(makeFieldLabel)
        emailLabels = card
            .emailAddresses
            .map { "\($0.type): \($0.value)" }
            .map(makeFieldLabel)
        phoneLabels = card
            .phoneNumbers
            .lazy
            .map { "\($0.type): \($0.value)" }
            .map(makeFieldLabel)
        addressLabels = card
            .addresses
            .lazy
            .map { "\($0.type): \($0.value)" }
            .map(makeFieldLabel)
    }
}
#endif
