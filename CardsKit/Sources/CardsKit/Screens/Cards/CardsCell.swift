//
//  CardsCell.swift
//  CardsKit
//
//  Created by Luke Street on 2/9/19.
//

import UIKit

class CardCell: UICollectionViewCell {
    
    let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fillProportionally
        sv.alignment = UIStackView.Alignment.center
        
        return sv
    }()
    
    lazy var nameLabel = makeFieldLabel()
    lazy var titleLabel = makeFieldLabel()
    lazy var subTitleLabel = makeFieldLabel()
    lazy var emailLabel = makeFieldLabel()
    lazy var phoneLabel = makeFieldLabel()
    lazy var addressLabel = makeFieldLabel()
    
    func makeFieldLabel() -> UILabel {
        let label = UILabel()
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
                nameLabel,
                titleLabel,
                subTitleLabel,
                emailLabel,
                phoneLabel,
                addressLabel
                ])
            contentView.addSubview(stackView)
            stackView.pin(.all, to: contentView)
        }
    }
    
    func configure(with card: Card) {
        nameLabel.text = "\(card.firstName) \(card.lastName)"
        titleLabel.text = card.title
        subTitleLabel.text = card.subTitle
        emailLabel.text = card.emailAddress
        phoneLabel.text = card.phoneNumber
        addressLabel.text = card.address
    }
}
