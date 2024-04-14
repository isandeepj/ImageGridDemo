//
//  ViewController.swift
//  ImageGridDemo
//
//  Created by Sandeep on 14/04/24.
//

import UIKit

class ViewController: UIViewController {
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing * 3
        layout.sectionInset = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: spacing)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.register(FeedImageCollectionViewCell.self, forCellWithReuseIdentifier: FeedImageCollectionViewCell.className)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        return collectionView
    }()
     lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    // Constants for spacing and cell size
    let spacing: CGFloat = 10
    lazy var cellSize: CGSize = {
        let numberOfColumns: CGFloat = 3
        let totalSpacing = spacing * (numberOfColumns - 1) + spacing * 2
        let screenWidth = UIScreen.main.bounds.width
        let cellWidth = (screenWidth - totalSpacing) / numberOfColumns
        let cellHeight = cellWidth * 1.25 + 30
        return CGSize(width: cellWidth.rounded(.down), height: cellHeight.rounded(.down))
    }()
    var feeds: [CoverageFeed] = []

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchData()
     }

}
// MARK: - UI Setup
extension ViewController {
    func setupUI() {
        view.addSubview(collectionView)
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
 
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Data Fetching
    func fetchData() {
        // Start the activity indicator animation
        activityIndicator.startAnimating()
        // Call the async function within an async block
        Task {
            do {
                self.feeds = try await FeedAdapter.fetchCoverageFeed()
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.collectionView.reloadData()
                    if self.feeds.isEmpty {
                        ToastManager.showToast(text: "No data available")
                    }
                }
             } catch let error as FeedAdapterError {
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    ToastManager.showToast(text: error.errorMessage, type: .bad)
                }
            } catch {
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    ToastManager.showToast(text: "Unexpected Error", type: .bad)
                }
            }
        }
    }
}
// MARK: - UICollectionViewDataSource & UICollectionViewDelegateFlowLayout
extension ViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feeds.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeedImageCollectionViewCell.className, for: indexPath)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let feedImageCell = cell as? FeedImageCollectionViewCell else {
            return
        }
        feedImageCell.set(feed: feeds[indexPath.item])
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
}
// MARK: - UICollectionViewDataSourcePrefetching
extension ViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for path in indexPaths {
            let feed = feeds[path.row]
            guard let url = feed.thumbnail?.imageURL else { continue }
            DownloadManager.shared.download(withURL: url)
        }
    }

    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for path in indexPaths {
            let card = feeds[path.row]
            guard let url = card.thumbnail?.imageURL else { continue }
            DownloadManager.shared.cancel(withURL: url)
        }
    }
}
