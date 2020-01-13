//
//  PrivacyPolicyViewController.swift
//  E6-0920
//
//  Created by yujinpil on 10/07/2019.
//  Copyright © 2019 jinpil. All rights reserved.
//

import UIKit

class PrivacyPolicyViewController: UIViewController {
  override func viewDidLoad() {
    let close = UIBarButtonItem(image: UIImage(named: "album_x"),
                                style: .plain,
                                target: self,
                                action: #selector(goBack(_:)))
    navigationItem.leftBarButtonItem = close
    navigationItem.leftBarButtonItem?.tintColor = .black
  }
  
  @objc private func goBack(_ sender: UIButton) {
    navigationController?.popViewController(animated: true)
  }
}
