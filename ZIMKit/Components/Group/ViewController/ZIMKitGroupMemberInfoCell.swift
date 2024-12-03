//
//  ZIMKitGroupMemberInfoCell.swift
//  ZIMKit
//
//  Created by zego on 2024/7/25.
//

import UIKit

class ZIMKitGroupMemberInfoCell: UICollectionViewCell {
    class var reuseId: String { String(describing: self) }
    lazy var imageView: UIImageView = {
        let imageView = UIImageView().withoutAutoresizingMaskConstraints
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 7
        return imageView
    }()
    
    lazy var memberName: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(hex: 0x646A73)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 0),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            imageView.widthAnchor.pin(equalToConstant: 34.0),
            imageView.heightAnchor.pin(equalToConstant: 34.0)
        ])
        
        contentView.addSubview(memberName)
        memberName.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            memberName.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 0),
            memberName.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 7),
            memberName.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: 0),
            memberName.heightAnchor.pin(equalToConstant: 17.0)
        ])
    }
}
