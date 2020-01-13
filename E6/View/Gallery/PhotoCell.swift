//
//  PhotoCell.swift
//  E6-0920
//
//  Created by yujinpil on 06/06/2019.
//  Copyright © 2019 jinpil. All rights reserved.
//

import Photos
import UIKit

protocol PhotoCellDelegate: class {
  func delete(cell: PhotoCell)
}

class PhotoCell: UICollectionViewCell {
  @IBOutlet weak var imageView: UIImageView!

  weak var delegate: PhotoCellDelegate?
  
  
  var thumbnail: UIImage! {
    didSet {
      // Set image to iamge View
      imageView.image = self.thumbnail
    }
  }
  
  override func prepareForReuse() {
    self.thumbnail = nil
  }
}
