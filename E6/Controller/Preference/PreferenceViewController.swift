//
//  PreferenceViewController.swift
//  E6-0920
//
//  Created by yujinpil on 28/06/2019.
//  Copyright © 2019 jinpil. All rights reserved.
//

import UIKit
import StoreKit

protocol PreferenceViewControllerDelegate: class {
  func passSlience(_ value: Bool)
  func passGrid(_ value: Bool)
}

class PreferenceViewController: UITableViewController {
  
  let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
  
  var delegate: PreferenceViewControllerDelegate?
  
  var isSilence: Bool = false
  
  var isGridOn: Bool = false

  @IBOutlet weak var versionLabel: UILabel!
  
  @IBOutlet weak var silenceButton: UISwitch!
  
  @IBOutlet weak var gridButton: UISwitch!
  
  @IBAction func dismissButtonDidTap(_ sender: Any) {
    dismiss(animated: true)
  }
  @IBAction func slienceSwitchDidTap(_ sender: UISwitch) {
    let isOn = sender.isOn
    self.delegate?.passSlience(isOn)
  }
  
  @IBAction func gridSwitchDidTap(_ sender: UISwitch) {
    let isOn = sender.isOn
    self.delegate?.passGrid(isOn)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    versionLabel.text = appVersion
    silenceButton.isOn = isSilence
    gridButton.isOn = isGridOn
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.section == 2 {
      if indexPath.row == 0 {
        
      }
      else if indexPath.row == 1 {
        
        let Username =  "e6.0920" // Your Instagram Username here
        let appURL = URL(string: "instagram://user?username=\(Username)")!
        let application = UIApplication.shared
        
        if application.canOpenURL(appURL) {
          application.open(appURL)
        } else {
          // if Instagram app is not installed, open URL inside Safari
          let webURL = URL(string: "https://instagram.com/\(Username)")!
          application.open(webURL)
        }
      }
      else if indexPath.row == 2 {
        SKStoreReviewController.requestReview()
      }
      else if indexPath.row == 4 {
        
      }
    }
  }
}
