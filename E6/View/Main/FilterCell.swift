//
//  MenuCell.swift
//  E6
//
//  Created by yujinpil on 05/09/2019.
//  Copyright © 2019 portrayer. All rights reserved.
//

import UIKit

class FilterCell: UICollectionViewCell {
  var rootView: UIView!
  var imageView: UIImageView!
  var labelView: UIView!
  var label: UILabel!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    imageView.image = nil
    label.text = nil
    label.textColor = .white
    labelView.backgroundColor = .clear
    rootView.backgroundColor = .clear
  }
  
  // MARK:- UI
  
  public func configureView(_ indexPath: IndexPath) {
    addView(indexPath)
    addImageView(indexPath)
    addLabelView()
    addLabel()
  }
  
  func addView(_ indexPath: IndexPath) {
    let view = UIView()
    view.frame = bounds
    
    if indexPath.row == 0 {
      view.backgroundColor = .white

      view.layer.mask = {
        let maskPath: UIBezierPath!

          maskPath = UIBezierPath(roundedRect: view.frame,
                                  byRoundingCorners: [UIRectCorner.topRight],
                                  cornerRadii: CGSize(width: 5.0, height: 5.0))
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        return maskLayer
      } ()
    }

    self.addSubview(view)
    
    view.translatesAutoresizingMaskIntoConstraints = false
    
    let top = view.topAnchor.constraint(equalTo: self.topAnchor)
    let leading = view.leadingAnchor.constraint(equalTo: self.leadingAnchor)
    let trailling = view.trailingAnchor.constraint(equalTo: self.trailingAnchor)
    let bottom = view.bottomAnchor.constraint(equalTo: self.bottomAnchor)
    
    NSLayoutConstraint.activate([top, leading, trailling, bottom])
    
    self.rootView = view
  }
  
  func addImageView(_ indexPath: IndexPath) {
    let view = UIImageView()
    view.contentMode = .scaleAspectFit
    view.backgroundColor = .clear
    view.layer.mask = {
      let maskPath: UIBezierPath!
      
      if indexPath.row == 0 {
        maskPath = UIBezierPath(roundedRect: CGRect(origin: bounds.origin, size: CGSize(width: bounds.size.width - 1, height: bounds.size.height - 1)),
                                byRoundingCorners: [UIRectCorner.topRight],
                                cornerRadii: CGSize(width:4.0, height: 4.0))
      }
      else {
        maskPath = UIBezierPath(roundedRect: CGRect(origin: bounds.origin, size: CGSize(width: bounds.size.width - 1, height: bounds.size.height - 1)),
                                byRoundingCorners: [UIRectCorner.topLeft, UIRectCorner.topRight],
                                cornerRadii: CGSize(width: 4.0, height: 4.0))
      }
      let maskLayer = CAShapeLayer()
      maskLayer.frame = view.frame
      maskLayer.path = maskPath.cgPath
      return maskLayer
    } ()
    
    self.addSubview(view)
    
    view.translatesAutoresizingMaskIntoConstraints = false
    
   let top: NSLayoutConstraint!
    let leading: NSLayoutConstraint!
    let trailling: NSLayoutConstraint!
    let bottom: NSLayoutConstraint!

    if indexPath.row == 0 {
      top = view.topAnchor.constraint(equalTo: self.rootView.topAnchor, constant: 0.5)
      leading = view.leadingAnchor.constraint(equalTo: self.rootView.leadingAnchor, constant: 0.5)
      trailling = view.trailingAnchor.constraint(equalTo: self.rootView.trailingAnchor, constant: -0.5)
      bottom = view.bottomAnchor.constraint(equalTo: self.rootView.bottomAnchor, constant: -0.5)
    }
    else {
      let forEqual: CGFloat!
      
      if DeviceType.IPHONE_4_OR_LESS || DeviceType.IPHONE_5_SE {
        forEqual = 10.0
      }
      else {
        forEqual = 13.0
      }
      
      top = view.topAnchor.constraint(equalTo: self.rootView.topAnchor, constant: forEqual / 2)
      leading = view.leadingAnchor.constraint(equalTo: self.rootView.leadingAnchor, constant: forEqual)
      trailling = view.trailingAnchor.constraint(equalTo: self.rootView.trailingAnchor, constant: -forEqual)
      bottom = view.bottomAnchor.constraint(equalTo: self.rootView.bottomAnchor, constant: -(forEqual + forEqual/2)) 
    }

    NSLayoutConstraint.activate([top, leading, trailling, bottom])
    
    self.imageView = view
  }
  
  func addLabelView() {
    let view = UIView()
    view.backgroundColor = .clear
    
    self.addSubview(view)
    
    view.translatesAutoresizingMaskIntoConstraints = false
    
    let leading = view.leadingAnchor.constraint(equalTo: self.rootView.leadingAnchor, constant: 0.5)
    let trailling = view.trailingAnchor.constraint(equalTo: self.rootView.trailingAnchor, constant: -0.5)
    let bottom = view.bottomAnchor.constraint(equalTo: self.rootView.bottomAnchor, constant: -0.5)
    let height = view.heightAnchor.constraint(equalToConstant: 12)
    
    NSLayoutConstraint.activate([leading, trailling, bottom, height])
    
    self.labelView = view
  }
  
  func addLabel() {
    let label = UILabel()
    label.textColor = .white
    label.font = UIFont(name: "ArialHebrew", size: 10)
  
    labelView.addSubview(label)
    
    label.translatesAutoresizingMaskIntoConstraints = false
    
    let centerX = label.centerXAnchor.constraint(equalTo: self.labelView.centerXAnchor)
    let centerY = label.centerYAnchor.constraint(equalTo: self.labelView.centerYAnchor, constant: 2)
    
    NSLayoutConstraint.activate([centerX, centerY])
    
    self.label = label
  }
  
  func makeUnSelected() {
    self.label.textColor = .white
  }
}

