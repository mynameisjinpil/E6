//
//  ElementButton.swift
//  E6
//
//  Created by yujinpil on 2019/10/16.
//  Copyright © 2019 portrayer. All rights reserved.
//

import UIKit

class SelectButton: UIButton {
  private var _isTapped: Bool!
  var isTapped: Bool! {
    set {
      self._isTapped = newValue
      if newValue {
        self.setTitleColor(.red, for: .normal)
      }
      else {
        self.setTitleColor(.white, for: .normal)
      }
    }
    get {
      return self._isTapped
    }
  }
  
  override var isHighlighted: Bool {
    didSet {
      if self.isHighlighted {
      }
      else {
      }
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    initState()
  }

  // MARK:- Custom Function
  
  func initState() {
    isTapped = false
    self.setTitleColor(.white, for: .normal)
    // icon make white
  }
}
