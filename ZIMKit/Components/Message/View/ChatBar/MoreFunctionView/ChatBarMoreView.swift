//
//  ChatBarMoreView.swift
//  ZIMKit
//
//  Created by Kael Ding on 2022/8/11.
//

import Foundation

struct ChatBarMoreModel{
    let icon: String
    let title: String
    let type: ZIMKitMenuBarButtonName
}

protocol ChatBarMoreViewDelegate: AnyObject {
    func chatBarMoreView(_ moreView: ChatBarMoreView, didSelectItemWith type: ZIMKitMenuBarButtonName)
}

class ChatBarMoreView: _View {
    
    lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 30
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
        layout.scrollDirection = .horizontal
        return layout
    }()
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: flowLayout)
            .withoutAutoresizingMaskConstraints
        collectionView.backgroundColor = .zim_backgroundGray2
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.bounces = true
        collectionView.isPagingEnabled = true
        collectionView.register(ChatBarMoreViewCell.self,
                                forCellWithReuseIdentifier: ChatBarMoreViewCell.reuseIdentifier)
        return collectionView
    }()
    
    weak var delegate: ChatBarMoreViewDelegate?

    public var dataSource:[ChatBarMoreModel] = []
    override func setUp() {
        super.setUp()
        backgroundColor = .zim_backgroundGray2
    }
    
    override func setUpLayout() {
        super.setUpLayout()
        
        addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.pin(equalTo: topAnchor),
            collectionView.leadingAnchor.pin(equalTo: leadingAnchor),
            collectionView.trailingAnchor.pin(equalTo: trailingAnchor),
            collectionView.heightAnchor.pin(equalToConstant:100)
        ])
    }
}

extension ChatBarMoreView: UICollectionViewDataSource,
                           UICollectionViewDelegate,
                           UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChatBarMoreViewCell.reuseIdentifier, for: indexPath) as? ChatBarMoreViewCell else {
            return ChatBarMoreViewCell()
        }
        
        if indexPath.row >= dataSource.count { return cell }
        cell.fillData(dataSource[indexPath.row])
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (bounds.width - 5 * 30) / 4
        return CGSize(width: width, height: 91)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row >= dataSource.count { return }
        let data = dataSource[indexPath.row]
        delegate?.chatBarMoreView(self, didSelectItemWith: data.type)
    }
}
