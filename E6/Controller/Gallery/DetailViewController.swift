//
//  ShowDetailViewController.swift
//  E6-0920
//
//  Created by yujinpil on 14/06/2019.
//  Copyright © 2019 jinpil. All rights reserved.
//

import UIKit
import Photos

class DetailViewController: UIViewController {
  @IBOutlet weak var detailView: UIImageView!
  let photoManager = PHCachingImageManager()
  var indexPath: IndexPath!
  var assets: PHFetchResult<PHAsset>!
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
    return UIStatusBarAnimation.slide
  }
  

  override func viewDidLoad() {
    super.viewDidLoad()
    // navigation items
    navigationController?.hidesBarsOnTap = true
    navigationController?.hidesBarsWhenVerticallyCompact = true
    
    tabBarController?.hidesBottomBarWhenPushed = true

    let leftButton = UIBarButtonItem(image: UIImage(named: "album_ablumview_back"),
                                     style: .done,
                                     target: self,
                                     action: Selector(("buttonMethod")))
    
    navigationItem.leftBarButtonItem = leftButton
    
    let rightButton = UIBarButtonItem(image: UIImage(named: "album_delete"),
                                     style: .done,
                                     target: self,
                                     action: Selector(("delete")))
    
    navigationItem.rightBarButtonItem = rightButton
    
    // image asset
    let asset = self.assets[indexPath.row]
    let screenSize: CGSize = UIScreen.main.bounds.size
    let scale = UIScreen.main.scale * 2
    let targetSize = CGSize(width: screenSize.width * scale, height: screenSize.height * scale)
    let requestOptions = PHImageRequestOptions()
    // NOTE:- If we didn't call requestImage as syncronous, result handler will called twice
    requestOptions.isSynchronous = true
    requestOptions.deliveryMode = .highQualityFormat

    photoManager.requestImage(for: asset,
                              targetSize: targetSize,
                              contentMode: .aspectFit,
                              options: requestOptions,
                              resultHandler: { (result, info) -> Void in
                                self.detailView.image = result })
    
    let swipeLeftRecognizer = UISwipeGestureRecognizer(target: self,
                                                       action: #selector(swipeToLeft(_:)))
    let swipeRightRecognizer = UISwipeGestureRecognizer(target: self,
                                                        action: #selector(swipeToRight(_:)))
                                            
    
    swipeLeftRecognizer.direction = .left
    swipeRightRecognizer.direction = .right
    
    self.view.addGestureRecognizer(swipeLeftRecognizer)
    self.view.addGestureRecognizer(swipeRightRecognizer)
  }
  
  @objc func swipeToLeft(_ sender :UISwipeGestureRecognizer){
    if !(assets.count <= indexPath.row + 1){
      self.indexPath.row += 1

      let asset = self.assets[indexPath.row]
      let screenSize: CGSize = UIScreen.main.bounds.size
      let scale = UIScreen.main.scale * 2
      let targetSize = CGSize(width: screenSize.width * scale, height: screenSize.height * scale)
      let requestOptions = PHImageRequestOptions()
      // NOTE:- If we didn't call requestImage as syncronous, result handler will called twice
      requestOptions.isSynchronous = true
      requestOptions.deliveryMode = .highQualityFormat
      
      photoManager.requestImage(for: asset,
                                targetSize: targetSize,
                                contentMode: .aspectFit,
                                options: requestOptions,
                                resultHandler: { (result, info) -> Void in
                                  UIView.animate(withDuration: 0.5,
                                                 delay: 0.5,
                                                 options: .allowUserInteraction,
                                                 animations:  { self.detailView.image = result },
                                                 completion: nil) })
    }
  }
  
  @objc func swipeToRight(_ sender :UISwipeGestureRecognizer){
    if !(0 > indexPath.row - 1){
      self.indexPath.row -= 1

      let asset = self.assets[indexPath.row]
      let screenSize: CGSize = UIScreen.main.bounds.size
      let scale = UIScreen.main.scale * 2
      let targetSize = CGSize(width: screenSize.width * scale, height: screenSize.height * scale)
      let requestOptions = PHImageRequestOptions()
      // NOTE:- If we didn't call requestImage as syncronous, result handler will called twice
      requestOptions.isSynchronous = true
      requestOptions.deliveryMode = .highQualityFormat

      photoManager.requestImage(for: asset,
                                targetSize: targetSize,
                                contentMode: .aspectFit,
                                options: requestOptions,
                                resultHandler: { (result, info) -> Void in
                                  self.detailView.image = result })
    }
  }
  
  @objc func buttonMethod() {
    navigationController?.popViewController(animated: true)
  }
  
  @objc func delete() {
    var willDeleteAsset: [PHAsset] = []
    willDeleteAsset.append(self.assets[indexPath.row])
    
    PHPhotoLibrary.shared().performChanges({
      PHAssetChangeRequest.deleteAssets(willDeleteAsset as NSFastEnumeration)
    },completionHandler: { success, error in
      if success {
        let photosFetchOption = PHFetchOptions()
        photosFetchOption.sortDescriptors
          = [NSSortDescriptor(key: "creationDate", ascending: false)] // 오름차순: false
        DispatchQueue.main.async {
          self.navigationController?.popViewController(animated: true)
        }
      }
      else {
        NSLog("error creating asset: \(String(describing: error))")
        
      }
    })
  }
}
