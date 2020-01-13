//
//  IndicatorTrackSlider.swift
//  E6
//
//  Created by yujinpil on 05/09/2019.
//  Copyright © 2019 portrayer. All rights reserved.
//

import UIKit



class IndicatorSlider: UISlider {
  var deviceModel: String!
  
  var indicatorView: UIView!
  
  var fixValue: Float!
  
  var initValue: Float! {
    didSet {
      for view in self.subviews {
        view.removeFromSuperview()
      }
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    deviceModel = UIDevice.modelName
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    deviceModel = UIDevice.modelName
    
    setIndicator(CGRect.zero)
  }
  
  func setIndicator(_ frame: CGRect) {
    let frame = CGRect(x: 0, y: 0, width: 5, height: 5)
    
    indicatorView = UIView(frame: frame)
    indicatorView.backgroundColor = .clear
    
    let circlePath = UIBezierPath(arcCenter: CGPoint(x: 0, y: 0),
                                  radius: CGFloat(3),
                                  startAngle: CGFloat(0),
                                  endAngle: CGFloat(Double.pi * 2),
                                  clockwise: true)
    
    let shapeLayer = CAShapeLayer()
    shapeLayer.path = circlePath.cgPath
    shapeLayer.fillColor = UIColor.white.cgColor
    shapeLayer.strokeColor = UIColor.white.cgColor
    shapeLayer.lineWidth = 1.0
    
    indicatorView.layer.addSublayer(shapeLayer)
    
    self.insertSubview(indicatorView, at: 1)
  }
  
  func setMidInitPoint() {
    indicatorView.frame = CGRect(x: self.frame.width / 2, y: 0, width: 10, height: 10)
  }
  
  func setColorInitPoint() {
    var deviation: CGFloat = 0.0
    
    if deviceModel == "iPhone 6" || deviceModel == "iPhone 7" || deviceModel == "Simulator iPhone 8" {
      deviation = 2
    }
    else if deviceModel == "iPhone XR" || deviceModel == "Simulator iPhone 11" {
      deviation = 3
    }
    else {
      deviation = 0
      print("no deviation")
    }
    
    let block = -((self.frame.size.width / 7) + deviation)
    
    indicatorView.frame = CGRect(x: (self.frame.width / 2) + block, y: 0, width: 10, height: 10)
  }
  
  func setHighlightsInitPoint() {
    var deviation: CGFloat = 0.0
    
    if deviceModel == "iPhone 6" || deviceModel == "iPhone 7" || deviceModel == "Simulator iPhone 8" ||
      deviceModel == "iPhone 6 Plus" || deviceModel == "iPhone 7 Plus" || deviceModel == "Simulator iPhone 8 Plus" {
      deviation = 1
    }
    else if deviceModel == "iPhone XR" || deviceModel == "Simulator iPhone 11" {
      deviation = 2
    }
    else if deviceModel == "iPhone XS MAX" || deviceModel == "Simulator iPhone 11 Pro Max" {
      deviation = 1
    }
    else {
      deviation = 0
      print("no deviation")
    }
    
    
    let block = (self.frame.size.width / 7) + deviation
    
    indicatorView.frame = CGRect(x: (self.frame.width / 2) + block, y: 0, width: 10, height: 10)
  }
  
  func setShadowsInitPoint() {
    var deviation: CGFloat = 0.0
    
    if deviceModel == "iPhone 6" || deviceModel == "iPhone 7" || deviceModel == "iPhone 8" {
      deviation = -4
    }
      else if deviceModel == "iPhone 6 Plus" || deviceModel == "iPhone 7 Plus" || deviceModel == "iPhone 8 Plus" {
      deviation = -3
    }
    else if deviceModel == "iPhone XR" || deviceModel == "iPhone 11" {
      deviation = -6
    }
    else if deviceModel == "iPhone X" || deviceModel == "iPhone XS" || deviceModel == "iPhone 11 Pro" {
      deviation = -0
    }
    else if deviceModel == "iPhone XS MAX" || deviceModel == "iPhone 11 Pro Max" {
      deviation = -2
    }
    else {
      deviation = 0
      print("no deviation")
    }
    
    let block = -((self.frame.size.width * 6) / 23)
    indicatorView.frame = CGRect(x: (self.frame.width / 2) + block + deviation, y: 0, width: 10, height: 10)
  }
  
  func setSharpenInitPoint() {
    var deviation: CGFloat = 0.0
     
     if deviceModel == "iPhone 6" || deviceModel == "iPhone 7" || deviceModel == "iPhone 8" ||
      deviceModel == "iPhone XR" || deviceModel == "iPhone 11" {
       deviation = -6
     }
     else {
       deviation = 0
       print("no deviation")
     }
    
    indicatorView.frame = CGRect(x: 17 + deviation, y: 0, width: 10, height: 10)
    print(UIDevice.modelName)
  }
  
  func setBlurInitPoint() {
    var deviation: CGFloat = 0.0

     if deviceModel == "iPhone 6" || deviceModel == "iPhone 7" || deviceModel == "iPhone 8" ||
       deviceModel == "iPhone XR" || deviceModel == "iPhone 11" {
        deviation = 6
     }
     else {
       deviation = 0
       print("no deviation")
     }
    
    indicatorView.frame = CGRect(x: self.frame.width - 17 + deviation, y: 0, width: 10, height: 10)
  }
}

