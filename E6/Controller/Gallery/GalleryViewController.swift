//
//  GalleryViewController.swift
//  E6-0920
//
//  Created by yujinpil on 06/06/2019.
//  Copyright © 2019 jinpil. All rights reserved.
//

import UIKit
import Photos

class GalleryViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  
  // MARK:- Variables
  
  private var allCells: [PhotoCell] = []

  private var willDeletedCells: [PhotoCell] = []
  
  @IBOutlet weak var leftBarButton: UIBarButtonItem!
  
  private let reuseIdentifier = "PhotoCell"
  
  private var cellPerRow: CGFloat = 3.0
  
  // This variable is Integer, but declare as float for operating.
  
  private var allPhotos: PHFetchResult<PHAsset>!
  
  var selectedIndex: IndexPath!
  
  fileprivate var photoManager = PHCachingImageManager()
  
  fileprivate var album = PHAssetCollection()
  
  private var thumbnailSize: CGSize!
  
  private var albumDrawer: UIView!
  
  private var drawerButton: UIButton!
  
  private let sectionInsets = UIEdgeInsets(top: 0.1,
                                           left: 2.0,
                                           bottom: 0.1,
                                           right: 2.0)
  
  // MARK:- Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
  
    navigationItem.leftBarButtonItem
      = UIBarButtonItem(image: UIImage(named: "album_x"),
                        style: .plain,
                        target: self,
                        action: #selector(dismissDidTap(_:)))
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    let photosFetchOption = PHFetchOptions()
    photosFetchOption.sortDescriptors
      = [NSSortDescriptor(key: "creationDate", ascending: false)] // 오름차순: false
    allPhotos = PHAsset.fetchAssets(with: photosFetchOption)
    collectionView.reloadData()
    navigationController?.hidesBarsOnTap = false
    
    let scale = UIScreen.main.scale * 21
    let cellSize = (collectionViewLayout as! UICollectionViewFlowLayout).itemSize
    
    thumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.width * scale)
  }
  
  // MARK:- Navigation Bar
  
  
  // MARK:- Navigation
  
  @objc func dismissDidTap(_ sender: Any) {
    dismiss(animated: true)
  }
  
  @objc func deleteDidTap(_ sender: Any) {
  }
  
  // MARK:- Cell Data Control
  
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    // We will choose album in navigation title. So we return 1 section
    return 1
  }
  
  override func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
    // Number of item per section.
    return allPhotos.count
  }
  
  override func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    // Set data to cell about index.
    
    let asset = allPhotos.object(at: indexPath.row) // Indexing photo
    let cell
      = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell",
                                           for: indexPath) as! PhotoCell
    cell.delegate = self
    allCells.append(cell)
    
    let requestOptions: PHImageRequestOptions = PHImageRequestOptions()
    requestOptions.deliveryMode = .highQualityFormat
    
    photoManager.requestImage(for: asset,
                              targetSize: thumbnailSize,
                              contentMode: .aspectFill,
                              options: requestOptions,
                              resultHandler: { image, _ in
                                cell.thumbnail = image })
    
    return cell
  }
  
  // MARK:- Cell Layout
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    // Cell size
    let paddingSpace = sectionInsets.left * (cellPerRow + 1)
    let availableWidth = view.frame.width - paddingSpace
    let widthPerItem = availableWidth / cellPerRow
    
    return CGSize(width: widthPerItem, height: widthPerItem) // square
  }
  
  // Inset for each cell
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      insetForSectionAt section: Int) -> UIEdgeInsets {
    return sectionInsets
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return sectionInsets.left
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return sectionInsets.left
  }
  
  // MARK: - UICollectionView Delegate
  
  override func collectionView(_ collectionView: UICollectionView,
                               didSelectItemAt indexPath: IndexPath) {
    self.selectedIndex = indexPath
    self.performSegue(withIdentifier: "showDetailVCSegue", sender: nil)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showDetailVCSegue" {
      let detailVC = segue.destination as! DetailViewController
      detailVC.assets = self.allPhotos
      detailVC.indexPath = selectedIndex
    }
  }
}

extension GalleryViewController: PhotoCellDelegate {
  func delete(cell: PhotoCell) {
    
  }
}
