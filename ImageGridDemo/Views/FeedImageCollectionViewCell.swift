//
//  FeedImageCollectionViewCell.swift
//  ImageGridDemo
//
//  Created by Sandeep on 14/04/24.
//

import Foundation
import UIKit

class FeedImageCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textAlignment = .center
        return label
    }()
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layout()
    }
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        self.imageView.image = nil
//        self.titleLabel.text = ""
//    }
    // MARK: - Layout
    func layout() {
        contentView.backgroundColor = .secondaryLabel
        contentView.layer.cornerRadius = 6
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.separator.cgColor
        contentView.layer.masksToBounds = true
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            titleLabel.heightAnchor.constraint(equalToConstant: 24),
            
            imageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    // MARK: - Public Method
    func set(feed: CoverageFeed) {
        titleLabel.text = feed.title
        activityIndicator.startAnimating()
        imageView.setImage(withURL: feed.thumbnail?.imageURL, placeholderImage: UIImage(named: "coverage_placeholder")) {[weak self]  _,_ in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
            }
        }
    }
}
