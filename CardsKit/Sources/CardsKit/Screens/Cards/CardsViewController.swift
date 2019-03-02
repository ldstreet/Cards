//
//  CardsViewController.swift
//  CardsKit
//
//  Created by Luke Street on 2/9/19.
//

#if os(iOS)
import UIKit
import LDSiOSKit
import PassKit

public class CardsViewController: UICollectionViewController {
    
    private var cards: [Card]
    
    public init(cards: [Card]) {
        self.cards = cards
        
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        collectionView.register(CardCell.self, forCellWithReuseIdentifier: "CardCell")
        
        view.backgroundColor = .white
        collectionView.backgroundColor = .clear
        collectionView.contentInset = .init(top: 20, left: 10, bottom: 20, right: 10)
        
        navigationItem.title = "Cards"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(tappedAddButton))
        
        let request = Request<Environment, [Card]>(
            using: Current.environment,
            path: "cards"
        )
        
        request.send { result in
            DispatchQueue.main.async {
                do {
                    self.cards = try result.get()
                    self.collectionView.reloadData()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        super.viewDidLoad()
    }
    
    @objc
    private func tappedAddButton() {
        
        let createCardVC = CreateCardViewController { card in
            self.cards.append(card)
            self.collectionView.reloadData()
        }
        
        navigationController?.pushViewController(createCardVC, animated: true)
    }
    
    override public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as? CardCell else {
            return .init()
        }
        cell.configure(with: cards[indexPath.row])
        return cell
    }
    
    override public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cards.count
    }
    
    override public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let card = cards[indexPath.item]
        let request = Request<Environment, Data>(
            using: Current.environment,
            path: "share",
            method: card.post,
            headers: [:]
        )
        request.send { result in
            switch result {
            case .success(let data):
                let pass = try! PKPass(data: data)
                let vc = PKAddPassesViewController(pass: pass)!
                self.present(vc, animated: true, completion: nil)
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension CardsViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 300, height: 300)
    }
}
#endif
